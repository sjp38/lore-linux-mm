Return-Path: <SRS0=RE7g=PQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 308CBC43387
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 17:56:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E24A22064C
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 17:56:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E24A22064C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7974D8E0086; Tue,  8 Jan 2019 12:56:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 720B58E0038; Tue,  8 Jan 2019 12:56:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BF618E0086; Tue,  8 Jan 2019 12:56:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1344E8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 12:56:15 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id f9so2451227pgs.13
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 09:56:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3eslU51piDgJnqnbna+ivcZ9jF4RPDE2SuUsNv9Dn4Q=;
        b=PxrLXMrsabd9YcBVPkEGmjiF86gdHzG6w8yIXh2Cjjmdl8y6Lb19aDIsXLUEZAxHGi
         QBwyzzZCFjHBm6xy5b46u1E7DeAkJdr/KXIm17zR4VnQSAM26F6FhMPC3mtLIPnAQEDK
         sSza0U3AOmbuwbhUvez4Sw48W9X33kHwozsxYBDHdQEBtoQjDNPENAMFvTqeglYnho+n
         bta415to0cDUDZg+raI1uuuj4I5xXAGPlmJxrJK3e2QpZjuBWG9gkhSY8ghIAlszBoaV
         qLcDBz07KA4DZRR5ZKtEwJjXcRlOMi1XQBOmni2a3r9SMrzVHUnOv8AXuZMXmmnK4vIL
         Dxuw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukehdMf6irqypLrtLBb8rTeup7v0EZPKiYkE2w3NuPh+iJy4LspM
	/I13txZj0Fr1A4RXu7cwqiwh4FRZWDh4Ks7wjC3QCwnar625Y5PGLbPsBQ6S/xW7Nk8w8SduelQ
	RjB1+upT4k2Me3/TK2IdGs2FtRrTB3gbdRTe6u82BQ8YZKdHIkJ9m8qe3voPc+qbiBA==
X-Received: by 2002:a63:e615:: with SMTP id g21mr2422831pgh.290.1546970174668;
        Tue, 08 Jan 2019 09:56:14 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7GJv5NKei36BAy/pzJ+mVvr59xp3JpDFInOPX9aY7aAvq8LAL+CUQkABf4gGxR3DZlw6Mf
X-Received: by 2002:a63:e615:: with SMTP id g21mr2422759pgh.290.1546970173377;
        Tue, 08 Jan 2019 09:56:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546970173; cv=none;
        d=google.com; s=arc-20160816;
        b=LFnv0bbQkDyjZRNu8s19z0M9Isq3nJsBvgqYBLNChNufKDVmizP0UNCEMIMA5neoNy
         W3bVe8Raba/AO4GOWt4wMb76mtMN94mWvmWfrTeAvmV2JjR0AcYjMgeSGlB7PP+wDy2y
         czJGZnB28PzCslATnCv2ma1O0L2wWc5NsWq8MDv+rl6L/aSiXr798gUWmsrD4PZ/7KCc
         BVPo2J7gVc5Yv6zagMEvUXEvi/r4jzv+jPxFZKQAYDm23pmWgVx17eCpOj+PmSHz+wFr
         IAS4XhRr853QOwvKULbWoal9EGwhrW2blcai/znwjaM8eKVQAquBbLZGeFk8zrnRHDJU
         FM4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=3eslU51piDgJnqnbna+ivcZ9jF4RPDE2SuUsNv9Dn4Q=;
        b=XHp8/RtaqJ9njVmPHtQlyPzytlL4xyyJQuZEZYqXESE7mBbFGRyv2mxUj7fdBH8jsv
         JImWUwa0/XxePu4wrSwC0auoW6pauowJvV6nWXjpgBM0nws6sStoX3DNzig6C5Yfb8iX
         5HAPUGlsRSCPcY1/dd+Rb4x5r3N7X6mcFWDWQ5KJlx8bVLFtZ5/PCdn3hO1OP6v1K70V
         tfklONQhOGY5kb0Vn3hDGEZ3xPOSt4ZnfNK8edARTUFbgY0XCXt+LKAr4sjmif4Np8HJ
         HS0pB54KjB1OUAByLu/9PPvoNrQEnWCDqPTSkdFrEjs1a9HpJ/flB8kNzMo1MFMlamHO
         SRBg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id v6si64776038pgv.277.2019.01.08.09.56.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 09:56:13 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 Jan 2019 09:56:12 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,455,1539673200"; 
   d="scan'208";a="125261114"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga001.jf.intel.com with ESMTP; 08 Jan 2019 09:56:09 -0800
Message-ID: <fb6465c99b3ada2c6af587a7eb00016d96d56f77.camel@linux.intel.com>
Subject: Re: [PATCH v7] mm/page_alloc.c: memory_hotplug: free pages as
 higher order
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Arun KS <arunks@codeaurora.org>, arunks.linux@gmail.com, 
 akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz,
 osalvador@suse.de,  linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: getarunks@gmail.com
Date: Tue, 08 Jan 2019 09:56:09 -0800
In-Reply-To: <1546578076-31716-1-git-send-email-arunks@codeaurora.org>
References: <1546578076-31716-1-git-send-email-arunks@codeaurora.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190108175609.xn4S96lU3QrLqsNxES-arhf9YGcIYz1r9J87Nuqr4tY@z>

On Fri, 2019-01-04 at 10:31 +0530, Arun KS wrote:
> When freeing pages are done with higher order, time spent on coalescing
> pages by buddy allocator can be reduced.  With section size of 256MB, hot
> add latency of a single section shows improvement from 50-60 ms to less
> than 1 ms, hence improving the hot add latency by 60 times.  Modify
> external providers of online callback to align with the change.
> 
> Signed-off-by: Arun KS <arunks@codeaurora.org>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Reviewed-by: Oscar Salvador <osalvador@suse.de>
> ---
> Changes since v6:
> - Rebased to 4.20
> - Changelog updated.
> - No improvement seen on arm64, hence removed removal of prefetch.
> 
> Changes since v5:
> - Rebased to 4.20-rc1.
> - Changelog updated.
> 
> Changes since v4:
> - As suggested by Michal Hocko,
> - Simplify logic in online_pages_block() by using get_order().
> - Seperate out removal of prefetch from __free_pages_core().
> 
> Changes since v3:
> - Renamed _free_pages_boot_core -> __free_pages_core.
> - Removed prefetch from __free_pages_core.
> - Removed xen_online_page().
> 
> Changes since v2:
> - Reuse code from __free_pages_boot_core().
> 
> Changes since v1:
> - Removed prefetch().
> 
> Changes since RFC:
> - Rebase.
> - As suggested by Michal Hocko remove pages_per_block.
> - Modifed external providers of online_page_callback.
> 
> v6: https://lore.kernel.org/patchwork/patch/1007253/
> v5: https://lore.kernel.org/patchwork/patch/995739/
> v4: https://lore.kernel.org/patchwork/patch/995111/
> v3: https://lore.kernel.org/patchwork/patch/992348/
> v2: https://lore.kernel.org/patchwork/patch/991363/
> v1: https://lore.kernel.org/patchwork/patch/989445/
> RFC: https://lore.kernel.org/patchwork/patch/984754/
> 
> ---
>  drivers/hv/hv_balloon.c        |  6 ++++--
>  drivers/xen/balloon.c          | 23 +++++++++++++++--------
>  include/linux/memory_hotplug.h |  2 +-
>  mm/internal.h                  |  1 +
>  mm/memory_hotplug.c            | 42 ++++++++++++++++++++++++++++++------------
>  mm/page_alloc.c                |  8 ++++----
>  6 files changed, 55 insertions(+), 27 deletions(-)
> 
> diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
> index 5301fef..211f3fe 100644
> --- a/drivers/hv/hv_balloon.c
> +++ b/drivers/hv/hv_balloon.c
> @@ -771,7 +771,7 @@ static void hv_mem_hot_add(unsigned long start, unsigned long size,
>  	}
>  }
>  
> -static void hv_online_page(struct page *pg)
> +static int hv_online_page(struct page *pg, unsigned int order)
>  {
>  	struct hv_hotadd_state *has;
>  	unsigned long flags;
> @@ -783,10 +783,12 @@ static void hv_online_page(struct page *pg)
>  		if ((pfn < has->start_pfn) || (pfn >= has->end_pfn))
>  			continue;
>  
> -		hv_page_online_one(has, pg);
> +		hv_bring_pgs_online(has, pfn, (1UL << order));
>  		break;
>  	}
>  	spin_unlock_irqrestore(&dm_device.ha_lock, flags);
> +
> +	return 0;
>  }
>  
>  static int pfn_covered(unsigned long start_pfn, unsigned long pfn_cnt)
> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
> index ceb5048..95f888f 100644
> --- a/drivers/xen/balloon.c
> +++ b/drivers/xen/balloon.c
> @@ -345,8 +345,8 @@ static enum bp_state reserve_additional_memory(void)
>  
>  	/*
>  	 * add_memory_resource() will call online_pages() which in its turn
> -	 * will call xen_online_page() callback causing deadlock if we don't
> -	 * release balloon_mutex here. Unlocking here is safe because the
> +	 * will call xen_bring_pgs_online() callback causing deadlock if we
> +	 * don't release balloon_mutex here. Unlocking here is safe because the
>  	 * callers drop the mutex before trying again.
>  	 */
>  	mutex_unlock(&balloon_mutex);
> @@ -369,15 +369,22 @@ static enum bp_state reserve_additional_memory(void)
>  	return BP_ECANCELED;
>  }
>  
> -static void xen_online_page(struct page *page)
> +static int xen_bring_pgs_online(struct page *pg, unsigned int order)
>  {
> -	__online_page_set_limits(page);
> +	unsigned long i, size = (1 << order);
> +	unsigned long start_pfn = page_to_pfn(pg);
> +	struct page *p;
>  
> +	pr_debug("Online %lu pages starting at pfn 0x%lx\n", size, start_pfn);
>  	mutex_lock(&balloon_mutex);
> -
> -	__balloon_append(page);
> -
> +	for (i = 0; i < size; i++) {
> +		p = pfn_to_page(start_pfn + i);
> +		__online_page_set_limits(p);
> +		__balloon_append(p);
> +	}
>  	mutex_unlock(&balloon_mutex);
> +
> +	return 0;
>  }
>  
>  static int xen_memory_notifier(struct notifier_block *nb, unsigned long val, void *v)
> @@ -702,7 +709,7 @@ static int __init balloon_init(void)
>  	balloon_stats.max_retry_count = RETRY_UNLIMITED;
>  
>  #ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
> -	set_online_page_callback(&xen_online_page);
> +	set_online_page_callback(&xen_bring_pgs_online);
>  	register_memory_notifier(&xen_memory_nb);
>  	register_sysctl_table(xen_root);
>  #endif
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 07da5c6..d56bfba 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -87,7 +87,7 @@ extern int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn,
>  	unsigned long *valid_start, unsigned long *valid_end);
>  extern void __offline_isolated_pages(unsigned long, unsigned long);
>  
> -typedef void (*online_page_callback_t)(struct page *page);
> +typedef int (*online_page_callback_t)(struct page *page, unsigned int order);
>  
>  extern int set_online_page_callback(online_page_callback_t callback);
>  extern int restore_online_page_callback(online_page_callback_t callback);
> diff --git a/mm/internal.h b/mm/internal.h
> index f4a7bb0..536bc2a 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -163,6 +163,7 @@ static inline struct page *pageblock_pfn_to_page(unsigned long start_pfn,
>  extern int __isolate_free_page(struct page *page, unsigned int order);
>  extern void memblock_free_pages(struct page *page, unsigned long pfn,
>  					unsigned int order);
> +extern void __free_pages_core(struct page *page, unsigned int order);
>  extern void prep_compound_page(struct page *page, unsigned int order);
>  extern void post_alloc_hook(struct page *page, unsigned int order,
>  					gfp_t gfp_flags);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index b9a667d..0ea0eb1 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -47,7 +47,7 @@
>   * and restore_online_page_callback() for generic callback restore.
>   */
>  
> -static void generic_online_page(struct page *page);
> +static int generic_online_page(struct page *page, unsigned int order);
>  
>  static online_page_callback_t online_page_callback = generic_online_page;
>  static DEFINE_MUTEX(online_page_callback_lock);
> @@ -656,26 +656,44 @@ void __online_page_free(struct page *page)
>  }
>  EXPORT_SYMBOL_GPL(__online_page_free);
>  
> -static void generic_online_page(struct page *page)
> +static int generic_online_page(struct page *page, unsigned int order)
>  {
> -	__online_page_set_limits(page);
> -	__online_page_increment_counters(page);
> -	__online_page_free(page);
> +	__free_pages_core(page, order);
> +	totalram_pages_add(1UL << order);
> +#ifdef CONFIG_HIGHMEM
> +	if (PageHighMem(page))
> +		totalhigh_pages_add(1UL << order);
> +#endif
> +	return 0;
> +}
> +
> +static int online_pages_blocks(unsigned long start, unsigned long nr_pages)
> +{
> +	unsigned long end = start + nr_pages;
> +	int order, ret, onlined_pages = 0;
> +
> +	while (start < end) {
> +		order = min(MAX_ORDER - 1,
> +			get_order(PFN_PHYS(end) - PFN_PHYS(start)));
> +
> +		ret = (*online_page_callback)(pfn_to_page(start), order);
> +		if (!ret)
> +			onlined_pages += (1UL << order);
> +		else if (ret > 0)
> +			onlined_pages += ret;
> +
> +		start += (1UL << order);
> +	}
> +	return onlined_pages;
>  }
>  
>  static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
>  			void *arg)
>  {
> -	unsigned long i;
>  	unsigned long onlined_pages = *(unsigned long *)arg;
> -	struct page *page;
>  
>  	if (PageReserved(pfn_to_page(start_pfn)))
> -		for (i = 0; i < nr_pages; i++) {
> -			page = pfn_to_page(start_pfn + i);
> -			(*online_page_callback)(page);
> -			onlined_pages++;
> -		}
> +		onlined_pages = online_pages_blocks(start_pfn, nr_pages);

Shouldn't this be a "+=" instead of an "="? It seems like you are going
to lose your count otherwise.

>  
>  	online_mem_sections(start_pfn, start_pfn + nr_pages);
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index cde5dac..f51a920 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1303,7 +1303,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
>  	local_irq_restore(flags);
>  }
>  
> -static void __init __free_pages_boot_core(struct page *page, unsigned int order)
> +void __free_pages_core(struct page *page, unsigned int order)
>  {
>  	unsigned int nr_pages = 1 << order;
>  	struct page *p = page;
> @@ -1382,7 +1382,7 @@ void __init memblock_free_pages(struct page *page, unsigned long pfn,
>  {
>  	if (early_page_uninitialised(pfn))
>  		return;
> -	return __free_pages_boot_core(page, order);
> +	__free_pages_core(page, order);
>  }
>  
>  /*
> @@ -1472,14 +1472,14 @@ static void __init deferred_free_range(unsigned long pfn,
>  	if (nr_pages == pageblock_nr_pages &&
>  	    (pfn & (pageblock_nr_pages - 1)) == 0) {
>  		set_pageblock_migratetype(page, MIGRATE_MOVABLE);
> -		__free_pages_boot_core(page, pageblock_order);
> +		__free_pages_core(page, pageblock_order);
>  		return;
>  	}
>  
>  	for (i = 0; i < nr_pages; i++, page++, pfn++) {
>  		if ((pfn & (pageblock_nr_pages - 1)) == 0)
>  			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
> -		__free_pages_boot_core(page, 0);
> +		__free_pages_core(page, 0);
>  	}
>  }
>  

