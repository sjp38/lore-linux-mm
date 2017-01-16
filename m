Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3A2186B0069
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 02:05:45 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id j82so203691462oih.6
        for <linux-mm@kvack.org>; Sun, 15 Jan 2017 23:05:45 -0800 (PST)
Received: from mail-oi0-x229.google.com (mail-oi0-x229.google.com. [2607:f8b0:4003:c06::229])
        by mx.google.com with ESMTPS id u189si8218088oib.290.2017.01.15.23.05.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Jan 2017 23:05:44 -0800 (PST)
Received: by mail-oi0-x229.google.com with SMTP id w204so95242060oiw.0
        for <linux-mm@kvack.org>; Sun, 15 Jan 2017 23:05:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1484238642-10674-5-git-send-email-jglisse@redhat.com>
References: <1484238642-10674-1-git-send-email-jglisse@redhat.com> <1484238642-10674-5-git-send-email-jglisse@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 15 Jan 2017 23:05:43 -0800
Message-ID: <CAPcyv4gnXyxHGitBCLbksy8PnHtePQ8260DKiF7CX8FXj2CtFQ@mail.gmail.com>
Subject: Re: [HMM v16 04/15] mm/ZONE_DEVICE/unaddressable: add support for
 un-addressable device memory v2
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Thu, Jan 12, 2017 at 8:30 AM, J=C3=A9r=C3=B4me Glisse <jglisse@redhat.co=
m> wrote:
> This add support for un-addressable device memory. Such memory is hotplug=
ed
> only so we can have struct page but we should never map them as such memo=
ry
> can not be accessed by CPU. For that reason it uses a special swap entry =
for
> CPU page table entry.
>
> This patch implement all the logic from special swap type to handling CPU
> page fault through a callback specified in the ZONE_DEVICE pgmap struct.
>
> Architecture that wish to support un-addressable device memory should mak=
e
> sure to never populate the kernel linar mapping for the physical range.
>
> This feature potentially breaks memory hotplug unless every driver using =
it
> magically predicts the future addresses of where memory will be hotplugge=
d.
>
> Changed since v1:
>   - Add unaddressable memory resource descriptor enum
>   - Explain why memory hotplug can fail because of un-addressable memory

How can we merge this with a known potential regression?

>
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  drivers/dax/pmem.c                |  4 +--
>  drivers/nvdimm/pmem.c             |  6 ++--
>  fs/proc/task_mmu.c                | 10 +++++-
>  include/linux/ioport.h            |  1 +
>  include/linux/memory_hotplug.h    |  7 ++++
>  include/linux/memremap.h          | 29 +++++++++++++++--
>  include/linux/swap.h              | 18 +++++++++--
>  include/linux/swapops.h           | 67 +++++++++++++++++++++++++++++++++=
++++++
>  kernel/memremap.c                 | 43 +++++++++++++++++++++++--
>  mm/Kconfig                        | 12 +++++++
>  mm/memory.c                       | 64 +++++++++++++++++++++++++++++++++=
+++-
>  mm/memory_hotplug.c               | 10 ++++--
>  mm/mprotect.c                     | 12 +++++++
>  tools/testing/nvdimm/test/iomap.c |  3 +-
>  14 files changed, 269 insertions(+), 17 deletions(-)
>
> diff --git a/drivers/dax/pmem.c b/drivers/dax/pmem.c
> index 66af7b1..c50b58d 100644
> --- a/drivers/dax/pmem.c
> +++ b/drivers/dax/pmem.c
> @@ -111,8 +111,8 @@ static int dax_pmem_probe(struct device *dev)
>         if (rc)
>                 return rc;
>
> -       addr =3D devm_memremap_pages(dev, &res, &dax_pmem->ref,
> -                                  altmap, NULL, NULL);
> +       addr =3D devm_memremap_pages(dev, &res, &dax_pmem->ref, altmap,
> +                                  NULL, NULL, NULL, NULL, MEMORY_DEVICE)=
;
>         if (IS_ERR(addr))
>                 return PTR_ERR(addr);
>
> diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
> index f2f1904..8166a56 100644
> --- a/drivers/nvdimm/pmem.c
> +++ b/drivers/nvdimm/pmem.c
> @@ -282,7 +282,8 @@ static int pmem_attach_disk(struct device *dev,
>         pmem->pfn_flags =3D PFN_DEV;
>         if (is_nd_pfn(dev)) {
>                 addr =3D devm_memremap_pages(dev, &pfn_res, &q->q_usage_c=
ounter,
> -                                          altmap, NULL, NULL);
> +                                          altmap, NULL, NULL, NULL,
> +                                          NULL, MEMORY_DEVICE);
>                 pfn_sb =3D nd_pfn->pfn_sb;
>                 pmem->data_offset =3D le64_to_cpu(pfn_sb->dataoff);
>                 pmem->pfn_pad =3D resource_size(res) - resource_size(&pfn=
_res);
> @@ -292,7 +293,8 @@ static int pmem_attach_disk(struct device *dev,
>         } else if (pmem_should_map_pages(dev)) {
>                 addr =3D devm_memremap_pages(dev, &nsio->res,
>                                            &q->q_usage_counter,
> -                                          NULL, NULL, NULL);
> +                                          NULL, NULL, NULL, NULL,
> +                                          NULL, MEMORY_DEVICE);
>                 pmem->pfn_flags |=3D PFN_MAP;
>         } else
>                 addr =3D devm_memremap(dev, pmem->phys_addr,
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 958f325..9a6ab71 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -535,8 +535,11 @@ static void smaps_pte_entry(pte_t *pte, unsigned lon=
g addr,
>                         } else {
>                                 mss->swap_pss +=3D (u64)PAGE_SIZE << PSS_=
SHIFT;
>                         }
> -               } else if (is_migration_entry(swpent))
> +               } else if (is_migration_entry(swpent)) {
>                         page =3D migration_entry_to_page(swpent);
> +               } else if (is_device_entry(swpent)) {
> +                       page =3D device_entry_to_page(swpent);
> +               }
>         } else if (unlikely(IS_ENABLED(CONFIG_SHMEM) && mss->check_shmem_=
swap
>                                                         && pte_none(*pte)=
)) {
>                 page =3D find_get_entry(vma->vm_file->f_mapping,
> @@ -699,6 +702,8 @@ static int smaps_hugetlb_range(pte_t *pte, unsigned l=
ong hmask,
>
>                 if (is_migration_entry(swpent))
>                         page =3D migration_entry_to_page(swpent);
> +               if (is_device_entry(swpent))
> +                       page =3D device_entry_to_page(swpent);
>         }
>         if (page) {
>                 int mapcount =3D page_mapcount(page);
> @@ -1182,6 +1187,9 @@ static pagemap_entry_t pte_to_pagemap_entry(struct =
pagemapread *pm,
>                 flags |=3D PM_SWAP;
>                 if (is_migration_entry(entry))
>                         page =3D migration_entry_to_page(entry);
> +
> +               if (is_device_entry(entry))
> +                       page =3D device_entry_to_page(entry);
>         }
>
>         if (page && !PageAnon(page))
> diff --git a/include/linux/ioport.h b/include/linux/ioport.h
> index 6230064..d154a18 100644
> --- a/include/linux/ioport.h
> +++ b/include/linux/ioport.h
> @@ -130,6 +130,7 @@ enum {
>         IORES_DESC_ACPI_NV_STORAGE              =3D 3,
>         IORES_DESC_PERSISTENT_MEMORY            =3D 4,
>         IORES_DESC_PERSISTENT_MEMORY_LEGACY     =3D 5,
> +       IORES_DESC_UNADDRESSABLE_MEMORY         =3D 6,
>  };
>
>  /* helpers to define resources */
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplu=
g.h
> index 3f50eb8..e7c5dc6 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -285,15 +285,22 @@ extern int zone_for_memory(int nid, u64 start, u64 =
size, int zone_default,
>   * never relied on struct page migration so far and new user of might al=
so
>   * prefer avoiding struct page migration.
>   *
> + * For device memory (which use ZONE_DEVICE) we want differentiate betwe=
en CPU
> + * accessible memory (persitent memory, device memory on an architecture=
 with a
> + * system bus that allow transparent access to device memory) and unaddr=
essable
> + * memory (device memory that can not be accessed by CPU directly).
> + *
>   * New non device memory specific flags can be added if ever needed.
>   *
>   * MEMORY_REGULAR: regular system memory
>   * DEVICE_MEMORY: device memory create a ZONE_DEVICE zone for it
>   * DEVICE_MEMORY_ALLOW_MIGRATE: page in that device memory ca be migrate=
d
> + * MEMORY_DEVICE_UNADDRESSABLE: un-addressable memory (CPU can not acces=
s it)
>   */
>  #define MEMORY_NORMAL 0
>  #define MEMORY_DEVICE (1 << 0)
>  #define MEMORY_DEVICE_ALLOW_MIGRATE (1 << 1)
> +#define MEMORY_DEVICE_UNADDRESSABLE (1 << 2)
>
>  extern int arch_add_memory(int nid, u64 start, u64 size, int flags);
>  extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages=
);
> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> index 582561f..4b9f02c 100644
> --- a/include/linux/memremap.h
> +++ b/include/linux/memremap.h
> @@ -35,31 +35,42 @@ static inline struct vmem_altmap *to_vmem_altmap(unsi=
gned long memmap_start)
>  }
>  #endif
>
> +typedef int (*dev_page_fault_t)(struct vm_area_struct *vma,
> +                               unsigned long addr,
> +                               struct page *page,
> +                               unsigned flags,
> +                               pmd_t *pmdp);
>  typedef void (*dev_page_free_t)(struct page *page, void *data);
>
>  /**
>   * struct dev_pagemap - metadata for ZONE_DEVICE mappings
> + * @page_fault: callback when CPU fault on an un-addressable device page
>   * @page_free: free page callback when page refcount reach 1
>   * @altmap: pre-allocated/reserved memory for vmemmap allocations
>   * @res: physical address range covered by @ref
>   * @ref: reference count that pins the devm_memremap_pages() mapping
>   * @dev: host device of the mapping for debug
>   * @data: privata data pointer for page_free
> + * @flags: device memory flags (look for MEMORY_DEVICE_* memory_hotplug.=
h)
>   */
>  struct dev_pagemap {
> +       dev_page_fault_t page_fault;
>         dev_page_free_t page_free;
>         struct vmem_altmap *altmap;
>         const struct resource *res;
>         struct percpu_ref *ref;
>         struct device *dev;
>         void *data;
> +       int flags;
>  };

dev_pagemap is only meant for get_user_pages() to do lookups of ptes
with _PAGE_DEVMAP and take a reference against the hosting device..

Why can't HMM use the typical vm_operations_struct fault path and push
more of these details to a driver rather than the core?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
