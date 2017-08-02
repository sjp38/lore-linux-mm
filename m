Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id ABC826B0550
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 03:19:06 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g9so38469379pfk.13
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 00:19:06 -0700 (PDT)
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id f11si11871153pln.472.2017.08.02.00.19.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 02 Aug 2017 00:19:05 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: [PATCH v6 6/7] mm: fix MADV_[FREE|DONTNEED] TLB flush miss problem
Date: Tue, 1 Aug 2017 17:08:17 -0700
Message-ID: <20170802000818.4760-7-namit@vmware.com>
In-Reply-To: <20170802000818.4760-1-namit@vmware.com>
References: <20170802000818.4760-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: nadav.amit@gmail.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Minchan Kim <minchan@kernel.org>, Ingo Molnar <mingo@redhat.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "David S.
 Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Jeff Dike <jdike@addtoit.com>, linux-arch@vger.kernel.org, Nadav Amit <namit@vmware.com>

From: Minchan Kim <minchan@kernel.org>

Nadav reported parallel MADV_DONTNEED on same range has a stale TLB problem
and Mel fixed it[1] and found same problem on MADV_FREE[2].

Quote from Mel Gorman

"The race in question is CPU 0 running madv_free and updating some PTEs
while CPU 1 is also running madv_free and looking at the same PTEs.  CPU 1
may have writable TLB entries for a page but fail the pte_dirty check
(because CPU 0 has updated it already) and potentially fail to flush.
Hence, when madv_free on CPU 1 returns, there are still potentially
writable TLB entries and the underlying PTE is still present so that a
subsequent write does not necessarily propagate the dirty bit to the
underlying PTE any more.  Reclaim at some unknown time at the future may
then see that the PTE is still clean and discard the page even though a
write has happened in the meantime.  I think this is possible but I could
have missed some protection in madv_free that prevents it happening."

This patch aims for solving both problems all at once and is ready for
other problem with KSM, MADV_FREE and soft-dirty story[3].

TLB batch API(tlb_[gather|finish]_mmu] uses [inc|dec]_tlb_flush_pending and
mmu_tlb_flush_pending so that when tlb_finish_mmu is called, we can catch
there are parallel threads going on. In that case, forcefully, flush TLB to
prevent for user to access memory via stale TLB entry although it fail to
gather page table entry.

I confirmed this patch works with [4] test program Nadav gave so this patch
supersedes "mm: Always flush VMA ranges affected by zap_page_range v2" in
current mmotm.

NOTE:

This patch modifies arch-specific TLB gathering interface(x86, ia64, s390,
sh, um). It seems most of architecture are straightforward but s390 need to
be careful because tlb_flush_mmu works only if mm->context.flush_mm is set
to non-zero which happens only a pte entry really is cleared by
ptep_get_and_clear and friends. However, this problem never changes the pte
entries but need to flush to prevent memory access from stale tlb.

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
Reported-by: Nadav Amit <namit@vmware.com>
Reported-by: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
---
 arch/arm/include/asm/tlb.h  |  7 ++++++-
 arch/ia64/include/asm/tlb.h |  4 +++-
 arch/s390/include/asm/tlb.h |  7 ++++++-
 arch/sh/include/asm/tlb.h   |  4 ++--
 arch/um/include/asm/tlb.h   |  7 ++++++-
 include/asm-generic/tlb.h   |  2 +-
 include/linux/mm_types.h    |  8 ++++++++
 mm/memory.c                 | 17 +++++++++++++++--
 8 files changed, 47 insertions(+), 9 deletions(-)

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
index 0e59ef57e234..b20a3621024f 100644
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
index 8f71521e7a44..faddde44de8c 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -116,7 +116,7 @@ void arch_tlb_gather_mmu(struct mmu_gather *tlb,
 	struct mm_struct *mm, unsigned long start, unsigned long end);
 void tlb_flush_mmu(struct mmu_gather *tlb);
 void arch_tlb_finish_mmu(struct mmu_gather *tlb,
-			 unsigned long start, unsigned long end);
+			 unsigned long start, unsigned long end, bool force);
 extern bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page,
 				   int page_size);
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index fc44315df47a..664c1e553228 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -534,6 +534,14 @@ static inline bool mm_tlb_flush_pending(struct mm_struct *mm)
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
index 7848b5030be0..d7a620dd183a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -272,10 +272,13 @@ void tlb_flush_mmu(struct mmu_gather *tlb)
  *	that were required.
  */
 void arch_tlb_finish_mmu(struct mmu_gather *tlb,
-		unsigned long start, unsigned long end)
+		unsigned long start, unsigned long end, bool force)
 {
 	struct mmu_gather_batch *batch, *next;
 
+	if (force)
+		__tlb_adjust_range(tlb, start, end - start);
+
 	tlb_flush_mmu(tlb);
 
 	/* keep the page table cache within bounds */
@@ -404,12 +407,22 @@ void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
 			unsigned long start, unsigned long end)
 {
 	arch_tlb_gather_mmu(tlb, mm, start, end);
+	inc_tlb_flush_pending(tlb->mm);
 }
 
 void tlb_finish_mmu(struct mmu_gather *tlb,
 		unsigned long start, unsigned long end)
 {
-	arch_tlb_finish_mmu(tlb, start, end);
+	/*
+	 * If there are parallel threads are doing PTE changes on same range
+	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
+	 * flush by batching, a thread has stable TLB entry can fail to flush
+	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
+	 * forcefully if we detect parallel PTE batching threads.
+	 */
+	bool force = mm_tlb_flush_nested(tlb->mm);
+
+	arch_tlb_finish_mmu(tlb, start, end, force);
 }
 
 /*
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
