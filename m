Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8C91A6B04EF
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 01:56:22 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id c14so7677667pgn.11
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 22:56:22 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id e12si17470327pgn.755.2017.07.31.22.56.20
        for <linux-mm@kvack.org>;
        Mon, 31 Jul 2017 22:56:21 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 3/4] mm: fix MADV_[FREE|DONTNEED] TLB flush miss problem
Date: Tue,  1 Aug 2017 14:56:16 +0900
Message-Id: <1501566977-20293-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1501566977-20293-1-git-send-email-minchan@kernel.org>
References: <1501566977-20293-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>, Ingo Molnar <mingo@redhat.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Jeff Dike <jdike@addtoit.com>, linux-arch@vger.kernel.org, Nadav Amit <nadav.amit@gmail.com>, Mel Gorman <mgorman@techsingularity.net>

Nadav reported parallel MADV_DONTNEED on same range has a stale TLB
problem and Mel fixed it[1] and found same problem on MADV_FREE[2].

Quote from Mel Gorman

"The race in question is CPU 0 running madv_free and updating some PTEs
while CPU 1 is also running madv_free and looking at the same PTEs.
CPU 1 may have writable TLB entries for a page but fail the pte_dirty
check (because CPU 0 has updated it already) and potentially fail to flush.
Hence, when madv_free on CPU 1 returns, there are still potentially writable
TLB entries and the underlying PTE is still present so that a subsequent write
does not necessarily propagate the dirty bit to the underlying PTE any more.
Reclaim at some unknown time at the future may then see that the PTE is still
clean and discard the page even though a write has happened in the meantime.
I think this is possible but I could have missed some protection in madv_free
that prevents it happening."

This patch aims for solving both problems all at once and is ready for
other problem with KSM, MADV_FREE and soft-dirty story[3].

TLB batch API(tlb_[gather|finish]_mmu] uses [inc|dec]_tlb_flush_pending
and mmu_tlb_flush_pending so that when tlb_finish_mmu is called, we can catch
there are parallel threads going on. In that case, forcefully, flush TLB
to prevent for user to access memory via stale TLB entry although it fail
to gather page table entry.

I confiremd this patch works with [4] test program Nadav gave so this patch
supersedes "mm: Always flush VMA ranges affected by zap_page_range v2"
in current mmotm.

NOTE:
This patch modifies arch-specific TLB gathering interface(x86, ia64,
s390, sh, um). It seems most of architecture are straightforward but s390
need to be careful because tlb_flush_mmu works only if mm->context.flush_mm
is set to non-zero which happens only a pte entry really is cleared by
ptep_get_and_clear and friends. However, this problem never changes the
pte entries but need to flush to prevent memory access from stale tlb.

Any thoughts?

[1] http://lkml.kernel.org/r/20170725101230.5v7gvnjmcnkzzql3@techsingularity.net
[2] http://lkml.kernel.org/r/20170725100722.2dxnmgypmwnrfawp@suse.de
[3] http://lkml.kernel.org/r/BD3A0EBE-ECF4-41D4-87FA-C755EA9AB6BD@gmail.com
[4] https://patchwork.kernel.org/patch/9861621/

Cc: Ingo Molnar <mingo@redhat.com>
Cc: Russell King <linux@armlinux.org.uk>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Jeff Dike <jdike@addtoit.com>
Cc: linux-arch@vger.kernel.org
Cc: Nadav Amit <nadav.amit@gmail.com>
Reported-by: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 arch/arm/include/asm/tlb.h  |  7 ++++++-
 arch/ia64/include/asm/tlb.h |  4 +++-
 arch/s390/include/asm/tlb.h |  7 ++++++-
 arch/sh/include/asm/tlb.h   |  4 ++--
 arch/um/include/asm/tlb.h   |  7 ++++++-
 include/asm-generic/tlb.h   |  2 +-
 include/linux/mm_types.h    |  8 ++++++++
 mm/memory.c                 | 32 +++++++++++++++++---------------
 8 files changed, 49 insertions(+), 22 deletions(-)

diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index 7f5b2a2d3861..d5562f9ce600 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -168,8 +168,13 @@ arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
 
 static inline void
 arch_tlb_finish_mmu(struct mmu_gather *tlb,
-			unsigned long start, unsigned long end)
+			unsigned long start, unsigned long end, bool force)
 {
+	if (force) {
+		tlb->range_start = start;
+		tlb->range_end = end;
+	}
+
 	tlb_flush_mmu(tlb);
 
 	/* keep the page table cache within bounds */
diff --git a/arch/ia64/include/asm/tlb.h b/arch/ia64/include/asm/tlb.h
index 93cadc04ac62..cbe5ac3699bf 100644
--- a/arch/ia64/include/asm/tlb.h
+++ b/arch/ia64/include/asm/tlb.h
@@ -187,8 +187,10 @@ arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
  */
 static inline void
 arch_tlb_finish_mmu(struct mmu_gather *tlb,
-			unsigned long start, unsigned long end)
+			unsigned long start, unsigned long end, bool force)
 {
+	if (force)
+		tlb->need_flush = 1;
 	/*
 	 * Note: tlb->nr may be 0 at this point, so we can't rely on tlb->start_addr and
 	 * tlb->end_addr.
diff --git a/arch/s390/include/asm/tlb.h b/arch/s390/include/asm/tlb.h
index fa4b461694b7..3a14b864b2e3 100644
--- a/arch/s390/include/asm/tlb.h
+++ b/arch/s390/include/asm/tlb.h
@@ -77,8 +77,13 @@ static inline void tlb_flush_mmu(struct mmu_gather *tlb)
 
 static inline void
 arch_tlb_finish_mmu(struct mmu_gather *tlb,
-		unsigned long start, unsigned long end)
+		unsigned long start, unsigned long end, bool force)
 {
+	if (force) {
+		tlb->start = start;
+		tlb->end = end;
+	}
+
 	tlb_flush_mmu(tlb);
 }
 
diff --git a/arch/sh/include/asm/tlb.h b/arch/sh/include/asm/tlb.h
index 89786560dbd4..51a8bc967e75 100644
--- a/arch/sh/include/asm/tlb.h
+++ b/arch/sh/include/asm/tlb.h
@@ -49,9 +49,9 @@ arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
 
 static inline void
 arch_tlb_finish_mmu(struct mmu_gather *tlb,
-		unsigned long start, unsigned long end)
+		unsigned long start, unsigned long end, bool force)
 {
-	if (tlb->fullmm)
+	if (tlb->fullmm || force)
 		flush_tlb_mm(tlb->mm);
 
 	/* keep the page table cache within bounds */
diff --git a/arch/um/include/asm/tlb.h b/arch/um/include/asm/tlb.h
index 2a901eca7145..344d95619d03 100644
--- a/arch/um/include/asm/tlb.h
+++ b/arch/um/include/asm/tlb.h
@@ -87,8 +87,13 @@ tlb_flush_mmu(struct mmu_gather *tlb)
  */
 static inline void
 arch_tlb_finish_mmu(struct mmu_gather *tlb,
-		unsigned long start, unsigned long end)
+		unsigned long start, unsigned long end, bool force)
 {
+	if (force) {
+		tlb->start = start;
+		tlb->end = end;
+		tlb->need_flush = 1;
+	}
 	tlb_flush_mmu(tlb);
 
 	/* keep the page table cache within bounds */
diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index ae05fdf96c2d..627d8a43cd24 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -116,7 +116,7 @@ void arch_generic_tlb_gather_mmu(struct mmu_gather *tlb,
 	struct mm_struct *mm, unsigned long start, unsigned long end);
 void tlb_flush_mmu(struct mmu_gather *tlb);
 void arch_generic_tlb_finish_mmu(struct mmu_gather *tlb,
-		unsigned long start, unsigned long end);
+		unsigned long start, unsigned long end, bool force);
 extern bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page,
 				   int page_size);
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 892a7b0196fd..3cadee0a3508 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -538,6 +538,14 @@ static inline bool mm_tlb_flush_pending(struct mm_struct *mm)
 	return atomic_read(&mm->tlb_flush_pending) > 0;
 }
 
+/*
+ * Returns true if there are two above TLB batching threads in parallel.
+ */
+static inline bool mm_tlb_flush_nested(struct mm_struct *mm)
+{
+	return atomic_read(&mm->tlb_flush_pending) > 1;
+}
+
 static inline void init_tlb_flush_pending(struct mm_struct *mm)
 {
 	atomic_set(&mm->tlb_flush_pending, 0);
diff --git a/mm/memory.c b/mm/memory.c
index 80012d7a9451..804a005410f6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -272,10 +272,13 @@ void tlb_flush_mmu(struct mmu_gather *tlb)
  *	that were required.
  */
 void arch_generic_tlb_finish_mmu(struct mmu_gather *tlb,
-		unsigned long start, unsigned long end)
+		unsigned long start, unsigned long end, bool force)
 {
 	struct mmu_gather_batch *batch, *next;
 
+	if (force)
+		__tlb_adjust_range(tlb, start, end - start);
+
 	tlb_flush_mmu(tlb);
 
 	/* keep the page table cache within bounds */
@@ -408,16 +411,26 @@ void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
 #else
 	arch_tlb_gather_mmu(tlb, mm, start, end);
 #endif
+	inc_tlb_flush_pending(tlb->mm);
 }
 
 void tlb_finish_mmu(struct mmu_gather *tlb,
 		unsigned long start, unsigned long end)
 {
+	/*
+	 * If there are parallel threads are doing PTE changes on same range
+	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
+	 * flush by batching, a thread has stable TLB entry can fail to flush
+	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
+	 * forcefully if we detect parallel PTE batching threads.
+	 */
+	bool force = mm_tlb_flush_nested(tlb->mm);
 #ifdef HAVE_GENERIC_MMU_GATHER
-	arch_generic_tlb_finish_mmu(tlb, start, end);
+	arch_generic_tlb_finish_mmu(tlb, start, end, force);
 #else
-	arch_tlb_finish_mmu(tlb, start, end);
+	arch_tlb_finish_mmu(tlb, start, end, force);
 #endif
+	dec_tlb_flush_pending(tlb->mm);
 }
 
 /*
@@ -1507,20 +1520,9 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
 	tlb_gather_mmu(&tlb, mm, start, end);
 	update_hiwater_rss(mm);
 	mmu_notifier_invalidate_range_start(mm, start, end);
-	for ( ; vma && vma->vm_start < end; vma = vma->vm_next) {
+	for ( ; vma && vma->vm_start < end; vma = vma->vm_next)
 		unmap_single_vma(&tlb, vma, start, end, NULL);
 
-		/*
-		 * zap_page_range does not specify whether mmap_sem should be
-		 * held for read or write. That allows parallel zap_page_range
-		 * operations to unmap a PTE and defer a flush meaning that
-		 * this call observes pte_none and fails to flush the TLB.
-		 * Rather than adding a complex API, ensure that no stale
-		 * TLB entries exist when this call returns.
-		 */
-		flush_tlb_range(vma, start, end);
-	}
-
 	mmu_notifier_invalidate_range_end(mm, start, end);
 	tlb_finish_mmu(&tlb, start, end);
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
