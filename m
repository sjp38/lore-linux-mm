Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 2B22D6B0083
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 14:12:52 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 21 Mar 2012 18:08:24 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2LI6iRM3342392
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 05:06:44 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2LIChOS007101
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 05:12:43 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Wed, 21 Mar 2012 23:38:26 +0530
Message-Id: <20120321180826.22773.57531.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20120321180811.22773.5801.sendpatchset@srdronam.in.ibm.com>
References: <20120321180811.22773.5801.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH 2/2] uprobes/core: counter to optimize probe hits.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>

From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

Maintain a per-mm counter (number of uprobes that are inserted on
this process address space). This counter can be used at probe hit
time to determine if we need to do a uprobe lookup in the uprobes
rbtree. Everytime a probe gets inserted successfully, the probe
count is incremented and everytime a probe gets removed successfully
the probe count is removed.

A new hook uprobe_munmap is added to keep the counter to be correct
even when a region is unmapped or remapped. This patch expects that
once a uprobe_munmap() is called, the vma either go away or a
subsequent uprobe_mmap gets called before a removal of a probe from
unregister_uprobe in the same address space.

On every executable vma thats cowed at fork, uprobe_mmap is called
so that the mm_uprobes_count is in sync.

When a vma of interest is mapped, insert the breakpoint at the right
address. Upon munmap, just make sure the data structures are
adjusted/cleaned up.

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
- Separate this patch from the patch that implements uprobe_mmap.
- Increment counter only after verifying that the probe lies underneath.

(v5)
- While forking, handle vma's that have VM_DONTCOPY.
- While forking, handle race of new breakpoints being inserted / removed
  in the parent process.

 include/linux/mm_types.h |    1 
 include/linux/uprobes.h  |    4 ++
 kernel/events/uprobes.c  |  122 +++++++++++++++++++++++++++++++++++++++++++---
 kernel/fork.c            |    3 +
 mm/mmap.c                |   10 +++-
 5 files changed, 131 insertions(+), 9 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 9ade86e..62d5aeb 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -390,6 +390,7 @@ struct mm_struct {
 	struct cpumask cpumask_allocation;
 #endif
 #ifdef CONFIG_UPROBES
+	atomic_t mm_uprobes_count;
 	struct uprobes_xol_area *uprobes_xol_area;
 #endif
 };
diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index cc1310f..6354ca0 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -104,6 +104,7 @@ extern bool __weak is_swbp_insn(uprobe_opcode_t *insn);
 extern int uprobe_register(struct inode *inode, loff_t offset, struct uprobe_consumer *uc);
 extern void uprobe_unregister(struct inode *inode, loff_t offset, struct uprobe_consumer *uc);
 extern int uprobe_mmap(struct vm_area_struct *vma);
+extern void uprobe_munmap(struct vm_area_struct *vma);
 extern void uprobe_free_utask(struct task_struct *t);
 extern void uprobe_copy_process(struct task_struct *t);
 extern unsigned long __weak uprobe_get_swbp_addr(struct pt_regs *regs);
@@ -128,6 +129,9 @@ static inline int uprobe_mmap(struct vm_area_struct *vma)
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
index cdad57f..57f1122 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -642,6 +642,30 @@ copy_insn(struct uprobe *uprobe, struct vm_area_struct *vma, unsigned long addr)
 	return __copy_insn(mapping, vma, uprobe->arch.insn, bytes, uprobe->offset);
 }
 
+/*
+ * How mm_uprobes_count gets updated
+ * uprobe_mmap() increments the count if
+ * 	- it successfully adds a breakpoint.
+ * 	- it cannot add a breakpoint, but sees that there is a underlying
+ * 	  breakpoint (via a is_swbp_at_addr()).
+ *
+ * uprobe_munmap() decrements the count if
+ * 	- it sees a underlying breakpoint, (via is_swbp_at_addr)
+ * 	  (Subsequent unregister_uprobe wouldnt find the breakpoint
+ * 	  unless a uprobe_mmap kicks in, since the old vma would be
+ * 	  dropped just after uprobe_munmap.)
+ *
+ * register_uprobe increments the count if:
+ * 	- it successfully adds a breakpoint.
+ *
+ * unregister_uprobe decrements the count if:
+ * 	- it sees a underlying breakpoint and removes successfully.
+ * 	  (via is_swbp_at_addr)
+ * 	  (Subsequent uprobe_munmap wouldnt find the breakpoint
+ * 	  since there is no underlying breakpoint after the
+ * 	  breakpoint removal.)
+ */
+
 static int
 install_breakpoint(struct uprobe *uprobe, struct mm_struct *mm,
 			struct vm_area_struct *vma, loff_t vaddr)
@@ -675,7 +699,19 @@ install_breakpoint(struct uprobe *uprobe, struct mm_struct *mm,
 
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
+	atomic_inc(&mm->mm_uprobes_count);
 	ret = set_swbp(&uprobe->arch, mm, addr);
+	if (ret)
+		atomic_dec(&mm->mm_uprobes_count);
 
 	return ret;
 }
@@ -683,7 +719,8 @@ install_breakpoint(struct uprobe *uprobe, struct mm_struct *mm,
 static void
 remove_breakpoint(struct uprobe *uprobe, struct mm_struct *mm, loff_t vaddr)
 {
-	set_orig_insn(&uprobe->arch, mm, (unsigned long)vaddr, true);
+	if (!set_orig_insn(&uprobe->arch, mm, (unsigned long)vaddr, true))
+		atomic_dec(&mm->mm_uprobes_count);
 }
 
 /*
@@ -1009,7 +1046,7 @@ int uprobe_mmap(struct vm_area_struct *vma)
 	struct list_head tmp_list;
 	struct uprobe *uprobe, *u;
 	struct inode *inode;
-	int ret;
+	int ret, count;
 
 	if (!atomic_read(&uprobe_events) || !valid_vma(vma, true))
 		return 0;
@@ -1023,6 +1060,7 @@ int uprobe_mmap(struct vm_area_struct *vma)
 	build_probe_list(inode, &tmp_list);
 
 	ret = 0;
+	count = 0;
 
 	list_for_each_entry_safe(uprobe, u, &tmp_list, pending_list) {
 		loff_t vaddr;
@@ -1030,21 +1068,87 @@ int uprobe_mmap(struct vm_area_struct *vma)
 		list_del(&uprobe->pending_list);
 		if (!ret) {
 			vaddr = vma_address(vma, uprobe->offset);
-			if (vaddr >= vma->vm_start && vaddr < vma->vm_end) {
-				ret = install_breakpoint(uprobe, vma->vm_mm, vma, vaddr);
-				/* Ignore double add: */
-				if (ret == -EEXIST)
-					ret = 0;
+			if (vaddr < vma->vm_start || vaddr >= vma->vm_end) {
+				put_uprobe(uprobe);
+				continue;
+			}
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
+				atomic_inc(&vma->vm_mm->mm_uprobes_count);
 			}
+
+			if (!ret)
+				count++;
+
 		}
 		put_uprobe(uprobe);
 	}
 
 	mutex_unlock(uprobes_mmap_hash(inode));
 
+	if (ret)
+		atomic_sub(count, &vma->vm_mm->mm_uprobes_count);
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
+		return;		/* Bail-out */
+
+	if (!atomic_read(&vma->vm_mm->mm_uprobes_count))
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
+
+			/*
+			 * An unregister could have removed the probe before
+			 * unmap. So check before we decrement the count.
+			 */
+			if (is_swbp_at_addr(vma->vm_mm, vaddr) == 1)
+				atomic_dec(&vma->vm_mm->mm_uprobes_count);
+		}
+		put_uprobe(uprobe);
+	}
+	mutex_unlock(uprobes_mmap_hash(inode));
+	return;
+}
+
 /* Slot allocation for XOL */
 static int xol_add_vma(struct uprobes_xol_area *area)
 {
@@ -1150,6 +1254,7 @@ void uprobe_free_xol_area(struct mm_struct *mm)
 void uprobe_reset_xol_area(struct mm_struct *mm)
 {
 	mm->uprobes_xol_area = NULL;
+	atomic_set(&mm->mm_uprobes_count, 0);
 }
 
 /*
@@ -1504,7 +1609,8 @@ int uprobe_pre_sstep_notifier(struct pt_regs *regs)
 {
 	struct uprobe_task *utask;
 
-	if (!current->mm)
+	if (!current->mm || !atomic_read(&current->mm->mm_uprobes_count))
+		/* task is currently not uprobed */
 		return 0;
 
 	utask = current->utask;
diff --git a/kernel/fork.c b/kernel/fork.c
index 41bc33e..adab936 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -421,6 +421,9 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 
 		if (retval)
 			goto out;
+
+		if (file && uprobe_mmap(tmp))
+			goto out;
 	}
 	/* a new mm has just been created */
 	arch_dup_mmap(oldmm, mm);
diff --git a/mm/mmap.c b/mm/mmap.c
index 6795aaf..d90bfb6 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -218,6 +218,7 @@ void unlink_file_vma(struct vm_area_struct *vma)
 		mutex_lock(&mapping->i_mmap_mutex);
 		__remove_shared_vm_struct(vma, file, mapping);
 		mutex_unlock(&mapping->i_mmap_mutex);
+		uprobe_munmap(vma);
 	}
 }
 
@@ -546,8 +547,14 @@ again:			remove_next = 1 + (end > next->vm_end);
 
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
@@ -626,6 +633,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 
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
