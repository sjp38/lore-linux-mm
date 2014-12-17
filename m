Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id A583D6B0032
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 18:40:20 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id l13so357830iga.2
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 15:40:20 -0800 (PST)
Received: from mail-ie0-x236.google.com (mail-ie0-x236.google.com. [2607:f8b0:4001:c03::236])
        by mx.google.com with ESMTPS id gc1si12375055igd.35.2014.12.17.15.40.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Dec 2014 15:40:19 -0800 (PST)
Received: by mail-ie0-f182.google.com with SMTP id x19so110492ier.13
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 15:40:19 -0800 (PST)
Date: Wed, 17 Dec 2014 15:40:17 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 4/6] mm: fix invalid use of pfn_valid_within in
 test_pages_in_a_zone
In-Reply-To: <548f68bb.wuNDZDL8qk6xEWTm%akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.10.1412171537560.16260@chino.kir.corp.google.com>
References: <548f68bb.wuNDZDL8qk6xEWTm%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, jcuster@sgi.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, rja@sgi.com, stable@vger.kernel.org

On Mon, 15 Dec 2014, akpm@linux-foundation.org wrote:

> diff -puN mm/memory_hotplug.c~mm-fix-invalid-use-of-pfn_valid_within-in-test_pages_in_a_zone mm/memory_hotplug.c
> --- a/mm/memory_hotplug.c~mm-fix-invalid-use-of-pfn_valid_within-in-test_pages_in_a_zone
> +++ a/mm/memory_hotplug.c
> @@ -1331,7 +1331,7 @@ int is_mem_section_removable(unsigned lo
>  }
>  
>  /*
> - * Confirm all pages in a range [start, end) is belongs to the same zone.
> + * Confirm all pages in a range [start, end) belong to the same zone.
>   */
>  int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
>  {
> @@ -1342,10 +1342,11 @@ int test_pages_in_a_zone(unsigned long s
>  	for (pfn = start_pfn;
>  	     pfn < end_pfn;
>  	     pfn += MAX_ORDER_NR_PAGES) {
> -		i = 0;
> -		/* This is just a CONFIG_HOLES_IN_ZONE check.*/
> -		while ((i < MAX_ORDER_NR_PAGES) && !pfn_valid_within(pfn + i))
> -			i++;
> +		/* Find the first valid pfn in this pageblock */
> +		for (i = 0; i < MAX_ORDER_NR_PAGES; i++) {
> +			if (pfn_valid(pfn + i))
> +				break;
> +		}
>  		if (i == MAX_ORDER_NR_PAGES)
>  			continue;
>  		page = pfn_to_page(pfn + i);

I think it would be much better to implement test_pages_in_a_zone() as a 
wrapper around the logic in memory compaction's pageblock_pfn_to_page() 
that does this exact same check for a pageblock.  It would only need to 
iterate the valid pageblocks in the [start_pfn, end_pfn) range and find 
the zone of the first pfn of the first valid pageblock.  This not only 
removes code, but it also unifies the implementation since your 
implementation above would be slower.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
