Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 669A66B0550
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 03:19:06 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 16so41750356pgg.8
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 00:19:06 -0700 (PDT)
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id f11si11871153pln.472.2017.08.02.00.19.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 02 Aug 2017 00:19:05 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: [PATCH v6 4/7] mm: refactoring TLB gathering API
Date: Tue, 1 Aug 2017 17:08:15 -0700
Message-ID: <20170802000818.4760-5-namit@vmware.com>
In-Reply-To: <20170802000818.4760-1-namit@vmware.com>
References: <20170802000818.4760-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: nadav.amit@gmail.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Minchan Kim <minchan@kernel.org>, Ingo Molnar <mingo@redhat.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "David S.
 Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Jeff Dike <jdike@addtoit.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Nadav Amit <namit@vmware.com>

From: Minchan Kim <minchan@kernel.org>

This patch is a preparatory patch for solving race problems caused by
TLB batch.  For that, we will increase/decrease TLB flush pending count
of mm_struct whenever tlb_[gather|finish]_mmu is called.

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
Cc: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
---
 arch/arm/include/asm/tlb.h  |  6 ++++--
 arch/ia64/include/asm/tlb.h |  6 ++++--
 arch/s390/include/asm/tlb.h | 12 ++++++------
 arch/sh/include/asm/tlb.h   |  6 ++++--
 arch/um/include/asm/tlb.h   |  8 +++++---
 include/asm-generic/tlb.h   |  7 ++++---
 include/linux/mm_types.h    |  6 ++++++
 mm/memory.c                 | 28 +++++++++++++++++++++-------
 8 files changed, 54 insertions(+), 25 deletions(-)

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
index 853b2a3d8dee..0e59ef57e234 100644
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
index 8afa4335e5b2..8f71521e7a44 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -112,10 +112,11 @@ struct mmu_gather {
 
 #define HAVE_GENERIC_MMU_GATHER
 
-void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long start, unsigned long end);
+void arch_tlb_gather_mmu(struct mmu_gather *tlb,
+	struct mm_struct *mm, unsigned long start, unsigned long end);
 void tlb_flush_mmu(struct mmu_gather *tlb);
-void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start,
-							unsigned long end);
+void arch_tlb_finish_mmu(struct mmu_gather *tlb,
+			 unsigned long start, unsigned long end);
 extern bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page,
 				   int page_size);
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 2956513619a7..248f4ed1f3e1 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -518,6 +518,12 @@ static inline cpumask_t *mm_cpumask(struct mm_struct *mm)
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
index bb11c474857e..7848b5030be0 100644
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
+void arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
+				unsigned long start, unsigned long end)
 {
 	tlb->mm = mm;
 
@@ -275,7 +271,8 @@ void tlb_flush_mmu(struct mmu_gather *tlb)
  *	Called at the end of the shootdown operation to free up any resources
  *	that were required.
  */
-void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
+void arch_tlb_finish_mmu(struct mmu_gather *tlb,
+		unsigned long start, unsigned long end)
 {
 	struct mmu_gather_batch *batch, *next;
 
@@ -398,6 +395,23 @@ void tlb_remove_table(struct mmu_gather *tlb, void *table)
 
 #endif /* CONFIG_HAVE_RCU_TABLE_FREE */
 
+/* tlb_gather_mmu
+ *	Called to initialize an (on-stack) mmu_gather structure for page-table
+ *	tear-down from @mm. The @fullmm argument is used when @mm is without
+ *	users and we're going to destroy the full address space (exit/execve).
+ */
+void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
+			unsigned long start, unsigned long end)
+{
+	arch_tlb_gather_mmu(tlb, mm, start, end);
+}
+
+void tlb_finish_mmu(struct mmu_gather *tlb,
+		unsigned long start, unsigned long end)
+{
+	arch_tlb_finish_mmu(tlb, start, end);
+}
+
 /*
  * Note: this doesn't free the actual pages themselves. That
  * has been handled earlier when unmapping all the memory regions.
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
