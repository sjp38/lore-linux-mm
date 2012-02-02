Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id C64246B13F3
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 09:30:38 -0500 (EST)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 2 Feb 2012 14:28:31 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q12EUXep987244
	for <linux-mm@kvack.org>; Fri, 3 Feb 2012 01:30:33 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q12EUTR4002649
	for <linux-mm@kvack.org>; Fri, 3 Feb 2012 01:30:32 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Thu, 02 Feb 2012 19:49:22 +0530
Message-Id: <20120202141922.5967.72111.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20120202141840.5967.39687.sendpatchset@srdronam.in.ibm.com>
References: <20120202141840.5967.39687.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v10 3.3-rc2 3/9] uprobes: slot allocation.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>


Uprobes executes the original instruction at a probed location out of
line. For this, we allocate a page (per mm) upon the first uprobe hit,
in the process' user address space, divide it into slots that are used
to store the actual instructions to be singlestepped.

Care is taken to ensure that the allocation is in an unmapped area as
close to the top of the user address space as possible, with appropriate
permission settings to keep selinux like frameworks happy.

Upon a uprobe hit, a free slot is acquired, and is released after the
singlestep completes.

[ Folded a fix for build issue on powerpc fixed and reported by Stephen
Rothwell]

Lots of improvements courtesy suggestions/inputs from Peter and Oleg.

Signed-off-by: Jim Keniston <jkenisto@us.ibm.com>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
Changelog (since v5)
- no more spin lock needed for slot allocation.
- use install_special_mapping to add a vma. (previous approach used
  init_creds)
- set uprobes_xol_area while holding map_sem exclusively.

 include/linux/mm_types.h |    4 +
 include/linux/uprobes.h  |   25 ++++++
 kernel/fork.c            |    4 +
 kernel/uprobes.c         |  202 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 235 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 3cc3062..9ade86e 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -12,6 +12,7 @@
 #include <linux/completion.h>
 #include <linux/cpumask.h>
 #include <linux/page-debug-flags.h>
+#include <linux/uprobes.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -388,6 +389,9 @@ struct mm_struct {
 #ifdef CONFIG_CPUMASK_OFFSTACK
 	struct cpumask cpumask_allocation;
 #endif
+#ifdef CONFIG_UPROBES
+	struct uprobes_xol_area *uprobes_xol_area;
+#endif
 };
 
 static inline void mm_init_cpumask(struct mm_struct *mm)
diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 333e775..c9ad7fc 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -27,6 +27,7 @@
 #include <linux/rbtree.h>
 
 struct vm_area_struct;
+struct mm_struct;
 #ifdef CONFIG_ARCH_SUPPORTS_UPROBES
 #include <asm/uprobes.h>
 #else
@@ -92,6 +93,26 @@ struct uprobe_task {
 	struct uprobe *active_uprobe;
 };
 
+/*
+ * On a breakpoint hit, thread contests for a slot.  It free the
+ * slot after singlestep.  Only definite number of slots are
+ * allocated.
+ */
+
+struct uprobes_xol_area {
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
 extern int __weak set_bkpt(struct mm_struct *mm, struct uprobe *uprobe,
 							unsigned long vaddr);
@@ -103,6 +124,7 @@ extern int register_uprobe(struct inode *inode, loff_t offset,
 extern void unregister_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer);
 extern void free_uprobe_utask(struct task_struct *tsk);
+extern void free_uprobes_xol_area(struct mm_struct *mm);
 extern int mmap_uprobe(struct vm_area_struct *vma);
 extern unsigned long __weak get_uprobe_bkpt_addr(struct pt_regs *regs);
 extern int uprobe_post_notifier(struct pt_regs *regs);
@@ -138,5 +160,8 @@ static inline unsigned long get_uprobe_bkpt_addr(struct pt_regs *regs)
 static inline void free_uprobe_utask(struct task_struct *tsk)
 {
 }
+static inline void free_uprobes_xol_area(struct mm_struct *mm)
+{
+}
 #endif /* CONFIG_UPROBES */
 #endif	/* _LINUX_UPROBES_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index 4e81a01..8e65a55 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -553,6 +553,7 @@ void mmput(struct mm_struct *mm)
 	might_sleep();
 
 	if (atomic_dec_and_test(&mm->mm_users)) {
+		free_uprobes_xol_area(mm);
 		exit_aio(mm);
 		ksm_exit(mm);
 		khugepaged_exit(mm); /* must run before exit_mmap */
@@ -739,6 +740,9 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	mm->pmd_huge_pte = NULL;
 #endif
+#ifdef CONFIG_UPROBES
+	mm->uprobes_xol_area = NULL;
+#endif
 
 	if (!mm_init(mm, tsk))
 		goto fail_nomem;
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index 810d15d..f789c84 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -33,6 +33,9 @@
 #include <linux/kdebug.h>	/* notifier mechanism */
 #include <linux/uprobes.h>
 
+#define UINSNS_PER_PAGE	(PAGE_SIZE/UPROBES_XOL_SLOT_BYTES)
+#define MAX_UPROBES_XOL_SLOTS UINSNS_PER_PAGE
+
 static struct srcu_struct uprobes_srcu;
 static struct rb_root uprobes_tree = RB_ROOT;
 static DEFINE_SPINLOCK(uprobes_treelock);	/* serialize rbtree access */
@@ -992,6 +995,201 @@ int mmap_uprobe(struct vm_area_struct *vma)
 	return ret;
 }
 
+/* Slot allocation for XOL */
+static int xol_add_vma(struct uprobes_xol_area *area)
+{
+	struct mm_struct *mm;
+	int ret;
+
+	area->page = alloc_page(GFP_HIGHUSER);
+	if (!area->page)
+		return -ENOMEM;
+
+	mm = current->mm;
+	down_write(&mm->mmap_sem);
+	ret = -EALREADY;
+	if (mm->uprobes_xol_area)
+		goto fail;
+
+	ret = -ENOMEM;
+
+	/* Try to map as high as possible, this is only a hint. */
+	area->vaddr = get_unmapped_area(NULL, TASK_SIZE - PAGE_SIZE,
+							PAGE_SIZE, 0, 0);
+	if (area->vaddr & ~PAGE_MASK) {
+		ret = area->vaddr;
+		goto fail;
+	}
+
+	ret = install_special_mapping(mm, area->vaddr, PAGE_SIZE,
+				VM_EXEC|VM_MAYEXEC|VM_DONTCOPY|VM_IO,
+				&area->page);
+	if (ret)
+		goto fail;
+
+	smp_wmb();	/* pairs with get_uprobes_xol_area() */
+	mm->uprobes_xol_area = area;
+	ret = 0;
+
+fail:
+	up_write(&mm->mmap_sem);
+	if (ret)
+		__free_page(area->page);
+
+	return ret;
+}
+
+static struct uprobes_xol_area *get_uprobes_xol_area(struct mm_struct *mm)
+{
+	struct uprobes_xol_area *area = mm->uprobes_xol_area;
+	smp_read_barrier_depends();/* pairs with wmb in xol_add_vma() */
+	return area;
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
+	struct uprobes_xol_area *area;
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
+	if (!xol_add_vma(area))
+		return area;
+
+fail:
+	kfree(area->bitmap);
+	kfree(area);
+	return get_uprobes_xol_area(current->mm);
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
+/*
+ *  - search for a free slot.
+ */
+static unsigned long xol_take_insn_slot(struct uprobes_xol_area *area)
+{
+	unsigned long slot_addr;
+	int slot_nr;
+
+	do {
+		slot_nr = find_first_zero_bit(area->bitmap, UINSNS_PER_PAGE);
+		if (slot_nr < UINSNS_PER_PAGE) {
+			if (!test_and_set_bit(slot_nr, area->bitmap))
+				break;
+
+			slot_nr = UINSNS_PER_PAGE;
+			continue;
+		}
+		wait_event(area->wq,
+			(atomic_read(&area->slot_count) < UINSNS_PER_PAGE));
+	} while (slot_nr >= UINSNS_PER_PAGE);
+
+	slot_addr = area->vaddr + (slot_nr * UPROBES_XOL_SLOT_BYTES);
+	atomic_inc(&area->slot_count);
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
+	struct uprobes_xol_area *area;
+	unsigned long offset;
+	void *vaddr;
+
+	area = get_uprobes_xol_area(current->mm);
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
+
+		slot_nr = offset / UPROBES_XOL_SLOT_BYTES;
+		if (slot_nr >= UINSNS_PER_PAGE)
+			return;
+
+		clear_bit(slot_nr, area->bitmap);
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
@@ -1020,6 +1218,7 @@ void free_uprobe_utask(struct task_struct *tsk)
 	if (utask->active_uprobe)
 		put_uprobe(utask->active_uprobe);
 
+	xol_free_insn_slot(tsk);
 	kfree(utask);
 	tsk->utask = NULL;
 }
@@ -1049,6 +1248,8 @@ static struct uprobe_task *add_utask(void)
 static int pre_ssout(struct uprobe *uprobe, struct pt_regs *regs,
 				unsigned long vaddr)
 {
+	if (xol_get_insn_slot(uprobe, vaddr) && !pre_xol(uprobe, regs))
+		return 0;
 	return -EFAULT;
 }
 
@@ -1166,6 +1367,7 @@ void uprobe_notify_resume(struct pt_regs *regs)
 		utask->active_uprobe = NULL;
 		utask->state = UTASK_RUNNING;
 		user_disable_single_step(current);
+		xol_free_insn_slot(current);
 
 		spin_lock_irq(&current->sighand->siglock);
 		recalc_sigpending(); /* see uprobe_deny_signal() */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
