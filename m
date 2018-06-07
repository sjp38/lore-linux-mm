Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D8A76B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 00:22:51 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id v71-v6so3917529oie.20
        for <linux-mm@kvack.org>; Wed, 06 Jun 2018 21:22:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f67-v6sor4265904oia.136.2018.06.06.21.22.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Jun 2018 21:22:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <152815395775.39010.9355109660470832490.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152815389835.39010.13253559944508110923.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152815395775.39010.9355109660470832490.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 6 Jun 2018 21:22:48 -0700
Message-ID: <CAPcyv4hPTqE0ODM7isZxcE6cbB3X4E6fbVR19fvWT3K77mPSLA@mail.gmail.com>
Subject: Re: [PATCH v3 11/12] mm, memory_failure: Teach memory_failure() about
 dev_pagemap pages
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm <linux-nvdimm@lists.01.org>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Mon, Jun 4, 2018 at 4:12 PM, Dan Williams <dan.j.williams@intel.com> wro=
te:
>     mce: Uncorrected hardware memory error in user-access at af34214200
>     {1}[Hardware Error]: It has been corrected by h/w and requires no fur=
ther action
>     mce: [Hardware Error]: Machine check events logged
>     {1}[Hardware Error]: event severity: corrected
>     Memory failure: 0xaf34214: reserved kernel page still referenced by 1=
 users
>     [..]
>     Memory failure: 0xaf34214: recovery action for reserved kernel page: =
Failed
>     mce: Memory error not recovered
>
> In contrast to typical memory, dev_pagemap pages may be dax mapped. With
> dax there is no possibility to map in another page dynamically since dax
> establishes 1:1 physical address to file offset associations. Also
> dev_pagemap pages associated with NVDIMM / persistent memory devices can
> internal remap/repair addresses with poison. While memory_failure()
> assumes that it can discard typical poisoned pages and keep them
> unmapped indefinitely, dev_pagemap pages may be returned to service
> after the error is cleared.
>
> Teach memory_failure() to detect and handle MEMORY_DEVICE_HOST
> dev_pagemap pages that have poison consumed by userspace. Mark the
> memory as UC instead of unmapping it completely to allow ongoing access
> via the device driver (nd_pmem). Later, nd_pmem will grow support for
> marking the page back to WB when the error is cleared.
>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Matthew Wilcox <mawilcox@microsoft.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Naoya, your thoughts on this patch? It is passing my unit tests for
filesystem-dax and device-dax.

> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  include/linux/mm.h  |    1
>  mm/memory-failure.c |  145 +++++++++++++++++++++++++++++++++++++++++++++=
++++++
>  2 files changed, 146 insertions(+)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 1ac1f06a4be6..566c972e03e7 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2669,6 +2669,7 @@ enum mf_action_page_type {
>         MF_MSG_TRUNCATED_LRU,
>         MF_MSG_BUDDY,
>         MF_MSG_BUDDY_2ND,
> +       MF_MSG_DAX,
>         MF_MSG_UNKNOWN,
>  };
>
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index b6efb78ba49b..de0bc897d6e7 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -55,6 +55,7 @@
>  #include <linux/hugetlb.h>
>  #include <linux/memory_hotplug.h>
>  #include <linux/mm_inline.h>
> +#include <linux/memremap.h>
>  #include <linux/kfifo.h>
>  #include <linux/ratelimit.h>
>  #include "internal.h"
> @@ -531,6 +532,7 @@ static const char * const action_page_types[] =3D {
>         [MF_MSG_TRUNCATED_LRU]          =3D "already truncated LRU page",
>         [MF_MSG_BUDDY]                  =3D "free buddy page",
>         [MF_MSG_BUDDY_2ND]              =3D "free buddy page (2nd try)",
> +       [MF_MSG_DAX]                    =3D "dax page",
>         [MF_MSG_UNKNOWN]                =3D "unknown page",
>  };
>
> @@ -1132,6 +1134,144 @@ static int memory_failure_hugetlb(unsigned long p=
fn, int flags)
>         return res;
>  }
>
> +static unsigned long dax_mapping_size(struct address_space *mapping,
> +               struct page *page)
> +{
> +       pgoff_t pgoff =3D page_to_pgoff(page);
> +       struct vm_area_struct *vma;
> +       unsigned long size =3D 0;
> +
> +       i_mmap_lock_read(mapping);
> +       xa_lock_irq(&mapping->i_pages);
> +       /* validate that @page is still linked to @mapping */
> +       if (page->mapping !=3D mapping) {
> +               xa_unlock_irq(&mapping->i_pages);
> +               i_mmap_unlock_read(mapping);
> +                       return 0;
> +       }
> +       vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
> +               unsigned long address =3D vma_address(page, vma);
> +               pgd_t *pgd;
> +               p4d_t *p4d;
> +               pud_t *pud;
> +               pmd_t *pmd;
> +               pte_t *pte;
> +
> +               pgd =3D pgd_offset(vma->vm_mm, address);
> +               if (!pgd_present(*pgd))
> +                       continue;
> +               p4d =3D p4d_offset(pgd, address);
> +               if (!p4d_present(*p4d))
> +                       continue;
> +               pud =3D pud_offset(p4d, address);
> +               if (!pud_present(*pud))
> +                       continue;
> +               if (pud_devmap(*pud)) {
> +                       size =3D PUD_SIZE;
> +                       break;
> +               }
> +               pmd =3D pmd_offset(pud, address);
> +               if (!pmd_present(*pmd))
> +                       continue;
> +               if (pmd_devmap(*pmd)) {
> +                       size =3D PMD_SIZE;
> +                       break;
> +               }
> +               pte =3D pte_offset_map(pmd, address);
> +               if (!pte_present(*pte))
> +                       continue;
> +               if (pte_devmap(*pte)) {
> +                       size =3D PAGE_SIZE;
> +                       break;
> +               }
> +       }
> +       xa_unlock_irq(&mapping->i_pages);
> +       i_mmap_unlock_read(mapping);
> +
> +       return size;
> +}
> +
> +static int memory_failure_dev_pagemap(unsigned long pfn, int flags,
> +               struct dev_pagemap *pgmap)
> +{
> +       struct page *page =3D pfn_to_page(pfn);
> +       const bool unmap_success =3D true;
> +       struct address_space *mapping;
> +       unsigned long size;
> +       LIST_HEAD(tokill);
> +       int rc =3D -EBUSY;
> +       loff_t start;
> +
> +       /*
> +        * Prevent the inode from being freed while we are interrogating
> +        * the address_space, typically this would be handled by
> +        * lock_page(), but dax pages do not use the page lock.
> +        */
> +       rcu_read_lock();
> +       mapping =3D page->mapping;
> +       if (!mapping) {
> +               rcu_read_unlock();
> +               goto out;
> +       }
> +       if (!igrab(mapping->host)) {
> +               mapping =3D NULL;
> +               rcu_read_unlock();
> +               goto out;
> +       }
> +       rcu_read_unlock();
> +
> +       if (hwpoison_filter(page)) {
> +               rc =3D 0;
> +               goto out;
> +       }
> +
> +       switch (pgmap->type) {
> +       case MEMORY_DEVICE_PRIVATE:
> +       case MEMORY_DEVICE_PUBLIC:
> +               /*
> +                * TODO: Handle HMM pages which may need coordination
> +                * with device-side memory.
> +                */
> +               goto out;
> +       default:
> +               break;
> +       }
> +
> +       /*
> +        * If the page is not mapped in userspace then report it as
> +        * unhandled.
> +        */
> +       size =3D dax_mapping_size(mapping, page);
> +       if (!size) {
> +               pr_err("Memory failure: %#lx: failed to unmap page\n", pf=
n);
> +               goto out;
> +       }
> +
> +       SetPageHWPoison(page);
> +
> +       /*
> +        * Unlike System-RAM there is no possibility to swap in a
> +        * different physical page at a given virtual address, so all
> +        * userspace consumption of ZONE_DEVICE memory necessitates
> +        * SIGBUS (i.e. MF_MUST_KILL)
> +        */
> +       flags |=3D MF_ACTION_REQUIRED | MF_MUST_KILL;
> +       collect_procs(mapping, page, &tokill, flags & MF_ACTION_REQUIRED)=
;
> +
> +       start =3D (page->index << PAGE_SHIFT) & ~(size - 1);
> +       unmap_mapping_range(page->mapping, start, start + size, 0);
> +
> +       kill_procs(&tokill, flags & MF_MUST_KILL, !unmap_success, ilog2(s=
ize),
> +                       mapping, page, flags);
> +       rc =3D 0;
> +out:
> +       if (mapping)
> +               iput(mapping->host);
> +       put_dev_pagemap(pgmap);
> +       action_result(pfn, MF_MSG_DAX, rc ? MF_FAILED : MF_RECOVERED);
> +       return rc;
> +}
> +
>  /**
>   * memory_failure - Handle memory failure of a page.
>   * @pfn: Page Number of the corrupted page
> @@ -1154,6 +1294,7 @@ int memory_failure(unsigned long pfn, int flags)
>         struct page *p;
>         struct page *hpage;
>         struct page *orig_head;
> +       struct dev_pagemap *pgmap;
>         int res;
>         unsigned long page_flags;
>
> @@ -1166,6 +1307,10 @@ int memory_failure(unsigned long pfn, int flags)
>                 return -ENXIO;
>         }
>
> +       pgmap =3D get_dev_pagemap(pfn, NULL);
> +       if (pgmap)
> +               return memory_failure_dev_pagemap(pfn, flags, pgmap);
> +
>         p =3D pfn_to_page(pfn);
>         if (PageHuge(p))
>                 return memory_failure_hugetlb(pfn, flags);
>
