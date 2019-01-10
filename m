Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A55CC8E0008
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:10:52 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id ay11so6918943plb.20
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 13:10:52 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id d7si71395773pfo.108.2019.01.10.13.10.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 13:10:51 -0800 (PST)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [RFC PATCH v7 16/16] xpfo, mm: Defer TLB flushes for non-current CPUs (x86 only)
Date: Thu, 10 Jan 2019 14:09:48 -0700
Message-Id: <c97fd93699adc018d666c3842ee973cb0acced2c.1547153058.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1547153058.git.khalid.aziz@oracle.com>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1547153058.git.khalid.aziz@oracle.com>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com, torvalds@linux-foundation.org, liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com
Cc: Khalid Aziz <khalid.aziz@oracle.com>, deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com, joao.m.martins@oracle.com, jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

XPFO flushes kernel space TLB entries for pages that are now mapped
in userspace on not only the current CPU but also all other CPUs.
If the number of TLB entries to flush exceeds
tlb_single_page_flush_ceiling, this results in entire TLB neing
flushed on all CPUs. A malicious userspace app can exploit the
dual mapping of a physical page caused by physmap only on the CPU
it is running on. There is no good reason to incur the very high
cost of TLB flush on CPUs that may never run the malicious app or
do not have any TLB entries for the malicious app. The cost of
full TLB flush goes up dramatically on machines with high core
count.

This patch flushes relevant TLB entries for current process or
entire TLB depending upon number of entries for the current CPU
and posts a pending TLB flush on all other CPUs when a page is
unmapped from kernel space and mapped in userspace. This pending
TLB flush is posted for each task separately and TLB is flushed on
a CPU when a task is scheduled on it that has a pending TLB flush
posted for that CPU. This patch does two things - (1) it
potentially aggregates multiple TLB flushes into one, and (2) it
avoids TLB flush on CPUs that never run the task that caused a TLB
flush. This has very significant impact especially on machines
with large core counts. To illustrate this, kernel was compiled
with -j on two classes of machines - a server with high core count
and large amount of memory, and a desktop class machine with more
modest specs. System time from "make -j" from vanilla 4.20 kernel,
4.20 with XPFO patches before applying this patch and after
applying this patch are below:

Hardware: 96-core Intel Xeon Platinum 8160 CPU @ 2.10GHz, 768 GB RAM
make -j60 all

4.20				915.183s
4.19+XPFO			24129.354s	26.366x
4.19+XPFO+Deferred flush	1216.987s	 1.330xx

Hardware: 4-core Intel Core i5-3550 CPU @ 3.30GHz, 8G RAM
make -j4 all

4.20				607.671s
4.19+XPFO			1588.646s	2.614x
4.19+XPFO+Deferred flush	794.473s	1.307xx

This patch could use more optimization. For instance, it posts a
pending full TLB flush for other CPUs even when number of TLB
entries being flushed does not exceed tlb_single_page_flush_ceiling.
Batching more TLB entry flushes, as was suggested for earlier
version of these patches, can help reduce these cases. This same
code should be implemented for other architectures as well once
finalized.

Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
---
 arch/x86/include/asm/tlbflush.h |  1 +
 arch/x86/mm/tlb.c               | 27 +++++++++++++++++++++++++++
 arch/x86/mm/xpfo.c              |  2 +-
 include/linux/sched.h           |  9 +++++++++
 4 files changed, 38 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index f4204bf377fc..92d23629d01d 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -561,6 +561,7 @@ extern void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 				unsigned long end, unsigned int stride_shift,
 				bool freed_tables);
 extern void flush_tlb_kernel_range(unsigned long start, unsigned long end);
+extern void xpfo_flush_tlb_kernel_range(unsigned long start, unsigned long end);
 
 static inline void flush_tlb_page(struct vm_area_struct *vma, unsigned long a)
 {
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 03b6b4c2238d..b04a501c850b 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -319,6 +319,15 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 		__flush_tlb_all();
 	}
 #endif
+
+	/* If there is a pending TLB flush for this CPU due to XPFO
+	 * flush, do it now.
+	 */
+	if (tsk && cpumask_test_and_clear_cpu(cpu, &tsk->pending_xpfo_flush)) {
+		count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
+		__flush_tlb_all();
+	}
+
 	this_cpu_write(cpu_tlbstate.is_lazy, false);
 
 	/*
@@ -801,6 +810,24 @@ void flush_tlb_kernel_range(unsigned long start, unsigned long end)
 	}
 }
 
+void xpfo_flush_tlb_kernel_range(unsigned long start, unsigned long end)
+{
+
+	/* Balance as user space task's flush, a bit conservative */
+	if (end == TLB_FLUSH_ALL ||
+	    (end - start) > tlb_single_page_flush_ceiling << PAGE_SHIFT) {
+		do_flush_tlb_all(NULL);
+	} else {
+		struct flush_tlb_info info;
+
+		info.start = start;
+		info.end = end;
+		do_kernel_range_flush(&info);
+	}
+	cpumask_setall(&current->pending_xpfo_flush);
+	cpumask_clear_cpu(smp_processor_id(), &current->pending_xpfo_flush);
+}
+
 void arch_tlbbatch_flush(struct arch_tlbflush_unmap_batch *batch)
 {
 	struct flush_tlb_info info = {
diff --git a/arch/x86/mm/xpfo.c b/arch/x86/mm/xpfo.c
index bcdb2f2089d2..5aa17cb2c813 100644
--- a/arch/x86/mm/xpfo.c
+++ b/arch/x86/mm/xpfo.c
@@ -110,7 +110,7 @@ inline void xpfo_flush_kernel_tlb(struct page *page, int order)
 		return;
 	}
 
-	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
+	xpfo_flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
 }
 
 /* Convert a user space virtual address to a physical address.
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 291a9bd5b97f..ba298be3b5a1 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1206,6 +1206,15 @@ struct task_struct {
 	unsigned long			prev_lowest_stack;
 #endif
 
+	/*
+	 * When a full TLB flush is needed to flush stale TLB entries
+	 * for pages that have been mapped into userspace and unmapped
+	 * from kernel space, this TLB flush will be delayed until the
+	 * task is scheduled on that CPU. Keep track of CPUs with
+	 * pending full TLB flush forced by xpfo.
+	 */
+	cpumask_t			pending_xpfo_flush;
+
 	/*
 	 * New fields for task_struct should be added above here, so that
 	 * they are included in the randomized portion of task_struct.
-- 
2.17.1
