Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 905B0280003
	for <linux-mm@kvack.org>; Sat, 13 Jun 2015 05:49:55 -0400 (EDT)
Received: by wigg3 with SMTP id g3so34744517wig.1
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 02:49:55 -0700 (PDT)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com. [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id en9si7882911wib.46.2015.06.13.02.49.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Jun 2015 02:49:53 -0700 (PDT)
Received: by wifx6 with SMTP id x6so34980907wif.0
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 02:49:52 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 12/12] x86/mm: Simplify pgd_alloc()
Date: Sat, 13 Jun 2015 11:49:15 +0200
Message-Id: <1434188955-31397-13-git-send-email-mingo@kernel.org>
In-Reply-To: <1434188955-31397-1-git-send-email-mingo@kernel.org>
References: <1434188955-31397-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>

Right now pgd_alloc() uses pgd_ctor(), which copies over the
current swapper_pg_dir[] to a new task's PGD.

This is not necessary, it's enough if we clear it: the PGD will
then be properly updated by arch_pgd_init_late().

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Waiman Long <Waiman.Long@hp.com>
Cc: linux-mm@kvack.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/mm/pgtable.c | 27 +++++++++------------------
 1 file changed, 9 insertions(+), 18 deletions(-)

diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 7cca42c01677..d7d341e57e33 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -87,20 +87,6 @@ void ___pud_free_tlb(struct mmu_gather *tlb, pud_t *pud)
 #define UNSHARED_PTRS_PER_PGD				\
 	(SHARED_KERNEL_PMD ? KERNEL_PGD_BOUNDARY : PTRS_PER_PGD)
 
-static void pgd_ctor(struct mm_struct *mm, pgd_t *pgd)
-{
-	/* If the pgd points to a shared pagetable level (either the
-	   ptes in non-PAE, or shared PMD in PAE), then just copy the
-	   references from swapper_pg_dir. */
-	if (CONFIG_PGTABLE_LEVELS == 2 ||
-	    (CONFIG_PGTABLE_LEVELS == 3 && SHARED_KERNEL_PMD) ||
-	    CONFIG_PGTABLE_LEVELS == 4) {
-		clone_pgd_range(pgd + KERNEL_PGD_BOUNDARY,
-				swapper_pg_dir + KERNEL_PGD_BOUNDARY,
-				KERNEL_PGD_PTRS);
-	}
-}
-
 /*
  * List of all pgd's needed for non-PAE so it can invalidate entries
  * in both cached and uncached pgd's; not needed for PAE since the
@@ -328,11 +314,16 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 		goto out_free_pmds;
 
 	/*
-	 * No locking is needed here, as the PGD is still private,
-	 * so no code walking the task list and looking at mm->pgd
-	 * will be able to see it before it's fully constructed:
+	 * Zero out the kernel portion here, we'll set them up in
+	 * arch_pgd_init_late(), when the pgd is globally
+	 * visible already per the task list, so that it cannot
+	 * miss updates.
+	 *
+	 * We need to zero it here, to make sure arch_pgd_init_late()
+	 * can initialize them without locking.
 	 */
-	pgd_ctor(mm, pgd);
+	memset(pgd + KERNEL_PGD_BOUNDARY, 0, KERNEL_PGD_PTRS*sizeof(pgd_t));
+
 	pgd_prepopulate_pmd(mm, pgd, pmds);
 
 	return pgd;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
