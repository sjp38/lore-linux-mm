Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 466A4900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 06:41:37 -0400 (EDT)
Received: by wgso17 with SMTP id o17so209034898wgs.1
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 03:41:36 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s1si20702621wiy.107.2015.04.21.03.41.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Apr 2015 03:41:28 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 5/6] mm, migrate: Batch TLB flushing when unmapping pages for migration
Date: Tue, 21 Apr 2015 11:41:19 +0100
Message-Id: <1429612880-21415-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1429612880-21415-1-git-send-email-mgorman@suse.de>
References: <1429612880-21415-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Page reclaim batches multiple TLB flushes into one IPI and this patch teaches
page migration to also batch any necessary flushes. MMtests has a THP scale
microbenchmark that deliberately fragments memory and then allocates THPs
to stress compaction. It's not a page reclaim benchmark and recent kernels
avoid excessive compaction but this patch reduced system CPU usage

               4.0.0       4.0.0
            baseline batchmigrate-v1
User          970.70     1012.24
System       2067.48     1840.00
Elapsed      1520.63     1529.66

Note that this particular workload was not TLB flush intensive with peaks
in interrupts during the compaction phase. The 4.0 kernel peaked at 345K
interrupts/second, the kernel that batches reclaim TLB entries peaked at
13K interrupts/second and this patch peaked at 10K interrupts/second.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 mm/internal.h |  5 +++++
 mm/migrate.c  | 13 +++++++++++--
 mm/vmscan.c   |  6 +-----
 3 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 35aba439c275..c2481574b41a 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -436,10 +436,15 @@ struct tlbflush_unmap_batch;
 
 #ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
 void try_to_unmap_flush(void);
+void alloc_tlb_ubc(void);
 #else
 static inline void try_to_unmap_flush(void)
 {
 }
 
+static inline void alloc_tlb_ubc(void)
+{
+}
+
 #endif /* CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH */
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/migrate.c b/mm/migrate.c
index 82c98c5aa6ed..4a1793dce6e3 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -878,8 +878,12 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 
 	/* Establish migration ptes or remove ptes */
 	if (page_mapped(page)) {
-		try_to_unmap(page,
-			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+		int ttu_retval = try_to_unmap(page,
+			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS|TTU_BATCH_FLUSH);
+
+		/* Must flush before copy in case of a writable TLB entry */
+		if (ttu_retval == SWAP_SUCCESS_CACHED)
+			try_to_unmap_flush();
 		page_was_mapped = 1;
 	}
 
@@ -1099,6 +1103,8 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 	if (!swapwrite)
 		current->flags |= PF_SWAPWRITE;
 
+	alloc_tlb_ubc();
+
 	for(pass = 0; pass < 10 && retry; pass++) {
 		retry = 0;
 
@@ -1137,6 +1143,9 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 	}
 	rc = nr_failed + retry;
 out:
+	/* Must flush before any potential frees */
+	try_to_unmap_flush();
+
 	while (!list_empty(&putback_list)) {
 		page = list_entry(putback_list.prev, struct page, lru);
 		list_del(&page->lru);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0ad3f435afdd..e39e7c4bf548 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2776,7 +2776,7 @@ out:
  * Allocate the control structure for batch TLB flushing. An allocation
  * failure is harmless as the reclaimer will send IPIs where necessary.
  */
-static inline void alloc_tlb_ubc(void)
+void alloc_tlb_ubc(void)
 {
 	if (current->tlb_ubc)
 		return;
@@ -2789,10 +2789,6 @@ static inline void alloc_tlb_ubc(void)
 	cpumask_clear(&current->tlb_ubc->cpumask);
 	current->tlb_ubc->nr_pages = 0;
 }
-#else
-static inline void alloc_tlb_ubc(void)
-{
-}
 #endif /* CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH */
 
 unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
