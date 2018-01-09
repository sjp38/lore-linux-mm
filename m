Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7097E6B0253
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 12:18:23 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id i6so9222201wre.6
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 09:18:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b14si9791606wma.161.2018.01.09.09.18.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Jan 2018 09:18:21 -0800 (PST)
Date: Tue, 9 Jan 2018 18:18:20 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/page_owner.c Clean up init_pages_in_zone()
Message-ID: <20180109171820.GN1732@dhcp22.suse.cz>
References: <20180109133303.GA11451@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180109133303.GA11451@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: linux-mm@kvack.org, vbabka@suse.cz, akpm@linux-foundation.org

On Tue 09-01-18 14:33:03, Oscar Salvador wrote:
[...]
> @@ -551,13 +548,11 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
>  		block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
>  		block_end_pfn = min(block_end_pfn, end_pfn);
>  
> -		page = pfn_to_page(pfn);
> -
>  		for (; pfn < block_end_pfn; pfn++) {
>  			if (!pfn_valid_within(pfn))
>  				continue;
>  
> -			page = pfn_to_page(pfn);
> +			struct page *page = pfn_to_page(pfn);
>  
>  			if (page_zone(page) != zone)
>  				continue;
> @@ -580,7 +575,7 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
>  			if (PageReserved(page))
>  				continue;
>  
> -			page_ext = lookup_page_ext(page);
> +			struct page_ext *page_ext = lookup_page_ext(page);
>  			if (unlikely(!page_ext))
>  				continue;

we do not interleave declarations with the code in the kernel. You can
move those from the function scope to the loop scope and remove the
pointless pfn and page initialization outside of the loop.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
