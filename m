Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0BF036B03CA
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 07:56:38 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id f13so5396628wrf.3
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 04:56:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y74si25956611wmd.130.2017.04.20.04.56.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Apr 2017 04:56:36 -0700 (PDT)
Subject: Re: your mail
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170415121734.6692-1-mhocko@kernel.org>
 <20170417054718.GD1351@js1304-desktop>
 <20170417081513.GA12511@dhcp22.suse.cz>
 <20170420012753.GA22054@js1304-desktop>
 <20170420072820.GB15781@dhcp22.suse.cz>
 <20170420084930.GC15781@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b9ff52f3-836e-db1e-2a2b-b60d71c53f69@suse.cz>
Date: Thu, 20 Apr 2017 13:56:34 +0200
MIME-Version: 1.0
In-Reply-To: <20170420084930.GC15781@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <js1304@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On 04/20/2017 10:49 AM, Michal Hocko wrote:
> On Thu 20-04-17 09:28:20, Michal Hocko wrote:
>> On Thu 20-04-17 10:27:55, Joonsoo Kim wrote:
> [...]
>>> Your patch try to add PageReserved() to __pageblock_pfn_to_page(). It
>>> woule make that zone->contiguous usually returns false since memory
>>> used by memblock API is marked as PageReserved() and your patch regard
>>> it as a hole. It invalidates set_zone_contiguous() optimization and I
>>> worry about it.
>>
>> OK, fair enough. I did't consider memblock allocations. I will rethink
>> this patch but there are essentially 3 options
>> 	- use a different criterion for the offline holes dection. I
>> 	  have just realized we might do it by storing the online
>> 	  information into the mem sections
>> 	- drop this patch
>> 	- move the PageReferenced check down the chain into
>> 	  isolate_freepages_block resp. isolate_migratepages_block
>>
>> I would prefer 3 over 2 over 1. I definitely want to make this more
>> robust so 1 is preferable long term but I do not want this to be a
>> roadblock to the rest of the rework. Does that sound acceptable to you?
> 
> So I've played with all three options just to see how the outcome would
> look like and it turned out that going with 1 will be easiest in the
> end. What do you think about the following? It should be free of any 
> false positives. I have only compile tested it yet.

That looks fine, can't say immediately if fully correct. I think you'll
need to bump SECTION_NID_SHIFT as well and make sure things still fit?
Otherwise looks like nobody needed a new section bit since 2005, so we
should be fine.

> ---
> From 747794c13c0e82b55b793a31cdbe1a84ee1c6920 Mon Sep 17 00:00:00 2001
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
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/memory_hotplug.h | 21 ++++++++++++++++++++
>  include/linux/mmzone.h         | 20 ++++++++++++++++++-
>  mm/memory_hotplug.c            |  3 +++
>  mm/page_alloc.c                |  5 ++++-
>  mm/sparse.c                    | 45 +++++++++++++++++++++++++++++++++++++++++-
>  5 files changed, 91 insertions(+), 3 deletions(-)
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
>  
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
> +	___page;				\
> + })
> +
>  /*
>   * Stub functions for when hotplug is off
>   */
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 0fc121bbf4ff..cad16ac080f5 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1143,7 +1143,8 @@ extern unsigned long usemap_size(void);
>   */
>  #define	SECTION_MARKED_PRESENT	(1UL<<0)
>  #define SECTION_HAS_MEM_MAP	(1UL<<1)
> -#define SECTION_MAP_LAST_BIT	(1UL<<2)
> +#define SECTION_IS_ONLINE	(1UL<<2)
> +#define SECTION_MAP_LAST_BIT	(1UL<<3)
>  #define SECTION_MAP_MASK	(~(SECTION_MAP_LAST_BIT-1))
>  #define SECTION_NID_SHIFT	2
>  
> @@ -1174,6 +1175,23 @@ static inline int valid_section_nr(unsigned long nr)
>  	return valid_section(__nr_to_section(nr));
>  }
>  
> +static inline int online_section(struct mem_section *section)
> +{
> +	return (section && (section->section_mem_map & SECTION_IS_ONLINE));
> +}
> +
> +static inline int online_section_nr(unsigned long nr)
> +{
> +	return online_section(__nr_to_section(nr));
> +}
> +
> +#ifdef CONFIG_MEMORY_HOTPLUG
> +void online_mem_sections(unsigned long start_pfn, unsigned long end_pfn);
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn);
> +#endif
> +#endif
> +
>  static inline struct mem_section *__pfn_to_section(unsigned long pfn)
>  {
>  	return __nr_to_section(pfn_to_section_nr(pfn));
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index caa58338d121..98f565c279bf 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -929,6 +929,9 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
>  	unsigned long i;
>  	unsigned long onlined_pages = *(unsigned long *)arg;
>  	struct page *page;
> +
> +	online_mem_sections(start_pfn, start_pfn + nr_pages);
> +
>  	if (PageReserved(pfn_to_page(start_pfn)))
>  		for (i = 0; i < nr_pages; i++) {
>  			page = pfn_to_page(start_pfn + i);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5d72d29a6ece..fa752de84eef 100644
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
> @@ -7686,6 +7688,7 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
>  			break;
>  	if (pfn == end_pfn)
>  		return;
> +	offline_mem_sections(pfn, end_pfn);
>  	zone = page_zone(pfn_to_page(pfn));
>  	spin_lock_irqsave(&zone->lock, flags);
>  	pfn = start_pfn;
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 6903c8fc3085..79017f90d8fc 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -185,7 +185,8 @@ void __init memory_present(int nid, unsigned long start, unsigned long end)
>  		ms = __nr_to_section(section);
>  		if (!ms->section_mem_map)
>  			ms->section_mem_map = sparse_encode_early_nid(nid) |
> -							SECTION_MARKED_PRESENT;
> +							SECTION_MARKED_PRESENT |
> +							SECTION_IS_ONLINE;
>  	}
>  }
>  
> @@ -590,6 +591,48 @@ void __init sparse_init(void)
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG
> +
> +/* Mark all memory sections within the pfn range as online */
> +void online_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
> +{
> +	unsigned long pfn;
> +
> +	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
> +		unsigned long section_nr = pfn_to_section_nr(start_pfn);
> +		struct mem_section *ms;
> +
> +		/* onlining code should never touch invalid ranges */
> +		if (WARN_ON(!valid_section_nr(section_nr)))
> +			continue;
> +
> +		ms = __nr_to_section(section_nr);
> +		ms->section_mem_map |= SECTION_IS_ONLINE;
> +	}
> +}
> +
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +/* Mark all memory sections within the pfn range as online */
> +void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
> +{
> +	unsigned long pfn;
> +
> +	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
> +		unsigned long section_nr = pfn_to_section_nr(start_pfn);
> +		struct mem_section *ms;
> +
> +		/*
> +		 * TODO this needs some double checking. Offlining code makes
> +		 * sure to check pfn_valid but those checks might be just bogus
> +		 */
> +		if (WARN_ON(!valid_section_nr(section_nr)))
> +			continue;
> +
> +		ms = __nr_to_section(section_nr);
> +		ms->section_mem_map &= ~SECTION_IS_ONLINE;
> +	}
> +}
> +#endif
> +
>  #ifdef CONFIG_SPARSEMEM_VMEMMAP
>  static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid)
>  {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
