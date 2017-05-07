Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CC9216B039F
	for <linux-mm@kvack.org>; Sun,  7 May 2017 08:39:01 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e64so42881889pfd.3
        for <linux-mm@kvack.org>; Sun, 07 May 2017 05:39:01 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id i3si10611180pfi.409.2017.05.07.05.39.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 May 2017 05:39:00 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 03/10] x86/mm: Make the batched unmap TLB flush API more generic
Date: Sun,  7 May 2017 05:38:32 -0700
Message-Id: <983c5ee661d8fe8a70c596c4e77076d11ce3f80a.1494160201.git.luto@kernel.org>
In-Reply-To: <cover.1494160201.git.luto@kernel.org>
References: <cover.1494160201.git.luto@kernel.org>
In-Reply-To: <cover.1494160201.git.luto@kernel.org>
References: <cover.1494160201.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Sasha Levin <sasha.levin@oracle.com>

try_to_unmap_flush() used to open-code a rather x86-centric flush
sequence: local_flush_tlb() + flush_tlb_others().  Rearrange the
code so that the arch (only x86 for now) provides
arch_tlbbatch_add_mm() and arch_tlbbatch_flush() and the core code
calls those functions instead.

I'll want this for x86 because, to enable address space ids, I can't
support the flush_tlb_others() mode used by exising
try_to_unmap_flush() implementation with good performance.  I can
support the new API fairly easily, though.

I imagine that other architectures may be in a similar position.
Architectures with strong remote flush primitives (arm64?) may have
even worse performance problems with flush_tlb_others() the way that
try_to_unmap_flush() uses it.

Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Nadav Amit <namit@vmware.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/tlbbatch.h | 16 ++++++++++++++++
 arch/x86/include/asm/tlbflush.h |  8 ++++++++
 arch/x86/mm/tlb.c               | 17 +++++++++++++++++
 include/linux/mm_types_task.h   | 15 +++++++++++----
 mm/rmap.c                       | 15 +--------------
 5 files changed, 53 insertions(+), 18 deletions(-)
 create mode 100644 arch/x86/include/asm/tlbbatch.h

diff --git a/arch/x86/include/asm/tlbbatch.h b/arch/x86/include/asm/tlbbatch.h
new file mode 100644
index 000000000000..01a6de16fb96
--- /dev/null
+++ b/arch/x86/include/asm/tlbbatch.h
@@ -0,0 +1,16 @@
+#ifndef _ARCH_X86_TLBBATCH_H
+#define _ARCH_X86_TLBBATCH_H
+
+#include <linux/cpumask.h>
+
+#ifdef CONFIG_SMP
+struct arch_tlbflush_unmap_batch {
+	/*
+	 * Each bit set is a CPU that potentially has a TLB entry for one of
+	 * the PFNs being flushed..
+	 */
+	struct cpumask cpumask;
+};
+#endif
+
+#endif /* _ARCH_X86_TLBBATCH_H */
diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 5ed64cdaf536..df71e3f2fe4d 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -329,6 +329,14 @@ static inline void reset_lazy_tlbstate(void)
 	this_cpu_write(cpu_tlbstate.active_mm, &init_mm);
 }
 
+static inline void arch_tlbbatch_add_mm(struct arch_tlbflush_unmap_batch *batch,
+					struct mm_struct *mm)
+{
+	cpumask_or(&batch->cpumask, &batch->cpumask, mm_cpumask(mm));
+}
+
+extern void arch_tlbbatch_flush(struct arch_tlbflush_unmap_batch *batch);
+
 #endif	/* SMP */
 
 #ifndef CONFIG_PARAVIRT
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 4d303864b310..743e4c6b4529 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -395,6 +395,23 @@ void flush_tlb_kernel_range(unsigned long start, unsigned long end)
 	}
 }
 
+void arch_tlbbatch_flush(struct arch_tlbflush_unmap_batch *batch)
+{
+	int cpu = get_cpu();
+
+	if (cpumask_test_cpu(cpu, &batch->cpumask)) {
+		count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
+		local_flush_tlb();
+		trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
+	}
+
+	if (cpumask_any_but(&batch->cpumask, cpu) < nr_cpu_ids)
+		flush_tlb_others(&batch->cpumask, NULL, 0, TLB_FLUSH_ALL);
+	cpumask_clear(&batch->cpumask);
+
+	put_cpu();
+}
+
 static ssize_t tlbflush_read_file(struct file *file, char __user *user_buf,
 			     size_t count, loff_t *ppos)
 {
diff --git a/include/linux/mm_types_task.h b/include/linux/mm_types_task.h
index 136dfdf63ba1..fc412fbd80bd 100644
--- a/include/linux/mm_types_task.h
+++ b/include/linux/mm_types_task.h
@@ -14,6 +14,10 @@
 
 #include <asm/page.h>
 
+#ifdef CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH
+#include <asm/tlbbatch.h>
+#endif
+
 #define USE_SPLIT_PTE_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS)
 #define USE_SPLIT_PMD_PTLOCKS	(USE_SPLIT_PTE_PTLOCKS && \
 		IS_ENABLED(CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK))
@@ -67,12 +71,15 @@ struct page_frag {
 struct tlbflush_unmap_batch {
 #ifdef CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH
 	/*
-	 * Each bit set is a CPU that potentially has a TLB entry for one of
-	 * the PFNs being flushed. See set_tlb_ubc_flush_pending().
+	 * The arch code makes the following promise: generic code can modify a
+	 * PTE, then call arch_tlbbatch_add_mm() (which internally provides all
+	 * needed barriers), then call arch_tlbbatch_flush(), and the entries
+	 * will be flushed on all CPUs by the time that arch_tlbbatch_flush()
+	 * returns.
 	 */
-	struct cpumask cpumask;
+	struct arch_tlbflush_unmap_batch arch;
 
-	/* True if any bit in cpumask is set */
+	/* True if a flush is needed. */
 	bool flush_required;
 
 	/*
diff --git a/mm/rmap.c b/mm/rmap.c
index f6838015810f..2e568c82f477 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -579,25 +579,12 @@ void page_unlock_anon_vma_read(struct anon_vma *anon_vma)
 void try_to_unmap_flush(void)
 {
 	struct tlbflush_unmap_batch *tlb_ubc = &current->tlb_ubc;
-	int cpu;
 
 	if (!tlb_ubc->flush_required)
 		return;
 
-	cpu = get_cpu();
-
-	if (cpumask_test_cpu(cpu, &tlb_ubc->cpumask)) {
-		count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
-		local_flush_tlb();
-		trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
-	}
-
-	if (cpumask_any_but(&tlb_ubc->cpumask, cpu) < nr_cpu_ids)
-		flush_tlb_others(&tlb_ubc->cpumask, NULL, 0, TLB_FLUSH_ALL);
-	cpumask_clear(&tlb_ubc->cpumask);
 	tlb_ubc->flush_required = false;
 	tlb_ubc->writable = false;
-	put_cpu();
 }
 
 /* Flush iff there are potentially writable TLB entries that can race with IO */
@@ -613,7 +600,7 @@ static void set_tlb_ubc_flush_pending(struct mm_struct *mm, bool writable)
 {
 	struct tlbflush_unmap_batch *tlb_ubc = &current->tlb_ubc;
 
-	cpumask_or(&tlb_ubc->cpumask, &tlb_ubc->cpumask, mm_cpumask(mm));
+	arch_tlbbatch_add_mm(&tlb_ubc->arch, mm);
 	tlb_ubc->flush_required = true;
 
 	/*
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
