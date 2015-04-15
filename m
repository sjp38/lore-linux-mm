Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 062966B0071
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 06:43:11 -0400 (EDT)
Received: by wizk4 with SMTP id k4so149197028wiz.1
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 03:43:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kn9si7415089wjb.61.2015.04.15.03.43.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Apr 2015 03:43:06 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 4/4] mm: migrate: Batch TLB flushing when unmapping pages for migration
Date: Wed, 15 Apr 2015 11:42:56 +0100
Message-Id: <1429094576-5877-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1429094576-5877-1-git-send-email-mgorman@suse.de>
References: <1429094576-5877-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

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
---
 mm/internal.h | 5 +++++
 mm/migrate.c  | 8 +++++++-
 mm/vmscan.c   | 6 +-----
 3 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index fe69dd159e34..cb70555a7291 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -436,10 +436,15 @@ struct unmap_batch;
 
 #ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
 void try_to_unmap_flush(void);
+void alloc_ubc(void);
 #else
 static inline void try_to_unmap_flush(void)
 {
 }
 
+static inline void alloc_ubc(void)
+{
+}
+
 #endif /* CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH */
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/migrate.c b/mm/migrate.c
index 85e042686031..973d8befe528 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -789,6 +789,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		if (current->flags & PF_MEMALLOC)
 			goto out;
 
+		try_to_unmap_flush();
 		lock_page(page);
 	}
 
@@ -805,6 +806,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		}
 		if (!force)
 			goto out_unlock;
+		try_to_unmap_flush();
 		wait_on_page_writeback(page);
 	}
 	/*
@@ -879,7 +881,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	/* Establish migration ptes or remove ptes */
 	if (page_mapped(page)) {
 		try_to_unmap(page,
-			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS|TTU_BATCH_FLUSH);
 		page_was_mapped = 1;
 	}
 
@@ -1098,6 +1100,8 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 	if (!swapwrite)
 		current->flags |= PF_SWAPWRITE;
 
+	alloc_ubc();
+
 	for(pass = 0; pass < 10 && retry; pass++) {
 		retry = 0;
 
@@ -1144,6 +1148,8 @@ out:
 	if (!swapwrite)
 		current->flags &= ~PF_SWAPWRITE;
 
+	try_to_unmap_flush();
+
 	return rc;
 }
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 68bcc0b73a76..d659e3655575 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2767,7 +2767,7 @@ out:
 }
 
 #ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
-static inline void alloc_ubc(void)
+void alloc_ubc(void)
 {
 	if (current->ubc)
 		return;
@@ -2784,10 +2784,6 @@ static inline void alloc_ubc(void)
 	cpumask_clear(&current->ubc->cpumask);
 	current->ubc->nr_pages = 0;
 }
-#else
-static inline void alloc_ubc(void)
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
