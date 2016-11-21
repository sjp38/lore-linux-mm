Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0DE29280260
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 07:33:23 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id o1so86012362ito.7
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 04:33:23 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w188si10094890itd.78.2016.11.21.04.33.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 04:33:22 -0800 (PST)
Date: Mon, 21 Nov 2016 07:33:17 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM v13 02/18] mm/ZONE_DEVICE/unaddressable: add support for
 un-addressable device memory
Message-ID: <20161121123316.GC2392@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-3-git-send-email-jglisse@redhat.com>
 <5832AB21.1010606@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5832AB21.1010606@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Mon, Nov 21, 2016 at 01:36:57PM +0530, Anshuman Khandual wrote:
> On 11/18/2016 11:48 PM, Jerome Glisse wrote:
> > This add support for un-addressable device memory. Such memory is hotpluged
> > only so we can have struct page but should never be map. This patch add code
> 
> struct pages inside the system RAM range unlike the vmem_altmap scheme
> where the struct pages can be inside the device memory itself. This
> possibility does not arise for un addressable device memory. May be we
> will have to block the paths where vmem_altmap is requested along with
> un addressable device memory.

I did not think checking for that explicitly was necessary, sounded like shooting
yourself in the foot and that it would be obvious :)

[...]

> > diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> > index 9341619..fe61dca 100644
> > --- a/include/linux/memremap.h
> > +++ b/include/linux/memremap.h
> > @@ -41,22 +41,34 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
> >   * @res: physical address range covered by @ref
> >   * @ref: reference count that pins the devm_memremap_pages() mapping
> >   * @dev: host device of the mapping for debug
> > + * @flags: memory flags (look for MEMORY_FLAGS_NONE in memory_hotplug.h)
> 
> ^^^^^^^^^^^^^ device memory flags instead ?

Well maybe it will be use for something else than device memory in the future
but yes for now it is only device memory so i can rename it.

> >   */
> >  struct dev_pagemap {
> >  	struct vmem_altmap *altmap;
> >  	const struct resource *res;
> >  	struct percpu_ref *ref;
> >  	struct device *dev;
> > +	int flags;
> >  };
> >  
> >  #ifdef CONFIG_ZONE_DEVICE
> >  void *devm_memremap_pages(struct device *dev, struct resource *res,
> > -		struct percpu_ref *ref, struct vmem_altmap *altmap);
> > +			  struct percpu_ref *ref, struct vmem_altmap *altmap,
> > +			  struct dev_pagemap **ppgmap, int flags);
> >  struct dev_pagemap *find_dev_pagemap(resource_size_t phys);
> > +
> > +static inline bool is_addressable_page(const struct page *page)
> > +{
> > +	return ((page_zonenum(page) != ZONE_DEVICE) ||
> > +		!(page->pgmap->flags & MEMORY_UNADDRESSABLE));
> > +}
> >  #else
> >  static inline void *devm_memremap_pages(struct device *dev,
> > -		struct resource *res, struct percpu_ref *ref,
> > -		struct vmem_altmap *altmap)
> > +					struct resource *res,
> > +					struct percpu_ref *ref,
> > +					struct vmem_altmap *altmap,
> > +					struct dev_pagemap **ppgmap,
> > +					int flags)
> 
> 
> As I had mentioned before devm_memremap_pages() should be changed not
> to accept a valid altmap along with request for un-addressable memory.

If you fear such case yes sure.


[...]

> > diff --git a/kernel/memremap.c b/kernel/memremap.c
> > index 07665eb..438a73aa2 100644
> > --- a/kernel/memremap.c
> > +++ b/kernel/memremap.c
> > @@ -246,7 +246,7 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
> >  	/* pages are dead and unused, undo the arch mapping */
> >  	align_start = res->start & ~(SECTION_SIZE - 1);
> >  	align_size = ALIGN(resource_size(res), SECTION_SIZE);
> > -	arch_remove_memory(align_start, align_size, MEMORY_DEVICE);
> > +	arch_remove_memory(align_start, align_size, pgmap->flags);
> >  	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
> >  	pgmap_radix_release(res);
> >  	dev_WARN_ONCE(dev, pgmap->altmap && pgmap->altmap->alloc,
> > @@ -270,6 +270,8 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
> >   * @res: "host memory" address range
> >   * @ref: a live per-cpu reference count
> >   * @altmap: optional descriptor for allocating the memmap from @res
> > + * @ppgmap: pointer set to new page dev_pagemap on success
> > + * @flags: flag for memory (look for MEMORY_FLAGS_NONE in memory_hotplug.h)
> >   *
> >   * Notes:
> >   * 1/ @ref must be 'live' on entry and 'dead' before devm_memunmap_pages() time
> > @@ -280,7 +282,8 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
> >   *    this is not enforced.
> >   */
> >  void *devm_memremap_pages(struct device *dev, struct resource *res,
> > -		struct percpu_ref *ref, struct vmem_altmap *altmap)
> > +			  struct percpu_ref *ref, struct vmem_altmap *altmap,
> > +			  struct dev_pagemap **ppgmap, int flags)
> >  {
> >  	resource_size_t key, align_start, align_size, align_end;
> >  	pgprot_t pgprot = PAGE_KERNEL;
> > @@ -322,6 +325,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
> >  	}
> >  	pgmap->ref = ref;
> >  	pgmap->res = &page_map->res;
> > +	pgmap->flags = flags | MEMORY_DEVICE;
> 
> So the caller of devm_memremap_pages() should not have give out MEMORY_DEVICE
> in the flag it passed on to this function ? Hmm, else we should just check
> that the flags contains all appropriate bits before proceeding.

Here i was just trying to be on the safe side, yes caller should already have set
the flag but this function is only use for device memory so it did not seem like
it would hurt to be extra safe. I can add a BUG_ON() but it seems people have mix
feeling about BUG_ON()

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
