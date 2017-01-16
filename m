Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 28F156B0038
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 14:31:42 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id 73so32843282otj.1
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 11:31:42 -0800 (PST)
Received: from mail-ot0-x233.google.com (mail-ot0-x233.google.com. [2607:f8b0:4003:c0f::233])
        by mx.google.com with ESMTPS id u74si9009151oif.122.2017.01.16.11.31.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 11:31:40 -0800 (PST)
Received: by mail-ot0-x233.google.com with SMTP id 104so49120294otd.3
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 11:31:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170116151713.GA4182@redhat.com>
References: <1484238642-10674-1-git-send-email-jglisse@redhat.com>
 <1484238642-10674-5-git-send-email-jglisse@redhat.com> <CAPcyv4gnXyxHGitBCLbksy8PnHtePQ8260DKiF7CX8FXj2CtFQ@mail.gmail.com>
 <20170116151713.GA4182@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 16 Jan 2017 11:31:39 -0800
Message-ID: <CAPcyv4jajtY4Q1PtPe9Jr4PwYUPAxhaGBno7tmt+KraSwCNswQ@mail.gmail.com>
Subject: Re: [HMM v16 04/15] mm/ZONE_DEVICE/unaddressable: add support for
 un-addressable device memory v2
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Mon, Jan 16, 2017 at 7:17 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> On Sun, Jan 15, 2017 at 11:05:43PM -0800, Dan Williams wrote:
>> On Thu, Jan 12, 2017 at 8:30 AM, J=C3=A9r=C3=B4me Glisse <jglisse@redhat=
.com> wrote:
>> > This add support for un-addressable device memory. Such memory is hotp=
luged
>> > only so we can have struct page but we should never map them as such m=
emory
>> > can not be accessed by CPU. For that reason it uses a special swap ent=
ry for
>> > CPU page table entry.
>> >
>> > This patch implement all the logic from special swap type to handling =
CPU
>> > page fault through a callback specified in the ZONE_DEVICE pgmap struc=
t.
>> >
>> > Architecture that wish to support un-addressable device memory should =
make
>> > sure to never populate the kernel linar mapping for the physical range=
.
>> >
>> > This feature potentially breaks memory hotplug unless every driver usi=
ng it
>> > magically predicts the future addresses of where memory will be hotplu=
gged.
>> >
>> > Changed since v1:
>> >   - Add unaddressable memory resource descriptor enum
>> >   - Explain why memory hotplug can fail because of un-addressable memo=
ry
>>
>> How can we merge this with a known potential regression?
>
> This only affect people using HMM it does not affect people that do not
> use it. Like i said for time being people that want HMM are ok with that.
> I haven't look yet on how to allow struct page about MAX_PHYSMEM_BITS
>
>>
>> >
>> > Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>> > Cc: Dan Williams <dan.j.williams@intel.com>
>> > Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
>> > ---
>> >  drivers/dax/pmem.c                |  4 +--
>> >  drivers/nvdimm/pmem.c             |  6 ++--
>> >  fs/proc/task_mmu.c                | 10 +++++-
>> >  include/linux/ioport.h            |  1 +
>> >  include/linux/memory_hotplug.h    |  7 ++++
>> >  include/linux/memremap.h          | 29 +++++++++++++++--
>> >  include/linux/swap.h              | 18 +++++++++--
>> >  include/linux/swapops.h           | 67 ++++++++++++++++++++++++++++++=
+++++++++
>> >  kernel/memremap.c                 | 43 +++++++++++++++++++++++--
>> >  mm/Kconfig                        | 12 +++++++
>> >  mm/memory.c                       | 64 ++++++++++++++++++++++++++++++=
++++++-
>> >  mm/memory_hotplug.c               | 10 ++++--
>> >  mm/mprotect.c                     | 12 +++++++
>> >  tools/testing/nvdimm/test/iomap.c |  3 +-
>> >  14 files changed, 269 insertions(+), 17 deletions(-)
>> >
>> > diff --git a/drivers/dax/pmem.c b/drivers/dax/pmem.c
>> > index 66af7b1..c50b58d 100644
>> > --- a/drivers/dax/pmem.c
>> > +++ b/drivers/dax/pmem.c
>> > @@ -111,8 +111,8 @@ static int dax_pmem_probe(struct device *dev)
>> >         if (rc)
>> >                 return rc;
>> >
>> > -       addr =3D devm_memremap_pages(dev, &res, &dax_pmem->ref,
>> > -                                  altmap, NULL, NULL);
>> > +       addr =3D devm_memremap_pages(dev, &res, &dax_pmem->ref, altmap=
,
>> > +                                  NULL, NULL, NULL, NULL, MEMORY_DEVI=
CE);
>> >         if (IS_ERR(addr))
>> >                 return PTR_ERR(addr);
>> >
>> > diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
>> > index f2f1904..8166a56 100644
>> > --- a/drivers/nvdimm/pmem.c
>> > +++ b/drivers/nvdimm/pmem.c
>> > @@ -282,7 +282,8 @@ static int pmem_attach_disk(struct device *dev,
>> >         pmem->pfn_flags =3D PFN_DEV;
>> >         if (is_nd_pfn(dev)) {
>> >                 addr =3D devm_memremap_pages(dev, &pfn_res, &q->q_usag=
e_counter,
>> > -                                          altmap, NULL, NULL);
>> > +                                          altmap, NULL, NULL, NULL,
>> > +                                          NULL, MEMORY_DEVICE);
>> >                 pfn_sb =3D nd_pfn->pfn_sb;
>> >                 pmem->data_offset =3D le64_to_cpu(pfn_sb->dataoff);
>> >                 pmem->pfn_pad =3D resource_size(res) - resource_size(&=
pfn_res);
>> > @@ -292,7 +293,8 @@ static int pmem_attach_disk(struct device *dev,
>> >         } else if (pmem_should_map_pages(dev)) {
>> >                 addr =3D devm_memremap_pages(dev, &nsio->res,
>> >                                            &q->q_usage_counter,
>> > -                                          NULL, NULL, NULL);
>> > +                                          NULL, NULL, NULL, NULL,
>> > +                                          NULL, MEMORY_DEVICE);
>> >                 pmem->pfn_flags |=3D PFN_MAP;
>> >         } else
>> >                 addr =3D devm_memremap(dev, pmem->phys_addr,
>> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
>> > index 958f325..9a6ab71 100644
>> > --- a/fs/proc/task_mmu.c
>> > +++ b/fs/proc/task_mmu.c
>> > @@ -535,8 +535,11 @@ static void smaps_pte_entry(pte_t *pte, unsigned =
long addr,
>> >                         } else {
>> >                                 mss->swap_pss +=3D (u64)PAGE_SIZE << P=
SS_SHIFT;
>> >                         }
>> > -               } else if (is_migration_entry(swpent))
>> > +               } else if (is_migration_entry(swpent)) {
>> >                         page =3D migration_entry_to_page(swpent);
>> > +               } else if (is_device_entry(swpent)) {
>> > +                       page =3D device_entry_to_page(swpent);
>> > +               }
>> >         } else if (unlikely(IS_ENABLED(CONFIG_SHMEM) && mss->check_shm=
em_swap
>> >                                                         && pte_none(*p=
te))) {
>> >                 page =3D find_get_entry(vma->vm_file->f_mapping,
>> > @@ -699,6 +702,8 @@ static int smaps_hugetlb_range(pte_t *pte, unsigne=
d long hmask,
>> >
>> >                 if (is_migration_entry(swpent))
>> >                         page =3D migration_entry_to_page(swpent);
>> > +               if (is_device_entry(swpent))
>> > +                       page =3D device_entry_to_page(swpent);
>> >         }
>> >         if (page) {
>> >                 int mapcount =3D page_mapcount(page);
>> > @@ -1182,6 +1187,9 @@ static pagemap_entry_t pte_to_pagemap_entry(stru=
ct pagemapread *pm,
>> >                 flags |=3D PM_SWAP;
>> >                 if (is_migration_entry(entry))
>> >                         page =3D migration_entry_to_page(entry);
>> > +
>> > +               if (is_device_entry(entry))
>> > +                       page =3D device_entry_to_page(entry);
>> >         }
>> >
>> >         if (page && !PageAnon(page))
>> > diff --git a/include/linux/ioport.h b/include/linux/ioport.h
>> > index 6230064..d154a18 100644
>> > --- a/include/linux/ioport.h
>> > +++ b/include/linux/ioport.h
>> > @@ -130,6 +130,7 @@ enum {
>> >         IORES_DESC_ACPI_NV_STORAGE              =3D 3,
>> >         IORES_DESC_PERSISTENT_MEMORY            =3D 4,
>> >         IORES_DESC_PERSISTENT_MEMORY_LEGACY     =3D 5,
>> > +       IORES_DESC_UNADDRESSABLE_MEMORY         =3D 6,
>> >  };
>> >
>> >  /* helpers to define resources */
>> > diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hot=
plug.h
>> > index 3f50eb8..e7c5dc6 100644
>> > --- a/include/linux/memory_hotplug.h
>> > +++ b/include/linux/memory_hotplug.h
>> > @@ -285,15 +285,22 @@ extern int zone_for_memory(int nid, u64 start, u=
64 size, int zone_default,
>> >   * never relied on struct page migration so far and new user of might=
 also
>> >   * prefer avoiding struct page migration.
>> >   *
>> > + * For device memory (which use ZONE_DEVICE) we want differentiate be=
tween CPU
>> > + * accessible memory (persitent memory, device memory on an architect=
ure with a
>> > + * system bus that allow transparent access to device memory) and una=
ddressable
>> > + * memory (device memory that can not be accessed by CPU directly).
>> > + *
>> >   * New non device memory specific flags can be added if ever needed.
>> >   *
>> >   * MEMORY_REGULAR: regular system memory
>> >   * DEVICE_MEMORY: device memory create a ZONE_DEVICE zone for it
>> >   * DEVICE_MEMORY_ALLOW_MIGRATE: page in that device memory ca be migr=
ated
>> > + * MEMORY_DEVICE_UNADDRESSABLE: un-addressable memory (CPU can not ac=
cess it)
>> >   */
>> >  #define MEMORY_NORMAL 0
>> >  #define MEMORY_DEVICE (1 << 0)
>> >  #define MEMORY_DEVICE_ALLOW_MIGRATE (1 << 1)
>> > +#define MEMORY_DEVICE_UNADDRESSABLE (1 << 2)
>> >
>> >  extern int arch_add_memory(int nid, u64 start, u64 size, int flags);
>> >  extern int offline_pages(unsigned long start_pfn, unsigned long nr_pa=
ges);
>> > diff --git a/include/linux/memremap.h b/include/linux/memremap.h
>> > index 582561f..4b9f02c 100644
>> > --- a/include/linux/memremap.h
>> > +++ b/include/linux/memremap.h
>> > @@ -35,31 +35,42 @@ static inline struct vmem_altmap *to_vmem_altmap(u=
nsigned long memmap_start)
>> >  }
>> >  #endif
>> >
>> > +typedef int (*dev_page_fault_t)(struct vm_area_struct *vma,
>> > +                               unsigned long addr,
>> > +                               struct page *page,
>> > +                               unsigned flags,
>> > +                               pmd_t *pmdp);
>> >  typedef void (*dev_page_free_t)(struct page *page, void *data);
>> >
>> >  /**
>> >   * struct dev_pagemap - metadata for ZONE_DEVICE mappings
>> > + * @page_fault: callback when CPU fault on an un-addressable device p=
age
>> >   * @page_free: free page callback when page refcount reach 1
>> >   * @altmap: pre-allocated/reserved memory for vmemmap allocations
>> >   * @res: physical address range covered by @ref
>> >   * @ref: reference count that pins the devm_memremap_pages() mapping
>> >   * @dev: host device of the mapping for debug
>> >   * @data: privata data pointer for page_free
>> > + * @flags: device memory flags (look for MEMORY_DEVICE_* memory_hotpl=
ug.h)
>> >   */
>> >  struct dev_pagemap {
>> > +       dev_page_fault_t page_fault;
>> >         dev_page_free_t page_free;
>> >         struct vmem_altmap *altmap;
>> >         const struct resource *res;
>> >         struct percpu_ref *ref;
>> >         struct device *dev;
>> >         void *data;
>> > +       int flags;
>> >  };
>>
>> dev_pagemap is only meant for get_user_pages() to do lookups of ptes
>> with _PAGE_DEVMAP and take a reference against the hosting device..
>
> And i want to build on top of that to extend _PAGE_DEVMAP to support
> a new usecase for unaddressable device memory.
>
>>
>> Why can't HMM use the typical vm_operations_struct fault path and push
>> more of these details to a driver rather than the core?
>
> Because the vm_operations_struct has nothing to do with the device.
> We are talking about regular vma here. Think malloc, mmap, share
> memory, ...  not about mmap(/dev/thedevice,...)
>
> So the vm_operations_struct is never under device control and we can
> not, nor want to, rely on that.

Can you explain more what's behind that "can not, nor want to"
statement? It seems to me that any awkwardness of moving to a
standalone device file interface is less than a maintaining a new /
parallel mm fault path through dev_pagemap.

>
> So what we looking for here is struct page that can behave mostly
> like anyother except that we do not want to allow GUP to take a
> reference almost exactly what ZONE_DEVICE already provide.
>
> So do you have any fundamental objections to this patchset ? And if
> so, how do you propose i solve the problem i am trying to address ?
> Because hardware exist today and without something like HMM we will
> not be able to support such hardware.

My pushback stems from it being a completely different use case for
devm_memremap_pages(), as evidenced by it growing from 4 arguments to
9, and the ongoing maintenance overhead of understanding HMM
requirements when updating the pmem usage of ZONE_DEVICE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
