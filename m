Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 323C36B0038
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 08:42:53 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id g57so59791681qta.5
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 05:42:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u8si6364845qta.11.2017.03.17.05.42.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 05:42:52 -0700 (PDT)
Date: Fri, 17 Mar 2017 08:42:45 -0400
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH 1/5] mm, swap: Fix comment in __read_swap_cache_async
Message-ID: <20170317124244.GF956@xps>
References: <20170317064635.12792-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170317064635.12792-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Aaron Lu <aaron.lu@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 17, 2017 at 02:46:19PM +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> The commit cbab0e4eec29 ("swap: avoid read_swap_cache_async() race to
> deadlock while waiting on discard I/O completion") fixed a deadlock in
> read_swap_cache_async().  Because at that time, in swap allocation
> path, a swap entry may be set as SWAP_HAS_CACHE, then wait for
> discarding to complete before the page for the swap entry is added to
> the swap cache.  But in the commit 815c2c543d3a ("swap: make swap
> discard async"), the discarding for swap become asynchronous, waiting
> for discarding to complete will be done before the swap entry is set
> as SWAP_HAS_CACHE.  So the comments in code is incorrect now.  This
> patch fixes the comments.
> 
> The cond_resched() added in the commit cbab0e4eec29 is not necessary
> now too.  But if we added some sleep in swap allocation path in the
> future, there may be some hard to debug/reproduce deadlock bug.  So it
> is kept.
>

^ this is a rather disconcerting way to describe why you left that part
behind, and I recollect telling you about it in a private discussion.

The fact is that __read_swap_cache_async() still races against get_swap_page()
with a way narrower window due to the async fashioned SSD wear leveling 
done for swap nowadays and other changes made within __read_swap_cache_async()'s
while loop thus making that old deadlock scenario very improbable to strike again.

All seems legit, apart from that last paragraph in the commit log
message


Acked-by: Rafael Aquini <aquini@redhat.com>
 
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Rafael Aquini <aquini@redhat.com>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> ---
>  mm/swap_state.c | 12 +-----------
>  1 file changed, 1 insertion(+), 11 deletions(-)
> 
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 473b71e052a8..7bfb9bd1ca21 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -360,17 +360,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
>  			/*
>  			 * We might race against get_swap_page() and stumble
>  			 * across a SWAP_HAS_CACHE swap_map entry whose page
> -			 * has not been brought into the swapcache yet, while
> -			 * the other end is scheduled away waiting on discard
> -			 * I/O completion at scan_swap_map().
> -			 *
> -			 * In order to avoid turning this transitory state
> -			 * into a permanent loop around this -EEXIST case
> -			 * if !CONFIG_PREEMPT and the I/O completion happens
> -			 * to be waiting on the CPU waitqueue where we are now
> -			 * busy looping, we just conditionally invoke the
> -			 * scheduler here, if there are some more important
> -			 * tasks to run.
> +			 * has not been brought into the swapcache yet.
>  			 */
>  			cond_resched();
>  			continue;
> -- 
> 2.11.0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
