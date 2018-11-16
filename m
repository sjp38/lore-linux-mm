Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id D5D376B0BD1
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 17:41:29 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id y2so10658630plr.8
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 14:41:29 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id q9si5924967pgh.92.2018.11.16.14.41.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 14:41:27 -0800 (PST)
Subject: Re: [RFC PATCH 3/4] mm, memory_hotplug: allocate memmap from the
 added memory range for sparse-vmemmap
References: <20181116101222.16581-1-osalvador@suse.com>
 <20181116101222.16581-4-osalvador@suse.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <87e29d18-c1f7-05b6-edda-1848fb2a1a03@intel.com>
Date: Fri, 16 Nov 2018 14:41:26 -0800
MIME-Version: 1.0
In-Reply-To: <20181116101222.16581-4-osalvador@suse.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.com>, linux-mm@kvack.org
Cc: mhocko@suse.com, david@redhat.com, rppt@linux.vnet.ibm.com, akpm@linux-foundation.org, arunks@codeaurora.org, bhe@redhat.com, dan.j.williams@intel.com, Pavel.Tatashin@microsoft.com, Jonathan.Cameron@huawei.com, jglisse@redhat.com, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On 11/16/18 2:12 AM, Oscar Salvador wrote:
> Physical memory hotadd has to allocate a memmap (struct page array) for
> the newly added memory section. Currently, kmalloc is used for those
> allocations.

Did you literally mean kmalloc?  I thought we had a bunch of ways of
allocating memmaps, but I didn't think kmalloc() was actually used.

Like vmemmap_alloc_block(), for instance, uses alloc_pages_node().

So, can the ZONE_DEVICE altmaps move over to this infrastructure?
Doesn't this effectively duplicate that code?

...
> diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
> index 7a9886f98b0c..03f014abd4eb 100644
> --- a/arch/powerpc/mm/init_64.c
> +++ b/arch/powerpc/mm/init_64.c
> @@ -278,6 +278,8 @@ void __ref vmemmap_free(unsigned long start, unsigned long end,
>  			continue;
>  
>  		page = pfn_to_page(addr >> PAGE_SHIFT);
> +		if (PageVmemmap(page))
> +			continue;
>  		section_base = pfn_to_page(vmemmap_section_start(start));
>  		nr_pages = 1 << page_order;

Reading this, I'm wondering if PageVmemmap() could be named better.
>From this is reads like "skip PageVmemmap() pages if freeing vmemmap",
which does not make much sense.

This probably at _least_ needs a comment to explain why the pages are
being skipped.

> diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
> index 4139affd6157..bc1523bcb09d 100644
> --- a/arch/s390/mm/init.c
> +++ b/arch/s390/mm/init.c
> @@ -231,6 +231,12 @@ int arch_add_memory(int nid, u64 start, u64 size,
>  	unsigned long size_pages = PFN_DOWN(size);
>  	int rc;
>  
> +	/*
> +	 * Physical memory is added only later during the memory online so we
> +	 * cannot use the added range at this stage unfortunatelly.

					unfortunately ^

> +	 */
> +	restrictions->flags &= ~MHP_MEMMAP_FROM_RANGE;

Could you also add to the  comment about this being specific to s390?

>  	rc = vmem_add_mapping(start, size);
>  	if (rc)
>  		return rc;
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index fd06bcbd9535..d5234ca5c483 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -815,6 +815,13 @@ static void __meminit free_pagetable(struct page *page, int order)
>  	unsigned long magic;
>  	unsigned int nr_pages = 1 << order;
>  
> +	/*
> +	 * runtime vmemmap pages are residing inside the memory section so
> +	 * they do not have to be freed anywhere.
> +	 */
> +	if (PageVmemmap(page))
> +		return;

Thanks for the comment on this one, this one is right on.

> @@ -16,13 +18,18 @@ struct device;
>   * @free: free pages set aside in the mapping for memmap storage
>   * @align: pages reserved to meet allocation alignments
>   * @alloc: track pages consumed, private to vmemmap_populate()
> + * @flush_alloc_pfns: callback to be called on the allocated range after it
> + * @nr_sects: nr of sects filled with memmap allocations
> + * is mapped to the vmemmap - see mark_vmemmap_pages
>   */

I think you split up the "@flush_alloc_pfns" comment accidentally.

>  struct vmem_altmap {
> -	const unsigned long base_pfn;
> +	unsigned long base_pfn;
>  	const unsigned long reserve;
>  	unsigned long free;
>  	unsigned long align;
>  	unsigned long alloc;
> +	int nr_sects;
> +	void (*flush_alloc_pfns)(struct vmem_altmap *self);
>  };
>  
>  /*
> @@ -133,8 +140,62 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap);
>  struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
>  		struct dev_pagemap *pgmap);
>  
> -unsigned long vmem_altmap_offset(struct vmem_altmap *altmap);
> +static inline unsigned long vmem_altmap_offset(struct vmem_altmap *altmap)
> +{
> +	/* number of pfns from base where pfn_to_page() is valid */
> +	return altmap->reserve + altmap->free;
> +}
>  void vmem_altmap_free(struct vmem_altmap *altmap, unsigned long nr_pfns);
> +
> +static inline void mark_vmemmap_pages(struct vmem_altmap *self)
> +{
> +	unsigned long pfn = self->base_pfn + self->reserve;
> +	unsigned long nr_pages = self->alloc;
> +	unsigned long align = PAGES_PER_SECTION * sizeof(struct page);
> +	struct page *head;
> +	unsigned long i;
> +
> +	pr_debug("%s: marking %px - %px as Vmemmap\n", __func__,
> +						pfn_to_page(pfn),
> +						pfn_to_page(pfn + nr_pages - 1));
> +	/*
> +	 * We keep track of the sections using this altmap by means
> +	 * of a refcount, so we know how much do we have to defer
> +	 * the call to vmemmap_free for this memory range.
> +	 * The refcount is kept in the first vmemmap page.
> +	 * For example:
> +	 * We add 10GB: (ffffea0004000000 - ffffea000427ffc0)
> +	 * ffffea0004000000 will have a refcount of 80.
> +	 */

The example is good, but it took me a minute to realize that 80 is
because 10GB is roughly 80 sections.

> +	head = (struct page *)ALIGN_DOWN((unsigned long)pfn_to_page(pfn), align);

Is this ALIGN_DOWN() OK?  It seems like it might be aligning 'pfn' down
into the reserved are that lies before it.

> +	head = (struct page *)((unsigned long)head - (align * self->nr_sects));
> +	page_ref_inc(head);
> +
> +	/*
> +	 * We have used a/another section only with memmap allocations.
> +	 * We need to keep track of it in order to get the first head page
> +	 * to increase its refcount.
> +	 * This makes it easier to compute.
> +	 */
> +	if (!((page_ref_count(head) * PAGES_PER_SECTION) % align))
> +		self->nr_sects++;
> +
> +	/*
> +	 * All allocations for the memory hotplug are the same sized so align
> +	 * should be 0
> +	 */
> +	WARN_ON(self->align);
> +        for (i = 0; i < nr_pages; i++, pfn++) {
> +                struct page *page = pfn_to_page(pfn);
> +                __SetPageVmemmap(page);
> +		init_page_count(page);
> +        }

Looks like some tabs vs. space problems.

> +	self->alloc = 0;
> +	self->base_pfn += nr_pages + self->reserve;
> +	self->free -= nr_pages;
> +}
>  #else
>  static inline void *devm_memremap_pages(struct device *dev,
>  		struct dev_pagemap *pgmap)
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 50ce1bddaf56..e79054fcc96e 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -437,6 +437,24 @@ static __always_inline int __PageMovable(struct page *page)
>  				PAGE_MAPPING_MOVABLE;
>  }
>  
> +#define VMEMMAP_PAGE ~PAGE_MAPPING_FLAGS
> +static __always_inline int PageVmemmap(struct page *page)
> +{
> +	return PageReserved(page) && (unsigned long)page->mapping == VMEMMAP_PAGE;
> +}
> +
> +static __always_inline void __ClearPageVmemmap(struct page *page)
> +{
> +	ClearPageReserved(page);
> +	page->mapping = NULL;
> +}
> +
> +static __always_inline void __SetPageVmemmap(struct page *page)
> +{
> +	SetPageReserved(page);
> +	page->mapping = (void *)VMEMMAP_PAGE;
> +}

Just curious, but why are these __ versions?  I thought we used that for
non-atomic bit operations, but this uses the atomic SetPageReserved().

> diff --git a/mm/compaction.c b/mm/compaction.c
> index 7c607479de4a..c94a480e01b5 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -768,6 +768,9 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>  
>  		page = pfn_to_page(low_pfn);
>  
> +		if (PageVmemmap(page))
> +			goto isolate_fail;

Comments, please.

...
> +static int __online_pages_range(unsigned long start_pfn, unsigned long nr_pages)
> +{
> +	if (PageReserved(pfn_to_page(start_pfn)))
> +		return online_pages_blocks(start_pfn, nr_pages);
> +
> +	return 0;
> +}

Why is it important that 'start_pfn' is PageReserved()?

>  static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
> -			void *arg)
> +								void *arg)
>  {
>  	unsigned long onlined_pages = *(unsigned long *)arg;
> +	unsigned long pfn = start_pfn;
> +	unsigned long end_pfn = start_pfn + nr_pages;
> +	bool vmemmap_page = false;
>  
> -	if (PageReserved(pfn_to_page(start_pfn)))
> -		onlined_pages = online_pages_blocks(start_pfn, nr_pages);
> +	for (; pfn < end_pfn; pfn++) {
> +		struct page *p = pfn_to_page(pfn);
> +
> +		/*
> +		 * Let us check if we got vmemmap pages.
> +		 */
> +		if (PageVmemmap(p)) {
> +			vmemmap_page = true;
> +			break;
> +		}
> +	}

OK, so we did the hot-add, and allocated some of the memmap[] inside the
area being hot-added.  Now, we're onlining the page.  We search every
page in the *entire* area being onlined to try to find a PageVmemmap()?
 That seems a bit inefficient, especially for sections where we don't
have a PageVmemmap().

> +	if (!vmemmap_page) {
> +		/*
> +		 * We can send the whole range to __online_pages_range,
> +		 * as we know for sure that there are not vmemmap pages.
> +		 */
> +		onlined_pages += __online_pages_range(start_pfn, nr_pages);
> +	} else {
> +		/*
> +		 * We need to strip the vmemmap pages here,
> +		 * as we do not want to send them to the buddy allocator.
> +		 */
> +		unsigned long sections = nr_pages / PAGES_PER_SECTION;
> +		unsigned long sect_nr = 0;
> +
> +		for (; sect_nr < sections; sect_nr++) {
> +			unsigned pfn_end_section;
> +			unsigned long memmap_pages = 0;
> +
> +			pfn = start_pfn + (PAGES_PER_SECTION * sect_nr);
> +			pfn_end_section = pfn + PAGES_PER_SECTION;
> +
> +			while (pfn < pfn_end_section) {
> +				struct page *p = pfn_to_page(pfn);
> +
> +				if (PageVmemmap(p))
> +					memmap_pages++;
> +				pfn++;
> +			}

... and another lienar search through the entire area being added.

> +			pfn = start_pfn + (PAGES_PER_SECTION * sect_nr);
> +			if (!memmap_pages) {
> +				onlined_pages += __online_pages_range(pfn, PAGES_PER_SECTION);

If I read this right, this if() and the first block are unneeded.  The
second block is funcationally identical if memmap_pages==0.  Seems like
we can simplify the code.  Also, is this _really_ under 80 columns?
Seems kinda long.

> +		if (PageVmemmap(page))
> +			continue;

FWIW, all these random-looking PageVmemmap() calls are a little
worrying.  What happens when we get one wrong?  Seems like we're kinda
bringing back all the PageReserved() checks we used to have scattered
all over.

> @@ -8138,6 +8146,16 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
>  			continue;
>  		}
>  		page = pfn_to_page(pfn);
> +
> +		/*
> +		 * vmemmap pages are residing inside the memory section so
> +		 * they do not have to be freed anywhere.
> +		 */
> +		if (PageVmemmap(page)) {
> +			pfn++;
> +			continue;
> +		}


> +static struct page *current_vmemmap_page = NULL;
> +static bool vmemmap_dec_and_test(void)
> +{
> +	bool ret = false;
> +
> +	if (page_ref_dec_and_test(current_vmemmap_page))
> +			ret = true;
> +	return ret;
> +}

That's a bit of an obfuscated way to do:

	return page_ref_dec_and_test(current_vmemmap_page));

:)

But, I also see a global variable, and this immediately makes me think
about locking and who "owns" this.  Comments would help.

> +static void free_vmemmap_range(unsigned long limit, unsigned long start, unsigned long end)
> +{
> +	unsigned long range_start;
> +	unsigned long range_end;
> +	unsigned long align = sizeof(struct page) * PAGES_PER_SECTION;
> +
> +	range_end = end;
> +	range_start = end - align;
> +	while (range_start >= limit) {
> +		vmemmap_free(range_start, range_end, NULL);
> +		range_end = range_start;
> +		range_start -= align;
> +	}
> +}

This loop looks like it's working from the end of the range back to the
beginning.  I guess that it works, but it's a bit unconventional to go
backwards.  Was there a reason?

Overall, there's a lot of complexity here.  This certainly doesn't make
the memory hotplug code simpler.
