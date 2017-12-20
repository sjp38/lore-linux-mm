Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D44436B027B
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 16:59:33 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id o32so6885725wrf.20
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 13:59:33 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id y91si14911139wrc.371.2017.12.20.13.59.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 20 Dec 2017 13:59:32 -0800 (PST)
Message-Id: <20171220215444.887819284@linutronix.de>
Date: Wed, 20 Dec 2017 22:35:55 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch V181 52/54] x86/mm/dump_pagetables: Check user space page
 table for WX pages
References: <20171220213503.672610178@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=0058-x86-mm-dump_pagetables-Check-user-space-page-table-f.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, Vlastimil Babka <vbabka@suse.cz>, daniel.gruss@iaik.tugraz.at, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org

From: Thomas Gleixner <tglx@linutronix.de>

ptdump_walk_pgd_level_checkwx() checks the kernel page table for WX pages,
but does not check the PAGE_TABLE_ISOLATION user space page table.

Restructure the code so that dmesg output is selected by an explicit
argument and not implicit via checking the pgd argument for !NULL.

Add the check for the user space page table.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: David Laight <David.Laight@aculab.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Eduardo Valentin <eduval@amazon.com>
Cc: Greg KH <gregkh@linuxfoundation.org>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: aliguori@amazon.com
Cc: daniel.gruss@iaik.tugraz.at
Cc: hughd@google.com
Cc: keescook@google.com
Cc: linux-mm@kvack.org
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
@@ -476,7 +476,7 @@ static inline bool is_hypervisor_range(i
 }
 
 static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
-				       bool checkwx)
+				       bool checkwx, bool dmesg)
 {
 #ifdef CONFIG_X86_64
 	pgd_t *start = (pgd_t *) &init_top_pgt;
@@ -489,7 +489,7 @@ static void ptdump_walk_pgd_level_core(s
 
 	if (pgd) {
 		start = pgd;
-		st.to_dmesg = true;
+		st.to_dmesg = dmesg;
 	}
 
 	st.check_wx = checkwx;
@@ -527,13 +527,33 @@ static void ptdump_walk_pgd_level_core(s
 
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
+#ifdef CONFIG_PAGE_TABLE_ISOLATION
+	pgd_t *pgd = (pgd_t *) &init_top_pgt;
+
+	if (!static_cpu_has(X86_FEATURE_PTI))
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
