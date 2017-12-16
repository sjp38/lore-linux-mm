Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id EA0E2440404
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 16:39:29 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 96so6982350wrk.7
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 13:39:29 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id u205si6359283wmu.15.2017.12.16.13.39.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 16 Dec 2017 13:39:29 -0800 (PST)
Message-Id: <20171216213140.472703911@linutronix.de>
Date: Sat, 16 Dec 2017 22:24:43 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch V149 49/50] x86/mm/dump_pagetables: Allow dumping current
 pagetables
References: <20171216212354.120930222@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=0059-x86-mm-dump_pagetables-Allow-dumping-current-pagetab.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org

From: Thomas Gleixner <tglx@linutronix.de>

Add two debugfs files which allow to dump the pagetable of the current
task.

current_kernel dumps the regular page table. This is the page table which
is normally shared between kernel and user space. If kernel page table
isolation is enabled this is the kernel space mapping.

If kernel page table isolation is enabled the second file, current_user,
dumps the user space page table.

These files allow to verify the resulting page tables for page table
isolation, but even in the normal case its useful to be able to inspect
user space page tables of current for debugging purposes.

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
 arch/x86/include/asm/pgtable.h |    2 -
 arch/x86/mm/debug_pagetables.c |   71 ++++++++++++++++++++++++++++++++++++++---
 arch/x86/mm/dump_pagetables.c  |    6 ++-
 3 files changed, 73 insertions(+), 6 deletions(-)

--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -28,7 +28,7 @@ extern pgd_t early_top_pgt[PTRS_PER_PGD]
 int __init __early_make_pgtable(unsigned long address, pmdval_t pmd);
 
 void ptdump_walk_pgd_level(struct seq_file *m, pgd_t *pgd);
-void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd);
+void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool user);
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
 
@@ -22,7 +22,57 @@ static const struct file_operations ptdu
 	.release	= single_release,
 };
 
-static struct dentry *dir, *pe;
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
+#ifdef CONFIG_PAGE_TABLE_ISOLATION
+static struct dentry *pe_curusr;
+
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
+static struct dentry *dir, *pe_knl, *pe_curknl;
 
 static int __init pt_dump_debug_init(void)
 {
@@ -30,9 +80,22 @@ static int __init pt_dump_debug_init(voi
 	if (!dir)
 		return -ENOMEM;
 
-	pe = debugfs_create_file("kernel", 0400, dir, NULL, &ptdump_fops);
-	if (!pe)
+	pe_knl = debugfs_create_file("kernel", 0400, dir, NULL,
+				     &ptdump_fops);
+	if (!pe_knl)
+		goto err;
+
+	pe_curknl = debugfs_create_file("current_kernel", 0400,
+					dir, NULL, &ptdump_curknl_fops);
+	if (!pe_curknl)
+		goto err;
+
+#ifdef CONFIG_PAGE_TABLE_ISOLATION
+	pe_curusr = debugfs_create_file("current_user", 0400,
+					dir, NULL, &ptdump_curusr_fops);
+	if (!pe_curusr)
 		goto err;
+#endif
 	return 0;
 err:
 	debugfs_remove_recursive(dir);
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -513,8 +513,12 @@ void ptdump_walk_pgd_level(struct seq_fi
 	ptdump_walk_pgd_level_core(m, pgd, false, true);
 }
 
-void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd)
+void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool user)
 {
+#ifdef CONFIG_PAGE_TABLE_ISOLATION
+	if (user && static_cpu_has_bug(X86_BUG_CPU_SECURE_MODE_PTI))
+		pgd = kernel_to_user_pgdp(pgd);
+#endif
 	ptdump_walk_pgd_level_core(m, pgd, false, false);
 }
 EXPORT_SYMBOL_GPL(ptdump_walk_pgd_level_debugfs);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
