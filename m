Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 01F046B13F4
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 09:30:50 -0500 (EST)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 2 Feb 2012 15:22:33 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q12EUk1t868474
	for <linux-mm@kvack.org>; Fri, 3 Feb 2012 01:30:46 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q12EUjVt009120
	for <linux-mm@kvack.org>; Fri, 3 Feb 2012 01:30:46 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Thu, 02 Feb 2012 19:49:38 +0530
Message-Id: <20120202141938.5967.45905.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20120202141840.5967.39687.sendpatchset@srdronam.in.ibm.com>
References: <20120202141840.5967.39687.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v10 3.3-rc2 4/9] uprobes: counter to optimize probe hits.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>


Maintain a per-mm counter (number of uprobes that are inserted on
this process address space). This counter can be used at probe hit
time to determine if we need to do a uprobe lookup in the uprobes
rbtree. Everytime a probe gets inserted successfully, the probe
count is incremented and everytime a probe gets removed successfully
the probe count is removed.

A new hook munmap_uprobe is added to keep the counter to be correct
even when a region is unmapped or remapped. This patch expects that
once a munmap_uprobe() is called, the vma either go away or a
subsequent mmap_uprobe gets called before a removal of a probe from
unregister_uprobe in the same address space.

On every executable vma thats cowed at fork, mmap_uprobe is called
so that the mm_uprobes_count is in sync.

When a vma of interest is mapped, insert the breakpoint at the right
address. Upon munmap, just make sure the data structures are
adjusted/cleaned up.

On process creation, make sure the probes count in the child is set
correctly.

Special cases that are taken care include:
a. mremap()
b. VM_DONTCOPY vmas on fork()
c. insertion/removal races in the parent during fork().

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
Changelog (since v7)
- Separate this patch from the patch that implements mmap_uprobe.
- Increment counter only after verifying that the probe lies underneath.

Changelog (since v5)
- While forking, handle vma's that have VM_DONTCOPY.
- While forking, handle race of new breakpoints being inserted / removed
  in the parent process.

 include/linux/mm_types.h |    1 
 include/linux/uprobes.h  |    4 ++
 kernel/fork.c            |    4 ++
 kernel/uprobes.c         |  103 ++++++++++++++++++++++++++++++++++++++++++++--
 mm/mmap.c                |   10 ++++
 5 files changed, 117 insertions(+), 5 deletions(-)

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
index c9ad7fc..0f6cc1a 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -126,6 +126,7 @@ extern void unregister_uprobe(struct inode *inode, loff_t offset,
 extern void free_uprobe_utask(struct task_struct *tsk);
 extern void free_uprobes_xol_area(struct mm_struct *mm);
 extern int mmap_uprobe(struct vm_area_struct *vma);
+extern void munmap_uprobe(struct vm_area_struct *vma);
 extern unsigned long __weak get_uprobe_bkpt_addr(struct pt_regs *regs);
 extern int uprobe_post_notifier(struct pt_regs *regs);
 extern int uprobe_bkpt_notifier(struct pt_regs *regs);
@@ -146,6 +147,9 @@ static inline int mmap_uprobe(struct vm_area_struct *vma)
 {
 	return 0;
 }
+static inline void munmap_uprobe(struct vm_area_struct *vma)
+{
+}
 static inline void uprobe_notify_resume(struct pt_regs *regs)
 {
 }
diff --git a/kernel/fork.c b/kernel/fork.c
index 8e65a55..53e7959 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -420,6 +420,9 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 
 		if (retval)
 			goto out;
+
+		if (file && mmap_uprobe(tmp))
+			goto out;
 	}
 	/* a new mm has just been created */
 	arch_dup_mmap(oldmm, mm);
@@ -741,6 +744,7 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
 	mm->pmd_huge_pte = NULL;
 #endif
 #ifdef CONFIG_UPROBES
+	atomic_set(&mm->mm_uprobes_count, 0);
 	mm->uprobes_xol_area = NULL;
 #endif
 
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index f789c84..96cf12c 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -615,6 +615,30 @@ static int copy_insn(struct uprobe *uprobe, struct vm_area_struct *vma,
 	return __copy_insn(mapping, vma, uprobe->insn, bytes, uprobe->offset);
 }
 
+/*
+ * How mm_uprobes_count gets updated
+ * mmap_uprobe() increments the count if
+ * 	- it successfully adds a breakpoint.
+ * 	- it not add a breakpoint, but sees that there is a underlying
+ * 	  breakpoint (via a is_bkpt_at_addr()).
+ *
+ * munmap_uprobe() decrements the count if
+ * 	- it sees a underlying breakpoint, (via is_bkpt_at_addr)
+ * 	- Subsequent unregister_uprobe wouldnt find the breakpoint
+ * 	  unless a mmap_uprobe kicks in, since the old vma would be
+ * 	  dropped just after munmap_uprobe.
+ *
+ * register_uprobe increments the count if:
+ * 	- it successfully adds a breakpoint.
+ *
+ * unregister_uprobe decrements the count if:
+ * 	- it sees a underlying breakpoint and removes successfully.
+ * 			(via is_bkpt_at_addr)
+ * 	- Subsequent munmap_uprobe wouldnt find the breakpoint
+ * 	  since there is no underlying breakpoint after the
+ * 	  breakpoint removal.
+ */
+
 static int install_breakpoint(struct mm_struct *mm, struct uprobe *uprobe,
 				struct vm_area_struct *vma, loff_t vaddr)
 {
@@ -646,7 +670,19 @@ static int install_breakpoint(struct mm_struct *mm, struct uprobe *uprobe,
 
 		uprobe->flags |= UPROBES_COPY_INSN;
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
 	ret = set_bkpt(mm, uprobe, addr);
+	if (ret)
+		atomic_dec(&mm->mm_uprobes_count);
 
 	return ret;
 }
@@ -654,7 +690,8 @@ static int install_breakpoint(struct mm_struct *mm, struct uprobe *uprobe,
 static void remove_breakpoint(struct mm_struct *mm, struct uprobe *uprobe,
 							loff_t vaddr)
 {
-	set_orig_insn(mm, uprobe, (unsigned long)vaddr, true);
+	if (!set_orig_insn(mm, uprobe, (unsigned long)vaddr, true))
+		atomic_dec(&mm->mm_uprobes_count);
 }
 
 /*
@@ -960,7 +997,7 @@ int mmap_uprobe(struct vm_area_struct *vma)
 	struct list_head tmp_list;
 	struct uprobe *uprobe, *u;
 	struct inode *inode;
-	int ret = 0;
+	int ret = 0, count = 0;
 
 	if (!atomic_read(&uprobe_events) || !valid_vma(vma, true))
 		return ret;	/* Bail-out */
@@ -984,17 +1021,74 @@ int mmap_uprobe(struct vm_area_struct *vma)
 			}
 			ret = install_breakpoint(vma->vm_mm, uprobe, vma,
 								vaddr);
-			if (ret == -EEXIST)
+			if (ret == -EEXIST) {
 				ret = 0;
+				if (!is_bkpt_at_addr(vma->vm_mm, vaddr))
+					continue;
+
+				/*
+				 * Unable to insert a breakpoint, but
+				 * breakpoint lies underneath. Increment the
+				 * probe count.
+				 */
+				atomic_inc(&vma->vm_mm->mm_uprobes_count);
+			}
+			if (!ret)
+				count++;
+
 		}
 		put_uprobe(uprobe);
 	}
 
 	mutex_unlock(uprobes_mmap_hash(inode));
+	if (ret)
+		atomic_sub(count, &vma->vm_mm->mm_uprobes_count);
 
 	return ret;
 }
 
+/*
+ * Called in context of a munmap of a vma.
+ */
+void munmap_uprobe(struct vm_area_struct *vma)
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
+	list_for_each_entry_safe(uprobe, u, &tmp_list, pending_list) {
+		loff_t vaddr;
+
+		list_del(&uprobe->pending_list);
+		vaddr = vma_address(vma, uprobe->offset);
+		if (vaddr >= vma->vm_start && vaddr < vma->vm_end) {
+
+			/*
+			 * An unregister could have removed the probe before
+			 * unmap. So check before we decrement the count.
+			 */
+			if (is_bkpt_at_addr(vma->vm_mm, vaddr) == 1)
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
@@ -1397,7 +1491,8 @@ int uprobe_bkpt_notifier(struct pt_regs *regs)
 {
 	struct uprobe_task *utask;
 
-	if (!current->mm)
+	if (!current->mm || !atomic_read(&current->mm->mm_uprobes_count))
+		/* task is currently not uprobed */
 		return 0;
 
 	utask = current->utask;
diff --git a/mm/mmap.c b/mm/mmap.c
index 1aed183..e7f5e3c 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -218,6 +218,7 @@ void unlink_file_vma(struct vm_area_struct *vma)
 		mutex_lock(&mapping->i_mmap_mutex);
 		__remove_shared_vm_struct(vma, file, mapping);
 		mutex_unlock(&mapping->i_mmap_mutex);
+		munmap_uprobe(vma);
 	}
 }
 
@@ -546,8 +547,14 @@ again:			remove_next = 1 + (end > next->vm_end);
 
 	if (file) {
 		mapping = file->f_mapping;
-		if (!(vma->vm_flags & VM_NONLINEAR))
+		if (!(vma->vm_flags & VM_NONLINEAR)) {
 			root = &mapping->i_mmap;
+			munmap_uprobe(vma);
+
+			if (adjust_next)
+				munmap_uprobe(next);
+		}
+
 		mutex_lock(&mapping->i_mmap_mutex);
 		if (insert) {
 			/*
@@ -626,6 +633,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 
 	if (remove_next) {
 		if (file) {
+			munmap_uprobe(next);
 			fput(file);
 			if (next->vm_flags & VM_EXECUTABLE)
 				removed_exe_file_vma(mm);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
