Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 77A836B0271
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 04:45:15 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id 98so19923603qkp.22
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 01:45:15 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y24si2296792qve.86.2018.11.05.01.45.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 01:45:14 -0800 (PST)
Date: Mon, 5 Nov 2018 17:45:08 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH] mm, memory_hotplug: teach has_unmovable_pages about of
 LRU migrateable pages
Message-ID: <20181105094508.GA22011@MiWiFi-R3L-srv>
References: <20181101091055.GA15166@MiWiFi-R3L-srv>
 <20181102155528.20358-1-mhocko@kernel.org>
 <20181105002009.GF27491@MiWiFi-R3L-srv>
 <20181105091407.GB4361@dhcp22.suse.cz>
 <20181105092851.GD4361@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181105092851.GD4361@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On 11/05/18 at 10:28am, Michal Hocko wrote:
> On Mon 05-11-18 10:14:07, Michal Hocko wrote:
> > Maybe we can add a retry for movable zone pages.
> 
> Or something like this. Ugly as hell, no question about that. I also
> have to think about this some more to convince myself this will not
> result in an endless loop under some situations.

Testing, will tell the result.

> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 48ceda313332..342d66eca0f3 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7779,12 +7779,16 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  	pfn = page_to_pfn(page);
>  	for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++) {
>  		unsigned long check = pfn + iter;
> +		unsigned long saved_flags;
>  
>  		if (!pfn_valid_within(check))
>  			continue;
>  
>  		page = pfn_to_page(check);
>  
> +retry:
> +		saved_flags = READ_ONCE(page->flags);
> +
>  		if (PageReserved(page))
>  			goto unmovable;
>  
> @@ -7840,6 +7844,13 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  				page->mapping->a_ops->migratepage)
>  			continue;
>  
> +		/*
> +		 * We might race with the allocation of the page so retry
> +		 * if flags have changed.
> +		 */
> +		if (saved_flags != READ_ONCE(page->flags))
> +			goto retry;
> +
>  		/*
>  		 * If there are RECLAIMABLE pages, we need to check
>  		 * it.  But now, memory offline itself doesn't call
> -- 
> Michal Hocko
> SUSE Labs
