Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E33706B000A
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 10:51:12 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id g36-v6so5729387edb.3
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 07:51:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l3si4589259edv.432.2018.10.04.07.51.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 07:51:11 -0700 (PDT)
Date: Thu, 4 Oct 2018 16:51:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4] memory_hotplug: Free pages as higher order
Message-ID: <20181004145108.GH22173@dhcp22.suse.cz>
References: <1538573979-28365-1-git-send-email-arunks@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1538573979-28365-1-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com, jgross@suse.com, akpm@linux-foundation.org, dan.j.williams@intel.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, gregkh@linuxfoundation.org, osalvador@suse.de, malat@debian.org, kirill.shutemov@linux.intel.com, jrdr.linux@gmail.com, yasu.isimatu@gmail.com, mgorman@techsingularity.net, aaron.lu@intel.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, vatsa@codeaurora.org, vinmenon@codeaurora.org, getarunks@gmail.com

On Wed 03-10-18 19:09:39, Arun KS wrote:
[...]
> +static int online_pages_blocks(unsigned long start, unsigned long nr_pages)
> +{
> +	unsigned long end = start + nr_pages;
> +	int order, ret, onlined_pages = 0;
> +
> +	while (start < end) {
> +		order = min(MAX_ORDER - 1UL, __ffs(start));
> +
> +		while (start + (1UL << order) > end)
> +			order--;

this really made me scratch my head. Wouldn't it be much simpler to do
the following?
		order = min(MAX_ORDER - 1, get_order(end - start))?

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
[...]
> -static void __init __free_pages_boot_core(struct page *page, unsigned int order)
> +void __free_pages_core(struct page *page, unsigned int order)
>  {
>  	unsigned int nr_pages = 1 << order;
>  	struct page *p = page;
>  	unsigned int loop;
>  
> -	prefetchw(p);
> -	for (loop = 0; loop < (nr_pages - 1); loop++, p++) {
> -		prefetchw(p + 1);
> +	for (loop = 0; loop < nr_pages; loop++, p++) {
>  		__ClearPageReserved(p);
>  		set_page_count(p, 0);
>  	}
> -	__ClearPageReserved(p);
> -	set_page_count(p, 0);
>  
>  	page_zone(page)->managed_pages += nr_pages;
>  	set_page_refcounted(page);

I think this is wort a separate patch as it is unrelated to the patch.

-- 
Michal Hocko
SUSE Labs
