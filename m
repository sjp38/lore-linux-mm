Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8AB266B0070
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 06:22:57 -0400 (EDT)
Received: by wgin8 with SMTP id n8so75394860wgi.0
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 03:22:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i16si15000712wiv.105.2015.04.16.03.22.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Apr 2015 03:22:54 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/4] mm: Gather more PFNs before sending a TLB to flush unmapped pages
Date: Thu, 16 Apr 2015 11:22:45 +0100
Message-Id: <1429179766-26711-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1429179766-26711-1-git-send-email-mgorman@suse.de>
References: <1429179766-26711-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The patch "mm: Send a single IPI to TLB flush multiple pages when unmapping"
would batch 32 pages before sending an IPI. This patch increases the size of
the data structure to hold a pages worth of PFNs before sending an IPI. This
is a trade-off between memory usage and reducing IPIS sent. In the ideal
case where multiple processes are reading large mapped files, this patch
reduces interrupts/second from roughly 180K per second to 60K per second.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/sched.h |  9 +++++----
 kernel/fork.c         |  6 ++++--
 mm/vmscan.c           | 13 +++++++------
 3 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 5c09db02fe78..3e4d3f545005 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1275,16 +1275,17 @@ enum perf_event_task_context {
 	perf_nr_task_contexts,
 };
 
-/* Matches SWAP_CLUSTER_MAX but refined to limit header dependencies */
-#define BATCH_TLBFLUSH_SIZE 32UL
-
 /* Track pages that require TLB flushes */
 struct tlbflush_unmap_batch {
 	struct cpumask cpumask;
 	unsigned long nr_pages;
-	unsigned long pfns[BATCH_TLBFLUSH_SIZE];
+	unsigned long pfns[0];
 };
 
+/* alloc_tlb_ubc() always allocates a page */
+#define BATCH_TLBFLUSH_SIZE \
+	((PAGE_SIZE - sizeof(struct tlbflush_unmap_batch)) / sizeof(unsigned long))
+
 struct task_struct {
 	volatile long state;	/* -1 unrunnable, 0 runnable, >0 stopped */
 	void *stack;
diff --git a/kernel/fork.c b/kernel/fork.c
index 86c872fec9fb..f260663f209a 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -247,8 +247,10 @@ void __put_task_struct(struct task_struct *tsk)
 	put_signal_struct(tsk->signal);
 
 #ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
-	kfree(tsk->tlb_ubc);
-	tsk->tlb_ubc = NULL;
+	if (tsk->tlb_ubc) {
+		free_page((unsigned long)tsk->tlb_ubc);
+		tsk->tlb_ubc = NULL;
+	}
 #endif
 
 	if (!profile_handoff_task(tsk))
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f668c8fa78fd..a8dde281652a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2766,17 +2766,18 @@ out:
 }
 
 #ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
+/*
+ * Allocate the control structure for batch TLB flushing. An allocation
+ * failure is harmless as the reclaimer will send IPIs where necessary.
+ * If the allocation size changes then update BATCH_TLBFLUSH_SIZE.
+ */
 static inline void alloc_tlb_ubc(void)
 {
 	if (current->tlb_ubc)
 		return;
 
-	/*
-	 * Allocate the control structure for batch TLB flushing. Harmless if
-	 * the allocation fails as reclaimer will just send more IPIs.
-	 */
-	current->tlb_ubc = kmalloc(sizeof(struct tlbflush_unmap_batch),
-						GFP_ATOMIC | __GFP_NOWARN);
+	current->tlb_ubc = (struct tlbflush_unmap_batch *)
+				__get_free_page(GFP_KERNEL | __GFP_NOWARN);
 	if (!current->tlb_ubc)
 		return;
 
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
