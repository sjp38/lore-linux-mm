Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C032628038C
	for <linux-mm@kvack.org>; Mon,  4 Sep 2017 21:04:10 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x78so3501222pff.7
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 18:04:10 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id n3si6002576pgr.150.2017.09.04.18.04.08
        for <linux-mm@kvack.org>;
        Mon, 04 Sep 2017 18:04:09 -0700 (PDT)
Date: Tue, 5 Sep 2017 10:03:59 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v8 11/14] lockdep: Apply crossrelease to PG_locked locks
Message-ID: <20170905010359.GQ3240@X58A-UD3R>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <1502089981-21272-12-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502089981-21272-12-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Mon, Aug 07, 2017 at 04:12:58PM +0900, Byungchul Park wrote:
> Although lock_page() and its family can cause deadlock, the lock
> correctness validator could not be applied to them until now, becasue
> things like unlock_page() might be called in a different context from
> the acquisition context, which violates lockdep's assumption.
> 
> Thanks to CONFIG_LOCKDEP_CROSSRELEASE, we can now apply the lockdep
> detector to page locks. Applied it.

I expect applying this into lock_page() is more useful than
wait_for_completion(). Could you consider this as the next?

> Signed-off-by: Byungchul Park <byungchul.park@lge.com>
> ---
>  include/linux/mm_types.h |   8 ++++
>  include/linux/pagemap.h  | 101 ++++++++++++++++++++++++++++++++++++++++++++---
>  lib/Kconfig.debug        |   8 ++++
>  mm/filemap.c             |   4 +-
>  mm/page_alloc.c          |   3 ++
>  5 files changed, 116 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index ff15181..f1e3dba 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -16,6 +16,10 @@
>  
>  #include <asm/mmu.h>
>  
> +#ifdef CONFIG_LOCKDEP_PAGELOCK
> +#include <linux/lockdep.h>
> +#endif
> +
>  #ifndef AT_VECTOR_SIZE_ARCH
>  #define AT_VECTOR_SIZE_ARCH 0
>  #endif
> @@ -216,6 +220,10 @@ struct page {
>  #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
>  	int _last_cpupid;
>  #endif
> +
> +#ifdef CONFIG_LOCKDEP_PAGELOCK
> +	struct lockdep_map_cross map;
> +#endif
>  }
>  /*
>   * The struct page can be forced to be double word aligned so that atomic ops
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 9717ca8..9f448c6 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -14,6 +14,9 @@
>  #include <linux/bitops.h>
>  #include <linux/hardirq.h> /* for in_interrupt() */
>  #include <linux/hugetlb_inline.h>
> +#ifdef CONFIG_LOCKDEP_PAGELOCK
> +#include <linux/lockdep.h>
> +#endif
>  
>  /*
>   * Bits in mapping->flags.
> @@ -450,26 +453,91 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
>  	return pgoff;
>  }
>  
> +#ifdef CONFIG_LOCKDEP_PAGELOCK
> +#define lock_page_init(p)						\
> +do {									\
> +	static struct lock_class_key __key;				\
> +	lockdep_init_map_crosslock((struct lockdep_map *)&(p)->map,	\
> +			"(PG_locked)" #p, &__key, 0);			\
> +} while (0)
> +
> +static inline void lock_page_acquire(struct page *page, int try)
> +{
> +	page = compound_head(page);
> +	lock_acquire_exclusive((struct lockdep_map *)&page->map, 0,
> +			       try, NULL, _RET_IP_);
> +}
> +
> +static inline void lock_page_release(struct page *page)
> +{
> +	page = compound_head(page);
> +	/*
> +	 * lock_commit_crosslock() is necessary for crosslocks.
> +	 */
> +	lock_commit_crosslock((struct lockdep_map *)&page->map);
> +	lock_release((struct lockdep_map *)&page->map, 0, _RET_IP_);
> +}
> +#else
> +static inline void lock_page_init(struct page *page) {}
> +static inline void lock_page_free(struct page *page) {}
> +static inline void lock_page_acquire(struct page *page, int try) {}
> +static inline void lock_page_release(struct page *page) {}
> +#endif
> +
>  extern void __lock_page(struct page *page);
>  extern int __lock_page_killable(struct page *page);
>  extern int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
>  				unsigned int flags);
> -extern void unlock_page(struct page *page);
> +extern void do_raw_unlock_page(struct page *page);
>  
> -static inline int trylock_page(struct page *page)
> +static inline void unlock_page(struct page *page)
> +{
> +	lock_page_release(page);
> +	do_raw_unlock_page(page);
> +}
> +
> +static inline int do_raw_trylock_page(struct page *page)
>  {
>  	page = compound_head(page);
>  	return (likely(!test_and_set_bit_lock(PG_locked, &page->flags)));
>  }
>  
> +static inline int trylock_page(struct page *page)
> +{
> +	if (do_raw_trylock_page(page)) {
> +		lock_page_acquire(page, 1);
> +		return 1;
> +	}
> +	return 0;
> +}
> +
>  /*
>   * lock_page may only be called if we have the page's inode pinned.
>   */
>  static inline void lock_page(struct page *page)
>  {
>  	might_sleep();
> -	if (!trylock_page(page))
> +
> +	if (!do_raw_trylock_page(page))
>  		__lock_page(page);
> +	/*
> +	 * acquire() must be after actual lock operation for crosslocks.
> +	 * This way a crosslock and current lock can be ordered like:
> +	 *
> +	 *	CONTEXT 1		CONTEXT 2
> +	 *	---------		---------
> +	 *	lock A (cross)
> +	 *	acquire A
> +	 *	  X = atomic_inc_return(&cross_gen_id)
> +	 *	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> +	 *				acquire B
> +	 *				  Y = atomic_read_acquire(&cross_gen_id)
> +	 *				lock B
> +	 *
> +	 * so that 'lock A and then lock B' can be seen globally,
> +	 * if X <= Y.
> +	 */
> +	lock_page_acquire(page, 0);
>  }
>  
>  /*
> @@ -479,9 +547,20 @@ static inline void lock_page(struct page *page)
>   */
>  static inline int lock_page_killable(struct page *page)
>  {
> +	int ret;
> +
>  	might_sleep();
> -	if (!trylock_page(page))
> -		return __lock_page_killable(page);
> +
> +	if (!do_raw_trylock_page(page)) {
> +		ret = __lock_page_killable(page);
> +		if (ret)
> +			return ret;
> +	}
> +	/*
> +	 * acquire() must be after actual lock operation for crosslocks.
> +	 * This way a crosslock and other locks can be ordered.
> +	 */
> +	lock_page_acquire(page, 0);
>  	return 0;
>  }
>  
> @@ -496,7 +575,17 @@ static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
>  				     unsigned int flags)
>  {
>  	might_sleep();
> -	return trylock_page(page) || __lock_page_or_retry(page, mm, flags);
> +
> +	if (do_raw_trylock_page(page) || __lock_page_or_retry(page, mm, flags)) {
> +		/*
> +		 * acquire() must be after actual lock operation for crosslocks.
> +		 * This way a crosslock and other locks can be ordered.
> +		 */
> +		lock_page_acquire(page, 0);
> +		return 1;
> +	}
> +
> +	return 0;
>  }
>  
>  /*
> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> index 4ba8adc..99b5f76 100644
> --- a/lib/Kconfig.debug
> +++ b/lib/Kconfig.debug
> @@ -1093,6 +1093,14 @@ config LOCKDEP_COMPLETE
>  	 A deadlock caused by wait_for_completion() and complete() can be
>  	 detected by lockdep using crossrelease feature.
>  
> +config LOCKDEP_PAGELOCK
> +	bool "Lock debugging: allow PG_locked lock to use deadlock detector"
> +	select LOCKDEP_CROSSRELEASE
> +	default n
> +	help
> +	 PG_locked lock is a kind of crosslock. Using crossrelease feature,
> +	 PG_locked lock can work with runtime deadlock detector.
> +
>  config PROVE_LOCKING
>  	bool "Lock debugging: prove locking correctness"
>  	depends on DEBUG_KERNEL && TRACE_IRQFLAGS_SUPPORT && STACKTRACE_SUPPORT && LOCKDEP_SUPPORT
> diff --git a/mm/filemap.c b/mm/filemap.c
> index a497024..0d83bf0 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1083,7 +1083,7 @@ static inline bool clear_bit_unlock_is_negative_byte(long nr, volatile void *mem
>   * portably (architectures that do LL/SC can test any bit, while x86 can
>   * test the sign bit).
>   */
> -void unlock_page(struct page *page)
> +void do_raw_unlock_page(struct page *page)
>  {
>  	BUILD_BUG_ON(PG_waiters != 7);
>  	page = compound_head(page);
> @@ -1091,7 +1091,7 @@ void unlock_page(struct page *page)
>  	if (clear_bit_unlock_is_negative_byte(PG_locked, &page->flags))
>  		wake_up_page_bit(page, PG_locked);
>  }
> -EXPORT_SYMBOL(unlock_page);
> +EXPORT_SYMBOL(do_raw_unlock_page);
>  
>  /**
>   * end_page_writeback - end writeback against a page
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6d30e91..2cbf412 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5406,6 +5406,9 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>  		} else {
>  			__init_single_pfn(pfn, zone, nid);
>  		}
> +#ifdef CONFIG_LOCKDEP_PAGELOCK
> +		lock_page_init(pfn_to_page(pfn));
> +#endif
>  	}
>  }
>  
> -- 
> 1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
