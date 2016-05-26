Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 87A076B007E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 19:15:32 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fg1so130602286pad.1
        for <linux-mm@kvack.org>; Thu, 26 May 2016 16:15:32 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id b1si23715255pax.45.2016.05.26.16.15.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 May 2016 16:15:31 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id b124so35254244pfb.0
        for <linux-mm@kvack.org>; Thu, 26 May 2016 16:15:31 -0700 (PDT)
Subject: Re: [PATCH] mm: check the return value of lookup_page_ext for all
 call sites
References: <1464023768-31025-1-git-send-email-yang.shi@linaro.org>
 <20160524025811.GA29094@bbox> <20160526003719.GB9661@bbox>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <8ae0197c-47b7-e5d2-20c3-eb9d01e6b65c@linaro.org>
Date: Thu, 26 May 2016 16:15:28 -0700
MIME-Version: 1.0
In-Reply-To: <20160526003719.GB9661@bbox>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On 5/25/2016 5:37 PM, Minchan Kim wrote:
> On Tue, May 24, 2016 at 11:58:11AM +0900, Minchan Kim wrote:
>> On Mon, May 23, 2016 at 10:16:08AM -0700, Yang Shi wrote:
>>> Per the discussion with Joonsoo Kim [1], we need check the return value of
>>> lookup_page_ext() for all call sites since it might return NULL in some cases,
>>> although it is unlikely, i.e. memory hotplug.
>>>
>>> Tested with ltp with "page_owner=0".
>>>
>>> [1] http://lkml.kernel.org/r/20160519002809.GA10245@js1304-P5Q-DELUXE
>>>
>>> Signed-off-by: Yang Shi <yang.shi@linaro.org>
>>
>> I didn't read code code in detail to see how page_ext memory space
>> allocated in boot code and memory hotplug but to me, it's not good
>> to check NULL whenever we calls lookup_page_ext.
>>
>> More dangerous thing is now page_ext is used by optionable feature(ie, not
>> critical for system stability) but if we want to use page_ext as
>> another important tool for the system in future,
>> it could be a serious problem.
>>
>> Can we put some hooks of page_ext into memory-hotplug so guarantee
>> that page_ext memory space is allocated with memmap space at the
>> same time? IOW, once every PFN wakers find a page is valid, page_ext
>> is valid, too so lookup_page_ext never returns NULL on valid page
>> by design.
>>
>> I hope we consider this direction, too.
>
> Yang, Could you think about this?

Thanks a lot for the suggestion. Sorry for the late reply, I was busy on 
preparing patches. I do agree this is a direction we should look into, 
but I haven't got time to think about it deeper. I hope Joonsoo could 
chime in too since he is the original author for page extension.

>
> Even, your patch was broken, I think.
> It doesn't work with !CONFIG_DEBUG_VM && !CONFIG_PAGE_POISONING because
> lookup_page_ext doesn't return NULL in that case.

Actually, I think the #ifdef should be removed if lookup_page_ext() is 
possible to return NULL. It sounds not make sense returning NULL only 
when DEBUG_VM is enabled. It should return NULL no matter what debug 
config is selected. If Joonsoo agrees with me I'm going to come up with 
a patch to fix it.

Regards,
Yang

>
>>
>> Thanks.
>>
>>> ---
>>>  include/linux/page_idle.h | 43 ++++++++++++++++++++++++++++++++++++-------
>>>  mm/page_alloc.c           |  6 ++++++
>>>  mm/page_owner.c           | 27 +++++++++++++++++++++++++++
>>>  mm/page_poison.c          |  8 +++++++-
>>>  mm/vmstat.c               |  2 ++
>>>  5 files changed, 78 insertions(+), 8 deletions(-)
>>>
>>> diff --git a/include/linux/page_idle.h b/include/linux/page_idle.h
>>> index bf268fa..8f5d4ad 100644
>>> --- a/include/linux/page_idle.h
>>> +++ b/include/linux/page_idle.h
>>> @@ -46,33 +46,62 @@ extern struct page_ext_operations page_idle_ops;
>>>
>>>  static inline bool page_is_young(struct page *page)
>>>  {
>>> -	return test_bit(PAGE_EXT_YOUNG, &lookup_page_ext(page)->flags);
>>> +	struct page_ext *page_ext;
>>> +	page_ext = lookup_page_ext(page);
>>> +	if (unlikely(!page_ext)
>>> +		return false;
>>> +
>>> +	return test_bit(PAGE_EXT_YOUNG, &page_ext->flags);
>>>  }
>>>
>>>  static inline void set_page_young(struct page *page)
>>>  {
>>> -	set_bit(PAGE_EXT_YOUNG, &lookup_page_ext(page)->flags);
>>> +	struct page_ext *page_ext;
>>> +	page_ext = lookup_page_ext(page);
>>> +	if (unlikely(!page_ext)
>>> +		return;
>>> +
>>> +	set_bit(PAGE_EXT_YOUNG, &page_ext->flags);
>>>  }
>>>
>>>  static inline bool test_and_clear_page_young(struct page *page)
>>>  {
>>> -	return test_and_clear_bit(PAGE_EXT_YOUNG,
>>> -				  &lookup_page_ext(page)->flags);
>>> +	struct page_ext *page_ext;
>>> +	page_ext = lookup_page_ext(page);
>>> +	if (unlikely(!page_ext)
>>> +		return false;
>>> +
>>> +	return test_and_clear_bit(PAGE_EXT_YOUNG, &page_ext->flags);
>>>  }
>>>
>>>  static inline bool page_is_idle(struct page *page)
>>>  {
>>> -	return test_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
>>> +	struct page_ext *page_ext;
>>> +	page_ext = lookup_page_ext(page);
>>> +	if (unlikely(!page_ext)
>>> +		return false;
>>> +
>>> +	return test_bit(PAGE_EXT_IDLE, &page_ext->flags);
>>>  }
>>>
>>>  static inline void set_page_idle(struct page *page)
>>>  {
>>> -	set_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
>>> +	struct page_ext *page_ext;
>>> +	page_ext = lookup_page_ext(page);
>>> +	if (unlikely(!page_ext)
>>> +		return;
>>> +
>>> +	set_bit(PAGE_EXT_IDLE, &page_ext->flags);
>>>  }
>>>
>>>  static inline void clear_page_idle(struct page *page)
>>>  {
>>> -	clear_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
>>> +	struct page_ext *page_ext;
>>> +	page_ext = lookup_page_ext(page);
>>> +	if (unlikely(!page_ext)
>>> +		return;
>>> +
>>> +	clear_bit(PAGE_EXT_IDLE, &page_ext->flags);
>>>  }
>>>  #endif /* CONFIG_64BIT */
>>>
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index f8f3bfc..d27e8b9 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -656,6 +656,9 @@ static inline void set_page_guard(struct zone *zone, struct page *page,
>>>  		return;
>>>
>>>  	page_ext = lookup_page_ext(page);
>>> +	if (unlikely(!page_ext))
>>> +		return;
>>> +
>>>  	__set_bit(PAGE_EXT_DEBUG_GUARD, &page_ext->flags);
>>>
>>>  	INIT_LIST_HEAD(&page->lru);
>>> @@ -673,6 +676,9 @@ static inline void clear_page_guard(struct zone *zone, struct page *page,
>>>  		return;
>>>
>>>  	page_ext = lookup_page_ext(page);
>>> +	if (unlikely(!page_ext))
>>> +		return;
>>> +
>>>  	__clear_bit(PAGE_EXT_DEBUG_GUARD, &page_ext->flags);
>>>
>>>  	set_page_private(page, 0);
>>> diff --git a/mm/page_owner.c b/mm/page_owner.c
>>> index 792b56d..902e398 100644
>>> --- a/mm/page_owner.c
>>> +++ b/mm/page_owner.c
>>> @@ -55,6 +55,8 @@ void __reset_page_owner(struct page *page, unsigned int order)
>>>
>>>  	for (i = 0; i < (1 << order); i++) {
>>>  		page_ext = lookup_page_ext(page + i);
>>> +		if (unlikely(!page_ext))
>>> +			continue;
>>>  		__clear_bit(PAGE_EXT_OWNER, &page_ext->flags);
>>>  	}
>>>  }
>>> @@ -62,6 +64,10 @@ void __reset_page_owner(struct page *page, unsigned int order)
>>>  void __set_page_owner(struct page *page, unsigned int order, gfp_t gfp_mask)
>>>  {
>>>  	struct page_ext *page_ext = lookup_page_ext(page);
>>> +
>>> +	if (unlikely(!page_ext))
>>> +		return;
>>> +
>>>  	struct stack_trace trace = {
>>>  		.nr_entries = 0,
>>>  		.max_entries = ARRAY_SIZE(page_ext->trace_entries),
>>> @@ -82,6 +88,8 @@ void __set_page_owner(struct page *page, unsigned int order, gfp_t gfp_mask)
>>>  void __set_page_owner_migrate_reason(struct page *page, int reason)
>>>  {
>>>  	struct page_ext *page_ext = lookup_page_ext(page);
>>> +	if (unlikely(!page_ext))
>>> +		return;
>>>
>>>  	page_ext->last_migrate_reason = reason;
>>>  }
>>> @@ -89,6 +97,12 @@ void __set_page_owner_migrate_reason(struct page *page, int reason)
>>>  gfp_t __get_page_owner_gfp(struct page *page)
>>>  {
>>>  	struct page_ext *page_ext = lookup_page_ext(page);
>>> +	if (unlikely(!page_ext))
>>> +		/*
>>> +		 * The caller just returns 0 if no valid gfp
>>> +		 * So return 0 here too.
>>> +		 */
>>> +		return 0;
>>>
>>>  	return page_ext->gfp_mask;
>>>  }
>>> @@ -97,6 +111,10 @@ void __copy_page_owner(struct page *oldpage, struct page *newpage)
>>>  {
>>>  	struct page_ext *old_ext = lookup_page_ext(oldpage);
>>>  	struct page_ext *new_ext = lookup_page_ext(newpage);
>>> +
>>> +	if (unlikely(!old_ext || !new_ext))
>>> +		return;
>>> +
>>>  	int i;
>>>
>>>  	new_ext->order = old_ext->order;
>>> @@ -186,6 +204,11 @@ err:
>>>  void __dump_page_owner(struct page *page)
>>>  {
>>>  	struct page_ext *page_ext = lookup_page_ext(page);
>>> +	if (unlikely(!page_ext)) {
>>> +		pr_alert("There is not page extension available.\n");
>>> +		return;
>>> +	}
>>> +
>>>  	struct stack_trace trace = {
>>>  		.nr_entries = page_ext->nr_entries,
>>>  		.entries = &page_ext->trace_entries[0],
>>> @@ -251,6 +274,8 @@ read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
>>>  		}
>>>
>>>  		page_ext = lookup_page_ext(page);
>>> +		if (unlikely(!page_ext))
>>> +			continue;
>>>
>>>  		/*
>>>  		 * Some pages could be missed by concurrent allocation or free,
>>> @@ -317,6 +342,8 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
>>>  				continue;
>>>
>>>  			page_ext = lookup_page_ext(page);
>>> +			if (unlikely(!page_ext))
>>> +				continue;
>>>
>>>  			/* Maybe overraping zone */
>>>  			if (test_bit(PAGE_EXT_OWNER, &page_ext->flags))
>>> diff --git a/mm/page_poison.c b/mm/page_poison.c
>>> index 1eae5fa..2e647c6 100644
>>> --- a/mm/page_poison.c
>>> +++ b/mm/page_poison.c
>>> @@ -54,6 +54,9 @@ static inline void set_page_poison(struct page *page)
>>>  	struct page_ext *page_ext;
>>>
>>>  	page_ext = lookup_page_ext(page);
>>> +	if (unlikely(!page_ext))
>>> +		return;
>>> +
>>>  	__set_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
>>>  }
>>>
>>> @@ -62,6 +65,9 @@ static inline void clear_page_poison(struct page *page)
>>>  	struct page_ext *page_ext;
>>>
>>>  	page_ext = lookup_page_ext(page);
>>> +	if (unlikely(!page_ext))
>>> +		return;
>>> +
>>>  	__clear_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
>>>  }
>>>
>>> @@ -70,7 +76,7 @@ bool page_is_poisoned(struct page *page)
>>>  	struct page_ext *page_ext;
>>>
>>>  	page_ext = lookup_page_ext(page);
>>> -	if (!page_ext)
>>> +	if (unlikely(!page_ext))
>>>  		return false;
>>>
>>>  	return test_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
>>> diff --git a/mm/vmstat.c b/mm/vmstat.c
>>> index 77e42ef..cb2a67b 100644
>>> --- a/mm/vmstat.c
>>> +++ b/mm/vmstat.c
>>> @@ -1061,6 +1061,8 @@ static void pagetypeinfo_showmixedcount_print(struct seq_file *m,
>>>  				continue;
>>>
>>>  			page_ext = lookup_page_ext(page);
>>> +			if (unlikely(!page_ext))
>>> +				continue;
>>>
>>>  			if (!test_bit(PAGE_EXT_OWNER, &page_ext->flags))
>>>  				continue;
>>> --
>>> 2.0.2
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
