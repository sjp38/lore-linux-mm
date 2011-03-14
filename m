Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 620E18D003E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 09:41:55 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp07.in.ibm.com (8.14.4/8.13.1) with ESMTP id p2EDfnfO016834
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:11:49 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2EDfnas3961080
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:11:49 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2EDfmIY010553
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 00:41:49 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Mon, 14 Mar 2011 19:06:10 +0530
Message-Id: <20110314133610.27435.93666.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v2 2.6.38-rc8-tip 11/20] 11: uprobes: slot allocation for uprobes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>


Every task is allocated a fixed slot. When a probe is hit, the original
instruction corresponding to the probe hit is copied to per-task fixed
slot. Currently we allocate one page of slots for each mm. Bitmaps are
used to know which slots are free. Each slot is made of 128 bytes so
that its cache aligned.

TODO: On massively threaded processes (or if a huge number of processes
share the same mm), there is a possiblilty of running out of slots.
One alternative could be to extend the slots as when slots are required.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Signed-off-by: Jim Keniston <jkenisto@us.ibm.com>
---
 include/linux/mm_types.h |    4 +
 include/linux/uprobes.h  |   21 ++++
 kernel/fork.c            |    4 +
 kernel/uprobes.c         |  241 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 270 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 96e4a77..6dfa507 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -12,6 +12,9 @@
 #include <linux/completion.h>
 #include <linux/cpumask.h>
 #include <linux/page-debug-flags.h>
+#ifdef CONFIG_UPROBES
+#include <linux/uprobes.h>
+#endif
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -319,6 +322,7 @@ struct mm_struct {
 	unsigned long uprobes_vaddr;
 	struct list_head uprobes_list;
 	atomic_t uprobes_count;
+	struct uprobes_xol_area *uprobes_xol_area;
 #endif
 };
 
diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index d5be840..c42975b 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -101,6 +101,25 @@ struct uprobe_task {
 };
 
 /*
+ * Every thread gets its own slot.  Once it's assigned a slot, it
+ * keeps that slot until the thread exits. Only definite number
+ * of slots are allocated.
+ */
+
+struct uprobes_xol_area {
+	spinlock_t slot_lock;	/* protects bitmap and slot (de)allocation*/
+	unsigned long *bitmap;	/* 0 = free slot */
+	struct page *page;
+
+	/*
+	 * We keep the vma's vm_start rather than a pointer to the vma
+	 * itself.  The probed process or a naughty kernel module could make
+	 * the vma go away, and we must handle that reasonably gracefully.
+	 */
+	unsigned long vaddr;		/* Page(s) of instruction slots */
+};
+
+/*
  * Most architectures can use the default versions of @read_opcode(),
  * @set_bkpt(), @set_orig_insn(), and @is_bkpt_insn();
  *
@@ -128,6 +147,7 @@ extern void uprobe_free_utask(struct task_struct *tsk);
 struct vm_area_struct;
 extern void uprobe_mmap(struct vm_area_struct *vma);
 extern void uprobe_dup_mmap(struct mm_struct *old_mm, struct mm_struct *mm);
+extern void uprobes_free_xol_area(struct mm_struct *mm);
 #else /* CONFIG_UPROBES is not defined */
 static inline int register_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer)
@@ -144,5 +164,6 @@ static inline void uprobe_dup_mmap(struct mm_struct *old_mm,
 }
 static inline void uprobe_free_utask(struct task_struct *tsk) {}
 static inline void uprobe_mmap(struct vm_area_struct *vma) { }
+static inline void uprobes_free_xol_area(struct mm_struct *mm) {}
 #endif /* CONFIG_UPROBES */
 #endif	/* _LINUX_UPROBES_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index de3d10a..0afa0cd 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -551,6 +551,7 @@ void mmput(struct mm_struct *mm)
 	might_sleep();
 
 	if (atomic_dec_and_test(&mm->mm_users)) {
+		uprobes_free_xol_area(mm);
 		exit_aio(mm);
 		ksm_exit(mm);
 		khugepaged_exit(mm); /* must run before exit_mmap */
@@ -677,6 +678,9 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
 	memcpy(mm, oldmm, sizeof(*mm));
 
 	/* Initializing for Swap token stuff */
+#ifdef CONFIG_UPROBES
+	mm->uprobes_xol_area = NULL;
+#endif
 	mm->token_priority = 0;
 	mm->last_interval = 0;
 
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index f3540ff..9d3d402 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -31,12 +31,28 @@
 #include <linux/slab.h>
 #include <linux/uprobes.h>
 #include <linux/rmap.h> /* needed for anon_vma_prepare */
+#include <linux/mman.h>	/* needed for PROT_EXEC, MAP_PRIVATE */
+#include <linux/file.h> /* needed for fput() */
 
+#define UINSNS_PER_PAGE	(PAGE_SIZE/UPROBES_XOL_SLOT_BYTES)
+#define MAX_UPROBES_XOL_SLOTS UINSNS_PER_PAGE
+
+/*
+ * valid_vma: Verify if the specified vma is an executable vma,
+ * but not an XOL vma.
+ *	- Return 1 if the specified virtual address is in an
+ *	  executable vma, but not in an XOL vma.
+ */
 static int valid_vma(struct vm_area_struct *vma)
 {
+	struct uprobes_xol_area *area = current->mm->uprobes_xol_area;
+
 	if (!vma->vm_file)
 		return 0;
 
+	if (area && (area->vaddr == vma->vm_start))
+			return 0;
+
 	if ((vma->vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)) ==
 						(VM_READ|VM_EXEC))
 		return 1;
@@ -807,6 +823,227 @@ mmap_out:
 	down_write(&mm->mmap_sem);
 }
 
+/* Slot allocation for XOL */
+
+static int xol_add_vma(struct uprobes_xol_area *area)
+{
+	struct vm_area_struct *vma;
+	struct mm_struct *mm;
+	struct file *file;
+	unsigned long addr;
+	int ret = -ENOMEM;
+
+	mm = get_task_mm(current);
+	if (!mm)
+		return -ESRCH;
+
+	down_write(&mm->mmap_sem);
+	if (mm->uprobes_xol_area) {
+		ret = -EALREADY;
+		goto fail;
+	}
+
+	/*
+	 * Find the end of the top mapping and skip a page.
+	 * If there is no space for PAGE_SIZE above
+	 * that, mmap will ignore our address hint.
+	 *
+	 * We allocate a "fake" unlinked shmem file because
+	 * anonymous memory might not be granted execute
+	 * permission when the selinux security hooks have
+	 * their way.
+	 */
+	vma = rb_entry(rb_last(&mm->mm_rb), struct vm_area_struct, vm_rb);
+	addr = vma->vm_end + PAGE_SIZE;
+	file = shmem_file_setup("uprobes/xol", PAGE_SIZE, VM_NORESERVE);
+	if (!file) {
+		printk(KERN_ERR "uprobes_xol failed to setup shmem_file "
+			"while allocating vma for pid/tgid %d/%d for "
+			"single-stepping out of line.\n",
+			current->pid, current->tgid);
+		goto fail;
+	}
+	addr = do_mmap_pgoff(file, addr, PAGE_SIZE, PROT_EXEC, MAP_PRIVATE, 0);
+	fput(file);
+
+	if (addr & ~PAGE_MASK) {
+		printk(KERN_ERR "uprobes_xol failed to allocate a vma for "
+				"pid/tgid %d/%d for single-stepping out of "
+				"line.\n", current->pid, current->tgid);
+		goto fail;
+	}
+	vma = find_vma(mm, addr);
+
+	/* Don't expand vma on mremap(). */
+	vma->vm_flags |= VM_DONTEXPAND | VM_DONTCOPY;
+	area->vaddr = vma->vm_start;
+	if (get_user_pages(current, mm, area->vaddr, 1, 1, 1, &area->page,
+				&vma) > 0)
+		ret = 0;
+
+fail:
+	up_write(&mm->mmap_sem);
+	mmput(mm);
+	return ret;
+}
+
+/*
+ * xol_alloc_area - Allocate process's uprobes_xol_area.
+ * This area will be used for storing instructions for execution out of
+ * line.
+ *
+ * Returns the allocated area or NULL.
+ */
+static struct uprobes_xol_area *xol_alloc_area(void)
+{
+	struct uprobes_xol_area *area = NULL;
+
+	area = kzalloc(sizeof(*area), GFP_USER);
+	if (unlikely(!area))
+		return NULL;
+
+	area->bitmap = kzalloc(BITS_TO_LONGS(UINSNS_PER_PAGE) * sizeof(long),
+								GFP_USER);
+
+	if (!area->bitmap)
+		goto fail;
+
+	spin_lock_init(&area->slot_lock);
+	if (!xol_add_vma(area) && !current->mm->uprobes_xol_area) {
+		task_lock(current);
+		if (!current->mm->uprobes_xol_area) {
+			current->mm->uprobes_xol_area = area;
+			task_unlock(current);
+			return area;
+		}
+		task_unlock(current);
+	}
+
+fail:
+	if (area) {
+		if (area->bitmap)
+			kfree(area->bitmap);
+		kfree(area);
+	}
+	return current->mm->uprobes_xol_area;
+}
+
+/*
+ * uprobes_free_xol_area - Free the area allocated for slots.
+ */
+void uprobes_free_xol_area(struct mm_struct *mm)
+{
+	struct uprobes_xol_area *area = mm->uprobes_xol_area;
+
+	if (!area)
+		return;
+
+	put_page(area->page);
+	kfree(area->bitmap);
+	kfree(area);
+}
+
+/*
+ * Find a slot
+ *  - searching in existing vmas for a free slot.
+ *  - If no free slot in existing vmas, return 0;
+ *
+ * Called when holding uprobes_xol_area->slot_lock
+ */
+static unsigned long xol_take_insn_slot(struct uprobes_xol_area *area)
+{
+	unsigned long slot_addr;
+	int slot_nr;
+
+	slot_nr = find_first_zero_bit(area->bitmap, UINSNS_PER_PAGE);
+	if (slot_nr < UINSNS_PER_PAGE) {
+		__set_bit(slot_nr, area->bitmap);
+		slot_addr = area->vaddr +
+				(slot_nr * UPROBES_XOL_SLOT_BYTES);
+		return slot_addr;
+	}
+
+	return 0;
+}
+
+/*
+ * xol_get_insn_slot - If was not allocated a slot, then
+ * allocate a slot.
+ * Returns the allocated slot address or 0.
+ */
+static unsigned long xol_get_insn_slot(struct uprobe *uprobe,
+					unsigned long slot_addr)
+{
+	struct uprobes_xol_area *area = current->mm->uprobes_xol_area;
+	unsigned long flags, xol_vaddr = current->utask->xol_vaddr;
+	void *vaddr;
+
+	if (!current->utask->xol_vaddr) {
+		if (!area)
+			area = xol_alloc_area();
+
+		if (!area)
+			return 0;
+
+		spin_lock_irqsave(&area->slot_lock, flags);
+		xol_vaddr = xol_take_insn_slot(area);
+		spin_unlock_irqrestore(&area->slot_lock, flags);
+		current->utask->xol_vaddr = xol_vaddr;
+	}
+
+	/*
+	 * Initialize the slot if xol_vaddr points to valid
+	 * instruction slot.
+	 */
+	if (unlikely(!xol_vaddr))
+		return 0;
+
+	current->utask->vaddr = slot_addr;
+	vaddr = kmap_atomic(area->page, KM_USER0);
+	xol_vaddr &= ~PAGE_MASK;
+	memcpy(vaddr + xol_vaddr, uprobe->insn, MAX_UINSN_BYTES);
+	kunmap_atomic(vaddr, KM_USER0);
+	return current->utask->xol_vaddr;
+}
+
+/*
+ * xol_free_insn_slot - If slot was earlier allocated by
+ * @xol_get_insn_slot(), make the slot available for
+ * subsequent requests.
+ */
+static void xol_free_insn_slot(struct task_struct *tsk, unsigned long slot_addr)
+{
+	struct uprobes_xol_area *area;
+	unsigned long vma_end;
+
+	if (!tsk->mm || !tsk->mm->uprobes_xol_area)
+		return;
+
+	area = tsk->mm->uprobes_xol_area;
+
+	if (unlikely(!slot_addr || IS_ERR_VALUE(slot_addr)))
+		return;
+
+	vma_end = area->vaddr + PAGE_SIZE;
+	if (area->vaddr <= slot_addr && slot_addr < vma_end) {
+		int slot_nr;
+		unsigned long offset = slot_addr - area->vaddr;
+		unsigned long flags;
+
+		BUG_ON(offset % UPROBES_XOL_SLOT_BYTES);
+
+		slot_nr = offset / UPROBES_XOL_SLOT_BYTES;
+		BUG_ON(slot_nr >= UINSNS_PER_PAGE);
+
+		spin_lock_irqsave(&area->slot_lock, flags);
+		__clear_bit(slot_nr, area->bitmap);
+		spin_unlock_irqrestore(&area->slot_lock, flags);
+		return;
+	}
+	printk(KERN_ERR "%s: no XOL vma for slot address %#lx\n",
+						__func__, slot_addr);
+}
+
 /*
  * Called with no locks held.
  * Called in context of a exiting or a exec-ing thread.
@@ -814,14 +1051,18 @@ mmap_out:
 void uprobe_free_utask(struct task_struct *tsk)
 {
 	struct uprobe_task *utask = tsk->utask;
+	unsigned long xol_vaddr;
 
 	if (!utask)
 		return;
 
+	xol_vaddr = utask->xol_vaddr;
 	if (utask->active_uprobe)
 		put_uprobe(utask->active_uprobe);
+
 	kfree(utask);
 	tsk->utask = NULL;
+	xol_free_insn_slot(tsk, xol_vaddr);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
