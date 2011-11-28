Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DB1A26B002D
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 14:12:59 -0500 (EST)
Date: Mon, 28 Nov 2011 20:07:46 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 5/5] uprobes: remove the uprobes_xol_area code
Message-ID: <20111128190746.GF4602@redhat.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com> <20111128190614.GA4602@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111128190614.GA4602@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

Remove the no longer needed uprobes_xol_area code.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---
 include/linux/mm_types.h |    1 -
 include/linux/uprobes.h  |   24 ------
 kernel/fork.c            |    2 -
 kernel/uprobes.c         |  198 ----------------------------------------------
 4 files changed, 0 insertions(+), 225 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 2595c9c..b3f1ece 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -392,7 +392,6 @@ struct mm_struct {
 #endif
 #ifdef CONFIG_UPROBES
 	atomic_t mm_uprobes_count;
-	struct uprobes_xol_area *uprobes_xol_area;
 #endif
 };
 
diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index bb59a66..4f92272 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -100,26 +100,6 @@ struct uprobe_task {
 	struct uprobe *active_uprobe;
 };
 
-/*
- * On a breakpoint hit, thread contests for a slot.  It free the
- * slot after singlestep.  Only definite number of slots are
- * allocated.
- */
-
-struct uprobes_xol_area {
-	wait_queue_head_t wq;	/* if all slots are busy */
-	atomic_t slot_count;	/* currently in use slots */
-	unsigned long *bitmap;	/* 0 = free slot */
-	struct page *page;
-
-	/*
-	 * We keep the vma's vm_start rather than a pointer to the vma
-	 * itself.  The probed process or a naughty kernel module could make
-	 * the vma go away, and we must handle that reasonably gracefully.
-	 */
-	unsigned long vaddr;		/* Page(s) of instruction slots */
-};
-
 #ifdef CONFIG_UPROBES
 extern int __weak set_bkpt(struct mm_struct *mm, struct uprobe *uprobe,
 							unsigned long vaddr);
@@ -131,7 +111,6 @@ extern int register_uprobe(struct inode *inode, loff_t offset,
 extern void unregister_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer);
 extern void free_uprobe_utask(struct task_struct *tsk);
-extern void free_uprobes_xol_area(struct mm_struct *mm);
 extern int mmap_uprobe(struct vm_area_struct *vma);
 extern void munmap_uprobe(struct vm_area_struct *vma);
 extern unsigned long __weak get_uprobe_bkpt_addr(struct pt_regs *regs);
@@ -174,8 +153,5 @@ static inline unsigned long get_uprobe_bkpt_addr(struct pt_regs *regs)
 static inline void free_uprobe_utask(struct task_struct *tsk)
 {
 }
-static inline void free_uprobes_xol_area(struct mm_struct *mm)
-{
-}
 #endif /* CONFIG_UPROBES */
 #endif	/* _LINUX_UPROBES_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index 166ee1b..a6b1757 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -553,7 +553,6 @@ void mmput(struct mm_struct *mm)
 	might_sleep();
 
 	if (atomic_dec_and_test(&mm->mm_users)) {
-		free_uprobes_xol_area(mm);
 		exit_aio(mm);
 		ksm_exit(mm);
 		khugepaged_exit(mm); /* must run before exit_mmap */
@@ -742,7 +741,6 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
 #endif
 #ifdef CONFIG_UPROBES
 	atomic_set(&mm->mm_uprobes_count, 0);
-	mm->uprobes_xol_area = NULL;
 #endif
 
 	if (!mm_init(mm, tsk))
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index c9e2f65..aaab607 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -33,9 +33,6 @@
 #include <linux/kdebug.h>	/* notifier mechanism */
 #include <linux/uprobes.h>
 
-#define UINSNS_PER_PAGE	(PAGE_SIZE/UPROBES_XOL_SLOT_BYTES)
-#define MAX_UPROBES_XOL_SLOTS UINSNS_PER_PAGE
-
 static bulkref_t uprobes_srcu;
 static struct rb_root uprobes_tree = RB_ROOT;
 static DEFINE_SPINLOCK(uprobes_treelock);	/* serialize rbtree access */
@@ -1062,201 +1059,6 @@ void munmap_uprobe(struct vm_area_struct *vma)
 	return;
 }
 
-/* Slot allocation for XOL */
-static int xol_add_vma(struct uprobes_xol_area *area)
-{
-	struct mm_struct *mm;
-	int ret;
-
-	area->page = alloc_page(GFP_HIGHUSER);
-	if (!area->page)
-		return -ENOMEM;
-
-	mm = current->mm;
-	down_write(&mm->mmap_sem);
-	ret = -EALREADY;
-	if (mm->uprobes_xol_area)
-		goto fail;
-
-	ret = -ENOMEM;
-
-	/* Try to map as high as possible, this is only a hint. */
-	area->vaddr = get_unmapped_area(NULL, TASK_SIZE - PAGE_SIZE,
-							PAGE_SIZE, 0, 0);
-	if (area->vaddr & ~PAGE_MASK) {
-		ret = area->vaddr;
-		goto fail;
-	}
-
-	ret = install_special_mapping(mm, area->vaddr, PAGE_SIZE,
-				VM_EXEC|VM_MAYEXEC|VM_DONTCOPY|VM_IO,
-				&area->page);
-	if (ret)
-		goto fail;
-
-	smp_wmb();	/* pairs with get_uprobes_xol_area() */
-	mm->uprobes_xol_area = area;
-	ret = 0;
-
-fail:
-	up_write(&mm->mmap_sem);
-	if (ret)
-		__free_page(area->page);
-
-	return ret;
-}
-
-static struct uprobes_xol_area *get_uprobes_xol_area(struct mm_struct *mm)
-{
-	struct uprobes_xol_area *area = mm->uprobes_xol_area;
-	smp_read_barrier_depends();/* pairs with wmb in xol_add_vma() */
-	return area;
-}
-
-/*
- * xol_alloc_area - Allocate process's uprobes_xol_area.
- * This area will be used for storing instructions for execution out of
- * line.
- *
- * Returns the allocated area or NULL.
- */
-static struct uprobes_xol_area *xol_alloc_area(void)
-{
-	struct uprobes_xol_area *area;
-
-	area = kzalloc(sizeof(*area), GFP_KERNEL);
-	if (unlikely(!area))
-		return NULL;
-
-	area->bitmap = kzalloc(BITS_TO_LONGS(UINSNS_PER_PAGE) * sizeof(long),
-								GFP_KERNEL);
-
-	if (!area->bitmap)
-		goto fail;
-
-	init_waitqueue_head(&area->wq);
-	if (!xol_add_vma(area))
-		return area;
-
-fail:
-	kfree(area->bitmap);
-	kfree(area);
-	return get_uprobes_xol_area(current->mm);
-}
-
-/*
- * free_uprobes_xol_area - Free the area allocated for slots.
- */
-void free_uprobes_xol_area(struct mm_struct *mm)
-{
-	struct uprobes_xol_area *area = mm->uprobes_xol_area;
-
-	if (!area)
-		return;
-
-	put_page(area->page);
-	kfree(area->bitmap);
-	kfree(area);
-}
-
-/*
- *  - search for a free slot.
- */
-static unsigned long xol_take_insn_slot(struct uprobes_xol_area *area)
-{
-	unsigned long slot_addr;
-	int slot_nr;
-
-	do {
-		slot_nr = find_first_zero_bit(area->bitmap, UINSNS_PER_PAGE);
-		if (slot_nr < UINSNS_PER_PAGE) {
-			if (!test_and_set_bit(slot_nr, area->bitmap))
-				break;
-
-			slot_nr = UINSNS_PER_PAGE;
-			continue;
-		}
-		wait_event(area->wq,
-			(atomic_read(&area->slot_count) < UINSNS_PER_PAGE));
-	} while (slot_nr >= UINSNS_PER_PAGE);
-
-	slot_addr = area->vaddr + (slot_nr * UPROBES_XOL_SLOT_BYTES);
-	atomic_inc(&area->slot_count);
-	return slot_addr;
-}
-
-/*
- * xol_get_insn_slot - If was not allocated a slot, then
- * allocate a slot.
- * Returns the allocated slot address or 0.
- */
-static unsigned long xol_get_insn_slot(struct uprobe *uprobe,
-					unsigned long slot_addr)
-{
-	struct uprobes_xol_area *area;
-	unsigned long offset;
-	void *vaddr;
-
-	area = get_uprobes_xol_area(current->mm);
-	if (!area) {
-		area = xol_alloc_area();
-		if (!area)
-			return 0;
-	}
-	current->utask->xol_vaddr = xol_take_insn_slot(area);
-
-	/*
-	 * Initialize the slot if xol_vaddr points to valid
-	 * instruction slot.
-	 */
-	if (unlikely(!current->utask->xol_vaddr))
-		return 0;
-
-	current->utask->vaddr = slot_addr;
-	offset = current->utask->xol_vaddr & ~PAGE_MASK;
-	vaddr = kmap_atomic(area->page);
-	memcpy(vaddr + offset, uprobe->insn, MAX_UINSN_BYTES);
-	kunmap_atomic(vaddr);
-	return current->utask->xol_vaddr;
-}
-
-/*
- * xol_free_insn_slot - If slot was earlier allocated by
- * @xol_get_insn_slot(), make the slot available for
- * subsequent requests.
- */
-static void xol_free_insn_slot(struct task_struct *tsk)
-{
-	struct uprobes_xol_area *area;
-	unsigned long vma_end;
-	unsigned long slot_addr;
-
-	if (!tsk->mm || !tsk->mm->uprobes_xol_area || !tsk->utask)
-		return;
-
-	slot_addr = tsk->utask->xol_vaddr;
-
-	if (unlikely(!slot_addr || IS_ERR_VALUE(slot_addr)))
-		return;
-
-	area = tsk->mm->uprobes_xol_area;
-	vma_end = area->vaddr + PAGE_SIZE;
-	if (area->vaddr <= slot_addr && slot_addr < vma_end) {
-		int slot_nr;
-		unsigned long offset = slot_addr - area->vaddr;
-
-		slot_nr = offset / UPROBES_XOL_SLOT_BYTES;
-		if (slot_nr >= UINSNS_PER_PAGE)
-			return;
-
-		clear_bit(slot_nr, area->bitmap);
-		atomic_dec(&area->slot_count);
-		if (waitqueue_active(&area->wq))
-			wake_up(&area->wq);
-		tsk->utask->xol_vaddr = 0;
-	}
-}
-
 /**
  * get_uprobe_bkpt_addr - compute address of bkpt given post-bkpt regs
  * @regs: Reflects the saved state of the task after it has hit a breakpoint
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
