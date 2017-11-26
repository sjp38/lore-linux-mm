Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8B3F46B0033
	for <linux-mm@kvack.org>; Sun, 26 Nov 2017 13:10:14 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id z14so12721753wrb.12
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 10:10:14 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id g20si14918518wrb.374.2017.11.26.10.10.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 26 Nov 2017 10:10:13 -0800 (PST)
Message-Id: <20171126180232.090169301@linutronix.de>
Date: Sun, 26 Nov 2017 18:55:41 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 3/4] x86/mm/debug_pagetables: Allow dumping current pagetables
References: <20171126175538.841453476@linutronix.de>
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
 arch/x86/mm/debug_pagetables.c |   79 ++++++++++++++++++++++++++++++++++++++---
 1 file changed, 74 insertions(+), 5 deletions(-)

--- a/arch/x86/mm/debug_pagetables.c
+++ b/arch/x86/mm/debug_pagetables.c
@@ -22,21 +22,90 @@ static const struct file_operations ptdu
 	.release	= single_release,
 };
 
-static struct dentry *pe;
+static int ptdump_show_curknl(struct seq_file *m, void *v)
+{
+	if (current->mm->pgd) {
+		down_read(&current->mm->mmap_sem);
+		ptdump_walk_pgd_level_debugfs(m, current->mm->pgd);
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
+		ptdump_walk_pgd_level_debugfs(m, current->mm->pgd + PTRS_PER_PGD);
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


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
