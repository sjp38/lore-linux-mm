Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f44.google.com (mail-vn0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id 708F46B0038
	for <linux-mm@kvack.org>; Sat, 11 Apr 2015 06:42:32 -0400 (EDT)
Received: by vnbg1 with SMTP id g1so10779877vnb.2
        for <linux-mm@kvack.org>; Sat, 11 Apr 2015 03:42:32 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id a17si3773060obf.53.2015.04.11.03.42.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 11 Apr 2015 03:42:31 -0700 (PDT)
Message-ID: <5528FA74.5020902@huawei.com>
Date: Sat, 11 Apr 2015 18:41:56 +0800
From: Xie XiuQi <xiexiuqi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 1/2] memory-failure: export page_type and action
 result
References: <1428404731-21565-1-git-send-email-xiexiuqi@huawei.com> <1428404731-21565-2-git-send-email-xiexiuqi@huawei.com> <20150408014524.GB24617@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20150408014524.GB24617@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "rostedt@goodmis.org" <rostedt@goodmis.org>, "mingo@redhat.com" <mingo@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "koct9i@gmail.com" <koct9i@gmail.com>, "hpa@linux.intel.com" <hpa@linux.intel.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "luto@amacapital.net" <luto@amacapital.net>, "nasa4836@gmail.com" <nasa4836@gmail.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "bhelgaas@google.com" <bhelgaas@google.com>, "bp@suse.de" <bp@suse.de>, "tony.luck@intel.com" <tony.luck@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 2015/4/8 9:45, Naoya Horiguchi wrote:
> On Tue, Apr 07, 2015 at 07:05:30PM +0800, Xie XiuQi wrote:
>> Export 'outcome' and 'page_type' to mm.h, so we could use this emnus
>> outside.
>>
>> This patch is preparation for adding trace events for memory-failure
>> recovery action.
>>
>> Signed-off-by: Xie XiuQi <xiexiuqi@huawei.com>
> 
> I made some update on mm/memory-failure.c, so some more rebasing is needed.
> Please see mm-memory-failurec-define-page-types-for-action_result-in-one-place-v3
> in latest linux-mmotm.

OK, I will

> 
> Other than that, this patch looks good to me.

Thanks!

> 
> Thanks,
> Naoya Horiguchi
> 
>> ---
>>  include/linux/mm.h  |  34 +++++++++++
>>  mm/memory-failure.c | 163 +++++++++++++++++++++-------------------------------
>>  2 files changed, 99 insertions(+), 98 deletions(-)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 4a3a385..5d812b0 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -2114,6 +2114,40 @@ extern void shake_page(struct page *p, int access);
>>  extern atomic_long_t num_poisoned_pages;
>>  extern int soft_offline_page(struct page *page, int flags);
>>  
>> +
>> +/*
>> + * Error handlers for various types of pages.
>> + */
>> +enum mf_outcome {
>> +	MF_IGNORED,	/* Error: cannot be handled */
>> +	MF_FAILED,	/* Error: handling failed */
>> +	MF_DELAYED,	/* Will be handled later */
>> +	MF_RECOVERED,	/* Successfully recovered */
>> +};
>> +
>> +enum mf_page_type {
>> +	MF_KERNEL,
>> +	MF_KERNEL_HIGH_ORDER,
>> +	MF_SLAB,
>> +	MF_DIFFERENT_COMPOUND,
>> +	MF_POISONED_HUGE,
>> +	MF_HUGE,
>> +	MF_FREE_HUGE,
>> +	MF_UNMAP_FAILED,
>> +	MF_DIRTY_SWAPCACHE,
>> +	MF_CLEAN_SWAPCACHE,
>> +	MF_DIRTY_MLOCKED_LRU,
>> +	MF_CLEAN_MLOCKED_LRU,
>> +	MF_DIRTY_UNEVICTABLE_LRU,
>> +	MF_CLEAN_UNEVICTABLE_LRU,
>> +	MF_DIRTY_LRU,
>> +	MF_CLEAN_LRU,
>> +	MF_TRUNCATED_LRU,
>> +	MF_BUDDY,
>> +	MF_BUDDY_2ND,
>> +	MF_UNKNOWN,
>> +};
>> +
>>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
>>  extern void clear_huge_page(struct page *page,
>>  			    unsigned long addr,
>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>> index 5074998..34e9c65 100644
>> --- a/mm/memory-failure.c
>> +++ b/mm/memory-failure.c
>> @@ -56,6 +56,7 @@
>>  #include <linux/mm_inline.h>
>>  #include <linux/kfifo.h>
>>  #include "internal.h"
>> +#include "ras/ras_event.h"
>>  
>>  int sysctl_memory_failure_early_kill __read_mostly = 0;
>>  
>> @@ -503,68 +504,34 @@ static void collect_procs(struct page *page, struct list_head *tokill,
>>  	kfree(tk);
>>  }
>>  
>> -/*
>> - * Error handlers for various types of pages.
>> - */
>> -
>> -enum outcome {
>> -	IGNORED,	/* Error: cannot be handled */
>> -	FAILED,		/* Error: handling failed */
>> -	DELAYED,	/* Will be handled later */
>> -	RECOVERED,	/* Successfully recovered */
>> -};
>> -
>>  static const char *action_name[] = {
>> -	[IGNORED] = "Ignored",
>> -	[FAILED] = "Failed",
>> -	[DELAYED] = "Delayed",
>> -	[RECOVERED] = "Recovered",
>> -};
>> -
>> -enum page_type {
>> -	KERNEL,
>> -	KERNEL_HIGH_ORDER,
>> -	SLAB,
>> -	DIFFERENT_COMPOUND,
>> -	POISONED_HUGE,
>> -	HUGE,
>> -	FREE_HUGE,
>> -	UNMAP_FAILED,
>> -	DIRTY_SWAPCACHE,
>> -	CLEAN_SWAPCACHE,
>> -	DIRTY_MLOCKED_LRU,
>> -	CLEAN_MLOCKED_LRU,
>> -	DIRTY_UNEVICTABLE_LRU,
>> -	CLEAN_UNEVICTABLE_LRU,
>> -	DIRTY_LRU,
>> -	CLEAN_LRU,
>> -	TRUNCATED_LRU,
>> -	BUDDY,
>> -	BUDDY_2ND,
>> -	UNKNOWN,
>> +	[MF_IGNORED] = "Ignored",
>> +	[MF_FAILED] = "Failed",
>> +	[MF_DELAYED] = "Delayed",
>> +	[MF_RECOVERED] = "Recovered",
>>  };
>>  
>>  static const char *action_page_type[] = {
>> -	[KERNEL]		= "reserved kernel page",
>> -	[KERNEL_HIGH_ORDER]	= "high-order kernel page",
>> -	[SLAB]			= "kernel slab page",
>> -	[DIFFERENT_COMPOUND]	= "different compound page after locking",
>> -	[POISONED_HUGE]		= "huge page already hardware poisoned",
>> -	[HUGE]			= "huge page",
>> -	[FREE_HUGE]		= "free huge page",
>> -	[UNMAP_FAILED]		= "unmapping failed page",
>> -	[DIRTY_SWAPCACHE]	= "dirty swapcache page",
>> -	[CLEAN_SWAPCACHE]	= "clean swapcache page",
>> -	[DIRTY_MLOCKED_LRU]	= "dirty mlocked LRU page",
>> -	[CLEAN_MLOCKED_LRU]	= "clean mlocked LRU page",
>> -	[DIRTY_UNEVICTABLE_LRU]	= "dirty unevictable LRU page",
>> -	[CLEAN_UNEVICTABLE_LRU]	= "clean unevictable LRU page",
>> -	[DIRTY_LRU]		= "dirty LRU page",
>> -	[CLEAN_LRU]		= "clean LRU page",
>> -	[TRUNCATED_LRU]		= "already truncated LRU page",
>> -	[BUDDY]			= "free buddy page",
>> -	[BUDDY_2ND]		= "free buddy page (2nd try)",
>> -	[UNKNOWN]		= "unknown page",
>> +	[MF_KERNEL]			= "reserved kernel page",
>> +	[MF_KERNEL_HIGH_ORDER]		= "high-order kernel page",
>> +	[MF_SLAB]			= "kernel slab page",
>> +	[MF_DIFFERENT_COMPOUND]		= "different compound page after locking",
>> +	[MF_POISONED_HUGE]		= "huge page already hardware poisoned",
>> +	[MF_HUGE]			= "huge page",
>> +	[MF_FREE_HUGE]			= "free huge page",
>> +	[MF_UNMAP_FAILED]		= "unmapping failed page",
>> +	[MF_DIRTY_SWAPCACHE]		= "dirty swapcache page",
>> +	[MF_CLEAN_SWAPCACHE]		= "clean swapcache page",
>> +	[MF_DIRTY_MLOCKED_LRU]		= "dirty mlocked LRU page",
>> +	[MF_CLEAN_MLOCKED_LRU]		= "clean mlocked LRU page",
>> +	[MF_DIRTY_UNEVICTABLE_LRU]	= "dirty unevictable LRU page",
>> +	[MF_CLEAN_UNEVICTABLE_LRU]	= "clean unevictable LRU page",
>> +	[MF_DIRTY_LRU]			= "dirty LRU page",
>> +	[MF_CLEAN_LRU]			= "clean LRU page",
>> +	[MF_TRUNCATED_LRU]		= "already truncated LRU page",
>> +	[MF_BUDDY]			= "free buddy page",
>> +	[MF_BUDDY_2ND]			= "free buddy page (2nd try)",
>> +	[MF_UNKNOWN]			= "unknown page",
>>  };
>>  
>>  /*
>> @@ -598,7 +565,7 @@ static int delete_from_lru_cache(struct page *p)
>>   */
>>  static int me_kernel(struct page *p, unsigned long pfn)
>>  {
>> -	return IGNORED;
>> +	return MF_IGNORED;
>>  }
>>  
>>  /*
>> @@ -607,7 +574,7 @@ static int me_kernel(struct page *p, unsigned long pfn)
>>  static int me_unknown(struct page *p, unsigned long pfn)
>>  {
>>  	printk(KERN_ERR "MCE %#lx: Unknown page state\n", pfn);
>> -	return FAILED;
>> +	return MF_FAILED;
>>  }
>>  
>>  /*
>> @@ -616,7 +583,7 @@ static int me_unknown(struct page *p, unsigned long pfn)
>>  static int me_pagecache_clean(struct page *p, unsigned long pfn)
>>  {
>>  	int err;
>> -	int ret = FAILED;
>> +	int ret = MF_FAILED;
>>  	struct address_space *mapping;
>>  
>>  	delete_from_lru_cache(p);
>> @@ -626,7 +593,7 @@ static int me_pagecache_clean(struct page *p, unsigned long pfn)
>>  	 * should be the one m_f() holds.
>>  	 */
>>  	if (PageAnon(p))
>> -		return RECOVERED;
>> +		return MF_RECOVERED;
>>  
>>  	/*
>>  	 * Now truncate the page in the page cache. This is really
>> @@ -640,7 +607,7 @@ static int me_pagecache_clean(struct page *p, unsigned long pfn)
>>  		/*
>>  		 * Page has been teared down in the meanwhile
>>  		 */
>> -		return FAILED;
>> +		return MF_FAILED;
>>  	}
>>  
>>  	/*
>> @@ -657,7 +624,7 @@ static int me_pagecache_clean(struct page *p, unsigned long pfn)
>>  				!try_to_release_page(p, GFP_NOIO)) {
>>  			pr_info("MCE %#lx: failed to release buffers\n", pfn);
>>  		} else {
>> -			ret = RECOVERED;
>> +			ret = MF_RECOVERED;
>>  		}
>>  	} else {
>>  		/*
>> @@ -665,7 +632,7 @@ static int me_pagecache_clean(struct page *p, unsigned long pfn)
>>  		 * This fails on dirty or anything with private pages
>>  		 */
>>  		if (invalidate_inode_page(p))
>> -			ret = RECOVERED;
>> +			ret = MF_RECOVERED;
>>  		else
>>  			printk(KERN_INFO "MCE %#lx: Failed to invalidate\n",
>>  				pfn);
>> @@ -751,9 +718,9 @@ static int me_swapcache_dirty(struct page *p, unsigned long pfn)
>>  	ClearPageUptodate(p);
>>  
>>  	if (!delete_from_lru_cache(p))
>> -		return DELAYED;
>> +		return MF_DELAYED;
>>  	else
>> -		return FAILED;
>> +		return MF_FAILED;
>>  }
>>  
>>  static int me_swapcache_clean(struct page *p, unsigned long pfn)
>> @@ -761,9 +728,9 @@ static int me_swapcache_clean(struct page *p, unsigned long pfn)
>>  	delete_from_swap_cache(p);
>>  
>>  	if (!delete_from_lru_cache(p))
>> -		return RECOVERED;
>> +		return MF_RECOVERED;
>>  	else
>> -		return FAILED;
>> +		return MF_FAILED;
>>  }
>>  
>>  /*
>> @@ -789,9 +756,9 @@ static int me_huge_page(struct page *p, unsigned long pfn)
>>  	if (!(page_mapping(hpage) || PageAnon(hpage))) {
>>  		res = dequeue_hwpoisoned_huge_page(hpage);
>>  		if (!res)
>> -			return RECOVERED;
>> +			return MF_RECOVERED;
>>  	}
>> -	return DELAYED;
>> +	return MF_DELAYED;
>>  }
>>  
>>  /*
>> @@ -826,7 +793,7 @@ static struct page_state {
>>  	int type;
>>  	int (*action)(struct page *p, unsigned long pfn);
>>  } error_states[] = {
>> -	{ reserved,	reserved,	KERNEL,	me_kernel },
>> +	{ reserved,	reserved,	MF_KERNEL,	me_kernel },
>>  	/*
>>  	 * free pages are specially detected outside this table:
>>  	 * PG_buddy pages only make a small fraction of all free pages.
>> @@ -837,31 +804,31 @@ static struct page_state {
>>  	 * currently unused objects without touching them. But just
>>  	 * treat it as standard kernel for now.
>>  	 */
>> -	{ slab,		slab,		SLAB,	me_kernel },
>> +	{ slab,		slab,		MF_SLAB,	me_kernel },
>>  
>>  #ifdef CONFIG_PAGEFLAGS_EXTENDED
>> -	{ head,		head,		HUGE,		me_huge_page },
>> -	{ tail,		tail,		HUGE,		me_huge_page },
>> +	{ head,		head,		MF_HUGE,		me_huge_page },
>> +	{ tail,		tail,		MF_HUGE,		me_huge_page },
>>  #else
>> -	{ compound,	compound,	HUGE,		me_huge_page },
>> +	{ compound,	compound,	MF_HUGE,		me_huge_page },
>>  #endif
>>  
>> -	{ sc|dirty,	sc|dirty,	DIRTY_SWAPCACHE,	me_swapcache_dirty },
>> -	{ sc|dirty,	sc,		CLEAN_SWAPCACHE,	me_swapcache_clean },
>> +	{ sc|dirty,	sc|dirty,	MF_DIRTY_SWAPCACHE,	me_swapcache_dirty },
>> +	{ sc|dirty,	sc,		MF_CLEAN_SWAPCACHE,	me_swapcache_clean },
>>  
>> -	{ mlock|dirty,	mlock|dirty,	DIRTY_MLOCKED_LRU,	me_pagecache_dirty },
>> -	{ mlock|dirty,	mlock,		CLEAN_MLOCKED_LRU,	me_pagecache_clean },
>> +	{ mlock|dirty,	mlock|dirty,	MF_DIRTY_MLOCKED_LRU,	me_pagecache_dirty },
>> +	{ mlock|dirty,	mlock,		MF_CLEAN_MLOCKED_LRU,	me_pagecache_clean },
>>  
>> -	{ unevict|dirty, unevict|dirty,	DIRTY_UNEVICTABLE_LRU,	me_pagecache_dirty },
>> -	{ unevict|dirty, unevict,	CLEAN_UNEVICTABLE_LRU,	me_pagecache_clean },
>> +	{ unevict|dirty, unevict|dirty,	MF_DIRTY_UNEVICTABLE_LRU,	me_pagecache_dirty },
>> +	{ unevict|dirty, unevict,	MF_CLEAN_UNEVICTABLE_LRU,	me_pagecache_clean },
>>  
>> -	{ lru|dirty,	lru|dirty,	DIRTY_LRU,	me_pagecache_dirty },
>> -	{ lru|dirty,	lru,		CLEAN_LRU,	me_pagecache_clean },
>> +	{ lru|dirty,	lru|dirty,	MF_DIRTY_LRU,	me_pagecache_dirty },
>> +	{ lru|dirty,	lru,		MF_CLEAN_LRU,	me_pagecache_clean },
>>  
>>  	/*
>>  	 * Catchall entry: must be at end.
>>  	 */
>> -	{ 0,		0,		UNKNOWN,	me_unknown },
>> +	{ 0,		0,		MF_UNKNOWN,	me_unknown },
>>  };
>>  
>>  #undef dirty
>> @@ -896,13 +863,13 @@ static int page_action(struct page_state *ps, struct page *p,
>>  	result = ps->action(p, pfn);
>>  
>>  	count = page_count(p) - 1;
>> -	if (ps->action == me_swapcache_dirty && result == DELAYED)
>> +	if (ps->action == me_swapcache_dirty && result == MF_DELAYED)
>>  		count--;
>>  	if (count != 0) {
>>  		printk(KERN_ERR
>>  		       "MCE %#lx: %s still referenced by %d users\n",
>>  		       pfn, action_page_type[ps->type], count);
>> -		result = FAILED;
>> +		result = MF_FAILED;
>>  	}
>>  	action_result(pfn, ps->type, result);
>>  
>> @@ -911,7 +878,7 @@ static int page_action(struct page_state *ps, struct page *p,
>>  	 * Could adjust zone counters here to correct for the missing page.
>>  	 */
>>  
>> -	return (result == RECOVERED || result == DELAYED) ? 0 : -EBUSY;
>> +	return (result == MF_RECOVERED || result == MF_DELAYED) ? 0 : -EBUSY;
>>  }
>>  
>>  /*
>> @@ -1152,7 +1119,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>>  	if (!(flags & MF_COUNT_INCREASED) &&
>>  		!get_page_unless_zero(hpage)) {
>>  		if (is_free_buddy_page(p)) {
>> -			action_result(pfn, BUDDY, DELAYED);
>> +			action_result(pfn, MF_BUDDY, MF_DELAYED);
>>  			return 0;
>>  		} else if (PageHuge(hpage)) {
>>  			/*
>> @@ -1169,12 +1136,12 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>>  			}
>>  			set_page_hwpoison_huge_page(hpage);
>>  			res = dequeue_hwpoisoned_huge_page(hpage);
>> -			action_result(pfn, FREE_HUGE,
>> -				      res ? IGNORED : DELAYED);
>> +			action_result(pfn, MF_FREE_HUGE,
>> +				      res ? MF_IGNORED : MF_DELAYED);
>>  			unlock_page(hpage);
>>  			return res;
>>  		} else {
>> -			action_result(pfn, KERNEL_HIGH_ORDER, IGNORED);
>> +			action_result(pfn, MF_KERNEL_HIGH_ORDER, MF_IGNORED);
>>  			return -EBUSY;
>>  		}
>>  	}
>> @@ -1196,9 +1163,9 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>>  			 */
>>  			if (is_free_buddy_page(p)) {
>>  				if (flags & MF_COUNT_INCREASED)
>> -					action_result(pfn, BUDDY, DELAYED);
>> +					action_result(pfn, MF_BUDDY, MF_DELAYED);
>>  				else
>> -					action_result(pfn, BUDDY_2ND, DELAYED);
>> +					action_result(pfn, MF_BUDDY_2ND, MF_DELAYED);
>>  				return 0;
>>  			}
>>  		}
>> @@ -1211,7 +1178,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>>  	 * If this happens just bail out.
>>  	 */
>>  	if (compound_head(p) != hpage) {
>> -		action_result(pfn, DIFFERENT_COMPOUND, IGNORED);
>> +		action_result(pfn, MF_DIFFERENT_COMPOUND, MF_IGNORED);
>>  		res = -EBUSY;
>>  		goto out;
>>  	}
>> @@ -1251,7 +1218,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>>  	 * on the head page to show that the hugepage is hwpoisoned
>>  	 */
>>  	if (PageHuge(p) && PageTail(p) && TestSetPageHWPoison(hpage)) {
>> -		action_result(pfn, POISONED_HUGE, IGNORED);
>> +		action_result(pfn, MF_POISONED_HUGE, MF_IGNORED);
>>  		unlock_page(hpage);
>>  		put_page(hpage);
>>  		return 0;
>> @@ -1280,7 +1247,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>>  	 */
>>  	if (hwpoison_user_mappings(p, pfn, trapno, flags, &hpage)
>>  	    != SWAP_SUCCESS) {
>> -		action_result(pfn, UNMAP_FAILED, IGNORED);
>> +		action_result(pfn, MF_UNMAP_FAILED, MF_IGNORED);
>>  		res = -EBUSY;
>>  		goto out;
>>  	}
>> @@ -1289,7 +1256,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>>  	 * Torn down by someone else?
>>  	 */
>>  	if (PageLRU(p) && !PageSwapCache(p) && p->mapping == NULL) {
>> -		action_result(pfn, TRUNCATED_LRU, IGNORED);
>> +		action_result(pfn, MF_TRUNCATED_LRU, MF_IGNORED);
>>  		res = -EBUSY;
>>  		goto out;
>>  	}
>> -- 
>> 1.8.3.1
>>
> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
