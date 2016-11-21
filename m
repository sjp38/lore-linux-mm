Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9981A6B04C1
	for <linux-mm@kvack.org>; Sun, 20 Nov 2016 21:29:31 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id i88so198712279pfk.3
        for <linux-mm@kvack.org>; Sun, 20 Nov 2016 18:29:31 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id n4si20122891pfn.9.2016.11.20.18.29.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Nov 2016 18:29:30 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id 3so27042061pgd.0
        for <linux-mm@kvack.org>; Sun, 20 Nov 2016 18:29:29 -0800 (PST)
Subject: Re: [HMM v13 08/18] mm/hmm: heterogeneous memory management (HMM for
 short)
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-9-git-send-email-jglisse@redhat.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <72428ecc-33fa-19d1-5376-cde331a4396f@gmail.com>
Date: Mon, 21 Nov 2016 13:29:23 +1100
MIME-Version: 1.0
In-Reply-To: <1479493107-982-9-git-send-email-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>



On 19/11/16 05:18, JA(C)rA'me Glisse wrote:
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
> + *
> + * Any CPU page table update that conflict with a range lock will wait until
> + * range is unlock. This garanty proper serialization of CPU and device page
> + * table update.
> + *
> + *
> + * Device memory:
> + *
> + * HMM provides helpers to help leverage device memory either addressable like
> + * regular memory by the CPU or un-addressable at all. In both case the device
> + * memory is associated to dedicated structs page (which are allocated like for
> + * hotplug memory). Device memory management is under the responsability of the
> + * device driver. HMM only allocate and initialize the struct pages associated
> + * with the device memory.
> + *
> + * Allocating struct page for device memory allow to use device memory allmost
> + * like any regular memory. Unlike regular memory it can not be added to the
> + * lru, nor can any memory allocation can use device memory directly. Device
> + * memory will only end up to be use in a process if device driver migrate some
				   in use 
> + * of the process memory from regular memory to device memory.
> + *

A process can never directly allocate device memory?

> + *
> + * Migration:
> + *
> + * Existing memory migration mechanism (mm/migrate.c) does not allow to use
> + * something else than the CPU to copy from source to destination memory. More
> + * over existing code is not tailor to drive migration from process virtual
				tailored
> + * address rather than from list of pages. Finaly the migration flow does not
					      Finally 
> + * allow for graceful failure at different step of the migration process.
> + *
> + * HMM solves all of the above though simple API :
> + *
> + *      hmm_vma_migrate(vma, start, end, ops);
> + *
> + * With ops struct providing 2 callback alloc_and_copy() which allocated the
> + * destination memory and initialize it using source memory. Migration can fail
> + * after this step and thus last callback finalize_and_map() allow the device
> + * driver to know which page were successfully migrated and which were not.
> + *
> + * This can easily be use outside of HMM intended use case.
> + *

I think it is a good API to have

> + *
> + * This header file contain all the API related to this 3 functionality and
> + * each functions and struct are more thouroughly documented in below comments.
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
		      uses
> + *
> + * Flags:
> + * HMM_PFN_VALID: pfn is valid
> + * HMM_PFN_WRITE: CPU page table have the write permission set
				    has
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

What is pfn_to_pfn? I presume it means CPU PFN to device PFN
or is it the reverse? Please add some comments

> +static inline hmm_pfn_t hmm_pfn_from_page(struct page *page)
> +{
> +	return (page_to_pfn(page) << HMM_PFN_SHIFT) | HMM_PFN_VALID;
> +}
> +
> +static inline hmm_pfn_t hmm_pfn_from_pfn(unsigned long pfn)
> +{
> +	return (pfn << HMM_PFN_SHIFT) | HMM_PFN_VALID;
> +}
> +

Same as above

> +
> +/* Below are for HMM internal use only ! Not to be use by device driver ! */
> +void hmm_mm_destroy(struct mm_struct *mm);
> +
> +#else /* IS_ENABLED(CONFIG_HMM) */
> +
> +/* Below are for HMM internal use only ! Not to be use by device driver ! */
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

It would be nice to split this into HMM, HMM_MIGRATE and HMM_MIRROR

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
> +
> +/*
> + * hmm_register - register HMM against an mm (HMM internal)
> + *
> + * @mm: mm struct to attach to
> + *
> + * This is not intended to be use directly by device driver but by other HMM
> + * component. It allocates an HMM struct if mm does not have one and initialize
> + * it.
> + */
> +static struct hmm *hmm_register(struct mm_struct *mm)
> +{
> +	struct hmm *hmm = NULL;
> +
> +	if (!mm->hmm) {
> +		hmm = kmalloc(sizeof(*hmm), GFP_KERNEL);
> +		if (!hmm)
> +			return NULL;
> +		hmm->mm = mm;
> +	}
> +
> +	spin_lock(&mm->page_table_lock);
> +	if (!mm->hmm)
> +		/*
> +		 * The hmm struct can only be free once mm_struct goes away
> +		 * hence we should always have pre-allocated an new hmm struct
> +		 * above.
> +		 */
> +		mm->hmm = hmm;
> +	else if (hmm)
> +		kfree(hmm);
> +	hmm = mm->hmm;
> +	spin_unlock(&mm->page_table_lock);
> +
> +	return hmm;
> +}
> +
> +void hmm_mm_destroy(struct mm_struct *mm)
> +{
> +	struct hmm *hmm;
> +
> +	/*
> +	 * We should not need to lock here as no one should be able to register
> +	 * a new HMM while an mm is being destroy. But just to be safe ...
> +	 */
> +	spin_lock(&mm->page_table_lock);
> +	hmm = mm->hmm;
> +	mm->hmm = NULL;
> +	spin_unlock(&mm->page_table_lock);
> +	if (!hmm)
> +		return;
> +

kfree can deal with NULL pointers, you can remove the if check

> +	kfree(hmm);
> +}
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
