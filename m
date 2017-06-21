Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id B2C7B6B02F3
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 01:22:22 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id k126so98019744oia.7
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 22:22:22 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y204si4554977oig.365.2017.06.20.22.22.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 22:22:21 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v3 02/11] x86/ldt: Simplify LDT switching logic
Date: Tue, 20 Jun 2017 22:22:08 -0700
Message-Id: <2a859ac01245f9594c58f9d0a8b2ed8a7cd2507e.1498022414.git.luto@kernel.org>
In-Reply-To: <cover.1498022414.git.luto@kernel.org>
References: <cover.1498022414.git.luto@kernel.org>
In-Reply-To: <cover.1498022414.git.luto@kernel.org>
References: <cover.1498022414.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>

Originally, Linux reloaded the LDT whenever the prev mm or the next
mm had an LDT.  It was changed in 0bbed3beb4f2 ("[PATCH]
Thread-Local Storage (TLS) support") (from the historical tree) like
this:

-		/* load_LDT, if either the previous or next thread
-		 * has a non-default LDT.
+		/*
+		 * load the LDT, if the LDT is different:
		 */
-		if (next->context.size+prev->context.size)
+		if (unlikely(prev->context.ldt != next->context.ldt))
			load_LDT(&next->context);

The current code is unlikely to avoid any LDT reloads, since different
mms won't share an LDT.

When we redo lazy mode to stop flush IPIs without switching to
init_mm, though, the current logic would become incorrect: it will
be possible to have real_prev == next but nonetheless have a stale
LDT descriptor.

Simplify the code to update LDTR if either the previous or the next
mm has an LDT, i.e. effectively restore the historical logic..
While we're at it, clean up the code by moving all the ifdeffery to
a header where it belongs.

Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/mmu_context.h | 26 ++++++++++++++++++++++++++
 arch/x86/mm/tlb.c                  | 20 ++------------------
 2 files changed, 28 insertions(+), 18 deletions(-)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 1458f530948b..ecfcb6643c9b 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -93,6 +93,32 @@ static inline void load_mm_ldt(struct mm_struct *mm)
 #else
 	clear_LDT();
 #endif
+}
+
+static inline void switch_ldt(struct mm_struct *prev, struct mm_struct *next)
+{
+#ifdef CONFIG_MODIFY_LDT_SYSCALL
+	/*
+	 * Load the LDT if either the old or new mm had an LDT.
+	 *
+	 * An mm will never go from having an LDT to not having an LDT.  Two
+	 * mms never share an LDT, so we don't gain anything by checking to
+	 * see whether the LDT changed.  There's also no guarantee that
+	 * prev->context.ldt actually matches LDTR, but, if LDTR is non-NULL,
+	 * then prev->context.ldt will also be non-NULL.
+	 *
+	 * If we really cared, we could optimize the case where prev == next
+	 * and we're exiting lazy mode.  Most of the time, if this happens,
+	 * we don't actually need to reload LDTR, but modify_ldt() is mostly
+	 * used by legacy code and emulators where we don't need this level of
+	 * performance.
+	 *
+	 * This uses | instead of || because it generates better code.
+	 */
+	if (unlikely((unsigned long)prev->context.ldt |
+		     (unsigned long)next->context.ldt))
+		load_mm_ldt(next);
+#endif
 
 	DEBUG_LOCKS_WARN_ON(preemptible());
 }
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index f06239c6919f..fd593833a854 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -148,25 +148,9 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 		     real_prev != &init_mm);
 	cpumask_clear_cpu(cpu, mm_cpumask(real_prev));
 
-	/* Load per-mm CR4 state */
+	/* Load per-mm CR4 and LDTR state */
 	load_mm_cr4(next);
-
-#ifdef CONFIG_MODIFY_LDT_SYSCALL
-	/*
-	 * Load the LDT, if the LDT is different.
-	 *
-	 * It's possible that prev->context.ldt doesn't match
-	 * the LDT register.  This can happen if leave_mm(prev)
-	 * was called and then modify_ldt changed
-	 * prev->context.ldt but suppressed an IPI to this CPU.
-	 * In this case, prev->context.ldt != NULL, because we
-	 * never set context.ldt to NULL while the mm still
-	 * exists.  That means that next->context.ldt !=
-	 * prev->context.ldt, because mms never share an LDT.
-	 */
-	if (unlikely(real_prev->context.ldt != next->context.ldt))
-		load_mm_ldt(next);
-#endif
+	switch_ldt(real_prev, next);
 }
 
 /*
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
