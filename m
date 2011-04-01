Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EFCCC8D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 10:44:01 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp05.au.ibm.com (8.14.4/8.13.1) with ESMTP id p31EcA0I016421
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:38:10 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p31Ehspk1839186
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:43:54 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p31Ehrp6026220
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:43:54 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 01 Apr 2011 20:04:13 +0530
Message-Id: <20110401143413.15455.75831.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v3 2.6.39-rc1-tip 9/26]  9: uprobes: mmap and fork hooks.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>


Provides hooks in mmap and fork.

On fork, after the new mm is created, we need to set the count of
uprobes.  On mmap, check if the mmap region is an executable page and if
its a executable page, walk through the rbtree and insert actual
breakpoints for already registered probes corresponding to this inode.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/uprobes.h |   14 ++++-
 kernel/fork.c           |    2 +
 kernel/uprobes.c        |  144 +++++++++++++++++++++++++++++++++++++++++++----
 mm/mmap.c               |    6 ++
 4 files changed, 154 insertions(+), 12 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 62036a0..27496c6 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -66,6 +66,7 @@ struct uprobe_consumer {
 struct uprobe {
 	struct rb_node		rb_node;	/* node in the rb tree */
 	atomic_t		ref;
+	struct list_head	pending_list;
 	struct rw_semaphore	consumer_rwsem;
 	struct uprobe_arch_info	arch_info;	/* arch specific info if any */
 	struct uprobe_consumer	*consumers;
@@ -110,6 +111,10 @@ extern int register_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer);
 extern void unregister_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer);
+
+struct vm_area_struct;
+extern int uprobe_mmap(struct vm_area_struct *vma);
+extern void uprobe_dup_mmap(struct mm_struct *old_mm, struct mm_struct *mm);
 #else /* CONFIG_UPROBES is not defined */
 static inline int register_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer)
@@ -120,6 +125,13 @@ static inline void unregister_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer)
 {
 }
-
+static inline void uprobe_dup_mmap(struct mm_struct *old_mm,
+		struct mm_struct *mm)
+{
+}
+static inline int uprobe_mmap(struct vm_area_struct *vma)
+{
+	return 0;
+}
 #endif /* CONFIG_UPROBES */
 #endif	/* _LINUX_UPROBES_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index e7548de..2f1a16d 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -68,6 +68,7 @@
 #include <linux/user-return-notifier.h>
 #include <linux/oom.h>
 #include <linux/khugepaged.h>
+#include <linux/uprobes.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -425,6 +426,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 	}
 	/* a new mm has just been created */
 	arch_dup_mmap(oldmm, mm);
+	uprobe_dup_mmap(oldmm, mm);
 	retval = 0;
 out:
 	up_write(&mm->mmap_sem);
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index d3ae4cb..8cf38d6 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -404,6 +404,7 @@ static struct uprobe *uprobes_add(struct inode *inode, loff_t offset)
 	uprobe->inode = inode;
 	uprobe->offset = offset;
 	init_rwsem(&uprobe->consumer_rwsem);
+	INIT_LIST_HEAD(&uprobe->pending_list);
 
 	/* add to uprobes_tree, sorted on inode:offset */
 	cur_uprobe = insert_uprobe(uprobe);
@@ -472,17 +473,32 @@ static bool del_consumer(struct uprobe *uprobe,
 	return ret;
 }
 
-static int __copy_insn(struct address_space *mapping, char *insn,
-			unsigned long nbytes, unsigned long offset)
+static int __copy_insn(struct address_space *mapping,
+		struct vm_area_struct *vma, char *insn,
+		unsigned long nbytes, unsigned long offset)
 {
 	struct page *page;
 	void *vaddr;
 	unsigned long off1;
-	loff_t idx;
+	unsigned long idx;
 
-	idx = offset >> PAGE_CACHE_SHIFT;
+	idx = (unsigned long) (offset >> PAGE_CACHE_SHIFT);
 	off1 = offset &= ~PAGE_MASK;
-	page = grab_cache_page(mapping, (unsigned long)idx);
+	if (vma) {
+		/*
+		 * We get here from uprobe_mmap() -- the case where we
+		 * are trying to copy an instruction from a page that's
+		 * not yet in page cache.
+		 *
+		 * Read page in before copy.
+		 */
+		struct file *filp = vma->vm_file;
+
+		if (!filp)
+			return -EINVAL;
+		page_cache_sync_readahead(mapping, &filp->f_ra, filp, idx, 1);
+	}
+	page = grab_cache_page(mapping, idx);
 	if (!page)
 		return -ENOMEM;
 
@@ -494,7 +510,8 @@ static int __copy_insn(struct address_space *mapping, char *insn,
 	return 0;
 }
 
-static int copy_insn(struct uprobe *uprobe, unsigned long addr)
+static int copy_insn(struct uprobe *uprobe, struct vm_area_struct *vma,
+					unsigned long addr)
 {
 	struct address_space *mapping;
 	int bytes;
@@ -512,12 +529,12 @@ static int copy_insn(struct uprobe *uprobe, unsigned long addr)
 
 	/* Instruction at the page-boundary; copy bytes in second page */
 	if (nbytes < bytes) {
-		if (__copy_insn(mapping, uprobe->insn + nbytes,
+		if (__copy_insn(mapping, vma, uprobe->insn + nbytes,
 				bytes - nbytes, uprobe->offset + nbytes))
 			return -ENOMEM;
 		bytes = nbytes;
 	}
-	return __copy_insn(mapping, uprobe->insn, bytes, uprobe->offset);
+	return __copy_insn(mapping, vma, uprobe->insn, bytes, uprobe->offset);
 }
 
 static struct task_struct *uprobes_get_mm_owner(struct mm_struct *mm)
@@ -532,7 +549,8 @@ static struct task_struct *uprobes_get_mm_owner(struct mm_struct *mm)
 	return tsk;
 }
 
-static int install_uprobe(struct mm_struct *mm, struct uprobe *uprobe)
+static int install_uprobe(struct mm_struct *mm, struct uprobe *uprobe,
+		struct vm_area_struct *vma)
 {
 	struct task_struct *tsk = uprobes_get_mm_owner(mm);
 	int ret;
@@ -541,7 +559,7 @@ static int install_uprobe(struct mm_struct *mm, struct uprobe *uprobe)
 		return -ESRCH;
 
 	if (!uprobe->copy) {
-		ret = copy_insn(uprobe, mm->uprobes_vaddr);
+		ret = copy_insn(uprobe, vma, mm->uprobes_vaddr);
 		if (ret)
 			goto put_return;
 		if (is_bkpt_insn(uprobe->insn)) {
@@ -698,7 +716,7 @@ int register_uprobe(struct inode *inode, loff_t offset,
 	}
 	list_for_each_entry_safe(mm, tmpmm, &try_list, uprobes_list) {
 		down_read(&mm->mmap_sem);
-		ret = install_uprobe(mm, uprobe);
+		ret = install_uprobe(mm, uprobe, NULL);
 
 		if (ret && (ret != -ESRCH || ret != -EEXIST)) {
 			up_read(&mm->mmap_sem);
@@ -833,3 +851,107 @@ put_unlock:
 	mutex_unlock(&uprobes_mutex);
 	put_uprobe(uprobe); /* drop access ref */
 }
+
+static void add_to_temp_list(struct vm_area_struct *vma, struct inode *inode,
+		struct list_head *tmp_list)
+{
+	struct uprobe *uprobe;
+	struct rb_node *n;
+	unsigned long flags;
+
+	n = uprobes_tree.rb_node;
+	spin_lock_irqsave(&treelock, flags);
+	uprobe = __find_uprobe(inode, 0, &n);
+	for (; n; n = rb_next(n)) {
+		uprobe = rb_entry(n, struct uprobe, rb_node);
+		if (match_inode(uprobe, inode, &n)) {
+			list_add(&uprobe->pending_list, tmp_list);
+			continue;
+		}
+		break;
+	}
+	spin_unlock_irqrestore(&treelock, flags);
+}
+
+/*
+ * Called from dup_mmap.
+ * called with mm->mmap_sem and old_mm->mmap_sem acquired.
+ */
+void uprobe_dup_mmap(struct mm_struct *old_mm, struct mm_struct *mm)
+{
+	atomic_set(&old_mm->uprobes_count,
+			atomic_read(&mm->uprobes_count));
+}
+
+/*
+ * Called from mmap_region.
+ * called with mm->mmap_sem acquired.
+ *
+ * Return -ve no if we fail to insert probes and we cannot
+ * bail-out.
+ * Return 0 otherwise. i.e :
+ *	- successful insertion of probes
+ *	- no possible probes to be inserted.
+ *	- insertion of probes failed but we can bail-out.
+ */
+int uprobe_mmap(struct vm_area_struct *vma)
+{
+	struct list_head tmp_list;
+	struct uprobe *uprobe, *u;
+	struct mm_struct *mm;
+	struct inode *inode;
+	unsigned long start;
+	unsigned long pgoff;
+	int ret = 0;
+
+	if (!valid_vma(vma))
+		return ret;	/* Bail-out */
+
+	INIT_LIST_HEAD(&tmp_list);
+
+	mm = vma->vm_mm;
+	inode = vma->vm_file->f_mapping->host;
+	start = vma->vm_start;
+	pgoff = vma->vm_pgoff;
+	__iget(inode);
+
+	up_write(&mm->mmap_sem);
+	mutex_lock(&uprobes_mutex);
+	down_read(&mm->mmap_sem);
+
+	vma = find_vma(mm, start);
+	/* Not the same vma */
+	if (!vma || vma->vm_start != start ||
+			vma->vm_pgoff != pgoff || !valid_vma(vma) ||
+			inode->i_mapping != vma->vm_file->f_mapping)
+		goto mmap_out;
+
+	add_to_temp_list(vma, inode, &tmp_list);
+	list_for_each_entry_safe(uprobe, u, &tmp_list, pending_list) {
+		loff_t vaddr;
+
+		list_del(&uprobe->pending_list);
+		if (ret)
+			continue;
+
+		vaddr = vma->vm_start + uprobe->offset;
+		vaddr -= vma->vm_pgoff << PAGE_SHIFT;
+		if (vaddr > ULONG_MAX)
+			/*
+			 * We cannot have a virtual address that is
+			 * greater than ULONG_MAX
+			 */
+			continue;
+		mm->uprobes_vaddr = (unsigned long)vaddr;
+		ret = install_uprobe(mm, uprobe, vma);
+		if (ret && (ret == -ESRCH || ret == -EEXIST))
+			ret = 0;
+	}
+
+mmap_out:
+	mutex_unlock(&uprobes_mutex);
+	iput(inode);
+	up_read(&mm->mmap_sem);
+	down_write(&mm->mmap_sem);
+	return ret;
+}
diff --git a/mm/mmap.c b/mm/mmap.c
index 2ec8eb5..dcd0308 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -30,6 +30,7 @@
 #include <linux/perf_event.h>
 #include <linux/audit.h>
 #include <linux/khugepaged.h>
+#include <linux/uprobes.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -1366,6 +1367,11 @@ out:
 			mm->locked_vm += (len >> PAGE_SHIFT);
 	} else if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK))
 		make_pages_present(addr, addr + len);
+
+	if (file && uprobe_mmap(vma))
+		/* matching probes but cannot insert */
+		goto unmap_and_free_vma;
+
 	return addr;
 
 unmap_and_free_vma:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
