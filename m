Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id E80F86B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 18:37:05 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id 36so4284947otv.7
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 15:37:05 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q16si11099105otd.200.2017.06.05.15.37.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 15:37:05 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 01/11] x86/ldt: Simplify LDT switching logic
Date: Mon,  5 Jun 2017 15:36:25 -0700
Message-Id: <a5eb3dead15bcb36732bb5b655ef4ebe23cf4aa3.1496701658.git.luto@kernel.org>
In-Reply-To: <cover.1496701658.git.luto@kernel.org>
References: <cover.1496701658.git.luto@kernel.org>
In-Reply-To: <cover.1496701658.git.luto@kernel.org>
References: <cover.1496701658.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>
Cc: Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Andy Lutomirski <luto@kernel.org>

We used to switch the LDT if the prev and next mms' LDTs didn't
match.  This was correct but overcomplicated -- it was subject to a
harmless race if prev called modify_ldt() which switching.  It was
also a pointless optimization, since different mms' LDTs are always
different.

Simplify the code to update LDTR if either the previous or the next
mm has an LDT.  While we're at it, clean up the code by moving all
the ifdeffery to a header where it belongs.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/mmu_context.h | 23 +++++++++++++++++++++++
 arch/x86/mm/tlb.c                  | 20 ++------------------
 2 files changed, 25 insertions(+), 18 deletions(-)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index f20d7ea47095..d59bbfb4c8b4 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -93,6 +93,29 @@ static inline void load_mm_ldt(struct mm_struct *mm)
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
+	 * and we're existing lazy mode.  Most of the time, if this happens,
+	 * we don't actually need to reload LDTR, but modify_ldt() is mostly
+	 * used by legacy code and emulators where we don't need this level of
+	 * performance.
+	 */
+	if (unlikely(prev->context.ldt || next->context.ldt))
+		load_mm_ldt(next);
+#endif
 
 	DEBUG_LOCKS_WARN_ON(preemptible());
 }
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 2a5e851f2035..b2485d69f7c2 100644
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
