Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id ABB916B003A
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 05:43:47 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so3391740pdj.1
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 02:43:47 -0700 (PDT)
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com. [202.81.31.141])
        by mx.google.com with ESMTPS id zp5si8857170pac.24.2014.04.29.02.43.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 02:43:46 -0700 (PDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <maddy@linux.vnet.ibm.com>;
	Tue, 29 Apr 2014 19:43:43 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id C029E3578052
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 19:41:38 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s3T9FfFs45219988
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 19:16:02 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s3T9Zn45030526
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 19:35:50 +1000
Message-ID: <535F7271.2010504@linux.vnet.ibm.com>
Date: Tue, 29 Apr 2014 15:05:45 +0530
From: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V3 1/2] mm: move FAULT_AROUND_ORDER to arch/
References: <1398675690-16186-1-git-send-email-maddy@linux.vnet.ibm.com> <1398675690-16186-2-git-send-email-maddy@linux.vnet.ibm.com> <20140428093606.95B90E009B@blue.fi.intel.com>
In-Reply-To: <20140428093606.95B90E009B@blue.fi.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, rusty@rustcorp.com.au, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org, dave.hansen@intel.com

On Monday 28 April 2014 03:06 PM, Kirill A. Shutemov wrote:
> Madhavan Srinivasan wrote:
>> Kirill A. Shutemov with 8c6e50b029 commit introduced
>> vm_ops->map_pages() for mapping easy accessible pages around
>> fault address in hope to reduce number of minor page faults.
>>
>> This patch creates infrastructure to modify the FAULT_AROUND_ORDER
>> value using mm/Kconfig. This will enable architecture maintainers
>> to decide on suitable FAULT_AROUND_ORDER value based on
>> performance data for that architecture. Patch also defaults
>> FAULT_AROUND_ORDER Kconfig element to 4.
>>
>> Signed-off-by: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
>> ---
>>  mm/Kconfig  |    8 ++++++++
>>  mm/memory.c |   11 ++++-------
>>  2 files changed, 12 insertions(+), 7 deletions(-)
>>
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index ebe5880..c7fc4f1 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -176,6 +176,14 @@ config MOVABLE_NODE
>>  config HAVE_BOOTMEM_INFO_NODE
>>  	def_bool n
>>  
>> +#
>> +# Fault around order is a control knob to decide the fault around pages.
>> +# Default value is set to 4 , but the arch can override it as desired.
>> +#
>> +config FAULT_AROUND_ORDER
>> +	int
>> +	default	4
>> +
>>  # eventually, we can have this option just 'select SPARSEMEM'
>>  config MEMORY_HOTPLUG
>>  	bool "Allow for memory hot-add"
>> diff --git a/mm/memory.c b/mm/memory.c
>> index d0f0bef..457436d 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -3382,11 +3382,9 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
>>  	update_mmu_cache(vma, address, pte);
>>  }
>>  
>> -#define FAULT_AROUND_ORDER 4
>> +unsigned int fault_around_order = CONFIG_FAULT_AROUND_ORDER;
>>  
>>  #ifdef CONFIG_DEBUG_FS
>> -static unsigned int fault_around_order = FAULT_AROUND_ORDER;
>> -
>>  static int fault_around_order_get(void *data, u64 *val)
>>  {
>>  	*val = fault_around_order;
>> @@ -3395,7 +3393,6 @@ static int fault_around_order_get(void *data, u64 *val)
>>  
>>  static int fault_around_order_set(void *data, u64 val)
>>  {
>> -	BUILD_BUG_ON((1UL << FAULT_AROUND_ORDER) > PTRS_PER_PTE);
>>  	if (1UL << val > PTRS_PER_PTE)
>>  		return -EINVAL;
>>  	fault_around_order = val;
>> @@ -3430,14 +3427,14 @@ static inline unsigned long fault_around_pages(void)
>>  {
>>  	unsigned long nr_pages;
>>  
>> -	nr_pages = 1UL << FAULT_AROUND_ORDER;
>> +	nr_pages = 1UL << fault_around_order;
>>  	BUILD_BUG_ON(nr_pages > PTRS_PER_PTE);
> 
> This BUILD_BUG_ON() doesn't make sense any more since compiler usually can't
> prove anything about extern variable.
> 
> Drop it or change to VM_BUG_ON() or something.
> 

Ok.

>>  	return nr_pages;
>>  }
>>  
>>  static inline unsigned long fault_around_mask(void)
>>  {
>> -	return ~((1UL << (PAGE_SHIFT + FAULT_AROUND_ORDER)) - 1);
>> +	return ~((1UL << (PAGE_SHIFT + fault_around_order)) - 1);
> 
> fault_around_pages() and fault_around_mask() should be moved outside of
> #ifdef CONFIG_DEBUG_FS and consolidated since they are practically identical
> both branches after the changes.
> 

Agreed. Will change it.

>>  }
>>  #endif
>>  
>> @@ -3495,7 +3492,7 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>>  	 * if page by the offset is not ready to be mapped (cold cache or
>>  	 * something).
>>  	 */
>> -	if (vma->vm_ops->map_pages) {
>> +	if ((vma->vm_ops->map_pages) && (fault_around_order)) {
> 
> Way too many parentheses.
> 

Sure. Will modify it.

Thanks for review
with regards
Maddy
>>  		pte = pte_offset_map_lock(mm, pmd, address, &ptl);
>>  		do_fault_around(vma, address, pte, pgoff, flags);
>>  		if (!pte_same(*pte, orig_pte))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
