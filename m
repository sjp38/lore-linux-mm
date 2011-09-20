Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5294A9000C9
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 08:17:17 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp03.in.ibm.com (8.14.4/8.13.1) with ESMTP id p8KCH8PN012659
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 17:47:08 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8KCH8du4264178
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 17:47:08 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8KCH6X2032659
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 17:47:07 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 20 Sep 2011 17:33:35 +0530
Message-Id: <20110920120335.25326.50673.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v5 3.1.0-rc4-tip 18/26]   uprobes: slot allocation.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>


One page of slots are allocated per mm.
On a probehit one free slot is acquired and released after
singlestep operation completes.

Signed-off-by: Jim Keniston <jkenisto@us.ibm.com>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/mm_types.h |    2 
 include/linux/uprobes.h  |   22 ++++
 kernel/fork.c            |    2 
 kernel/uprobes.c         |  246 +++++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 267 insertions(+), 5 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 9aeb64f..aa2e427 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -12,6 +12,7 @@
 #include <linux/completion.h>
 #include <linux/cpumask.h>
 #include <linux/page-debug-flags.h>
+#include <linux/uprobes.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -351,6 +352,7 @@ struct mm_struct {
 #endif
 #ifdef CONFIG_UPROBES
 	atomic_t mm_uprobes_count;
+	struct uprobes_xol_area *uprobes_xol_area;
 #endif
 };
 
diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 30576fa..a407d17 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -92,6 +92,27 @@ struct uprobe_task {
 	struct uprobe *active_uprobe;
 };
 
+/*
+ * On a breakpoint hit, thread contests for a slot.  It free the
+ * slot after singlestep.  Only definite number of slots are
+ * allocated.
+ */
+
+struct uprobes_xol_area {
+	spinlock_t slot_lock;	/* protects bitmap and slot (de)allocation*/
+	wait_queue_head_t wq;	/* if all slots are busy */
+	atomic_t slot_count;	/* currently in use slots */
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
 #ifdef CONFIG_UPROBES
 extern int __weak set_bkpt(struct task_struct *tsk, struct uprobe *uprobe,
 							unsigned long vaddr);
@@ -105,6 +126,7 @@ extern int register_uprobe(struct inode *inode, loff_t offset,
 extern void unregister_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer);
 extern void free_uprobe_utask(struct task_struct *tsk);
+extern void free_uprobes_xol_area(struct mm_struct *mm);
 extern int mmap_uprobe(struct vm_area_struct *vma);
 extern void munmap_uprobe(struct vm_area_struct *vma);
 extern unsigned long __weak get_uprobe_bkpt_addr(struct pt_regs *regs);
diff --git a/kernel/fork.c b/kernel/fork.c
index 5914bc1..088a27c 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -557,6 +557,7 @@ void mmput(struct mm_struct *mm)
 	might_sleep();
 
 	if (atomic_dec_and_test(&mm->mm_users)) {
+		free_uprobes_xol_area(mm);
 		exit_aio(mm);
 		ksm_exit(mm);
 		khugepaged_exit(mm); /* must run before exit_mmap */
@@ -744,6 +745,7 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
 #ifdef CONFIG_UPROBES
 	atomic_set(&mm->mm_uprobes_count,
 			atomic_read(&oldmm->mm_uprobes_count));
+	mm->uprobes_xol_area = NULL;
 #endif
 
 	if (!mm_init(mm, tsk))
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index 083c577..ca1f622 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -31,8 +31,13 @@
 #include <linux/swap.h>		/* try_to_free_swap */
 #include <linux/ptrace.h>	/* user_enable_single_step */
 #include <linux/kdebug.h>	/* notifier mechanism */
+#include <linux/mman.h>		/* PROT_EXEC, MAP_PRIVATE */
+#include <linux/init_task.h>	/* init_cred */
 #include <linux/uprobes.h>
 
+#define UINSNS_PER_PAGE	(PAGE_SIZE/UPROBES_XOL_SLOT_BYTES)
+#define MAX_UPROBES_XOL_SLOTS UINSNS_PER_PAGE
+
 static struct rb_root uprobes_tree = RB_ROOT;
 static DEFINE_SPINLOCK(uprobes_treelock);	/* serialize (un)register */
 static DEFINE_MUTEX(uprobes_mmap_mutex);	/* uprobe->pending_list */
@@ -49,15 +54,21 @@ struct vma_info {
 };
 
 /*
- * valid_vma: Verify if the specified vma is an executable vma
+ * valid_vma: Verify if the specified vma is an executable vma,
+ * but not an XOL vma.
  *	- Return 1 if the specified virtual address is in an
- *	  executable vma.
+ *	  executable vma, but not in an XOL vma.
  */
 static bool valid_vma(struct vm_area_struct *vma)
 {
+	struct uprobes_xol_area *area = vma->vm_mm->uprobes_xol_area;
+
 	if (!vma->vm_file)
 		return false;
 
+	if (area && (area->vaddr == vma->vm_start))
+			return false;
+
 	if ((vma->vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)) ==
 						(VM_READ|VM_EXEC))
 		return true;
@@ -1034,6 +1045,218 @@ void munmap_uprobe(struct vm_area_struct *vma)
 	return;
 }
 
+/* Slot allocation for XOL */
+static int xol_add_vma(struct uprobes_xol_area *area)
+{
+	const struct cred *curr_cred;
+	struct vm_area_struct *vma;
+	struct mm_struct *mm;
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
+	 * override credentials otherwise anonymous memory might
+	 * not be granted execute permission when the selinux
+	 * security hooks have their way.
+	 */
+	vma = rb_entry(rb_last(&mm->mm_rb), struct vm_area_struct, vm_rb);
+	addr = vma->vm_end + PAGE_SIZE;
+	curr_cred = override_creds(&init_cred);
+	addr = do_mmap_pgoff(NULL, addr, PAGE_SIZE, PROT_EXEC, MAP_PRIVATE, 0);
+	revert_creds(curr_cred);
+
+	if (addr & ~PAGE_MASK)
+		goto fail;
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
+	area = kzalloc(sizeof(*area), GFP_KERNEL);
+	if (unlikely(!area))
+		return NULL;
+
+	area->bitmap = kzalloc(BITS_TO_LONGS(UINSNS_PER_PAGE) * sizeof(long),
+								GFP_KERNEL);
+
+	if (!area->bitmap)
+		goto fail;
+
+	init_waitqueue_head(&area->wq);
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
+	kfree(area->bitmap);
+	kfree(area);
+	return current->mm->uprobes_xol_area;
+}
+
+/*
+ * free_uprobes_xol_area - Free the area allocated for slots.
+ */
+void free_uprobes_xol_area(struct mm_struct *mm)
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
+static void xol_wait_event(struct uprobes_xol_area *area)
+{
+	if (atomic_read(&area->slot_count) >= UINSNS_PER_PAGE)
+		wait_event(area->wq,
+			(atomic_read(&area->slot_count) < UINSNS_PER_PAGE));
+}
+
+/*
+ *  - search for a free slot.
+ */
+static unsigned long xol_take_insn_slot(struct uprobes_xol_area *area)
+{
+	unsigned long slot_addr, flags;
+	int slot_nr;
+
+	do {
+		spin_lock_irqsave(&area->slot_lock, flags);
+		slot_nr = find_first_zero_bit(area->bitmap, UINSNS_PER_PAGE);
+		if (slot_nr < UINSNS_PER_PAGE) {
+			__set_bit(slot_nr, area->bitmap);
+			slot_addr = area->vaddr +
+					(slot_nr * UPROBES_XOL_SLOT_BYTES);
+			atomic_inc(&area->slot_count);
+		}
+		spin_unlock_irqrestore(&area->slot_lock, flags);
+		if (slot_nr >= UINSNS_PER_PAGE)
+			xol_wait_event(area);
+
+	} while (slot_nr >= UINSNS_PER_PAGE);
+
+	return slot_addr;
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
+	unsigned long offset;
+	void *vaddr;
+
+	if (!area) {
+		area = xol_alloc_area();
+		if (!area)
+			return 0;
+	}
+	current->utask->xol_vaddr = xol_take_insn_slot(area);
+
+	/*
+	 * Initialize the slot if xol_vaddr points to valid
+	 * instruction slot.
+	 */
+	if (unlikely(!current->utask->xol_vaddr))
+		return 0;
+
+	current->utask->vaddr = slot_addr;
+	offset = current->utask->xol_vaddr & ~PAGE_MASK;
+	vaddr = kmap_atomic(area->page);
+	memcpy(vaddr + offset, uprobe->insn, MAX_UINSN_BYTES);
+	kunmap_atomic(vaddr);
+	return current->utask->xol_vaddr;
+}
+
+/*
+ * xol_free_insn_slot - If slot was earlier allocated by
+ * @xol_get_insn_slot(), make the slot available for
+ * subsequent requests.
+ */
+static void xol_free_insn_slot(struct task_struct *tsk)
+{
+	struct uprobes_xol_area *area;
+	unsigned long vma_end;
+	unsigned long slot_addr;
+
+	if (!tsk->mm || !tsk->mm->uprobes_xol_area || !tsk->utask)
+		return;
+
+	slot_addr = tsk->utask->xol_vaddr;
+
+	if (unlikely(!slot_addr || IS_ERR_VALUE(slot_addr)))
+		return;
+
+	area = tsk->mm->uprobes_xol_area;
+	vma_end = area->vaddr + PAGE_SIZE;
+	if (area->vaddr <= slot_addr && slot_addr < vma_end) {
+		int slot_nr;
+		unsigned long offset = slot_addr - area->vaddr;
+		unsigned long flags;
+
+		slot_nr = offset / UPROBES_XOL_SLOT_BYTES;
+		if (slot_nr >= UINSNS_PER_PAGE)
+			return;
+
+		spin_lock_irqsave(&area->slot_lock, flags);
+		__clear_bit(slot_nr, area->bitmap);
+		spin_unlock_irqrestore(&area->slot_lock, flags);
+		atomic_dec(&area->slot_count);
+		if (waitqueue_active(&area->wq))
+			wake_up(&area->wq);
+		tsk->utask->xol_vaddr = 0;
+	}
+}
+
 /**
  * get_uprobe_bkpt_addr - compute address of bkpt given post-bkpt regs
  * @regs: Reflects the saved state of the task after it has hit a breakpoint
@@ -1059,6 +1282,7 @@ void free_uprobe_utask(struct task_struct *tsk)
 	if (utask->active_uprobe)
 		put_uprobe(utask->active_uprobe);
 
+	xol_free_insn_slot(tsk);
 	kfree(utask);
 	tsk->utask = NULL;
 }
@@ -1088,7 +1312,10 @@ static struct uprobe_task *add_utask(void)
 static int pre_ssout(struct uprobe *uprobe, struct pt_regs *regs,
 				unsigned long vaddr)
 {
-	/* TODO: Yet to be implemented */
+	if (xol_get_insn_slot(uprobe, vaddr) && !pre_xol(uprobe, regs)) {
+		set_instruction_pointer(regs, current->utask->xol_vaddr);
+		return 0;
+	}
 	return -EFAULT;
 }
 
@@ -1098,8 +1325,16 @@ static int pre_ssout(struct uprobe *uprobe, struct pt_regs *regs,
  */
 static bool sstep_complete(struct uprobe *uprobe, struct pt_regs *regs)
 {
-	/* TODO: Yet to be implemented */
-	return false;
+	unsigned long vaddr = instruction_pointer(regs);
+
+	/*
+	 * If we have executed out of line, Instruction pointer
+	 * cannot be same as virtual address of XOL slot.
+	 */
+	if (vaddr == current->utask->xol_vaddr)
+		return false;
+	post_xol(uprobe, regs);
+	return true;
 }
 
 /*
@@ -1154,6 +1389,7 @@ void uprobe_notify_resume(struct pt_regs *regs)
 			utask->active_uprobe = NULL;
 			utask->state = UTASK_RUNNING;
 			user_disable_single_step(current);
+			xol_free_insn_slot(current);
 
 			/* TODO Stop queueing signals. */
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
