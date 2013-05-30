Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id A223D6B0033
	for <linux-mm@kvack.org>; Thu, 30 May 2013 18:02:24 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id 14so1090786pdc.25
        for <linux-mm@kvack.org>; Thu, 30 May 2013 15:02:23 -0700 (PDT)
Date: Thu, 30 May 2013 15:02:22 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] swap: avoid read_swap_cache_async() race to deadlock
 while waiting on discard I/O compeletion
In-Reply-To: <2434dea05a7fda7e7ccf48f70124bd65f2556b2d.1369935749.git.aquini@redhat.com>
Message-ID: <alpine.LNX.2.00.1305301458100.11425@eggly.anvils>
References: <2434dea05a7fda7e7ccf48f70124bd65f2556b2d.1369935749.git.aquini@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, shli@kernel.org, riel@redhat.com, lwoodman@redhat.com, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, stable@vger.kernel.org

On Thu, 30 May 2013, Rafael Aquini wrote:

> read_swap_cache_async() can race against get_swap_page(), and stumble across
> a SWAP_HAS_CACHE entry in the swap map whose page wasn't brought into the
> swapcache yet. This transient swap_map state is expected to be transitory,
> but the actual placement of discard at scan_swap_map() inserts a wait for
> I/O completion thus making the thread at read_swap_cache_async() to loop
> around its -EEXIST case, while the other end at get_swap_page()
> is scheduled away at scan_swap_map(). This can leave the system deadlocked
> if the I/O completion happens to be waiting on the CPU workqueue where
> read_swap_cache_async() is busy looping and !CONFIG_PREEMPT.
> 
> This patch introduces a cond_resched() call to make the aforementioned
> read_swap_cache_async() busy loop condition to bail out when necessary,
> thus avoiding the subtle race window.

Yes, I never realized this at the time I inserted discard there.
As you know, Shaohua has a better swap discard implementation, which
avoids the problem by using SWAP_MAP_BAD, but this cond_resched() is
a good simple workaround for now - thanks.

> 
> Signed-off-by: Rafael Aquini <aquini@redhat.com>

Acked-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org

> ---
>  mm/swap_state.c | 14 +++++++++++++-
>  1 file changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index b3d40dc..9ad9e3b 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -336,8 +336,20 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
>  		 * Swap entry may have been freed since our caller observed it.
>  		 */
>  		err = swapcache_prepare(entry);
> -		if (err == -EEXIST) {	/* seems racy */
> +		if (err == -EEXIST) {
>  			radix_tree_preload_end();
> +			/*
> +			 * We might race against get_swap_page() and stumble
> +			 * across a SWAP_HAS_CACHE swap_map entry whose page
> +			 * has not been brought into the swapcache yet, while
> +			 * the other end is scheduled away waiting on discard
> +			 * I/O completion.
> +			 * In order to avoid turning this transitory state
> +			 * into a permanent loop around this -EEXIST case,
> +			 * lets just conditionally invoke the scheduler,
> +			 * if there are some more important tasks to run.
> +			 */
> +			cond_resched();
>  			continue;
>  		}
>  		if (err) {		/* swp entry is obsolete ? */
> -- 
> 1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
