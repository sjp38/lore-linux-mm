Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 973B06B0282
	for <linux-mm@kvack.org>; Mon,  1 Jan 2018 09:42:50 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id l99so22679190wrc.18
        for <linux-mm@kvack.org>; Mon, 01 Jan 2018 06:42:50 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a2si20671102wmg.27.2018.01.01.06.42.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jan 2018 06:42:49 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 034/146] x86/mm/dump_pagetables: Allow dumping current pagetables
Date: Mon,  1 Jan 2018 15:37:05 +0100
Message-Id: <20180101140128.806395270@linuxfoundation.org>
In-Reply-To: <20180101140123.743014891@linuxfoundation.org>
References: <20180101140123.743014891@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Thomas Gleixner <tglx@linutronix.de>

commit a4b51ef6552c704764684cef7e753162dc87c5fa upstream.

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
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

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
@@ -530,8 +530,12 @@ void ptdump_walk_pgd_level(struct seq_fi
 	ptdump_walk_pgd_level_core(m, pgd, false, true);
 }
 
-void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd)
+void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool user)
 {
+#ifdef CONFIG_PAGE_TABLE_ISOLATION
+	if (user && static_cpu_has(X86_FEATURE_PTI))
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
