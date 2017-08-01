Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C0D186B04EC
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 01:56:21 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p20so7304333pfj.2
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 22:56:21 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id q11si18543428pli.172.2017.07.31.22.56.19
        for <linux-mm@kvack.org>;
        Mon, 31 Jul 2017 22:56:20 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 1/4] mm: refactoring TLB gathering API
Date: Tue,  1 Aug 2017 14:56:14 +0900
Message-Id: <1501566977-20293-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1501566977-20293-1-git-send-email-minchan@kernel.org>
References: <1501566977-20293-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>, Ingo Molnar <mingo@redhat.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Jeff Dike <jdike@addtoit.com>, linux-arch@vger.kernel.org, Nadav Amit <nadav.amit@gmail.com>, Mel Gorman <mgorman@techsingularity.net>

This patch is ready for solving race problems caused by TLB batch.
For that, we will increase/decrease TLB flush pending count of
mm_struct whenever tlb_[gather|finish]_mmu is called.

Before making it simple, this patch separates architecture specific
part and rename it to arch_tlb_[gather|finish]_mmu and generic part
just calls it.

It shouldn't change any behavior.

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
Cc: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 arch/arm/include/asm/tlb.h  |  6 ++++--
 arch/ia64/include/asm/tlb.h |  6 ++++--
 arch/s390/include/asm/tlb.h | 12 ++++++------
 arch/sh/include/asm/tlb.h   |  6 ++++--
 arch/um/include/asm/tlb.h   |  8 +++++---
 include/asm-generic/tlb.h   |  7 ++++---
 include/linux/mm_types.h    |  6 ++++++
 mm/memory.c                 | 36 +++++++++++++++++++++++++++++-------
 8 files changed, 62 insertions(+), 25 deletions(-)

diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index 3f2eb76243e3..7f5b2a2d3861 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -148,7 +148,8 @@ static inline void tlb_flush_mmu(struct mmu_gather *tlb)
 }
 
 static inline void
-tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long start, unsigned long end)
+arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
+			unsigned long start, unsigned long end)
 {
 	tlb->mm = mm;
 	tlb->fullmm = !(start | (end+1));
@@ -166,7 +167,8 @@ tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long start
 }
 
 static inline void
-tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
+arch_tlb_finish_mmu(struct mmu_gather *tlb,
+			unsigned long start, unsigned long end)
 {
 	tlb_flush_mmu(tlb);
 
diff --git a/arch/ia64/include/asm/tlb.h b/arch/ia64/include/asm/tlb.h
index fced197b9626..93cadc04ac62 100644
--- a/arch/ia64/include/asm/tlb.h
+++ b/arch/ia64/include/asm/tlb.h
@@ -168,7 +168,8 @@ static inline void __tlb_alloc_page(struct mmu_gather *tlb)
 
 
 static inline void
-tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long start, unsigned long end)
+arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
+			unsigned long start, unsigned long end)
 {
 	tlb->mm = mm;
 	tlb->max = ARRAY_SIZE(tlb->local);
@@ -185,7 +186,8 @@ tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long start
  * collected.
  */
 static inline void
-tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
+arch_tlb_finish_mmu(struct mmu_gather *tlb,
+			unsigned long start, unsigned long end)
 {
 	/*
 	 * Note: tlb->nr may be 0 at this point, so we can't rely on tlb->start_addr and
diff --git a/arch/s390/include/asm/tlb.h b/arch/s390/include/asm/tlb.h
index 950af48e88be..fa4b461694b7 100644
--- a/arch/s390/include/asm/tlb.h
+++ b/arch/s390/include/asm/tlb.h
@@ -47,10 +47,9 @@ struct mmu_table_batch {
 extern void tlb_table_flush(struct mmu_gather *tlb);
 extern void tlb_remove_table(struct mmu_gather *tlb, void *table);
 
-static inline void tlb_gather_mmu(struct mmu_gather *tlb,
-				  struct mm_struct *mm,
-				  unsigned long start,
-				  unsigned long end)
+static inline void
+arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
+			unsigned long start, unsigned long end)
 {
 	tlb->mm = mm;
 	tlb->start = start;
@@ -76,8 +75,9 @@ static inline void tlb_flush_mmu(struct mmu_gather *tlb)
 	tlb_flush_mmu_free(tlb);
 }
 
-static inline void tlb_finish_mmu(struct mmu_gather *tlb,
-				  unsigned long start, unsigned long end)
+static inline void
+arch_tlb_finish_mmu(struct mmu_gather *tlb,
+		unsigned long start, unsigned long end)
 {
 	tlb_flush_mmu(tlb);
 }
diff --git a/arch/sh/include/asm/tlb.h b/arch/sh/include/asm/tlb.h
index 46e0d635e36f..89786560dbd4 100644
--- a/arch/sh/include/asm/tlb.h
+++ b/arch/sh/include/asm/tlb.h
@@ -36,7 +36,8 @@ static inline void init_tlb_gather(struct mmu_gather *tlb)
 }
 
 static inline void
-tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long start, unsigned long end)
+arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
+		unsigned long start, unsigned long end)
 {
 	tlb->mm = mm;
 	tlb->start = start;
@@ -47,7 +48,8 @@ tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long start
 }
 
 static inline void
-tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
+arch_tlb_finish_mmu(struct mmu_gather *tlb,
+		unsigned long start, unsigned long end)
 {
 	if (tlb->fullmm)
 		flush_tlb_mm(tlb->mm);
diff --git a/arch/um/include/asm/tlb.h b/arch/um/include/asm/tlb.h
index 600a2e9bfee2..2a901eca7145 100644
--- a/arch/um/include/asm/tlb.h
+++ b/arch/um/include/asm/tlb.h
@@ -45,7 +45,8 @@ static inline void init_tlb_gather(struct mmu_gather *tlb)
 }
 
 static inline void
-tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long start, unsigned long end)
+arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
+		unsigned long start, unsigned long end)
 {
 	tlb->mm = mm;
 	tlb->start = start;
@@ -80,12 +81,13 @@ tlb_flush_mmu(struct mmu_gather *tlb)
 	tlb_flush_mmu_free(tlb);
 }
 
-/* tlb_finish_mmu
+/* arch_tlb_finish_mmu
  *	Called at the end of the shootdown operation to free up any resources
  *	that were required.
  */
 static inline void
-tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
+arch_tlb_finish_mmu(struct mmu_gather *tlb,
+		unsigned long start, unsigned long end)
 {
 	tlb_flush_mmu(tlb);
 
diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index 8afa4335e5b2..ae05fdf96c2d 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -112,10 +112,11 @@ struct mmu_gather {
 
 #define HAVE_GENERIC_MMU_GATHER
 
-void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long start, unsigned long end);
+void arch_generic_tlb_gather_mmu(struct mmu_gather *tlb,
+	struct mm_struct *mm, unsigned long start, unsigned long end);
 void tlb_flush_mmu(struct mmu_gather *tlb);
-void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start,
-							unsigned long end);
+void arch_generic_tlb_finish_mmu(struct mmu_gather *tlb,
+		unsigned long start, unsigned long end);
 extern bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page,
 				   int page_size);
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 0e478ebd2706..c605f2a3a68e 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -522,6 +522,12 @@ static inline cpumask_t *mm_cpumask(struct mm_struct *mm)
 	return mm->cpu_vm_mask_var;
 }
 
+struct mmu_gather;
+extern void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
+				unsigned long start, unsigned long end);
+extern void tlb_finish_mmu(struct mmu_gather *tlb,
+				unsigned long start, unsigned long end);
+
 #if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
 /*
  * Memory barriers to keep this state in sync are graciously provided by
diff --git a/mm/memory.c b/mm/memory.c
index edabf6f03447..80012d7a9451 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -215,12 +215,8 @@ static bool tlb_next_batch(struct mmu_gather *tlb)
 	return true;
 }
 
-/* tlb_gather_mmu
- *	Called to initialize an (on-stack) mmu_gather structure for page-table
- *	tear-down from @mm. The @fullmm argument is used when @mm is without
- *	users and we're going to destroy the full address space (exit/execve).
- */
-void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long start, unsigned long end)
+void arch_generic_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
+				unsigned long start, unsigned long end)
 {
 	tlb->mm = mm;
 
@@ -275,7 +271,8 @@ void tlb_flush_mmu(struct mmu_gather *tlb)
  *	Called at the end of the shootdown operation to free up any resources
  *	that were required.
  */
-void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
+void arch_generic_tlb_finish_mmu(struct mmu_gather *tlb,
+		unsigned long start, unsigned long end)
 {
 	struct mmu_gather_batch *batch, *next;
 
@@ -398,6 +395,31 @@ void tlb_remove_table(struct mmu_gather *tlb, void *table)
 
 #endif /* CONFIG_HAVE_RCU_TABLE_FREE */
 
+/* tlb_gather_mmu
+ *	Called to initialize an (on-stack) mmu_gather structure for page-table
+ *	tear-down from @mm. The @fullmm argument is used when @mm is without
+ *	users and we're going to destroy the full address space (exit/execve).
+ */
+void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
+			unsigned long start, unsigned long end)
+{
+#ifdef HAVE_GENERIC_MMU_GATHER
+	arch_generic_tlb_gather_mmu(tlb, mm, start, end);
+#else
+	arch_tlb_gather_mmu(tlb, mm, start, end);
+#endif
+}
+
+void tlb_finish_mmu(struct mmu_gather *tlb,
+		unsigned long start, unsigned long end)
+{
+#ifdef HAVE_GENERIC_MMU_GATHER
+	arch_generic_tlb_finish_mmu(tlb, start, end);
+#else
+	arch_tlb_finish_mmu(tlb, start, end);
+#endif
+}
+
 /*
  * Note: this doesn't free the actual pages themselves. That
  * has been handled earlier when unmapping all the memory regions.
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
