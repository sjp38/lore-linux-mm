Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 34D786B0037
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 19:21:26 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so3615960pab.8
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 16:21:25 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id tm7si5753487pab.111.2014.04.25.16.21.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Apr 2014 16:21:24 -0700 (PDT)
Received: by mail-pa0-f42.google.com with SMTP id bj1so400938pad.1
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 16:21:24 -0700 (PDT)
Date: Fri, 25 Apr 2014 16:21:22 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: [PATCH] mm: split 'tlb_flush_mmu()' into tlb flushing and memory
 freeing parts
Message-ID: <alpine.LFD.2.11.1404251615320.11259@i7.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>
Cc: Peter Anvin <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org, Russell King <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>, Michal Hocko <mhocko@suse.cz>, linux-sh@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, linux-s390@vger.kernel.org


From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 25 Apr 2014 16:05:40 -0700
Subject: [PATCH] mm: split 'tlb_flush_mmu()' into tlb flushing and memory freeing parts

The mmu-gather operation 'tlb_flush_mmu()' has done two things: the
actual tlb flush operation, and the batched freeing of the pages that
the TLB entries pointed at.

This splits the operation into separate phases, so that the forced
batched flushing done by zap_pte_range() can now do the actual TLB flush
while still holding the page table lock, but delay the batched freeing
of all the pages to after the lock has been dropped.

This in turn allows us to avoid a race condition between
set_page_dirty() (as called by zap_pte_range() when it finds a dirty
shared memory pte) and page_mkclean(): because we now flush all the
dirty page data from the TLB's while holding the pte lock,
page_mkclean() will be held up walking the (recently cleaned) page
tables until after the TLB entries have been flushed from all CPU's.

Reported-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Tested-by: Dave Hansen <dave.hansen@intel.com>
Acked-by: Hugh Dickins <hughd@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Tony Luck <tony.luck@intel.com>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---

Ok, this is now tentatively committed to my tree. I decided to just go 
ahead and do the ARM/ia64/sh parts blindly, since the splitup was fairly 
trivial (ia64 being slightly more complicated). I tested the UM one, at 
least as far as compiling. The others are totally untested, it would be 
good to make sure I didn't screw anything up.

The x86 and generic parts are the same that DaveH already tested and that 
got sent out a few days ago.

 arch/arm/include/asm/tlb.h  | 12 +++++++++-
 arch/ia64/include/asm/tlb.h | 42 ++++++++++++++++++++++++++---------
 arch/s390/include/asm/tlb.h | 13 ++++++++++-
 arch/sh/include/asm/tlb.h   |  8 +++++++
 arch/um/include/asm/tlb.h   | 16 ++++++++++++--
 mm/memory.c                 | 53 +++++++++++++++++++++++++++++----------------
 6 files changed, 111 insertions(+), 33 deletions(-)

diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index 0baf7f0d9394..f1a0dace3efe 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -98,15 +98,25 @@ static inline void __tlb_alloc_page(struct mmu_gather *tlb)
 	}
 }
 
-static inline void tlb_flush_mmu(struct mmu_gather *tlb)
+static inline void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
 {
 	tlb_flush(tlb);
+}
+
+static inline void tlb_flush_mmu_free(struct mmu_gather *tlb)
+{
 	free_pages_and_swap_cache(tlb->pages, tlb->nr);
 	tlb->nr = 0;
 	if (tlb->pages == tlb->local)
 		__tlb_alloc_page(tlb);
 }
 
+static inline void tlb_flush_mmu(struct mmu_gather *tlb)
+{
+	tlb_flush_mmu_tlbonly(tlb);
+	tlb_flush_mmu_free(tlb);
+}
+
 static inline void
 tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long start, unsigned long end)
 {
diff --git a/arch/ia64/include/asm/tlb.h b/arch/ia64/include/asm/tlb.h
index bc5efc7c3f3f..39d64e0df1de 100644
--- a/arch/ia64/include/asm/tlb.h
+++ b/arch/ia64/include/asm/tlb.h
@@ -91,18 +91,9 @@ extern struct ia64_tr_entry *ia64_idtrs[NR_CPUS];
 #define RR_RID_MASK	0x00000000ffffff00L
 #define RR_TO_RID(val) 	((val >> 8) & 0xffffff)
 
-/*
- * Flush the TLB for address range START to END and, if not in fast mode, release the
- * freed pages that where gathered up to this point.
- */
 static inline void
-ia64_tlb_flush_mmu (struct mmu_gather *tlb, unsigned long start, unsigned long end)
+ia64_tlb_flush_mmu_tlbonly(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
-	unsigned long i;
-	unsigned int nr;
-
-	if (!tlb->need_flush)
-		return;
 	tlb->need_flush = 0;
 
 	if (tlb->fullmm) {
@@ -135,6 +126,14 @@ ia64_tlb_flush_mmu (struct mmu_gather *tlb, unsigned long start, unsigned long e
 		flush_tlb_range(&vma, ia64_thash(start), ia64_thash(end));
 	}
 
+}
+
+static inline void
+ia64_tlb_flush_mmu_free(struct mmu_gather *tlb)
+{
+	unsigned long i;
+	unsigned int nr;
+
 	/* lastly, release the freed pages */
 	nr = tlb->nr;
 
@@ -144,6 +143,19 @@ ia64_tlb_flush_mmu (struct mmu_gather *tlb, unsigned long start, unsigned long e
 		free_page_and_swap_cache(tlb->pages[i]);
 }
 
+/*
+ * Flush the TLB for address range START to END and, if not in fast mode, release the
+ * freed pages that where gathered up to this point.
+ */
+static inline void
+ia64_tlb_flush_mmu (struct mmu_gather *tlb, unsigned long start, unsigned long end)
+{
+	if (!tlb->need_flush)
+		return;
+	ia64_tlb_flush_mmu_tlbonly(tlb, start, end);
+	ia64_tlb_flush_mmu_free(tlb);
+}
+
 static inline void __tlb_alloc_page(struct mmu_gather *tlb)
 {
 	unsigned long addr = __get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
@@ -206,6 +218,16 @@ static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 	return tlb->max - tlb->nr;
 }
 
+static inline void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
+{
+	ia64_tlb_flush_mmu_tlbonly(tlb, tlb->start_addr, tlb->end_addr);
+}
+
+static inline void tlb_flush_mmu_free(struct mmu_gather *tlb)
+{
+	ia64_tlb_flush_mmu_free(tlb);
+}
+
 static inline void tlb_flush_mmu(struct mmu_gather *tlb)
 {
 	ia64_tlb_flush_mmu(tlb, tlb->start_addr, tlb->end_addr);
diff --git a/arch/s390/include/asm/tlb.h b/arch/s390/include/asm/tlb.h
index c544b6f05d95..a25f09fbaf36 100644
--- a/arch/s390/include/asm/tlb.h
+++ b/arch/s390/include/asm/tlb.h
@@ -59,12 +59,23 @@ static inline void tlb_gather_mmu(struct mmu_gather *tlb,
 	tlb->batch = NULL;
 }
 
-static inline void tlb_flush_mmu(struct mmu_gather *tlb)
+static inline void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
 {
 	__tlb_flush_mm_lazy(tlb->mm);
+}
+
+static inline void tlb_flush_mmu_free(struct mmu_gather *tlb)
+{
 	tlb_table_flush(tlb);
 }
 
+
+static inline void tlb_flush_mmu(struct mmu_gather *tlb)
+{
+	tlb_flush_mmu_tlbonly(tlb);
+	tlb_flush_mmu_free(tlb);
+}
+
 static inline void tlb_finish_mmu(struct mmu_gather *tlb,
 				  unsigned long start, unsigned long end)
 {
diff --git a/arch/sh/include/asm/tlb.h b/arch/sh/include/asm/tlb.h
index 362192ed12fe..62f80d2a9df9 100644
--- a/arch/sh/include/asm/tlb.h
+++ b/arch/sh/include/asm/tlb.h
@@ -86,6 +86,14 @@ tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
 	}
 }
 
+static inline void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
+{
+}
+
+static inline void tlb_flush_mmu_free(struct mmu_gather *tlb)
+{
+}
+
 static inline void tlb_flush_mmu(struct mmu_gather *tlb)
 {
 }
diff --git a/arch/um/include/asm/tlb.h b/arch/um/include/asm/tlb.h
index 29b0301c18aa..16eb63fac57d 100644
--- a/arch/um/include/asm/tlb.h
+++ b/arch/um/include/asm/tlb.h
@@ -59,13 +59,25 @@ extern void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 			       unsigned long end);
 
 static inline void
+tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
+{
+	flush_tlb_mm_range(tlb->mm, tlb->start, tlb->end);
+}
+
+static inline void
+tlb_flush_mmu_free(struct mmu_gather *tlb)
+{
+	init_tlb_gather(tlb);
+}
+
+static inline void
 tlb_flush_mmu(struct mmu_gather *tlb)
 {
 	if (!tlb->need_flush)
 		return;
 
-	flush_tlb_mm_range(tlb->mm, tlb->start, tlb->end);
-	init_tlb_gather(tlb);
+	tlb_flush_mmu_tlbonly(tlb);
+	tlb_flush_mmu_free(tlb);
 }
 
 /* tlb_finish_mmu
diff --git a/mm/memory.c b/mm/memory.c
index 93e332d5ed77..037b812a9531 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -232,17 +232,18 @@ void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long
 #endif
 }
 
-void tlb_flush_mmu(struct mmu_gather *tlb)
+static void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
 {
-	struct mmu_gather_batch *batch;
-
-	if (!tlb->need_flush)
-		return;
 	tlb->need_flush = 0;
 	tlb_flush(tlb);
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb_table_flush(tlb);
 #endif
+}
+
+static void tlb_flush_mmu_free(struct mmu_gather *tlb)
+{
+	struct mmu_gather_batch *batch;
 
 	for (batch = &tlb->local; batch; batch = batch->next) {
 		free_pages_and_swap_cache(batch->pages, batch->nr);
@@ -251,6 +252,14 @@ void tlb_flush_mmu(struct mmu_gather *tlb)
 	tlb->active = &tlb->local;
 }
 
+void tlb_flush_mmu(struct mmu_gather *tlb)
+{
+	if (!tlb->need_flush)
+		return;
+	tlb_flush_mmu_tlbonly(tlb);
+	tlb_flush_mmu_free(tlb);
+}
+
 /* tlb_finish_mmu
  *	Called at the end of the shootdown operation to free up any resources
  *	that were required.
@@ -1127,8 +1136,10 @@ again:
 			if (PageAnon(page))
 				rss[MM_ANONPAGES]--;
 			else {
-				if (pte_dirty(ptent))
+				if (pte_dirty(ptent)) {
+					force_flush = 1;
 					set_page_dirty(page);
+				}
 				if (pte_young(ptent) &&
 				    likely(!(vma->vm_flags & VM_SEQ_READ)))
 					mark_page_accessed(page);
@@ -1137,9 +1148,10 @@ again:
 			page_remove_rmap(page);
 			if (unlikely(page_mapcount(page) < 0))
 				print_bad_pte(vma, addr, ptent, page);
-			force_flush = !__tlb_remove_page(tlb, page);
-			if (force_flush)
+			if (unlikely(!__tlb_remove_page(tlb, page))) {
+				force_flush = 1;
 				break;
+			}
 			continue;
 		}
 		/*
@@ -1174,18 +1186,11 @@ again:
 
 	add_mm_rss_vec(mm, rss);
 	arch_leave_lazy_mmu_mode();
-	pte_unmap_unlock(start_pte, ptl);
 
-	/*
-	 * mmu_gather ran out of room to batch pages, we break out of
-	 * the PTE lock to avoid doing the potential expensive TLB invalidate
-	 * and page-free while holding it.
-	 */
+	/* Do the actual TLB flush before dropping ptl */
 	if (force_flush) {
 		unsigned long old_end;
 
-		force_flush = 0;
-
 		/*
 		 * Flush the TLB just for the previous segment,
 		 * then update the range to be the remaining
@@ -1193,11 +1198,21 @@ again:
 		 */
 		old_end = tlb->end;
 		tlb->end = addr;
-
-		tlb_flush_mmu(tlb);
-
+		tlb_flush_mmu_tlbonly(tlb);
 		tlb->start = addr;
 		tlb->end = old_end;
+	}
+	pte_unmap_unlock(start_pte, ptl);
+
+	/*
+	 * If we forced a TLB flush (either due to running out of
+	 * batch buffers or because we needed to flush dirty TLB
+	 * entries before releasing the ptl), free the batched
+	 * memory too. Restart if we didn't do everything.
+	 */
+	if (force_flush) {
+		force_flush = 0;
+		tlb_flush_mmu_free(tlb);
 
 		if (addr != end)
 			goto again;
-- 
2.0.0.rc1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
