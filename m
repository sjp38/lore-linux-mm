Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 49F9A6B0072
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 06:33:41 -0500 (EST)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 18 Nov 2011 17:03:30 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAIBXPOA4595880
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 17:03:25 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAIBXOVj002430
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 22:33:25 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 18 Nov 2011 16:37:23 +0530
Message-Id: <20111118110723.10512.66282.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v7 3.2-rc2 4/30] uprobes: Define hooks for mmap/munmap.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>


If an executable vma is getting mapped, search and insert corresponding
probes. On unmap, make sure the probes count is decremented by appropriate
amount.

On process creation, make sure the probes count in the child is set
correctly.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---

Changelog: (Since v5)
- use hash locks.
- Handle mremap.
- while forking, handle vma's that have VM_DONTCOPY.
- while forking, handle race of new breakpoints being inserted / removed
  in the parent process.
- Introduce find_least_offset_node() instead of close match logic in
  find_uprobe
- munmap now reuses build_probe_list instead of dec_mm_uprobes_count.

 include/linux/mm_types.h |    3 +
 include/linux/uprobes.h  |   12 +++
 kernel/fork.c            |    7 ++
 kernel/uprobes.c         |  188 ++++++++++++++++++++++++++++++++++++++++++++--
 mm/mmap.c                |   33 ++++++++
 5 files changed, 233 insertions(+), 10 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 5b42f1b..544a0b6 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -389,6 +389,9 @@ struct mm_struct {
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
index ba0d172..c8c287a 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -66,6 +66,7 @@
 #include <linux/user-return-notifier.h>
 #include <linux/oom.h>
 #include <linux/khugepaged.h>
+#include <linux/uprobes.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -421,6 +422,9 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 
 		if (retval)
 			goto out;
+
+		if (file && mmap_uprobe(tmp))
+			goto out;
 	}
 	/* a new mm has just been created */
 	arch_dup_mmap(oldmm, mm);
@@ -738,6 +742,9 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	mm->pmd_huge_pte = NULL;
 #endif
+#ifdef CONFIG_UPROBES
+	atomic_set(&mm->mm_uprobes_count, 0);
+#endif
 
 	if (!mm_init(mm, tsk))
 		goto fail_nomem;
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index 70ab372..1baae40 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -36,6 +36,18 @@ static struct mutex uprobes_mutex[UPROBES_HASH_SZ];
 #define uprobes_hash(v)	(&uprobes_mutex[((unsigned long)(v)) %\
 						UPROBES_HASH_SZ])
 
+/* serialize uprobe->pending_list */
+static struct mutex uprobes_mmap_mutex[UPROBES_HASH_SZ];
+#define uprobes_mmap_hash(v)	(&uprobes_mmap_mutex[((unsigned long)(v)) %\
+						UPROBES_HASH_SZ])
+
+/*
+ * uprobe_events allows us to skip the mmap_uprobe if there are no uprobe
+ * events active at this time.  Probably a fine grained per inode count is
+ * better?
+ */
+static atomic_t uprobe_events = ATOMIC_INIT(0);
+
 /*
  * Maintain a temporary per vma info that can be used to search if a vma
  * has already been handled. This structure is introduced since extending
@@ -105,7 +117,6 @@ static struct uprobe *__find_uprobe(struct inode *inode, loff_t offset)
 			n = n->rb_left;
 		else
 			n = n->rb_right;
-
 	}
 	return NULL;
 }
@@ -191,6 +202,7 @@ static struct uprobe *alloc_uprobe(struct inode *inode, loff_t offset)
 	uprobe->inode = igrab(inode);
 	uprobe->offset = offset;
 	init_rwsem(&uprobe->consumer_rwsem);
+	INIT_LIST_HEAD(&uprobe->pending_list);
 
 	/* add to uprobes_tree, sorted on inode:offset */
 	cur_uprobe = insert_uprobe(uprobe);
@@ -200,7 +212,8 @@ static struct uprobe *alloc_uprobe(struct inode *inode, loff_t offset)
 		kfree(uprobe);
 		uprobe = cur_uprobe;
 		iput(inode);
-	}
+	} else
+		atomic_inc(&uprobe_events);
 	return uprobe;
 }
 
@@ -238,15 +251,24 @@ static bool del_consumer(struct uprobe *uprobe,
 	return ret;
 }
 
-static int install_breakpoint(struct mm_struct *mm)
+static int install_breakpoint(struct mm_struct *mm, struct uprobe *uprobe)
 {
-	/* Placeholder: Yet to be implemented */
+	/*
+	 * Probe is to be deleted;
+	 * Dont know if somebody already inserted the probe;
+	 * behave as if probe already exists.
+	 */
+	if (!uprobe->consumers)
+		return -EEXIST;
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
 
@@ -259,6 +281,7 @@ static void delete_uprobe(struct uprobe *uprobe)
 	spin_unlock_irqrestore(&uprobes_treelock, flags);
 	iput(uprobe->inode);
 	put_uprobe(uprobe);
+	atomic_dec(&uprobe_events);
 }
 
 static struct vma_info *__find_next_vma_info(struct list_head *head,
@@ -362,7 +385,7 @@ static int __register_uprobe(struct inode *inode, loff_t offset,
 			mmput(mm);
 			continue;
 		}
-		ret = install_breakpoint(mm);
+		ret = install_breakpoint(mm, uprobe);
 		up_read(&mm->mmap_sem);
 		mmput(mm);
 		if (ret && ret == -EEXIST)
@@ -413,7 +436,7 @@ static void __unregister_uprobe(struct inode *inode, loff_t offset,
 			mmput(mm);
 			continue;
 		}
-		remove_breakpoint(mm);
+		remove_breakpoint(mm, uprobe);
 		up_read(&mm->mmap_sem);
 		mmput(mm);
 	}
@@ -514,13 +537,160 @@ void unregister_uprobe(struct inode *inode, loff_t offset,
 		iput(inode);
 }
 
+/*
+ * Of all the nodes that correspond to the given inode, return the node
+ * with the least offset.
+ */
+static struct rb_node *find_least_offset_node(struct inode *inode)
+{
+	struct uprobe u = { .inode = inode, .offset = 0};
+	struct rb_node *n = uprobes_tree.rb_node;
+	struct rb_node *close_node = NULL;
+	struct uprobe *uprobe;
+	int match;
+
+	while (n) {
+		uprobe = rb_entry(n, struct uprobe, rb_node);
+		match = match_uprobe(&u, uprobe);
+		if (uprobe->inode == inode)
+			close_node = n;
+
+		if (!match)
+			return close_node;
+
+		if (match < 0)
+			n = n->rb_left;
+		else
+			n = n->rb_right;
+	}
+	return close_node;
+}
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
+	spin_lock_irqsave(&uprobes_treelock, flags);
+	n = find_least_offset_node(inode);
+	for (; n; n = rb_next(n)) {
+		uprobe = rb_entry(n, struct uprobe, rb_node);
+		if (uprobe->inode != inode)
+			break;
+
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
+	int ret = 0, count = 0;
+
+	if (!atomic_read(&uprobe_events) || !valid_vma(vma, true))
+		return ret;	/* Bail-out */
+
+	inode = igrab(vma->vm_file->f_mapping->host);
+	if (!inode)
+		return ret;
+
+	INIT_LIST_HEAD(&tmp_list);
+	mutex_lock(uprobes_mmap_hash(inode));
+	build_probe_list(inode, &tmp_list);
+	list_for_each_entry_safe(uprobe, u, &tmp_list, pending_list) {
+		loff_t vaddr;
+
+		list_del(&uprobe->pending_list);
+		if (!ret) {
+			vaddr = vma->vm_start + uprobe->offset;
+			vaddr -= vma->vm_pgoff << PAGE_SHIFT;
+			if (vaddr < vma->vm_start || vaddr >= vma->vm_end) {
+				put_uprobe(uprobe);
+				continue;
+			}
+			ret = install_breakpoint(vma->vm_mm, uprobe);
+			if (ret == -EEXIST) {
+				atomic_inc(&vma->vm_mm->mm_uprobes_count);
+				ret = 0;
+			}
+			if (!ret)
+				count++;
+		}
+		put_uprobe(uprobe);
+	}
+
+	mutex_unlock(uprobes_mmap_hash(inode));
+	iput(inode);
+	if (ret)
+		atomic_sub(count, &vma->vm_mm->mm_uprobes_count);
+
+	return ret;
+}
+
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
+	inode = igrab(vma->vm_file->f_mapping->host);
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
+		vaddr = vma->vm_start + uprobe->offset;
+		vaddr -= vma->vm_pgoff << PAGE_SHIFT;
+		if (vaddr >= vma->vm_start && vaddr < vma->vm_end)
+			atomic_dec(&vma->vm_mm->mm_uprobes_count);
+		put_uprobe(uprobe);
+	}
+	mutex_unlock(uprobes_mmap_hash(inode));
+	iput(inode);
+	return;
+}
+
 static int __init init_uprobes(void)
 {
 	int i;
 
-	for (i = 0; i < UPROBES_HASH_SZ; i++)
+	for (i = 0; i < UPROBES_HASH_SZ; i++) {
 		mutex_init(&uprobes_mutex[i]);
-
+		mutex_init(&uprobes_mmap_mutex[i]);
+	}
 	return 0;
 }
 
diff --git a/mm/mmap.c b/mm/mmap.c
index eae90af..83813fa 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -30,6 +30,7 @@
 #include <linux/perf_event.h>
 #include <linux/audit.h>
 #include <linux/khugepaged.h>
+#include <linux/uprobes.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -217,6 +218,7 @@ void unlink_file_vma(struct vm_area_struct *vma)
 		mutex_lock(&mapping->i_mmap_mutex);
 		__remove_shared_vm_struct(vma, file, mapping);
 		mutex_unlock(&mapping->i_mmap_mutex);
+		munmap_uprobe(vma);
 	}
 }
 
@@ -545,8 +547,14 @@ again:			remove_next = 1 + (end > next->vm_end);
 
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
@@ -616,8 +624,16 @@ again:			remove_next = 1 + (end > next->vm_end);
 	if (mapping)
 		mutex_unlock(&mapping->i_mmap_mutex);
 
+	if (root) {
+		mmap_uprobe(vma);
+
+		if (adjust_next)
+			mmap_uprobe(next);
+	}
+
 	if (remove_next) {
 		if (file) {
+			munmap_uprobe(next);
 			fput(file);
 			if (next->vm_flags & VM_EXECUTABLE)
 				removed_exe_file_vma(mm);
@@ -637,6 +653,8 @@ again:			remove_next = 1 + (end > next->vm_end);
 			goto again;
 		}
 	}
+	if (insert && file)
+		mmap_uprobe(insert);
 
 	validate_mm(mm);
 
@@ -1329,6 +1347,11 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
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
@@ -2305,6 +2328,10 @@ int insert_vm_struct(struct mm_struct * mm, struct vm_area_struct * vma)
 	if ((vma->vm_flags & VM_ACCOUNT) &&
 	     security_vm_enough_memory_mm(mm, vma_pages(vma)))
 		return -ENOMEM;
+
+	if (vma->vm_file && mmap_uprobe(vma))
+		return -EINVAL;
+
 	vma_link(mm, vma, prev, rb_link, rb_parent);
 	return 0;
 }
@@ -2356,6 +2383,10 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 			new_vma->vm_pgoff = pgoff;
 			if (new_vma->vm_file) {
 				get_file(new_vma->vm_file);
+
+				if (mmap_uprobe(new_vma))
+					goto out_free_mempol;
+
 				if (vma->vm_flags & VM_EXECUTABLE)
 					added_exe_file_vma(mm);
 			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
