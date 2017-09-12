Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C101E6B033E
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 08:49:55 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v109so11831030wrc.5
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 05:49:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 2si1291640wmn.251.2017.09.12.05.49.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Sep 2017 05:49:54 -0700 (PDT)
Date: Tue, 12 Sep 2017 14:49:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/memory_hotplug: fix wrong casting for
 __remove_section()
Message-ID: <20170912124952.uraxdt5bgl25zhf7@dhcp22.suse.cz>
References: <51a59ec3-e7ba-2562-1917-036b8181092c@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51a59ec3-e7ba-2562-1917-036b8181092c@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, qiuxishi@huawei.com, arbab@linux.vnet.ibm.com, Vlastimil Babka <vbabka@suse.cz>

On Fri 08-09-17 16:43:04, YASUAKI ISHIMATSU wrote:
> __remove_section() calls __remove_zone() to shrink zone and pgdat.
> But due to wrong castings, __remvoe_zone() cannot shrink zone
> and pgdat correctly if pfn is over 0xffffffff.
> 
> So the patch fixes the following 3 wrong castings.
> 
>   1. find_smallest_section_pfn() returns 0 or start_pfn which defined
>      as unsigned long. But the function always returns 32bit value
>      since the function is defined as int.
> 
>   2. find_biggest_section_pfn() returns 0 or pfn which defined as
>      unsigned long. the function always returns 32bit value
>      since the function is defined as int.

this is indeed wrong. Pfns over would be really broken 15TB. Not that
unrealistic these days

> 
>   3. __remove_section() calculates start_pfn using section_nr_to_pfn()
>      and scn_nr. section_nr_to_pfn() just shifts scn_nr by
>      PFN_SECTION_SHIFT bit. But since scn_nr is defined as int,
>      section_nr_to_pfn() always return 32 bit value.

Dohh, those nasty macros. This is hidden quite well. It seems other
callers are using unsigned long properly. But I would rather make sure
we won't repeat that error again. Can we instead make section_nr_to_pfn
resp. pfn_to_section_nr static inline and enfore proper types?

I would also split this into two patches. 

Thanks!

> The patch fixes the wrong castings.
> 
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> ---
>  mm/memory_hotplug.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 73bf17d..3514ef2 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -331,7 +331,7 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
> 
>  #ifdef CONFIG_MEMORY_HOTREMOVE
>  /* find the smallest valid pfn in the range [start_pfn, end_pfn) */
> -static int find_smallest_section_pfn(int nid, struct zone *zone,
> +static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
>  				     unsigned long start_pfn,
>  				     unsigned long end_pfn)
>  {
> @@ -356,7 +356,7 @@ static int find_smallest_section_pfn(int nid, struct zone *zone,
>  }
> 
>  /* find the biggest valid pfn in the range [start_pfn, end_pfn). */
> -static int find_biggest_section_pfn(int nid, struct zone *zone,
> +static unsigned long find_biggest_section_pfn(int nid, struct zone *zone,
>  				    unsigned long start_pfn,
>  				    unsigned long end_pfn)
>  {
> @@ -544,7 +544,7 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
>  		return ret;
> 
>  	scn_nr = __section_nr(ms);
> -	start_pfn = section_nr_to_pfn(scn_nr);
> +	start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
>  	__remove_zone(zone, start_pfn);
> 
>  	sparse_remove_one_section(zone, ms, map_offset);
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
