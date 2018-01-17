Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 11062280298
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 05:02:27 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id v10so5405944wrv.22
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 02:02:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v6si843781wrg.302.2018.01.17.02.02.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Jan 2018 02:02:25 -0800 (PST)
Subject: Re: [PATCH v2] mm/page_owner: Clean up init_pages_in_zone()
References: <20180110084355.GA22822@techadventures.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8395025d-90fd-7341-09b7-115ff131f6ac@suse.cz>
Date: Wed, 17 Jan 2018 11:02:24 +0100
MIME-Version: 1.0
In-Reply-To: <20180110084355.GA22822@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>, linux-mm@kvack.org
Cc: mhocko@suse.com, akpm@linux-foundation.org

On 01/10/2018 09:43 AM, Oscar Salvador wrote:
> This patch removes two redundant assignments in init_pages_in_zone function.
> 
> Signed-off-by: Oscar Salvador <osalvador@techadventures.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

A nitpick below.

> ---
>  mm/page_owner.c | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index 69f83fc763bb..b361781e5ab6 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -528,14 +528,11 @@ read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
>  
>  static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
>  {
> -	struct page *page;
> -	struct page_ext *page_ext;
>  	unsigned long pfn = zone->zone_start_pfn, block_end_pfn;

block_end_pfn declaration could be moved to the outer for loop

>  	unsigned long end_pfn = pfn + zone->spanned_pages;

While here, I would use zone_end_pfn() on the line above.

>  	unsigned long count = 0;
>  
>  	/* Scan block by block. First and last block may be incomplete */

Now the comment is stray, I would just remove it too.

> -	pfn = zone->zone_start_pfn;
>  
>  	/*
>  	 * Walk the zone in pageblock_nr_pages steps. If a page block spans
> @@ -551,9 +548,9 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
>  		block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
>  		block_end_pfn = min(block_end_pfn, end_pfn);
>  
> -		page = pfn_to_page(pfn);
> -
>  		for (; pfn < block_end_pfn; pfn++) {
> +			struct page *page;
> +			struct page_ext *page_ext;
>  			if (!pfn_valid_within(pfn))
>  				continue;
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
