Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8326B6B0069
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 23:03:45 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x23so3604135pgx.6
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 20:03:45 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d14si31681993pfj.6.2016.11.22.20.03.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 20:03:44 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAN3xEEo058659
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 23:03:43 -0500
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26vvrndb3m-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 23:03:43 -0500
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 23 Nov 2016 14:03:40 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 8F48C2CE8054
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 15:03:38 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAN43cu950987058
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 15:03:38 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAN43cxu015870
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 15:03:38 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: Re: [HMM v13 08/18] mm/hmm: heterogeneous memory management (HMM for
 short)
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-9-git-send-email-jglisse@redhat.com>
Date: Wed, 23 Nov 2016 09:33:35 +0530
MIME-Version: 1.0
In-Reply-To: <1479493107-982-9-git-send-email-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Message-Id: <58351517.2060405@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On 11/18/2016 11:48 PM, JA(C)rA'me Glisse wrote:
> HMM provides 3 separate functionality :
>     - Mirroring: synchronize CPU page table and device page table
>     - Device memory: allocating struct page for device memory
>     - Migration: migrating regular memory to device memory
> 
> This patch introduces some common helpers and definitions to all of
> those 3 functionality.
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
> Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
> Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
> ---
>  MAINTAINERS              |   7 +++
>  include/linux/hmm.h      | 139 +++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/mm_types.h |   5 ++
>  kernel/fork.c            |   2 +
>  mm/Kconfig               |  11 ++++
>  mm/Makefile              |   1 +
>  mm/hmm.c                 |  86 +++++++++++++++++++++++++++++
>  7 files changed, 251 insertions(+)
>  create mode 100644 include/linux/hmm.h
>  create mode 100644 mm/hmm.c
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index f593300..41cd63d 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -5582,6 +5582,13 @@ S:	Supported
>  F:	drivers/scsi/hisi_sas/
>  F:	Documentation/devicetree/bindings/scsi/hisilicon-sas.txt
>  
> +HMM - Heterogeneous Memory Management
> +M:	JA(C)rA'me Glisse <jglisse@redhat.com>
> +L:	linux-mm@kvack.org
> +S:	Maintained
> +F:	mm/hmm*
> +F:	include/linux/hmm*
> +
>  HOST AP DRIVER
>  M:	Jouni Malinen <j@w1.fi>
>  L:	hostap@shmoo.com (subscribers-only)
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> new file mode 100644
> index 0000000..54dd529
> --- /dev/null
> +++ b/include/linux/hmm.h
> @@ -0,0 +1,139 @@
> +/*
> + * Copyright 2013 Red Hat Inc.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * Authors: JA(C)rA'me Glisse <jglisse@redhat.com>
> + */
> +/*
> + * HMM provides 3 separate functionality :
> + *   - Mirroring: synchronize CPU page table and device page table
> + *   - Device memory: allocating struct page for device memory
> + *   - Migration: migrating regular memory to device memory
> + *
> + * Each can be use independently from the others.

Small nit s/use/used/

> + *
> + *
> + * Mirroring:
> + *
> + * HMM provide helpers to mirror process address space on a device. For this it
> + * provides several helpers to order device page table update in respect to CPU
> + * page table update. Requirement is that for any given virtual address the CPU
> + * and device page table can not point to different physical page. It uses the
> + * mmu_notifier API and introduce virtual address range lock which block CPU
> + * page table update for a range while the device page table is being updated.
> + * Usage pattern is:
> + *
> + *      hmm_vma_range_lock(vma, start, end);
> + *      // snap shot CPU page table
> + *      // update device page table from snapshot
> + *      hmm_vma_range_unlock(vma, start, end);

This code block can be explained better in more detail.

> + *
> + * Any CPU page table update that conflict with a range lock will wait until
> + * range is unlock. This garanty proper serialization of CPU and device page
> + * table update.
> + *

Small typo in here      ^^^^^^^^^^^^

> + *
> + * Device memory:
> + *
> + * HMM provides helpers to help leverage device memory either addressable like
> + * regular memory by the CPU or un-addressable at all. In both case the device
> + * memory is associated to dedicated structs page (which are allocated like for
> + * hotplug memory). Device memory management is under the responsability of the

Typo in here                                               ^^^^^^^^^^^^^^^^

> + * device driver. HMM only allocate and initialize the struct pages associated
> + * with the device memory.

We should also mention that its hot plugged into the kernel as a ZONE_DEVICE
based memory.

> + *
> + * Allocating struct page for device memory allow to use device memory allmost
> + * like any regular memory. Unlike regular memory it can not be added to the
> + * lru, nor can any memory allocation can use device memory directly. Device
> + * memory will only end up to be use in a process if device driver migrate some
> + * of the process memory from regular memory to device memory.
> + *
> + *
> + * Migration:
> + *
> + * Existing memory migration mechanism (mm/migrate.c) does not allow to use
> + * something else than the CPU to copy from source to destination memory. More
> + * over existing code is not tailor to drive migration from process virtual
> + * address rather than from list of pages. Finaly the migration flow does not
> + * allow for graceful failure at different step of the migration process.

The primary reason being the fact that migrate_pages() interface handles system
memory LRU pages and at this point it cannot handle these new ZONE_DEVICE based
pages whether they are addressable or not. IIUC HMM migration API layer intends
to handle both LRU system ram pages and non LRU ZONE_DEVICE struct pages and
achieve the migration both ways. The API should also include a struct page list
based migration (like migrate_pages()) along with the proposed virtual range
based migration. So the driver can choose either approach. Going forward this
API layer should also include migration interface for the addressable ZONE_DEVICE
pages like persistent memory.

> + *
> + * HMM solves all of the above though simple API :

I guess you meant "through" instead of "though".

> + *
> + *      hmm_vma_migrate(vma, start, end, ops);
> + *
> + * With ops struct providing 2 callback alloc_and_copy() which allocated the
> + * destination memory and initialize it using source memory. Migration can fail
> + * after this step and thus last callback finalize_and_map() allow the device
> + * driver to know which page were successfully migrated and which were not.

So we have page->pgmap->free_devpage() to release the individual page back
into the device driver management during migration and also we have this ops
based finalize_and_mmap() to check on the failed instances inside a single
migration context which can contain set of pages at a time.

> + *
> + * This can easily be use outside of HMM intended use case.

Where you think this can be used outside of HMM ?

> + *
> + *
> + * This header file contain all the API related to this 3 functionality and
> + * each functions and struct are more thouroughly documented in below comments.

Typo s/thouroughly/thoroughly/

> + */
> +#ifndef LINUX_HMM_H
> +#define LINUX_HMM_H
> +
> +#include <linux/kconfig.h>
> +
> +#if IS_ENABLED(CONFIG_HMM)
> +
> +
> +/*
> + * hmm_pfn_t - HMM use its own pfn type to keep several flags per page
> + *
> + * Flags:
> + * HMM_PFN_VALID: pfn is valid
> + * HMM_PFN_WRITE: CPU page table have the write permission set
> + */
> +typedef unsigned long hmm_pfn_t;
> +
> +#define HMM_PFN_VALID (1 << 0)
> +#define HMM_PFN_WRITE (1 << 1)
> +#define HMM_PFN_SHIFT 2
> +
> +static inline struct page *hmm_pfn_to_page(hmm_pfn_t pfn)
> +{
> +	if (!(pfn & HMM_PFN_VALID))
> +		return NULL;
> +	return pfn_to_page(pfn >> HMM_PFN_SHIFT);
> +}
> +
> +static inline unsigned long hmm_pfn_to_pfn(hmm_pfn_t pfn)
> +{
> +	if (!(pfn & HMM_PFN_VALID))
> +		return -1UL;
> +	return (pfn >> HMM_PFN_SHIFT);
> +}
> +
> +static inline hmm_pfn_t hmm_pfn_from_page(struct page *page)
> +{
> +	return (page_to_pfn(page) << HMM_PFN_SHIFT) | HMM_PFN_VALID;
> +}
> +
> +static inline hmm_pfn_t hmm_pfn_from_pfn(unsigned long pfn)
> +{
> +	return (pfn << HMM_PFN_SHIFT) | HMM_PFN_VALID;
> +}

Hmm, so if we use last two bits on PFN as flags, it does reduce the number of
bits available for the actual PFN range. But given that we support maximum of
64TB on POWER (not sure about X86) we can live with this two bits going away
from the unsigned long. But what is the purpose of tracking validity and write
flag inside the PFN ?

> +
> +
> +/* Below are for HMM internal use only ! Not to be use by device driver ! */

s/use/used/

> +void hmm_mm_destroy(struct mm_struct *mm);
> +
> +#else /* IS_ENABLED(CONFIG_HMM) */
> +
> +/* Below are for HMM internal use only ! Not to be use by device driver ! */


ditto

> +static inline void hmm_mm_destroy(struct mm_struct *mm) {}
> +
> +#endif /* IS_ENABLED(CONFIG_HMM) */
> +#endif /* LINUX_HMM_H */
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 4a8aced..4effdbf 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -23,6 +23,7 @@
>  
>  struct address_space;
>  struct mem_cgroup;
> +struct hmm;
>  
>  #define USE_SPLIT_PTE_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS)
>  #define USE_SPLIT_PMD_PTLOCKS	(USE_SPLIT_PTE_PTLOCKS && \
> @@ -516,6 +517,10 @@ struct mm_struct {
>  	atomic_long_t hugetlb_usage;
>  #endif
>  	struct work_struct async_put_work;
> +#if IS_ENABLED(CONFIG_HMM)
> +	/* HMM need to track few things per mm */
> +	struct hmm *hmm;
> +#endif
>  };

hmm, so the HMM structure is one for each mm context.

>  
>  static inline void mm_init_cpumask(struct mm_struct *mm)
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 690a1aad..af0eec8 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -27,6 +27,7 @@
>  #include <linux/binfmts.h>
>  #include <linux/mman.h>
>  #include <linux/mmu_notifier.h>
> +#include <linux/hmm.h>
>  #include <linux/fs.h>
>  #include <linux/mm.h>
>  #include <linux/vmacache.h>
> @@ -702,6 +703,7 @@ void __mmdrop(struct mm_struct *mm)
>  	BUG_ON(mm == &init_mm);
>  	mm_free_pgd(mm);
>  	destroy_context(mm);
> +	hmm_mm_destroy(mm);
>  	mmu_notifier_mm_destroy(mm);
>  	check_mm(mm);
>  	free_mm(mm);
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 0a21411..be18cc2 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -289,6 +289,17 @@ config MIGRATION
>  config ARCH_ENABLE_HUGEPAGE_MIGRATION
>  	bool
>  
> +config HMM
> +	bool "Heterogeneous memory management (HMM)"
> +	depends on MMU
> +	default n
> +	help
> +	  Heterogeneous memory management, set of helpers for:
> +	    - mirroring of process address space on a device
> +	    - using device memory transparently inside a process
> +
> +	  If unsure, say N to disable HMM.
> +
>  config PHYS_ADDR_T_64BIT
>  	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
>  
> diff --git a/mm/Makefile b/mm/Makefile
> index 2ca1faf..6ac1284 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -76,6 +76,7 @@ obj-$(CONFIG_FAILSLAB) += failslab.o
>  obj-$(CONFIG_MEMORY_HOTPLUG) += memory_hotplug.o
>  obj-$(CONFIG_MEMTEST)		+= memtest.o
>  obj-$(CONFIG_MIGRATION) += migrate.o
> +obj-$(CONFIG_HMM) += hmm.o
>  obj-$(CONFIG_QUICKLIST) += quicklist.o
>  obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o khugepaged.o
>  obj-$(CONFIG_PAGE_COUNTER) += page_counter.o
> diff --git a/mm/hmm.c b/mm/hmm.c
> new file mode 100644
> index 0000000..342b596
> --- /dev/null
> +++ b/mm/hmm.c
> @@ -0,0 +1,86 @@
> +/*
> + * Copyright 2013 Red Hat Inc.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * Authors: JA(C)rA'me Glisse <jglisse@redhat.com>
> + */
> +/*
> + * Refer to include/linux/hmm.h for informations about heterogeneous memory

s/informations/information/

> + * management or HMM for short.
> + */
> +#include <linux/mm.h>
> +#include <linux/hmm.h>
> +#include <linux/slab.h>
> +#include <linux/sched.h>
> +
> +/*
> + * struct hmm - HMM per mm struct
> + *
> + * @mm: mm struct this HMM struct is bound to
> + */
> +struct hmm {
> +	struct mm_struct	*mm;
> +};

So right now its empty other than this link back to the struct mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
