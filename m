Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD0F18E0003
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 03:34:00 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id v3so1472343itf.4
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 00:34:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b191sor5432975itc.22.2018.12.20.00.33.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 00:33:59 -0800 (PST)
MIME-Version: 1.0
References: <20170817000548.32038-1-jglisse@redhat.com> <20170817000548.32038-8-jglisse@redhat.com>
In-Reply-To: <20170817000548.32038-8-jglisse@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 20 Dec 2018 00:33:47 -0800
Message-ID: <CAA9_cmeag7n4yeiP6pYZSz80KyxqfwbsXJCWvyNE4PSaxCKA3A@mail.gmail.com>
Subject: Re: [HMM-v25 07/19] mm/ZONE_DEVICE: new type of ZONE_DEVICE for
 unaddressable memory v5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Wed, Aug 16, 2017 at 5:06 PM J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com=
> wrote:
>
> HMM (heterogeneous memory management) need struct page to support migrati=
on
> from system main memory to device memory.  Reasons for HMM and migration =
to
> device memory is explained with HMM core patch.
>
> This patch deals with device memory that is un-addressable memory (ie CPU
> can not access it). Hence we do not want those struct page to be manage
> like regular memory. That is why we extend ZONE_DEVICE to support differe=
nt
> types of memory.
>
> A persistent memory type is define for existing user of ZONE_DEVICE and a
> new device un-addressable type is added for the un-addressable memory typ=
e.
> There is a clear separation between what is expected from each memory typ=
e
> and existing user of ZONE_DEVICE are un-affected by new requirement and n=
ew
> use of the un-addressable type. All specific code path are protect with
> test against the memory type.
>
> Because memory is un-addressable we use a new special swap type for when
> a page is migrated to device memory (this reduces the number of maximum
> swap file).
>
> The main two additions beside memory type to ZONE_DEVICE is two callbacks=
.
> First one, page_free() is call whenever page refcount reach 1 (which mean=
s
> the page is free as ZONE_DEVICE page never reach a refcount of 0). This
> allow device driver to manage its memory and associated struct page.
>
> The second callback page_fault() happens when there is a CPU access to
> an address that is back by a device page (which are un-addressable by the
> CPU). This callback is responsible to migrate the page back to system
> main memory. Device driver can not block migration back to system memory,
> HMM make sure that such page can not be pin into device memory.
>
> If device is in some error condition and can not migrate memory back then
> a CPU page fault to device memory should end with SIGBUS.
>
> Changed since v4:
>   - s/DEVICE_PUBLIC/DEVICE_HOST (to free DEVICE_PUBLIC for HMM-CDM)
> Changed since v3:
>   - fix comments that was still using UNADDRESSABLE as keyword
>   - kernel configuration simplification
> Changed since v2:
>   - s/DEVICE_UNADDRESSABLE/DEVICE_PRIVATE
> Changed since v1:
>   - rename to device private memory (from device unaddressable)
>
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Acked-by: Dan Williams <dan.j.williams@intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
[..]
>  fs/proc/task_mmu.c       |  7 +++++
>  include/linux/ioport.h   |  1 +
>  include/linux/memremap.h | 73 ++++++++++++++++++++++++++++++++++++++++++=
++++++
>  include/linux/mm.h       | 12 ++++++++
>  include/linux/swap.h     | 24 ++++++++++++++--
>  include/linux/swapops.h  | 68 ++++++++++++++++++++++++++++++++++++++++++=
++
>  kernel/memremap.c        | 34 ++++++++++++++++++++++
>  mm/Kconfig               | 11 +++++++-
>  mm/memory.c              | 61 ++++++++++++++++++++++++++++++++++++++++
>  mm/memory_hotplug.c      | 10 +++++--
>  mm/mprotect.c            | 14 ++++++++++
>  11 files changed, 309 insertions(+), 6 deletions(-)
>
[..]
> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> index 93416196ba64..8e164ec9eed0 100644
> --- a/include/linux/memremap.h
> +++ b/include/linux/memremap.h
> @@ -4,6 +4,8 @@
>  #include <linux/ioport.h>
>  #include <linux/percpu-refcount.h>
>
> +#include <asm/pgtable.h>
> +

So it turns out, over a year later, that this include was a mistake
and makes the build fragile.

>  struct resource;
>  struct device;
>
[..]
> +typedef int (*dev_page_fault_t)(struct vm_area_struct *vma,
> +                               unsigned long addr,
> +                               const struct page *page,
> +                               unsigned int flags,
> +                               pmd_t *pmdp);

I recently included this file somewhere that did not have a pile of
other mm headers included and 0day reports:

  In file included from arch/m68k/include/asm/pgtable_mm.h:148:0,
                    from arch/m68k/include/asm/pgtable.h:5,
                    from include/linux/memremap.h:7,
                    from drivers//dax/bus.c:3:
   arch/m68k/include/asm/motorola_pgtable.h: In function 'pgd_offset':
>> arch/m68k/include/asm/motorola_pgtable.h:199:11: error: dereferencing po=
inter to incomplete type 'const struct mm_struct'
     return mm->pgd + pgd_index(address);
              ^~
I assume this pulls in the entirety of pgtable.h just to get the pmd_t
definition?

> +typedef void (*dev_page_free_t)(struct page *page, void *data);
> +
>  /**
>   * struct dev_pagemap - metadata for ZONE_DEVICE mappings
> + * @page_fault: callback when CPU fault on an unaddressable device page
> + * @page_free: free page callback when page refcount reaches 1
>   * @altmap: pre-allocated/reserved memory for vmemmap allocations
>   * @res: physical address range covered by @ref
>   * @ref: reference count that pins the devm_memremap_pages() mapping
>   * @dev: host device of the mapping for debug
> + * @data: private data pointer for page_free()
> + * @type: memory type: see MEMORY_* in memory_hotplug.h
>   */
>  struct dev_pagemap {
> +       dev_page_fault_t page_fault;

Rather than try to figure out how to forward declare pmd_t, how about
just move dev_page_fault_t out of the generic dev_pagemap and into the
HMM specific container structure? This should be straightfoward on top
of the recent refactor.
