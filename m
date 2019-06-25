Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E971C48BD7
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 20:24:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4307B208CB
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 20:24:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4307B208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E50886B0007; Tue, 25 Jun 2019 16:24:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E015E8E0003; Tue, 25 Jun 2019 16:24:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7BF78E0002; Tue, 25 Jun 2019 16:24:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8F1896B0007
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 16:24:46 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id y9so9818162plp.12
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 13:24:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=oXShIeTU1xqEd3oHV53mR9YzeYvFj+d3+vj/oExRSP4=;
        b=NE9oJZi83oz1R0qoNJhyltcRcrLW9WLS3fNEvobT51eOowHkVTJVh9DMqkhJh9FEyJ
         2HThxcGO91wEoINw2MeR7Yw2YrkW6TkcEejUCCYJb0nyiXgDuz2Tnkq5a2cGiWI+6u0S
         rmKI1RY5HKqWuPi/xbgyKnZAdD919ZLQTzhSDvtdpEhgthfp1pdadOfR0mC1t+YS5Hhr
         KX8I83HpT8D76vfHPKRn8zzBa7m6U4egmE8rY/eWdMrr+ciyb8E4qEgIbMN6hnUmTK7I
         JO3+qwImuoTEJKd4vPaW+jz8/lXDMa7C0XC1s2ZuxZdd/crVcLupdG+oOI3dGAKON3ch
         xyHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU5QjdtyNJan+FPm5t1RaLMW3+E+Ov2ppRBuz/lVsADDkr2jYp9
	LPs6A3j/qqL4IaYhZr5l8l7HE8sk1h+f+s4ydW84LEf+4GfMh+36RDayR0ZJMM7gmT/lyYKSo4s
	rkMLZYVnfKMBCGt1NNlFU5OOqKSQ4oj9C5wdHE3G1A7c26dFGe0XMzV2oe1OCA3w32A==
X-Received: by 2002:a63:d211:: with SMTP id a17mr40674205pgg.269.1561494285166;
        Tue, 25 Jun 2019 13:24:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyVRohsGDSbcdcEv/NOEb+gIO9DelsDFLkSCWaqnCVPAQ9vg4NHig8xWN1WSXo35qjkHrlG
X-Received: by 2002:a63:d211:: with SMTP id a17mr40674135pgg.269.1561494283931;
        Tue, 25 Jun 2019 13:24:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561494283; cv=none;
        d=google.com; s=arc-20160816;
        b=DZPfIwPHS244LICSk+0BOn4htbqJZDjIHDESl48Sloe+WGsGjekUHFNLUv18xXTIvI
         eTsEUF3XU1/mT8ZhQgW7hJ9IL0osnzTUcf7thqKsC+R2XayvBuXHvANEWioCcLNlpjpJ
         hTmzqmtypiTXEoUvGrXUAeLOiML+1yNVr05fa6/ziaEgEcJA6KtWmRnu4wIGpUIMYRwK
         ZQqXnElY/WoWfpq4tCEYA11xMQJ9Dateak+2tgLmyH+dxww0gQe8CGVVcCvTvvENYXrc
         JYl1tI0m3CsZUrYYDLFMyZ/wiY2nUwdjG/7dnOAWx5iTy/KvpH1Xt0WwirzELOcx6LzN
         e+tA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=oXShIeTU1xqEd3oHV53mR9YzeYvFj+d3+vj/oExRSP4=;
        b=Y/nLRvKURx9aBoWspYjkCcqpvaqGbaoRSStHGR1IqDgNEkcAOflg3cfHnBi+oUo8D1
         Y/M0G8JKV4yLbC9uS88uHRGEkl5Bevfr1HGCohUu4VfqOjrH4+4l+659IM3t2cNeFf80
         jl+fdQt/kUQ9ZtXw8+nL8vKcZ+N/QYuYB1oCKu2QqyIrzlnlzmAZNLUFfKP9oOmuJ4uc
         xY3W4x3xbtf5Jh846YEYBRZO0jjmoI2L+v9qipqEKC70M+xZH8n3h4DBT3vc4tI1fYQu
         vCyHI3NseZhBoz85YRm6ThZSYNsjbT/PXvqxlzaAHFXNZBN+CSnW/Cc5n3J6E78ZXYWS
         ox/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id co12si1209594plb.197.2019.06.25.13.24.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 13:24:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jun 2019 13:24:43 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,417,1557212400"; 
   d="scan'208";a="172486070"
Received: from ray.jf.intel.com (HELO [10.7.201.139]) ([10.7.201.139])
  by orsmga002.jf.intel.com with ESMTP; 25 Jun 2019 13:24:43 -0700
Subject: Re: [PATCH v1 5/6] mm: Add logic for separating "aerated" pages from
 "raw" pages
To: Alexander Duyck <alexander.duyck@gmail.com>, nitesh@redhat.com,
 kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
References: <20190619222922.1231.27432.stgit@localhost.localdomain>
 <20190619223331.1231.39271.stgit@localhost.localdomain>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <f704f160-49fb-2fdf-e8ac-44b47245a75c@intel.com>
Date: Tue, 25 Jun 2019 13:24:42 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <20190619223331.1231.39271.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/19/19 3:33 PM, Alexander Duyck wrote:
> Add a set of pointers we shall call "boundary" which represents the upper
> boundary between the "raw" and "aerated" pages. The general idea is that in
> order for a page to cross from one side of the boundary to the other it
> will need to go through the aeration treatment.

Aha!  The mysterious "boundary"!

But, how can you introduce code that deals with boundaries before
introducing the boundary itself?  Or was that comment misplaced?

FWIW, I'm not a fan of these commit messages.  They are really hard to
map to the data structures.

	One goal in this set is to avoid creating new data structures.
	We accomplish that by reusing the free lists to hold aerated and
	non-aerated pages.  But, in order to use the existing free list,
	we need a boundary to separate aerated from raw.

Further:

	Pages are temporarily removed from the free lists while aerating
	them.

This needs a justification why you chose this path, and also what the
larger implications are.

> By doing this we should be able to make certain that we keep the aerated
> pages as one contiguous block on the end of each free list. This will allow
> us to efficiently walk the free lists whenever we need to go in and start
> processing hints to the hypervisor that the pages are no longer in use.

You don't really walk them though, right?  It *keeps* you from having to
ever walk the lists.

I also don't see what the boundary has to do with aerated pages being on
the tail of the list.  If you want them on the tail, you just always
list_add_tail() them.

> And added advantage to this approach is that we should be reducing the
> overall memory footprint of the guest as it will be more likely to recycle
> warm pages versus the aerated pages that are likely to be cache cold.

I'm confused.  Isn't an aerated page non-present on the guest?  That's
worse than cache cold.  It costs a VMEXIT to bring back in.

> Since we will only be aerating one zone at a time we keep the boundary
> limited to being defined for just the zone we are currently placing aerated
> pages into. Doing this we can keep the number of additional poitners needed
> quite small.

							pointers ^

> +struct list_head *__aerator_get_tail(unsigned int order, int migratetype);
>  static inline struct list_head *aerator_get_tail(struct zone *zone,
>  						 unsigned int order,
>  						 int migratetype)
>  {
> +#ifdef CONFIG_AERATION
> +	if (order >= AERATOR_MIN_ORDER &&
> +	    test_bit(ZONE_AERATION_ACTIVE, &zone->flags))
> +		return __aerator_get_tail(order, migratetype);
> +#endif
>  	return &zone->free_area[order].free_list[migratetype];
>  }

Logically, I have no idea what this is doing.  "Go get pages out of the
aerated list?"  "raw list"?  Needs comments.

> +static inline void aerator_del_from_boundary(struct page *page,
> +					     struct zone *zone)
> +{
> +	if (PageAerated(page) && test_bit(ZONE_AERATION_ACTIVE, &zone->flags))
> +		__aerator_del_from_boundary(page, zone);
> +}
> +
>  static inline void set_page_aerated(struct page *page,
>  				    struct zone *zone,
>  				    unsigned int order,
> @@ -28,6 +59,9 @@ static inline void set_page_aerated(struct page *page,
>  	/* record migratetype and flag page as aerated */
>  	set_pcppage_migratetype(page, migratetype);
>  	__SetPageAerated(page);
> +
> +	/* update boundary of new migratetype and record it */
> +	aerator_add_to_boundary(page, zone);
>  #endif
>  }
>  
> @@ -39,11 +73,19 @@ static inline void clear_page_aerated(struct page *page,
>  	if (likely(!PageAerated(page)))
>  		return;
>  
> +	/* push boundary back if we removed the upper boundary */
> +	aerator_del_from_boundary(page, zone);
> +
>  	__ClearPageAerated(page);
>  	area->nr_free_aerated--;
>  #endif
>  }
>  
> +static inline unsigned long aerator_raw_pages(struct free_area *area)
> +{
> +	return area->nr_free - area->nr_free_aerated;
> +}
> +
>  /**
>   * aerator_notify_free - Free page notification that will start page processing
>   * @zone: Pointer to current zone of last page processed
> @@ -57,5 +99,20 @@ static inline void clear_page_aerated(struct page *page,
>   */
>  static inline void aerator_notify_free(struct zone *zone, int order)
>  {
> +#ifdef CONFIG_AERATION
> +	if (!static_key_false(&aerator_notify_enabled))
> +		return;
> +	if (order < AERATOR_MIN_ORDER)
> +		return;
> +	if (test_bit(ZONE_AERATION_REQUESTED, &zone->flags))
> +		return;
> +	if (aerator_raw_pages(&zone->free_area[order]) < AERATOR_HWM)
> +		return;
> +
> +	__aerator_notify(zone);
> +#endif
>  }

Again, this is really hard to review.  I see some possible overhead in a
fast path here, but only if aerator_notify_free() is called in a fast
path.  Is it?  I have to go digging in the previous patches to figure
that out.

> +static struct aerator_dev_info *a_dev_info;
> +struct static_key aerator_notify_enabled;
> +
> +struct list_head *boundary[MAX_ORDER - AERATOR_MIN_ORDER][MIGRATE_TYPES];
> +
> +static void aerator_reset_boundary(struct zone *zone, unsigned int order,
> +				   unsigned int migratetype)
> +{
> +	boundary[order - AERATOR_MIN_ORDER][migratetype] =
> +			&zone->free_area[order].free_list[migratetype];
> +}
> +
> +#define for_each_aerate_migratetype_order(_order, _type) \
> +	for (_order = MAX_ORDER; _order-- != AERATOR_MIN_ORDER;) \
> +		for (_type = MIGRATE_TYPES; _type--;)
> +
> +static void aerator_populate_boundaries(struct zone *zone)
> +{
> +	unsigned int order, mt;
> +
> +	if (test_bit(ZONE_AERATION_ACTIVE, &zone->flags))
> +		return;
> +
> +	for_each_aerate_migratetype_order(order, mt)
> +		aerator_reset_boundary(zone, order, mt);
> +
> +	set_bit(ZONE_AERATION_ACTIVE, &zone->flags);
> +}

This function appears misnamed as it's doing more than boundary
manipulation.

> +struct list_head *__aerator_get_tail(unsigned int order, int migratetype)
> +{
> +	return boundary[order - AERATOR_MIN_ORDER][migratetype];
> +}
> +
> +void __aerator_del_from_boundary(struct page *page, struct zone *zone)
> +{
> +	unsigned int order = page_private(page) - AERATOR_MIN_ORDER;
> +	int mt = get_pcppage_migratetype(page);
> +	struct list_head **tail = &boundary[order][mt];
> +
> +	if (*tail == &page->lru)
> +		*tail = page->lru.next;
> +}

Ewww.  Please just track the page that's the boundary, not the list head
inside the page that's the boundary.

This also at least needs one comment along the lines of: Move the
boundary if the page representing the boundary is being removed.


> +void aerator_add_to_boundary(struct page *page, struct zone *zone)
> +{
> +	unsigned int order = page_private(page) - AERATOR_MIN_ORDER;
> +	int mt = get_pcppage_migratetype(page);
> +	struct list_head **tail = &boundary[order][mt];
> +
> +	*tail = &page->lru;
> +}
> +
> +void aerator_shutdown(void)
> +{
> +	static_key_slow_dec(&aerator_notify_enabled);
> +
> +	while (atomic_read(&a_dev_info->refcnt))
> +		msleep(20);

We generally frown on open-coded check/sleep loops.  What is this for?

> +	WARN_ON(!list_empty(&a_dev_info->batch));
> +
> +	a_dev_info = NULL;
> +}
> +EXPORT_SYMBOL_GPL(aerator_shutdown);
> +
> +static void aerator_schedule_initial_aeration(void)
> +{
> +	struct zone *zone;
> +
> +	for_each_populated_zone(zone) {
> +		spin_lock(&zone->lock);
> +		__aerator_notify(zone);
> +		spin_unlock(&zone->lock);
> +	}
> +}

Why do we need an initial aeration?

> +int aerator_startup(struct aerator_dev_info *sdev)
> +{
> +	if (a_dev_info)
> +		return -EBUSY;
> +
> +	INIT_LIST_HEAD(&sdev->batch);
> +	atomic_set(&sdev->refcnt, 0);
> +
> +	a_dev_info = sdev;
> +	aerator_schedule_initial_aeration();
> +
> +	static_key_slow_inc(&aerator_notify_enabled);
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(aerator_startup);
> +
> +static void aerator_fill(struct zone *zone)
> +{
> +	struct list_head *batch = &a_dev_info->batch;
> +	int budget = a_dev_info->capacity;

Where does capacity come from?

> +	unsigned int order, mt;
> +
> +	for_each_aerate_migratetype_order(order, mt) {
> +		struct page *page;
> +
> +		/*
> +		 * Pull pages from free list until we have drained
> +		 * it or we have filled the batch reactor.
> +		 */

What's a reactor?

> +		while ((page = get_aeration_page(zone, order, mt))) {
> +			list_add_tail(&page->lru, batch);
> +
> +			if (!--budget)
> +				return;
> +		}
> +	}
> +
> +	/*
> +	 * If there are no longer enough free pages to fully populate
> +	 * the aerator, then we can just shut it down for this zone.
> +	 */
> +	clear_bit(ZONE_AERATION_REQUESTED, &zone->flags);
> +	atomic_dec(&a_dev_info->refcnt);
> +}

Huh, so this is the number of threads doing aeration?  Didn't we just
make a big deal about there only being one zone being aerated at a time?
 Or, did I misunderstand what refcnt is from its lack of clear
documentation?

> +static void aerator_drain(struct zone *zone)
> +{
> +	struct list_head *list = &a_dev_info->batch;
> +	struct page *page;
> +
> +	/*
> +	 * Drain the now aerated pages back into their respective
> +	 * free lists/areas.
> +	 */
> +	while ((page = list_first_entry_or_null(list, struct page, lru))) {
> +		list_del(&page->lru);
> +		put_aeration_page(zone, page);
> +	}
> +}
> +
> +static void aerator_scrub_zone(struct zone *zone)
> +{
> +	/* See if there are any pages to pull */
> +	if (!test_bit(ZONE_AERATION_REQUESTED, &zone->flags))
> +		return;

How would someone ask for the zone to be scrubbed when aeration has not
been requested?

> +	spin_lock(&zone->lock);
> +
> +	do {
> +		aerator_fill(zone);

Should this say:

		/* Pull pages out of the allocator into a local list */

?

> +		if (list_empty(&a_dev_info->batch))
> +			break;

		/* no pages were acquired, give up */

> +		spin_unlock(&zone->lock);
> +
> +		/*
> +		 * Start aerating the pages in the batch, and then
> +		 * once that is completed we can drain the reactor
> +		 * and refill the reactor, restarting the cycle.
> +		 */
> +		a_dev_info->react(a_dev_info);

After reading (most of) this set, I'm going to reiterate my suggestion:
please find new nomenclature.  I can't parse that comment and I don't
know whether that's because it's a bad comment or whether you really
mean "cycle" the english word or "cycle" referring to some new
definition relating to this patch set.

I've asked quite nicely a few times now.

> +		spin_lock(&zone->lock);
> +
> +		/*
> +		 * Guarantee boundaries are populated before we
> +		 * start placing aerated pages in the zone.
> +		 */
> +		aerator_populate_boundaries(zone);

aerator_populate_boundaries() has apparent concurrency checks via
ZONE_AERATION_ACTIVE.  Why are those needed when this is called under a
spinlock?

