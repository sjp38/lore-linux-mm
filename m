Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 716122806D8
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 08:34:59 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id o21so2302012wrb.9
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 05:34:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s25si3396032wrb.187.2017.04.19.05.34.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Apr 2017 05:34:58 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm: consider zone which is not fully populated to
 have holes
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170415121734.6692-1-mhocko@kernel.org>
 <20170415121734.6692-2-mhocko@kernel.org>
 <97a658cd-e656-6efa-7725-150063d276f1@suse.cz>
 <20170418092757.GM22360@dhcp22.suse.cz>
 <12814e7e-5ed7-de1f-3e7c-9501eec1682a@suse.cz>
 <20170419121637.GG29789@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b9859e0e-79ee-6e79-0d25-a6e31895ee7f@suse.cz>
Date: Wed, 19 Apr 2017 14:34:54 +0200
MIME-Version: 1.0
In-Reply-To: <20170419121637.GG29789@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <js1304@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On 04/19/2017 02:16 PM, Michal Hocko wrote:
> On Wed 19-04-17 13:59:40, Vlastimil Babka wrote:
>> On 04/18/2017 11:27 AM, Michal Hocko wrote:
> [...]
>>> I am not aware of any such user. PageReserved has always been about "the
>>> core mm should touch these pages and modify their state" AFAIR.
>>> But I believe that touching those holes just asks for problems so I
>>> would rather have them covered.
>>
>> OK. I guess it's OK to use PageReserved of first pageblock page to
>> determine if we can trust page_zone(), because the memory offline
>> scenario should have sufficient granularity and not make holes inside
>> pageblock?
> 
> Yes memblocks should be section size aligned and that is 128M resp. 2GB
> on large machines. So we are talking about much larger than page block
> granularity here.
> 
> Anyway, Joonsoo didn't like the the explicit PageReserved checks so I
> have come with pfn_to_online_page which hides this implementation
> detail. How do you like the following instead?

Yeah that's OK. The other two patches will be updated as well?
Ideally we would later convert this helper to use some special values
for zone/node id (such as -1) instead of PageReserved to indicate an
offline node, as we discussed.

> ---
> From 0f5544b5d01f4bc1572e43cc2a0156ae33a2922c Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Thu, 13 Apr 2017 10:28:45 +0200
> Subject: [PATCH] mm: consider zone which is not fully populated to have holes
> 
> __pageblock_pfn_to_page has two users currently, set_zone_contiguous
> which checks whether the given zone contains holes and
> pageblock_pfn_to_page which then carefully returns a first valid
> page from the given pfn range for the given zone. This doesn't handle
> zones which are not fully populated though. Memory pageblocks can be
> offlined or might not have been onlined yet. In such a case the zone
> should be considered to have holes otherwise pfn walkers can touch
> and play with offline pages.
> 
> Current callers of pageblock_pfn_to_page in compaction seem to work
> properly right now because they only isolate PageBuddy
> (isolate_freepages_block) or PageLRU resp. __PageMovable
> (isolate_migratepages_block) which will be always false for these pages.
> It would be safer to skip these pages altogether, though. In order
> to do that let's add pfn_to_online_page helper which checks PageReserved
> because offline pages are reserved until they are onlined. There might
> be other users of the PageReserved flag but they are rare and even if we
> hit into those pages we should skip them in pfn walkers anyway. So this
> is not harmful.
> 
> Use the new helper in __pageblock_pfn_to_page and skip the whole page
> block in such a case. Vlastimil has noted that we might skip over
> the page block even when there is a single reserved page but that
> shouldn't lead to major issues because reserved pages are used very
> seldom.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/memory_hotplug.h | 28 ++++++++++++++++++++++++++++
>  mm/page_alloc.c                |  4 +++-
>  2 files changed, 31 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 3c8cf86201c3..736fe73e65af 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -14,6 +14,26 @@ struct memory_block;
>  struct resource;
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG
> +/*
> + * Return page for the valid pfn only if the page is online.
> + * Offline pages are marked reserved. There are other users of PageReserved
> + * but pfn walkers should avoid them in general so such a false positive
> + * is not harmful.
> + *
> + * It would be great if this was a static inline but dependency hell doesn't
> + * allow that for now.
> + */
> +#define pfn_to_online_page(pfn)				\
> +({							\
> +	struct page *___page = NULL;			\
> +							\
> +	if (pfn_valid(pfn)) {				\
> +		___page = pfn_to_page(pfn);		\
> +		if (unlikely(PageReserved(___page))) 	\
> +			___page = NULL;			\
> +	}						\
> +	___page;					\
> +})
>  
>  /*
>   * Types for free bootmem stored in page->lru.next. These have to be in
> @@ -203,6 +223,14 @@ extern void set_zone_contiguous(struct zone *zone);
>  extern void clear_zone_contiguous(struct zone *zone);
>  
>  #else /* ! CONFIG_MEMORY_HOTPLUG */
> +#define pfn_to_online_page(pfn)			\
> +({						\
> +	struct page *___page = NULL;		\
> +	if (pfn_valid(pfn))			\
> +		___page = pfn_to_page(pfn);	\
> +	___page;				\
> + })
> +
>  /*
>   * Stub functions for when hotplug is off
>   */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5d72d29a6ece..9dd814f4e7f5 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1353,7 +1353,9 @@ struct page *__pageblock_pfn_to_page(unsigned long start_pfn,
>  	if (!pfn_valid(start_pfn) || !pfn_valid(end_pfn))
>  		return NULL;
>  
> -	start_page = pfn_to_page(start_pfn);
> +	start_page = pfn_to_online_page(start_pfn);
> +	if (!start_page)
> +		return NULL;
>  
>  	if (page_zone(start_page) != zone)
>  		return NULL;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
