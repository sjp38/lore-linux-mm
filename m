Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 54A106B0264
	for <linux-mm@kvack.org>; Wed, 25 May 2016 03:12:39 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 129so72880476pfx.0
        for <linux-mm@kvack.org>; Wed, 25 May 2016 00:12:39 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id qk1si10653409pac.100.2016.05.25.00.12.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 00:12:38 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id f8so4347571pag.0
        for <linux-mm@kvack.org>; Wed, 25 May 2016 00:12:38 -0700 (PDT)
Subject: Re: [PATCH] mm: check the return value of lookup_page_ext for all
 call sites
References: <1464023768-31025-1-git-send-email-yang.shi@linaro.org>
From: shakil <bforce1729@gmail.com>
Message-ID: <526ffcc1-39ab-7504-248d-0aaf92724bf9@gmail.com>
Date: Wed, 25 May 2016 00:12:34 -0700
MIME-Version: 1.0
In-Reply-To: <1464023768-31025-1-git-send-email-yang.shi@linaro.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linaro.org>, akpm@linux-foundation.org, iamjoonsoo.kim@lge.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org



On 5/23/2016 10:16 AM, Yang Shi wrote:
> Per the discussion with Joonsoo Kim [1], we need check the return value of
> lookup_page_ext() for all call sites since it might return NULL in some cases,
> although it is unlikely, i.e. memory hotplug.
>
> Tested with ltp with "page_owner=0".
>
> [1] http://lkml.kernel.org/r/20160519002809.GA10245@js1304-P5Q-DELUXE
>
> Signed-off-by: Yang Shi <yang.shi@linaro.org>
> ---
>   include/linux/page_idle.h | 43 ++++++++++++++++++++++++++++++++++++-------
>   mm/page_alloc.c           |  6 ++++++
>   mm/page_owner.c           | 27 +++++++++++++++++++++++++++
>   mm/page_poison.c          |  8 +++++++-
>   mm/vmstat.c               |  2 ++
>   5 files changed, 78 insertions(+), 8 deletions(-)
>
> diff --git a/include/linux/page_idle.h b/include/linux/page_idle.h
> index bf268fa..8f5d4ad 100644
> --- a/include/linux/page_idle.h
> +++ b/include/linux/page_idle.h
> @@ -46,33 +46,62 @@ extern struct page_ext_operations page_idle_ops;
>   
>   static inline bool page_is_young(struct page *page)
>   {
> -	return test_bit(PAGE_EXT_YOUNG, &lookup_page_ext(page)->flags);
> +	struct page_ext *page_ext;
> +	page_ext = lookup_page_ext(page);
> +	if (unlikely(!page_ext)
> +		return false;
> +
> +	return test_bit(PAGE_EXT_YOUNG, &page_ext->flags);
>   }
>   
>   static inline void set_page_young(struct page *page)
>   {
> -	set_bit(PAGE_EXT_YOUNG, &lookup_page_ext(page)->flags);
> +	struct page_ext *page_ext;
> +	page_ext = lookup_page_ext(page);
> +	if (unlikely(!page_ext)
> +		return;
> +
> +	set_bit(PAGE_EXT_YOUNG, &page_ext->flags);
>   }
>   
>   static inline bool test_and_clear_page_young(struct page *page)
>   {
> -	return test_and_clear_bit(PAGE_EXT_YOUNG,
> -				  &lookup_page_ext(page)->flags);
> +	struct page_ext *page_ext;
> +	page_ext = lookup_page_ext(page);
> +	if (unlikely(!page_ext)
> +		return false;
> +
> +	return test_and_clear_bit(PAGE_EXT_YOUNG, &page_ext->flags);
>   }
>   
>   static inline bool page_is_idle(struct page *page)
>   {
> -	return test_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
> +	struct page_ext *page_ext;
> +	page_ext = lookup_page_ext(page);
> +	if (unlikely(!page_ext)
> +		return false;
> +
> +	return test_bit(PAGE_EXT_IDLE, &page_ext->flags);
>   }
>   
>   static inline void set_page_idle(struct page *page)
>   {
> -	set_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
> +	struct page_ext *page_ext;
> +	page_ext = lookup_page_ext(page);
> +	if (unlikely(!page_ext)
> +		return;
> +
> +	set_bit(PAGE_EXT_IDLE, &page_ext->flags);
>   }
>   
>   static inline void clear_page_idle(struct page *page)
>   {
> -	clear_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
> +	struct page_ext *page_ext;
> +	page_ext = lookup_page_ext(page);
> +	if (unlikely(!page_ext)
> +		return;
> +
> +	clear_bit(PAGE_EXT_IDLE, &page_ext->flags);
>   }
>   #endif /* CONFIG_64BIT */
>   
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f8f3bfc..d27e8b9 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -656,6 +656,9 @@ static inline void set_page_guard(struct zone *zone, struct page *page,
>   		return;
>   
>   	page_ext = lookup_page_ext(page);
> +	if (unlikely(!page_ext))
> +		return;
> +
>   	__set_bit(PAGE_EXT_DEBUG_GUARD, &page_ext->flags);
>   
>   	INIT_LIST_HEAD(&page->lru);
> @@ -673,6 +676,9 @@ static inline void clear_page_guard(struct zone *zone, struct page *page,
>   		return;
>   
>   	page_ext = lookup_page_ext(page);
> +	if (unlikely(!page_ext))
> +		return;
> +
>   	__clear_bit(PAGE_EXT_DEBUG_GUARD, &page_ext->flags);
>   
>   	set_page_private(page, 0);
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index 792b56d..902e398 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -55,6 +55,8 @@ void __reset_page_owner(struct page *page, unsigned int order)
>   
>   	for (i = 0; i < (1 << order); i++) {
>   		page_ext = lookup_page_ext(page + i);
> +		if (unlikely(!page_ext))
> +			continue;
>   		__clear_bit(PAGE_EXT_OWNER, &page_ext->flags);
>   	}
>   }
> @@ -62,6 +64,10 @@ void __reset_page_owner(struct page *page, unsigned int order)
>   void __set_page_owner(struct page *page, unsigned int order, gfp_t gfp_mask)
>   {
>   	struct page_ext *page_ext = lookup_page_ext(page);
> +
> +	if (unlikely(!page_ext))
> +		return;
> +
>   	struct stack_trace trace = {
>   		.nr_entries = 0,
>   		.max_entries = ARRAY_SIZE(page_ext->trace_entries),
> @@ -82,6 +88,8 @@ void __set_page_owner(struct page *page, unsigned int order, gfp_t gfp_mask)
>   void __set_page_owner_migrate_reason(struct page *page, int reason)
>   {
>   	struct page_ext *page_ext = lookup_page_ext(page);
> +	if (unlikely(!page_ext))
> +		return;
>   
>   	page_ext->last_migrate_reason = reason;
>   }
> @@ -89,6 +97,12 @@ void __set_page_owner_migrate_reason(struct page *page, int reason)
>   gfp_t __get_page_owner_gfp(struct page *page)
>   {
>   	struct page_ext *page_ext = lookup_page_ext(page);
> +	if (unlikely(!page_ext))
> +		/*
> +		 * The caller just returns 0 if no valid gfp
> +		 * So return 0 here too.
> +		 */
> +		return 0;
>   
>   	return page_ext->gfp_mask;
>   }
> @@ -97,6 +111,10 @@ void __copy_page_owner(struct page *oldpage, struct page *newpage)
>   {
>   	struct page_ext *old_ext = lookup_page_ext(oldpage);
>   	struct page_ext *new_ext = lookup_page_ext(newpage);
> +
> +	if (unlikely(!old_ext || !new_ext))
> +		return;
> +
>   	int i;
>   
>   	new_ext->order = old_ext->order;
> @@ -186,6 +204,11 @@ err:
>   void __dump_page_owner(struct page *page)
>   {
>   	struct page_ext *page_ext = lookup_page_ext(page);
> +	if (unlikely(!page_ext)) {
> +		pr_alert("There is not page extension available.\n");
> +		return;
> +	}
> +
>   	struct stack_trace trace = {
>   		.nr_entries = page_ext->nr_entries,
>   		.entries = &page_ext->trace_entries[0],
> @@ -251,6 +274,8 @@ read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
>   		}
>   
>   		page_ext = lookup_page_ext(page);
> +		if (unlikely(!page_ext))
> +			continue;
>   
>   		/*
>   		 * Some pages could be missed by concurrent allocation or free,
> @@ -317,6 +342,8 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
>   				continue;
>   
>   			page_ext = lookup_page_ext(page);
> +			if (unlikely(!page_ext))
> +				continue;
>   
>   			/* Maybe overraping zone */
>   			if (test_bit(PAGE_EXT_OWNER, &page_ext->flags))
> diff --git a/mm/page_poison.c b/mm/page_poison.c
> index 1eae5fa..2e647c6 100644
> --- a/mm/page_poison.c
> +++ b/mm/page_poison.c
> @@ -54,6 +54,9 @@ static inline void set_page_poison(struct page *page)
>   	struct page_ext *page_ext;
>   
>   	page_ext = lookup_page_ext(page);
> +	if (unlikely(!page_ext))
> +		return;
> +
>   	__set_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
>   }
>   
> @@ -62,6 +65,9 @@ static inline void clear_page_poison(struct page *page)
>   	struct page_ext *page_ext;
>   
>   	page_ext = lookup_page_ext(page);
> +	if (unlikely(!page_ext))
> +		return;
> +
>   	__clear_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
>   }
>   
> @@ -70,7 +76,7 @@ bool page_is_poisoned(struct page *page)
>   	struct page_ext *page_ext;
>   
>   	page_ext = lookup_page_ext(page);
> -	if (!page_ext)
> +	if (unlikely(!page_ext))
>   		return false;
>   
>   	return test_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 77e42ef..cb2a67b 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1061,6 +1061,8 @@ static void pagetypeinfo_showmixedcount_print(struct seq_file *m,
>   				continue;
>   
>   			page_ext = lookup_page_ext(page);
> +			if (unlikely(!page_ext))
> +				continue;
>   
>   			if (!test_bit(PAGE_EXT_OWNER, &page_ext->flags))
>   				continue;

if (unlikely(!page_ext)  /* Breaks the build */
  

  static inline bool page_is_young(struct page *page)
  {
-	return test_bit(PAGE_EXT_YOUNG, &lookup_page_ext(page)->flags);
+	struct page_ext *page_ext;
+	page_ext = lookup_page_ext(page);
+	if (unlikely(!page_ext)
+		return false;
+
+	return test_bit(PAGE_EXT_YOUNG, &page_ext->flags);
  }

Thanks
Shakil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
