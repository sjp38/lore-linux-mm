Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2229A6B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 10:52:48 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id 63so1890879qgz.16
        for <linux-mm@kvack.org>; Thu, 15 May 2014 07:52:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 67si2674260qgl.191.2014.05.15.07.52.47
        for <linux-mm@kvack.org>;
        Thu, 15 May 2014 07:52:47 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] HWPOISON: avoid repeatedly raising some MCEs for a shared page
Date: Thu, 15 May 2014 10:52:39 -0400
Message-Id: <5374d4bf.c9158c0a.04b6.ffff893cSMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <1400152576-32004-1-git-send-email-slaoub@gmail.com>
References: <1400152576-32004-1-git-send-email-slaoub@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: slaoub@gmail.com
Cc: ak@linux.intel.com, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org

On Thu, May 15, 2014 at 07:16:16PM +0800, Chen Yucong wrote:
> We assume that there have three processes P1, P2, and P3 which share a
> page frame PF0. PF0 have a multi-bit error that has not yet been detected.
> 
> At some point, P1 has access to PF0 for loading data or fetching instruction.
> So a MCE related to PF0 has been raised and all logical processors have to
> entry do_machine_check() due to MCE-Broadcast mechanism. But only P1 need to
> execute memory_failure() due to TIF_MCE_NOTIFY signal. During the process of
> executing memory_failure(), both P2 and P3 have a probability of accessing
> the PF0. So they also can entry into memory_failure(), but they will return
> very soon due to the PG_hwpoison has been set by P1. However, P1 may not
> really isolate PF0, for example try_to_unmap() has not yet been executed. As
> a result, P1/P2 may raise the same MCE again.

How serious is this problem? Concurrent accesses for multi-bit memory errors
don't happen so often, and even if that happens we just waste a few CPU cycles.
So it seems to me hard to justify adding a new page flag for this specific purpose.

Thanks,
Naoya Horiguchi

> 
> Signed-off-by: Chen Yucong <slaoub@gmail.com>
> ---
>  include/linux/page-flags.h |    6 ++++++
>  include/linux/pagemap.h    |   27 +++++++++++++++++++++++++++
>  mm/filemap.c               |   30 ++++++++++++++++++++++++++++++
>  mm/memory-failure.c        |   11 +++++++++++
>  4 files changed, 74 insertions(+)
> 
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 8304959..c5c99a5 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -105,6 +105,7 @@ enum pageflags {
>  #endif
>  #ifdef CONFIG_MEMORY_FAILURE
>  	PG_hwpoison,		/* hardware poisoned page. Don't touch */
> +	PG_hwpoison_lock,
>  #endif
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  	PG_compound_lock,
> @@ -271,10 +272,15 @@ PAGEFLAG_FALSE(Uncached)
>  #ifdef CONFIG_MEMORY_FAILURE
>  PAGEFLAG(HWPoison, hwpoison)
>  TESTSCFLAG(HWPoison, hwpoison)
> +PAGEFLAG(HWPoisonLock, hwpoison_lock)
> +TESTSCFLAG(HWPoisonLock, hwpoison_lock)
>  #define __PG_HWPOISON (1UL << PG_hwpoison)
> +#define __PG_HWPOISON_LOCK (1UL << PG_hwpoison_lock)
>  #else
>  PAGEFLAG_FALSE(HWPoison)
>  #define __PG_HWPOISON 0
> +PAGEFLAG_FALSE(HWPoisonLock)
> +#define __PG_HWPOISON_LOCK 0
>  #endif
>  
>  u64 stable_page_flags(struct page *page);
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index c74f8bb..9c3bdcb 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -508,6 +508,33 @@ static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
>  	return trylock_page(page) || __lock_page_or_retry(page, mm, flags);
>  }
>  
> +#ifdef CONFIG_MEMORY_FAILURE
> +extern void __lock_hwpoison_page(struct page *page);
> +extern void unlock_hwpoison_page(struct page *page);
> +
> +static inline void __set_page_hwpoison_lock(struct page *page)
> +{
> +	__set_bit(PG_hwpoison_lock, &page->flags);
> +}
> +
> +static inline void __clear_page_hwpoison_lock(struct page *page)
> +{
> +	__clear_bit(PG_hwpoison_lock, &page->flags);
> +}
> +
> +static inline int trylock_hwpoison_page(struct page *page)
> +{
> +	return likely(!test_and_set_bit_lock(PG_hwpoison_lock, &page->flags));
> +}
> +
> +static inline void lock_hwpoison_page(struct page *page)
> +{
> +	might_sleep();
> +	if (!trylock_hwpoison_page(page))
> +		__lock_hwpoison_page(page);
> +}
> +#endif
> +
>  /*
>   * This is exported only for wait_on_page_locked/wait_on_page_writeback.
>   * Never use this directly!
> diff --git a/mm/filemap.c b/mm/filemap.c
> index bec4b9b..9162527 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -843,6 +843,36 @@ int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
>  	}
>  }
>  
> +#ifdef CONFIG_MEMORY_FAILURE
> +/**
> + * unlock_hwpoison_page -unlock a poisonous page
> + * @page: the page
> + * Unlocks the poisonous page and wakes up sleeper in __wait_on_bit_lock().
> + */
> +void unlock_hwpoison_page(struct page *page)
> +{
> +	VM_BUG_ON(!PageHWPoisonLock(page));
> +	clear_bit_unlock(PG_hwpoison_lock, &page->flags);
> +	smp_mb__after_clear_bit();
> +	wake_up_page(page, PG_hwpoison_lock);
> +}
> +EXPORT_SYMBOL(unlock_hwpoison_page);
> +
> +/**
> + * __lock_hwpoison_page - get a lock one the poisonous page, assuming
> + * we need to sleep to get it
> + * @page: the posionous page to lock
> + */
> +void __lock_hwpoison_page(struct page *page)
> +{
> +	DEFINE_WAIT_BIT(wait, &page->flags, PG_hwpoison_lock);
> +
> +	__wait_on_bit_lock(page_waitqueue(page), &wait, sleep_on_page,
> +							TASK_UNINTERRUPTIBLE);
> +}
> +EXPORT_SYMBOL(__lock_hwpoison_page);
> +#endif
> +
>  /**
>   * page_cache_next_hole - find the next hole (not-present entry)
>   * @mapping: mapping
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 9872af1..f839a54 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1041,9 +1041,11 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>  	}
>  
>  	p = pfn_to_page(pfn);
> +	lock_hwpoison_page(p);
>  	hpage = compound_head(p);
>  	if (TestSetPageHWPoison(p)) {
>  		printk(KERN_ERR "MCE %#lx: already hardware poisoned\n", pfn);
> +		unlock_hwpoison_page(p);
>  		return 0;
>  	}
>  
> @@ -1078,6 +1080,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>  		!get_page_unless_zero(hpage)) {
>  		if (is_free_buddy_page(p)) {
>  			action_result(pfn, "free buddy", DELAYED);
> +			unlock_hwpoison_page(p);
>  			return 0;
>  		} else if (PageHuge(hpage)) {
>  			/*
> @@ -1089,6 +1092,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>  				    || (p != hpage && TestSetPageHWPoison(hpage))) {
>  					atomic_long_sub(nr_pages, &num_poisoned_pages);
>  					unlock_page(hpage);
> +					unlock_hwpoison_page(p);
>  					return 0;
>  				}
>  			}
> @@ -1097,9 +1101,11 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>  			action_result(pfn, "free huge",
>  				      res ? IGNORED : DELAYED);
>  			unlock_page(hpage);
> +			unlock_hwpoison_page(p);
>  			return res;
>  		} else {
>  			action_result(pfn, "high order kernel", IGNORED);
> +			unlock_hwpoison_page(p);
>  			return -EBUSY;
>  		}
>  	}
> @@ -1124,10 +1130,12 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>  					action_result(pfn, "free buddy", DELAYED);
>  				else
>  					action_result(pfn, "free buddy, 2nd try", DELAYED);
> +				unlock_hwpoison_page(p);
>  				return 0;
>  			}
>  			action_result(pfn, "non LRU", IGNORED);
>  			put_page(p);
> +			unlock_hwpoison_page(p);
>  			return -EBUSY;
>  		}
>  	}
> @@ -1161,6 +1169,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>  			atomic_long_sub(nr_pages, &num_poisoned_pages);
>  		unlock_page(hpage);
>  		put_page(hpage);
> +		unlock_hwpoison_page(p);
>  		return 0;
>  	}
>  
> @@ -1173,6 +1182,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>  				IGNORED);
>  		unlock_page(hpage);
>  		put_page(hpage);
> +		unlock_hwpoison_page(p);
>  		return 0;
>  	}
>  	/*
> @@ -1228,6 +1238,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>  	res = page_action(ps, p, pfn);
>  out:
>  	unlock_page(hpage);
> +	unlock_hwpoison_page(p);
>  	return res;
>  }
>  EXPORT_SYMBOL_GPL(memory_failure);
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
