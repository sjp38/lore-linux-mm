Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 85BEB6B04F8
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 02:42:06 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r187so82904340pfr.8
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 23:42:06 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id n5si12194446pgk.396.2017.07.27.23.42.04
        for <linux-mm@kvack.org>;
        Thu, 27 Jul 2017 23:42:05 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 2/3] mm: fix MADV_[FREE|DONTNEED] TLB flush miss problem
Date: Fri, 28 Jul 2017 15:41:51 +0900
Message-Id: <1501224112-23656-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1501224112-23656-1-git-send-email-minchan@kernel.org>
References: <1501224112-23656-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team <kernel-team@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Russell King <linux@armlinux.org.uk>, linux-arm-kernel@lists.infradead.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-sh@vger.kernel.org, Jeff Dike <jdike@addtoit.com>, user-mode-linux-devel@lists.sourceforge.net, linux-arch@vger.kernel.org, Nadav Amit <nadav.amit@gmail.com>, Mel Gorman <mgorman@techsingularity.net>

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

TLB batch API(tlb_[gather|finish]_mmu] uses [set|clear]_tlb_flush_pending
and mmu_tlb_flush_pending so that when tlb_finish_mmu is called, we can catch
there are parallel threads going on. In that case, flush TLB to prevent
for user to access memory via stale TLB entry although it fail to gather
pte entry.

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
Cc: x86@kernel.org
Cc: Russell King <linux@armlinux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org
Cc: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-s390@vger.kernel.org
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: linux-sh@vger.kernel.org
Cc: Jeff Dike <jdike@addtoit.com>
Cc: user-mode-linux-devel@lists.sourceforge.net
Cc: linux-arch@vger.kernel.org
Cc: Nadav Amit <nadav.amit@gmail.com>
Reported-by: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 arch/arm/include/asm/tlb.h  | 15 ++++++++++++++-
 arch/ia64/include/asm/tlb.h | 12 ++++++++++++
 arch/s390/include/asm/tlb.h | 15 +++++++++++++++
 arch/sh/include/asm/tlb.h   |  4 +++-
 arch/um/include/asm/tlb.h   |  8 ++++++++
 include/linux/mm_types.h    |  7 +++++--
 mm/memory.c                 | 24 ++++++++++++------------
 7 files changed, 69 insertions(+), 16 deletions(-)

diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index 3f2eb76243e3..8c26961f0503 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -163,13 +163,26 @@ tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long start
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb->batch = NULL;
 #endif
+	set_tlb_flush_pending(tlb->mm);
 }
 
 static inline void
 tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
-	tlb_flush_mmu(tlb);
+	/*
+	 * If there are parallel threads are doing PTE changes on same range
+	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
+	 * flush by batching, a thread has stable TLB entry can fail to flush
+	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
+	 * if we detect parallel PTE batching threads.
+	 */
+	if (mm_tlb_flush_pending(tlb->mm, false) > 1) {
+		tlb->range_start = start;
+		tlb->range_end = end;
+	}
 
+	tlb_flush_mmu(tlb);
+	clear_tlb_flush_pending(tlb->mm);
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
 
diff --git a/arch/ia64/include/asm/tlb.h b/arch/ia64/include/asm/tlb.h
index fced197b9626..22fe976a4693 100644
--- a/arch/ia64/include/asm/tlb.h
+++ b/arch/ia64/include/asm/tlb.h
@@ -178,6 +178,7 @@ tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long start
 	tlb->start = start;
 	tlb->end = end;
 	tlb->start_addr = ~0UL;
+	set_tlb_flush_pending(tlb->mm);
 }
 
 /*
@@ -188,10 +189,21 @@ static inline void
 tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
 	/*
+	 * If there are parallel threads are doing PTE changes on same range
+	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
+	 * flush by batching, a thread has stable TLB entry can fail to flush
+	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
+	 * if we detect parallel PTE batching threads.
+	 */
+	if (mm_tlb_flush_pending(tlb->mm, false) > 1)
+		tlb->need_flush = 1;
+
+	/*
 	 * Note: tlb->nr may be 0 at this point, so we can't rely on tlb->start_addr and
 	 * tlb->end_addr.
 	 */
 	ia64_tlb_flush_mmu(tlb, start, end);
+	clear_tlb_flush_pending(tlb->mm);
 
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
diff --git a/arch/s390/include/asm/tlb.h b/arch/s390/include/asm/tlb.h
index 950af48e88be..69eede9f31e5 100644
--- a/arch/s390/include/asm/tlb.h
+++ b/arch/s390/include/asm/tlb.h
@@ -57,6 +57,8 @@ static inline void tlb_gather_mmu(struct mmu_gather *tlb,
 	tlb->end = end;
 	tlb->fullmm = !(start | (end+1));
 	tlb->batch = NULL;
+
+	set_tlb_flush_pending(tlb->mm);
 }
 
 static inline void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
@@ -79,7 +81,20 @@ static inline void tlb_flush_mmu(struct mmu_gather *tlb)
 static inline void tlb_finish_mmu(struct mmu_gather *tlb,
 				  unsigned long start, unsigned long end)
 {
+	/*
+	 * If there are parallel threads are doing PTE changes on same range
+	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
+	 * flush by batching, a thread has stable TLB entry can fail to flush
+	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
+	 * if we detect parallel PTE batching threads.
+	 */
+	if (mm_tlb_flush_pending(tlb->mm, false) > 1) {
+		tlb->start = start;
+		tlb->end = end;
+	}
+
 	tlb_flush_mmu(tlb);
+	clear_tlb_flush_pending(tlb->mm);
 }
 
 /*
diff --git a/arch/sh/include/asm/tlb.h b/arch/sh/include/asm/tlb.h
index 46e0d635e36f..37d1e247f0dc 100644
--- a/arch/sh/include/asm/tlb.h
+++ b/arch/sh/include/asm/tlb.h
@@ -44,14 +44,16 @@ tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long start
 	tlb->fullmm = !(start | (end+1));
 
 	init_tlb_gather(tlb);
+	set_tlb_flush_pending(tlb->mm);
 }
 
 static inline void
 tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
-	if (tlb->fullmm)
+	if (tlb->fullmm || mm_tlb_flush_pending(tlb->mm, false) > 1)
 		flush_tlb_mm(tlb->mm);
 
+	clear_tlb_flush_pending(tlb->mm);
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
 }
diff --git a/arch/um/include/asm/tlb.h b/arch/um/include/asm/tlb.h
index 600a2e9bfee2..8938c4914bd0 100644
--- a/arch/um/include/asm/tlb.h
+++ b/arch/um/include/asm/tlb.h
@@ -53,6 +53,7 @@ tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long start
 	tlb->fullmm = !(start | (end+1));
 
 	init_tlb_gather(tlb);
+	set_tlb_flush_pending(tlb->mm);
 }
 
 extern void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
@@ -87,7 +88,14 @@ tlb_flush_mmu(struct mmu_gather *tlb)
 static inline void
 tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
+	if (mm_tlb_flush_pending(tlb->mm, false) > 1) {
+		tlb->start = start;
+		tlb->end = end;
+		tlb->need_flush = 1;
+	}
+
 	tlb_flush_mmu(tlb);
+	clear_tlb_flush_pending(tlb->mm);
 
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 6953d2c706fe..8bb0dfc004be 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -527,8 +527,9 @@ static inline cpumask_t *mm_cpumask(struct mm_struct *mm)
  * which happen while the lock is not taken, and the PTE updates, which happen
  * while the lock is taken, are serialized.
  */
-static inline bool mm_tlb_flush_pending(struct mm_struct *mm, bool pt_locked)
+static inline int mm_tlb_flush_pending(struct mm_struct *mm, bool pt_locked)
 {
+	int nr_pending;
 	/*
 	 * mm_tlb_flush_pending() is safe if it is executed while the page-table
 	 * lock is taken. But if the lock was already released, there does not
@@ -538,8 +539,10 @@ static inline bool mm_tlb_flush_pending(struct mm_struct *mm, bool pt_locked)
 	if (!pt_locked)
 		smp_mb__after_unlock_lock();
 
-	return atomic_read(&mm->tlb_flush_pending) > 0;
+	nr_pending = atomic_read(&mm->tlb_flush_pending);
+	return nr_pending;
 }
+
 static inline void set_tlb_flush_pending(struct mm_struct *mm)
 {
 	atomic_inc(&mm->tlb_flush_pending);
diff --git a/mm/memory.c b/mm/memory.c
index ea9f28e44b81..7861d3556c6e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -239,6 +239,7 @@ void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long
 	tlb->page_size = 0;
 
 	__tlb_reset_range(tlb);
+	set_tlb_flush_pending(tlb->mm);
 }
 
 static void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
@@ -278,8 +279,18 @@ void tlb_flush_mmu(struct mmu_gather *tlb)
 void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
 	struct mmu_gather_batch *batch, *next;
+	/*
+	 * If there are parallel threads are doing PTE changes on same range
+	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
+	 * flush by batching, a thread has stable TLB entry can fail to flush
+	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
+	 * if we detect parallel PTE batching threads.
+	 */
+	if (mm_tlb_flush_pending(tlb->mm, false) > 1)
+		__tlb_adjust_range(tlb, start, end - start);
 
 	tlb_flush_mmu(tlb);
+	clear_tlb_flush_pending(tlb->mm);
 
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
@@ -1485,20 +1496,9 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
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
