Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6E1C36B028D
	for <linux-mm@kvack.org>; Sat, 22 Apr 2017 14:11:58 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id j29so30211232qtj.19
        for <linux-mm@kvack.org>; Sat, 22 Apr 2017 11:11:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t188si13500005qkh.308.2017.04.22.11.11.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Apr 2017 11:11:57 -0700 (PDT)
Date: Sat, 22 Apr 2017 14:11:51 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 03/15] mm/unaddressable-memory: new type of ZONE_DEVICE for
 unaddressable memory
Message-ID: <20170422181151.GA2360@redhat.com>
References: <20170422033037.3028-1-jglisse@redhat.com>
 <20170422033037.3028-4-jglisse@redhat.com>
 <CAPcyv4jq0+FptsqUY14PA7WfgjYOt-kA5r084c8vvmkAU8WqaQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4jq0+FptsqUY14PA7WfgjYOt-kA5r084c8vvmkAU8WqaQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Fri, Apr 21, 2017 at 10:30:01PM -0700, Dan Williams wrote:
> On Fri, Apr 21, 2017 at 8:30 PM, Jerome Glisse <jglisse@redhat.com> wrote:

[...]

> > +/*
> > + * Specialize ZONE_DEVICE memory into multiple types each having differents
> > + * usage.
> > + *
> > + * MEMORY_DEVICE_PERSISTENT:
> > + * Persistent device memory (pmem): struct page might be allocated in different
> > + * memory and architecture might want to perform special actions. It is similar
> > + * to regular memory, in that the CPU can access it transparently. However,
> > + * it is likely to have different bandwidth and latency than regular memory.
> > + * See Documentation/nvdimm/nvdimm.txt for more information.
> > + *
> > + * MEMORY_DEVICE_UNADDRESSABLE:
> > + * Device memory that is not directly addressable by the CPU: CPU can neither
> > + * read nor write _UNADDRESSABLE memory. In this case, we do still have struct
> > + * pages backing the device memory. Doing so simplifies the implementation, but
> > + * it is important to remember that there are certain points at which the struct
> > + * page must be treated as an opaque object, rather than a "normal" struct page.
> > + * A more complete discussion of unaddressable memory may be found in
> > + * include/linux/hmm.h and Documentation/vm/hmm.txt.
> > + */
> > +enum memory_type {
> > +       MEMORY_DEVICE_PERSISTENT = 0,
> > +       MEMORY_DEVICE_UNADDRESSABLE,
> > +};
> 
> Ok, this is a bikeshed, but I think it is important. I think these
> should be called MEMORY_DEVICE_PUBLIC and MEMORY_DEVICE_PRIVATE. The
> reason is that persistence has nothing to do with the code paths that
> deal with the pmem use case of ZONE_DEVICE. The only property the mm
> cares about is that the address range behaves the same as host memory
> for dma and cpu accesses. The "unaddressable" designation always
> confuses me because a memory range isn't memory if it's
> "unaddressable". It is addressable, it's just "private" to the device.

I can change the name but the memory is truely unaddressable, the CPU
can not access it whatsoever (well it can access a small window but
even that is not guaranteed).


> > +/*
> > + * For MEMORY_DEVICE_UNADDRESSABLE we use ZONE_DEVICE and extend it with two
> > + * callbacks:
> > + *   page_fault()
> > + *   page_free()
> > + *
> > + * Additional notes about MEMORY_DEVICE_UNADDRESSABLE may be found in
> > + * include/linux/hmm.h and Documentation/vm/hmm.txt. There is also a brief
> > + * explanation in include/linux/memory_hotplug.h.
> > + *
> > + * The page_fault() callback must migrate page back, from device memory to
> > + * system memory, so that the CPU can access it. This might fail for various
> > + * reasons (device issues,  device have been unplugged, ...). When such error
> > + * conditions happen, the page_fault() callback must return VM_FAULT_SIGBUS and
> > + * set the CPU page table entry to "poisoned".
> > + *
> > + * Note that because memory cgroup charges are transferred to the device memory,
> > + * this should never fail due to memory restrictions. However, allocation
> > + * of a regular system page might still fail because we are out of memory. If
> > + * that happens, the page_fault() callback must return VM_FAULT_OOM.
> > + *
> > + * The page_fault() callback can also try to migrate back multiple pages in one
> > + * chunk, as an optimization. It must, however, prioritize the faulting address
> > + * over all the others.
> > + *
> > + *
> > + * The page_free() callback is called once the page refcount reaches 1
> > + * (ZONE_DEVICE pages never reach 0 refcount unless there is a refcount bug.
> > + * This allows the device driver to implement its own memory management.)
> > + */
> > +typedef int (*dev_page_fault_t)(struct vm_area_struct *vma,
> > +                               unsigned long addr,
> > +                               struct page *page,
> > +                               unsigned int flags,
> > +                               pmd_t *pmdp);
> > +typedef void (*dev_page_free_t)(struct page *page, void *data);
> > +
> >  /**
> >   * struct dev_pagemap - metadata for ZONE_DEVICE mappings
> > + * @page_fault: callback when CPU fault on an unaddressable device page
> > + * @page_free: free page callback when page refcount reaches 1
> >   * @altmap: pre-allocated/reserved memory for vmemmap allocations
> >   * @res: physical address range covered by @ref
> >   * @ref: reference count that pins the devm_memremap_pages() mapping
> >   * @dev: host device of the mapping for debug
> > + * @data: private data pointer for page_free()
> > + * @type: memory type: see MEMORY_* in memory_hotplug.h
> >   */
> >  struct dev_pagemap {
> > +       dev_page_fault_t page_fault;
> > +       dev_page_free_t page_free;
> >         struct vmem_altmap *altmap;
> >         const struct resource *res;
> >         struct percpu_ref *ref;
> >         struct device *dev;
> > +       void *data;
> > +       enum memory_type type;
> >  };
> 
> I think the only attribute that belongs here is @type, the rest are
> specific to the device_private case.
> 
> struct dev_private_pagemap {
>     dev_page_fault_t page_fault;
>     dev_page_free_t page_free;
>     void *data;
>     struct dev_pagemap pgmap;
> };
> 
> As Logan pointed out we can kill the internal struct page_map in
> kernel/memremap.c and let devm_memremap_pages() take a "struct
> dev_pagemap *" pointer. That way when future dev_pagemap users come
> along they can wrap the core structure with whatever specific data
> they need for their use case.

I don't want to make that change as part of HMM, this can be done
as a patchset on top. Also it is easier to add callback to dev_pagemap
especially as we want p2p and HMM side by side not as something
exclusive.

[...]

> > +#if IS_ENABLED(CONFIG_DEVICE_UNADDRESSABLE)
> > +static inline swp_entry_t make_device_entry(struct page *page, bool write)
> > +{
> > +       return swp_entry(write ? SWP_DEVICE_WRITE : SWP_DEVICE_READ,
> > +                        page_to_pfn(page));
> > +}
> > +
> > +static inline bool is_device_entry(swp_entry_t entry)
> > +{
> > +       int type = swp_type(entry);
> > +       return type == SWP_DEVICE_READ || type == SWP_DEVICE_WRITE;
> > +}
> > +
> > +static inline void make_device_entry_read(swp_entry_t *entry)
> > +{
> > +       *entry = swp_entry(SWP_DEVICE_READ, swp_offset(*entry));
> > +}
> > +
> > +static inline bool is_write_device_entry(swp_entry_t entry)
> > +{
> > +       return unlikely(swp_type(entry) == SWP_DEVICE_WRITE);
> > +}
> > +
> > +static inline struct page *device_entry_to_page(swp_entry_t entry)
> > +{
> > +       return pfn_to_page(swp_offset(entry));
> > +}
> > +
> > +int device_entry_fault(struct vm_area_struct *vma,
> > +                      unsigned long addr,
> > +                      swp_entry_t entry,
> > +                      unsigned int flags,
> > +                      pmd_t *pmdp);
> 
> 
> The use of the "device" term is ambiguous. Since these changes are
> specific to the MEMORY_DEVICE_PRIVATE can we reflect "private" in the
> name? Change "device" to "devpriv" or "device_private"?

Yes we can.

[...]

> > @@ -194,12 +196,47 @@ void put_zone_device_page(struct page *page)
> >          * ZONE_DEVICE page refcount should never reach 0 and never be freed
> >          * to kernel memory allocator.
> >          */
> > -       page_ref_dec(page);
> > +       int count = page_ref_dec_return(page);
> > +
> > +       /*
> > +        * If refcount is 1 then page is freed and refcount is stable as nobody
> > +        * holds a reference on the page.
> > +        */
> > +       if (page->pgmap->page_free && count == 1)
> > +               page->pgmap->page_free(page, page->pgmap->data);
> 
> 
> Reading this it isn't clear whether we are dealing with the public or
> private case. I think this should be:
> 
> if (count == 1)
>         zone_device_page_free(page);
> 
> ...where zone_device_page_free() is a helper that is explicit about
> the expectations of which ZONE_DEVICE types need to take action on a
> 'free' event.
> 
> static void zone_device_page_free(struct page *page)
> {
>         struct dev_private_pagemap *priv_pgmap;
> 
>         if (page->pgmap->type == MEMORY_DEVICE_PUBLIC)
>                 return;
> 
>         priv_pgmap = container_of(page->pgmap, typeof(*priv_pgmap), pgmap);
>         priv_pgmap->page_free(page);
> }

Ok.

> > @@ -332,6 +369,10 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
> >         }
> >         pgmap->ref = ref;
> >         pgmap->res = &page_map->res;
> > +       pgmap->type = MEMORY_DEVICE_PERSISTENT;
> > +       pgmap->page_fault = NULL;
> > +       pgmap->page_free = NULL;
> > +       pgmap->data = NULL;
> 
> 
> This goes away if we convert to passing in the dev_pagemap, and I
> think that is a useful cleanup.

Yes but i rather do it as a patchset on top as i am sure p2p folks
will want to give input and i don't want to delay until we can agree
on exact fields we want/need.

[...]

> > diff --git a/mm/mprotect.c b/mm/mprotect.c
> > index 8edd0d5..dadb020 100644
> > --- a/mm/mprotect.c
> > +++ b/mm/mprotect.c
> > @@ -126,6 +126,20 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
> >
> >                                 pages++;
> >                         }
> > +
> > +                       if (is_write_device_entry(entry)) {
> > +                               pte_t newpte;
> > +
> > +                               /*
> > +                                * We do not preserve soft-dirtiness. See
> > +                                * copy_one_pte() for explanation.
> > +                                */
> > +                               make_device_entry_read(&entry);
> > +                               newpte = swp_entry_to_pte(entry);
> > +                               set_pte_at(mm, addr, pte, newpte);
> > +
> > +                               pages++;
> > +                       }
> >                 }
> >         } while (pte++, addr += PAGE_SIZE, addr != end);
> >         arch_leave_lazy_mmu_mode();
> 
> I think this is a good example of how the usage of the generic
> "device" term makes the new "private" code paths harder to spot /
> discern from the current "public" requirements.

I will change to devpriv

Thank for reviewing.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
