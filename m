Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A516C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 14:05:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4EFF214C6
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 14:05:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4EFF214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56C386B0005; Mon,  5 Aug 2019 10:05:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F5CC6B0006; Mon,  5 Aug 2019 10:05:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 348E66B0007; Mon,  5 Aug 2019 10:05:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 077EC6B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 10:05:51 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id c1so72503903qkl.7
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 07:05:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=K4iazMuvZVoKwfpzePgniV62HmVhk4cXwBNm9fpjqt0=;
        b=NTgIgAXfHBiyojY5Ej4uPmeGd6ggplB/zFME7fDyam7/LGroFoJYJDcbYPTXM3Yv/7
         IinlKunI2UJYgjhs6ckC6/c0YEzXv/+6g1iH1L1zWs/IvcKUriskMAXgFZBlQkImwfoI
         qz68FU0Fny6EOSJDIi/rr2xNGzLXlcMyJ7uktbm0fIrJMDMaNQGRwdZ7XjvIdGAkPwgz
         WHtO0C3PbnjtNgh/B9eYw2yoMr0zxXNqAxKMj37GyJTBxO0+dzwR7LCN0FRiYGftGRGN
         u34MwZJzwzXefHW22UC0Won6J6GlIB435Nde/IdWfazKtxzP1kOxCGLaVZdba6OPQWoA
         q3cw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXwKmpVLZuBUV/78rI+jfKa5ea2GfbVAJmYxvqQ2e7OZio73sy/
	3SiVJVJe/Qz6QgfYBFZl8PEO8LDFw89Hrv2jnzYGpAYZOcYewD9W8zQkWTFu6jhGV6XmvTE8ieM
	tAwz74j4vgISyXpx1vx7h9pN02B991dKE3Tu6z6I4cFSexyoghPHge5ZVU5apMtIC8g==
X-Received: by 2002:a37:c87:: with SMTP id 129mr92284954qkm.240.1565013950691;
        Mon, 05 Aug 2019 07:05:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAhAKjjCv6dcmxlflNAUreFe8E2u4pbQKNnWaL2G9J3bvNtp/BmA99Ax7NgSbbJlAMmvt4
X-Received: by 2002:a37:c87:: with SMTP id 129mr92284807qkm.240.1565013949025;
        Mon, 05 Aug 2019 07:05:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565013949; cv=none;
        d=google.com; s=arc-20160816;
        b=bwhowAjypFf07suaNsU9vCaIYw4VHay4QYvpPbaA2V+IleFe9SvsFHKCbVAZr6Gqov
         dUwiAHCaHHizCLwtLVVX/+3ojMTtvdWa3t5/B0RCLvphzJfGdQJF3aSNOreaIRGljGdU
         OjYl50L9SDpRWmbA0K6eosQgGhRMnIhEB/+Jm3h/irlbO1Y/Crktlyz9Nu3CQ/TIckw1
         K3Dta2GyV3/vC3GeRoLx35LHwf5EAlpM0Guf2DJYWSKIIM/rDTzMtNKcs3PjS7PAS4ul
         BXWodsFwPx29dhKtJwCtw2o4sfjtqVTbb4y1ARW99WiozYQqENfTqZiI3J2jhYf5UDIt
         kVNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=K4iazMuvZVoKwfpzePgniV62HmVhk4cXwBNm9fpjqt0=;
        b=Z61k3UR0Qyqxi+/G1mAPl3/MIV1uFX57Z8YrSNs/hyjWsx+fgraefe4RBvVBODPhqw
         oZbqTYmo8oZyqc/fMrwVh1w933MNRqgQCDzw9FggZwARKr7DzPzIWSMI81HlOha+cPpZ
         8jIcRvzBEyDgp7XOgAj68VF6ccziwWlPl+recWpzl7QT6QLYJ+SU4oSRuDTAwisYgNzi
         Xz00Cc2haesMioq1zwSZuoA8WBT5API+3TIt8ERIl34tLhIL8kdL0w3t1EBe8SOzV2L9
         uDdOS5BpqJy/TZFtcS+9tBYasiqjsLFABofqMw7YAr9JxW/U2G7UzOdLqdVpK14Jcf3K
         HrBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p53si48318848qtp.199.2019.08.05.07.05.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 07:05:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DB9B489ACA;
	Mon,  5 Aug 2019 14:05:47 +0000 (UTC)
Received: from [10.18.17.163] (dhcp-17-163.bos.redhat.com [10.18.17.163])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 449A55D6C8;
	Mon,  5 Aug 2019 14:05:35 +0000 (UTC)
Subject: Re: [PATCH v3 4/6] mm: Introduce Reported pages
To: Alexander Duyck <alexander.duyck@gmail.com>, kvm@vger.kernel.org,
 david@redhat.com, mst@redhat.com, dave.hansen@intel.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
References: <20190801222158.22190.96964.stgit@localhost.localdomain>
 <20190801223359.22190.2212.stgit@localhost.localdomain>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <42683cc1-3235-5894-2610-bc7b9d443eb0@redhat.com>
Date: Mon, 5 Aug 2019 10:05:33 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190801223359.22190.2212.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Mon, 05 Aug 2019 14:05:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 8/1/19 6:33 PM, Alexander Duyck wrote:
> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>
> In order to pave the way for free page reporting in virtualized
> environments we will need a way to get pages out of the free lists and
> identify those pages after they have been returned. To accomplish this,=

> this patch adds the concept of a Reported Buddy, which is essentially
> meant to just be the Uptodate flag used in conjunction with the Buddy
> page type.
>
> It adds a set of pointers we shall call "boundary" which represents the=

> upper boundary between the unreported and reported pages. The general i=
dea
> is that in order for a page to cross from one side of the boundary to t=
he
> other it will need to go through the reporting process. Ultimately a
> free_list has been fully processed when the boundary has been moved fro=
m
> the tail all they way up to occupying the first entry in the list.
>
> Doing this we should be able to make certain that we keep the reported
> pages as one contiguous block in each free list. This will allow us to
> efficiently manipulate the free lists whenever we need to go in and sta=
rt
> sending reports to the hypervisor that there are new pages that have be=
en
> freed and are no longer in use.
>
> An added advantage to this approach is that we should be reducing the
> overall memory footprint of the guest as it will be more likely to recy=
cle
> warm pages versus trying to allocate the reported pages that were likel=
y
> evicted from the guest memory.
>
> Since we will only be reporting one zone at a time we keep the boundary=

> limited to being defined for just the zone we are currently reporting p=
ages
> from. Doing this we can keep the number of additional pointers needed q=
uite
> small. To flag that the boundaries are in place we use a single bit
> in the zone to indicate that reporting and the boundaries are active.
>
> The determination of when to start reporting is based on the tracking o=
f
> the number of free pages in a given area versus the number of reported
> pages in that area. We keep track of the number of reported pages per
> free_area in a separate zone specific area. We do this to avoid modifyi=
ng
> the free_area structure as this can lead to false sharing for the highe=
st
> order with the zone lock which leads to a noticeable performance
> degradation.
>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> ---
>  include/linux/mmzone.h         |   40 +++++
>  include/linux/page-flags.h     |   11 +
>  include/linux/page_reporting.h |  138 ++++++++++++++++++
>  mm/Kconfig                     |    5 +
>  mm/Makefile                    |    1=20
>  mm/memory_hotplug.c            |    1=20
>  mm/page_alloc.c                |  136 ++++++++++++++++++
>  mm/page_reporting.c            |  299 ++++++++++++++++++++++++++++++++=
++++++++
>  8 files changed, 623 insertions(+), 8 deletions(-)
>  create mode 100644 include/linux/page_reporting.h
>  create mode 100644 mm/page_reporting.c
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index f0c68b6b6154..4e6692380deb 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -460,6 +460,14 @@ struct zone {
>  	seqlock_t		span_seqlock;
>  #endif
> =20
> +#ifdef CONFIG_PAGE_REPORTING
> +	/*
> +	 * Pointer to reported page tracking statistics array. The size of
> +	 * the array is MAX_ORDER - PAGE_REPORTING_MIN_ORDER. NULL when
> +	 * unused page reporting is not present.
> +	 */
> +	unsigned long		*reported_pages;
> +#endif
>  	int initialized;
> =20
>  	/* Write-intensive fields used from the page allocator */
> @@ -535,6 +543,14 @@ enum zone_flags {
>  	ZONE_BOOSTED_WATERMARK,		/* zone recently boosted watermarks.
>  					 * Cleared when kswapd is woken.
>  					 */
> +	ZONE_PAGE_REPORTING_REQUESTED,	/* zone enabled page reporting and has=

> +					 * requested flushing the data out of
> +					 * higher order pages.
> +					 */
> +	ZONE_PAGE_REPORTING_ACTIVE,	/* zone enabled page reporting and is
> +					 * activly flushing the data out of
> +					 * higher order pages.
> +					 */
>  };
> =20
>  static inline unsigned long zone_managed_pages(struct zone *zone)
> @@ -755,6 +771,8 @@ static inline bool pgdat_is_empty(pg_data_t *pgdat)=

>  	return !pgdat->node_start_pfn && !pgdat->node_spanned_pages;
>  }
> =20
> +#include <linux/page_reporting.h>
> +
>  /* Used for pages not on another list */
>  static inline void add_to_free_list(struct page *page, struct zone *zo=
ne,
>  				    unsigned int order, int migratetype)
> @@ -769,10 +787,16 @@ static inline void add_to_free_list(struct page *=
page, struct zone *zone,
>  static inline void add_to_free_list_tail(struct page *page, struct zon=
e *zone,
>  					 unsigned int order, int migratetype)
>  {
> -	struct free_area *area =3D &zone->free_area[order];
> +	struct list_head *tail =3D get_unreported_tail(zone, order, migratety=
pe);
> =20
> -	list_add_tail(&page->lru, &area->free_list[migratetype]);
> -	area->nr_free++;
> +	/*
> +	 * To prevent the unreported pages from being interleaved with the
> +	 * reported ones while we are actively processing pages we will use
> +	 * the head of the reported pages to determine the tail of the free
> +	 * list.
> +	 */
> +	list_add_tail(&page->lru, tail);
> +	zone->free_area[order].nr_free++;
>  }
> =20
>  /* Used for pages which are on another list */
> @@ -781,12 +805,22 @@ static inline void move_to_free_list(struct page =
*page, struct zone *zone,
>  {
>  	struct free_area *area =3D &zone->free_area[order];
> =20
> +	/*
> +	 * Clear Hinted flag, if present, to avoid placing reported pages
> +	 * at the top of the free_list. It is cheaper to just process this
> +	 * page again than to walk around a page that is already reported.
> +	 */
> +	clear_page_reported(page, zone);
> +
>  	list_move(&page->lru, &area->free_list[migratetype]);
>  }
> =20
>  static inline void del_page_from_free_list(struct page *page, struct z=
one *zone,
>  					   unsigned int order)
>  {
> +	/* Clear Reported flag, if present, before resetting page type */
> +	clear_page_reported(page, zone);
> +
>  	list_del(&page->lru);
>  	__ClearPageBuddy(page);
>  	set_page_private(page, 0);
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index f91cb8898ff0..759a3b3956f2 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -163,6 +163,9 @@ enum pageflags {
> =20
>  	/* non-lru isolated movable page */
>  	PG_isolated =3D PG_reclaim,
> +
> +	/* Buddy pages. Used to track which pages have been reported */
> +	PG_reported =3D PG_uptodate,
>  };
> =20
>  #ifndef __GENERATING_BOUNDS_H
> @@ -432,6 +435,14 @@ static inline bool set_hwpoison_free_buddy_page(st=
ruct page *page)
>  #endif
> =20
>  /*
> + * PageReported() is used to track reported free pages within the Budd=
y
> + * allocator. We can use the non-atomic version of the test and set
> + * operations as both should be shielded with the zone lock to prevent=

> + * any possible races on the setting or clearing of the bit.
> + */
> +__PAGEFLAG(Reported, reported, PF_NO_COMPOUND)
> +
> +/*
>   * On an anonymous page mapped into a user virtual memory area,
>   * page->mapping points to its anon_vma, not to a struct address_space=
;
>   * with the PAGE_MAPPING_ANON bit set to distinguish it.  See rmap.h.
> diff --git a/include/linux/page_reporting.h b/include/linux/page_report=
ing.h
> new file mode 100644
> index 000000000000..498bde6ea764
> --- /dev/null
> +++ b/include/linux/page_reporting.h
> @@ -0,0 +1,138 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
> +#ifndef _LINUX_PAGE_REPORTING_H
> +#define _LINUX_PAGE_REPORTING_H
> +
> +#include <linux/mmzone.h>
> +#include <linux/jump_label.h>
> +#include <linux/pageblock-flags.h>
> +#include <asm/pgtable_types.h>
> +
> +#define PAGE_REPORTING_MIN_ORDER	pageblock_order
> +#define PAGE_REPORTING_HWM		32
> +
> +#ifdef CONFIG_PAGE_REPORTING
> +struct page_reporting_dev_info {
> +	/* function that alters pages to make them "reported" */
> +	void (*report)(struct page_reporting_dev_info *phdev,
> +		       unsigned int nents);
> +
> +	/* scatterlist containing pages to be processed */
> +	struct scatterlist *sg;
> +
> +	/*
> +	 * Upper limit on the number of pages that the react function
> +	 * expects to be placed into the batch list to be processed.
> +	 */
> +	unsigned long capacity;
> +
> +	/* work struct for processing reports */
> +	struct delayed_work work;
> +
> +	/*
> +	 * The number of zones requesting reporting, plus one additional if
> +	 * processing thread is active.
> +	 */
> +	atomic_t refcnt;
> +};
> +
> +extern struct static_key page_reporting_notify_enabled;
> +
> +/* Boundary functions */
> +struct list_head *__page_reporting_get_boundary(unsigned int order,
> +						int migratetype);
> +void page_reporting_del_from_boundary(struct page *page, struct zone *=
zone);
> +void page_reporting_add_to_boundary(struct page *page, struct zone *zo=
ne,
> +				    int migratetype);
> +
> +/* Hinted page accessors, defined in page_alloc.c */
> +struct page *get_unreported_page(struct zone *zone, unsigned int order=
,
> +				 int migratetype);
> +void put_reported_page(struct zone *zone, struct page *page);
> +
> +void __page_reporting_request(struct zone *zone);
> +void __page_reporting_free_stats(struct zone *zone);
> +
> +/* Tear-down and bring-up for page reporting devices */
> +void page_reporting_shutdown(struct page_reporting_dev_info *phdev);
> +int page_reporting_startup(struct page_reporting_dev_info *phdev);
> +#endif /* CONFIG_PAGE_REPORTING */
> +
> +static inline struct list_head *
> +get_unreported_tail(struct zone *zone, unsigned int order, int migrate=
type)
> +{
> +#ifdef CONFIG_PAGE_REPORTING
> +	if (order >=3D PAGE_REPORTING_MIN_ORDER &&
> +	    test_bit(ZONE_PAGE_REPORTING_ACTIVE, &zone->flags))
> +		return __page_reporting_get_boundary(order, migratetype);
> +#endif
> +	return &zone->free_area[order].free_list[migratetype];
> +}
> +
> +static inline void clear_page_reported(struct page *page,
> +				     struct zone *zone)
> +{
> +#ifdef CONFIG_PAGE_REPORTING
> +	if (likely(!PageReported(page)))
> +		return;
> +
> +	/* push boundary back if we removed the upper boundary */
> +	if (test_bit(ZONE_PAGE_REPORTING_ACTIVE, &zone->flags))
> +		page_reporting_del_from_boundary(page, zone);
> +
> +	__ClearPageReported(page);
> +
> +	/* page_private will contain the page order, so just use it directly =
*/
> +	zone->reported_pages[page_private(page) - PAGE_REPORTING_MIN_ORDER]--=
;
> +#endif
> +}
> +
> +/* Free reported_pages and reset reported page tracking count to 0 */
> +static inline void page_reporting_reset(struct zone *zone)
> +{
> +#ifdef CONFIG_PAGE_REPORTING
> +	if (zone->reported_pages)
> +		__page_reporting_free_stats(zone);
> +#endif
> +}
> +
> +/**
> + * page_reporting_notify_free - Free page notification to start page p=
rocessing
> + * @zone: Pointer to current zone of last page processed
> + * @order: Order of last page added to zone
> + *
> + * This function is meant to act as a screener for __page_reporting_re=
quest
> + * which will determine if a give zone has crossed over the high-water=
 mark
> + * that will justify us beginning page treatment. If we have crossed t=
hat
> + * threshold then it will start the process of pulling some pages and
> + * placing them in the batch list for treatment.
> + */
> +static inline void page_reporting_notify_free(struct zone *zone, int o=
rder)
> +{
> +#ifdef CONFIG_PAGE_REPORTING
> +	unsigned long nr_reported;
> +
> +	/* Called from hot path in __free_one_page() */
> +	if (!static_key_false(&page_reporting_notify_enabled))
> +		return;
> +
> +	/* Limit notifications only to higher order pages */
> +	if (order < PAGE_REPORTING_MIN_ORDER)
> +		return;
> +
> +	/* Do not bother with tests if we have already requested reporting */=

> +	if (test_bit(ZONE_PAGE_REPORTING_REQUESTED, &zone->flags))
> +		return;
> +
> +	/* If reported_pages is not populated, assume 0 */
> +	nr_reported =3D zone->reported_pages ?
> +		    zone->reported_pages[order - PAGE_REPORTING_MIN_ORDER] : 0;
> +
> +	/* Only request it if we have enough to begin the page reporting */
> +	if (zone->free_area[order].nr_free < nr_reported + PAGE_REPORTING_HWM=
)
> +		return;
> +
> +	/* This is slow, but should be called very rarely */
> +	__page_reporting_request(zone);
> +#endif
> +}
> +#endif /*_LINUX_PAGE_REPORTING_H */
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 56cec636a1fc..f5c68bba522f 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -237,6 +237,11 @@ config COMPACTION
>            linux-mm@kvack.org.
> =20
>  #
> +# support for unused page reporting
> +config PAGE_REPORTING
> +	bool
> +
> +#
>  # support for page migration
>  #
>  config MIGRATION
> diff --git a/mm/Makefile b/mm/Makefile
> index d0b295c3b764..1e17ba0ed2f0 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -105,3 +105,4 @@ obj-$(CONFIG_PERCPU_STATS) +=3D percpu-stats.o
>  obj-$(CONFIG_ZONE_DEVICE) +=3D memremap.o
>  obj-$(CONFIG_HMM_MIRROR) +=3D hmm.o
>  obj-$(CONFIG_MEMFD_CREATE) +=3D memfd.o
> +obj-$(CONFIG_PAGE_REPORTING) +=3D page_reporting.o
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 9a82e12bd0e7..3acd2c3e53b3 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1608,6 +1608,7 @@ static int __ref __offline_pages(unsigned long st=
art_pfn,
>  	if (!populated_zone(zone)) {
>  		zone_pcp_reset(zone);
>  		build_all_zonelists(NULL);
> +		page_reporting_reset(zone);
>  	} else
>  		zone_pcp_update(zone);
> =20
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 71aadc7d5ff6..69b848e5b83f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -68,6 +68,7 @@
>  #include <linux/lockdep.h>
>  #include <linux/nmi.h>
>  #include <linux/psi.h>
> +#include <linux/page_reporting.h>
> =20
>  #include <asm/sections.h>
>  #include <asm/tlbflush.h>
> @@ -915,7 +916,7 @@ static inline struct capture_control *task_capc(str=
uct zone *zone)
>  static inline void __free_one_page(struct page *page,
>  		unsigned long pfn,
>  		struct zone *zone, unsigned int order,
> -		int migratetype)
> +		int migratetype, bool reported)
>  {
>  	struct capture_control *capc =3D task_capc(zone);
>  	unsigned long uninitialized_var(buddy_pfn);
> @@ -990,11 +991,20 @@ static inline void __free_one_page(struct page *p=
age,
>  done_merging:
>  	set_page_order(page, order);
> =20
> -	if (is_shuffle_order(order) ? shuffle_add_to_tail() :
> -	    buddy_merge_likely(pfn, buddy_pfn, page, order))
> +	if (reported ||
> +	    (is_shuffle_order(order) ? shuffle_add_to_tail() :
> +	     buddy_merge_likely(pfn, buddy_pfn, page, order)))
>  		add_to_free_list_tail(page, zone, order, migratetype);
>  	else
>  		add_to_free_list(page, zone, order, migratetype);
> +
> +	/*
> +	 * No need to notify on a reported page as the total count of
> +	 * unreported pages will not have increased since we have essentially=

> +	 * merged the reported page with one or more unreported pages.
> +	 */
> +	if (!reported)
> +		page_reporting_notify_free(zone, order);
>  }
> =20
>  /*
> @@ -1305,7 +1315,7 @@ static void free_pcppages_bulk(struct zone *zone,=
 int count,
>  		if (unlikely(isolated_pageblocks))
>  			mt =3D get_pageblock_migratetype(page);
> =20
> -		__free_one_page(page, page_to_pfn(page), zone, 0, mt);
> +		__free_one_page(page, page_to_pfn(page), zone, 0, mt, false);
>  		trace_mm_page_pcpu_drain(page, 0, mt);
>  	}
>  	spin_unlock(&zone->lock);
> @@ -1321,7 +1331,7 @@ static void free_one_page(struct zone *zone,
>  		is_migrate_isolate(migratetype))) {
>  		migratetype =3D get_pfnblock_migratetype(page, pfn);
>  	}
> -	__free_one_page(page, pfn, zone, order, migratetype);
> +	__free_one_page(page, pfn, zone, order, migratetype, false);
>  	spin_unlock(&zone->lock);
>  }
> =20
> @@ -2183,6 +2193,122 @@ struct page *__rmqueue_smallest(struct zone *zo=
ne, unsigned int order,
>  	return NULL;
>  }
> =20
> +#ifdef CONFIG_PAGE_REPORTING
> +/**
> + * get_unreported_page - Pull an unreported page from the free_list
> + * @zone: Zone to draw pages from
> + * @order: Order to draw pages from
> + * @mt: Migratetype to draw pages from
> + *
> + * This function will obtain a page from the free list. It will start =
by
> + * attempting to pull from the tail of the free list and if that is al=
ready
> + * reported on it will instead pull the head if that is unreported.
> + *
> + * The page will have the migrate type and order stored in the page
> + * metadata. While being processed the page will not be avaialble for
> + * allocation.
> + *
> + * Return: page pointer if raw page found, otherwise NULL
> + */
> +struct page *get_unreported_page(struct zone *zone, unsigned int order=
, int mt)
> +{
> +	struct list_head *tail =3D get_unreported_tail(zone, order, mt);
> +	struct free_area *area =3D &(zone->free_area[order]);
> +	struct list_head *list =3D &area->free_list[mt];
> +	struct page *page;
> +
> +	/* zone lock should be held when this function is called */
> +	lockdep_assert_held(&zone->lock);
> +
> +	/* Find a page of the appropriate size in the preferred list */
> +	page =3D list_last_entry(tail, struct page, lru);
> +	list_for_each_entry_from_reverse(page, list, lru) {
> +		/* If we entered this loop then the "raw" list isn't empty */
> +
> +		/* If the page is reported try the head of the list */
> +		if (PageReported(page)) {
> +			page =3D list_first_entry(list, struct page, lru);
> +
> +			/*
> +			 * If both the head and tail are reported then reset
> +			 * the boundary so that we read as an empty list
> +			 * next time and bail out.
> +			 */
> +			if (PageReported(page)) {
> +				page_reporting_add_to_boundary(page, zone, mt);
> +				break;
> +			}
> +		}
> +
> +		del_page_from_free_list(page, zone, order);
> +
> +		/* record migratetype and order within page */
> +		set_pcppage_migratetype(page, mt);
> +		set_page_private(page, order);
> +
> +		/*
> +		 * Page will not be available for allocation while we are
> +		 * processing it so update the freepage state.
> +		 */
> +		__mod_zone_freepage_state(zone, -(1 << order), mt);
> +
> +		return page;
> +	}
> +
> +	return NULL;
> +}
> +
> +/**
> + * put_reported_page - Return a now-reported page back where we got it=

> + * @zone: Zone to return pages to
> + * @page: Page that was reported
> + *
> + * This function will pull the migratetype and order information out
> + * of the page and attempt to return it where it found it. If the page=

> + * is added to the free list without changes we will mark it as being
> + * reported.
> + */
> +void put_reported_page(struct zone *zone, struct page *page)
> +{
> +	unsigned int order, mt;
> +	unsigned long pfn;
> +
> +	/* zone lock should be held when this function is called */
> +	lockdep_assert_held(&zone->lock);
> +
> +	mt =3D get_pcppage_migratetype(page);
> +	pfn =3D page_to_pfn(page);
> +
> +	if (unlikely(has_isolate_pageblock(zone) || is_migrate_isolate(mt))) =
{
> +		mt =3D get_pfnblock_migratetype(page, pfn);
> +		set_pcppage_migratetype(page, mt);
> +	}
> +
> +	order =3D page_private(page);
> +	set_page_private(page, 0);
> +
> +	__free_one_page(page, pfn, zone, order, mt, true);

I don't think we need to hold the zone lock for fetching migratetype and =
other
information.
We can save some lock held time by acquiring and releasing zone lock befo=
re and
after __free_one_page() respectively. Isn't?

> +
> +	/*
> +	 * If page was comingled with another page we cannot consider
> +	 * the result to be "reported" since part of the page hasn't been.
> +	 * In this case we will simply exit and not update the "reported"
> +	 * state. Instead just treat the result as a unreported page.
> +	 */
> +	if (!PageBuddy(page) || page_order(page) !=3D order)
> +		return;
> +
> +	/* update areated page accounting */
> +	zone->reported_pages[order - PAGE_REPORTING_MIN_ORDER]++;
> +
> +	/* update boundary of new migratetype and record it */
> +	page_reporting_add_to_boundary(page, zone, mt);
> +
> +	/* flag page as reported */
> +	__SetPageReported(page);
> +}
> +#endif /* CONFIG_PAGE_REPORTING */
> +
>  /*
>   * This array describes the order lists are fallen back to when
>   * the free lists for the desirable migrate type are depleted
> diff --git a/mm/page_reporting.c b/mm/page_reporting.c
> new file mode 100644
> index 000000000000..971138205ae5
> --- /dev/null
> +++ b/mm/page_reporting.c
> @@ -0,0 +1,299 @@
> +// SPDX-License-Identifier: GPL-2.0
> +#include <linux/mm.h>
> +#include <linux/mmzone.h>
> +#include <linux/page-isolation.h>
> +#include <linux/gfp.h>
> +#include <linux/export.h>
> +#include <linux/delay.h>
> +#include <linux/slab.h>
> +#include <linux/scatterlist.h>
> +#include "internal.h"
> +
> +static struct page_reporting_dev_info __rcu *ph_dev_info __read_mostly=
;
> +struct static_key page_reporting_notify_enabled;
> +
> +struct list_head *boundary[MAX_ORDER - PAGE_REPORTING_MIN_ORDER][MIGRA=
TE_TYPES];
> +
> +static void page_reporting_reset_boundary(struct zone *zone, unsigned =
int order,
> +					  unsigned int migratetype)
> +{
> +	boundary[order - PAGE_REPORTING_MIN_ORDER][migratetype] =3D
> +			&zone->free_area[order].free_list[migratetype];
> +}
> +
> +#define for_each_reporting_migratetype_order(_order, _type) \
> +	for (_order =3D MAX_ORDER; _order-- !=3D PAGE_REPORTING_MIN_ORDER;) \=

> +		for (_type =3D MIGRATE_TYPES; _type--;)
> +
> +static int page_reporting_populate_metadata(struct zone *zone)
> +{
> +	unsigned int order, mt;
> +
> +	/*
> +	 * We need to make sure we have somewhere to store the tracking
> +	 * data for how many reported pages are in the zone. To do that
> +	 * we need to make certain zone->reported_pages is populated.
> +	 */
> +	if (!zone->reported_pages) {
> +		zone->reported_pages =3D
> +			kcalloc(MAX_ORDER - PAGE_REPORTING_MIN_ORDER,
> +				sizeof(unsigned long),
> +				GFP_KERNEL);
> +		if (!zone->reported_pages)
> +			return -ENOMEM;
> +	}
> +
> +	/* Update boundary data to reflect the zone we are currently working =
*/
> +	for_each_reporting_migratetype_order(order, mt)
> +		page_reporting_reset_boundary(zone, order, mt);
> +
> +	return 0;
> +}
> +
> +struct list_head *__page_reporting_get_boundary(unsigned int order,
> +						int migratetype)
> +{
> +	return boundary[order - PAGE_REPORTING_MIN_ORDER][migratetype];
> +}
> +
> +void page_reporting_del_from_boundary(struct page *page, struct zone *=
zone)
> +{
> +	unsigned int order =3D page_private(page) - PAGE_REPORTING_MIN_ORDER;=

> +	int mt =3D get_pcppage_migratetype(page);
> +	struct list_head **tail =3D &boundary[order][mt];
> +
> +	if (*tail =3D=3D &page->lru)
> +		*tail =3D page->lru.next;
> +}
> +
> +void page_reporting_add_to_boundary(struct page *page, struct zone *zo=
ne,
> +				    int migratetype)
> +{
> +	unsigned int order =3D page_private(page) - PAGE_REPORTING_MIN_ORDER;=

> +	struct list_head **tail =3D &boundary[order][migratetype];
> +
> +	*tail =3D &page->lru;
> +}
> +
> +static unsigned int page_reporting_fill(struct zone *zone,
> +					struct page_reporting_dev_info *phdev)
> +{
> +	struct scatterlist *sg =3D phdev->sg;
> +	unsigned int order, mt, count =3D 0;
> +
> +	sg_init_table(phdev->sg, phdev->capacity);
> +
> +	for_each_reporting_migratetype_order(order, mt) {
> +		struct page *page;
> +
> +		/*
> +		 * Pull pages from free list until we have drained
> +		 * it or we have reached capacity.
> +		 */
> +		while ((page =3D get_unreported_page(zone, order, mt))) {
> +			sg_set_page(&sg[count], page, PAGE_SIZE << order, 0);
> +
> +			if (++count =3D=3D phdev->capacity)
> +				return count;
> +		}
> +	}
> +
> +	/* mark end of scatterlist due to underflow */
> +	if (count)
> +		sg_mark_end(&sg[count - 1]);
> +
> +	/*
> +	 * If there are no longer enough free pages to fully populate
> +	 * the scatterlist, then we can just shut it down for this zone.
> +	 */
> +	__clear_bit(ZONE_PAGE_REPORTING_REQUESTED, &zone->flags);
> +	atomic_dec(&phdev->refcnt);
> +
> +	return count;
> +}
> +
> +static void page_reporting_drain(struct zone *zone,
> +				 struct page_reporting_dev_info *phdev)
> +{
> +	struct scatterlist *sg =3D phdev->sg;
> +
> +	/*
> +	 * Drain the now reported pages back into their respective
> +	 * free lists/areas. We assume at least one page is populated.
> +	 */
> +	do {
> +		put_reported_page(zone, sg_page(sg));
> +	} while (!sg_is_last(sg++));
> +}
> +
> +/*
> + * The page reporting cycle consists of 4 stages, fill, report, drain,=
 and idle.
> + * We will cycle through the first 3 stages until we fail to obtain an=
y
> + * pages, in that case we will switch to idle.
> + */
> +static void page_reporting_cycle(struct zone *zone,
> +				 struct page_reporting_dev_info *phdev)
> +{
> +	/*
> +	 * Guarantee boundaries and stats are populated before we
> +	 * start placing reported pages in the zone.
> +	 */
> +	if (page_reporting_populate_metadata(zone))
> +		return;
> +
> +	spin_lock(&zone->lock);
> +
> +	/* set bit indicating boundaries are present */
> +	__set_bit(ZONE_PAGE_REPORTING_ACTIVE, &zone->flags);
> +
> +	do {
> +		/* Pull pages out of allocator into a scaterlist */
> +		unsigned int nents =3D page_reporting_fill(zone, phdev);
> +
> +		/* no pages were acquired, give up */
> +		if (!nents)
> +			break;
> +
> +		spin_unlock(&zone->lock);
> +
> +		/* begin processing pages in local list */
> +		phdev->report(phdev, nents);
> +
> +		spin_lock(&zone->lock);
> +
> +		/*
> +		 * We should have a scatterlist of pages that have been
> +		 * processed. Return them to their original free lists.
> +		 */
> +		page_reporting_drain(zone, phdev);
> +
> +		/* keep pulling pages till there are none to pull */
> +	} while (test_bit(ZONE_PAGE_REPORTING_REQUESTED, &zone->flags));
> +
> +	/* processing of the zone is complete, we can disable boundaries */
> +	__clear_bit(ZONE_PAGE_REPORTING_ACTIVE, &zone->flags);
> +
> +	spin_unlock(&zone->lock);
> +}
> +
> +static void page_reporting_process(struct work_struct *work)
> +{
> +	struct delayed_work *d_work =3D to_delayed_work(work);
> +	struct page_reporting_dev_info *phdev =3D
> +		container_of(d_work, struct page_reporting_dev_info, work);
> +	struct zone *zone =3D first_online_pgdat()->node_zones;
> +
> +	do {
> +		if (test_bit(ZONE_PAGE_REPORTING_REQUESTED, &zone->flags))
> +			page_reporting_cycle(zone, phdev);
> +
> +		/*
> +		 * Move to next zone, if at the end of the list
> +		 * test to see if we can just go into idle.
> +		 */
> +		zone =3D next_zone(zone);
> +		if (zone)
> +			continue;
> +		zone =3D first_online_pgdat()->node_zones;
> +
> +		/*
> +		 * As long as refcnt has not reached zero there are still
> +		 * zones to be processed.
> +		 */
> +	} while (atomic_read(&phdev->refcnt));
> +}
> +
> +/* request page reporting on this zone */
> +void __page_reporting_request(struct zone *zone)
> +{
> +	struct page_reporting_dev_info *phdev;
> +
> +	rcu_read_lock();
> +
> +	/*
> +	 * We use RCU to protect the ph_dev_info pointer. In almost all
> +	 * cases this should be present, however in the unlikely case of
> +	 * a shutdown this will be NULL and we should exit.
> +	 */
> +	phdev =3D rcu_dereference(ph_dev_info);
> +	if (unlikely(!phdev))
> +		return;
> +
> +	/*
> +	 * We can use separate test and set operations here as there
> +	 * is nothing else that can set or clear this bit while we are
> +	 * holding the zone lock. The advantage to doing it this way is
> +	 * that we don't have to dirty the cacheline unless we are
> +	 * changing the value.
> +	 */
> +	__set_bit(ZONE_PAGE_REPORTING_REQUESTED, &zone->flags);
> +
> +	/*
> +	 * Delay the start of work to allow a sizable queue to
> +	 * build. For now we are limiting this to running no more
> +	 * than 10 times per second.
> +	 */
> +	if (!atomic_fetch_inc(&phdev->refcnt))
> +		schedule_delayed_work(&phdev->work, HZ / 10);
> +
> +	rcu_read_unlock();
> +}
> +
> +void __page_reporting_free_stats(struct zone *zone)
> +{
> +	/* free reported_page statisitics */
> +	kfree(zone->reported_pages);
> +	zone->reported_pages =3D NULL;
> +}
> +
> +void page_reporting_shutdown(struct page_reporting_dev_info *phdev)
> +{
> +	if (rcu_access_pointer(ph_dev_info) !=3D phdev)
> +		return;
> +
> +	/* Disable page reporting notification */
> +	static_key_slow_dec(&page_reporting_notify_enabled);
> +	RCU_INIT_POINTER(ph_dev_info, NULL);
> +	synchronize_rcu();
> +
> +	/* Flush any existing work, and lock it out */
> +	cancel_delayed_work_sync(&phdev->work);
> +
> +	/* Free scatterlist */
> +	kfree(phdev->sg);
> +	phdev->sg =3D NULL;
> +}
> +EXPORT_SYMBOL_GPL(page_reporting_shutdown);
> +
> +int page_reporting_startup(struct page_reporting_dev_info *phdev)
> +{
> +	struct zone *zone;
> +
> +	/* nothing to do if already in use */
> +	if (rcu_access_pointer(ph_dev_info))
> +		return -EBUSY;
> +
> +	/* allocate scatterlist to store pages being reported on */
> +	phdev->sg =3D kcalloc(phdev->capacity, sizeof(*phdev->sg), GFP_KERNEL=
);
> +	if (!phdev->sg)
> +		return -ENOMEM;
> +
> +	/* initialize refcnt and work structures */
> +	atomic_set(&phdev->refcnt, 0);
> +	INIT_DELAYED_WORK(&phdev->work, &page_reporting_process);
> +
> +	/* assign device, and begin initial flush of populated zones */
> +	rcu_assign_pointer(ph_dev_info, phdev);


Will, it not make sense to do this at the top after rcu_access_pointer ch=
eck()?
Otherwise, there could be a race between two enablers. Am I missing somet=
hing here?


> +	for_each_populated_zone(zone) {
> +		spin_lock(&zone->lock);
> +		__page_reporting_request(zone);
> +		spin_unlock(&zone->lock);
> +	}
> +
> +	/* enable page reporting notification */
> +	static_key_slow_inc(&page_reporting_notify_enabled);
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(page_reporting_startup);
> +
>
--=20
Thanks
Nitesh

