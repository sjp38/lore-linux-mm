Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D8DB96B0069
	for <linux-mm@kvack.org>; Sun, 26 Nov 2017 18:26:12 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id o14so17456974wrf.6
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 15:26:12 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 59si20033746wrr.53.2017.11.26.15.26.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 26 Nov 2017 15:26:11 -0800 (PST)
Message-Id: <20171126232414.563046145@linutronix.de>
Date: Mon, 27 Nov 2017 00:14:07 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch V2 4/5] x86/mm/debug_pagetables: Allow dumping current
 pagetables
References: <20171126231403.657575796@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=x86-mm-dump_pagetables--Add-support-for-KAISER-tables.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

Add two debugfs files which allow to dump the pagetable of the current task.

current_page_tables_knl dumps the regular page table. This is the page
table which is normally shared between kernel and user space. If KAISER is
enabled this is the kernel space mapping.

If KAISER is enabled the second file, current_page_tables_usr, dumps the
user space page table.

These files allow to verify the resulting page tables for KAISER, but even
in the non KAISER case its useful to be able to inspect user space page
tables of current for debugging purposes.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/include/asm/pgtable.h |    2 -
 arch/x86/mm/debug_pagetables.c |   81 +++++++++++++++++++++++++++++++++++++----
 arch/x86/mm/dump_pagetables.c  |    4 +-
 3 files changed, 79 insertions(+), 8 deletions(-)

--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -28,7 +28,7 @@ extern pgd_t early_top_pgt[PTRS_PER_PGD]
 int __init __early_make_pgtable(unsigned long address, pmdval_t pmd);
 
 void ptdump_walk_pgd_level(struct seq_file *m, pgd_t *pgd);
-void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd);
+void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool shadow);
 void ptdump_walk_pgd_level_checkwx(void);
 
 #ifdef CONFIG_DEBUG_WX
--- a/arch/x86/mm/debug_pagetables.c
+++ b/arch/x86/mm/debug_pagetables.c
@@ -5,7 +5,7 @@
 
 static int ptdump_show(struct seq_file *m, void *v)
 {
-	ptdump_walk_pgd_level_debugfs(m, NULL);
+	ptdump_walk_pgd_level_debugfs(m, NULL, false);
 	return 0;
 }
 
@@ -22,21 +22,90 @@ static const struct file_operations ptdu
 	.release	= single_release,
 };
 
-static struct dentry *pe;
+static int ptdump_show_curknl(struct seq_file *m, void *v)
+{
+	if (current->mm->pgd) {
+		down_read(&current->mm->mmap_sem);
+		ptdump_walk_pgd_level_debugfs(m, current->mm->pgd, false);
+		up_read(&current->mm->mmap_sem);
+	}
+	return 0;
+}
+
+static int ptdump_open_curknl(struct inode *inode, struct file *filp)
+{
+	return single_open(filp, ptdump_show_curknl, NULL);
+}
+
+static const struct file_operations ptdump_curknl_fops = {
+	.owner		= THIS_MODULE,
+	.open		= ptdump_open_curknl,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+#ifdef CONFIG_KAISER
+static int ptdump_show_curusr(struct seq_file *m, void *v)
+{
+	if (current->mm->pgd) {
+		down_read(&current->mm->mmap_sem);
+		ptdump_walk_pgd_level_debugfs(m, current->mm->pgd, true);
+		up_read(&current->mm->mmap_sem);
+	}
+	return 0;
+}
+
+static int ptdump_open_curusr(struct inode *inode, struct file *filp)
+{
+	return single_open(filp, ptdump_show_curusr, NULL);
+}
+
+static const struct file_operations ptdump_curusr_fops = {
+	.owner		= THIS_MODULE,
+	.open		= ptdump_open_curusr,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+#endif
+
+static struct dentry *pe_knl, *pe_curknl, *pe_curusr;
+
+static void pt_dump_debug_remove_files(void)
+{
+	debugfs_remove_recursive(pe_knl);
+	debugfs_remove_recursive(pe_curknl);
+	debugfs_remove_recursive(pe_curusr);
+}
 
 static int __init pt_dump_debug_init(void)
 {
-	pe = debugfs_create_file("kernel_page_tables", S_IRUSR, NULL, NULL,
-				 &ptdump_fops);
-	if (!pe)
+	pe_knl = debugfs_create_file("kernel_page_tables", S_IRUSR, NULL, NULL,
+				     &ptdump_fops);
+	if (!pe_knl)
 		return -ENOMEM;
 
+	pe_curknl = debugfs_create_file("current_page_tables_knl", S_IRUSR,
+					NULL, NULL, &ptdump_curknl_fops);
+	if (!pe_curknl)
+		goto err;
+
+#ifdef CONFIG_KAISER
+	pe_curusr = debugfs_create_file("current_page_tables_usr", S_IRUSR,
+					NULL, NULL, &ptdump_curusr_fops);
+	if (!pe_curusr)
+		goto err;
+#endif
 	return 0;
+err:
+	pt_dump_debug_remove_files();
+	return -ENOMEM;
 }
 
 static void __exit pt_dump_debug_exit(void)
 {
-	debugfs_remove_recursive(pe);
+	pt_dump_debug_remove_files();
 }
 
 module_init(pt_dump_debug_init);
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -501,8 +501,10 @@ void ptdump_walk_pgd_level(struct seq_fi
 	ptdump_walk_pgd_level_core(m, pgd, false, true);
 }
 
-void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd)
+void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool shadow)
 {
+	if (shadow)
+		pgd += PTRS_PER_PGD;
 	ptdump_walk_pgd_level_core(m, pgd, false, false);
 }
 EXPORT_SYMBOL_GPL(ptdump_walk_pgd_level_debugfs);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
