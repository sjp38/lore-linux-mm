Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id EC5446B0062
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 19:44:43 -0400 (EDT)
Date: Tue, 5 Jun 2012 16:44:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] swap: allow swap readahead to be merged
Message-Id: <20120605164442.c7d12faa.akpm@linux-foundation.org>
In-Reply-To: <1338798803-5009-2-git-send-email-ehrhardt@linux.vnet.ibm.com>
References: <1338798803-5009-1-git-send-email-ehrhardt@linux.vnet.ibm.com>
	<1338798803-5009-2-git-send-email-ehrhardt@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ehrhardt@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, axboe@kernel.dk, hughd@google.com, minchan@kernel.org

On Mon,  4 Jun 2012 10:33:22 +0200
ehrhardt@linux.vnet.ibm.com wrote:

> From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
> 
> Swap readahead works fine, but the I/O to disk is almost always done in page
> size requests, despite the fact that readahead submits 1<<page-cluster pages
> at a time.
> On older kernels the old per device plugging behavior might have captured
> this and merged the requests, but currently all comes down to much more I/Os
> than required.

Yes, long ago we (ie: I) decided that swap I/O isn't sufficiently
common to bother doing any fancy high-level aggregation: just toss it
at the queue and use the general BIO merging.

> On a single device this might not be an issue, but as soon as a server runs
> on shared san resources savin I/Os not only improves swapin throughput but
> also provides a lower resource utilization.
> 
> With a load running KVM in a lot of memory overcommitment (the hot memory
> is 1.5 times the host memory) swapping throughput improves significantly
> and the lead feels more responsive as well as achieves more throughput.
> 
> In a test setup with 16 swap disks running blocktrace on one of those disks
> shows the improved merging:
> Prior:
> Reads Queued:     560,888,    2,243MiB  Writes Queued:     226,242,  904,968KiB
> Read Dispatches:  544,701,    2,243MiB  Write Dispatches:  159,318,  904,968KiB
> Reads Requeued:         0               Writes Requeued:         0
> Reads Completed:  544,716,    2,243MiB  Writes Completed:  159,321,  904,980KiB
> Read Merges:       16,187,   64,748KiB  Write Merges:       61,744,  246,976KiB
> IO unplugs:       149,614               Timer unplugs:       2,940
> 
> With the patch:
> Reads Queued:     734,315,    2,937MiB  Writes Queued:     300,188,    1,200MiB
> Read Dispatches:  214,972,    2,937MiB  Write Dispatches:  215,176,    1,200MiB
> Reads Requeued:         0               Writes Requeued:         0
> Reads Completed:  214,971,    2,937MiB  Writes Completed:  215,177,    1,200MiB
> Read Merges:      519,343,    2,077MiB  Write Merges:       73,325,  293,300KiB
> IO unplugs:       337,130               Timer unplugs:      11,184

This is rather hard to understand.  How much faster did it get?

> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -14,6 +14,7 @@
>  #include <linux/init.h>
>  #include <linux/pagemap.h>
>  #include <linux/backing-dev.h>
> +#include <linux/blkdev.h>
>  #include <linux/pagevec.h>
>  #include <linux/migrate.h>
>  #include <linux/page_cgroup.h>
> @@ -376,6 +377,7 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
>  	unsigned long offset = swp_offset(entry);
>  	unsigned long start_offset, end_offset;
>  	unsigned long mask = (1UL << page_cluster) - 1;
> +	struct blk_plug plug;
>  
>  	/* Read a page_cluster sized and aligned cluster around offset. */
>  	start_offset = offset & ~mask;
> @@ -383,6 +385,7 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
>  	if (!start_offset)	/* First page is swap header. */
>  		start_offset++;
>  
> +	blk_start_plug(&plug);
>  	for (offset = start_offset; offset <= end_offset ; offset++) {
>  		/* Ok, do the async read-ahead now */
>  		page = read_swap_cache_async(swp_entry(swp_type(entry), offset),
> @@ -391,6 +394,8 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
>  			continue;
>  		page_cache_release(page);
>  	}
> +	blk_finish_plug(&plug);
> +
>  	lru_add_drain();	/* Push any new pages onto the LRU now */
>  	return read_swap_cache_async(entry, gfp_mask, vma, addr);

AFACIT this affects tmpfs as well, and it would be
interesting/useful/diligent to check for performance improvements or
regressions in that area.

And the patch doesn't help swapoff, in try_to_unuse().  Or any other
callers of swap_readpage(), if they exist.

The switch to explicit plugging might have caused swap regressions in
other areas so perhaps a more extensive patch is needed.  But
swapin_readahead() covers most cases and a more extensive patch will
work OK with this one, so I guess we run witht he simple patch for now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
