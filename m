Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2B21F900015
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 08:51:06 -0400 (EDT)
Received: by wibut5 with SMTP id ut5so85172077wib.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 05:51:05 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gf1si1006151wib.52.2015.06.08.05.51.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 05:51:00 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/3] mm: Defer flush of writable TLB entries
Date: Mon,  8 Jun 2015 13:50:54 +0100
Message-Id: <1433767854-24408-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1433767854-24408-1-git-send-email-mgorman@suse.de>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

If a PTE is unmapped and it's dirty then it was writable recently. Due
to deferred TLB flushing, it's best to assume a writable TLB cache entry
exists. With that assumption, the TLB must be flushed before any IO can
start or the page is freed to avoid lost writes or data corruption. This
patch defers flushing of potentially writable TLBs as long as possible.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/sched.h |  1 +
 mm/internal.h         |  4 ++++
 mm/rmap.c             | 28 +++++++++++++++++++++-------
 mm/vmscan.c           |  7 ++++++-
 4 files changed, 32 insertions(+), 8 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 57ff61b16565..827d9b123bd5 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1296,6 +1296,7 @@ enum perf_event_task_context {
 struct tlbflush_unmap_batch {
 	struct cpumask cpumask;
 	unsigned long nr_pages;
+	bool writable;
 	unsigned long pfns[BATCH_TLBFLUSH_SIZE];
 };
 
diff --git a/mm/internal.h b/mm/internal.h
index 8cbb68ccc731..ecf47a01420d 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -438,10 +438,14 @@ struct tlbflush_unmap_batch;
 
 #ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
 void try_to_unmap_flush(void);
+void try_to_unmap_flush_dirty(void);
 #else
 static inline void try_to_unmap_flush(void)
 {
 }
+static inline void try_to_unmap_flush_dirty(void)
+{
+}
 
 #endif /* CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH */
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/rmap.c b/mm/rmap.c
index a8dbba62398a..3c8ebacfe6ef 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -621,11 +621,21 @@ void try_to_unmap_flush(void)
 	}
 	cpumask_clear(&tlb_ubc->cpumask);
 	tlb_ubc->nr_pages = 0;
+	tlb_ubc->writable = false;
 	preempt_enable();
 }
 
+/* Flush iff there are potentially writable TLB entries that can race with IO */
+void try_to_unmap_flush_dirty(void)
+{
+	struct tlbflush_unmap_batch *tlb_ubc = current->tlb_ubc;
+
+	if (tlb_ubc && tlb_ubc->writable)
+		try_to_unmap_flush();
+}
+
 static void set_tlb_ubc_flush_pending(struct mm_struct *mm,
-		struct page *page)
+		struct page *page, bool writable)
 {
 	struct tlbflush_unmap_batch *tlb_ubc = current->tlb_ubc;
 
@@ -633,6 +643,14 @@ static void set_tlb_ubc_flush_pending(struct mm_struct *mm,
 	tlb_ubc->pfns[tlb_ubc->nr_pages] = page_to_pfn(page);
 	tlb_ubc->nr_pages++;
 
+	/*
+	 * If the PTE was dirty then it's best to assume it's writable. The
+	 * caller must use try_to_unmap_flush_dirty() or try_to_unmap_flush()
+	 * before the page any IO is initiated.
+	 */
+	if (writable)
+		tlb_ubc->writable = true;
+
 	if (tlb_ubc->nr_pages == BATCH_TLBFLUSH_SIZE)
 		try_to_unmap_flush();
 }
@@ -657,7 +675,7 @@ static bool should_defer_flush(struct mm_struct *mm, enum ttu_flags flags)
 }
 #else
 static void set_tlb_ubc_flush_pending(struct mm_struct *mm,
-		struct page *page)
+		struct page *page, bool writable)
 {
 }
 
@@ -1309,11 +1327,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		 */
 		pteval = ptep_get_and_clear(mm, address, pte);
 
-		/* Potentially writable TLBs must be flushed before IO */
-		if (pte_dirty(pteval))
-			flush_tlb_page(vma, address);
-		else
-			set_tlb_ubc_flush_pending(mm, page);
+		set_tlb_ubc_flush_pending(mm, page, pte_dirty(pteval));
 	} else {
 		pteval = ptep_clear_flush(vma, address, pte);
 	}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5121742ccb87..0055224c52d4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1065,7 +1065,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			if (!sc->may_writepage)
 				goto keep_locked;
 
-			/* Page is dirty, try to write it out here */
+			/*
+			 * Page is dirty. Flush the TLB if a writable entry
+			 * potentially exists to avoid CPU writes after IO
+			 * starts and then write it out here
+			 */
+			try_to_unmap_flush_dirty();
 			switch (pageout(page, mapping, sc)) {
 			case PAGE_KEEP:
 				goto keep_locked;
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
