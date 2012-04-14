Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id F3E376B004A
	for <linux-mm@kvack.org>; Sat, 14 Apr 2012 14:26:24 -0400 (EDT)
Date: Sat, 14 Apr 2012 11:26:02 -0700
From: tip-bot for Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Message-ID: <tip-cbc91f71b51b8335f1fc7ccfca8011f31a717367@git.kernel.org>
Reply-To: mingo@kernel.org, torvalds@linux-foundation.org,
        peterz@infradead.org, anton@redhat.com, rostedt@goodmis.org,
        jkenisto@linux.vnet.ibm.com, tglx@linutronix.de, oleg@redhat.com,
        linux-mm@kvack.org, hpa@zytor.com, linux-kernel@vger.kernel.org,
        andi@firstfloor.org, hch@infradead.org, ananth@in.ibm.com,
        masami.hiramatsu.pt@hitachi.com, acme@infradead.org,
        srikar@linux.vnet.ibm.com
In-Reply-To: <20120411103527.23245.9835.sendpatchset@srdronam.in.ibm.com>
References: <20120411103527.23245.9835.sendpatchset@srdronam.in.ibm.com>
Subject: [tip:perf/uprobes] uprobes/core:
  Decrement uprobe count before the pages are unmapped
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: mingo@kernel.org, torvalds@linux-foundation.org, peterz@infradead.org, anton@redhat.com, rostedt@goodmis.org, jkenisto@linux.vnet.ibm.com, tglx@linutronix.de, oleg@redhat.com, linux-mm@kvack.org, hpa@zytor.com, linux-kernel@vger.kernel.org, andi@firstfloor.org, hch@infradead.org, ananth@in.ibm.com, masami.hiramatsu.pt@hitachi.com, acme@infradead.org, srikar@linux.vnet.ibm.com

Commit-ID:  cbc91f71b51b8335f1fc7ccfca8011f31a717367
Gitweb:     http://git.kernel.org/tip/cbc91f71b51b8335f1fc7ccfca8011f31a717367
Author:     Srikar Dronamraju <srikar@linux.vnet.ibm.com>
AuthorDate: Wed, 11 Apr 2012 16:05:27 +0530
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sat, 14 Apr 2012 13:25:48 +0200

uprobes/core: Decrement uprobe count before the pages are unmapped

Uprobes has a callback (uprobe_munmap()) in the unmap path to
maintain the uprobes count.

In the exit path this callback gets called in unlink_file_vma().
However by the time unlink_file_vma() is called, the pages would
have been unmapped (in unmap_vmas()) and the task->rss_stat counts
accounted (in zap_pte_range()).

If the exiting process has probepoints, uprobe_munmap() checks if
the breakpoint instruction was around before decrementing the probe
count.

This results in a file backed page being reread by uprobe_munmap()
and hence it does not find the breakpoint.

This patch fixes this problem by moving the callback to
unmap_single_vma(). Since unmap_single_vma() may not unmap the
complete vma, add start and end parameters to uprobe_munmap().

This bug became apparent courtesy of commit c3f0327f8e9d
("mm: add rss counters consistency check").

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
Link: http://lkml.kernel.org/r/20120411103527.23245.9835.sendpatchset@srdronam.in.ibm.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
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
