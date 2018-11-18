Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 916C46B171E
	for <linux-mm@kvack.org>; Sun, 18 Nov 2018 17:55:01 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c3so10886255eda.3
        for <linux-mm@kvack.org>; Sun, 18 Nov 2018 14:55:01 -0800 (PST)
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id s1-v6si2735975ejs.111.2018.11.18.14.54.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Nov 2018 14:54:59 -0800 (PST)
Message-ID: <1542581665.2947.46.camel@suse.com>
Subject: Re: [RFC PATCH 3/4] mm, memory_hotplug: allocate memmap from the
 added memory range for sparse-vmemmap
From: osalvador <osalvador@suse.com>
Date: Sun, 18 Nov 2018 23:54:25 +0100
In-Reply-To: <87e29d18-c1f7-05b6-edda-1848fb2a1a03@intel.com>
References: <20181116101222.16581-1-osalvador@suse.com>
	 <20181116101222.16581-4-osalvador@suse.com>
	 <87e29d18-c1f7-05b6-edda-1848fb2a1a03@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org
Cc: mhocko@suse.com, david@redhat.com, rppt@linux.vnet.ibm.com, akpm@linux-foundation.org, arunks@codeaurora.org, bhe@redhat.com, dan.j.williams@intel.com, Pavel.Tatashin@microsoft.com, Jonathan.Cameron@huawei.com, jglisse@redhat.com, linux-kernel@vger.kernel.org

On Fri, 2018-11-16 at 14:41 -0800, Dave Hansen wrote:
> On 11/16/18 2:12 AM, Oscar Salvador wrote:
> > Physical memory hotadd has to allocate a memmap (struct page array)
> > for
> > the newly added memory section. Currently, kmalloc is used for
> > those
> > allocations.
> 
> Did you literally mean kmalloc?  I thought we had a bunch of ways of
> allocating memmaps, but I didn't think kmalloc() was actually used.

No, sorry.
The name of the fuctions used for allocating a memmap contain the word
kmalloc, so it was a confusion.
Indeed, vmemmap_alloc_block() ends up calling alloc_pages_node().
__kmalloc_section_usemap() is the one that calls kmalloc.

> 
> So, can the ZONE_DEVICE altmaps move over to this infrastructure?
> Doesn't this effectively duplicate that code?

Actually, we are reciclyng/using part of the ZONE_DEVICE altmap code,
and the "struct vmemmap_altmap" itself.

The only thing we added in that regard is the callback function
mark_vmemmap_pages(), that controls the refcount and marks the pages as
Vmemmap.


> ...
> > diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
> > index 7a9886f98b0c..03f014abd4eb 100644
> > --- a/arch/powerpc/mm/init_64.c
> > +++ b/arch/powerpc/mm/init_64.c
> > @@ -278,6 +278,8 @@ void __ref vmemmap_free(unsigned long start,
> > unsigned long end,
> >  			continue;
> >  
> >  		page = pfn_to_page(addr >> PAGE_SHIFT);
> > +		if (PageVmemmap(page))
> > +			continue;
> >  		section_base =
> > pfn_to_page(vmemmap_section_start(start));
> >  		nr_pages = 1 << page_order;
> 
> Reading this, I'm wondering if PageVmemmap() could be named better.
> From this is reads like "skip PageVmemmap() pages if freeing
> vmemmap",
> which does not make much sense.
> 
> This probably at _least_ needs a comment to explain why the pages are
> being skipped.

The thing is that we do not need to send Vmemmap pages to the buddy
system by means of free_pages/free_page_reserved, as those pages reside
within the memory section.
The only thing we need is to clear the mapping(pagetables).

I just realized that that piece of code is wrong, as it does not allow
to clear the mapping.
One of the consequences to only have tested this on x86_64.

> 
> > diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
> > index 4139affd6157..bc1523bcb09d 100644
> > --- a/arch/s390/mm/init.c
> > +++ b/arch/s390/mm/init.c
> > @@ -231,6 +231,12 @@ int arch_add_memory(int nid, u64 start, u64
> > size,
> >  	unsigned long size_pages = PFN_DOWN(size);
> >  	int rc;
> >  
> > +	/*
> > +	 * Physical memory is added only later during the memory
> > online so we
> > +	 * cannot use the added range at this stage
> > unfortunatelly.
> 
> 					unfortunately ^
> 
> > +	 */
> > +	restrictions->flags &= ~MHP_MEMMAP_FROM_RANGE;
> 
> Could you also add to the  comment about this being specific to s390?

Sure, will do.

> >  	rc = vmem_add_mapping(start, size);
> >  	if (rc)
> >  		return rc;
> > diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> > index fd06bcbd9535..d5234ca5c483 100644
> > --- a/arch/x86/mm/init_64.c
> > +++ b/arch/x86/mm/init_64.c
> > @@ -815,6 +815,13 @@ static void __meminit free_pagetable(struct
> > page *page, int order)
> >  	unsigned long magic;
> >  	unsigned int nr_pages = 1 << order;
> >  
> > +	/*
> > +	 * runtime vmemmap pages are residing inside the memory
> > section so
> > +	 * they do not have to be freed anywhere.
> > +	 */
> > +	if (PageVmemmap(page))
> > +		return;
> 
> Thanks for the comment on this one, this one is right on.
> 
> > @@ -16,13 +18,18 @@ struct device;
> >   * @free: free pages set aside in the mapping for memmap storage
> >   * @align: pages reserved to meet allocation alignments
> >   * @alloc: track pages consumed, private to vmemmap_populate()
> > + * @flush_alloc_pfns: callback to be called on the allocated range
> > after it
> > + * @nr_sects: nr of sects filled with memmap allocations
> > + * is mapped to the vmemmap - see mark_vmemmap_pages
> >   */
> 
> I think you split up the "@flush_alloc_pfns" comment accidentally.

Indeed, looks "broken".
I will fix it.


> > +	/*
> > +	 * We keep track of the sections using this altmap by
> > means
> > +	 * of a refcount, so we know how much do we have to defer
> > +	 * the call to vmemmap_free for this memory range.
> > +	 * The refcount is kept in the first vmemmap page.
> > +	 * For example:
> > +	 * We add 10GB: (ffffea0004000000 - ffffea000427ffc0)
> > +	 * ffffea0004000000 will have a refcount of 80.
> > +	 */
> 
> The example is good, but it took me a minute to realize that 80 is
> because 10GB is roughly 80 sections.

I will try to make it more clear.

> 
> > +	head = (struct page *)ALIGN_DOWN((unsigned
> > long)pfn_to_page(pfn), align);
> 
> Is this ALIGN_DOWN() OK?  It seems like it might be aligning 'pfn'
> down
> into the reserved are that lies before it.

This aligns down to the section.
It makes sure that given any page within a section, it will return the
first page of it.
For example, for pages from ffffea0004000000 to 0xffffea00041f8000,
it will always return ffffea0004000000. (which is first vmemmap page).

Then, we have another computation:

head = (struct page *)((unsigned long)head - (align * self->nr_sects));

In case we filled up a complete section with memmap allocations, self-
>nr_sects get increased.
So, when we cross sections, we know how much do we have to go backwards
to get the first vmemmap page of the first section.

So, in case we got the page 0xffffea0004208000, the first ALIGN_DOWN
would give us 0xffffea0004200000, and then the second computation will
give us ffffea0004000000.

> > +	WARN_ON(self->align);
> > +        for (i = 0; i < nr_pages; i++, pfn++) {
> > +                struct page *page = pfn_to_page(pfn);
> > +                __SetPageVmemmap(page);
> > +		init_page_count(page);
> > +        }
> 
> Looks like some tabs vs. space problems.

Sorry, I fixed it.


> > +static __always_inline void __ClearPageVmemmap(struct page *page)
> > +{
> > +	ClearPageReserved(page);
> > +	page->mapping = NULL;
> > +}
> > +
> > +static __always_inline void __SetPageVmemmap(struct page *page)
> > +{
> > +	SetPageReserved(page);
> > +	page->mapping = (void *)VMEMMAP_PAGE;
> > +}
> 
> Just curious, but why are these __ versions?  I thought we used that
> for
> non-atomic bit operations, but this uses the atomic
> SetPageReserved().

I think that we can use __SetPageReserved and __ClearPageReserved here,
as

a) these pages are not initialized yet
b) hot-add operations are serialized
c) we should be the only ones making use of this mem range

> 
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 7c607479de4a..c94a480e01b5 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -768,6 +768,9 @@ isolate_migratepages_block(struct
> > compact_control *cc, unsigned long low_pfn,
> >  
> >  		page = pfn_to_page(low_pfn);
> >  
> > +		if (PageVmemmap(page))
> > +			goto isolate_fail;
> 
> Comments, please.

Will do.


> ...
> > +static int __online_pages_range(unsigned long start_pfn, unsigned
> > long nr_pages)
> > +{
> > +	if (PageReserved(pfn_to_page(start_pfn)))
> > +		return online_pages_blocks(start_pfn, nr_pages);
> > +
> > +	return 0;
> > +}
> 
> Why is it important that 'start_pfn' is PageReserved()?

This check condition on PageReserved was already there before my patch.
I think that this is done because we do set all the pages within the
page as PageReserved by means of:

online_pages()->move_pfn_range()->move_pfn_range_to_zone()-
>memmap_init_zone()

memmap_init_zone marks the page as reserved.
I guess that this is later being checked when onlining the page to
check that no one touched those pages in the meantime.

> 
> >  static int online_pages_range(unsigned long start_pfn, unsigned
> > long nr_pages,
> > -			void *arg)
> > +								vo
> > id *arg)
> >  {
> >  	unsigned long onlined_pages = *(unsigned long *)arg;
> > +	unsigned long pfn = start_pfn;
> > +	unsigned long end_pfn = start_pfn + nr_pages;
> > +	bool vmemmap_page = false;
> >  
> > -	if (PageReserved(pfn_to_page(start_pfn)))
> > -		onlined_pages = online_pages_blocks(start_pfn,
> > nr_pages);
> > +	for (; pfn < end_pfn; pfn++) {
> > +		struct page *p = pfn_to_page(pfn);
> > +
> > +		/*
> > +		 * Let us check if we got vmemmap pages.
> > +		 */
> > +		if (PageVmemmap(p)) {
> > +			vmemmap_page = true;
> > +			break;
> > +		}
> > +	}
> 
> OK, so we did the hot-add, and allocated some of the memmap[] inside
> the
> area being hot-added.  Now, we're onlining the page.  We search every
> page in the *entire* area being onlined to try to find a
> PageVmemmap()?
>  That seems a bit inefficient, especially for sections where we don't
> have a PageVmemmap().
> 
[...]
> 
> If I read this right, this if() and the first block are
> unneeded.  The
> second block is funcationally identical if memmap_pages==0.  Seems
> like
> we can simplify the code.  Also, is this _really_ under 80 columns?
> Seems kinda long.

Yeah, before the optimization for freeing pages higher order, this
would have been much easier.
I just wanted to be very carefull and strip the vmemmap pages there
before sending the range to the buddy allocator.

But this can be done better, you are right.

I will think more about this.

> 
> > +		if (PageVmemmap(page))
> > +			continue;
> 
> FWIW, all these random-looking PageVmemmap() calls are a little
> worrying.  What happens when we get one wrong?  Seems like we're
> kinda
> bringing back all the PageReserved() checks we used to have scattered
> all over.

Well, we check for Vmemmap pages in:

* has_unmovable_pages
* __offline_isolated_pages
* free_pages_check
* test_pages_isolated
* __test_page_isolated_in_pageblock
* arch-specific code to not free them

The check in free_pages_check can be gone, as a vmemmap page should
never reach that.

The rest of the checks are either because we have to skip to make
forward progess, as it is the case in
has_unmovable_pages/__test_page_isolated_in_pageblock, or because we do
not need to perform any action on them.

I will try to see if I can get rid of some, and I will improve the
comenting.


> 
> > +static struct page *current_vmemmap_page = NULL;
> > +static bool vmemmap_dec_and_test(void)
> > +{
> > +	bool ret = false;
> > +
> > +	if (page_ref_dec_and_test(current_vmemmap_page))
> > +			ret = true;
> > +	return ret;
> > +}
> 
> That's a bit of an obfuscated way to do:
> 
> 	return page_ref_dec_and_test(current_vmemmap_page));
> 
> :)

Yes, much easier and better.

> 
> But, I also see a global variable, and this immediately makes me
> think
> about locking and who "owns" this.  Comments would help.

The thing is that __kfree_section_memmap is only called from
sparse_remove_one_section by means of free_section_usemap.
sparse_remove_one_section is called from the hot-remove operation,
which is serialized by the hotplug lock.

But I agree that comments would help to understand this much better.
I will add them.

> 
> > +static void free_vmemmap_range(unsigned long limit, unsigned long
> > start, unsigned long end)
> > +{
> > +	unsigned long range_start;
> > +	unsigned long range_end;
> > +	unsigned long align = sizeof(struct page) *
> > PAGES_PER_SECTION;
> > +
> > +	range_end = end;
> > +	range_start = end - align;
> > +	while (range_start >= limit) {
> > +		vmemmap_free(range_start, range_end, NULL);
> > +		range_end = range_start;
> > +		range_start -= align;
> > +	}
> > +}
> 
> This loop looks like it's working from the end of the range back to
> the
> beginning.  I guess that it works, but it's a bit unconventional to
> go
> backwards.  Was there a reason?

Yes, it is intended to be that way.
The thing is that the memory for the page tables for the memmap array
is comming from the beggining of the hot-added section/s.
If we call vmemmap_free() from the beginning, the PMDs will be cleared
up, and future references to the next sections when called from
vmemmap_free() will blow up.

I know it is not very elegant to call it backwards, but the alternative
was to fiddle into arch specifics to hold the pmd clearing phase until
all sections that were using vmemmap pages were torn down.

So I picked this approach that does not involve any arch specifics and
just works quite well.

> 
> Overall, there's a lot of complexity here.  This certainly doesn't
> make
> the memory hotplug code simpler.

I will try to make it more understandable and simple.

Thanks a lot for your review Dan!
