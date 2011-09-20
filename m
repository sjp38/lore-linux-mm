Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id E777B9000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 08:14:22 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id p8KCDEne007700
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 22:13:14 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8KCCOZS1302680
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 22:12:24 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8KCEHtA014708
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 22:14:18 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 20 Sep 2011 17:30:40 +0530
Message-Id: <20110920120040.25326.63549.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v5 3.1.0-rc4-tip 4/26]   uprobes: Define hooks for mmap/munmap.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>


If an executable vma is getting mapped, search and insert corresponding
probes. On unmap, make sure the per-mm count is decremented by appropriate
amount.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/mm_types.h |    3 +
 include/linux/uprobes.h  |   12 +++
 kernel/fork.c            |    5 +
 kernel/uprobes.c         |  174 +++++++++++++++++++++++++++++++++++++++++++---
 mm/memory.c              |    4 +
 mm/mmap.c                |    6 ++
 6 files changed, 194 insertions(+), 10 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 774b895..9aeb64f 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -349,6 +349,9 @@ struct mm_struct {
 #ifdef CONFIG_CPUMASK_OFFSTACK
 	struct cpumask cpumask_allocation;
 #endif
+#ifdef CONFIG_UPROBES
+	atomic_t mm_uprobes_count;
+#endif
 };
 
 static inline void mm_init_cpumask(struct mm_struct *mm)
diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 6d5a3fe..b4de058 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -25,6 +25,8 @@
 
 #include <linux/rbtree.h>
 
+struct vm_area_struct;
+
 struct uprobe_consumer {
 	int (*handler)(struct uprobe_consumer *self, struct pt_regs *regs);
 	/*
@@ -40,6 +42,7 @@ struct uprobe {
 	struct rb_node		rb_node;	/* node in the rb tree */
 	atomic_t		ref;
 	struct rw_semaphore	consumer_rwsem;
+	struct list_head	pending_list;
 	struct uprobe_consumer	*consumers;
 	struct inode		*inode;		/* Also hold a ref to inode */
 	loff_t			offset;
@@ -50,6 +53,8 @@ extern int register_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer);
 extern void unregister_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer);
+extern int mmap_uprobe(struct vm_area_struct *vma);
+extern void munmap_uprobe(struct vm_area_struct *vma);
 #else /* CONFIG_UPROBES is not defined */
 static inline int register_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer)
@@ -60,5 +65,12 @@ static inline void unregister_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer)
 {
 }
+static inline int mmap_uprobe(struct vm_area_struct *vma)
+{
+	return 0;
+}
+static inline void munmap_uprobe(struct vm_area_struct *vma)
+{
+}
 #endif /* CONFIG_UPROBES */
 #endif	/* _LINUX_UPROBES_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index 8e6b6f4..7cc0b51 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -66,6 +66,7 @@
 #include <linux/user-return-notifier.h>
 #include <linux/oom.h>
 #include <linux/khugepaged.h>
+#include <linux/uprobes.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -739,6 +740,10 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	mm->pmd_huge_pte = NULL;
 #endif
+#ifdef CONFIG_UPROBES
+	atomic_set(&mm->mm_uprobes_count,
+			atomic_read(&oldmm->mm_uprobes_count));
+#endif
 
 	if (!mm_init(mm, tsk))
 		goto fail_nomem;
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index eeb6ed5..5bc3f90 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -29,6 +29,7 @@
 
 static struct rb_root uprobes_tree = RB_ROOT;
 static DEFINE_SPINLOCK(uprobes_treelock);	/* serialize (un)register */
+static DEFINE_MUTEX(uprobes_mmap_mutex);	/* uprobe->pending_list */
 
 /*
  * Maintain a temporary per vma info that can be used to search if a vma
@@ -58,13 +59,23 @@ static bool valid_vma(struct vm_area_struct *vma)
 	return false;
 }
 
-static int match_uprobe(struct uprobe *l, struct uprobe *r)
+static int match_uprobe(struct uprobe *l, struct uprobe *r, int *match_inode)
 {
+	/*
+	 * if match_inode is non NULL then indicate if the
+	 * inode atleast match.
+	 */
+	if (match_inode)
+		*match_inode = 0;
+
 	if (l->inode < r->inode)
 		return -1;
 	if (l->inode > r->inode)
 		return 1;
 	else {
+		if (match_inode)
+			*match_inode = 1;
+
 		if (l->offset < r->offset)
 			return -1;
 
@@ -75,16 +86,20 @@ static int match_uprobe(struct uprobe *l, struct uprobe *r)
 	return 0;
 }
 
-static struct uprobe *__find_uprobe(struct inode * inode, loff_t offset)
+static struct uprobe *__find_uprobe(struct inode * inode, loff_t offset,
+					struct rb_node **close_match)
 {
 	struct uprobe u = { .inode = inode, .offset = offset };
 	struct rb_node *n = uprobes_tree.rb_node;
 	struct uprobe *uprobe;
-	int match;
+	int match, match_inode;
 
 	while (n) {
 		uprobe = rb_entry(n, struct uprobe, rb_node);
-		match = match_uprobe(&u, uprobe);
+		match = match_uprobe(&u, uprobe, &match_inode);
+		if (close_match && match_inode)
+			*close_match = n;
+
 		if (!match) {
 			atomic_inc(&uprobe->ref);
 			return uprobe;
@@ -108,7 +123,7 @@ static struct uprobe *find_uprobe(struct inode * inode, loff_t offset)
 	unsigned long flags;
 
 	spin_lock_irqsave(&uprobes_treelock, flags);
-	uprobe = __find_uprobe(inode, offset);
+	uprobe = __find_uprobe(inode, offset, NULL);
 	spin_unlock_irqrestore(&uprobes_treelock, flags);
 	return uprobe;
 }
@@ -123,7 +138,7 @@ static struct uprobe *__insert_uprobe(struct uprobe *uprobe)
 	while (*p) {
 		parent = *p;
 		u = rb_entry(parent, struct uprobe, rb_node);
-		match = match_uprobe(uprobe, u);
+		match = match_uprobe(uprobe, u, NULL);
 		if (!match) {
 			atomic_inc(&u->ref);
 			return u;
@@ -179,6 +194,7 @@ static struct uprobe *alloc_uprobe(struct inode *inode, loff_t offset)
 	uprobe->inode = igrab(inode);
 	uprobe->offset = offset;
 	init_rwsem(&uprobe->consumer_rwsem);
+	INIT_LIST_HEAD(&uprobe->pending_list);
 
 	/* add to uprobes_tree, sorted on inode:offset */
 	cur_uprobe = insert_uprobe(uprobe);
@@ -232,15 +248,21 @@ static bool del_consumer(struct uprobe *uprobe,
 	return ret;
 }
 
-static int install_breakpoint(struct mm_struct *mm)
+
+static int install_breakpoint(struct mm_struct *mm, struct uprobe *uprobe)
 {
 	/* Placeholder: Yet to be implemented */
+	if (!uprobe->consumers)
+		return 0;
+
+	atomic_inc(&mm->mm_uprobes_count);
 	return 0;
 }
 
-static void remove_breakpoint(struct mm_struct *mm)
+static void remove_breakpoint(struct mm_struct *mm, struct uprobe *uprobe)
 {
 	/* Placeholder: Yet to be implemented */
+	atomic_dec(&mm->mm_uprobes_count);
 	return;
 }
 
@@ -340,7 +362,7 @@ static int __register_uprobe(struct inode *inode, loff_t offset,
 			mmput(mm);
 			continue;
 		}
-		ret = install_breakpoint(mm);
+		ret = install_breakpoint(mm, uprobe);
 		if (ret && (ret != -ESRCH || ret != -EEXIST)) {
 			up_read(&mm->mmap_sem);
 			mmput(mm);
@@ -382,7 +404,7 @@ static void __unregister_uprobe(struct inode *inode, loff_t offset,
 			mmput(mm);
 			continue;
 		}
-		remove_breakpoint(mm);
+		remove_breakpoint(mm, uprobe);
 		up_read(&mm->mmap_sem);
 		mmput(mm);
 	}
@@ -476,3 +498,135 @@ void unregister_uprobe(struct inode *inode, loff_t offset,
 	put_uprobe(uprobe);
 	iput(inode);
 }
+
+/*
+ * For a given inode, build a list of probes that need to be inserted.
+ */
+static void build_probe_list(struct inode *inode, struct list_head *head)
+{
+	struct uprobe *uprobe;
+	struct rb_node *n;
+	unsigned long flags;
+
+	n = uprobes_tree.rb_node;
+	spin_lock_irqsave(&uprobes_treelock, flags);
+	uprobe = __find_uprobe(inode, 0, &n);
+	/*
+	 * If indeed there is a probe for the inode and with offset zero,
+	 * then lets release its reference. (ref got thro __find_uprobe)
+	 */
+	if (uprobe)
+		put_uprobe(uprobe);
+	for (; n; n = rb_next(n)) {
+		uprobe = rb_entry(n, struct uprobe, rb_node);
+		if (uprobe->inode != inode)
+			break;
+		list_add(&uprobe->pending_list, head);
+		atomic_inc(&uprobe->ref);
+	}
+	spin_unlock_irqrestore(&uprobes_treelock, flags);
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
+ *	- (or) no possible probes to be inserted.
+ *	- (or) insertion of probes failed but we can bail-out.
+ */
+int mmap_uprobe(struct vm_area_struct *vma)
+{
+	struct list_head tmp_list;
+	struct uprobe *uprobe, *u;
+	struct inode *inode;
+	int ret = 0;
+
+	if (!valid_vma(vma))
+		return ret;	/* Bail-out */
+
+	inode = igrab(vma->vm_file->f_mapping->host);
+	if (!inode)
+		return ret;
+
+	INIT_LIST_HEAD(&tmp_list);
+	mutex_lock(&uprobes_mmap_mutex);
+	build_probe_list(inode, &tmp_list);
+	list_for_each_entry_safe(uprobe, u, &tmp_list, pending_list) {
+		loff_t vaddr;
+
+		list_del(&uprobe->pending_list);
+		if (!ret && uprobe->consumers) {
+			vaddr = vma->vm_start + uprobe->offset;
+			vaddr -= vma->vm_pgoff << PAGE_SHIFT;
+			if (vaddr < vma->vm_start || vaddr >= vma->vm_end)
+				continue;
+			ret = install_breakpoint(vma->vm_mm, uprobe);
+
+			if (ret && (ret == -ESRCH || ret == -EEXIST))
+				ret = 0;
+		}
+		put_uprobe(uprobe);
+	}
+
+	mutex_unlock(&uprobes_mmap_mutex);
+	iput(inode);
+	return ret;
+}
+
+static void dec_mm_uprobes_count(struct vm_area_struct *vma,
+		struct inode *inode)
+{
+	struct uprobe *uprobe;
+	struct rb_node *n;
+	unsigned long flags;
+
+	n = uprobes_tree.rb_node;
+	spin_lock_irqsave(&uprobes_treelock, flags);
+	uprobe = __find_uprobe(inode, 0, &n);
+
+	/*
+	 * If indeed there is a probe for the inode and with offset zero,
+	 * then lets release its reference. (ref got thro __find_uprobe)
+	 */
+	if (uprobe)
+		put_uprobe(uprobe);
+	for (; n; n = rb_next(n)) {
+		loff_t vaddr;
+
+		uprobe = rb_entry(n, struct uprobe, rb_node);
+		if (uprobe->inode != inode)
+			break;
+		vaddr = vma->vm_start + uprobe->offset;
+		vaddr -= vma->vm_pgoff << PAGE_SHIFT;
+		if (vaddr < vma->vm_start || vaddr >= vma->vm_end)
+			continue;
+		atomic_dec(&vma->vm_mm->mm_uprobes_count);
+	}
+	spin_unlock_irqrestore(&uprobes_treelock, flags);
+}
+
+/*
+ * Called in context of a munmap of a vma.
+ */
+void munmap_uprobe(struct vm_area_struct *vma)
+{
+	struct inode *inode;
+
+	if (!valid_vma(vma))
+		return;		/* Bail-out */
+
+	if (!atomic_read(&vma->vm_mm->mm_uprobes_count))
+		return;
+
+	inode = igrab(vma->vm_file->f_mapping->host);
+	if (!inode)
+		return;
+
+	dec_mm_uprobes_count(vma, inode);
+	iput(inode);
+	return;
+}
diff --git a/mm/memory.c b/mm/memory.c
index a56e3ba..a65fd1f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -57,6 +57,7 @@
 #include <linux/swapops.h>
 #include <linux/elf.h>
 #include <linux/gfp.h>
+#include <linux/uprobes.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -1337,6 +1338,9 @@ unsigned long unmap_vmas(struct mmu_gather *tlb,
 		if (unlikely(is_pfn_mapping(vma)))
 			untrack_pfn_vma(vma, 0, 0);
 
+		if (vma->vm_file)
+			munmap_uprobe(vma);
+
 		while (start != end) {
 			if (unlikely(is_vm_hugetlb_page(vma))) {
 				/*
diff --git a/mm/mmap.c b/mm/mmap.c
index a65efd4..f51d482 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -30,6 +30,7 @@
 #include <linux/perf_event.h>
 #include <linux/audit.h>
 #include <linux/khugepaged.h>
+#include <linux/uprobes.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -1329,6 +1330,11 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
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
