Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E6E4F6B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 18:29:09 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id m85so3923265wma.8
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 15:29:09 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id j4si5481092edk.222.2017.08.30.15.29.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 15:29:07 -0700 (PDT)
Subject: Re: [PATCH v7 9/9] sparc64: Add support for ADI (Application Data
 Integrity)
References: <cover.1502219353.git.khalid.aziz@oracle.com>
 <cover.1502219353.git.khalid.aziz@oracle.com>
 <3a687666c2e7972fb6d2379848f31006ac1dd59a.1502219353.git.khalid.aziz@oracle.com>
 <F65BCC2D-8FA4-453F-8378-3369C44B0319@oracle.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <7b8216b8-e732-0b31-a374-1a817d4fbc80@oracle.com>
Date: Wed, 30 Aug 2017 16:27:54 -0600
MIME-Version: 1.0
In-Reply-To: <F65BCC2D-8FA4-453F-8378-3369C44B0319@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anthony Yznaga <anthony.yznaga@oracle.com>
Cc: David Miller <davem@davemloft.net>, dave.hansen@linux.intel.com, corbet@lwn.net, Bob Picco <bob.picco@oracle.com>, steven.sistare@oracle.com, pasha.tatashin@oracle.com, mike.kravetz@oracle.com, mingo@kernel.org, nitin.m.gupta@oracle.com, kirill.shutemov@linux.intel.com, tom.hromatka@oracle.com, eric.saint.etienne@oracle.com, allen.pais@oracle.com, cmetcalf@mellanox.com, akpm@linux-foundation.org, geert@linux-m68k.org, tklauser@distanz.ch, atish.patra@oracle.com, vijay.ac.kumar@oracle.com, peterz@infradead.org, mhocko@suse.com, jack@suse.cz, lstoakes@gmail.com, hughd@google.com, thomas.tai@oracle.com, paul.gortmaker@windriver.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, willy@infradead.org, ying.huang@intel.com, zhongjiang@huawei.com, minchan@kernel.org, vegard.nossum@oracle.com, imbrenda@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid@gonehiking.org>

Hi Anthony,

Thanks for taking the time to provide feedback. My comments inline below.

On 08/25/2017 04:31 PM, Anthony Yznaga wrote:
> 
>> On Aug 9, 2017, at 2:26 PM, Khalid Aziz <khalid.aziz@oracle.com> wrote:
>> ......deleted......
>> +provided by the hypervisor to the kernel.  Kernel returns the value of
>> +ADI block size to userspace using auxiliary vector along with other ADI
>> +info. Following auxiliary vectors are provided by the kernel:
>> +
>> +	AT_ADI_BLKSZ	ADI block size. This is the granularity and
>> +			alignment, in bytes, of ADI versioning.
>> +	AT_ADI_NBITS	Number of ADI version bits in the VA
> 
> The previous patch series also defined AT_ADI_UEONADI.  Why was that
> removed?

This was based upon a conversation we had when you mentioned future 
processors may not implement this or change the way this is interpreted 
and any applications depending upon this value would break at that 
point. I removed it to eliminate building an unreliable dependency. If I 
misunderstood what you said, please let me know.

> 
>> +
>> +
>> +IMPORTANT NOTES:
>> +
>> +- Version tag values of 0x0 and 0xf are reserved.
> 
> The documentation should probably state more specifically that an
> in-memory tag value of 0x0 or 0xf is treated as "match all" by the HW
> meaning that a mismatch exception will never be generated regardless
> of the tag bits set in the VA accessing the memory.

Will do.

> 
>> +
>> +- Version tags are set on virtual addresses from userspace even though
>> +  tags are stored in physical memory. Tags are set on a physical page
>> +  after it has been allocated to a task and a pte has been created for
>> +  it.
>> +
>> +- When a task frees a memory page it had set version tags on, the page
>> +  goes back to free page pool. When this page is re-allocated to a task,
>> +  kernel clears the page using block initialization ASI which clears the
>> +  version tags as well for the page. If a page allocated to a task is
>> +  freed and allocated back to the same task, old version tags set by the
>> +  task on that page will no longer be present.
> 
> The specifics should be included here, too, so someone doesn't have
> to guess what's going on if they make changes and the tags are no longer
> cleared.  The HW clears the tag for a cacheline for block initializing
> stores to 64-byte aligned addresses if PSTATE.mcde=0 or TTE.mcd=0.
> PSTATE.mce is set when executing in the kernel, but pages are cleared
> using kernel physical mapping VAs which are mapped with TTE.mcd=0.
> 
> Another HW behavior that should be mentioned is that tag mismatches
> are not detected for non-faulting loads.

Sure, I can add that.

> 
>> +
>> +- Kernel does not set any tags for user pages and it is entirely a
>> +  task's responsibility to set any version tags. Kernel does ensure the
>> +  version tags are preserved if a page is swapped out to the disk and
>> +  swapped back in. It also preserves that version tags if a page is
>> +  migrated.
> 
> I only have a cursory understanding of how page migration works, but
> I could not see how the tags would be preserved if a page were migrated.
> I figured the place to copy the tags would be migrate_page_copy(), but
> I don't see changes there.
> 
> 

For migrating user pages, the way I understand the code works is if the 
page is mapped (which is the only time ADI tags are even in place), 
try_to_unmap() is called with TTU_MIGRATION flag set. try_to_unmap() 
will call arch_unmap_one() which saves the tags from currently mapped 
page. When the new page has been allocated, contents of the old page are 
faulted in through do_swap_page() which will call arch_do_swap_page(). 
arch_do_swap_page() then restores the ADI tags.


>> diff --git a/arch/sparc/include/asm/mman.h b/arch/sparc/include/asm/mman.h
>> index 59bb5938d852..b799796ad963 100644
>> --- a/arch/sparc/include/asm/mman.h
>> +++ b/arch/sparc/include/asm/mman.h
>> @@ -6,5 +6,75 @@
>> #ifndef __ASSEMBLY__
>> #define arch_mmap_check(addr,len,flags)	sparc_mmap_check(addr,len)
>> int sparc_mmap_check(unsigned long addr, unsigned long len);
>> -#endif
>> +
>> +#ifdef CONFIG_SPARC64
>> +#include <asm/adi_64.h>
>> +
>> +#define arch_calc_vm_prot_bits(prot, pkey) sparc_calc_vm_prot_bits(prot)
>> +static inline unsigned long sparc_calc_vm_prot_bits(unsigned long prot)
>> +{
>> +	if (prot & PROT_ADI) {
>> +		struct pt_regs *regs;
>> +
>> +		if (!current->mm->context.adi) {
>> +			regs = task_pt_regs(current);
>> +			regs->tstate |= TSTATE_MCDE;
>> +			current->mm->context.adi = true;
> 
> If a process is multi-threaded when it enables ADI on some memory for
> the first time, TSTATE_MCDE will only be set for the calling thread
> and it will not be possible to enable it for the other threads.
> One possible way to handle this is to enable TSTATE_MCDE for all user
> threads when they are initialized if adi_capable() returns true.
> 

Or set TSTATE_MCDE unconditionally here by removing "if 
(!current->mm->context.adi)"?

> 
>> +		}
>> +		return VM_SPARC_ADI;
>> +	} else {
>> +		return 0;
>> +	}
>> +}
>> +
>> +#define arch_vm_get_page_prot(vm_flags) sparc_vm_get_page_prot(vm_flags)
>> +static inline pgprot_t sparc_vm_get_page_prot(unsigned long vm_flags)
>> +{
>> +	return (vm_flags & VM_SPARC_ADI) ? __pgprot(_PAGE_MCD_4V) : __pgprot(0);
>> +}
>> +
>> +#define arch_validate_prot(prot, addr) sparc_validate_prot(prot, addr)
>> +static inline int sparc_validate_prot(unsigned long prot, unsigned long addr)
>> +{
>> +	if (prot & ~(PROT_READ | PROT_WRITE | PROT_EXEC | PROT_SEM | PROT_ADI))
>> +		return 0;
>> +	if (prot & PROT_ADI) {
>> +		if (!adi_capable())
>> +			return 0;
>> +
>> +		/* ADI tags can not be set on read-only memory, so it makes
>> +		 * sense to enable ADI on writable memory only.
>> +		 */
>> +		if (!(prot & PROT_WRITE))
>> +			return 0;
> 
> This prevents the use of ADI for the legitimate case where shared memory
> is mapped read/write for a master process but mapped read-only for a
> client process.  The master process could set the tags and communicate
> the expected tag values to the client.

A non-writable mapping can access the shared memory using non-ADI tagged 
addresses if it does not enable ADI on its mappings, so it is 
superfluous to even allow enabling ADI. I can remove this if that helps 
any use cases that wouldn't work with above condition.

>> +tag_storage_desc_t *alloc_tag_store(struct mm_struct *mm,
>> +				    struct vm_area_struct *vma,
>> +				    unsigned long addr)
>> +{
>> +	unsigned char *tags;
>> +	unsigned long i, size, max_desc, flags;
>> +	tag_storage_desc_t *tag_desc, *open_desc;
>> +	unsigned long end_addr, hole_start, hole_end;
>> +
>> +	max_desc = PAGE_SIZE/sizeof(tag_storage_desc_t);
>> +	open_desc = NULL;
>> +	hole_start = 0;
>> +	hole_end = ULONG_MAX;
>> +	end_addr = addr + PAGE_SIZE - 1;
>> +
>> +	/* Check if this vma already has tag storage descriptor
>> +	 * allocated for it.
>> +	 */
>> +	spin_lock_irqsave(&mm->context.tag_lock, flags);
>> +	if (mm->context.tag_store) {
>> +		tag_desc = mm->context.tag_store;
>> +
>> +		/* Look for a matching entry for this address. While doing
>> +		 * that, look for the first open slot as well and find
>> +		 * the hole in already allocated range where this request
>> +		 * will fit in.
>> +		 */
>> +		for (i = 0; i < max_desc; i++) {
>> +			if (tag_desc->tag_users == 0) {
>> +				if (open_desc == NULL)
>> +					open_desc = tag_desc;
>> +			} else {
>> +				if ((addr >= tag_desc->start) &&
>> +				    (tag_desc->end >= (addr + PAGE_SIZE - 1))) {
>> +					tag_desc->tag_users++;
>> +					goto out;
>> +				}
>> +			}
>> +			if ((tag_desc->start > end_addr) &&
>> +			    (tag_desc->start < hole_end))
>> +				hole_end = tag_desc->start;
>> +			if ((tag_desc->end < addr) &&
>> +			    (tag_desc->end > hole_start))
>> +				hole_start = tag_desc->end;
>> +			tag_desc++;
>> +		}
>> +
>> +	} else {
>> +		size = sizeof(tag_storage_desc_t)*max_desc;
>> +		mm->context.tag_store = kzalloc(size, GFP_NOIO|__GFP_NOWARN);
> 
> The spin_lock_irqsave() above means that all but level 15 interrupts
> will be disabled when kzalloc() is called.  If kzalloc() can sleep
> there's a risk of deadlock.

I could call kzalloc() with GFP_NOWAIT instead of GFP_NOIO. Would that 
address the risk of deadlock?

> 
> 
>> +		if (mm->context.tag_store == NULL) {
>> +			tag_desc = NULL;
>> +			goto out;
>> +		}
>> +		tag_desc = mm->context.tag_store;
>> +		for (i = 0; i < max_desc; i++, tag_desc++)
>> +			tag_desc->tag_users = 0;
>> +		open_desc = mm->context.tag_store;
>> +		i = 0;
>> +	}
>> +
>> +	/* Check if we ran out of tag storage descriptors */
>> +	if (open_desc == NULL) {
>> +		tag_desc = NULL;
>> +		goto out;
>> +	}
>> +
>> +	/* Mark this tag descriptor slot in use and then initialize it */
>> +	tag_desc = open_desc;
>> +	tag_desc->tag_users = 1;
>> +
>> +	/* Tag storage has not been allocated for this vma and space
>> +	 * is available in tag storage descriptor. Since this page is
>> +	 * being swapped out, there is high probability subsequent pages
>> +	 * in the VMA will be swapped out as well. Allocates pages to
>> +	 * store tags for as many pages in this vma as possible but not
>> +	 * more than TAG_STORAGE_PAGES. Each byte in tag space holds
>> +	 * two ADI tags since each ADI tag is 4 bits. Each ADI tag
>> +	 * covers adi_blksize() worth of addresses. Check if the hole is
>> +	 * big enough to accommodate full address range for using
>> +	 * TAG_STORAGE_PAGES number of tag pages.
>> +	 */
>> +	size = TAG_STORAGE_PAGES * PAGE_SIZE;
>> +	end_addr = addr + (size*2*adi_blksize()) - 1;
> 
> Since size > PAGE_SIZE, end_addr could theoretically overflow >
> 
>> +	if (hole_end < end_addr) {
>> +		/* Available hole is too small on the upper end of
>> +		 * address. Can we expand the range towards the lower
>> +		 * address and maximize use of this slot?
>> +		 */
>> +		unsigned long tmp_addr;
>> +
>> +		end_addr = hole_end - 1;
>> +		tmp_addr = end_addr - (size*2*adi_blksize()) + 1;
> 
> Similarily, tmp_addr may underflow.

I will add checks for these two.

> 
>> +		if (tmp_addr < hole_start) {
>> +			/* Available hole is restricted on lower address
>> +			 * end as well
>> +			 */
>> +			tmp_addr = hole_start + 1;
>> +		}
>> +		addr = tmp_addr;
>> +		size = (end_addr + 1 - addr)/(2*adi_blksize());
>> +		size = (size + (PAGE_SIZE-adi_blksize()))/PAGE_SIZE;
>> +		size = size * PAGE_SIZE;
>> +	}
>> +	tags = kzalloc(size, GFP_NOIO|__GFP_NOWARN);
> 
> Potential deadlock due to PIL=14?

Same as above - call kzalloc() with GFP_NOWAIT?

>> diff --git a/arch/sparc/kernel/etrap_64.S b/arch/sparc/kernel/etrap_64.S
>> index 1276ca2567ba..7be33bf45cff 100644
>> --- a/arch/sparc/kernel/etrap_64.S
>> +++ b/arch/sparc/kernel/etrap_64.S
>> @@ -132,7 +132,33 @@ etrap_save:	save	%g2, -STACK_BIAS, %sp
>> 		stx	%g6, [%sp + PTREGS_OFF + PT_V9_G6]
>> 		stx	%g7, [%sp + PTREGS_OFF + PT_V9_G7]
>> 		or	%l7, %l0, %l7
>> -		sethi	%hi(TSTATE_TSO | TSTATE_PEF), %l0
>> +661:		sethi	%hi(TSTATE_TSO | TSTATE_PEF), %l0
>> +		/*
>> +		 * If userspace is using ADI, it could potentially pass
>> +		 * a pointer with version tag embedded in it. To maintain
>> +		 * the ADI security, we must enable PSTATE.mcde. Userspace
>> +		 * would have already set TTE.mcd in an earlier call to
>> +		 * kernel and set the version tag for the address being
>> +		 * dereferenced. Setting PSTATE.mcde would ensure any
>> +		 * access to userspace data through a system call honors
>> +		 * ADI and does not allow a rogue app to bypass ADI by
>> +		 * using system calls. Setting PSTATE.mcde only affects
>> +		 * accesses to virtual addresses that have TTE.mcd set.
>> +		 * Set PMCDPER to ensure any exceptions caused by ADI
>> +		 * version tag mismatch are exposed before system call
>> +		 * returns to userspace. Setting PMCDPER affects only
>> +		 * writes to virtual addresses that have TTE.mcd set and
>> +		 * have a version tag set as well.
>> +		 */
>> +		.section .sun_m7_1insn_patch, "ax"
>> +		.word	661b
>> +		sethi	%hi(TSTATE_TSO | TSTATE_PEF | TSTATE_MCDE), %l0
>> +		.previous
>> +661:		nop
>> +		.section .sun_m7_1insn_patch, "ax"
>> +		.word	661b
>> +		.word 0xaf902001	/* wrpr %g0, 1, %pmcdper */
> 
> I commented on this on the last patch series revision.  PMCDPER could be
> set once when each CPU is configured rather than every time the kernel
> is entered.  Since it's never cleared, setting it repeatedly unnecessarily
> impacts the performance of etrap.

Yes, you did and I thought I had addressed it in that thread:

">> I considered that possibility. What made me uncomfortable with that 
is there is no way to prevent a driver/module or future code elsewhere 
in kernel from clearing PMCDPER with possibly good reason. If that were 
to happen, setting PMCDPER here ensures kernel will always see 
consistent behavior with system calls. It does come at a cost. Is that 
cost unacceptable to ensure consistent behavior?
> 
> Aren't you still at risk if the thread relinquishes the CPU while in the kernel and is then rescheduled on a CPU where PMCDPER has erroneously been left cleared?  You may need to save and restore PMCDPER as well as MCDPER on context switch, but I don't know if that will cover you completely.
> "

I should add setting PMCDPER to 1 in finish_arch_post_lock_switch() to 
address the possibility you had mentioned.

> 
> Also, there are places in rtrap where PSTATE is set before continuing
> execution in the kernel.  These should also be patched to set TSTATE_MCDE.
> 

I will find and fix those.

>> diff --git a/arch/sparc/kernel/setup_64.c b/arch/sparc/kernel/setup_64.c
>> index 422b17880955..a9da205da394 100644
>> --- a/arch/sparc/kernel/setup_64.c
>> +++ b/arch/sparc/kernel/setup_64.c
>> @@ -240,6 +240,12 @@ void sun4v_patch_1insn_range(struct sun4v_1insn_patch_entry *start,
>> 	}
>> }
>>
>> +void sun_m7_patch_1insn_range(struct sun4v_1insn_patch_entry *start,
>> +			     struct sun4v_1insn_patch_entry *end)
>> +{
>> +	sun4v_patch_1insn_range(start, end);
>> +}
>> +
>> void sun4v_patch_2insn_range(struct sun4v_2insn_patch_entry *start,
>> 			     struct sun4v_2insn_patch_entry *end)
>> {
>> @@ -289,9 +295,12 @@ static void __init sun4v_patch(void)
>> 	sun4v_patch_2insn_range(&__sun4v_2insn_patch,
>> 				&__sun4v_2insn_patch_end);
>> 	if (sun4v_chip_type == SUN4V_CHIP_SPARC_M7 ||
>> -	    sun4v_chip_type == SUN4V_CHIP_SPARC_SN)
>> +	    sun4v_chip_type == SUN4V_CHIP_SPARC_SN) {
>> +		sun_m7_patch_1insn_range(&__sun_m7_1insn_patch,
>> +					 &__sun_m7_1insn_patch_end);
>> 		sun_m7_patch_2insn_range(&__sun_m7_2insn_patch,
>> 					 &__sun_m7_2insn_patch_end);
> 
> Why not call sun4v_patch_1insn_range() and sun4v_patch_2insn_range()
> here instead of adding new functions that just call these functions?

Sounds reasonable, I can change that.

Thanks,
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
