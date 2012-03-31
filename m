Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id D6A846B00EA
	for <linux-mm@kvack.org>; Sat, 31 Mar 2012 13:19:48 -0400 (EDT)
Date: Sat, 31 Mar 2012 10:19:11 -0700
From: tip-bot for Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Message-ID: <tip-d4b3b6384f98f8692ad0209891ccdbc7e78bbefe@git.kernel.org>
Reply-To: mingo@kernel.org, torvalds@linux-foundation.org,
        peterz@infradead.org, anton@redhat.com, rostedt@goodmis.org,
        jkenisto@linux.vnet.ibm.com, tglx@linutronix.de, oleg@redhat.com,
        linux-mm@kvack.org, hpa@zytor.com, linux-kernel@vger.kernel.org,
        andi@firstfloor.org, hch@infradead.org, ananth@in.ibm.com,
        masami.hiramatsu.pt@hitachi.com, acme@infradead.org,
        srikar@linux.vnet.ibm.com
In-Reply-To: <20120330182631.10018.48175.sendpatchset@srdronam.in.ibm.com>
References: <20120330182631.10018.48175.sendpatchset@srdronam.in.ibm.com>
Subject: [tip:perf/uprobes] uprobes/core:
  Allocate XOL slots for uprobes use
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: mingo@kernel.org, torvalds@linux-foundation.org, peterz@infradead.org, anton@redhat.com, rostedt@goodmis.org, jkenisto@linux.vnet.ibm.com, tglx@linutronix.de, oleg@redhat.com, linux-mm@kvack.org, hpa@zytor.com, linux-kernel@vger.kernel.org, andi@firstfloor.org, hch@infradead.org, ananth@in.ibm.com, masami.hiramatsu.pt@hitachi.com, acme@infradead.org, srikar@linux.vnet.ibm.com

Commit-ID:  d4b3b6384f98f8692ad0209891ccdbc7e78bbefe
Gitweb:     http://git.kernel.org/tip/d4b3b6384f98f8692ad0209891ccdbc7e78bbefe
Author:     Srikar Dronamraju <srikar@linux.vnet.ibm.com>
AuthorDate: Fri, 30 Mar 2012 23:56:31 +0530
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sat, 31 Mar 2012 11:50:01 +0200

uprobes/core: Allocate XOL slots for uprobes use

Uprobes executes the original instruction at a probed location
out of line. For this, we allocate a page (per mm) upon the
first uprobe hit, in the process user address space, divide it
into slots that are used to store the actual instructions to be
singlestepped. These slots are known as xol (execution out of
line) slots.

Care is taken to ensure that the allocation is in an unmapped
area as close to the top of the user address space as possible,
with appropriate permission settings to keep selinux like
frameworks happy.

Upon a uprobe hit, a free slot is acquired, and is released
after the singlestep completes.

Lots of improvements courtesy suggestions/inputs from Peter and
Oleg.

[ Folded a fix for build issue on powerpc fixed and reported by
  Stephen Rothwell. ]

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Cc: Jim Keniston <jkenisto@linux.vnet.ibm.com>
Cc: Linux-mm <linux-mm@kvack.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Arnaldo Carvalho de Melo <acme@infradead.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Anton Arapov <anton@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Link: http://lkml.kernel.org/r/20120330182631.10018.48175.sendpatchset@srdronam.in.ibm.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/mm_types.h |    2 +
 include/linux/uprobes.h  |   34 +++++++
 kernel/events/uprobes.c  |  215 ++++++++++++++++++++++++++++++++++++++++++++++
 kernel/fork.c            |    2 +
 4 files changed, 253 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 3cc3062..26574c7 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -12,6 +12,7 @@
 #include <linux/completion.h>
 #include <linux/cpumask.h>
 #include <linux/page-debug-flags.h>
+#include <linux/uprobes.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -388,6 +389,7 @@ struct mm_struct {
 #ifdef CONFIG_CPUMASK_OFFSTACK
 	struct cpumask cpumask_allocation;
 #endif
+	struct uprobes_state uprobes_state;
 };
 
 static inline void mm_init_cpumask(struct mm_struct *mm)
diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 5ec778f..a111460 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -28,6 +28,8 @@
 #include <linux/rbtree.h>
 
 struct vm_area_struct;
+struct mm_struct;
+struct inode;
 
 #ifdef CONFIG_ARCH_SUPPORTS_UPROBES
 # include <asm/uprobes.h>
@@ -76,6 +78,28 @@ struct uprobe_task {
 	unsigned long			vaddr;
 };
 
+/*
+ * On a breakpoint hit, thread contests for a slot.  It frees the
+ * slot after singlestep. Currently a fixed number of slots are
+ * allocated.
+ */
+struct xol_area {
+	wait_queue_head_t 	wq;		/* if all slots are busy */
+	atomic_t 		slot_count;	/* number of in-use slots */
+	unsigned long 		*bitmap;	/* 0 = free slot */
+	struct page 		*page;
+
+	/*
+	 * We keep the vma's vm_start rather than a pointer to the vma
+	 * itself.  The probed process or a naughty kernel module could make
+	 * the vma go away, and we must handle that reasonably gracefully.
+	 */
+	unsigned long 		vaddr;		/* Page(s) of instruction slots */
+};
+
+struct uprobes_state {
+	struct xol_area		*xol_area;
+};
 extern int __weak set_swbp(struct arch_uprobe *aup, struct mm_struct *mm, unsigned long vaddr);
 extern int __weak set_orig_insn(struct arch_uprobe *aup, struct mm_struct *mm,  unsigned long vaddr, bool verify);
 extern bool __weak is_swbp_insn(uprobe_opcode_t *insn);
@@ -90,7 +114,11 @@ extern int uprobe_pre_sstep_notifier(struct pt_regs *regs);
 extern void uprobe_notify_resume(struct pt_regs *regs);
 extern bool uprobe_deny_signal(void);
 extern bool __weak arch_uprobe_skip_sstep(struct arch_uprobe *aup, struct pt_regs *regs);
+extern void uprobe_clear_state(struct mm_struct *mm);
+extern void uprobe_reset_state(struct mm_struct *mm);
 #else /* !CONFIG_UPROBES */
+struct uprobes_state {
+};
 static inline int
 uprobe_register(struct inode *inode, loff_t offset, struct uprobe_consumer *uc)
 {
@@ -121,5 +149,11 @@ static inline void uprobe_free_utask(struct task_struct *t)
 static inline void uprobe_copy_process(struct task_struct *t)
 {
 }
+static inline void uprobe_clear_state(struct mm_struct *mm)
+{
+}
+static inline void uprobe_reset_state(struct mm_struct *mm)
+{
+}
 #endif /* !CONFIG_UPROBES */
 #endif	/* _LINUX_UPROBES_H */
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index b807d15..b395edb 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -35,6 +35,9 @@
 
 #include <linux/uprobes.h>
 
+#define UINSNS_PER_PAGE			(PAGE_SIZE/UPROBE_XOL_SLOT_BYTES)
+#define MAX_UPROBE_XOL_SLOTS		UINSNS_PER_PAGE
+
 static struct srcu_struct uprobes_srcu;
 static struct rb_root uprobes_tree = RB_ROOT;
 
@@ -1042,6 +1045,213 @@ int uprobe_mmap(struct vm_area_struct *vma)
 	return ret;
 }
 
+/* Slot allocation for XOL */
+static int xol_add_vma(struct xol_area *area)
+{
+	struct mm_struct *mm;
+	int ret;
+
+	area->page = alloc_page(GFP_HIGHUSER);
+	if (!area->page)
+		return -ENOMEM;
+
+	ret = -EALREADY;
+	mm = current->mm;
+
+	down_write(&mm->mmap_sem);
+	if (mm->uprobes_state.xol_area)
+		goto fail;
+
+	ret = -ENOMEM;
+
+	/* Try to map as high as possible, this is only a hint. */
+	area->vaddr = get_unmapped_area(NULL, TASK_SIZE - PAGE_SIZE, PAGE_SIZE, 0, 0);
+	if (area->vaddr & ~PAGE_MASK) {
+		ret = area->vaddr;
+		goto fail;
+	}
+
+	ret = install_special_mapping(mm, area->vaddr, PAGE_SIZE,
+				VM_EXEC|VM_MAYEXEC|VM_DONTCOPY|VM_IO, &area->page);
+	if (ret)
+		goto fail;
+
+	smp_wmb();	/* pairs with get_xol_area() */
+	mm->uprobes_state.xol_area = area;
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
+static struct xol_area *get_xol_area(struct mm_struct *mm)
+{
+	struct xol_area *area;
+
+	area = mm->uprobes_state.xol_area;
+	smp_read_barrier_depends();	/* pairs with wmb in xol_add_vma() */
+
+	return area;
+}
+
+/*
+ * xol_alloc_area - Allocate process's xol_area.
+ * This area will be used for storing instructions for execution out of
+ * line.
+ *
+ * Returns the allocated area or NULL.
+ */
+static struct xol_area *xol_alloc_area(void)
+{
+	struct xol_area *area;
+
+	area = kzalloc(sizeof(*area), GFP_KERNEL);
+	if (unlikely(!area))
+		return NULL;
+
+	area->bitmap = kzalloc(BITS_TO_LONGS(UINSNS_PER_PAGE) * sizeof(long), GFP_KERNEL);
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
+
+	return get_xol_area(current->mm);
+}
+
+/*
+ * uprobe_clear_state - Free the area allocated for slots.
+ */
+void uprobe_clear_state(struct mm_struct *mm)
+{
+	struct xol_area *area = mm->uprobes_state.xol_area;
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
+ * uprobe_reset_state - Free the area allocated for slots.
+ */
+void uprobe_reset_state(struct mm_struct *mm)
+{
+	mm->uprobes_state.xol_area = NULL;
+}
+
+/*
+ *  - search for a free slot.
+ */
+static unsigned long xol_take_insn_slot(struct xol_area *area)
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
+		wait_event(area->wq, (atomic_read(&area->slot_count) < UINSNS_PER_PAGE));
+	} while (slot_nr >= UINSNS_PER_PAGE);
+
+	slot_addr = area->vaddr + (slot_nr * UPROBE_XOL_SLOT_BYTES);
+	atomic_inc(&area->slot_count);
+
+	return slot_addr;
+}
+
+/*
+ * xol_get_insn_slot - If was not allocated a slot, then
+ * allocate a slot.
+ * Returns the allocated slot address or 0.
+ */
+static unsigned long xol_get_insn_slot(struct uprobe *uprobe, unsigned long slot_addr)
+{
+	struct xol_area *area;
+	unsigned long offset;
+	void *vaddr;
+
+	area = get_xol_area(current->mm);
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
+	memcpy(vaddr + offset, uprobe->arch.insn, MAX_UINSN_BYTES);
+	kunmap_atomic(vaddr);
+
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
+	struct xol_area *area;
+	unsigned long vma_end;
+	unsigned long slot_addr;
+
+	if (!tsk->mm || !tsk->mm->uprobes_state.xol_area || !tsk->utask)
+		return;
+
+	slot_addr = tsk->utask->xol_vaddr;
+
+	if (unlikely(!slot_addr || IS_ERR_VALUE(slot_addr)))
+		return;
+
+	area = tsk->mm->uprobes_state.xol_area;
+	vma_end = area->vaddr + PAGE_SIZE;
+	if (area->vaddr <= slot_addr && slot_addr < vma_end) {
+		unsigned long offset;
+		int slot_nr;
+
+		offset = slot_addr - area->vaddr;
+		slot_nr = offset / UPROBE_XOL_SLOT_BYTES;
+		if (slot_nr >= UINSNS_PER_PAGE)
+			return;
+
+		clear_bit(slot_nr, area->bitmap);
+		atomic_dec(&area->slot_count);
+		if (waitqueue_active(&area->wq))
+			wake_up(&area->wq);
+
+		tsk->utask->xol_vaddr = 0;
+	}
+}
+
 /**
  * uprobe_get_swbp_addr - compute address of swbp given post-swbp regs
  * @regs: Reflects the saved state of the task after it has hit a breakpoint
@@ -1070,6 +1280,7 @@ void uprobe_free_utask(struct task_struct *t)
 	if (utask->active_uprobe)
 		put_uprobe(utask->active_uprobe);
 
+	xol_free_insn_slot(t);
 	kfree(utask);
 	t->utask = NULL;
 }
@@ -1108,6 +1319,9 @@ static struct uprobe_task *add_utask(void)
 static int
 pre_ssout(struct uprobe *uprobe, struct pt_regs *regs, unsigned long vaddr)
 {
+	if (xol_get_insn_slot(uprobe, vaddr) && !arch_uprobe_pre_xol(&uprobe->arch, regs))
+		return 0;
+
 	return -EFAULT;
 }
 
@@ -1252,6 +1466,7 @@ static void handle_singlestep(struct uprobe_task *utask, struct pt_regs *regs)
 	utask->active_uprobe = NULL;
 	utask->state = UTASK_RUNNING;
 	user_disable_single_step(current);
+	xol_free_insn_slot(current);
 
 	spin_lock_irq(&current->sighand->siglock);
 	recalc_sigpending(); /* see uprobe_deny_signal() */
diff --git a/kernel/fork.c b/kernel/fork.c
index eb7b633..3133b9d 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -554,6 +554,7 @@ void mmput(struct mm_struct *mm)
 	might_sleep();
 
 	if (atomic_dec_and_test(&mm->mm_users)) {
+		uprobe_clear_state(mm);
 		exit_aio(mm);
 		ksm_exit(mm);
 		khugepaged_exit(mm); /* must run before exit_mmap */
@@ -760,6 +761,7 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	mm->pmd_huge_pte = NULL;
 #endif
+	uprobe_reset_state(mm);
 
 	if (!mm_init(mm, tsk))
 		goto fail_nomem;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
