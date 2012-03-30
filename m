Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 9E0B26B004A
	for <linux-mm@kvack.org>; Fri, 30 Mar 2012 14:32:26 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 30 Mar 2012 18:26:10 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2UIQ9Fv3285144
	for <linux-mm@kvack.org>; Sat, 31 Mar 2012 05:26:09 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2UIWJeQ028683
	for <linux-mm@kvack.org>; Sat, 31 Mar 2012 05:32:20 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 30 Mar 2012 23:56:46 +0530
Message-Id: <20120330182646.10018.85805.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20120330182631.10018.48175.sendpatchset@srdronam.in.ibm.com>
References: <20120330182631.10018.48175.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH 2/2] uprobes/core: Optimize probe hits with help of counter
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

Maintain a per-mm counter (number of uprobes that are inserted on
this process address space). This counter can be used at probe hit
time to determine if we need a lookup in the uprobes rbtree.
Everytime a probe gets inserted successfully, the probe count is
incremented and everytime a probe gets removed, the probe count is
decremented.

The new uprobe_munmap hook ensures the count is correct on a unmap
or remap of a region. We expect that once a uprobe_munmap() is
called, the vma goes away.  So uprobe_unregister() finding a probe
to unregister would either mean unmap event hasnt occurred yet or a
mmap event on the same executable file occured after a unmap event.

Additionally, uprobe_mmap hook now also gets called:
a. on every executable vma that is COWed at fork.
b. a vma of interest is newly mapped; breakpoint insertion also
   happens at the required address.

On process creation, make sure the probes count in the child is set
correctly.

Special cases that are taken care include:
a. mremap
b. VM_DONTCOPY vmas on fork()
c. insertion/removal races in the parent during fork().

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---

Changelog:
(v7)
- Move mm->mm_uprobes_count to mm->uprobes_state.count.
- Separate this patch from the patch that implements uprobe_mmap.
- Increment counter only after verifying that the probe lies underneath.

(v5)
- While forking, handle vma's that have VM_DONTCOPY.
- While forking, handle race of new breakpoints being inserted / removed
  in the parent process.

 include/linux/uprobes.h |    5 ++
 kernel/events/uprobes.c |  119 ++++++++++++++++++++++++++++++++++++++++++++---
 kernel/fork.c           |    3 +
 mm/mmap.c               |   10 ++++
 4 files changed, 128 insertions(+), 9 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index a111460..d594d3b 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -99,6 +99,7 @@ struct xol_area {
 
 struct uprobes_state {
 	struct xol_area		*xol_area;
+	atomic_t		count;
 };
 extern int __weak set_swbp(struct arch_uprobe *aup, struct mm_struct *mm, unsigned long vaddr);
 extern int __weak set_orig_insn(struct arch_uprobe *aup, struct mm_struct *mm,  unsigned long vaddr, bool verify);
@@ -106,6 +107,7 @@ extern bool __weak is_swbp_insn(uprobe_opcode_t *insn);
 extern int uprobe_register(struct inode *inode, loff_t offset, struct uprobe_consumer *uc);
 extern void uprobe_unregister(struct inode *inode, loff_t offset, struct uprobe_consumer *uc);
 extern int uprobe_mmap(struct vm_area_struct *vma);
+extern void uprobe_munmap(struct vm_area_struct *vma);
 extern void uprobe_free_utask(struct task_struct *t);
 extern void uprobe_copy_process(struct task_struct *t);
 extern unsigned long __weak uprobe_get_swbp_addr(struct pt_regs *regs);
@@ -132,6 +134,9 @@ static inline int uprobe_mmap(struct vm_area_struct *vma)
 {
 	return 0;
 }
+static inline void uprobe_munmap(struct vm_area_struct *vma)
+{
+}
 static inline void uprobe_notify_resume(struct pt_regs *regs)
 {
 }
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index b395edb..29e881b 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -642,6 +642,29 @@ copy_insn(struct uprobe *uprobe, struct vm_area_struct *vma, unsigned long addr)
 	return __copy_insn(mapping, vma, uprobe->arch.insn, bytes, uprobe->offset);
 }
 
+/*
+ * How mm->uprobes_state.count gets updated
+ * uprobe_mmap() increments the count if
+ * 	- it successfully adds a breakpoint.
+ * 	- it cannot add a breakpoint, but sees that there is a underlying
+ * 	  breakpoint (via a is_swbp_at_addr()).
+ *
+ * uprobe_munmap() decrements the count if
+ * 	- it sees a underlying breakpoint, (via is_swbp_at_addr)
+ * 	  (Subsequent uprobe_unregister wouldnt find the breakpoint
+ * 	  unless a uprobe_mmap kicks in, since the old vma would be
+ * 	  dropped just after uprobe_munmap.)
+ *
+ * uprobe_register increments the count if:
+ * 	- it successfully adds a breakpoint.
+ *
+ * uprobe_unregister decrements the count if:
+ * 	- it sees a underlying breakpoint and removes successfully.
+ * 	  (via is_swbp_at_addr)
+ * 	  (Subsequent uprobe_munmap wouldnt find the breakpoint
+ * 	  since there is no underlying breakpoint after the
+ * 	  breakpoint removal.)
+ */
 static int
 install_breakpoint(struct uprobe *uprobe, struct mm_struct *mm,
 			struct vm_area_struct *vma, loff_t vaddr)
@@ -675,7 +698,19 @@ install_breakpoint(struct uprobe *uprobe, struct mm_struct *mm,
 
 		uprobe->flags |= UPROBE_COPY_INSN;
 	}
+
+	/*
+	 * Ideally, should be updating the probe count after the breakpoint
+	 * has been successfully inserted. However a thread could hit the
+	 * breakpoint we just inserted even before the probe count is
+	 * incremented. If this is the first breakpoint placed, breakpoint
+	 * notifier might ignore uprobes and pass the trap to the thread.
+	 * Hence increment before and decrement on failure.
+	 */
+	atomic_inc(&mm->uprobes_state.count);
 	ret = set_swbp(&uprobe->arch, mm, addr);
+	if (ret)
+		atomic_dec(&mm->uprobes_state.count);
 
 	return ret;
 }
@@ -683,7 +718,8 @@ install_breakpoint(struct uprobe *uprobe, struct mm_struct *mm,
 static void
 remove_breakpoint(struct uprobe *uprobe, struct mm_struct *mm, loff_t vaddr)
 {
-	set_orig_insn(&uprobe->arch, mm, (unsigned long)vaddr, true);
+	if (!set_orig_insn(&uprobe->arch, mm, (unsigned long)vaddr, true))
+		atomic_dec(&mm->uprobes_state.count);
 }
 
 /*
@@ -1009,7 +1045,7 @@ int uprobe_mmap(struct vm_area_struct *vma)
 	struct list_head tmp_list;
 	struct uprobe *uprobe, *u;
 	struct inode *inode;
-	int ret;
+	int ret, count;
 
 	if (!atomic_read(&uprobe_events) || !valid_vma(vma, true))
 		return 0;
@@ -1023,6 +1059,7 @@ int uprobe_mmap(struct vm_area_struct *vma)
 	build_probe_list(inode, &tmp_list);
 
 	ret = 0;
+	count = 0;
 
 	list_for_each_entry_safe(uprobe, u, &tmp_list, pending_list) {
 		loff_t vaddr;
@@ -1030,21 +1067,85 @@ int uprobe_mmap(struct vm_area_struct *vma)
 		list_del(&uprobe->pending_list);
 		if (!ret) {
 			vaddr = vma_address(vma, uprobe->offset);
-			if (vaddr >= vma->vm_start && vaddr < vma->vm_end) {
-				ret = install_breakpoint(uprobe, vma->vm_mm, vma, vaddr);
-				/* Ignore double add: */
-				if (ret == -EEXIST)
-					ret = 0;
+
+			if (vaddr < vma->vm_start || vaddr >= vma->vm_end) {
+				put_uprobe(uprobe);
+				continue;
 			}
+
+			ret = install_breakpoint(uprobe, vma->vm_mm, vma, vaddr);
+
+			/* Ignore double add: */
+			if (ret == -EEXIST) {
+				ret = 0;
+
+				if (!is_swbp_at_addr(vma->vm_mm, vaddr))
+					continue;
+
+				/*
+				 * Unable to insert a breakpoint, but
+				 * breakpoint lies underneath. Increment the
+				 * probe count.
+				 */
+				atomic_inc(&vma->vm_mm->uprobes_state.count);
+			}
+
+			if (!ret)
+				count++;
 		}
 		put_uprobe(uprobe);
 	}
 
 	mutex_unlock(uprobes_mmap_hash(inode));
 
+	if (ret)
+		atomic_sub(count, &vma->vm_mm->uprobes_state.count);
+
 	return ret;
 }
 
+/*
+ * Called in context of a munmap of a vma.
+ */
+void uprobe_munmap(struct vm_area_struct *vma)
+{
+	struct list_head tmp_list;
+	struct uprobe *uprobe, *u;
+	struct inode *inode;
+
+	if (!atomic_read(&uprobe_events) || !valid_vma(vma, false))
+		return;
+
+	if (!atomic_read(&vma->vm_mm->uprobes_state.count))
+		return;
+
+	inode = vma->vm_file->f_mapping->host;
+	if (!inode)
+		return;
+
+	INIT_LIST_HEAD(&tmp_list);
+	mutex_lock(uprobes_mmap_hash(inode));
+	build_probe_list(inode, &tmp_list);
+
+	list_for_each_entry_safe(uprobe, u, &tmp_list, pending_list) {
+		loff_t vaddr;
+
+		list_del(&uprobe->pending_list);
+		vaddr = vma_address(vma, uprobe->offset);
+
+		if (vaddr >= vma->vm_start && vaddr < vma->vm_end) {
+			/*
+			 * An unregister could have removed the probe before
+			 * unmap. So check before we decrement the count.
+			 */
+			if (is_swbp_at_addr(vma->vm_mm, vaddr) == 1)
+				atomic_dec(&vma->vm_mm->uprobes_state.count);
+		}
+		put_uprobe(uprobe);
+	}
+	mutex_unlock(uprobes_mmap_hash(inode));
+}
+
 /* Slot allocation for XOL */
 static int xol_add_vma(struct xol_area *area)
 {
@@ -1150,6 +1251,7 @@ void uprobe_clear_state(struct mm_struct *mm)
 void uprobe_reset_state(struct mm_struct *mm)
 {
 	mm->uprobes_state.xol_area = NULL;
+	atomic_set(&mm->uprobes_state.count, 0);
 }
 
 /*
@@ -1504,7 +1606,8 @@ int uprobe_pre_sstep_notifier(struct pt_regs *regs)
 {
 	struct uprobe_task *utask;
 
-	if (!current->mm)
+	if (!current->mm || !atomic_read(&current->mm->uprobes_state.count))
+		/* task is currently not uprobed */
 		return 0;
 
 	utask = current->utask;
diff --git a/kernel/fork.c b/kernel/fork.c
index b00f620..ca9a384 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -422,6 +422,9 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 
 		if (retval)
 			goto out;
+
+		if (file && uprobe_mmap(tmp))
+			goto out;
 	}
 	/* a new mm has just been created */
 	arch_dup_mmap(oldmm, mm);
diff --git a/mm/mmap.c b/mm/mmap.c
index 9ae8650..b17a39f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -218,6 +218,7 @@ void unlink_file_vma(struct vm_area_struct *vma)
 		mutex_lock(&mapping->i_mmap_mutex);
 		__remove_shared_vm_struct(vma, file, mapping);
 		mutex_unlock(&mapping->i_mmap_mutex);
+		uprobe_munmap(vma);
 	}
 }
 
@@ -545,8 +546,14 @@ again:			remove_next = 1 + (end > next->vm_end);
 
 	if (file) {
 		mapping = file->f_mapping;
-		if (!(vma->vm_flags & VM_NONLINEAR))
+		if (!(vma->vm_flags & VM_NONLINEAR)) {
 			root = &mapping->i_mmap;
+			uprobe_munmap(vma);
+
+			if (adjust_next)
+				uprobe_munmap(next);
+		}
+
 		mutex_lock(&mapping->i_mmap_mutex);
 		if (insert) {
 			/*
@@ -625,6 +632,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 
 	if (remove_next) {
 		if (file) {
+			uprobe_munmap(next);
 			fput(file);
 			if (next->vm_flags & VM_EXECUTABLE)
 				removed_exe_file_vma(mm);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
