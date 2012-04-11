Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 77CCB6B004A
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 06:43:11 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 11 Apr 2012 10:36:23 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3BAaGTn979192
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 20:36:16 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3BAgfP9005129
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 20:42:42 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Wed, 11 Apr 2012 16:05:27 +0530
Message-Id: <20120411103527.23245.9835.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20120411103516.23245.2700.sendpatchset@srdronam.in.ibm.com>
References: <20120411103516.23245.2700.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH 2/2] uprobes/core: Decrement uprobe count before the pages are unmapped
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

Uprobes has a hook(uprobe_munmap) in unmap path to keep the uprobes count
sane. In the exit path this hook gets called in unlink_file_vma. However by
the time unlink_file_vma is called, the pages would have been unmapped
(unmap_vmas) and the rss_stat counts accounted (zap_pte_range). If
the exiting process has probepoints, uprobe_munmap checks if the breakpoint
instruction was around before decrementing the probe count.

This results in a filebacked page being reread by uprobe_munmap and hence 
it does not find the breakpoint.

This patch fixes this problem by moving the hook to unmap_single_vma.
Since unmap_single_vma may not unmap the complete vma, add start and end
parameters to uprobe_munmap.
This bug became apparent courtesy commit c3f0327f8e9d7.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/uprobes.h |    5 +++--
 kernel/events/uprobes.c |    4 ++--
 mm/memory.c             |    3 +++
 mm/mmap.c               |    8 ++++----
 4 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index d594d3b..efe4b33 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -107,7 +107,7 @@ extern bool __weak is_swbp_insn(uprobe_opcode_t *insn);
 extern int uprobe_register(struct inode *inode, loff_t offset, struct uprobe_consumer *uc);
 extern void uprobe_unregister(struct inode *inode, loff_t offset, struct uprobe_consumer *uc);
 extern int uprobe_mmap(struct vm_area_struct *vma);
-extern void uprobe_munmap(struct vm_area_struct *vma);
+extern void uprobe_munmap(struct vm_area_struct *vma, unsigned long start, unsigned long end);
 extern void uprobe_free_utask(struct task_struct *t);
 extern void uprobe_copy_process(struct task_struct *t);
 extern unsigned long __weak uprobe_get_swbp_addr(struct pt_regs *regs);
@@ -134,7 +134,8 @@ static inline int uprobe_mmap(struct vm_area_struct *vma)
 {
 	return 0;
 }
-static inline void uprobe_munmap(struct vm_area_struct *vma)
+static inline void
+uprobe_munmap(struct vm_area_struct *vma, unsigned long start, unsigned long end)
 {
 }
 static inline void uprobe_notify_resume(struct pt_regs *regs)
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index c5caeec..985be4d 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -1112,7 +1112,7 @@ int uprobe_mmap(struct vm_area_struct *vma)
 /*
  * Called in context of a munmap of a vma.
  */
-void uprobe_munmap(struct vm_area_struct *vma)
+void uprobe_munmap(struct vm_area_struct *vma, unsigned long start, unsigned long end)
 {
 	struct list_head tmp_list;
 	struct uprobe *uprobe, *u;
@@ -1138,7 +1138,7 @@ void uprobe_munmap(struct vm_area_struct *vma)
 		list_del(&uprobe->pending_list);
 		vaddr = vma_address(vma, uprobe->offset);
 
-		if (vaddr >= vma->vm_start && vaddr < vma->vm_end) {
+		if (vaddr >= start && vaddr < end) {
 			/*
 			 * An unregister could have removed the probe before
 			 * unmap. So check before we decrement the count.
diff --git a/mm/memory.c b/mm/memory.c
index 6105f47..bf8b403 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1307,6 +1307,9 @@ static void unmap_single_vma(struct mmu_gather *tlb,
 	if (end <= vma->vm_start)
 		return;
 
+	if (vma->vm_file)
+		uprobe_munmap(vma, start, end);
+
 	if (vma->vm_flags & VM_ACCOUNT)
 		*nr_accounted += (end - start) >> PAGE_SHIFT;
 
diff --git a/mm/mmap.c b/mm/mmap.c
index b17a39f..15c21a1 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -218,7 +218,6 @@ void unlink_file_vma(struct vm_area_struct *vma)
 		mutex_lock(&mapping->i_mmap_mutex);
 		__remove_shared_vm_struct(vma, file, mapping);
 		mutex_unlock(&mapping->i_mmap_mutex);
-		uprobe_munmap(vma);
 	}
 }
 
@@ -548,10 +547,11 @@ again:			remove_next = 1 + (end > next->vm_end);
 		mapping = file->f_mapping;
 		if (!(vma->vm_flags & VM_NONLINEAR)) {
 			root = &mapping->i_mmap;
-			uprobe_munmap(vma);
+			uprobe_munmap(vma, vma->vm_start, vma->vm_end);
 
 			if (adjust_next)
-				uprobe_munmap(next);
+				uprobe_munmap(next, next->vm_start,
+							next->vm_end);
 		}
 
 		mutex_lock(&mapping->i_mmap_mutex);
@@ -632,7 +632,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 
 	if (remove_next) {
 		if (file) {
-			uprobe_munmap(next);
+			uprobe_munmap(next, next->vm_start, next->vm_end);
 			fput(file);
 			if (next->vm_flags & VM_EXECUTABLE)
 				removed_exe_file_vma(mm);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
