Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 685F7C43444
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 16:23:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECC56206B7
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 16:23:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECC56206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 583D58E0002; Thu, 10 Jan 2019 11:23:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5358F8E0001; Thu, 10 Jan 2019 11:23:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44B038E0002; Thu, 10 Jan 2019 11:23:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id F16998E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 11:23:36 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id m3so8111998pfj.14
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 08:23:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XOHIQcY4GoVGS3wnbzkAY9EFxeZpqvcWVrzgNqkF0d8=;
        b=adWPJODNyMVL9ee4daS0chmpPW3RDQUGfex7uoYRhRFp90QkhaAufSfmWXv2VuGr2P
         2B7S2A2TaWFil9qAUjZwC64DiGu6Myw3nmoop1rvogqiYEgDpDux1aHnx7pe9Nll1QbZ
         zzm8k5EfQOnuEO9xpMUyyF+vgpuBTOf12/7feeguN+a4op5a9A0c8kWNK8pg1O7jBwRm
         COQc7pYD+PFiAIy+0T9kZsrqr1Dur2aeb3c48+JlXDNCtZAd4Ig+DlWAxn9Q1nBSm8kr
         ls5IIagA4QVBiXOWNxr4DRar1ifGKEuR1tfPyA5cW5sG/EBnnmy45LW3qfZ7CI8MEhtp
         gyfQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukcN7CjYUsr6yuQPs3EOS6THfa2EacK29ZSGF4Zw8J8Lc7+mHygK
	fEKI/+9onD48fJFQLnbThhY/JMYO5h9VZW0BxowC1eKRt+fLWmsZMyOwqqf51X8Ng8k8Xij7Uiw
	zKpLs8JqQXw9YAwn3wzjxMkjwfskUEkO/Mfq1dELJZ7busz3h+D03vpDJhP5YN+Cmhw==
X-Received: by 2002:a62:9111:: with SMTP id l17mr10808732pfe.200.1547137416541;
        Thu, 10 Jan 2019 08:23:36 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5n77Vi0NuIAxauseGYpIxeXzwrkWx0pdXEOiZfwK5jPFe7z0ZJq+Hj+GpbwLxtFWSppKDi
X-Received: by 2002:a62:9111:: with SMTP id l17mr10808623pfe.200.1547137414868;
        Thu, 10 Jan 2019 08:23:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547137414; cv=none;
        d=google.com; s=arc-20160816;
        b=teM0kUQshj749Tc2Tf5EUGyktGDYEQM/zoY9ehEYhiuXQmMXONNKsgIqt/ZvzWcYcY
         OTvjOlDfWKQiESrsbWhqwVJgIvaiAmwFhYteZeelTFUPzTEaXMB2yjDX66yjkLclRiM+
         SrzsBm/gcvP0LBvwGyqa+DpPZVDAP3t2p+2vO6/oytS1bMdvm23rz3FavcxbZIh5k0HG
         WWAXZfFQWeA+btEYUpPiTnmZnlNsJFtmvaw1lq1AkSt4UQFkGwH6BaVszSKObF2t0wNY
         +CQWA7cYy7EYYqNtmFVEnLWy+6l9sVbGtJsUcoyCDGzgaeRzWT+drFdBIGUHQAcUSFU3
         x4og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=XOHIQcY4GoVGS3wnbzkAY9EFxeZpqvcWVrzgNqkF0d8=;
        b=w0FdECX0Ea7KCWD3mMkg2ZIaJMPVN8pVnvBrE34NjRZtCIdssBSoX9vZUkRuDmvKy+
         Aq4JRkBT5GAK+LGqmrClP48Ag9Uu6Icjr4RmtPRa7e5QnLrImmPGByjaALQ90/CPRX7H
         KcdByE0eCPschWM8sS+x1xjaLYIkiA6JIbYIioeFakva81uFlI0AUXqvMUBxPWC4qQMX
         6nowGELBAjzZq0DwIMZW9LjPwa40Ra05H8n7qwbmKcRC94tUzTTBipmpL+0w3nlX4fvT
         avNnpOnGsSVrnEVIxjSVhXwvYObRo5AqwNLuQu+T/iOE64raQixRS9WmtZ6gjn+oYgOM
         MbAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id g21si26790118plo.435.2019.01.10.08.23.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 08:23:34 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Jan 2019 08:23:34 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,462,1539673200"; 
   d="scan'208";a="126621178"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga001.jf.intel.com with ESMTP; 10 Jan 2019 08:23:34 -0800
Message-ID: <f65b1b22426855ff261b3af719e58eded576a168.camel@linux.intel.com>
Subject: Re: [PATCH v9] mm/page_alloc.c: memory_hotplug: free pages as
 higher order
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Arun KS <arunks@codeaurora.org>, arunks.linux@gmail.com, 
 akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz,
 osalvador@suse.de,  linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: getarunks@gmail.com
Date: Thu, 10 Jan 2019 08:23:34 -0800
In-Reply-To: <1547098543-26452-1-git-send-email-arunks@codeaurora.org>
References: <1547098543-26452-1-git-send-email-arunks@codeaurora.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110162334.9-4eUnLkqNNmrIFmbJY3CS6csreXyfCg0KE5EmEnwRY@z>

On Thu, 2019-01-10 at 11:05 +0530, Arun KS wrote:
> When freeing pages are done with higher order, time spent on coalescing
> pages by buddy allocator can be reduced.  With section size of 256MB, hot
> add latency of a single section shows improvement from 50-60 ms to less
> than 1 ms, hence improving the hot add latency by 60 times.  Modify
> external providers of online callback to align with the change.
> 
> Signed-off-by: Arun KS <arunks@codeaurora.org>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Reviewed-by: Oscar Salvador <osalvador@suse.de>

So I decided to give this one last thorough review and I think I might
have found a few more minor issues, but not anything that is
necessarily a showstopper.

Reviewed-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>

> ---
> Changes since v8:
> - Remove return type change for online_page_callback.
> - Use consistent names for external online_page providers.
> - Fix onlined_pages accounting.
> 
> Changes since v7:
> - Rebased to 5.0-rc1.
> - Fixed onlined_pages accounting.
> - Added comment for return value of online_page_callback.
> - Renamed xen_bring_pgs_online to xen_online_pages.
> 
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
> v8: https://lore.kernel.org/patchwork/patch/1030332/
> v7: https://lore.kernel.org/patchwork/patch/1028908/
> v6: https://lore.kernel.org/patchwork/patch/1007253/
> v5: https://lore.kernel.org/patchwork/patch/995739/
> v4: https://lore.kernel.org/patchwork/patch/995111/
> v3: https://lore.kernel.org/patchwork/patch/992348/
> v2: https://lore.kernel.org/patchwork/patch/991363/
> v1: https://lore.kernel.org/patchwork/patch/989445/
> RFC: https://lore.kernel.org/patchwork/patch/984754/
> ---
> ---
>  drivers/hv/hv_balloon.c        |  4 ++--
>  drivers/xen/balloon.c          | 15 ++++++++++-----
>  include/linux/memory_hotplug.h |  2 +-
>  mm/internal.h                  |  1 +
>  mm/memory_hotplug.c            | 37 +++++++++++++++++++++++++------------
>  mm/page_alloc.c                |  8 ++++----
>  6 files changed, 43 insertions(+), 24 deletions(-)
> 
> diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
> index 5301fef..55d79f8 100644
> --- a/drivers/hv/hv_balloon.c
> +++ b/drivers/hv/hv_balloon.c
> @@ -771,7 +771,7 @@ static void hv_mem_hot_add(unsigned long start, unsigned long size,
>  	}
>  }
>  
> -static void hv_online_page(struct page *pg)
> +static void hv_online_page(struct page *pg, unsigned int order)
>  {
>  	struct hv_hotadd_state *has;
>  	unsigned long flags;
> @@ -783,7 +783,7 @@ static void hv_online_page(struct page *pg)
>  		if ((pfn < has->start_pfn) || (pfn >= has->end_pfn))
>  			continue;
>  

I haven't followed earlier reviews, but do we know for certain the
entire range being onlined will fit within a single hv_hotadd_state? If
nothing else it seems like this check should be updated so that we are
checking to verify that pfn + (1UL << order) is less than or equal to
has->end_pfn.

> -		hv_page_online_one(has, pg);
> +		hv_bring_pgs_online(has, pfn, (1UL << order));
>  		break;
>  	}
>  	spin_unlock_irqrestore(&dm_device.ha_lock, flags);
> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
> index ceb5048..d107447 100644
> --- a/drivers/xen/balloon.c
> +++ b/drivers/xen/balloon.c
> @@ -369,14 +369,19 @@ static enum bp_state reserve_additional_memory(void)
>  	return BP_ECANCELED;
>  }
>  
> -static void xen_online_page(struct page *page)
> +static void xen_online_page(struct page *page, unsigned int order)
>  {
> -	__online_page_set_limits(page);
> +	unsigned long i, size = (1 << order);
> +	unsigned long start_pfn = page_to_pfn(page);
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
>  }
>  
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 07da5c6..e368730 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -87,7 +87,7 @@ extern int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn,
>  	unsigned long *valid_start, unsigned long *valid_end);
>  extern void __offline_isolated_pages(unsigned long, unsigned long);
>  
> -typedef void (*online_page_callback_t)(struct page *page);
> +typedef void (*online_page_callback_t)(struct page *page, unsigned int order);
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
> index b9a667d..77dff24 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -47,7 +47,7 @@
>   * and restore_online_page_callback() for generic callback restore.
>   */
>  
> -static void generic_online_page(struct page *page);
> +static void generic_online_page(struct page *page, unsigned int order);
>  
>  static online_page_callback_t online_page_callback = generic_online_page;
>  static DEFINE_MUTEX(online_page_callback_lock);
> @@ -656,26 +656,39 @@ void __online_page_free(struct page *page)
>  }
>  EXPORT_SYMBOL_GPL(__online_page_free);
>  
> -static void generic_online_page(struct page *page)
> +static void generic_online_page(struct page *page, unsigned int order)
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

So this is mostly just optimization related so you can ignore this
suggestion if you want. I was looking at this and it occurred to me
that I don't think you need to convert this to a physical address do
you?

Couldn't you just do something like the following:
		if ((end - start) >= (1UL << (MAX_ORDER - 1))
			order = MAX_ORDER - 1;
		else
			order = __fls(end - start);

I would think this would save you a few steps in terms of conversions
and such since you are already working in page frame numbers anyway so
a block of 8 pfns would represent an order 3 page wouldn't it?

Also it seems like an alternative to using "end" would be to just track
nr_pages. Then you wouldn't have to do the "end - start" math in a few
spots as long as you remembered to decrement nr_pages by the amount you
increment start by.

> +		(*online_page_callback)(pfn_to_page(start), order);
> +
> +		onlined_pages += (1UL << order);
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
> +		onlined_pages += online_pages_blocks(start_pfn, nr_pages);
>  
>  	online_mem_sections(start_pfn, start_pfn + nr_pages);
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d295c9b..883212a 100644
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

