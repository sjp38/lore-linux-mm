Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 011BE2802AF
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 09:40:11 -0400 (EDT)
Received: by wgqq4 with SMTP id q4so140830538wgq.1
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 06:40:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bo1si30329328wjb.27.2015.07.06.06.40.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 06 Jul 2015 06:40:04 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/4] mm: Defer flush of writable TLB entries
Date: Mon,  6 Jul 2015 14:39:55 +0100
Message-Id: <1436189996-7220-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1436189996-7220-1-git-send-email-mgorman@suse.de>
References: <1436189996-7220-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

If a PTE is unmapped and it's dirty then it was writable recently. Due
to deferred TLB flushing, it's best to assume a writable TLB cache entry
exists. With that assumption, the TLB must be flushed before any IO can
start or the page is freed to avoid lost writes or data corruption. This
patch defers flushing of potentially writable TLBs as long as possible.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 include/linux/sched.h |  7 +++++++
 mm/internal.h         |  4 ++++
 mm/rmap.c             | 28 +++++++++++++++++++++-------
 mm/vmscan.c           |  7 ++++++-
 4 files changed, 38 insertions(+), 8 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 1a83fb44ab34..e769d5b4975c 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1351,6 +1351,13 @@ struct tlbflush_unmap_batch {
 
 	/* True if any bit in cpumask is set */
 	bool flush_required;
+
+	/*
+	 * If true then the PTE was dirty when unmapped. The entry must be
+	 * flushed before IO is initiated or a stale TLB entry potentially
+	 * allows an update without redirtying the page.
+	 */
+	bool writable;
 };
 
 struct task_struct {
diff --git a/mm/internal.h b/mm/internal.h
index bd6372ac5f7f..1195dd2d6a2b 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -431,10 +431,14 @@ struct tlbflush_unmap_batch;
 
 #ifdef CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH
 void try_to_unmap_flush(void);
+void try_to_unmap_flush_dirty(void);
 #else
 static inline void try_to_unmap_flush(void)
 {
 }
+static inline void try_to_unmap_flush_dirty(void)
+{
+}
 
 #endif /* CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH */
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/rmap.c b/mm/rmap.c
index d54f47666af5..85a8aea2d593 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -625,16 +625,34 @@ void try_to_unmap_flush(void)
 	}
 	cpumask_clear(&tlb_ubc->cpumask);
 	tlb_ubc->flush_required = false;
+	tlb_ubc->writable = false;
 	put_cpu();
 }
 
+/* Flush iff there are potentially writable TLB entries that can race with IO */
+void try_to_unmap_flush_dirty(void)
+{
+	struct tlbflush_unmap_batch *tlb_ubc = &current->tlb_ubc;
+
+	if (tlb_ubc->writable)
+		try_to_unmap_flush();
+}
+
 static void set_tlb_ubc_flush_pending(struct mm_struct *mm,
-		struct page *page)
+		struct page *page, bool writable)
 {
 	struct tlbflush_unmap_batch *tlb_ubc = &current->tlb_ubc;
 
 	cpumask_or(&tlb_ubc->cpumask, &tlb_ubc->cpumask, mm_cpumask(mm));
 	tlb_ubc->flush_required = true;
+
+	/*
+	 * If the PTE was dirty then it's best to assume it's writable. The
+	 * caller must use try_to_unmap_flush_dirty() or try_to_unmap_flush()
+	 * before the page is queued for IO.
+	 */
+	if (writable)
+		tlb_ubc->writable = true;
 }
 
 /*
@@ -657,7 +675,7 @@ static bool should_defer_flush(struct mm_struct *mm, enum ttu_flags flags)
 }
 #else
 static void set_tlb_ubc_flush_pending(struct mm_struct *mm,
-		struct page *page)
+		struct page *page, bool writable)
 {
 }
 
@@ -1314,11 +1332,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
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
index e4f1df1052a2..b5c5dc0997a1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1102,7 +1102,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			if (!sc->may_writepage)
 				goto keep_locked;
 
-			/* Page is dirty, try to write it out here */
+			/*
+			 * Page is dirty. Flush the TLB if a writable entry
+			 * potentially exists to avoid CPU writes after IO
+			 * starts and then write it out here.
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
