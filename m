Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CF0CB6B026D
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 11:52:35 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id n13so4530806wmc.3
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 08:52:35 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id l67si5397214wmg.46.2017.12.04.08.52.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 04 Dec 2017 08:52:34 -0800 (PST)
Message-Id: <20171204150609.673971250@linutronix.de>
Date: Mon, 04 Dec 2017 15:08:05 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 59/60] x86/mm/dump_pagetables: Check user space page table for
 WX pages
References: <20171204140706.296109558@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=x86-mm-dump_pagetables--Check_shadow_page_table_for_WX_pages.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, Borislav Petkov <bp@alien8.de>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at

From: Thomas Gleixner <tglx@linutronix.de>

ptdump_walk_pgd_level_checkwx() checks the kernel page table for WX pages,
but does not check the KERNEL_PAGE_TABLE_ISOLATION user space page table.

Restructure the code so that dmesg output is selected by an explicit
argument and not implicit via checking the pgd argument for !NULL.

Add the check for the user space page table.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: keescook@google.com
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: moritz.lipp@iaik.tugraz.at
Cc: linux-mm@kvack.org
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: hughd@google.com
Cc: daniel.gruss@iaik.tugraz.at
Cc: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: michael.schwarz@iaik.tugraz.at
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: richard.fellner@student.tugraz.at

---
 arch/x86/include/asm/pgtable.h |    1 +
 arch/x86/mm/debug_pagetables.c |    2 +-
 arch/x86/mm/dump_pagetables.c  |   30 +++++++++++++++++++++++++-----
 3 files changed, 27 insertions(+), 6 deletions(-)

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
@@ -498,13 +498,33 @@ static void ptdump_walk_pgd_level_core(s
 
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
+static void ptdump_walk_user_pgd_level_checkwx(void)
+{
+#ifdef CONFIG_KERNEL_PAGE_TABLE_ISOLATION
+	pgd_t *pgd = (pgd_t *) &init_top_pgt;
+
+	if (!static_cpu_has_bug(X86_BUG_CPU_SECURE_MODE_KPTI))
+		return;
+
+	pr_info("x86/mm: Checking user space page tables\n");
+	pgd = kernel_to_user_pgdp(pgd);
+	ptdump_walk_pgd_level_core(NULL, pgd, true, false);
+#endif
 }
-EXPORT_SYMBOL_GPL(ptdump_walk_pgd_level);
 
 void ptdump_walk_pgd_level_checkwx(void)
 {
-	ptdump_walk_pgd_level_core(NULL, NULL, true);
+	ptdump_walk_pgd_level_core(NULL, NULL, true, false);
+	ptdump_walk_user_pgd_level_checkwx();
 }
 
 static int __init pt_dump_init(void)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
