Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2E14C76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 11:47:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B9A1229F9
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 11:47:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B9A1229F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 145DE8E006B; Thu, 25 Jul 2019 07:47:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F6548E0059; Thu, 25 Jul 2019 07:47:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED7C98E006B; Thu, 25 Jul 2019 07:47:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C6F6E8E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 07:47:18 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id k31so44337172qte.13
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 04:47:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=uZUsQ0AyQ0DLx2FZu88yWY6SEu2+A3kcQ7y+a60lwPY=;
        b=nIyymUbxpxEilxyIWKC2k8GS2HTYhV+eXk/IVtH6cF38o9XV+ElL9eObx5ugWd9CZD
         Y8nRGEb93dpHJ06Gt5OvMJn9xS1cURVBjWU1Rzba74B90iFHYBUSqNClxRhG5MBdOlqH
         ZIcxHQi6BoZP+SzlL0NABhl91F470OZGWmsN07T5ddfFmZfutRE6Pq/c/r7E/b+ga4ID
         GsQ1M3dSYHwJbDjNNFHB+e1gIuS6C/MUvAt8MJZ+hSNxfDUxl2DSM20lg69CB7SLldW0
         idptBPVSMYX9NcZz5ANTjvCNT04SPKNhWdxaMdc2AEUAQ77sU1xYuDXybsH8o9cIJf7D
         Bhxw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVQZYoXn/cWx/vW94KnEBuBE+Nn3mLQzjUL69LkjBTnSNuYzGke
	snHA7dmQpVeZ34GyMrUzNT6LrFvQh/VXJfThu2662N6fqxXAfmhBHZ+PmZtTLvBnS0zACB7pn/Y
	HFiDiO/vv0y1ct5KH5Qkh/lKS1dPGM1EmybhLh6kXtsAY9XTSnYb3Ebb5Y4WR3RgpZg==
X-Received: by 2002:a05:620a:1187:: with SMTP id b7mr56741640qkk.218.1564055238356;
        Thu, 25 Jul 2019 04:47:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQbdwZi9m+ANQ/ZBJEQPgvE6TeBKpBNe6DGtJqD5IWyo76Jq3Ra2nYqhjxWyJeVx/xp+B9
X-Received: by 2002:a05:620a:1187:: with SMTP id b7mr56741600qkk.218.1564055237490;
        Thu, 25 Jul 2019 04:47:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564055237; cv=none;
        d=google.com; s=arc-20160816;
        b=hGyj5htUgz20duzNjKf2F+fYvaRlVBemco/aTsFCqPHoDnDJmkXaIdF0QYOdKY4BLr
         3C6pqF0GpTW/m0QjFs2ZWkv4nN2emYmCKHzd2/SI4pvSsjggxuGUAzl7rXlZkvci9Au9
         CjGg90nYTem8bnHL+Y46ZNlPAivLc7M4Fx8+9JiMP8V2DX6huU16ts2o5BM9Q7MEHKwb
         +0d1jKvgb9Cy4bpU42AXSYt3pkD+vd9kSre8tSAdfWGF4/oz8oF/9FU7IDakXFDl1IVa
         qPJgfL0cd7BzPu12+wj8JHpZM5dAPadmwu/4YJEdyXgC3M4rHeNXm+fRi4QF88e0MhZ9
         V/ng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=uZUsQ0AyQ0DLx2FZu88yWY6SEu2+A3kcQ7y+a60lwPY=;
        b=uc7Oou+JXo4w7XOTitQ83NSGZN49vjKkUszXiJq5aGF+IEFmdXuIHrF4GrwvZY0QQA
         N85o8Y9qymgvh9Je+3PSwRGDkI6B1oqXXIq3QTSAtPM6jEr9R3i2rKRETK3M0E1UpzvY
         +bkHiAh8WekIlY10EZc+PZtB4kBbWQbO2bxqM13GpMSUlBABOx/bsdyKe5R9hkX+s/gE
         qLfXyw3CVoqJ/oicuy+0i9J/puF5tLLLSlZEmX83rgXoeqLwXRceNnThwgmlSoB59xc2
         wXOWz4QL3yq20q60T83CH2gUY0U88uoVzMjy6m3NbHGNysxERYp/gaGXx5nqGsM9PEbC
         kDhw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g55si30477715qta.91.2019.07.25.04.47.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 04:47:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A0DB4C0BB29E;
	Thu, 25 Jul 2019 11:47:16 +0000 (UTC)
Received: from [10.18.17.163] (dhcp-17-163.bos.redhat.com [10.18.17.163])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5E76F61F21;
	Thu, 25 Jul 2019 11:46:57 +0000 (UTC)
Subject: Re: [PATCH v2 4/5] mm: Introduce Hinted pages
To: David Hildenbrand <david@redhat.com>,
 Alexander Duyck <alexander.duyck@gmail.com>, kvm@vger.kernel.org,
 mst@redhat.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 Matthew Wilcox <willy@infradead.org>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <20190724170259.6685.18028.stgit@localhost.localdomain>
 <a9f52894-52df-cd0c-86ac-eea9fbe96e34@redhat.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <227bf405-a924-a8de-3f58-f7799f1ba7a1@redhat.com>
Date: Thu, 25 Jul 2019 07:46:56 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <a9f52894-52df-cd0c-86ac-eea9fbe96e34@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Thu, 25 Jul 2019 11:47:16 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/25/19 4:53 AM, David Hildenbrand wrote:
> On 24.07.19 19:03, Alexander Duyck wrote:
>> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>>
>> In order to pave the way for free page hinting in virtualized environments
>> we will need a way to get pages out of the free lists and identify those
>> pages after they have been returned. To accomplish this, this patch adds
>> the concept of a Hinted Buddy, which is essentially meant to just be the
>> Offline page type used in conjunction with the Buddy page type.
>>
>> It adds a set of pointers we shall call "boundary" which represents the
>> upper boundary between the unhinted and hinted pages. The general idea is
>> that in order for a page to cross from one side of the boundary to the
>> other it will need to go through the hinting process. Ultimately a
>> free_list has been fully processed when the boundary has been moved from
>> the tail all they way up to occupying the first entry in the list.
>>
>> Doing this we should be able to make certain that we keep the hinted
>> pages as one contiguous block in each free list. This will allow us to
>> efficiently manipulate the free lists whenever we need to go in and start
>> sending hints to the hypervisor that there are new pages that have been
>> freed and are no longer in use.
>>
>> An added advantage to this approach is that we should be reducing the
>> overall memory footprint of the guest as it will be more likely to recycle
>> warm pages versus trying to allocate the hinted pages that were likely
>> evicted from the guest memory.
>>
>> Since we will only be hinting one zone at a time we keep the boundary
>> limited to being defined for just the zone we are currently placing hinted
>> pages into. Doing this we can keep the number of additional pointers needed
>> quite small. To flag that the boundaries are in place we use a single bit
>> in the zone to indicate that hinting and the boundaries are active.
>>
>> The determination of when to start hinting is based on the tracking of the
>> number of free pages in a given area versus the number of hinted pages in
>> that area. We keep track of the number of hinted pages per free_area in a
>> separate zone specific area. We do this to avoid modifying the free_area
>> structure as this can lead to false sharing for the highest order with the
>> zone lock which leads to a noticeable performance degradation.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>> ---
>>  include/linux/mmzone.h       |   40 +++++-
>>  include/linux/page-flags.h   |    8 +
>>  include/linux/page_hinting.h |  139 ++++++++++++++++++++
>>  mm/Kconfig                   |    5 +
>>  mm/Makefile                  |    1 
>>  mm/memory_hotplug.c          |    1 
>>  mm/page_alloc.c              |  136 ++++++++++++++++++-
>>  mm/page_hinting.c            |  298 ++++++++++++++++++++++++++++++++++++++++++
>>  8 files changed, 620 insertions(+), 8 deletions(-)
>>  create mode 100644 include/linux/page_hinting.h
>>  create mode 100644 mm/page_hinting.c
>>
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index f0c68b6b6154..42bdebb20484 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -460,6 +460,14 @@ struct zone {
>>  	seqlock_t		span_seqlock;
>>  #endif
>>  
>> +#ifdef CONFIG_PAGE_HINTING
>> +	/*
>> +	 * Pointer to hinted page tracking statistics array. The size of
>> +	 * the array is MAX_ORDER - PAGE_HINTING_MIN_ORDER. NULL when
>> +	 * page hinting is not present.
>> +	 */
>> +	unsigned long		*hinted_pages;
>> +#endif
>>  	int initialized;
>>  
>>  	/* Write-intensive fields used from the page allocator */
>> @@ -535,6 +543,14 @@ enum zone_flags {
>>  	ZONE_BOOSTED_WATERMARK,		/* zone recently boosted watermarks.
>>  					 * Cleared when kswapd is woken.
>>  					 */
>> +	ZONE_PAGE_HINTING_REQUESTED,	/* zone enabled page hinting and has
>> +					 * requested flushing the data out of
>> +					 * higher order pages.
>> +					 */
>> +	ZONE_PAGE_HINTING_ACTIVE,	/* zone enabled page hinting and is
>> +					 * activly flushing the data out of
>> +					 * higher order pages.
>> +					 */
>>  };
>>  
>>  static inline unsigned long zone_managed_pages(struct zone *zone)
>> @@ -755,6 +771,8 @@ static inline bool pgdat_is_empty(pg_data_t *pgdat)
>>  	return !pgdat->node_start_pfn && !pgdat->node_spanned_pages;
>>  }
>>  
>> +#include <linux/page_hinting.h>
>> +
>>  /* Used for pages not on another list */
>>  static inline void add_to_free_list(struct page *page, struct zone *zone,
>>  				    unsigned int order, int migratetype)
>> @@ -769,10 +787,16 @@ static inline void add_to_free_list(struct page *page, struct zone *zone,
>>  static inline void add_to_free_list_tail(struct page *page, struct zone *zone,
>>  					 unsigned int order, int migratetype)
>>  {
>> -	struct free_area *area = &zone->free_area[order];
>> +	struct list_head *tail = get_unhinted_tail(zone, order, migratetype);
>>  
>> -	list_add_tail(&page->lru, &area->free_list[migratetype]);
>> -	area->nr_free++;
>> +	/*
>> +	 * To prevent the unhinted pages from being interleaved with the
>> +	 * hinted ones while we are actively processing pages we will use
>> +	 * the head of the hinted pages to determine the tail of the free
>> +	 * list.
>> +	 */
>> +	list_add_tail(&page->lru, tail);
>> +	zone->free_area[order].nr_free++;
>>  }
>>  
>>  /* Used for pages which are on another list */
>> @@ -781,12 +805,22 @@ static inline void move_to_free_list(struct page *page, struct zone *zone,
>>  {
>>  	struct free_area *area = &zone->free_area[order];
>>  
>> +	/*
>> +	 * Clear Hinted flag, if present, to avoid placing hinted pages
>> +	 * at the top of the free_list. It is cheaper to just process this
>> +	 * page again, then have to walk around a page that is already hinted.
>> +	 */
>> +	clear_page_hinted(page, zone);
>> +
>>  	list_move(&page->lru, &area->free_list[migratetype]);
>>  }
>>  
>>  static inline void del_page_from_free_list(struct page *page, struct zone *zone,
>>  					   unsigned int order)
>>  {
>> +	/* Clear Hinted flag, if present, before clearing the Buddy flag */
>> +	clear_page_hinted(page, zone);
>> +
>>  	list_del(&page->lru);
>>  	__ClearPageBuddy(page);
>>  	set_page_private(page, 0);
>> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
>> index b848517da64c..b753dbf673cb 100644
>> --- a/include/linux/page-flags.h
>> +++ b/include/linux/page-flags.h
>> @@ -745,6 +745,14 @@ static inline int page_has_type(struct page *page)
>>  PAGE_TYPE_OPS(Offline, offline)
>>  
>>  /*
>> + * PageHinted() is an alias for Offline, however it is not meant to be an
>> + * exclusive value. It should be combined with PageBuddy() when seen as it
>> + * is meant to indicate that the page has been scrubbed while waiting in
>> + * the buddy system.
>> + */
>> +PAGE_TYPE_OPS(Hinted, offline)
>
> CCing Matthew
>
> I am still not sure if I like the idea of having two page types at a time.
>
> 1. Once we run out of page type bits (which can happen easily looking at
> it getting more and more user - e.g., maybe for vmmap pages soon), we
> might want to convert again back to a value-based, not bit-based type
> detection. This will certainly make this switch harder.
>
> 2. It will complicate the kexec/kdump handling. I assume it can be fixed
> some way - e.g., making the elf interface aware of the exact notion of
> page type bits compared to mapcount values we have right now (e.g.,
> PAGE_BUDDY_MAPCOUNT_VALUE). Not addressed in this series yet.
>
>
> Can't we reuse one of the traditional page flags for that, not used
> along with buddy pages? E.g., PG_dirty: Pages that were not hinted yet
> are dirty.

Will it not conflict with the regular use case of PG_dirty bit somehow?


> Matthew, what's your take?
>
-- 
Thanks
Nitesh

