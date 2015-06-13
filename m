Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 04F13280003
	for <linux-mm@kvack.org>; Sat, 13 Jun 2015 05:49:44 -0400 (EDT)
Received: by wibut5 with SMTP id ut5so35642489wib.1
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 02:49:43 -0700 (PDT)
Received: from mail-wg0-x230.google.com (mail-wg0-x230.google.com. [2a00:1450:400c:c00::230])
        by mx.google.com with ESMTPS id j1si7852558wia.88.2015.06.13.02.49.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Jun 2015 02:49:43 -0700 (PDT)
Received: by wgbhy7 with SMTP id hy7so4474889wgb.2
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 02:49:42 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 06/12] x86/mm: Enable and use the arch_pgd_init_late() method
Date: Sat, 13 Jun 2015 11:49:09 +0200
Message-Id: <1434188955-31397-7-git-send-email-mingo@kernel.org>
In-Reply-To: <1434188955-31397-1-git-send-email-mingo@kernel.org>
References: <1434188955-31397-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>

Prepare for lockless PGD init: enable the arch_pgd_init_late() callback
and add a 'careful' implementation of PGD init to it: only copy over
non-zero entries.

Since PGD entries only ever get added, this method catches any updates
to swapper_pg_dir[] that might have occurred between early PGD init
and late PGD init.

Note that this only matters for code that does not use the pgd_list but
the task list to find all PGDs in the system.

Subsequent patches will convert pgd_list users to task-list iterations.

[ This adds extra overhead in that we do the PGD initialization for a
  second time - a later patch will simplify this, once we don't have
  old pgd_list users. ]

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/Kconfig      |  1 +
 arch/x86/mm/pgtable.c | 59 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 60 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 7e39f9b22705..15c19ce149f0 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -27,6 +27,7 @@ config X86
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_FAST_MULTIPLIER
 	select ARCH_HAS_GCOV_PROFILE_ALL
+	select ARCH_HAS_PGD_INIT_LATE
 	select ARCH_HAS_SG_CHAIN
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select ARCH_MIGHT_HAVE_ACPI_PDC		if ACPI
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index fb0a9dd1d6e4..7a561b7cc01c 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -391,6 +391,65 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 	return NULL;
 }
 
+/*
+ * Initialize the kernel portion of the PGD.
+ *
+ * This is done separately, because pgd_alloc() happens when
+ * the task is not on the task list yet - and PGD updates
+ * happen by walking the task list.
+ *
+ * No locking is needed here, as we just copy over the reference
+ * PGD. The reference PGD (pgtable_init) is only ever expanded
+ * at the highest, PGD level. Thus any other task extending it
+ * will first update the reference PGD, then modify the task PGDs.
+ */
+void arch_pgd_init_late(struct mm_struct *mm)
+{
+	/*
+	 * This function is called after a new MM has been made visible
+	 * in fork() or exec() via:
+	 *
+	 *   tsk->mm = mm;
+	 *
+	 * This barrier makes sure the MM is visible to new RCU
+	 * walkers before we initialize the pagetables below, so that
+	 * we don't miss updates:
+	 */
+	smp_wmb();
+
+	/*
+	 * If the pgd points to a shared pagetable level (either the
+	 * ptes in non-PAE, or shared PMD in PAE), then just copy the
+	 * references from swapper_pg_dir:
+	 */
+	if ( CONFIG_PGTABLE_LEVELS == 2 ||
+	    (CONFIG_PGTABLE_LEVELS == 3 && SHARED_KERNEL_PMD) ||
+	     CONFIG_PGTABLE_LEVELS == 4) {
+
+		pgd_t *pgd_src = swapper_pg_dir + KERNEL_PGD_BOUNDARY;
+		pgd_t *pgd_dst =        mm->pgd + KERNEL_PGD_BOUNDARY;
+		int i;
+
+		for (i = 0; i < KERNEL_PGD_PTRS; i++, pgd_src++, pgd_dst++) {
+			/*
+			 * This is lock-less, so it can race with PGD updates
+			 * coming from vmalloc() or CPA methods, but it's safe,
+			 * because:
+			 *
+			 * 1) this PGD is not in use yet, we have still not
+			 *    scheduled this task.
+			 * 2) we only ever extend PGD entries
+			 *
+			 * So if we observe a non-zero PGD entry we can copy it,
+			 * it won't change from under us. Parallel updates (new
+			 * allocations) will modify our (already visible) PGD:
+			 */
+			if (!pgd_none(*pgd_src))
+				set_pgd(pgd_dst, *pgd_src);
+		}
+	}
+}
+
 void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	pgd_mop_up_pmds(mm, pgd);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
