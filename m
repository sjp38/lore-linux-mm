Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD12B6B04E7
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 06:11:04 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q10so383662877pgq.7
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 03:11:04 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h189si10886086pfb.15.2016.11.21.03.11.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 03:11:03 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uALB9ihx087193
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 06:11:03 -0500
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26uyg19381-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 06:11:03 -0500
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 21 Nov 2016 21:11:00 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 27E8E2CE8054
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 22:10:57 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uALBAuGX56557698
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 22:10:56 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uALBAucU017801
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 22:10:56 +1100
Subject: Re: [HMM v13 06/18] mm/ZONE_DEVICE/unaddressable: add special swap
 for unaddressable
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-7-git-send-email-jglisse@redhat.com>
 <3f759fff-fe8d-89c4-5c86-c9f27403bf3b@gmail.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 21 Nov 2016 16:40:54 +0530
MIME-Version: 1.0
In-Reply-To: <3f759fff-fe8d-89c4-5c86-c9f27403bf3b@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Message-Id: <5832D63E.9000102@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On 11/21/2016 07:36 AM, Balbir Singh wrote:
> 
> 
> On 19/11/16 05:18, JA(C)rA'me Glisse wrote:
>> To allow use of device un-addressable memory inside a process add a
>> special swap type. Also add a new callback to handle page fault on
>> such entry.
>>
>> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
>> Cc: Dan Williams <dan.j.williams@intel.com>
>> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
>> ---
>>  fs/proc/task_mmu.c       | 10 +++++++-
>>  include/linux/memremap.h |  5 ++++
>>  include/linux/swap.h     | 18 ++++++++++---
>>  include/linux/swapops.h  | 67 ++++++++++++++++++++++++++++++++++++++++++++++++
>>  kernel/memremap.c        | 14 ++++++++++
>>  mm/Kconfig               | 12 +++++++++
>>  mm/memory.c              | 24 +++++++++++++++++
>>  mm/mprotect.c            | 12 +++++++++
>>  8 files changed, 158 insertions(+), 4 deletions(-)
>>
>> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
>> index 6909582..0726d39 100644
>> --- a/fs/proc/task_mmu.c
>> +++ b/fs/proc/task_mmu.c
>> @@ -544,8 +544,11 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
>>  			} else {
>>  				mss->swap_pss += (u64)PAGE_SIZE << PSS_SHIFT;
>>  			}
>> -		} else if (is_migration_entry(swpent))
>> +		} else if (is_migration_entry(swpent)) {
>>  			page = migration_entry_to_page(swpent);
>> +		} else if (is_device_entry(swpent)) {
>> +			page = device_entry_to_page(swpent);
>> +		}
> 
> 
> So the reason there is a device swap entry for a page belonging to a user process is
> that it is in the middle of migration or is it always that a swap entry represents
> unaddressable memory belonging to a GPU device, but its tracked in the page table
> entries of the process.

I guess the later is the case and its used for the page table mirroring
purpose after intercepting the page faults. But will leave upto Jerome
to explain more on this.

> 
>>  	} else if (unlikely(IS_ENABLED(CONFIG_SHMEM) && mss->check_shmem_swap
>>  							&& pte_none(*pte))) {
>>  		page = find_get_entry(vma->vm_file->f_mapping,
>> @@ -708,6 +711,8 @@ static int smaps_hugetlb_range(pte_t *pte, unsigned long hmask,
>>  
>>  		if (is_migration_entry(swpent))
>>  			page = migration_entry_to_page(swpent);
>> +		if (is_device_entry(swpent))
>> +			page = device_entry_to_page(swpent);
>>  	}
>>  	if (page) {
>>  		int mapcount = page_mapcount(page);
>> @@ -1191,6 +1196,9 @@ static pagemap_entry_t pte_to_pagemap_entry(struct pagemapread *pm,
>>  		flags |= PM_SWAP;
>>  		if (is_migration_entry(entry))
>>  			page = migration_entry_to_page(entry);
>> +
>> +		if (is_device_entry(entry))
>> +			page = device_entry_to_page(entry);
>>  	}
>>  
>>  	if (page && !PageAnon(page))
>> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
>> index b6f03e9..d584c74 100644
>> --- a/include/linux/memremap.h
>> +++ b/include/linux/memremap.h
>> @@ -47,6 +47,11 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
>>   */
>>  struct dev_pagemap {
>>  	void (*free_devpage)(struct page *page, void *data);
>> +	int (*fault)(struct vm_area_struct *vma,
>> +		     unsigned long addr,
>> +		     struct page *page,
>> +		     unsigned flags,
>> +		     pmd_t *pmdp);
>>  	struct vmem_altmap *altmap;
>>  	const struct resource *res;
>>  	struct percpu_ref *ref;
>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>> index 7e553e1..599cb54 100644
>> --- a/include/linux/swap.h
>> +++ b/include/linux/swap.h
>> @@ -50,6 +50,17 @@ static inline int current_is_kswapd(void)
>>   */
>>  
>>  /*
>> + * Un-addressable device memory support
>> + */
>> +#ifdef CONFIG_DEVICE_UNADDRESSABLE
>> +#define SWP_DEVICE_NUM 2
>> +#define SWP_DEVICE_WRITE (MAX_SWAPFILES + SWP_HWPOISON_NUM + SWP_MIGRATION_NUM)
>> +#define SWP_DEVICE (MAX_SWAPFILES + SWP_HWPOISON_NUM + SWP_MIGRATION_NUM + 1)
>> +#else
>> +#define SWP_DEVICE_NUM 0
>> +#endif
>> +
>> +/*
>>   * NUMA node memory migration support
>>   */
>>  #ifdef CONFIG_MIGRATION
>> @@ -71,7 +82,8 @@ static inline int current_is_kswapd(void)
>>  #endif
>>  
>>  #define MAX_SWAPFILES \
>> -	((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_HWPOISON_NUM)
>> +	((1 << MAX_SWAPFILES_SHIFT) - SWP_DEVICE_NUM - \
>> +	SWP_MIGRATION_NUM - SWP_HWPOISON_NUM)
>>  
>>  /*
>>   * Magic header for a swap area. The first part of the union is
>> @@ -442,8 +454,8 @@ static inline void show_swap_cache_info(void)
>>  {
>>  }
>>  
>> -#define free_swap_and_cache(swp)	is_migration_entry(swp)
>> -#define swapcache_prepare(swp)		is_migration_entry(swp)
>> +#define free_swap_and_cache(e) (is_migration_entry(e) || is_device_entry(e))
>> +#define swapcache_prepare(e) (is_migration_entry(e) || is_device_entry(e))
>>  
>>  static inline int add_swap_count_continuation(swp_entry_t swp, gfp_t gfp_mask)
>>  {
>> diff --git a/include/linux/swapops.h b/include/linux/swapops.h
>> index 5c3a5f3..d1aa425 100644
>> --- a/include/linux/swapops.h
>> +++ b/include/linux/swapops.h
>> @@ -100,6 +100,73 @@ static inline void *swp_to_radix_entry(swp_entry_t entry)
>>  	return (void *)(value | RADIX_TREE_EXCEPTIONAL_ENTRY);
>>  }
>>  
>> +#ifdef CONFIG_DEVICE_UNADDRESSABLE
>> +static inline swp_entry_t make_device_entry(struct page *page, bool write)
>> +{
>> +	return swp_entry(write?SWP_DEVICE_WRITE:SWP_DEVICE, page_to_pfn(page));
> 
> Code style checks
> 
>> +}
>> +
>> +static inline bool is_device_entry(swp_entry_t entry)
>> +{
>> +	int type = swp_type(entry);
>> +	return type == SWP_DEVICE || type == SWP_DEVICE_WRITE;
>> +}
>> +
>> +static inline void make_device_entry_read(swp_entry_t *entry)
>> +{
>> +	*entry = swp_entry(SWP_DEVICE, swp_offset(*entry));
>> +}
>> +
>> +static inline bool is_write_device_entry(swp_entry_t entry)
>> +{
>> +	return unlikely(swp_type(entry) == SWP_DEVICE_WRITE);
>> +}
>> +
>> +static inline struct page *device_entry_to_page(swp_entry_t entry)
>> +{
>> +	return pfn_to_page(swp_offset(entry));
>> +}
>> +
>> +int device_entry_fault(struct vm_area_struct *vma,
>> +		       unsigned long addr,
>> +		       swp_entry_t entry,
>> +		       unsigned flags,
>> +		       pmd_t *pmdp);
>> +#else /* CONFIG_DEVICE_UNADDRESSABLE */
>> +static inline swp_entry_t make_device_entry(struct page *page, bool write)
>> +{
>> +	return swp_entry(0, 0);
>> +}
>> +
>> +static inline void make_device_entry_read(swp_entry_t *entry)
>> +{
>> +}
>> +
>> +static inline bool is_device_entry(swp_entry_t entry)
>> +{
>> +	return false;
>> +}
>> +
>> +static inline bool is_write_device_entry(swp_entry_t entry)
>> +{
>> +	return false;
>> +}
>> +
>> +static inline struct page *device_entry_to_page(swp_entry_t entry)
>> +{
>> +	return NULL;
>> +}
>> +
>> +static inline int device_entry_fault(struct vm_area_struct *vma,
>> +				     unsigned long addr,
>> +				     swp_entry_t entry,
>> +				     unsigned flags,
>> +				     pmd_t *pmdp)
>> +{
>> +	return VM_FAULT_SIGBUS;
>> +}
>> +#endif /* CONFIG_DEVICE_UNADDRESSABLE */
>> +
>>  #ifdef CONFIG_MIGRATION
>>  static inline swp_entry_t make_migration_entry(struct page *page, int write)
>>  {
>> diff --git a/kernel/memremap.c b/kernel/memremap.c
>> index cf83928..0670015 100644
>> --- a/kernel/memremap.c
>> +++ b/kernel/memremap.c
>> @@ -18,6 +18,8 @@
>>  #include <linux/io.h>
>>  #include <linux/mm.h>
>>  #include <linux/memory_hotplug.h>
>> +#include <linux/swap.h>
>> +#include <linux/swapops.h>
>>  
>>  #ifndef ioremap_cache
>>  /* temporary while we convert existing ioremap_cache users to memremap */
>> @@ -200,6 +202,18 @@ void put_zone_device_page(struct page *page)
>>  }
>>  EXPORT_SYMBOL(put_zone_device_page);
>>  
>> +int device_entry_fault(struct vm_area_struct *vma,
>> +		       unsigned long addr,
>> +		       swp_entry_t entry,
>> +		       unsigned flags,
>> +		       pmd_t *pmdp)
>> +{
>> +	struct page *page = device_entry_to_page(entry);
>> +
>> +	return page->pgmap->fault(vma, addr, page, flags, pmdp);
>> +}
>> +EXPORT_SYMBOL(device_entry_fault);
>> +
>>  static void pgmap_radix_release(struct resource *res)
>>  {
>>  	resource_size_t key, align_start, align_size, align_end;
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index be0ee11..0a21411 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -704,6 +704,18 @@ config ZONE_DEVICE
>>  
>>  	  If FS_DAX is enabled, then say Y.
>>  
>> +config DEVICE_UNADDRESSABLE
>> +	bool "Un-addressable device memory (GPU memory, ...)"
>> +	depends on ZONE_DEVICE
>> +
>> +	help
>> +	  Allow to create struct page for un-addressable device memory
>> +	  ie memory that is only accessible by the device (or group of
>> +	  devices).
>> +
>> +	  This allow to migrate chunk of process memory to device memory
>> +	  while that memory is use by the device.
>> +
>>  config FRAME_VECTOR
>>  	bool
>>  
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 15f2908..a83d690 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -889,6 +889,21 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>>  					pte = pte_swp_mksoft_dirty(pte);
>>  				set_pte_at(src_mm, addr, src_pte, pte);
>>  			}
>> +		} else if (is_device_entry(entry)) {
>> +			page = device_entry_to_page(entry);
>> +
>> +			get_page(page);
>> +			rss[mm_counter(page)]++;
> 
> Why does rss count go up?
> 
>> +			page_dup_rmap(page, false);
>> +
>> +			if (is_write_device_entry(entry) &&
>> +			    is_cow_mapping(vm_flags)) {
>> +				make_device_entry_read(&entry);
>> +				pte = swp_entry_to_pte(entry);
>> +				if (pte_swp_soft_dirty(*src_pte))
>> +					pte = pte_swp_mksoft_dirty(pte);
>> +				set_pte_at(src_mm, addr, src_pte, pte);
>> +			}
>>  		}
>>  		goto out_set_pte;
>>  	}
>> @@ -1191,6 +1206,12 @@ again:
>>  
>>  			page = migration_entry_to_page(entry);
>>  			rss[mm_counter(page)]--;
>> +		} else if (is_device_entry(entry)) {
>> +			struct page *page = device_entry_to_page(entry);
>> +			rss[mm_counter(page)]--;
>> +
>> +			page_remove_rmap(page, false);
>> +			put_page(page);
>>  		}
>>  		if (unlikely(!free_swap_and_cache(entry)))
>>  			print_bad_pte(vma, addr, ptent, NULL);
>> @@ -2536,6 +2557,9 @@ int do_swap_page(struct fault_env *fe, pte_t orig_pte)
>>  	if (unlikely(non_swap_entry(entry))) {
>>  		if (is_migration_entry(entry)) {
>>  			migration_entry_wait(vma->vm_mm, fe->pmd, fe->address);
>> +		} else if (is_device_entry(entry)) {
>> +			ret = device_entry_fault(vma, fe->address, entry,
>> +						 fe->flags, fe->pmd);
> 
> What does device_entry_fault() actually do here?

IIUC it calls page->pgmap->fault() which is device specific page fault for
the page and thats how the control reaches device driver from the core VM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
