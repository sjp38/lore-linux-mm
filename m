Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 89D4528028E
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 05:15:32 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id e8so404881wmc.6
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 02:15:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 89si2379481edh.295.2017.11.10.02.15.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Nov 2017 02:15:30 -0800 (PST)
Date: Fri, 10 Nov 2017 11:15:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RESEND PATCH] mm, oom_reaper: gather each vma to prevent
 leaking TLB entry
Message-ID: <20171110101529.op6yaxtdke2p4bsh@dhcp22.suse.cz>
References: <20171107095453.179940-1-wangnan0@huawei.com>
 <20171110001933.GA12421@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171110001933.GA12421@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Wang Nan <wangnan0@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, Bob Liu <liubo95@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Roman Gushchin <guro@fb.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>

On Fri 10-11-17 09:19:33, Minchan Kim wrote:
> On Tue, Nov 07, 2017 at 09:54:53AM +0000, Wang Nan wrote:
> > tlb_gather_mmu(&tlb, mm, 0, -1) means gathering the whole virtual memory
> > space. In this case, tlb->fullmm is true. Some archs like arm64 doesn't
> > flush TLB when tlb->fullmm is true:
> > 
> >   commit 5a7862e83000 ("arm64: tlbflush: avoid flushing when fullmm == 1").
> > 
> > Which makes leaking of tlb entries.
> 
> That means soft-dirty which has used tlb_gather_mmu with fullmm could be
> broken via losing write-protection bit once it supports arm64 in future?
> 
> If so, it would be better to use TASK_SIZE rather than -1 in tlb_gather_mmu.
> Of course, it's a off-topic.

I wouldn't play tricks like that. And maybe the API itself could be more
explicit. E.g. add a lazy parameter which would allow arch specific code
to not flush if it is sure that nobody can actually stumble over missed
flush. E.g. the following?

diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index d5562f9ce600..fe9042aee8e9 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -149,7 +149,8 @@ static inline void tlb_flush_mmu(struct mmu_gather *tlb)
 
 static inline void
 arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
-			unsigned long start, unsigned long end)
+			unsigned long start, unsigned long end,
+			bool lazy)
 {
 	tlb->mm = mm;
 	tlb->fullmm = !(start | (end+1));
diff --git a/arch/arm64/include/asm/tlb.h b/arch/arm64/include/asm/tlb.h
index ffdaea7954bb..7adde19b2bcc 100644
--- a/arch/arm64/include/asm/tlb.h
+++ b/arch/arm64/include/asm/tlb.h
@@ -43,7 +43,7 @@ static inline void tlb_flush(struct mmu_gather *tlb)
 	 * The ASID allocator will either invalidate the ASID or mark
 	 * it as used.
 	 */
-	if (tlb->fullmm)
+	if (tlb->lazy)
 		return;
 
 	/*
diff --git a/arch/ia64/include/asm/tlb.h b/arch/ia64/include/asm/tlb.h
index cbe5ac3699bf..50c440f5b7bc 100644
--- a/arch/ia64/include/asm/tlb.h
+++ b/arch/ia64/include/asm/tlb.h
@@ -169,7 +169,8 @@ static inline void __tlb_alloc_page(struct mmu_gather *tlb)
 
 static inline void
 arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
-			unsigned long start, unsigned long end)
+			unsigned long start, unsigned long end,
+			bool lazy)
 {
 	tlb->mm = mm;
 	tlb->max = ARRAY_SIZE(tlb->local);
diff --git a/arch/s390/include/asm/tlb.h b/arch/s390/include/asm/tlb.h
index 2eb8ff0d6fca..2310657b64c4 100644
--- a/arch/s390/include/asm/tlb.h
+++ b/arch/s390/include/asm/tlb.h
@@ -49,7 +49,8 @@ extern void tlb_remove_table(struct mmu_gather *tlb, void *table);
 
 static inline void
 arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
-			unsigned long start, unsigned long end)
+			unsigned long start, unsigned long end,
+			bool lazy)
 {
 	tlb->mm = mm;
 	tlb->start = start;
diff --git a/arch/sh/include/asm/tlb.h b/arch/sh/include/asm/tlb.h
index 51a8bc967e75..ae4c50a7c1ec 100644
--- a/arch/sh/include/asm/tlb.h
+++ b/arch/sh/include/asm/tlb.h
@@ -37,7 +37,7 @@ static inline void init_tlb_gather(struct mmu_gather *tlb)
 
 static inline void
 arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
-		unsigned long start, unsigned long end)
+		unsigned long start, unsigned long end, bool lazy)
 {
 	tlb->mm = mm;
 	tlb->start = start;
diff --git a/arch/um/include/asm/tlb.h b/arch/um/include/asm/tlb.h
index 344d95619d03..f24af66d07a4 100644
--- a/arch/um/include/asm/tlb.h
+++ b/arch/um/include/asm/tlb.h
@@ -46,7 +46,7 @@ static inline void init_tlb_gather(struct mmu_gather *tlb)
 
 static inline void
 arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
-		unsigned long start, unsigned long end)
+		unsigned long start, unsigned long end, bool lazy)
 {
 	tlb->mm = mm;
 	tlb->start = start;
diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index faddde44de8c..c312fcd5a953 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -102,6 +102,7 @@ struct mmu_gather {
 	/* we have performed an operation which
 	 * requires a complete flush of the tlb */
 				need_flush_all : 1;
+				lazy : 1;
 
 	struct mmu_gather_batch *active;
 	struct mmu_gather_batch	local;
@@ -113,7 +114,8 @@ struct mmu_gather {
 #define HAVE_GENERIC_MMU_GATHER
 
 void arch_tlb_gather_mmu(struct mmu_gather *tlb,
-	struct mm_struct *mm, unsigned long start, unsigned long end);
+	struct mm_struct *mm, unsigned long start, unsigned long end,
+	bool lazy);
 void tlb_flush_mmu(struct mmu_gather *tlb);
 void arch_tlb_finish_mmu(struct mmu_gather *tlb,
 			 unsigned long start, unsigned long end, bool force);
diff --git a/mm/memory.c b/mm/memory.c
index 590709e84a43..7dfdd4d8224f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -218,13 +218,15 @@ static bool tlb_next_batch(struct mmu_gather *tlb)
 }
 
 void arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
-				unsigned long start, unsigned long end)
+				unsigned long start, unsigned long end,
+				bool lazy)
 {
 	tlb->mm = mm;
 
 	/* Is it from 0 to ~0? */
 	tlb->fullmm     = !(start | (end+1));
 	tlb->need_flush_all = 0;
+	tlb->lazy	= lazy;
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
+/* tlb_gather_mmu_lazy
+ * 	Basically same as tlb_gather_mmu except it allows architectures to
+ * 	skip tlb flushing if they can ensure that nobody will reuse tlb entries
+ */
+void tlb_gather_mmu_lazy(struct mmu_gather *tlb, struct mm_struct *mm,
+			unsigned long start, unsigned long end)
+{
+	arch_tlb_gather_mmu(tlb, mm, start, end, true);
 	inc_tlb_flush_pending(tlb->mm);
 }
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 680506faceae..43594a6a2eac 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2997,7 +2997,7 @@ void exit_mmap(struct mm_struct *mm)
 
 	lru_add_drain();
 	flush_cache_mm(mm);
-	tlb_gather_mmu(&tlb, mm, 0, -1);
+	tlb_gather_mmu_lazy(&tlb, mm, 0, -1);
 	/* update_hiwater_rss(mm) here? but nobody should be looking */
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	unmap_vmas(&tlb, vma, 0, -1);

> However, I want to add a big fat comment in tlb_gather_mmu to warn "TLB
> flushing with (0, -1) can be skipped on some architectures" so upcoming
> users can care of.

Yes, this would be really useful if the api is not explicit.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
