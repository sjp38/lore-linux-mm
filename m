Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3DE1C8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 17:17:58 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id g12so2931496pll.22
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 14:17:58 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id h17si12326482pgd.538.2019.01.08.14.17.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 14:17:56 -0800 (PST)
Message-ID: <7c81c8bc741819e87e9a2a39a8b1b6d2f8d3423a.camel@linux.intel.com>
Subject: Re: [PATCH v7] mm/page_alloc.c: memory_hotplug: free pages as
 higher order
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Tue, 08 Jan 2019 14:17:56 -0800
In-Reply-To: <1546578076-31716-1-git-send-email-arunks@codeaurora.org>
References: <1546578076-31716-1-git-send-email-arunks@codeaurora.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>, arunks.linux@gmail.com, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: getarunks@gmail.com

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

Sorry, ended up encountering a couple more things that have me a bit
confused.

[...]

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

So the question I have is why was a return value added to these
functions? They were previously void types and now they are int. What
is the return value expected other than 0?

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

Why did we rename this function? I see it was added as a new function
in v3, however in v4 we ended up replacing it completely. So why not
just keep the same name and make it easier for us to identify that the
is the Xen version of the XXX_online_pages callback?

[...]

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

So if the ret > 0 it is supposed to represent how many pages were
onlined within a given block? What if the ret was negative? Really I am
not a fan of adding a return value to the online functions unless we
specifically document what the expected return values are supposed to
be. If we don't have any return values other than 0 there isn't much
point in having one anyway.
