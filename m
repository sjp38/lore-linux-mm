Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AFD2A6B0038
	for <linux-mm@kvack.org>; Thu,  4 May 2017 23:07:58 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c2so23953773pfd.9
        for <linux-mm@kvack.org>; Thu, 04 May 2017 20:07:58 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id e126si3932355pfg.115.2017.05.04.20.07.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 May 2017 20:07:57 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH] swap: add block io poll in swapin path
References: <7dd0349ba5d321af557d7a09e08610f2486ea29e.1493930299.git.shli@fb.com>
Date: Fri, 05 May 2017 11:07:54 +0800
In-Reply-To: <7dd0349ba5d321af557d7a09e08610f2486ea29e.1493930299.git.shli@fb.com>
	(Shaohua Li's message of "Thu, 4 May 2017 13:42:25 -0700")
Message-ID: <87shkk0zn9.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Kernel-team@fb.com, Tim Chen <tim.c.chen@intel.com>, Huang Ying <ying.huang@intel.com>, Jens Axboe <axboe@fb.com>

Hi, Shaohua,

Shaohua Li <shli@fb.com> writes:

> For fast flash disk, async IO could introduce overhead because of
> context switch. block-mq now supports IO poll, which improves
> performance and latency a lot. swapin is a good place to use this
> technique, because the task is waitting for the swapin page to continue
> execution.
>
> In my virtual machine, directly read 4k data from a NVMe with iopoll is
> about 60% better than that without poll. With iopoll support in swapin
> patch, my microbenchmark (a task does random memory write) is about 10%
> ~ 25% faster.

How many concurrent processes/threads for memory writing in your test?

In general, I think polling is a good way to reduce swap in latency for
high speed NVMe disk.

I have a question.  If the load of NVMe disk is high, for example, there
is quite some swap out occurs at the same time of swap in, the latency
of swap in may be much higher too.  Then, under the max swap in latency,
the overhead of polling may be high.  For example, it may be not an
issue to pool for 10us, but it is more serious if we poll for 500us or
1ms.  Is there some way to resolve this?  Can we set a threshold for
polling?  Then if we poll for more than the threshold, we will go to
sleep.

Best Regards,
Huang, Ying

> CPU utilization increases a lot though, 2x and even 3x CPU
> utilization. This will depend on disk speed though. While iopoll in
> swapin isn't intended for all usage cases, it's a win for latency
> sensistive workloads with high speed swap disk. block layer has knob to
> control poll in runtime. If poll isn't enabled in block layer, there
> should be no noticeable change in swapin.
>
> The swapin readahead might read several pages in in the same time and
> form a big IO request. Since the IO will take longer time, it doesn't
> make sense to do poll, so the patch only does iopoll for single page
> swapin.
>
> Cc: Tim Chen <tim.c.chen@intel.com>
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Jens Axboe <axboe@fb.com>
> Signed-off-by: Shaohua Li <shli@fb.com>
> ---
>  include/linux/swap.h |  5 +++--
>  mm/madvise.c         |  4 ++--
>  mm/page_io.c         | 20 ++++++++++++++++++--
>  mm/swap_state.c      | 10 ++++++----
>  mm/swapfile.c        |  2 +-
>  5 files changed, 30 insertions(+), 11 deletions(-)
>
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index ba58824..c589e6c 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -331,7 +331,7 @@ extern void kswapd_stop(int nid);
>  #include <linux/blk_types.h> /* for bio_end_io_t */
>  
>  /* linux/mm/page_io.c */
> -extern int swap_readpage(struct page *);
> +extern int swap_readpage(struct page *, bool do_poll);
>  extern int swap_writepage(struct page *page, struct writeback_control *wbc);
>  extern void end_swap_bio_write(struct bio *bio);
>  extern int __swap_writepage(struct page *page, struct writeback_control *wbc,
> @@ -362,7 +362,8 @@ extern void free_page_and_swap_cache(struct page *);
>  extern void free_pages_and_swap_cache(struct page **, int);
>  extern struct page *lookup_swap_cache(swp_entry_t);
>  extern struct page *read_swap_cache_async(swp_entry_t, gfp_t,
> -			struct vm_area_struct *vma, unsigned long addr);
> +			struct vm_area_struct *vma, unsigned long addr,
> +			bool do_poll);
>  extern struct page *__read_swap_cache_async(swp_entry_t, gfp_t,
>  			struct vm_area_struct *vma, unsigned long addr,
>  			bool *new_page_allocated);
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 25b78ee..8eda184 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -205,7 +205,7 @@ static int swapin_walk_pmd_entry(pmd_t *pmd, unsigned long start,
>  			continue;
>  
>  		page = read_swap_cache_async(entry, GFP_HIGHUSER_MOVABLE,
> -								vma, index);
> +							vma, index, false);
>  		if (page)
>  			put_page(page);
>  	}
> @@ -246,7 +246,7 @@ static void force_shm_swapin_readahead(struct vm_area_struct *vma,
>  		}
>  		swap = radix_to_swp_entry(page);
>  		page = read_swap_cache_async(swap, GFP_HIGHUSER_MOVABLE,
> -								NULL, 0);
> +							NULL, 0, false);
>  		if (page)
>  			put_page(page);
>  	}
> diff --git a/mm/page_io.c b/mm/page_io.c
> index 23f6d0d..464cf16 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -117,6 +117,7 @@ static void swap_slot_free_notify(struct page *page)
>  static void end_swap_bio_read(struct bio *bio)
>  {
>  	struct page *page = bio->bi_io_vec[0].bv_page;
> +	struct task_struct *waiter = bio->bi_private;
>  
>  	if (bio->bi_error) {
>  		SetPageError(page);
> @@ -133,6 +134,7 @@ static void end_swap_bio_read(struct bio *bio)
>  out:
>  	unlock_page(page);
>  	bio_put(bio);
> +	wake_up_process(waiter);
>  }
>  
>  int generic_swapfile_activate(struct swap_info_struct *sis,
> @@ -329,11 +331,13 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
>  	return ret;
>  }
>  
> -int swap_readpage(struct page *page)
> +int swap_readpage(struct page *page, bool do_poll)
>  {
>  	struct bio *bio;
>  	int ret = 0;
>  	struct swap_info_struct *sis = page_swap_info(page);
> +	blk_qc_t qc;
> +	struct block_device *bdev;
>  
>  	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
> @@ -372,9 +376,21 @@ int swap_readpage(struct page *page)
>  		ret = -ENOMEM;
>  		goto out;
>  	}
> +	bdev = bio->bi_bdev;
> +	bio->bi_private = current;
>  	bio_set_op_attrs(bio, REQ_OP_READ, 0);
>  	count_vm_event(PSWPIN);
> -	submit_bio(bio);
> +	qc = submit_bio(bio);
> +	while (do_poll) {
> +		set_current_state(TASK_UNINTERRUPTIBLE);
> +		if (!PageLocked(page))
> +			break;
> +
> +		if (!blk_mq_poll(bdev_get_queue(bdev), qc))
> +			break;
> +	}
> +	__set_current_state(TASK_RUNNING);
> +
>  out:
>  	return ret;
>  }
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 539b888..7c0a66c 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -404,14 +404,14 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
>   * the swap entry is no longer in use.
>   */
>  struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
> -			struct vm_area_struct *vma, unsigned long addr)
> +			struct vm_area_struct *vma, unsigned long addr, bool do_poll)
>  {
>  	bool page_was_allocated;
>  	struct page *retpage = __read_swap_cache_async(entry, gfp_mask,
>  			vma, addr, &page_was_allocated);
>  
>  	if (page_was_allocated)
> -		swap_readpage(retpage);
> +		swap_readpage(retpage, do_poll);
>  
>  	return retpage;
>  }
> @@ -488,11 +488,13 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
>  	unsigned long start_offset, end_offset;
>  	unsigned long mask;
>  	struct blk_plug plug;
> +	bool do_poll = true;
>  
>  	mask = swapin_nr_pages(offset) - 1;
>  	if (!mask)
>  		goto skip;
>  
> +	do_poll = false;
>  	/* Read a page_cluster sized and aligned cluster around offset. */
>  	start_offset = offset & ~mask;
>  	end_offset = offset | mask;
> @@ -503,7 +505,7 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
>  	for (offset = start_offset; offset <= end_offset ; offset++) {
>  		/* Ok, do the async read-ahead now */
>  		page = read_swap_cache_async(swp_entry(swp_type(entry), offset),
> -						gfp_mask, vma, addr);
> +						gfp_mask, vma, addr, false);
>  		if (!page)
>  			continue;
>  		if (offset != entry_offset)
> @@ -514,7 +516,7 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
>  
>  	lru_add_drain();	/* Push any new pages onto the LRU now */
>  skip:
> -	return read_swap_cache_async(entry, gfp_mask, vma, addr);
> +	return read_swap_cache_async(entry, gfp_mask, vma, addr, do_poll);
>  }
>  
>  int init_swap_address_space(unsigned int type, unsigned long nr_pages)
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 4f6cba1..04516c1 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1719,7 +1719,7 @@ int try_to_unuse(unsigned int type, bool frontswap,
>  		swap_map = &si->swap_map[i];
>  		entry = swp_entry(type, i);
>  		page = read_swap_cache_async(entry,
> -					GFP_HIGHUSER_MOVABLE, NULL, 0);
> +					GFP_HIGHUSER_MOVABLE, NULL, 0, false);
>  		if (!page) {
>  			/*
>  			 * Either swap_duplicate() failed because entry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
