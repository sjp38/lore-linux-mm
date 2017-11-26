Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id EF5536B025E
	for <linux-mm@kvack.org>; Sun, 26 Nov 2017 18:26:47 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id a45so1356981wra.14
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 15:26:47 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 28si9779668wrw.317.2017.11.26.15.26.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 26 Nov 2017 15:26:47 -0800 (PST)
Message-Id: <20171126232414.481903103@linutronix.de>
Date: Mon, 27 Nov 2017 00:14:06 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch V2 3/5] x86/dump_pagetables: Check KAISER shadow page table
 for WX pages
References: <20171126231403.657575796@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=x86-kaiser--Check-shadow-pagetable-for-WX-mappings.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

ptdump_walk_pgd_level_checkwx() checks the kernel page table for WX pages,
but does not check the KAISER shadow page table.

Restructure the code so that dmesg output is selected by an explicit
argument and not implicit via checking the pgd argument for !NULL. 
Add the check for the shadow page table.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/include/asm/pgtable.h |    1 +
 arch/x86/mm/debug_pagetables.c |    2 +-
 arch/x86/mm/dump_pagetables.c  |   27 ++++++++++++++++++++++-----
 3 files changed, 24 insertions(+), 6 deletions(-)

--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -28,6 +28,7 @@ extern pgd_t early_top_pgt[PTRS_PER_PGD]
 int __init __early_make_pgtable(unsigned long address, pmdval_t pmd);
 
 void ptdump_walk_pgd_level(struct seq_file *m, pgd_t *pgd);
+void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd);
 void ptdump_walk_pgd_level_checkwx(void);
 
 #ifdef CONFIG_DEBUG_WX
--- a/arch/x86/mm/debug_pagetables.c
+++ b/arch/x86/mm/debug_pagetables.c
@@ -5,7 +5,7 @@
 
 static int ptdump_show(struct seq_file *m, void *v)
 {
-	ptdump_walk_pgd_level(m, NULL);
+	ptdump_walk_pgd_level_debugfs(m, NULL);
 	return 0;
 }
 
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -447,7 +447,7 @@ static inline bool is_hypervisor_range(i
 }
 
 static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
-				       bool checkwx)
+				       bool checkwx, bool dmesg)
 {
 #ifdef CONFIG_X86_64
 	pgd_t *start = (pgd_t *) &init_top_pgt;
@@ -460,7 +460,7 @@ static void ptdump_walk_pgd_level_core(s
 
 	if (pgd) {
 		start = pgd;
-		st.to_dmesg = true;
+		st.to_dmesg = dmesg;
 	}
 
 	st.check_wx = checkwx;
@@ -498,13 +498,30 @@ static void ptdump_walk_pgd_level_core(s
 
 void ptdump_walk_pgd_level(struct seq_file *m, pgd_t *pgd)
 {
-	ptdump_walk_pgd_level_core(m, pgd, false);
+	ptdump_walk_pgd_level_core(m, pgd, false, true);
+}
+
+void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd)
+{
+	ptdump_walk_pgd_level_core(m, pgd, false, false);
+}
+EXPORT_SYMBOL_GPL(ptdump_walk_pgd_level_debugfs);
+
+void ptdump_walk_shadow_pgd_level_checkwx(void)
+{
+#ifdef CONFIG_KAISER
+	pgd_t *pgd = (pgd_t *) &init_top_pgt;
+
+	pr_info("x86/mm: Checking shadow page tables\n");
+	pgd += PTRS_PER_PGD;
+	ptdump_walk_pgd_level_core(NULL, pgd, true, false);
+#endif
 }
-EXPORT_SYMBOL_GPL(ptdump_walk_pgd_level);
 
 void ptdump_walk_pgd_level_checkwx(void)
 {
-	ptdump_walk_pgd_level_core(NULL, NULL, true);
+	ptdump_walk_pgd_level_core(NULL, NULL, true, false);
+	ptdump_walk_shadow_pgd_level_checkwx();
 }
 
 static int __init pt_dump_init(void)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
