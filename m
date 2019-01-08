Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D615A8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 13:40:20 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id b8so3339678pfe.10
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 10:40:20 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id e13si9225907pfi.271.2019.01.08.10.40.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 10:40:19 -0800 (PST)
Message-ID: <37498672d5b2345b1435477e78251282af42742b.camel@linux.intel.com>
Subject: Re: [PATCH v7] mm/page_alloc.c: memory_hotplug: free pages as
 higher order
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Tue, 08 Jan 2019 10:40:18 -0800
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

After running into my initial issue I actually had a few more questions
about this patch.

> [...]
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

Should the limit for this really be MAX_ORDER - 1 or should it be
pageblock_order? In some cases this will be the same value, but I seem
to recall that for x86 MAX_ORDER can be several times larger than
pageblock_order.

>  static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
>  			void *arg)
>  {
> -	unsigned long i;
>  	unsigned long onlined_pages = *(unsigned long *)arg;
> -	struct page *page;
>  
>  	if (PageReserved(pfn_to_page(start_pfn)))

I'm not sure we even really need this check. Getting back to the
discussion I have been having with Michal in regards to the need for
the DAX pages to not have the reserved bit cleared I was originally
wondering if we could replace this check with a call to
online_section_nr since the section shouldn't be online until we set
the bit below in online_mem_sections.

However after doing some further digging it looks like this could
probably be dropped entirely since we only call this function from
online_pages and that function is only called by memory_block_action if
pages_correctly_probed returns true. However pages_correctly_probed
should return false if any of the sections contained in the page range
is already online.

> -		for (i = 0; i < nr_pages; i++) {
> -			page = pfn_to_page(start_pfn + i);
> -			(*online_page_callback)(page);
> -			onlined_pages++;
> -		}
> +		onlined_pages = online_pages_blocks(start_pfn, nr_pages);
>  
>  	online_mem_sections(start_pfn, start_pfn + nr_pages);
>  
