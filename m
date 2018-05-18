Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 91BEA6B027A
	for <linux-mm@kvack.org>; Fri, 18 May 2018 13:42:28 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id d61-v6so6527121otb.21
        for <linux-mm@kvack.org>; Fri, 18 May 2018 10:42:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o5-v6sor4100135oia.96.2018.05.18.10.42.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 May 2018 10:42:27 -0700 (PDT)
Subject: Re: [PATCH] Revert "mm/cma: manage the memory of the CMA area by
 using the ZONE_MOVABLE"
References: <20180517125959.8095-1-ville.syrjala@linux.intel.com>
 <20180517132109.GU12670@dhcp22.suse.cz> <20180517133629.GH23723@intel.com>
 <20180517135832.GI23723@intel.com> <20180517164947.GV12670@dhcp22.suse.cz>
 <20180517170816.GW12670@dhcp22.suse.cz>
 <ccbe3eda-0880-1d59-2204-6bd4b317a4fe@redhat.com>
 <20180518040104.GA17433@js1304-desktop>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <913e9450-da8b-8d4a-d1bd-06f1e0f49340@redhat.com>
Date: Fri, 18 May 2018 10:42:23 -0700
MIME-Version: 1.0
In-Reply-To: <20180518040104.GA17433@js1304-desktop>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Hocko <mhocko@kernel.org>, =?UTF-8?B?VmlsbGUgU3lyasOkbMOk?= <ville.syrjala@linux.intel.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Tony Lindgren <tony@atomide.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/17/2018 09:01 PM, Joonsoo Kim wrote:
> On Thu, May 17, 2018 at 10:53:32AM -0700, Laura Abbott wrote:
>> On 05/17/2018 10:08 AM, Michal Hocko wrote:
>>> On Thu 17-05-18 18:49:47, Michal Hocko wrote:
>>>> On Thu 17-05-18 16:58:32, Ville SyrjA?lA? wrote:
>>>>> On Thu, May 17, 2018 at 04:36:29PM +0300, Ville SyrjA?lA? wrote:
>>>>>> On Thu, May 17, 2018 at 03:21:09PM +0200, Michal Hocko wrote:
>>>>>>> On Thu 17-05-18 15:59:59, Ville Syrjala wrote:
>>>>>>>> From: Ville SyrjA?lA? <ville.syrjala@linux.intel.com>
>>>>>>>>
>>>>>>>> This reverts commit bad8c6c0b1144694ecb0bc5629ede9b8b578b86e.
>>>>>>>>
>>>>>>>> Make x86 with HIGHMEM=y and CMA=y boot again.
>>>>>>>
>>>>>>> Is there any bug report with some more details? It is much more
>>>>>>> preferable to fix the issue rather than to revert the whole thing
>>>>>>> right away.
>>>>>>
>>>>>> The machine I have in front of me right now didn't give me anything.
>>>>>> Black screen, and netconsole was silent. No serial port on this
>>>>>> machine unfortunately.
>>>>>
>>>>> Booted on another machine with serial:
>>>>
>>>> Could you provide your .config please?
>>>>
>>>> [...]
>>>>> [    0.000000] cma: Reserved 4 MiB at 0x0000000037000000
>>>> [...]
>>>>> [    0.000000] BUG: Bad page state in process swapper  pfn:377fe
>>>>> [    0.000000] page:f53effc0 count:0 mapcount:-127 mapping:00000000 index:0x0
>>>>
>>>> OK, so this looks the be the source of the problem. -128 would be a
>>>> buddy page but I do not see anything that would set the counter to -127
>>>> and the real map count updates shouldn't really happen that early.
>>>>
>>>> Maybe CONFIG_DEBUG_VM and CONFIG_DEBUG_HIGHMEM will tell us more.
>>>
>>> Looking closer, I _think_ that the bug is in set_highmem_pages_init->is_highmem
>>> and zone_movable_is_highmem might force CMA pages in the zone movable to
>>> be initialized as highmem. And that sounds supicious to me. Joonsoo?
>>>
>>
>> For a point of reference, arm with this configuration doesn't hit this bug
>> because highmem pages are freed via the memblock interface only instead
>> of iterating through each zone. It looks like the x86 highmem code
>> assumes only a single highmem zone and/or it's disjoint?
> 
> Good point! Reason of the crash is that the span of MOVABLE_ZONE is
> extended to whole node span for future CMA initialization, and,
> normal memory is wrongly freed here.
> 
> Here goes the fix. Ville, Could you test below patch?
> I re-generated the issue on my side and this patch fixed it.
> 

Reviewed-by: Laura Abbott <labbott@redhat.com>

> Thanks.
> 
> ------------>8-------------
>  From 569899a4dbd28cebb8d350d3d1ebb590d88b2629 Mon Sep 17 00:00:00 2001
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Date: Fri, 18 May 2018 10:52:05 +0900
> Subject: [PATCH] x86/32/highmem: check if the zone is matched when free
>   highmem pages on init
> 
> If CONFIG_CMA is enabled, it extends the span of the MOVABLE_ZONE
> to manage the CMA memory later. And, in this case, the span of the
> MOVABLE_ZONE could overlap the other zone's memory. We need to
> avoid freeing this overlapped memory here since it would be the
> memory of the other zone. Therefore, this patch adds a check
> whether the page is indeed on the requested zone or not. Skipped
> page will be freed when the memory of the matched zone is freed.
> 
> Reported-by: Ville SyrjA?lA? <ville.syrjala@linux.intel.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>   arch/x86/include/asm/highmem.h |  4 ++--
>   arch/x86/mm/highmem_32.c       |  5 ++++-
>   arch/x86/mm/init_32.c          | 25 +++++++++++++++++++++----
>   3 files changed, 27 insertions(+), 7 deletions(-)
> 
> diff --git a/arch/x86/include/asm/highmem.h b/arch/x86/include/asm/highmem.h
> index a805993..e383f57 100644
> --- a/arch/x86/include/asm/highmem.h
> +++ b/arch/x86/include/asm/highmem.h
> @@ -72,8 +72,8 @@ void *kmap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot);
>   
>   #define flush_cache_kmaps()	do { } while (0)
>   
> -extern void add_highpages_with_active_regions(int nid, unsigned long start_pfn,
> -					unsigned long end_pfn);
> +extern void add_highpages_with_active_regions(int nid, struct zone *zone,
> +				unsigned long start_pfn, unsigned long end_pfn);
>   
>   #endif /* __KERNEL__ */
>   
> diff --git a/arch/x86/mm/highmem_32.c b/arch/x86/mm/highmem_32.c
> index 6d18b70..bf9f5b8 100644
> --- a/arch/x86/mm/highmem_32.c
> +++ b/arch/x86/mm/highmem_32.c
> @@ -120,6 +120,9 @@ void __init set_highmem_pages_init(void)
>   		if (!is_highmem(zone))
>   			continue;
>   
> +		if (!populated_zone(zone))
> +			continue;
> +
>   		zone_start_pfn = zone->zone_start_pfn;
>   		zone_end_pfn = zone_start_pfn + zone->spanned_pages;
>   
> @@ -127,7 +130,7 @@ void __init set_highmem_pages_init(void)
>   		printk(KERN_INFO "Initializing %s for node %d (%08lx:%08lx)\n",
>   				zone->name, nid, zone_start_pfn, zone_end_pfn);
>   
> -		add_highpages_with_active_regions(nid, zone_start_pfn,
> +		add_highpages_with_active_regions(nid, zone, zone_start_pfn,
>   				 zone_end_pfn);
>   	}
>   }
> diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
> index 8008db2..f646072 100644
> --- a/arch/x86/mm/init_32.c
> +++ b/arch/x86/mm/init_32.c
> @@ -431,7 +431,7 @@ static void __init permanent_kmaps_init(pgd_t *pgd_base)
>   	pkmap_page_table = pte;
>   }
>   
> -void __init add_highpages_with_active_regions(int nid,
> +void __init add_highpages_with_active_regions(int nid, struct zone *zone,
>   			 unsigned long start_pfn, unsigned long end_pfn)
>   {
>   	phys_addr_t start, end;
> @@ -442,9 +442,26 @@ void __init add_highpages_with_active_regions(int nid,
>   					    start_pfn, end_pfn);
>   		unsigned long e_pfn = clamp_t(unsigned long, PFN_DOWN(end),
>   					      start_pfn, end_pfn);
> -		for ( ; pfn < e_pfn; pfn++)
> -			if (pfn_valid(pfn))
> -				free_highmem_page(pfn_to_page(pfn));
> +		for ( ; pfn < e_pfn; pfn++) {
> +			struct page *page;
> +
> +			if (!pfn_valid(pfn))
> +				continue;
> +
> +			page = pfn_to_page(pfn);
> +
> +			/*
> +			 * If CONFIG_CMA is enabled, it extends the span of
> +			 * the MOVABLE_ZONE to manage the CMA memory
> +			 * in the future. And, in this case, the span of the
> +			 * MOVABLE_ZONE could overlap the other zone's memory.
> +			 * We need to avoid freeing this memory here.
> +			 */
> +			if (IS_ENABLED(CONFIG_CMA) && page_zone(page) != zone)
> +				continue;
> +
> +			free_highmem_page(pfn_to_page(pfn));
> +		}
>   	}
>   }
>   #else
> 
