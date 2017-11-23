Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 26B146B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 04:02:55 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id a22so3517823wme.0
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 01:02:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c2sor10448741edi.33.2017.11.23.01.02.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 01:02:53 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH] arch, mm: introduce arch_tlb_gather_mmu_exit
Date: Thu, 23 Nov 2017 10:02:36 +0100
Message-Id: <20171123090236.18574-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Will Deacon <will.deacon@arm.com>, Minchan Kim <minchan@kernel.org>, Andrea Argangeli <andrea@kernel.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

5a7862e83000 ("arm64: tlbflush: avoid flushing when fullmm == 1") has
introduced an optimization to not flush tlb when we are tearing the
whole address space down. Will goes on to explain

: Basically, we tag each address space with an ASID (PCID on x86) which
: is resident in the TLB. This means we can elide TLB invalidation when
: pulling down a full mm because we won't ever assign that ASID to
: another mm without doing TLB invalidation elsewhere (which actually
: just nukes the whole TLB).

This all is nice but tlb_gather users are not aware of that and this can
actually cause some real problems. E.g. the oom_reaper tries to reap the
whole address space but it might race with threads accessing the memory [1].
It is possible that soft-dirty handling might suffer from the same
problem [2] as soon as it starts supporting the feature.

Introduce an explicit exit variant tlb_gather_mmu_exit which allows the
behavior arm64 implements for the fullmm case and replace it by an
explicit exit flag in the mmu_gather structure. exit_mmap path is then
turned into the explicit exit variant. Other architectures simply ignore
the flag.

[1] http://lkml.kernel.org/r/20171106033651.172368-1-wangnan0@huawei.com
[2] http://lkml.kernel.org/r/20171110001933.GA12421@bbox
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi,
I am sending this as an RFC because I am not fully familiar with the tlb
gather arch implications, espacially the semantic of fullmm. Therefore
I might duplicate some of its functionality. I hope people on the CC
list will help me to sort this out.

Comments? Objections?

 arch/arm/include/asm/tlb.h   |  3 ++-
 arch/arm64/include/asm/tlb.h |  2 +-
 arch/ia64/include/asm/tlb.h  |  3 ++-
 arch/s390/include/asm/tlb.h  |  3 ++-
 arch/sh/include/asm/tlb.h    |  2 +-
 arch/um/include/asm/tlb.h    |  2 +-
 include/asm-generic/tlb.h    |  6 ++++--
 include/linux/mm_types.h     |  2 ++
 mm/memory.c                  | 17 +++++++++++++++--
 mm/mmap.c                    |  2 +-
 10 files changed, 31 insertions(+), 11 deletions(-)

diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index d5562f9ce600..f2696f831cae 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -149,7 +149,8 @@ static inline void tlb_flush_mmu(struct mmu_gather *tlb)
 
 static inline void
 arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
-			unsigned long start, unsigned long end)
+			unsigned long start, unsigned long end,
+			bool exit)
 {
 	tlb->mm = mm;
 	tlb->fullmm = !(start | (end+1));
diff --git a/arch/arm64/include/asm/tlb.h b/arch/arm64/include/asm/tlb.h
index ffdaea7954bb..812c12f5e634 100644
--- a/arch/arm64/include/asm/tlb.h
+++ b/arch/arm64/include/asm/tlb.h
@@ -43,7 +43,7 @@ static inline void tlb_flush(struct mmu_gather *tlb)
 	 * The ASID allocator will either invalidate the ASID or mark
 	 * it as used.
 	 */
-	if (tlb->fullmm)
+	if (tlb->fullmm && tlb->exit)
 		return;
 
 	/*
diff --git a/arch/ia64/include/asm/tlb.h b/arch/ia64/include/asm/tlb.h
index 44f0ac0df308..f3639447e26d 100644
--- a/arch/ia64/include/asm/tlb.h
+++ b/arch/ia64/include/asm/tlb.h
@@ -170,7 +170,8 @@ static inline void __tlb_alloc_page(struct mmu_gather *tlb)
 
 static inline void
 arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
-			unsigned long start, unsigned long end)
+			unsigned long start, unsigned long end,
+			bool exit)
 {
 	tlb->mm = mm;
 	tlb->max = ARRAY_SIZE(tlb->local);
diff --git a/arch/s390/include/asm/tlb.h b/arch/s390/include/asm/tlb.h
index 457b7ba0fbb6..c02207eb4278 100644
--- a/arch/s390/include/asm/tlb.h
+++ b/arch/s390/include/asm/tlb.h
@@ -50,7 +50,8 @@ extern void tlb_remove_table(struct mmu_gather *tlb, void *table);
 
 static inline void
 arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
-			unsigned long start, unsigned long end)
+			unsigned long start, unsigned long end,
+			bool exit)
 {
 	tlb->mm = mm;
 	tlb->start = start;
diff --git a/arch/sh/include/asm/tlb.h b/arch/sh/include/asm/tlb.h
index 77abe192fb43..c4248c8b1e6b 100644
--- a/arch/sh/include/asm/tlb.h
+++ b/arch/sh/include/asm/tlb.h
@@ -38,7 +38,7 @@ static inline void init_tlb_gather(struct mmu_gather *tlb)
 
 static inline void
 arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
-		unsigned long start, unsigned long end)
+		unsigned long start, unsigned long end, bool exit)
 {
 	tlb->mm = mm;
 	tlb->start = start;
diff --git a/arch/um/include/asm/tlb.h b/arch/um/include/asm/tlb.h
index dce6db147f24..057d5c6adfe0 100644
--- a/arch/um/include/asm/tlb.h
+++ b/arch/um/include/asm/tlb.h
@@ -47,7 +47,7 @@ static inline void init_tlb_gather(struct mmu_gather *tlb)
 
 static inline void
 arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
-		unsigned long start, unsigned long end)
+		unsigned long start, unsigned long end, bool exit)
 {
 	tlb->mm = mm;
 	tlb->start = start;
diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index faddde44de8c..2b29d77d201e 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -101,7 +101,8 @@ struct mmu_gather {
 	unsigned int		fullmm : 1,
 	/* we have performed an operation which
 	 * requires a complete flush of the tlb */
-				need_flush_all : 1;
+				need_flush_all : 1,
+				exit : 1;
 
 	struct mmu_gather_batch *active;
 	struct mmu_gather_batch	local;
@@ -113,7 +114,8 @@ struct mmu_gather {
 #define HAVE_GENERIC_MMU_GATHER
 
 void arch_tlb_gather_mmu(struct mmu_gather *tlb,
-	struct mm_struct *mm, unsigned long start, unsigned long end);
+	struct mm_struct *mm, unsigned long start, unsigned long end,
+	bool exit);
 void tlb_flush_mmu(struct mmu_gather *tlb);
 void arch_tlb_finish_mmu(struct mmu_gather *tlb,
 			 unsigned long start, unsigned long end, bool force);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index cfd0ac4e5e0e..6f6b615259e6 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -527,6 +527,8 @@ static inline cpumask_t *mm_cpumask(struct mm_struct *mm)
 struct mmu_gather;
 extern void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
 				unsigned long start, unsigned long end);
+extern void tlb_gather_mmu_exit(struct mmu_gather *tlb, struct mm_struct *mm,
+				unsigned long start, unsigned long end);
 extern void tlb_finish_mmu(struct mmu_gather *tlb,
 				unsigned long start, unsigned long end);
 
diff --git a/mm/memory.c b/mm/memory.c
index 4617c4e3738e..3dcd3631a37a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -218,13 +218,15 @@ static bool tlb_next_batch(struct mmu_gather *tlb)
 }
 
 void arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
-				unsigned long start, unsigned long end)
+				unsigned long start, unsigned long end,
+				bool exit)
 {
 	tlb->mm = mm;
 
 	/* Is it from 0 to ~0? */
 	tlb->fullmm     = !(start | (end+1));
 	tlb->need_flush_all = 0;
+	tlb->exit	= exit;
 	tlb->local.next = NULL;
 	tlb->local.nr   = 0;
 	tlb->local.max  = ARRAY_SIZE(tlb->__pages);
@@ -408,7 +410,18 @@ void tlb_remove_table(struct mmu_gather *tlb, void *table)
 void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
 			unsigned long start, unsigned long end)
 {
-	arch_tlb_gather_mmu(tlb, mm, start, end);
+	arch_tlb_gather_mmu(tlb, mm, start, end, false);
+	inc_tlb_flush_pending(tlb->mm);
+}
+
+/* tlb_gather_mmu_exit
+ * 	Basically same as tlb_gather_mmu except it allows architectures to
+ * 	skip tlb flushing if they can ensure that nobody will reuse tlb entries
+ */
+void tlb_gather_mmu_exit(struct mmu_gather *tlb, struct mm_struct *mm,
+			unsigned long start, unsigned long end)
+{
+	arch_tlb_gather_mmu(tlb, mm, start, end, true);
 	inc_tlb_flush_pending(tlb->mm);
 }
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 476e810cf100..8fa392ac289f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2999,7 +2999,7 @@ void exit_mmap(struct mm_struct *mm)
 
 	lru_add_drain();
 	flush_cache_mm(mm);
-	tlb_gather_mmu(&tlb, mm, 0, -1);
+	tlb_gather_mmu_exit(&tlb, mm, 0, -1);
 	/* update_hiwater_rss(mm) here? but nobody should be looking */
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	unmap_vmas(&tlb, vma, 0, -1);
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
