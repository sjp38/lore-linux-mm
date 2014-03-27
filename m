Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2A7CF6B0031
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 14:42:11 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id c41so3188897eek.22
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 11:42:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id r9si4586761eew.78.2014.03.27.11.42.08
        for <linux-mm@kvack.org>;
        Thu, 27 Mar 2014 11:42:09 -0700 (PDT)
Message-ID: <533470F7.4000406@redhat.com>
Date: Thu, 27 Mar 2014 14:41:59 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch]x86: clearing access bit don't flush tlb
References: <20140326223034.GA31713@kernel.org> <53336907.1050105@redhat.com> <20140327171237.GA9490@kernel.org>
In-Reply-To: <20140327171237.GA9490@kernel.org>
Content-Type: multipart/mixed;
 boundary="------------090300070802020406070101"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, mel@csn.ul.ie

This is a multi-part message in MIME format.
--------------090300070802020406070101
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 03/27/2014 01:12 PM, Shaohua Li wrote:
> On Wed, Mar 26, 2014 at 07:55:51PM -0400, Rik van Riel wrote:
>> On 03/26/2014 06:30 PM, Shaohua Li wrote:
>>>
>>> I posted this patch a year ago or so, but it gets lost. Repost it here to check
>>> if we can make progress this time.
>>
>> I believe we can make progress. However, I also
>> believe the code could be enhanced to address a
>> concern that Hugh raised last time this was
>> proposed...
>>
>>> And according to intel manual, tlb has less than 1k entries, which covers < 4M
>>> memory. In today's system, several giga byte memory is normal. After page
>>> reclaim clears pte access bit and before cpu access the page again, it's quite
>>> unlikely this page's pte is still in TLB. And context swich will flush tlb too.
>>> The chance skiping tlb flush to impact page reclaim should be very rare.
>>
>> Context switch to a kernel thread does not result in a
>> TLB flush, due to the lazy TLB code.
>>
>> While I agree with you that clearing the TLB right at
>> the moment the accessed bit is cleared in a PTE is
>> not necessary, I believe it would be good to clear
>> the TLB on affected CPUs relatively soon, maybe at the
>> next time schedule is called?
>>
>>> --- linux.orig/arch/x86/mm/pgtable.c	2014-03-27 05:22:08.572100549 +0800
>>> +++ linux/arch/x86/mm/pgtable.c	2014-03-27 05:46:12.456131121 +0800
>>> @@ -399,13 +399,12 @@ int pmdp_test_and_clear_young(struct vm_
>>>   int ptep_clear_flush_young(struct vm_area_struct *vma,
>>>   			   unsigned long address, pte_t *ptep)
>>>   {
>>> -	int young;
>>> -
>>> -	young = ptep_test_and_clear_young(vma, address, ptep);
>>> -	if (young)
>>> -		flush_tlb_page(vma, address);
>>> -
>>> -	return young;
>>> +	/*
>>> +	 * In X86, clearing access bit without TLB flush doesn't cause data
>>> +	 * corruption. Doing this could cause wrong page aging and so hot pages
>>> +	 * are reclaimed, but the chance should be very rare.
>>> +	 */
>>> +	return ptep_test_and_clear_young(vma, address, ptep);
>>>   }
>>
>>
>> At this point, we could use vma->vm_mm->cpu_vm_mask_var to
>> set (or clear) some bit in the per-cpu data of each CPU that
>> has active/valid tlb state for the mm in question.
>>
>> I could see using cpu_tlbstate.state for this, or maybe
>> another variable in cpu_tlbstate, so switch_mm will load
>> both items with the same cache line.
>>
>> At schedule time, the function switch_mm() can examine that
>> variable (it already touches that data, anyway), and flush
>> the TLB even if prev==next.
>>
>> I suspect that would be both low overhead enough to get you
>> the performance gains you want, and address the concern that
>> we do want to flush the TLB at some point.
>>
>> Does that sound reasonable?
>
> So looks what you suggested is to force tlb flush for a mm with access bit
> cleared in two corner cases:
> 1. lazy tlb flush
> 2. context switch between threads from one process
>
> Am I missing anything? I'm wonering if we should care about these corner cases.

I believe the corner case is relatively rare, but I also
suspect that your patch could fail pretty badly in some
of those cases, and the fix is easy...

> On the other hand, a thread might run long time without schedule. If the corner
> cases are an issue, the long run thread is a severer issue. My point is context
> switch does provide a safeguard, but we don't depend on it. The whole theory at
> the back of this patch is page which has access bit cleared is unlikely
> accessed again when its pte entry is still in tlb cache.

On the contrary, a TLB with a good cache policy should
retain the most actively used entries, in favor of
less actively used ones.

That means the pages we care most about keeping, are
the ones also most at danger of not having the accessed
bit flushed to memory.

Does the attached (untested) patch look reasonable?




--------------090300070802020406070101
Content-Type: text/x-patch;
 name="flush_young_lazy_tlb.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="flush_young_lazy_tlb.patch"


Signed-off-by: Rik van Riel <riel@redhat.com>
---
 arch/x86/include/asm/mmu_context.h |  5 ++++-
 arch/x86/include/asm/tlbflush.h    | 12 ++++++++++++
 arch/x86/mm/pgtable.c              |  9 ++++++---
 3 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index be12c53..665d98b 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -39,6 +39,7 @@ static inline void switch_mm(struct mm_struct *prev, struct mm_struct *next,
 #ifdef CONFIG_SMP
 		this_cpu_write(cpu_tlbstate.state, TLBSTATE_OK);
 		this_cpu_write(cpu_tlbstate.active_mm, next);
+		this_cpu_write(cpu_tlbstate.force_flush, false);
 #endif
 		cpumask_set_cpu(cpu, mm_cpumask(next));
 
@@ -57,7 +58,8 @@ static inline void switch_mm(struct mm_struct *prev, struct mm_struct *next,
 		this_cpu_write(cpu_tlbstate.state, TLBSTATE_OK);
 		BUG_ON(this_cpu_read(cpu_tlbstate.active_mm) != next);
 
-		if (!cpumask_test_cpu(cpu, mm_cpumask(next))) {
+		if (!cpumask_test_cpu(cpu, mm_cpumask(next)) ||
+				this_cpu_read(cpu_tlbstate.force_flush)) {
 			/*
 			 * On established mms, the mm_cpumask is only changed
 			 * from irq context, from ptep_clear_flush() while in
@@ -70,6 +72,7 @@ static inline void switch_mm(struct mm_struct *prev, struct mm_struct *next,
 			 * tlb flush IPI delivery. We must reload CR3
 			 * to make sure to use no freed page tables.
 			 */
+			this_cpu_write(cpu_tlbstate.force_flush, false);
 			load_cr3(next->pgd);
 			load_LDT_nolock(&next->context);
 		}
diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 04905bf..f2cda2c 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -151,6 +151,10 @@ static inline void reset_lazy_tlbstate(void)
 {
 }
 
+static inline void tlb_set_force_flush(int cpu)
+{
+}
+
 static inline void flush_tlb_kernel_range(unsigned long start,
 					  unsigned long end)
 {
@@ -187,6 +191,7 @@ void native_flush_tlb_others(const struct cpumask *cpumask,
 struct tlb_state {
 	struct mm_struct *active_mm;
 	int state;
+	bool force_flush;
 };
 DECLARE_PER_CPU_SHARED_ALIGNED(struct tlb_state, cpu_tlbstate);
 
@@ -196,6 +201,13 @@ static inline void reset_lazy_tlbstate(void)
 	this_cpu_write(cpu_tlbstate.active_mm, &init_mm);
 }
 
+static inline void tlb_set_force_flush(int cpu)
+{
+	struct tlb_state *percputlb= &per_cpu(cpu_tlbstate, cpu);
+	if (percputlb->force_flush == false)
+		percputlb->force_flush = true;
+}
+
 #endif	/* SMP */
 
 #ifndef CONFIG_PARAVIRT
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index c96314a..dcd26e9 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -4,6 +4,7 @@
 #include <asm/pgtable.h>
 #include <asm/tlb.h>
 #include <asm/fixmap.h>
+#include <asm/tlbflush.h>
 
 #define PGALLOC_GFP GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO
 
@@ -399,11 +400,13 @@ int pmdp_test_and_clear_young(struct vm_area_struct *vma,
 int ptep_clear_flush_young(struct vm_area_struct *vma,
 			   unsigned long address, pte_t *ptep)
 {
-	int young;
+	int young, cpu;
 
 	young = ptep_test_and_clear_young(vma, address, ptep);
-	if (young)
-		flush_tlb_page(vma, address);
+	if (young) {
+		for_each_cpu(cpu, vma->vm_mm->cpu_vm_mask_var)
+			tlb_set_force_flush(cpu);
+	}
 
 	return young;
 }

--------------090300070802020406070101--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
