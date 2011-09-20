Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4FE3A9000C4
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 08:16:34 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp07.in.ibm.com (8.14.4/8.13.1) with ESMTP id p8KCGQKx020704
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 17:46:26 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8KCFA3V3723452
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 17:45:10 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8KCF87m024934
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 17:45:10 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 20 Sep 2011 17:31:37 +0530
Message-Id: <20110920120137.25326.72005.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v5 3.1.0-rc4-tip 9/26]   Uprobes: Background page replacement.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>


Provides Background page replacement by
 - cow the page that needs replacement.
 - modify a copy of the cowed page.
 - replace the cow page with the modified page
 - flush the page tables.

Also provides additional routines to read an opcode from a given virtual
address and for verifying if a instruction is a breakpoint instruction.

Signed-off-by: Jim Keniston <jkenisto@us.ibm.com>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/uprobes.h |    4 +
 kernel/uprobes.c        |  268 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 266 insertions(+), 6 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 2548b94..2c139f3 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -29,6 +29,7 @@ struct vm_area_struct;
 #ifdef CONFIG_ARCH_SUPPORTS_UPROBES
 #include <asm/uprobes.h>
 #else
+typedef u8 uprobe_opcode_t;
 struct uprobe_arch_info {};
 #define MAX_UINSN_BYTES 4
 #endif
@@ -74,6 +75,9 @@ extern int __weak set_bkpt(struct task_struct *tsk, struct uprobe *uprobe,
 							unsigned long vaddr);
 extern int __weak set_orig_insn(struct task_struct *tsk,
 		struct uprobe *uprobe, unsigned long vaddr, bool verify);
+extern bool __weak is_bkpt_insn(u8 *insn);
+extern int __weak read_opcode(struct task_struct *tsk, unsigned long vaddr,
+						uprobe_opcode_t *opcode);
 extern int register_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer);
 extern void unregister_uprobe(struct inode *inode, loff_t offset,
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index e0e10dd..9adc3aa 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -26,6 +26,9 @@
 #include <linux/pagemap.h>	/* grab_cache_page */
 #include <linux/slab.h>
 #include <linux/sched.h>
+#include <linux/rmap.h>		/* anon_vma_prepare */
+#include <linux/mmu_notifier.h>	/* set_pte_at_notify */
+#include <linux/swap.h>		/* try_to_free_swap */
 #include <linux/uprobes.h>
 
 static struct rb_root uprobes_tree = RB_ROOT;
@@ -60,18 +63,265 @@ static bool valid_vma(struct vm_area_struct *vma)
 	return false;
 }
 
+/**
+ * __replace_page - replace page in vma by new page.
+ * based on replace_page in mm/ksm.c
+ *
+ * @vma:      vma that holds the pte pointing to page
+ * @page:     the cowed page we are replacing by kpage
+ * @kpage:    the modified page we replace page by
+ *
+ * Returns 0 on success, -EFAULT on failure.
+ */
+static int __replace_page(struct vm_area_struct *vma, struct page *page,
+					struct page *kpage)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *ptep;
+	spinlock_t *ptl;
+	unsigned long addr;
+	int err = -EFAULT;
+
+	addr = page_address_in_vma(page, vma);
+	if (addr == -EFAULT)
+		goto out;
+
+	pgd = pgd_offset(mm, addr);
+	if (!pgd_present(*pgd))
+		goto out;
+
+	pud = pud_offset(pgd, addr);
+	if (!pud_present(*pud))
+		goto out;
+
+	pmd = pmd_offset(pud, addr);
+	if (!pmd_present(*pmd))
+		goto out;
+
+	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
+	if (!ptep)
+		goto out;
+
+	get_page(kpage);
+	page_add_new_anon_rmap(kpage, vma, addr);
+
+	flush_cache_page(vma, addr, pte_pfn(*ptep));
+	ptep_clear_flush(vma, addr, ptep);
+	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
+
+	page_remove_rmap(page);
+	if (!page_mapped(page))
+		try_to_free_swap(page);
+	put_page(page);
+	pte_unmap_unlock(ptep, ptl);
+	err = 0;
+
+out:
+	return err;
+}
+
+/*
+ * NOTE:
+ * Expect the breakpoint instruction to be the smallest size instruction for
+ * the architecture. If an arch has variable length instruction and the
+ * breakpoint instruction is not of the smallest length instruction
+ * supported by that architecture then we need to modify read_opcode /
+ * write_opcode accordingly. This would never be a problem for archs that
+ * have fixed length instructions.
+ */
+
+/*
+ * write_opcode - write the opcode at a given virtual address.
+ * @tsk: the probed task.
+ * @uprobe: the breakpointing information.
+ * @vaddr: the virtual address to store the opcode.
+ * @opcode: opcode to be written at @vaddr.
+ *
+ * Called with tsk->mm->mmap_sem held (for read and with a reference to
+ * tsk->mm).
+ *
+ * For task @tsk, write the opcode at @vaddr.
+ * Return 0 (success) or a negative errno.
+ */
+static int write_opcode(struct task_struct *tsk, struct uprobe * uprobe,
+			unsigned long vaddr, uprobe_opcode_t opcode)
+{
+	struct page *old_page, *new_page;
+	struct address_space *mapping;
+	void *vaddr_old, *vaddr_new;
+	struct vm_area_struct *vma;
+	unsigned long addr;
+	int ret;
+
+	/* Read the page with vaddr into memory */
+	ret = get_user_pages(tsk, tsk->mm, vaddr, 1, 0, 0, &old_page, &vma);
+	if (ret <= 0)
+		return ret;
+	ret = -EINVAL;
+
+	/*
+	 * We are interested in text pages only. Our pages of interest
+	 * should be mapped for read and execute only. We desist from
+	 * adding probes in write mapped pages since the breakpoints
+	 * might end up in the file copy.
+	 */
+	if (!valid_vma(vma))
+		goto put_out;
+
+	mapping = uprobe->inode->i_mapping;
+	if (mapping != vma->vm_file->f_mapping)
+		goto put_out;
+
+	addr = vma->vm_start + uprobe->offset;
+	addr -= vma->vm_pgoff << PAGE_SHIFT;
+	if (vaddr != (unsigned long) addr)
+		goto put_out;
+
+	/* Allocate a page */
+	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, vaddr);
+	if (!new_page) {
+		ret = -ENOMEM;
+		goto put_out;
+	}
+
+	/*
+	 * lock page will serialize against do_wp_page()'s
+	 * PageAnon() handling
+	 */
+	lock_page(old_page);
+	/* copy the page now that we've got it stable */
+	vaddr_old = kmap_atomic(old_page);
+	vaddr_new = kmap_atomic(new_page);
+
+	memcpy(vaddr_new, vaddr_old, PAGE_SIZE);
+	/* poke the new insn in, ASSUMES we don't cross page boundary */
+	vaddr &= ~PAGE_MASK;
+	memcpy(vaddr_new + vaddr, &opcode, uprobe_opcode_sz);
+
+	kunmap_atomic(vaddr_new);
+	kunmap_atomic(vaddr_old);
+
+	ret = anon_vma_prepare(vma);
+	if (ret) {
+		page_cache_release(new_page);
+		goto unlock_out;
+	}
+
+	lock_page(new_page);
+	ret = __replace_page(vma, old_page, new_page);
+	unlock_page(new_page);
+	if (ret != 0)
+		page_cache_release(new_page);
+unlock_out:
+	unlock_page(old_page);
+
+put_out:
+	put_page(old_page); /* we did a get_page in the beginning */
+	return ret;
+}
+
+/**
+ * read_opcode - read the opcode at a given virtual address.
+ * @tsk: the probed task.
+ * @vaddr: the virtual address to read the opcode.
+ * @opcode: location to store the read opcode.
+ *
+ * Called with tsk->mm->mmap_sem held (for read and with a reference to
+ * tsk->mm.
+ *
+ * For task @tsk, read the opcode at @vaddr and store it in @opcode.
+ * Return 0 (success) or a negative errno.
+ */
+int __weak read_opcode(struct task_struct *tsk, unsigned long vaddr,
+						uprobe_opcode_t *opcode)
+{
+	struct vm_area_struct *vma;
+	struct page *page;
+	void *vaddr_new;
+	int ret;
+
+	ret = get_user_pages(tsk, tsk->mm, vaddr, 1, 0, 0, &page, &vma);
+	if (ret <= 0)
+		return ret;
+	ret = -EINVAL;
+
+	/*
+	 * We are interested in text pages only. Our pages of interest
+	 * should be mapped for read and execute only. We desist from
+	 * adding probes in write mapped pages since the breakpoints
+	 * might end up in the file copy.
+	 */
+	if (!valid_vma(vma))
+		goto put_out;
+
+	lock_page(page);
+	vaddr_new = kmap_atomic(page);
+	vaddr &= ~PAGE_MASK;
+	memcpy(opcode, vaddr_new + vaddr, uprobe_opcode_sz);
+	kunmap_atomic(vaddr_new);
+	unlock_page(page);
+	ret =  0;
+
+put_out:
+	put_page(page); /* we did a get_user_pages in the beginning */
+	return ret;
+}
+
+/**
+ * set_bkpt - store breakpoint at a given address.
+ * @tsk: the probed task.
+ * @uprobe: the probepoint information.
+ * @vaddr: the virtual address to insert the opcode.
+ *
+ * For task @tsk, store the breakpoint instruction at @vaddr.
+ * Return 0 (success) or a negative errno.
+ */
 int __weak set_bkpt(struct task_struct *tsk, struct uprobe *uprobe,
 						unsigned long vaddr)
 {
-	/* placeholder: yet to be implemented */
-	return 0;
+	return write_opcode(tsk, uprobe, vaddr, UPROBES_BKPT_INSN);
 }
 
+/**
+ * set_orig_insn - Restore the original instruction.
+ * @tsk: the probed task.
+ * @uprobe: the probepoint information.
+ * @vaddr: the virtual address to insert the opcode.
+ * @verify: if true, verify existance of breakpoint instruction.
+ *
+ * For task @tsk, restore the original opcode (opcode) at @vaddr.
+ * Return 0 (success) or a negative errno.
+ */
 int __weak set_orig_insn(struct task_struct *tsk, struct uprobe *uprobe,
-					unsigned long vaddr, bool verify)
+				unsigned long vaddr, bool verify)
 {
-	/* placeholder: yet to be implemented */
-	return 0;
+	if (verify) {
+		uprobe_opcode_t opcode;
+		int result = read_opcode(tsk, vaddr, &opcode);
+		if (result)
+			return result;
+		if (opcode != UPROBES_BKPT_INSN)
+			return -EINVAL;
+	}
+	return write_opcode(tsk, uprobe, vaddr,
+			*(uprobe_opcode_t *) uprobe->insn);
+}
+
+/**
+ * is_bkpt_insn - check if instruction is breakpoint instruction.
+ * @insn: instruction to be checked.
+ * Default implementation of is_bkpt_insn
+ * Returns true if @insn is a breakpoint instruction.
+ */
+bool __weak is_bkpt_insn(u8 *insn)
+{
+	uprobe_opcode_t opcode;
+
+	memcpy(&opcode, insn, UPROBES_BKPT_INSN_SIZE);
+	return (opcode == UPROBES_BKPT_INSN);
 }
 
 static int match_uprobe(struct uprobe *l, struct uprobe *r, int *match_inode)
@@ -357,7 +607,13 @@ static int install_breakpoint(struct mm_struct *mm, struct uprobe *uprobe,
 		ret = copy_insn(uprobe, vma, addr);
 		if (ret)
 			goto put_return;
-		/* TODO : Analysis and verification of instruction */
+		if (is_bkpt_insn(uprobe->insn)) {
+			ret = -EEXIST;
+			goto put_return;
+		}
+		ret = analyze_insn(tsk, uprobe);
+		if (ret)
+			goto put_return;
 		uprobe->copy = 1;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
