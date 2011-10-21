Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DA3B96B0034
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 08:22:19 -0400 (EDT)
From: Joerg Roedel <joerg.roedel@amd.com>
Subject: [PATCH 1/3] mm: Disable tlb_fast_mode() when mm has notifiers
Date: Fri, 21 Oct 2011 14:21:46 +0200
Message-ID: <1319199708-17777-2-git-send-email-joerg.roedel@amd.com>
In-Reply-To: <1319199708-17777-1-git-send-email-joerg.roedel@amd.com>
References: <1319199708-17777-1-git-send-email-joerg.roedel@amd.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, joro@8bytes.org, Joerg Roedel <joerg.roedel@amd.com>

When the MMU-Notifiers are used to manage non-CPU TLBs the
tlb_fast_mode can't be used anymore. So disable it when an
mm has notifiers.

Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
---
 include/asm-generic/tlb.h    |    2 +-
 include/linux/mmu_notifier.h |    1 +
 mm/memory.c                  |    2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index e58fa77..8c6cc1b 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -100,7 +100,7 @@ struct mmu_gather {
 
 static inline int tlb_fast_mode(struct mmu_gather *tlb)
 {
-#ifdef CONFIG_SMP
+#if defined(CONFIG_SMP) || defined(CONFIG_MMU_NOTIFIER)
 	return tlb->fast_mode;
 #else
 	/*
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 1d1b1e1..b9469d6 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -373,6 +373,7 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 #define pmdp_clear_flush_notify pmdp_clear_flush
 #define pmdp_splitting_flush_notify pmdp_splitting_flush
 #define set_pte_at_notify set_pte_at
+#define mm_has_notifiers(mm) 0
 
 #endif /* CONFIG_MMU_NOTIFIER */
 
diff --git a/mm/memory.c b/mm/memory.c
index a56e3ba..b31f9e0 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -230,7 +230,7 @@ void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, bool fullmm)
 
 	tlb->fullmm     = fullmm;
 	tlb->need_flush = 0;
-	tlb->fast_mode  = (num_possible_cpus() == 1);
+	tlb->fast_mode  = (num_possible_cpus() == 1) && !mm_has_notifiers(mm);
 	tlb->local.next = NULL;
 	tlb->local.nr   = 0;
 	tlb->local.max  = ARRAY_SIZE(tlb->__pages);
-- 
1.7.5.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
