Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id A5FC16B007D
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 09:06:25 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp08.in.ibm.com (8.14.4/8.13.1) with ESMTP id p57CuUtm028698
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 18:26:30 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p57D6Ixa2826354
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 18:36:18 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p57D6GIp027445
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:06:17 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 07 Jun 2011 18:29:31 +0530
Message-Id: <20110607125931.28590.12362.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v4 3.0-rc2-tip 7/22]  7: uprobes: mmap and fork hooks.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>


Provides hooks in mmap and fork.

On fork, after the new mm is created, we need to set the count of
uprobes.  On mmap, check if the mmap region is an executable page and if
its a executable page, walk through the rbtree and insert actual
breakpoints for already registered probes corresponding to this inode.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/uprobes.h |   14 ++++++
 kernel/fork.c           |    2 +
 kernel/uprobes.c        |  106 +++++++++++++++++++++++++++++++++++++++++++++++
 mm/mmap.c               |    6 +++
 4 files changed, 127 insertions(+), 1 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 4087cc3..fc2f9d2 100644
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
+extern int mmap_uprobe(struct vm_area_struct *vma);
+extern void dup_mmap_uprobe(struct mm_struct *old_mm, struct mm_struct *mm);
 #else /* CONFIG_UPROBES is not defined */
 static inline int register_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer)
@@ -120,6 +125,13 @@ static inline void unregister_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer)
 {
 }
-
+static inline void dup_mmap_uprobe(struct mm_struct *old_mm,
+		struct mm_struct *mm)
+{
+}
+static inline int mmap_uprobe(struct vm_area_struct *vma)
+{
+	return 0;
+}
 #endif /* CONFIG_UPROBES */
 #endif	/* _LINUX_UPROBES_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index 0276c30..f6c7cb1 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -67,6 +67,7 @@
 #include <linux/user-return-notifier.h>
 #include <linux/oom.h>
 #include <linux/khugepaged.h>
+#include <linux/uprobes.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -423,6 +424,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 	}
 	/* a new mm has just been created */
 	arch_dup_mmap(oldmm, mm);
+	dup_mmap_uprobe(oldmm, mm);
 	retval = 0;
 out:
 	up_write(&mm->mmap_sem);
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index 9564a78..93a53c0 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -451,6 +451,7 @@ static struct uprobe *alloc_uprobe(struct inode *inode, loff_t offset)
 	uprobe->inode = inode;
 	uprobe->offset = offset;
 	init_rwsem(&uprobe->consumer_rwsem);
+	INIT_LIST_HEAD(&uprobe->pending_list);
 
 	/* add to uprobes_tree, sorted on inode:offset */
 	cur_uprobe = insert_uprobe(uprobe);
@@ -916,3 +917,108 @@ put_unlock:
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
+	spin_lock_irqsave(&uprobes_treelock, flags);
+	uprobe = __find_uprobe(inode, 0, &n);
+	for (; n; n = rb_next(n)) {
+		uprobe = rb_entry(n, struct uprobe, rb_node);
+		if (uprobe->inode != inode)
+			break;
+		list_add(&uprobe->pending_list, tmp_list);
+		continue;
+	}
+	spin_unlock_irqrestore(&uprobes_treelock, flags);
+}
+
+/*
+ * Called from dup_mmap.
+ * called with mm->mmap_sem and old_mm->mmap_sem acquired.
+ */
+void dup_mmap_uprobe(struct mm_struct *old_mm, struct mm_struct *mm)
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
+int mmap_uprobe(struct vm_area_struct *vma)
+{
+	struct list_head tmp_list;
+	struct uprobe *uprobe, *u;
+	struct mm_struct *mm;
+	struct inode *inode;
+	unsigned long start, pgoff;
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
+		if (vaddr < vma->vm_start || vaddr > vma->vm_end)
+			/* Not in this vma */
+			continue;
+		if (vaddr > TASK_SIZE)
+			/*
+			 * We cannot have a virtual address that is
+			 * greater than TASK_SIZE
+			 */
+			continue;
+		mm->uprobes_vaddr = (unsigned long)vaddr;
+		ret = install_breakpoint(mm, uprobe);
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
index bbdc9af..3ff312f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -30,6 +30,7 @@
 #include <linux/perf_event.h>
 #include <linux/audit.h>
 #include <linux/khugepaged.h>
+#include <linux/uprobes.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -1344,6 +1345,11 @@ out:
 			mm->locked_vm += (len >> PAGE_SHIFT);
 	} else if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK))
 		make_pages_present(addr, addr + len);
+
+	if (file && mmap_uprobe(vma))
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
