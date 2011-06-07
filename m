Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D7B846B0092
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 09:07:06 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp05.au.ibm.com (8.14.4/8.13.1) with ESMTP id p57D0sDV008779
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:00:54 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p57D72cg626714
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:07:02 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p57D716t000983
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:07:02 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 07 Jun 2011 18:30:11 +0530
Message-Id: <20110607130011.28590.36183.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v4 3.0-rc2-tip 10/22] 10: uprobes: slot allocation for uprobes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>


Slots are allocated at probe hit time and released after singlestep. When a
probe is hit, the original instruction corresponding to the probe hit is
copied to allocated slot. Currently we allocate one page of slots for
each mm. Bitmaps are used to know which slots are free. Each slot is made of
128 bytes so that its cache aligned.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Signed-off-by: Jim Keniston <jkenisto@us.ibm.com>
---
 include/linux/mm_types.h |    4 +
 include/linux/uprobes.h  |   23 ++++
 kernel/fork.c            |    4 +
 kernel/uprobes.c         |  242 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 273 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 7bfef2e..e016ac7 100644
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
 
@@ -320,6 +323,7 @@ struct mm_struct {
 	unsigned long uprobes_vaddr;
 	struct list_head uprobes_list; /* protected by uprobes_mutex */
 	atomic_t uprobes_count;
+	struct uprobes_xol_area *uprobes_xol_area;
 #endif
 };
 
diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 821e000..4590e9a 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -101,6 +101,27 @@ struct uprobe_task {
 };
 
 /*
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
+/*
  * Most architectures can use the default versions of @read_opcode(),
  * @set_bkpt(), @set_orig_insn(), and @is_bkpt_insn();
  *
@@ -139,6 +160,7 @@ extern void free_uprobe_utask(struct task_struct *tsk);
 struct vm_area_struct;
 extern int mmap_uprobe(struct vm_area_struct *vma);
 extern void dup_mmap_uprobe(struct mm_struct *old_mm, struct mm_struct *mm);
+extern void free_uprobes_xol_area(struct mm_struct *mm);
 #else /* CONFIG_UPROBES is not defined */
 static inline int register_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer)
@@ -158,5 +180,6 @@ static inline int mmap_uprobe(struct vm_area_struct *vma)
 	return 0;
 }
 static inline void free_uprobe_utask(struct task_struct *tsk) {}
+static inline void free_uprobes_xol_area(struct mm_struct *mm) {}
 #endif /* CONFIG_UPROBES */
 #endif	/* _LINUX_UPROBES_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index bf5999b..c2790b5 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -557,6 +557,7 @@ void mmput(struct mm_struct *mm)
 	might_sleep();
 
 	if (atomic_dec_and_test(&mm->mm_users)) {
+		free_uprobes_xol_area(mm);
 		exit_aio(mm);
 		ksm_exit(mm);
 		khugepaged_exit(mm); /* must run before exit_mmap */
@@ -741,6 +742,9 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	mm->pmd_huge_pte = NULL;
 #endif
+#ifdef CONFIG_UPROBES
+	mm->uprobes_xol_area = NULL;
+#endif
 
 	if (!mm_init(mm, tsk))
 		goto fail_nomem;
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index 2bb2bd7..d19c3b0 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -33,12 +33,29 @@
 #include <linux/rmap.h> /* needed for anon_vma_prepare */
 #include <linux/mmu_notifier.h> /* needed for set_pte_at_notify */
 #include <linux/swap.h>	/* needed for try_to_free_swap */
+#include <linux/mman.h>	/* needed for PROT_EXEC, MAP_PRIVATE */
+#include <linux/file.h> /* needed for fput() */
+#include <linux/init_task.h> /* init_cred */
 
+#define UINSNS_PER_PAGE	(PAGE_SIZE/UPROBES_XOL_SLOT_BYTES)
+#define MAX_UPROBES_XOL_SLOTS UINSNS_PER_PAGE
+
+/*
+ * valid_vma: Verify if the specified vma is an executable vma,
+ * but not an XOL vma.
+ *	- Return 1 if the specified virtual address is in an
+ *	  executable vma, but not in an XOL vma.
+ */
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
@@ -1023,6 +1040,229 @@ mmap_out:
 	return ret;
 }
 
+/* Slot allocation for XOL */
+
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
+	if (addr & ~PAGE_MASK) {
+		pr_debug("uprobes_xol failed to allocate a vma for pid/tgid"
+				"%d/%d for single-stepping out of line.\n",
+				current->pid, current->tgid);
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
+	vaddr = kmap_atomic(area->page, KM_USER0);
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
+		if (slot_nr >= UINSNS_PER_PAGE) {
+			pr_debug("%s: no XOL vma for slot address %#lx\n",
+						__func__, slot_addr);
+			return;
+		}
+
+		spin_lock_irqsave(&area->slot_lock, flags);
+		__clear_bit(slot_nr, area->bitmap);
+		spin_unlock_irqrestore(&area->slot_lock, flags);
+		atomic_dec(&area->slot_count);
+		if (waitqueue_active(&area->wq))
+			wake_up(&area->wq);
+		tsk->utask->xol_vaddr = 0;
+		return;
+	}
+	pr_debug("%s: no XOL vma for slot address %#lx\n",
+						__func__, slot_addr);
+}
+
 /*
  * Called with no locks held.
  * Called in context of a exiting or a exec-ing thread.
@@ -1036,6 +1276,8 @@ void free_uprobe_utask(struct task_struct *tsk)
 
 	if (utask->active_uprobe)
 		put_uprobe(utask->active_uprobe);
+
+	xol_free_insn_slot(tsk);
 	kfree(utask);
 	tsk->utask = NULL;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
