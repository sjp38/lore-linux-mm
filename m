Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 632FCC48BD6
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 19:45:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E01402085A
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 19:45:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E01402085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F1AF6B0005; Tue, 25 Jun 2019 15:45:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A3528E0003; Tue, 25 Jun 2019 15:45:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 543B48E0002; Tue, 25 Jun 2019 15:45:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 173EA6B0005
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 15:45:47 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id g21so6486055pfb.13
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 12:45:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=1OGnkTij6ksitxC4wqvq1g//3oMcBvM2TisXC2szJHA=;
        b=gh8+I5KMb2E6PcDfYeeEAkIsu8asdsw0ixBALkWoWidms5RlIe4aqlDFpiSs49kf7u
         9nr60iqd0stL/uRIwEFYdec/K+rMWSs8cDwhRHp4eURNZJloOrgWEKzigXWiSxDwgYWN
         kGbtBJbccoNazJcy5oOw29sLo02yxIgo5inzif3H9VqC1LQWxtD8goMLzqE1fhhv8I9Q
         iUkFu4y3zvClwb/A+wQDTAidxxETzAAkXe02TckdjZ8cHl+KQJykPqM955BqZL7Ht7yk
         HJLMMXmipW7O/9/DS9WcHixKqTKfCxset8sK/qG+KNrfs9Xpof+JTHuufIiQYGWA1ARC
         W4cQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWH1PxdGEIuMyRZQzBO4XBBifHqQwHawAtedufNDXRcasBs7jkM
	ZiLKAwsnQWd3fCXEHHZtrRZ+gM6CDkvrI8ewdAUBOub9oB20Nu95jM6zFLQvOS/BKmxotpyB5pB
	Ta3VBqSuTYSiAjDS7iKVeOChMbASU8/n4w5nUT483cJBc8eiLzSdwtnnLWmoXZGFfcA==
X-Received: by 2002:a63:1b46:: with SMTP id b6mr32213617pgm.183.1561491946668;
        Tue, 25 Jun 2019 12:45:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSc/aLlF2hrHKTVH99e0+Uhlya6bgyV9+oBlLbCTlvaGyUQA9kKMvdT3561IhvO8wjqIc5
X-Received: by 2002:a63:1b46:: with SMTP id b6mr32213557pgm.183.1561491945570;
        Tue, 25 Jun 2019 12:45:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561491945; cv=none;
        d=google.com; s=arc-20160816;
        b=IkuJBted90JtB+6bAie7q0RDvyhVLgPCIhsg4z3rQzkg5OnxOr8RFFPsUeblnJrVfu
         4jNyB78KcZH8Ym04H2vpodFwOKM0WlYyDJJEUixWkZLDgMsYYJKQZx4oMwQ+v88y+wvy
         o+zZvFEay8E/vd3hEcGQN7GgRvMlxZMIbRKF826fxj4B/Tp0CEC+MkoAErBJ3aryScW9
         d4cj3I55VMES4uzom/qAky3QSF2M7cHfq03TWYh3cu5noNqCE8IryjL7gf3L2lQPGqea
         ykpwAnNdxwf62mdG8K2MjQqYgu6sZHPf6UxUoc+0xVGblZt/XkL/3Qg1ow8zJcoF3GPK
         uDGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=1OGnkTij6ksitxC4wqvq1g//3oMcBvM2TisXC2szJHA=;
        b=jNrtk3kT/NaQNmf5tI9IKano3rGIjOyux0Eid/xSILGgIksWeb3b7cm45eDQVOXVTX
         JfBZQb011W6YTSm89zpXFzfQX1/H9/efG+Iy/+dmpM60o/iccuunej43lB2Aszdnp9Go
         HcMn2YClT9wzeZnmcLuXySA1MHWVBAM0LH5RR0YMLL3VWzxwpiEn90zlRz5t8NnwkJXA
         2/jVge3wL+bm2t397pc8zHQrJCyU2OZ6V5xUXoZDGQe5Nknz5qAXEH7TZzf9J1c0alZk
         +rM3lleHq//WmAJArCIzPYSiROhfEfcNH3hWBYIcs5kSSjbQ6ybKj/5Ideybhfiy+rad
         RKJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id r5si15413260pfc.112.2019.06.25.12.45.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 12:45:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jun 2019 12:45:44 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,416,1557212400"; 
   d="scan'208";a="172474310"
Received: from ray.jf.intel.com (HELO [10.7.201.139]) ([10.7.201.139])
  by orsmga002.jf.intel.com with ESMTP; 25 Jun 2019 12:45:44 -0700
Subject: Re: [PATCH v1 4/6] mm: Introduce "aerated" pages
To: Alexander Duyck <alexander.duyck@gmail.com>, nitesh@redhat.com,
 kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
References: <20190619222922.1231.27432.stgit@localhost.localdomain>
 <20190619223323.1231.86906.stgit@localhost.localdomain>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <a147b569-9f1b-a1be-e019-0059c654892d@intel.com>
Date: Tue, 25 Jun 2019 12:45:44 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <20190619223323.1231.86906.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> +static inline void set_page_aerated(struct page *page,
> +				    struct zone *zone,
> +				    unsigned int order,
> +				    int migratetype)
> +{
> +#ifdef CONFIG_AERATION
> +	/* update areated page accounting */
> +	zone->free_area[order].nr_free_aerated++;
> +
> +	/* record migratetype and flag page as aerated */
> +	set_pcppage_migratetype(page, migratetype);
> +	__SetPageAerated(page);
> +#endif
> +}

Please don't refer to code before you introduce it, even if you #ifdef
it.  I went looking back in the series for the PageAerated() definition,
but didn't think to look forward.

Also, it doesn't make any sense to me that you would need to set the
migratetype here.  Isn't it set earlier in the allocator?  Also, when
can this function be called?  There's obviously some locking in place
because of the __Set, but what are they?

> +static inline void clear_page_aerated(struct page *page,
> +				      struct zone *zone,
> +				      struct free_area *area)
> +{
> +#ifdef CONFIG_AERATION
> +	if (likely(!PageAerated(page)))
> +		return;

Logically, why would you ever clear_page_aerated() on a page that's not
aerated?  Comments needed.

BTW, I already hate typing aerated. :)

> +	__ClearPageAerated(page);
> +	area->nr_free_aerated--;
> +#endif
> +}

More non-atomic flag clears.  Still no comments.


> @@ -787,10 +790,10 @@ static inline void add_to_free_area(struct page *page, struct zone *zone,
>  static inline void add_to_free_area_tail(struct page *page, struct zone *zone,
>  					 unsigned int order, int migratetype)
>  {
> -	struct free_area *area = &zone->free_area[order];
> +	struct list_head *tail = aerator_get_tail(zone, order, migratetype);

There is no logical change in this patch from this line.  That's
unfortunate because I can't see the change in logic that's presumably
coming.  You'll presumably change aerator_get_tail(), but then I'll have
to remember that this line is here and come back to it from a later patch.

If it *doesn't* change behavior, it has no business being calle
aerator_...().

This series seems rather suboptimal for reviewing.

> -	list_add_tail(&page->lru, &area->free_list[migratetype]);
> -	area->nr_free++;
> +	list_add_tail(&page->lru, tail);
> +	zone->free_area[order].nr_free++;
>  }
>  
>  /* Used for pages which are on another list */
> @@ -799,6 +802,8 @@ static inline void move_to_free_area(struct page *page, struct zone *zone,
>  {
>  	struct free_area *area = &zone->free_area[order];
>  
> +	clear_page_aerated(page, zone, area);
> +
>  	list_move(&page->lru, &area->free_list[migratetype]);
>  }

It's not immediately clear to me why moving a page should clear
aeration.  A comment would help make it clear.

> @@ -868,10 +869,11 @@ static inline struct capture_control *task_capc(struct zone *zone)
>  static inline void __free_one_page(struct page *page,
>  		unsigned long pfn,
>  		struct zone *zone, unsigned int order,
> -		int migratetype)
> +		int migratetype, bool aerated)
>  {
>  	struct capture_control *capc = task_capc(zone);
>  	unsigned long uninitialized_var(buddy_pfn);
> +	bool fully_aerated = aerated;
>  	unsigned long combined_pfn;
>  	unsigned int max_order;
>  	struct page *buddy;
> @@ -902,6 +904,11 @@ static inline void __free_one_page(struct page *page,
>  			goto done_merging;
>  		if (!page_is_buddy(page, buddy, order))
>  			goto done_merging;
> +
> +		/* assume buddy is not aerated */
> +		if (aerated)
> +			fully_aerated = false;

So, "full" vs. "partial" is with respect to high-order pages?  Why not
just check the page flag on the buddy?

>  		/*
>  		 * Our buddy is free or it is CONFIG_DEBUG_PAGEALLOC guard page,
>  		 * merge with it and move up one order.
> @@ -943,11 +950,17 @@ static inline void __free_one_page(struct page *page,
>  done_merging:
>  	set_page_order(page, order);
>  
> -	if (buddy_merge_likely(pfn, buddy_pfn, page, order) ||
> +	if (aerated ||
> +	    buddy_merge_likely(pfn, buddy_pfn, page, order) ||
>  	    is_shuffle_tail_page(order))
>  		add_to_free_area_tail(page, zone, order, migratetype);
>  	else
>  		add_to_free_area(page, zone, order, migratetype);

Aerated pages always go to the tail?  Ahh, so they don't get consumed
quickly and have to be undone?  Comments, please.

> +	if (fully_aerated)
> +		set_page_aerated(page, zone, order, migratetype);
> +	else
> +		aerator_notify_free(zone, order);
>  }

What is this notifying for?  It's not like this is some opaque
registration interface.  What does this *do*?

> @@ -2127,6 +2140,77 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
>  	return NULL;
>  }
>  
> +#ifdef CONFIG_AERATION
> +/**
> + * get_aeration_page - Provide a "raw" page for aeration by the aerator
> + * @zone: Zone to draw pages from
> + * @order: Order to draw pages from
> + * @migratetype: Migratetype to draw pages from

FWIW, kerneldoc is a waste of bytes here.  Please use it sparingly.

> + * This function will obtain a page from above the boundary. As a result
> + * we can guarantee the page has not been aerated.

This is the first mention of a boundary.  That's not good since I have
no idea at this point what the boundary is for or between.


> + * The page will have the migrate type and order stored in the page
> + * metadata.
> + *
> + * Return: page pointer if raw page found, otherwise NULL
> + */
> +struct page *get_aeration_page(struct zone *zone, unsigned int order,
> +			       int migratetype)
> +{
> +	struct free_area *area = &(zone->free_area[order]);
> +	struct list_head *list = &area->free_list[migratetype];
> +	struct page *page;
> +
> +	/* Find a page of the appropriate size in the preferred list */

I don't get the size comment.  Hasn't this already been given an order?

> +	page = list_last_entry(aerator_get_tail(zone, order, migratetype),
> +			       struct page, lru);
> +	list_for_each_entry_from_reverse(page, list, lru) {
> +		if (PageAerated(page)) {
> +			page = list_first_entry(list, struct page, lru);
> +			if (PageAerated(page))
> +				break;
> +		}

This confuses me.  It looks for a page, then goes to the next page and
checks again?  Why check twice?  Why is a function looking for an
aerated page that finds *two* pages returning NULL?

I'm stumped.

> +		del_page_from_free_area(page, zone, order);
> +
> +		/* record migratetype and order within page */
> +		set_pcppage_migratetype(page, migratetype);
> +		set_page_private(page, order);
> +		__mod_zone_freepage_state(zone, -(1 << order), migratetype);
> +
> +		return page;
> +	}
> +
> +	return NULL;
> +}

Oh, so this is trying to find a page _for_ aerating.
"get_aeration_page()" does not convey that.  Can that improved?
get_page_for_aeration()?

Rather than talk about boundaries, wouldn't a better description have been:

	Similar to allocation, this function removes a page from the
	free lists.  However, it only removes unaerated pages.

> +/**
> + * put_aeration_page - Return a now-aerated "raw" page back where we got it
> + * @zone: Zone to return pages to
> + * @page: Previously "raw" page that can now be returned after aeration
> + *
> + * This function will pull the migratetype and order information out
> + * of the page and attempt to return it where it found it.
> + */
> +void put_aeration_page(struct zone *zone, struct page *page)
> +{
> +	unsigned int order, mt;
> +	unsigned long pfn;
> +
> +	mt = get_pcppage_migratetype(page);
> +	pfn = page_to_pfn(page);
> +
> +	if (unlikely(has_isolate_pageblock(zone) || is_migrate_isolate(mt)))
> +		mt = get_pfnblock_migratetype(page, pfn);
> +
> +	order = page_private(page);
> +	set_page_private(page, 0);
> +
> +	__free_one_page(page, pfn, zone, order, mt, true);
> +}
> +#endif /* CONFIG_AERATION */

Yikes.  This seems to have glossed over some pretty big aspects here.
Pages which are being aerated are not free.  Pages which are freed are
diverted to be aerated before becoming free.  Right?  That sounds like
two really important things to add to a changelog.

>  /*
>   * This array describes the order lists are fallen back to when
>   * the free lists for the desirable migrate type are depleted
> @@ -5929,9 +6013,12 @@ void __ref memmap_init_zone_device(struct zone *zone,
>  static void __meminit zone_init_free_lists(struct zone *zone)
>  {
>  	unsigned int order, t;
> -	for_each_migratetype_order(order, t) {
> +	for_each_migratetype_order(order, t)
>  		INIT_LIST_HEAD(&zone->free_area[order].free_list[t]);
> +
> +	for (order = MAX_ORDER; order--; ) {
>  		zone->free_area[order].nr_free = 0;
> +		zone->free_area[order].nr_free_aerated = 0;
>  	}
>  }
>  
> 

