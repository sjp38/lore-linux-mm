Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2EF856B03A5
	for <linux-mm@kvack.org>; Sun,  7 May 2017 08:39:16 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u21so5826758pgn.5
        for <linux-mm@kvack.org>; Sun, 07 May 2017 05:39:16 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id y32si10659693plh.238.2017.05.07.05.39.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 May 2017 05:39:15 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 06/10] x86/mm: Refactor flush_tlb_mm_range() to merge local and remote cases
Date: Sun,  7 May 2017 05:38:35 -0700
Message-Id: <93331aabeabecaae30cf1179b467d744a786c9de.1494160201.git.luto@kernel.org>
In-Reply-To: <cover.1494160201.git.luto@kernel.org>
References: <cover.1494160201.git.luto@kernel.org>
In-Reply-To: <cover.1494160201.git.luto@kernel.org>
References: <cover.1494160201.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

The local flush path is very similar to the remote flush path.
Merge them.

This is intended to make no difference to behavior whatsoever.  It
removes some code and will make future changes to the flushing
mechanics simpler.

This patch does remove one small optimization: flush_tlb_mm_range()
now has an unconditional smp_mb() instead of using MOV to CR3 or
INVLPG as a full barrier when applicable.  I think this is okay for
a few reasons.  First, smp_mb() is quite cheap compared to the cost
of a TLB flush.  Second, this rearrangement makes a bigger
optimization available: with some work on the SMP function call
code, we could do the local and remote flushes in parallel.  Third,
I'm planning a rework of the TLB flush algorithm that will require
an atomic operation at the beginning of each flush, and that
operation will replace the smp_mb().

Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Nadav Amit <namit@vmware.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/tlbflush.h |   1 -
 arch/x86/mm/tlb.c               | 113 +++++++++++++++++-----------------------
 2 files changed, 48 insertions(+), 66 deletions(-)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 6d236c1aff89..c600d2d4a501 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -225,7 +225,6 @@ static inline void __flush_tlb_one(unsigned long addr)
  * ..but the i386 has somewhat limited tlb flushing capabilities,
  * and page-granular flushes are available only on i486 and up.
  */
-
 struct flush_tlb_info {
 	struct mm_struct *mm;
 	unsigned long start;
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 3143c9a180e5..12b8812e8926 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -216,22 +216,9 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
  * write/read ordering problems.
  */
 
-/*
- * TLB flush funcation:
- * 1) Flush the tlb entries if the cpu uses the mm that's being flushed.
- * 2) Leave the mm if we are in the lazy tlb mode.
- */
-static void flush_tlb_func(void *info)
+static void flush_tlb_func_common(const struct flush_tlb_info *f,
+				  bool local, enum tlb_flush_reason reason)
 {
-	const struct flush_tlb_info *f = info;
-
-	inc_irq_stat(irq_tlb_count);
-
-	if (f->mm && f->mm != this_cpu_read(cpu_tlbstate.active_mm))
-		return;
-
-	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
-
 	if (this_cpu_read(cpu_tlbstate.state) != TLBSTATE_OK) {
 		leave_mm(smp_processor_id());
 		return;
@@ -239,7 +226,9 @@ static void flush_tlb_func(void *info)
 
 	if (f->end == TLB_FLUSH_ALL) {
 		local_flush_tlb();
-		trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, TLB_FLUSH_ALL);
+		if (local)
+			count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
+		trace_tlb_flush(reason, TLB_FLUSH_ALL);
 	} else {
 		unsigned long addr;
 		unsigned long nr_pages =
@@ -249,10 +238,32 @@ static void flush_tlb_func(void *info)
 			__flush_tlb_single(addr);
 			addr += PAGE_SIZE;
 		}
-		trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, nr_pages);
+		if (local)
+			count_vm_tlb_events(NR_TLB_LOCAL_FLUSH_ONE, nr_pages);
+		trace_tlb_flush(reason, nr_pages);
 	}
 }
 
+static void flush_tlb_func_local(void *info, enum tlb_flush_reason reason)
+{
+	const struct flush_tlb_info *f = info;
+
+	flush_tlb_func_common(f, true, reason);
+}
+
+static void flush_tlb_func_remote(void *info)
+{
+	const struct flush_tlb_info *f = info;
+
+	inc_irq_stat(irq_tlb_count);
+
+	if (f->mm && f->mm != this_cpu_read(cpu_tlbstate.active_mm))
+		return;
+
+	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
+	flush_tlb_func_common(f, false, TLB_REMOTE_SHOOTDOWN);
+}
+
 void native_flush_tlb_others(const struct cpumask *cpumask,
 			     const struct flush_tlb_info *info)
 {
@@ -269,11 +280,11 @@ void native_flush_tlb_others(const struct cpumask *cpumask,
 		cpu = smp_processor_id();
 		cpumask = uv_flush_tlb_others(cpumask, info);
 		if (cpumask)
-			smp_call_function_many(cpumask, flush_tlb_func,
+			smp_call_function_many(cpumask, flush_tlb_func_remote,
 					       (void *)info, 1);
 		return;
 	}
-	smp_call_function_many(cpumask, flush_tlb_func,
+	smp_call_function_many(cpumask, flush_tlb_func_remote,
 			       (void *)info, 1);
 }
 
@@ -292,61 +303,33 @@ static unsigned long tlb_single_page_flush_ceiling __read_mostly = 33;
 void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 				unsigned long end, unsigned long vmflag)
 {
-	unsigned long addr;
-	struct flush_tlb_info info;
-	/* do a global flush by default */
-	unsigned long base_pages_to_flush = TLB_FLUSH_ALL;
-
-	preempt_disable();
+	int cpu;
 
-	if ((end != TLB_FLUSH_ALL) && !(vmflag & VM_HUGETLB))
-		base_pages_to_flush = (end - start) >> PAGE_SHIFT;
-	if (base_pages_to_flush > tlb_single_page_flush_ceiling)
-		base_pages_to_flush = TLB_FLUSH_ALL;
-
-	if (current->active_mm != mm) {
-		/* Synchronize with switch_mm. */
-		smp_mb();
-
-		goto out;
-	}
-
-	if (this_cpu_read(cpu_tlbstate.state) != TLBSTATE_OK) {
-		leave_mm(smp_processor_id());
+	struct flush_tlb_info info = {
+		.mm = mm,
+	};
 
-		/* Synchronize with switch_mm. */
-		smp_mb();
+	cpu = get_cpu();
 
-		goto out;
-	}
+	/* Synchronize with switch_mm. */
+	smp_mb();
 
-	/*
-	 * Both branches below are implicit full barriers (MOV to CR or
-	 * INVLPG) that synchronize with switch_mm.
-	 */
-	if (base_pages_to_flush == TLB_FLUSH_ALL) {
-		count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
-		local_flush_tlb();
+	/* Should we flush just the requested range? */
+	if ((end != TLB_FLUSH_ALL) &&
+	    !(vmflag & VM_HUGETLB) &&
+	    ((end - start) >> PAGE_SHIFT) <= tlb_single_page_flush_ceiling) {
+		info.start = start;
+		info.end = end;
 	} else {
-		/* flush range by one by one 'invlpg' */
-		for (addr = start; addr < end;	addr += PAGE_SIZE) {
-			count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ONE);
-			__flush_tlb_single(addr);
-		}
-	}
-	trace_tlb_flush(TLB_LOCAL_MM_SHOOTDOWN, base_pages_to_flush);
-out:
-	info.mm = mm;
-	if (base_pages_to_flush == TLB_FLUSH_ALL) {
 		info.start = 0UL;
 		info.end = TLB_FLUSH_ALL;
-	} else {
-		info.start = start;
-		info.end = end;
 	}
-	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
+
+	if (mm == current->active_mm)
+		flush_tlb_func_local(&info, TLB_LOCAL_MM_SHOOTDOWN);
+	if (cpumask_any_but(mm_cpumask(mm), cpu) < nr_cpu_ids)
 		flush_tlb_others(mm_cpumask(mm), &info);
-	preempt_enable();
+	put_cpu();
 }
 
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
