Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 442656B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 16:17:23 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g64so149871295pfb.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 13:17:23 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id c1si30480884pas.37.2016.05.27.13.17.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 13:17:21 -0700 (PDT)
Received: by mail-pa0-x235.google.com with SMTP id bz2so13336644pad.1
        for <linux-mm@kvack.org>; Fri, 27 May 2016 13:17:21 -0700 (PDT)
Subject: Re: [PATCH] mm: check the return value of lookup_page_ext for all
 call sites
References: <1464023768-31025-1-git-send-email-yang.shi@linaro.org>
 <20160524025811.GA29094@bbox> <20160526003719.GB9661@bbox>
 <8ae0197c-47b7-e5d2-20c3-eb9d01e6b65c@linaro.org>
 <20160527130246.4adb78f29e15d19fae80419a@linux-foundation.org>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <ab9cf30c-4979-07af-6732-e647078ef579@linaro.org>
Date: Fri, 27 May 2016 13:17:19 -0700
MIME-Version: 1.0
In-Reply-To: <20160527130246.4adb78f29e15d19fae80419a@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On 5/27/2016 1:02 PM, Andrew Morton wrote:
> On Thu, 26 May 2016 16:15:28 -0700 "Shi, Yang" <yang.shi@linaro.org> wrote:
>
>>>>
>>>> I hope we consider this direction, too.
>>>
>>> Yang, Could you think about this?
>>
>> Thanks a lot for the suggestion. Sorry for the late reply, I was busy on
>> preparing patches. I do agree this is a direction we should look into,
>> but I haven't got time to think about it deeper. I hope Joonsoo could
>> chime in too since he is the original author for page extension.
>>
>>>
>>> Even, your patch was broken, I think.
>>> It doesn't work with !CONFIG_DEBUG_VM && !CONFIG_PAGE_POISONING because
>>> lookup_page_ext doesn't return NULL in that case.
>>
>> Actually, I think the #ifdef should be removed if lookup_page_ext() is
>> possible to return NULL. It sounds not make sense returning NULL only
>> when DEBUG_VM is enabled. It should return NULL no matter what debug
>> config is selected. If Joonsoo agrees with me I'm going to come up with
>> a patch to fix it.
>>
>
> I've lost the plot here.  What is the status of this patch?
>
> Latest version:

Yes, this is the latest version. We are discussing about some future 
optimization.

And, Minchan Kim pointed out a possible race condition which exists even 
before this patch. I proposed a quick fix, as long as they are happy to 
the fix, I will post it to the mailing list.

Thanks,
Yang

>
> From: Yang Shi <yang.shi@linaro.org>
> Subject: mm: check the return value of lookup_page_ext for all call sites
>
> Per the discussion with Joonsoo Kim [1], we need check the return value of
> lookup_page_ext() for all call sites since it might return NULL in some
> cases, although it is unlikely, i.e.  memory hotplug.
>
> Tested with ltp with "page_owner=0".
>
> [1] http://lkml.kernel.org/r/20160519002809.GA10245@js1304-P5Q-DELUXE
>
> [akpm@linux-foundation.org: fix build-breaking typos]
> [arnd@arndb.de: fix build problems from lookup_page_ext]
>   Link: http://lkml.kernel.org/r/6285269.2CksypHdYp@wuerfel
> [akpm@linux-foundation.org: coding-style fixes]
> Link: http://lkml.kernel.org/r/1464023768-31025-1-git-send-email-yang.shi@linaro.org
> Signed-off-by: Yang Shi <yang.shi@linaro.org>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
>  include/linux/page_idle.h |   43 ++++++++++++++++++++++++++++++------
>  mm/page_alloc.c           |    6 +++++
>  mm/page_owner.c           |   26 +++++++++++++++++++++
>  mm/page_poison.c          |    8 +++++-
>  mm/vmstat.c               |    2 +
>  5 files changed, 77 insertions(+), 8 deletions(-)
>
> diff -puN include/linux/page_idle.h~mm-check-the-return-value-of-lookup_page_ext-for-all-call-sites include/linux/page_idle.h
> --- a/include/linux/page_idle.h~mm-check-the-return-value-of-lookup_page_ext-for-all-call-sites
> +++ a/include/linux/page_idle.h
> @@ -46,33 +46,62 @@ extern struct page_ext_operations page_i
>
>  static inline bool page_is_young(struct page *page)
>  {
> -	return test_bit(PAGE_EXT_YOUNG, &lookup_page_ext(page)->flags);
> +	struct page_ext *page_ext = lookup_page_ext(page);
> +
> +	if (unlikely(!page_ext))
> +		return false;
> +
> +	return test_bit(PAGE_EXT_YOUNG, &page_ext->flags);
>  }
>
>  static inline void set_page_young(struct page *page)
>  {
> -	set_bit(PAGE_EXT_YOUNG, &lookup_page_ext(page)->flags);
> +	struct page_ext *page_ext = lookup_page_ext(page);
> +
> +	if (unlikely(!page_ext))
> +		return;
> +
> +	set_bit(PAGE_EXT_YOUNG, &page_ext->flags);
>  }
>
>  static inline bool test_and_clear_page_young(struct page *page)
>  {
> -	return test_and_clear_bit(PAGE_EXT_YOUNG,
> -				  &lookup_page_ext(page)->flags);
> +	struct page_ext *page_ext = lookup_page_ext(page);
> +
> +	if (unlikely(!page_ext))
> +		return false;
> +
> +	return test_and_clear_bit(PAGE_EXT_YOUNG, &page_ext->flags);
>  }
>
>  static inline bool page_is_idle(struct page *page)
>  {
> -	return test_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
> +	struct page_ext *page_ext = lookup_page_ext(page);
> +
> +	if (unlikely(!page_ext))
> +		return false;
> +
> +	return test_bit(PAGE_EXT_IDLE, &page_ext->flags);
>  }
>
>  static inline void set_page_idle(struct page *page)
>  {
> -	set_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
> +	struct page_ext *page_ext = lookup_page_ext(page);
> +
> +	if (unlikely(!page_ext))
> +		return;
> +
> +	set_bit(PAGE_EXT_IDLE, &page_ext->flags);
>  }
>
>  static inline void clear_page_idle(struct page *page)
>  {
> -	clear_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
> +	struct page_ext *page_ext = lookup_page_ext(page);
> +
> +	if (unlikely(!page_ext))
> +		return;
> +
> +	clear_bit(PAGE_EXT_IDLE, &page_ext->flags);
>  }
>  #endif /* CONFIG_64BIT */
>
> diff -puN mm/page_alloc.c~mm-check-the-return-value-of-lookup_page_ext-for-all-call-sites mm/page_alloc.c
> --- a/mm/page_alloc.c~mm-check-the-return-value-of-lookup_page_ext-for-all-call-sites
> +++ a/mm/page_alloc.c
> @@ -656,6 +656,9 @@ static inline void set_page_guard(struct
>  		return;
>
>  	page_ext = lookup_page_ext(page);
> +	if (unlikely(!page_ext))
> +		return;
> +
>  	__set_bit(PAGE_EXT_DEBUG_GUARD, &page_ext->flags);
>
>  	INIT_LIST_HEAD(&page->lru);
> @@ -673,6 +676,9 @@ static inline void clear_page_guard(stru
>  		return;
>
>  	page_ext = lookup_page_ext(page);
> +	if (unlikely(!page_ext))
> +		return;
> +
>  	__clear_bit(PAGE_EXT_DEBUG_GUARD, &page_ext->flags);
>
>  	set_page_private(page, 0);
> diff -puN mm/page_owner.c~mm-check-the-return-value-of-lookup_page_ext-for-all-call-sites mm/page_owner.c
> --- a/mm/page_owner.c~mm-check-the-return-value-of-lookup_page_ext-for-all-call-sites
> +++ a/mm/page_owner.c
> @@ -55,6 +55,8 @@ void __reset_page_owner(struct page *pag
>
>  	for (i = 0; i < (1 << order); i++) {
>  		page_ext = lookup_page_ext(page + i);
> +		if (unlikely(!page_ext))
> +			continue;
>  		__clear_bit(PAGE_EXT_OWNER, &page_ext->flags);
>  	}
>  }
> @@ -62,6 +64,7 @@ void __reset_page_owner(struct page *pag
>  void __set_page_owner(struct page *page, unsigned int order, gfp_t gfp_mask)
>  {
>  	struct page_ext *page_ext = lookup_page_ext(page);
> +
>  	struct stack_trace trace = {
>  		.nr_entries = 0,
>  		.max_entries = ARRAY_SIZE(page_ext->trace_entries),
> @@ -69,6 +72,9 @@ void __set_page_owner(struct page *page,
>  		.skip = 3,
>  	};
>
> +	if (unlikely(!page_ext))
> +		return;
> +
>  	save_stack_trace(&trace);
>
>  	page_ext->order = order;
> @@ -82,6 +88,8 @@ void __set_page_owner(struct page *page,
>  void __set_page_owner_migrate_reason(struct page *page, int reason)
>  {
>  	struct page_ext *page_ext = lookup_page_ext(page);
> +	if (unlikely(!page_ext))
> +		return;
>
>  	page_ext->last_migrate_reason = reason;
>  }
> @@ -89,6 +97,12 @@ void __set_page_owner_migrate_reason(str
>  gfp_t __get_page_owner_gfp(struct page *page)
>  {
>  	struct page_ext *page_ext = lookup_page_ext(page);
> +	if (unlikely(!page_ext))
> +		/*
> +		 * The caller just returns 0 if no valid gfp
> +		 * So return 0 here too.
> +		 */
> +		return 0;
>
>  	return page_ext->gfp_mask;
>  }
> @@ -99,6 +113,9 @@ void __copy_page_owner(struct page *oldp
>  	struct page_ext *new_ext = lookup_page_ext(newpage);
>  	int i;
>
> +	if (unlikely(!old_ext || !new_ext))
> +		return;
> +
>  	new_ext->order = old_ext->order;
>  	new_ext->gfp_mask = old_ext->gfp_mask;
>  	new_ext->nr_entries = old_ext->nr_entries;
> @@ -193,6 +210,11 @@ void __dump_page_owner(struct page *page
>  	gfp_t gfp_mask = page_ext->gfp_mask;
>  	int mt = gfpflags_to_migratetype(gfp_mask);
>
> +	if (unlikely(!page_ext)) {
> +		pr_alert("There is not page extension available.\n");
> +		return;
> +	}
> +
>  	if (!test_bit(PAGE_EXT_OWNER, &page_ext->flags)) {
>  		pr_alert("page_owner info is not active (free page?)\n");
>  		return;
> @@ -251,6 +273,8 @@ read_page_owner(struct file *file, char
>  		}
>
>  		page_ext = lookup_page_ext(page);
> +		if (unlikely(!page_ext))
> +			continue;
>
>  		/*
>  		 * Some pages could be missed by concurrent allocation or free,
> @@ -317,6 +341,8 @@ static void init_pages_in_zone(pg_data_t
>  				continue;
>
>  			page_ext = lookup_page_ext(page);
> +			if (unlikely(!page_ext))
> +				continue;
>
>  			/* Maybe overraping zone */
>  			if (test_bit(PAGE_EXT_OWNER, &page_ext->flags))
> diff -puN mm/page_poison.c~mm-check-the-return-value-of-lookup_page_ext-for-all-call-sites mm/page_poison.c
> --- a/mm/page_poison.c~mm-check-the-return-value-of-lookup_page_ext-for-all-call-sites
> +++ a/mm/page_poison.c
> @@ -54,6 +54,9 @@ static inline void set_page_poison(struc
>  	struct page_ext *page_ext;
>
>  	page_ext = lookup_page_ext(page);
> +	if (unlikely(!page_ext))
> +		return;
> +
>  	__set_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
>  }
>
> @@ -62,6 +65,9 @@ static inline void clear_page_poison(str
>  	struct page_ext *page_ext;
>
>  	page_ext = lookup_page_ext(page);
> +	if (unlikely(!page_ext))
> +		return;
> +
>  	__clear_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
>  }
>
> @@ -70,7 +76,7 @@ bool page_is_poisoned(struct page *page)
>  	struct page_ext *page_ext;
>
>  	page_ext = lookup_page_ext(page);
> -	if (!page_ext)
> +	if (unlikely(!page_ext))
>  		return false;
>
>  	return test_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
> diff -puN mm/vmstat.c~mm-check-the-return-value-of-lookup_page_ext-for-all-call-sites mm/vmstat.c
> --- a/mm/vmstat.c~mm-check-the-return-value-of-lookup_page_ext-for-all-call-sites
> +++ a/mm/vmstat.c
> @@ -1061,6 +1061,8 @@ static void pagetypeinfo_showmixedcount_
>  				continue;
>
>  			page_ext = lookup_page_ext(page);
> +			if (unlikely(!page_ext))
> +				continue;
>
>  			if (!test_bit(PAGE_EXT_OWNER, &page_ext->flags))
>  				continue;
> _
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
