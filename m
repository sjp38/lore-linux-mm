Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4564B6B0038
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 22:46:37 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id p66so9918003pga.4
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 19:46:37 -0800 (PST)
Received: from mail-pg0-x22c.google.com (mail-pg0-x22c.google.com. [2607:f8b0:400e:c05::22c])
        by mx.google.com with ESMTPS id i6si26112065pfa.90.2016.11.21.19.46.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 19:46:36 -0800 (PST)
Received: by mail-pg0-x22c.google.com with SMTP id f188so2629805pgc.3
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 19:46:36 -0800 (PST)
Date: Mon, 21 Nov 2016 19:46:28 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2] mm: support anonymous stable page
In-Reply-To: <20161120233015.GA14113@bbox>
Message-ID: <alpine.LSU.2.11.1611211932410.1085@eggly.anvils>
References: <20161120233015.GA14113@bbox>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Darrick J . Wong" <darrick.wong@oracle.com>, Hyeoncheol Lee <cheol.lee@lge.com>, yjay.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 21 Nov 2016, Minchan Kim wrote:
> From: Minchan Kim <minchan@kernel.org>
> Date: Fri, 11 Nov 2016 15:02:57 +0900
> Subject: [PATCH v2] mm: support anonymous stable page
> 
> For developemnt for zram-swap asynchronous writeback, I found
> strange corruption of compressed page. With investigation, it
> reveals currently stable page doesn't support anonymous page.
> IOW, reuse_swap_page can reuse the page without waiting
> writeback completion so that it can corrupt data during
> zram compression. It can affect every swap device which supports
> asynchronous writeback and CRC checking as well as zRAM.
> 
> Unfortunately, reuse_swap_page should be atomic so that we
> cannot wait on writeback in there so the approach in this patch
> is simply return false if we found it needs stable page.
> Although it increases memory footprint temporarily, it happens
> rarely and it should be reclaimed easily althoug it happened.
> Also, It would be better than waiting of IO completion, which
> is critial path for application latency.
> 
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Darrick J. Wong <darrick.wong@oracle.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Hugh Dickins <hughd@google.com>

Looks good, thanks: we can always optimize away that little overhead
in the PageWriteback case, if it ever shows up in someone's testing.

Andrew might ask if we should Cc stable (haha): I think we agree
that it's a defect we've been aware of ever since stable pages were
first proposed, but nobody has actually been troubled by it before
your async zram development: so, you're right to be fixing it ahead
of your zram changes, but we don't see a call for backporting.

> ---
> * from v1
>  * use swap_info_struct instead of swapper_space->host inode - Hugh
> 
>  include/linux/swap.h |  3 ++-
>  mm/swapfile.c        | 20 +++++++++++++++++++-
>  2 files changed, 21 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index a56523cefb9b..55ff5593c193 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -150,8 +150,9 @@ enum {
>  	SWP_FILE	= (1 << 7),	/* set after swap_activate success */
>  	SWP_AREA_DISCARD = (1 << 8),	/* single-time swap area discards */
>  	SWP_PAGE_DISCARD = (1 << 9),	/* freed swap page-cluster discards */
> +	SWP_STABLE_WRITES = (1 << 10),	/* no overwrite PG_writeback pages */
>  					/* add others here before... */
> -	SWP_SCANNING	= (1 << 10),	/* refcount in scan_swap_map */
> +	SWP_SCANNING	= (1 << 11),	/* refcount in scan_swap_map */
>  };
>  
>  #define SWAP_CLUSTER_MAX 32UL
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 2210de290b54..66bc330c0b65 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -943,11 +943,25 @@ bool reuse_swap_page(struct page *page, int *total_mapcount)
>  	count = page_trans_huge_mapcount(page, total_mapcount);
>  	if (count <= 1 && PageSwapCache(page)) {
>  		count += page_swapcount(page);
> -		if (count == 1 && !PageWriteback(page)) {
> +		if (count != 1)
> +			goto out;
> +		if (!PageWriteback(page)) {
>  			delete_from_swap_cache(page);
>  			SetPageDirty(page);
> +		} else {
> +			swp_entry_t entry;
> +			struct swap_info_struct *p;
> +
> +			entry.val = page_private(page);
> +			p = swap_info_get(entry);
> +			if (p->flags & SWP_STABLE_WRITES) {
> +				spin_unlock(&p->lock);
> +				return false;
> +			}
> +			spin_unlock(&p->lock);
>  		}
>  	}
> +out:
>  	return count <= 1;
>  }
>  
> @@ -2447,6 +2461,10 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  		error = -ENOMEM;
>  		goto bad_swap;
>  	}
> +
> +	if (bdi_cap_stable_pages_required(inode_to_bdi(inode)))
> +		p->flags |= SWP_STABLE_WRITES;
> +
>  	if (p->bdev && blk_queue_nonrot(bdev_get_queue(p->bdev))) {
>  		int cpu;
>  
> -- 
> 2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
