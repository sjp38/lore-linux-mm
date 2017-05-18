Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6A05F831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 12:15:16 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c202so9949996wme.10
        for <linux-mm@kvack.org>; Thu, 18 May 2017 09:15:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q55si5561584edd.130.2017.05.18.09.15.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 May 2017 09:15:14 -0700 (PDT)
Subject: Re: [PATCH 07/14] mm: consider zone which is not fully populated to
 have holes
References: <20170515085827.16474-1-mhocko@kernel.org>
 <20170515085827.16474-8-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ae859e14-bf82-ae37-9c85-d4b31ce89b0a@suse.cz>
Date: Thu, 18 May 2017 18:14:39 +0200
MIME-Version: 1.0
In-Reply-To: <20170515085827.16474-8-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 05/15/2017 10:58 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
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
> It would be safer to skip these pages altogether, though.
> 
> In order to do this patch adds a new memory section state
> (SECTION_IS_ONLINE) which is set in memory_present (during boot
> time) or in online_pages_range during the memory hotplug. Similarly
> offline_mem_sections clears the bit and it is called when the memory
> range is offlined.
> 
> pfn_to_online_page helper is then added which check the mem section and
> only returns a page if it is onlined already.
> 
> Use the new helper in __pageblock_pfn_to_page and skip the whole page
> block in such a case.
> 
> Changes since v3
> - clarify pfn_valid semantic - requested by Joonsoo
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/memory_hotplug.h | 21 ++++++++++++++++++++
>  include/linux/mmzone.h         | 35 ++++++++++++++++++++++++++------
>  mm/memory_hotplug.c            |  3 +++
>  mm/page_alloc.c                |  5 ++++-
>  mm/sparse.c                    | 45 +++++++++++++++++++++++++++++++++++++++++-
>  5 files changed, 101 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 3c8cf86201c3..fc1c873504eb 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -14,6 +14,19 @@ struct memory_block;
>  struct resource;
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG
> +/*
> + * Return page for the valid pfn only if the page is online. All pfn
> + * walkers which rely on the fully initialized page->flags and others
> + * should use this rather than pfn_valid && pfn_to_page
> + */
> +#define pfn_to_online_page(pfn)				\
> +({							\
> +	struct page *___page = NULL;			\
> +							\
> +	if (online_section_nr(pfn_to_section_nr(pfn)))	\
> +		___page = pfn_to_page(pfn);		\
> +	___page;					\
> +})

This seems to be already assuming pfn_valid() to be true. There's no
"pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS" check and the comment
suggests as such, but...

>  /*
>   * Types for free bootmem stored in page->lru.next. These have to be in
> @@ -203,6 +216,14 @@ extern void set_zone_contiguous(struct zone *zone);
>  extern void clear_zone_contiguous(struct zone *zone);
>  
>  #else /* ! CONFIG_MEMORY_HOTPLUG */
> +#define pfn_to_online_page(pfn)			\
> +({						\
> +	struct page *___page = NULL;		\
> +	if (pfn_valid(pfn))			\
> +		___page = pfn_to_page(pfn);	\

This includes the pfn_valid() check itself. Why the discrepancy?
Somebody might develop code with !HOTPLUG and forget the check, and then
it starts breaking with HOTPLUG?

> +	___page;				\
> + })
> +
>  /*
>   * Stub functions for when hotplug is off
>   */

...

> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 05796ee974f7..c3a146028ba6 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -929,6 +929,9 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
>  	unsigned long i;
>  	unsigned long onlined_pages = *(unsigned long *)arg;
>  	struct page *page;
> +
> +	online_mem_sections(start_pfn, start_pfn + nr_pages);

Shouldn't this be moved *below* the loop that initializes struct pages?
In the offline case you do mark sections offline before "tearing" struct
pages, so that should be symmetric.

> +
>  	if (PageReserved(pfn_to_page(start_pfn)))
>  		for (i = 0; i < nr_pages; i++) {
>  			page = pfn_to_page(start_pfn + i);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c1670f090107..7e5151a7dd7b 100644
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
> @@ -7671,6 +7673,7 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
>  			break;
>  	if (pfn == end_pfn)
>  		return;
> +	offline_mem_sections(pfn, end_pfn);
>  	zone = page_zone(pfn_to_page(pfn));
>  	spin_lock_irqsave(&zone->lock, flags);
>  	pfn = start_pfn;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
