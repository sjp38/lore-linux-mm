Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E756C6B0074
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 14:04:44 -0500 (EST)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 11 Nov 2011 00:34:39 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAAJ4BWW3186918
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 00:34:11 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAAJ4Ahm017335
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 06:04:11 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 11 Nov 2011 00:09:16 +0530
Message-Id: <20111110183916.11361.57725.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20111110183725.11361.57827.sendpatchset@srdronam.in.ibm.com>
References: <20111110183725.11361.57827.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v6 3.2-rc1 9/28]   Uprobes: Background page replacement.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>


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

Changelog (since v5)
- pass NULL to get_user_pages for the task parameter.
- call SetPageUptodate on the new page allocated in write_opcode.
- fix leaking a reference to the new page under certain conditions.

 include/linux/uprobes.h |    2 
 kernel/uprobes.c        |  267 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 261 insertions(+), 8 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 44f28dc..bc1f190 100644
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
@@ -74,6 +75,7 @@ extern int __weak set_bkpt(struct mm_struct *mm, struct uprobe *uprobe,
 							unsigned long vaddr);
 extern int __weak set_orig_insn(struct mm_struct *mm, struct uprobe *uprobe,
 					unsigned long vaddr, bool verify);
+extern bool __weak is_bkpt_insn(u8 *insn);
 extern int register_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer);
 extern void unregister_uprobe(struct inode *inode, loff_t offset,
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index f4574fd..393eaf6 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -26,6 +26,9 @@
 #include <linux/pagemap.h>	/* read_mapping_page */
 #include <linux/slab.h>
 #include <linux/sched.h>
+#include <linux/rmap.h>		/* anon_vma_prepare */
+#include <linux/mmu_notifier.h>	/* set_pte_at_notify */
+#include <linux/swap.h>		/* try_to_free_swap */
 #include <linux/uprobes.h>
 
 static struct rb_root uprobes_tree = RB_ROOT;
@@ -83,18 +86,251 @@ static bool valid_vma(struct vm_area_struct *vma, bool is_reg)
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
+ * @mm: the probed process address space.
+ * @uprobe: the breakpointing information.
+ * @vaddr: the virtual address to store the opcode.
+ * @opcode: opcode to be written at @vaddr.
+ *
+ * Called with mm->mmap_sem held (for read and with a reference to
+ * mm).
+ *
+ * For mm @mm, write the opcode at @vaddr.
+ * Return 0 (success) or a negative errno.
+ */
+static int write_opcode(struct mm_struct *mm, struct uprobe *uprobe,
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
+	ret = get_user_pages(NULL, mm, vaddr, 1, 0, 0, &old_page, &vma);
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
+	if (!valid_vma(vma, opcode == UPROBES_BKPT_INSN))
+		goto put_out;
+
+	mapping = uprobe->inode->i_mapping;
+	if (mapping != vma->vm_file->f_mapping)
+		goto put_out;
+
+	addr = vma->vm_start + uprobe->offset;
+	addr -= vma->vm_pgoff << PAGE_SHIFT;
+	if (vaddr != (unsigned long)addr)
+		goto put_out;
+
+	ret = -ENOMEM;
+	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, vaddr);
+	if (!new_page)
+		goto put_out;
+
+	__SetPageUptodate(new_page);
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
+	if (ret)
+		goto unlock_out;
+
+	lock_page(new_page);
+	ret = __replace_page(vma, old_page, new_page);
+	unlock_page(new_page);
+
+unlock_out:
+	unlock_page(old_page);
+	page_cache_release(new_page);
+
+put_out:
+	put_page(old_page);	/* we did a get_page in the beginning */
+	return ret;
+}
+
+/**
+ * read_opcode - read the opcode at a given virtual address.
+ * @mm: the probed process address space.
+ * @vaddr: the virtual address to read the opcode.
+ * @opcode: location to store the read opcode.
+ *
+ * Called with mm->mmap_sem held (for read and with a reference to
+ * mm.
+ *
+ * For mm @mm, read the opcode at @vaddr and store it in @opcode.
+ * Return 0 (success) or a negative errno.
+ */
+static int read_opcode(struct mm_struct *mm, unsigned long vaddr,
+						uprobe_opcode_t *opcode)
+{
+	struct page *page;
+	void *vaddr_new;
+	int ret;
+
+	ret = get_user_pages(NULL, mm, vaddr, 1, 0, 0, &page, NULL);
+	if (ret <= 0)
+		return ret;
+
+	lock_page(page);
+	vaddr_new = kmap_atomic(page);
+	vaddr &= ~PAGE_MASK;
+	memcpy(opcode, vaddr_new + vaddr, uprobe_opcode_sz);
+	kunmap_atomic(vaddr_new);
+	unlock_page(page);
+	put_page(page);		/* we did a get_user_pages in the beginning */
+	return 0;
+}
+
+/**
+ * set_bkpt - store breakpoint at a given address.
+ * @mm: the probed process address space.
+ * @uprobe: the probepoint information.
+ * @vaddr: the virtual address to insert the opcode.
+ *
+ * For mm @mm, store the breakpoint instruction at @vaddr.
+ * Return 0 (success) or a negative errno.
+ */
 int __weak set_bkpt(struct mm_struct *mm, struct uprobe *uprobe,
 						unsigned long vaddr)
 {
-	/* placeholder: yet to be implemented */
-	return 0;
+	return write_opcode(mm, uprobe, vaddr, UPROBES_BKPT_INSN);
 }
 
+/**
+ * set_orig_insn - Restore the original instruction.
+ * @mm: the probed process address space.
+ * @uprobe: the probepoint information.
+ * @vaddr: the virtual address to insert the opcode.
+ * @verify: if true, verify existance of breakpoint instruction.
+ *
+ * For mm @mm, restore the original opcode (opcode) at @vaddr.
+ * Return 0 (success) or a negative errno.
+ */
 int __weak set_orig_insn(struct mm_struct *mm, struct uprobe *uprobe,
 					unsigned long vaddr, bool verify)
 {
-	/* placeholder: yet to be implemented */
-	return 0;
+	if (verify) {
+		uprobe_opcode_t opcode;
+		int result = read_opcode(mm, vaddr, &opcode);
+
+		if (result)
+			return result;
+
+		if (opcode != UPROBES_BKPT_INSN)
+			return -EINVAL;
+	}
+	return write_opcode(mm, uprobe, vaddr,
+				*(uprobe_opcode_t *)uprobe->insn);
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
 
 static int match_uprobe(struct uprobe *l, struct uprobe *r)
@@ -329,7 +565,7 @@ static int install_breakpoint(struct mm_struct *mm, struct uprobe *uprobe,
 				struct vm_area_struct *vma, loff_t vaddr)
 {
 	unsigned long addr;
-	int ret = -EINVAL;
+	int ret;
 
 	/*
 	 * Probe is to be deleted;
@@ -345,7 +581,13 @@ static int install_breakpoint(struct mm_struct *mm, struct uprobe *uprobe,
 		if (ret)
 			return ret;
 
-		/* TODO : Analysis and verification of instruction */
+		if (is_bkpt_insn(uprobe->insn))
+			return -EEXIST;
+
+		ret = analyze_insn(mm, uprobe);
+		if (ret)
+			return ret;
+
 		uprobe->copy = 1;
 	}
 	ret = set_bkpt(mm, uprobe, addr);
@@ -761,12 +1003,21 @@ void munmap_uprobe(struct vm_area_struct *vma)
 	build_probe_list(inode, &tmp_list);
 	list_for_each_entry_safe(uprobe, u, &tmp_list, pending_list) {
 		loff_t vaddr;
+		uprobe_opcode_t opcode;
 
 		list_del(&uprobe->pending_list);
 		vaddr = vma->vm_start + uprobe->offset;
 		vaddr -= vma->vm_pgoff << PAGE_SHIFT;
-		if (vaddr >= vma->vm_start && vaddr < vma->vm_end)
-			atomic_dec(&vma->vm_mm->mm_uprobes_count);
+		if (vaddr >= vma->vm_start && vaddr < vma->vm_end) {
+
+			/*
+			 * An unregister could have removed the probe before
+			 * unmap. So check before we decrement the count.
+			 */
+			if (!read_opcode(vma->vm_mm, vaddr, &opcode) &&
+						(opcode == UPROBES_BKPT_INSN))
+				atomic_dec(&vma->vm_mm->mm_uprobes_count);
+		}
 		put_uprobe(uprobe);
 	}
 	mutex_unlock(uprobes_mmap_hash(inode));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
