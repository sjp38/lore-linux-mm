Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 51EF66B0032
	for <linux-mm@kvack.org>; Thu, 30 May 2013 15:55:54 -0400 (EDT)
Date: Thu, 30 May 2013 15:55:39 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] swap: avoid read_swap_cache_async() race to deadlock
 while waiting on discard I/O compeletion
Message-ID: <20130530195539.GA27226@cmpxchg.org>
References: <2434dea05a7fda7e7ccf48f70124bd65f2556b2d.1369935749.git.aquini@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2434dea05a7fda7e7ccf48f70124bd65f2556b2d.1369935749.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, shli@kernel.org, riel@redhat.com, lwoodman@redhat.com, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, stable@vger.kernel.org

On Thu, May 30, 2013 at 03:05:00PM -0300, Rafael Aquini wrote:
> read_swap_cache_async() can race against get_swap_page(), and stumble across
> a SWAP_HAS_CACHE entry in the swap map whose page wasn't brought into the
> swapcache yet. This transient swap_map state is expected to be transitory,
> but the actual placement of discard at scan_swap_map() inserts a wait for
> I/O completion thus making the thread at read_swap_cache_async() to loop
> around its -EEXIST case, while the other end at get_swap_page()
> is scheduled away at scan_swap_map(). This can leave the system deadlocked
> if the I/O completion happens to be waiting on the CPU workqueue where

waitqueue?

> read_swap_cache_async() is busy looping and !CONFIG_PREEMPT.
> 
> This patch introduces a cond_resched() call to make the aforementioned
> read_swap_cache_async() busy loop condition to bail out when necessary,
> thus avoiding the subtle race window.
> 
> Signed-off-by: Rafael Aquini <aquini@redhat.com>
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

Might be worth mentioning the !CONFIG_PREEMPT deadlock scenario here,
especially since under CONFIG_PREEMPT the radix_tree_preload_end() is
already a scheduling point through the preempt_enable().

Other than that, the patch looks good to me!

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
