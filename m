Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id AE64C6B006C
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 13:32:27 -0400 (EDT)
Received: by wgv5 with SMTP id 5so18713402wgv.1
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 10:32:27 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ei5si4298646wid.118.2015.06.09.10.32.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Jun 2015 10:32:10 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 4/4] mm: Send one IPI per CPU to TLB flush pages that were recently unmapped
Date: Tue,  9 Jun 2015 18:31:58 +0100
Message-Id: <1433871118-15207-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1433871118-15207-1-git-send-email-mgorman@suse.de>
References: <1433871118-15207-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

When unmapping pages, an IPI is sent to flush all TLB entries on CPUs that
potentially have a valid TLB entry. There are many circumstances where
this happens but the obvious one is kswapd reclaiming pages belonging to a
running process as kswapd and the task are likely running on separate CPUs.
This forces processes running the affected CPUs to refill their TLB entries.
This is an unpredictable cost as it heavily depends on the workloads,
the timing and the exact CPU used.

This patch uses a structure similar in principle to a pagevec to collect
a list of PFNs and CPUs that require flushing. It then sends one IPI per
CPU that was mapping any of those pages to flush the list of PFNs. A new
TLB flush helper is required for this and one is added for x86. Other
architectures will need to decide if batching like this is both safe and
worth the overhead.

There is a direct cost to tracking the PFNs both in memory and the cost of
the individual PFN flushes.  In the absolute worst case, the kernel flushes
individual PFNs and none of the active TLB entries were being used. Hence,
this results reflect the full cost without any of the benefit of preserving
existing entries.

On a 4-socket machine the results were

                                        4.1.0-rc6          4.1.0-rc6
                                    batchdirty-v6      batchunmap-v6
Ops lru-file-mmap-read-elapsed   121.27 (  0.00%)   118.79 (  2.05%)

           4.1.0-rc6      4.1.0-rc6
        batchdirty-v6 batchunmap-v6
User          620.84         608.48
System       4245.35        4152.89
Elapsed       122.65         120.15

In this case the workload completed faster and there was less CPU overhead
but as it's a NUMA machine there are a lot of factors at play. It's easier
to quantify on a single socket machine;

                                        4.1.0-rc6          4.1.0-rc6
                                    batchdirty-v6      batchunmap-v6
Ops lru-file-mmap-read-elapsed    20.35 (  0.00%)    21.52 ( -5.75%)

           4.1.0-rc6   4.1.0-rc6
        batchdirty-v6r5batchunmap-v6r5
User           58.02       60.70
System         77.57       81.92
Elapsed        22.14       23.16

That shows the workload takes 5.75% longer to complete with a similar
increase in the system CPU usage.

It is expected that there is overhead to tracking the PFNs and flushing
individual pages. This can be quantified but we cannot quantify the
indirect savings due to active unrelated TLB entries being preserved.
Whether this matters depends on whether the workload was using those
entries and if they would be used before a context switch but targeting
the TLB flushes is the conservative and safer choice.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/x86/include/asm/tlbflush.h |  2 ++
 include/linux/sched.h           | 12 ++++++++++--
 init/Kconfig                    | 10 ++++------
 mm/rmap.c                       | 25 +++++++++++++------------
 4 files changed, 29 insertions(+), 20 deletions(-)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index cd791948b286..10c197a649f5 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -152,6 +152,8 @@ static inline void __flush_tlb_one(unsigned long addr)
  * and page-granular flushes are available only on i486 and up.
  */
 
+#define flush_local_tlb_addr(addr) __flush_tlb_single(addr)
+
 #ifndef CONFIG_SMP
 
 /* "_up" is for UniProcessor.
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 6b787a7f6c38..4dbffe0a1868 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1289,6 +1289,9 @@ enum perf_event_task_context {
 	perf_nr_task_contexts,
 };
 
+/* Matches SWAP_CLUSTER_MAX but refined to limit header dependencies */
+#define BATCH_TLBFLUSH_SIZE 32UL
+
 /* Track pages that require TLB flushes */
 struct tlbflush_unmap_batch {
 	/*
@@ -1297,8 +1300,13 @@ struct tlbflush_unmap_batch {
 	 */
 	struct cpumask cpumask;
 
-	/* True if any bit in cpumask is set */
-	bool flush_required;
+	/*
+	 * The number and list of pfns to be flushed. PFNs are tracked instead
+	 * of struct pages to avoid multiple page->pfn lookups by each CPU that
+	 * receives an IPI in percpu_flush_tlb_batch_pages.
+	 */
+	unsigned int nr_pages;
+	unsigned long pfns[BATCH_TLBFLUSH_SIZE];
 
 	/*
 	 * If true then the PTE was dirty when unmapped. The entry must be
diff --git a/init/Kconfig b/init/Kconfig
index 6e6fa4842250..095b3d470c3f 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -904,12 +904,10 @@ config ARCH_SUPPORTS_NUMA_BALANCING
 	bool
 
 #
-# For architectures that prefer to flush all TLBs after a number of pages
-# are unmapped instead of sending one IPI per page to flush. The architecture
-# must provide guarantees on what happens if a clean TLB cache entry is
-# written after the unmap. Details are in mm/rmap.c near the check for
-# should_defer_flush. The architecture should also consider if the full flush
-# and the refill costs are offset by the savings of sending fewer IPIs.
+# For architectures that have a local TLB flush for a PFN without knowledge
+# of the VMA. The architecture must provide guarantees on what happens if
+# a clean TLB cache entry is written after the unmap. Details are in mm/rmap.c
+# near the check for should_defer_flush.
 config ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH
 	bool
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 1e36b2fb3e95..0085b0eb720c 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -586,15 +586,12 @@ vma_address(struct page *page, struct vm_area_struct *vma)
 #ifdef CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH
 static void percpu_flush_tlb_batch_pages(void *data)
 {
-	/*
-	 * All TLB entries are flushed on the assumption that it is
-	 * cheaper to flush all TLBs and let them be refilled than
-	 * flushing individual PFNs. Note that we do not track mm's
-	 * to flush as that might simply be multiple full TLB flushes
-	 * for no gain.
-	 */
+	struct tlbflush_unmap_batch *tlb_ubc = data;
+	unsigned int i;
+
 	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
-	local_flush_tlb();
+	for (i = 0; i < tlb_ubc->nr_pages; i++)
+		flush_local_tlb_addr(tlb_ubc->pfns[i] << PAGE_SHIFT);
 }
 
 /*
@@ -608,10 +605,10 @@ void try_to_unmap_flush(void)
 	struct tlbflush_unmap_batch *tlb_ubc = current->tlb_ubc;
 	int cpu;
 
-	if (!tlb_ubc || !tlb_ubc->flush_required)
+	if (!tlb_ubc || !tlb_ubc->nr_pages)
 		return;
 
-	trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, -1UL);
+	trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, tlb_ubc->nr_pages);
 
 	cpu = get_cpu();
 	if (cpumask_test_cpu(cpu, &tlb_ubc->cpumask))
@@ -622,7 +619,7 @@ void try_to_unmap_flush(void)
 			percpu_flush_tlb_batch_pages, (void *)tlb_ubc, true);
 	}
 	cpumask_clear(&tlb_ubc->cpumask);
-	tlb_ubc->flush_required = false;
+	tlb_ubc->nr_pages = 0;
 	tlb_ubc->writable = false;
 	put_cpu();
 }
@@ -642,7 +639,8 @@ static void set_tlb_ubc_flush_pending(struct mm_struct *mm,
 	struct tlbflush_unmap_batch *tlb_ubc = current->tlb_ubc;
 
 	cpumask_or(&tlb_ubc->cpumask, &tlb_ubc->cpumask, mm_cpumask(mm));
-	tlb_ubc->flush_required = true;
+	tlb_ubc->pfns[tlb_ubc->nr_pages] = page_to_pfn(page);
+	tlb_ubc->nr_pages++;
 
 	/*
 	 * If the PTE was dirty then it's best to assume it's writable. The
@@ -651,6 +649,9 @@ static void set_tlb_ubc_flush_pending(struct mm_struct *mm,
 	 */
 	if (writable)
 		tlb_ubc->writable = true;
+
+	if (tlb_ubc->nr_pages == BATCH_TLBFLUSH_SIZE)
+		try_to_unmap_flush();
 }
 
 /*
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
