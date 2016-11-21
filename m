Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7F2F46B04E6
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 05:58:19 -0500 (EST)
Received: by mail-yw0-f197.google.com with SMTP id l139so633790244ywe.5
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 02:58:19 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m123si4575632yba.274.2016.11.21.02.58.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 02:58:18 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uALAsJp4034117
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 05:58:18 -0500
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26uygk8c0d-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 05:58:18 -0500
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 21 Nov 2016 20:58:15 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id C766E3578053
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 21:58:12 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uALAwC0930540016
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 21:58:12 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uALAwC3r012238
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 21:58:12 +1100
Subject: Re: [HMM v13 06/18] mm/ZONE_DEVICE/unaddressable: add special swap
 for unaddressable
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-7-git-send-email-jglisse@redhat.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 21 Nov 2016 16:28:04 +0530
MIME-Version: 1.0
In-Reply-To: <1479493107-982-7-git-send-email-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Message-Id: <5832D33C.6030403@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On 11/18/2016 11:48 PM, JA(C)rA'me Glisse wrote:
> To allow use of device un-addressable memory inside a process add a
> special swap type. Also add a new callback to handle page fault on
> such entry.

IIUC this swap type is required only for the mirror cases and its
not a requirement for migration. If it's required for mirroring
purpose where we intercept each page fault, the commit message
here should clearly elaborate on that more.

> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  fs/proc/task_mmu.c       | 10 +++++++-
>  include/linux/memremap.h |  5 ++++
>  include/linux/swap.h     | 18 ++++++++++---
>  include/linux/swapops.h  | 67 ++++++++++++++++++++++++++++++++++++++++++++++++
>  kernel/memremap.c        | 14 ++++++++++
>  mm/Kconfig               | 12 +++++++++
>  mm/memory.c              | 24 +++++++++++++++++
>  mm/mprotect.c            | 12 +++++++++
>  8 files changed, 158 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 6909582..0726d39 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -544,8 +544,11 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
>  			} else {
>  				mss->swap_pss += (u64)PAGE_SIZE << PSS_SHIFT;
>  			}
> -		} else if (is_migration_entry(swpent))
> +		} else if (is_migration_entry(swpent)) {
>  			page = migration_entry_to_page(swpent);
> +		} else if (is_device_entry(swpent)) {
> +			page = device_entry_to_page(swpent);
> +		}
>  	} else if (unlikely(IS_ENABLED(CONFIG_SHMEM) && mss->check_shmem_swap
>  							&& pte_none(*pte))) {
>  		page = find_get_entry(vma->vm_file->f_mapping,
> @@ -708,6 +711,8 @@ static int smaps_hugetlb_range(pte_t *pte, unsigned long hmask,
>  
>  		if (is_migration_entry(swpent))
>  			page = migration_entry_to_page(swpent);
> +		if (is_device_entry(swpent))
> +			page = device_entry_to_page(swpent);
>  	}
>  	if (page) {
>  		int mapcount = page_mapcount(page);
> @@ -1191,6 +1196,9 @@ static pagemap_entry_t pte_to_pagemap_entry(struct pagemapread *pm,
>  		flags |= PM_SWAP;
>  		if (is_migration_entry(entry))
>  			page = migration_entry_to_page(entry);
> +
> +		if (is_device_entry(entry))
> +			page = device_entry_to_page(entry);
>  	}
>  
>  	if (page && !PageAnon(page))
> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> index b6f03e9..d584c74 100644
> --- a/include/linux/memremap.h
> +++ b/include/linux/memremap.h
> @@ -47,6 +47,11 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
>   */
>  struct dev_pagemap {
>  	void (*free_devpage)(struct page *page, void *data);
> +	int (*fault)(struct vm_area_struct *vma,
> +		     unsigned long addr,
> +		     struct page *page,
> +		     unsigned flags,
> +		     pmd_t *pmdp);

We are extending the dev_pagemap once again to accommodate device driver
specific fault routines for these pages. Wondering if this extension and
the new swap type should be in the same patch.

>  	struct vmem_altmap *altmap;
>  	const struct resource *res;
>  	struct percpu_ref *ref;
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 7e553e1..599cb54 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -50,6 +50,17 @@ static inline int current_is_kswapd(void)
>   */
>  
>  /*
> + * Un-addressable device memory support
> + */
> +#ifdef CONFIG_DEVICE_UNADDRESSABLE
> +#define SWP_DEVICE_NUM 2
> +#define SWP_DEVICE_WRITE (MAX_SWAPFILES + SWP_HWPOISON_NUM + SWP_MIGRATION_NUM)
> +#define SWP_DEVICE (MAX_SWAPFILES + SWP_HWPOISON_NUM + SWP_MIGRATION_NUM + 1)
> +#else
> +#define SWP_DEVICE_NUM 0
> +#endif
> +
> +/*
>   * NUMA node memory migration support
>   */
>  #ifdef CONFIG_MIGRATION
> @@ -71,7 +82,8 @@ static inline int current_is_kswapd(void)
>  #endif
>  
>  #define MAX_SWAPFILES \
> -	((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_HWPOISON_NUM)
> +	((1 << MAX_SWAPFILES_SHIFT) - SWP_DEVICE_NUM - \
> +	SWP_MIGRATION_NUM - SWP_HWPOISON_NUM)
>  
>  /*
>   * Magic header for a swap area. The first part of the union is
> @@ -442,8 +454,8 @@ static inline void show_swap_cache_info(void)
>  {
>  }
>  
> -#define free_swap_and_cache(swp)	is_migration_entry(swp)
> -#define swapcache_prepare(swp)		is_migration_entry(swp)
> +#define free_swap_and_cache(e) (is_migration_entry(e) || is_device_entry(e))
> +#define swapcache_prepare(e) (is_migration_entry(e) || is_device_entry(e))
>  
>  static inline int add_swap_count_continuation(swp_entry_t swp, gfp_t gfp_mask)
>  {
> diff --git a/include/linux/swapops.h b/include/linux/swapops.h
> index 5c3a5f3..d1aa425 100644
> --- a/include/linux/swapops.h
> +++ b/include/linux/swapops.h
> @@ -100,6 +100,73 @@ static inline void *swp_to_radix_entry(swp_entry_t entry)
>  	return (void *)(value | RADIX_TREE_EXCEPTIONAL_ENTRY);
>  }
>  
> +#ifdef CONFIG_DEVICE_UNADDRESSABLE
> +static inline swp_entry_t make_device_entry(struct page *page, bool write)
> +{
> +	return swp_entry(write?SWP_DEVICE_WRITE:SWP_DEVICE, page_to_pfn(page));
> +}
> +
> +static inline bool is_device_entry(swp_entry_t entry)
> +{
> +	int type = swp_type(entry);
> +	return type == SWP_DEVICE || type == SWP_DEVICE_WRITE;
> +}
> +
> +static inline void make_device_entry_read(swp_entry_t *entry)
> +{
> +	*entry = swp_entry(SWP_DEVICE, swp_offset(*entry));
> +}
> +
> +static inline bool is_write_device_entry(swp_entry_t entry)
> +{
> +	return unlikely(swp_type(entry) == SWP_DEVICE_WRITE);
> +}
> +
> +static inline struct page *device_entry_to_page(swp_entry_t entry)
> +{
> +	return pfn_to_page(swp_offset(entry));
> +}
> +
> +int device_entry_fault(struct vm_area_struct *vma,
> +		       unsigned long addr,
> +		       swp_entry_t entry,
> +		       unsigned flags,
> +		       pmd_t *pmdp);
> +#else /* CONFIG_DEVICE_UNADDRESSABLE */
> +static inline swp_entry_t make_device_entry(struct page *page, bool write)
> +{
> +	return swp_entry(0, 0);
> +}
> +
> +static inline void make_device_entry_read(swp_entry_t *entry)
> +{
> +}
> +
> +static inline bool is_device_entry(swp_entry_t entry)
> +{
> +	return false;
> +}
> +
> +static inline bool is_write_device_entry(swp_entry_t entry)
> +{
> +	return false;
> +}
> +
> +static inline struct page *device_entry_to_page(swp_entry_t entry)
> +{
> +	return NULL;
> +}
> +
> +static inline int device_entry_fault(struct vm_area_struct *vma,
> +				     unsigned long addr,
> +				     swp_entry_t entry,
> +				     unsigned flags,
> +				     pmd_t *pmdp)
> +{
> +	return VM_FAULT_SIGBUS;
> +}
> +#endif /* CONFIG_DEVICE_UNADDRESSABLE */
> +
>  #ifdef CONFIG_MIGRATION
>  static inline swp_entry_t make_migration_entry(struct page *page, int write)
>  {
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index cf83928..0670015 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -18,6 +18,8 @@
>  #include <linux/io.h>
>  #include <linux/mm.h>
>  #include <linux/memory_hotplug.h>
> +#include <linux/swap.h>
> +#include <linux/swapops.h>
>  
>  #ifndef ioremap_cache
>  /* temporary while we convert existing ioremap_cache users to memremap */
> @@ -200,6 +202,18 @@ void put_zone_device_page(struct page *page)
>  }
>  EXPORT_SYMBOL(put_zone_device_page);
>  
> +int device_entry_fault(struct vm_area_struct *vma,
> +		       unsigned long addr,
> +		       swp_entry_t entry,
> +		       unsigned flags,
> +		       pmd_t *pmdp)
> +{
> +	struct page *page = device_entry_to_page(entry);
> +

A BUG_ON() if page->pgmap->fault has not been populated by the driver.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
