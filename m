Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id E3CA66B0031
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 21:16:25 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id lj1so1789987pab.20
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 18:16:24 -0700 (PDT)
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com. [202.81.31.140])
        by mx.google.com with ESMTPS id f1si1874189pbn.16.2014.04.08.18.16.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 18:16:23 -0700 (PDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <maddy@linux.vnet.ibm.com>;
	Wed, 9 Apr 2014 11:16:19 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 27BF43578064
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 11:16:16 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s391G16E852390
	for <linux-mm@kvack.org>; Wed, 9 Apr 2014 11:16:01 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s391EhPh005721
	for <linux-mm@kvack.org>; Wed, 9 Apr 2014 11:14:44 +1000
Message-ID: <53449EF4.10805@linux.vnet.ibm.com>
Date: Wed, 09 Apr 2014 06:44:28 +0530
From: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 1/2] mm: move FAULT_AROUND_ORDER to arch/
References: <1396592835-24767-1-git-send-email-maddy@linux.vnet.ibm.com> <1396592835-24767-2-git-send-email-maddy@linux.vnet.ibm.com> <20140404131747.GA23076@node.dhcp.inet.fi>
In-Reply-To: <20140404131747.GA23076@node.dhcp.inet.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org

On Friday 04 April 2014 06:47 PM, Kirill A. Shutemov wrote:
> On Fri, Apr 04, 2014 at 11:57:14AM +0530, Madhavan Srinivasan wrote:
>> Kirill A. Shutemov with faultaround patchset introduced
>> vm_ops->map_pages() for mapping easy accessible pages around
>> fault address in hope to reduce number of minor page faults.
>>
>> This patch creates infrastructure to move the FAULT_AROUND_ORDER
>> to arch/ using Kconfig. This will enable architecture maintainers
>> to decide on suitable FAULT_AROUND_ORDER value based on
>> performance data for that architecture. Patch also adds
>> FAULT_AROUND_ORDER Kconfig element in arch/X86.
>>
>> Signed-off-by: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
>> ---
>>  arch/x86/Kconfig   |    4 ++++
>>  include/linux/mm.h |    9 +++++++++
>>  mm/memory.c        |   12 +++++-------
>>  3 files changed, 18 insertions(+), 7 deletions(-)
>>
>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>> index 9c0a657..5833f22 100644
>> --- a/arch/x86/Kconfig
>> +++ b/arch/x86/Kconfig
>> @@ -1177,6 +1177,10 @@ config DIRECT_GBPAGES
>>  	  support it. This can improve the kernel's performance a tiny bit by
>>  	  reducing TLB pressure. If in doubt, say "Y".
>>  
>> +config FAULT_AROUND_ORDER
>> +	int
>> +	default "4"
>> +
>>  # Common NUMA Features
>>  config NUMA
>>  	bool "Numa Memory Allocation and Scheduler Support"
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 0bd4359..b93c1c3 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -26,6 +26,15 @@ struct file_ra_state;
>>  struct user_struct;
>>  struct writeback_control;
>>  
>> +/*
>> + * Fault around order is a control knob to decide the fault around pages.
>> + * Default value is set to 0UL (disabled), but the arch can override it as
>> + * desired.
>> + */
>> +#ifndef CONFIG_FAULT_AROUND_ORDER
>> +#define CONFIG_FAULT_AROUND_ORDER 0
>> +#endif
>> +
> 
> I don't think it should be in header file: nobody except mm/memory.c cares.
> Just put it instead '#define FAULT_AROUND_ORDER'.
> 

Ok. Will do this change.

>>  #ifndef CONFIG_NEED_MULTIPLE_NODES	/* Don't use mapnrs, do it properly */
>>  extern unsigned long max_mapnr;
>>  
>> diff --git a/mm/memory.c b/mm/memory.c
>> index b02c584..22a4a89 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -3358,10 +3358,8 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
>>  	update_mmu_cache(vma, address, pte);
>>  }
>>  
>> -#define FAULT_AROUND_ORDER 4
>> -
>>  #ifdef CONFIG_DEBUG_FS
>> -static unsigned int fault_around_order = FAULT_AROUND_ORDER;
>> +static unsigned int fault_around_order = CONFIG_FAULT_AROUND_ORDER;
>>  
>>  static int fault_around_order_get(void *data, u64 *val)
>>  {
>> @@ -3371,7 +3369,7 @@ static int fault_around_order_get(void *data, u64 *val)
>>  
>>  static int fault_around_order_set(void *data, u64 val)
>>  {
>> -	BUILD_BUG_ON((1UL << FAULT_AROUND_ORDER) > PTRS_PER_PTE);
>> +	BUILD_BUG_ON((1UL << CONFIG_FAULT_AROUND_ORDER) > PTRS_PER_PTE);
>>  	if (1UL << val > PTRS_PER_PTE)
>>  		return -EINVAL;
>>  	fault_around_order = val;
>> @@ -3406,14 +3404,14 @@ static inline unsigned long fault_around_pages(void)
>>  {
>>  	unsigned long nr_pages;
>>  
>> -	nr_pages = 1UL << FAULT_AROUND_ORDER;
>> +	nr_pages = 1UL << CONFIG_FAULT_AROUND_ORDER;
>>  	BUILD_BUG_ON(nr_pages > PTRS_PER_PTE);
>>  	return nr_pages;
>>  }
>>  
>>  static inline unsigned long fault_around_mask(void)
>>  {
>> -	return ~((1UL << (PAGE_SHIFT + FAULT_AROUND_ORDER)) - 1);
>> +	return ~((1UL << (PAGE_SHIFT + CONFIG_FAULT_AROUND_ORDER)) - 1);
>>  }
>>  #endif
>>  
>> @@ -3471,7 +3469,7 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>>  	 * if page by the offset is not ready to be mapped (cold cache or
>>  	 * something).
>>  	 */
>> -	if (vma->vm_ops->map_pages) {
>> +	if ((vma->vm_ops->map_pages) && (fault_around_pages() > 1)) {
> 
> 	if (vma->vm_ops->map_pages && fault_around_pages()) {
> 
For a fault around value of 0, fault_around_pages() will return 1 and
that is reason for checking it greater than 1. Also, using debug fs,
fault around value can be zeroed.

With regards
Maddy
>>  		pte = pte_offset_map_lock(mm, pmd, address, &ptl);
>>  		do_fault_around(vma, address, pte, pgoff, flags);
>>  		if (!pte_same(*pte, orig_pte))
>> -- 
>> 1.7.10.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
