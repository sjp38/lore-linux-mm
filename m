Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id EC2976B0038
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 21:18:21 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id v16so24021294qge.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 18:18:21 -0800 (PST)
Received: from mail-qk0-x234.google.com (mail-qk0-x234.google.com. [2607:f8b0:400d:c09::234])
        by mx.google.com with ESMTPS id n83si4193611qhn.97.2015.12.15.18.18.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 18:18:20 -0800 (PST)
Received: by mail-qk0-x234.google.com with SMTP id k189so44148299qkc.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 18:18:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151215161438.e971fc9b98814513bbacb3ed@linux-foundation.org>
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
	<20151210023916.30368.94401.stgit@dwillia2-desk3.jf.intel.com>
	<20151215161438.e971fc9b98814513bbacb3ed@linux-foundation.org>
Date: Tue, 15 Dec 2015 18:18:20 -0800
Message-ID: <CAPcyv4hRmMJBBWr6dTjX05KFUE8sv6WQa0Co9h-ukHn=_8p6Ag@mail.gmail.com>
Subject: Re: [-mm PATCH v2 23/25] mm, x86: get_user_pages() for dax mappings
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@sr71.net>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Peter Zijlstra <peterz@infradead.org>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Logan Gunthorpe <logang@deltatee.com>

On Tue, Dec 15, 2015 at 4:14 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 09 Dec 2015 18:39:16 -0800 Dan Williams <dan.j.williams@intel.com> wrote:
>
>> A dax mapping establishes a pte with _PAGE_DEVMAP set when the driver
>> has established a devm_memremap_pages() mapping, i.e. when the pfn_t
>> return from ->direct_access() has PFN_DEV and PFN_MAP set.  Later, when
>> encountering _PAGE_DEVMAP during a page table walk we lookup and pin a
>> struct dev_pagemap instance to keep the result of pfn_to_page() valid
>> until put_page().
>
> This patch adds a whole bunch of code and cycles to everyone's kernels,
> but few of those kernels will ever use it.  What are our options for
> reducing that overhead, presumably via Kconfig?

It's does compile out when CONFIG_ZONE_DEVICE=n.

>> --- a/arch/x86/mm/gup.c
>> +++ b/arch/x86/mm/gup.c
>> @@ -63,6 +63,16 @@ retry:
>>  #endif
>>  }
>>
>> +static void undo_dev_pagemap(int *nr, int nr_start, struct page **pages)
>> +{
>> +     while ((*nr) - nr_start) {
>> +             struct page *page = pages[--(*nr)];
>> +
>> +             ClearPageReferenced(page);
>> +             put_page(page);
>> +     }
>> +}
>
> PG_referenced is doing something magical in this code.  Could we have a
> nice comment explaining its meaning in this context?  Unless it's
> already there and I missed it..

In this case I'm just duplicating what gup_pte_range() already does
with normal memory pages, no special meaning for zone_device pages.

>
>>
>> ...
>>
>> @@ -830,6 +831,20 @@ static inline void put_dev_pagemap(struct dev_pagemap *pgmap)
>>               percpu_ref_put(pgmap->ref);
>>  }
>>
>> +static inline void get_page(struct page *page)
>> +{
>> +     if (is_zone_device_page(page))
>> +             percpu_ref_get(page->pgmap->ref);
>> +
>> +     page = compound_head(page);
>
> So we're assuming that is_zone_device_page() against a tail page works
> OK.  That's presently true, fingers crossed for the future...
>
> And we're also assuming that device pages are never compound.  How safe
> is that assumption?

These pages are never on a slab lru or touched by the mm outside of
get_user_pages() and the I/O path for dma mapping.  It's a bug if a
zone_device page is anything but a standalone vanilla page.

>> +     /*
>> +      * Getting a normal page or the head of a compound page
>> +      * requires to already have an elevated page->_count.
>> +      */
>> +     VM_BUG_ON_PAGE(atomic_read(&page->_count) <= 0, page);
>> +     atomic_inc(&page->_count);
>> +}
>
> The core pagecache lookup bypasses get_page() by using
> page_cache_get_speculative(), but get_page() might be a hotpath for
> some workloads.  Here we're adding quite a bit of text and math and a
> branch.  I'm counting 157 callsites.
>
> So this is a rather unwelcome change.  Why do we need to alter such a
> generic function as get_page() anyway?  Is there some way to avoid
> altering it?

The minimum requirement is to pin down the driver while the pages it
allocated might be in active use for dma or other i/o. We could meet
this requirement by simply pinning the driver while any dax vma is
open.

The downside of this is that it blocks device driver unbind
indefinitely while a dax vma is established rather than only
temporarily blocking unbind/remove for the lifetime of an O_DIRECT I/O
operation.

This goes back to a recurring debate about whether pmem is "memory" or
a "storage-device / disk".

pmem as memory => pin it active while any vma is established

pmem as storage device => pin it active only while i/o is in flight
and forcibly revoke mappings on an unbind/remove event.

>> +static void touch_pmd(struct vm_area_struct *vma, unsigned long addr,
>> +             pmd_t *pmd)
>> +{
>> +     pmd_t _pmd;
>> +
>> +     /*
>> +      * We should set the dirty bit only for FOLL_WRITE but for now
>> +      * the dirty bit in the pmd is meaningless.  And if the dirty
>> +      * bit will become meaningful and we'll only set it with
>> +      * FOLL_WRITE, an atomic set_bit will be required on the pmd to
>> +      * set the young bit, instead of the current set_pmd_at.
>> +      */
>> +     _pmd = pmd_mkyoung(pmd_mkdirty(*pmd));
>> +     if (pmdp_set_access_flags(vma, addr & HPAGE_PMD_MASK,
>> +                             pmd, _pmd,  1))
>> +             update_mmu_cache_pmd(vma, addr, pmd);
>> +}
>> +
>> +struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
>> +             pmd_t *pmd, int flags)
>> +{
>> +     unsigned long pfn = pmd_pfn(*pmd);
>> +     struct mm_struct *mm = vma->vm_mm;
>> +     struct dev_pagemap *pgmap;
>> +     struct page *page;
>> +
>> +     assert_spin_locked(pmd_lockptr(mm, pmd));
>> +
>> +     if (flags & FOLL_WRITE && !pmd_write(*pmd))
>> +             return NULL;
>> +
>> +     if (pmd_present(*pmd) && pmd_devmap(*pmd))
>> +             /* pass */;
>> +     else
>> +             return NULL;
>> +
>> +     if (flags & FOLL_TOUCH)
>> +             touch_pmd(vma, addr, pmd);
>> +
>> +     /*
>> +      * device mapped pages can only be returned if the
>> +      * caller will manage the page reference count.
>> +      */
>> +     if (!(flags & FOLL_GET))
>> +             return ERR_PTR(-EEXIST);
>> +
>> +     pfn += (addr & ~PMD_MASK) >> PAGE_SHIFT;
>> +     pgmap = get_dev_pagemap(pfn, NULL);
>> +     if (!pgmap)
>> +             return ERR_PTR(-EFAULT);
>> +     page = pfn_to_page(pfn);
>> +     get_page(page);
>> +     put_dev_pagemap(pgmap);
>> +
>> +     return page;
>> +}
>
> hm, so device pages can be huge.  How does this play with get_page()'s
> assumption that the pages cannot be compound?

We don't need to track the pages as a compound unit because they'll
never hit mm paths that care about the distinction.  They are
effectively never "onlined".

> And again, this is bloating up the kernel for not-widely-used stuff.

I suspect the ability to compile it out is little comfort since we're
looking to get CONFIG_ZONE_DEVICE enabled by default in major distros.
If that's the case I'm wiling to entertain the coarse pinning route.
We can always circle back for the finer grained option if a problem
arises, but let me know if CONFIG_ZONE_DEVICE=n was all you were
looking for...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
