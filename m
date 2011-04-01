Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 318548D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 10:43:21 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp08.in.ibm.com (8.14.4/8.13.1) with ESMTP id p31DiVje007028
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 19:14:31 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p31EhF3C4325460
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 20:13:15 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p31EhEIF030054
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:43:15 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 01 Apr 2011 20:03:38 +0530
Message-Id: <20110401143338.15455.98645.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v3 2.6.39-rc1-tip 6/26]  6: Uprobes: register/unregister probes.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>


A probe is specified by a file:offset.  While registering, a breakpoint
is inserted for the first consumer, On subsequent probes, the consumer
gets appended to the existing consumers. While unregistering a
breakpoint is removed if the consumer happens to be the last consumer.
All other unregisterations, the consumer is deleted from the list of
consumers.

Probe specifications are maintained in a rb tree. A probe specification
is converted into a uprobe before store in a rb tree.  A uprobe can be
shared by many consumers.

Given a inode, we get a list of mm's that have mapped the inode.
However we want to limit the probes to certain processes/threads.  The
filtering should be at thread level. To limit the probes to a certain
processes/threads, we would want to walk through the list of threads
whose mm member refer to a given mm.

Here are the options that I thought of:
1. Use mm->owner and walk thro the thread_group of mm->owner, siblings
of mm->owner, siblings of parent of mm->owner.  This should be
good list to traverse. Not sure if this is an exhaustive
enough list that all tasks that have a mm set to this mm_struct are
walked through.

2. Install probes on all mm's that have mapped the probes and filter
only at probe hit time.

3. walk thro do_each_thread; while_each_thread; I think this will catch
all tasks that have a mm set to the given mm. However this might
be too heavy esp if mm corresponds to a library.

4. add a list_head element to the mm struct and update the list whenever
the task->mm thread gets updated. This could mean extending the current
mm->owner. However there is some maintainance overhead.

Currently we use the second approach, i.e probe all mm's that have mapped
the probes and filter only at probe hit.

Also would be interested to know if there are ways to call
replace_page without having to take mmap_sem.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/mm_types.h |    5 +
 include/linux/uprobes.h  |   32 +++++
 kernel/uprobes.c         |  280 ++++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 306 insertions(+), 11 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 02aa561..c691096 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -317,6 +317,11 @@ struct mm_struct {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
 #endif
+#ifdef CONFIG_UPROBES
+	unsigned long uprobes_vaddr;
+	struct list_head uprobes_list; /* protected by uprobes_mutex */
+	atomic_t uprobes_count;
+#endif
 };
 
 /* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index bfe2e9e..62036a0 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -31,6 +31,7 @@
  * ARCH_SUPPORTS_UPROBES is not defined.
  */
 typedef u8 uprobe_opcode_t;
+struct uprobe_arch_info	{};		/* arch specific info*/
 #endif /* CONFIG_ARCH_SUPPORTS_UPROBES */
 
 /* Post-execution fixups.  Some architectures may define others. */
@@ -62,6 +63,19 @@ struct uprobe_consumer {
 	struct uprobe_consumer *next;
 };
 
+struct uprobe {
+	struct rb_node		rb_node;	/* node in the rb tree */
+	atomic_t		ref;
+	struct rw_semaphore	consumer_rwsem;
+	struct uprobe_arch_info	arch_info;	/* arch specific info if any */
+	struct uprobe_consumer	*consumers;
+	struct inode		*inode;		/* Also hold a ref to inode */
+	loff_t			offset;
+	u8			insn[MAX_UINSN_BYTES];	/* orig instruction */
+	u16			fixups;
+	int			copy;
+};
+
 /*
  * Most architectures can use the default versions of @read_opcode(),
  * @set_bkpt(), @set_orig_insn(), and @is_bkpt_insn();
@@ -90,4 +104,22 @@ struct uprobe_consumer {
  *	the probed instruction stream.  @tskinfo is as for @pre_xol().
  *	You must provide this function.
  */
+
+#ifdef CONFIG_UPROBES
+extern int register_uprobe(struct inode *inode, loff_t offset,
+				struct uprobe_consumer *consumer);
+extern void unregister_uprobe(struct inode *inode, loff_t offset,
+				struct uprobe_consumer *consumer);
+#else /* CONFIG_UPROBES is not defined */
+static inline int register_uprobe(struct inode *inode, loff_t offset,
+				struct uprobe_consumer *consumer)
+{
+	return -ENOSYS;
+}
+static inline void unregister_uprobe(struct inode *inode, loff_t offset,
+				struct uprobe_consumer *consumer)
+{
+}
+
+#endif /* CONFIG_UPROBES */
 #endif	/* _LINUX_UPROBES_H */
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index f37418b..ff3f15e 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -32,17 +32,6 @@
 #include <linux/uprobes.h>
 #include <linux/rmap.h> /* needed for anon_vma_prepare */
 
-struct uprobe {
-	struct rb_node		rb_node;	/* node in the rb tree */
-	atomic_t		ref;		/* lifetime muck */
-	struct rw_semaphore	consumer_rwsem;
-	struct uprobe_consumer	*consumers;
-	struct inode		*inode;		/* we hold a ref */
-	loff_t			offset;
-	u8			insn[MAX_UINSN_BYTES];
-	u16			fixups;
-};
-
 static bool valid_vma(struct vm_area_struct *vma)
 {
 	if (!vma->vm_file)
@@ -470,3 +459,272 @@ static bool del_consumer(struct uprobe *uprobe,
 	up_write(&uprobe->consumer_rwsem);
 	return ret;
 }
+
+static int install_uprobe(struct mm_struct *mm, struct uprobe *uprobe)
+{
+	int ret = 0;
+
+	/*TODO: install breakpoint */
+	if (!ret)
+		atomic_inc(&mm->uprobes_count);
+	return ret;
+}
+
+static int remove_uprobe(struct mm_struct *mm, struct uprobe *uprobe)
+{
+	int ret = 0;
+
+	/*TODO: remove breakpoint */
+	if (!ret)
+		atomic_dec(&mm->uprobes_count);
+
+	return ret;
+}
+
+static void delete_uprobe(struct mm_struct *mm, struct uprobe *uprobe)
+{
+	down_read(&mm->mmap_sem);
+	remove_uprobe(mm, uprobe);
+	list_del(&mm->uprobes_list);
+	up_read(&mm->mmap_sem);
+	mmput(mm);
+}
+
+/*
+ * There could be threads that have hit the breakpoint and are entering
+ * the notifier code and trying to acquire the treelock. The thread
+ * calling erase_uprobe() that is removing the uprobe from the rb_tree
+ * can race with these threads and might acquire the treelock compared
+ * to some of the breakpoint hit threads. In such a case, the breakpoint
+ * hit threads will not find the uprobe. Finding if a "trap" instruction
+ * was present at the interrupting address is racy. Hence provide some
+ * extra time (by way of synchronize_sched() for breakpoint hit threads
+ * to acquire the treelock before the uprobe is removed from the rbtree.
+ */
+static void erase_uprobe(struct uprobe *uprobe)
+{
+	unsigned long flags;
+
+	synchronize_sched();
+	spin_lock_irqsave(&treelock, flags);
+	rb_erase(&uprobe->rb_node, &uprobes_tree);
+	spin_unlock_irqrestore(&treelock, flags);
+	iput(uprobe->inode);
+}
+
+static DEFINE_MUTEX(uprobes_mutex);
+
+/*
+ * register_uprobe - register a probe
+ * @inode: the file in which the probe has to be placed.
+ * @offset: offset from the start of the file.
+ * @consumer: information on howto handle the probe..
+ *
+ * Apart from the access refcount, register_uprobe() takes a creation
+ * refcount (thro uprobes_add) if and only if this @uprobe is getting
+ * inserted into the rbtree (i.e first consumer for a @inode:@offset
+ * tuple).  Creation refcount stops unregister_uprobe from freeing the
+ * @uprobe even before the register operation is complete. Creation
+ * refcount is released when the last @consumer for the @uprobe
+ * unregisters.
+ *
+ * Return errno if it cannot successully install probes
+ * else return 0 (success)
+ */
+int register_uprobe(struct inode *inode, loff_t offset,
+				struct uprobe_consumer *consumer)
+{
+	struct prio_tree_iter iter;
+	struct list_head try_list, success_list;
+	struct address_space *mapping;
+	struct mm_struct *mm, *tmpmm;
+	struct vm_area_struct *vma;
+	struct uprobe *uprobe;
+	int ret = -1;
+
+	if (!inode || !consumer || consumer->next)
+		return -EINVAL;
+
+	uprobe = uprobes_add(inode, offset);
+	if (!uprobe)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&try_list);
+	INIT_LIST_HEAD(&success_list);
+	mapping = inode->i_mapping;
+
+	mutex_lock(&uprobes_mutex);
+	if (uprobe->consumers) {
+		ret = 0;
+		goto consumers_add;
+	}
+
+	spin_lock(&mapping->i_mmap_lock);
+	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, 0, 0) {
+		loff_t vaddr;
+
+		if (!atomic_inc_not_zero(&vma->vm_mm->mm_users))
+			continue;
+
+		mm = vma->vm_mm;
+		if (!valid_vma(vma)) {
+			mmput(mm);
+			continue;
+		}
+
+		vaddr = vma->vm_start + offset;
+		vaddr -= vma->vm_pgoff << PAGE_SHIFT;
+		if (vaddr > ULONG_MAX) {
+			/*
+			 * We cannot have a virtual address that is
+			 * greater than ULONG_MAX
+			 */
+			mmput(mm);
+			continue;
+		}
+		mm->uprobes_vaddr = (unsigned long) vaddr;
+		list_add(&mm->uprobes_list, &try_list);
+	}
+	spin_unlock(&mapping->i_mmap_lock);
+
+	if (list_empty(&try_list)) {
+		ret = 0;
+		goto consumers_add;
+	}
+	list_for_each_entry_safe(mm, tmpmm, &try_list, uprobes_list) {
+		down_read(&mm->mmap_sem);
+		ret = install_uprobe(mm, uprobe);
+
+		if (ret && (ret != -ESRCH || ret != -EEXIST)) {
+			up_read(&mm->mmap_sem);
+			break;
+		}
+		if (!ret)
+			list_move(&mm->uprobes_list, &success_list);
+		else {
+			/*
+			 * install_uprobe failed as there are no active
+			 * threads for the mm; ignore the error.
+			 */
+			list_del(&mm->uprobes_list);
+			mmput(mm);
+		}
+		up_read(&mm->mmap_sem);
+	}
+
+	if (list_empty(&try_list)) {
+		/*
+		 * All install_uprobes were successful;
+		 * cleanup successful entries.
+		 */
+		ret = 0;
+		list_for_each_entry_safe(mm, tmpmm, &success_list,
+						uprobes_list) {
+			list_del(&mm->uprobes_list);
+			mmput(mm);
+		}
+		goto consumers_add;
+	}
+
+	/*
+	 * Atleast one unsuccessful install_uprobe;
+	 * remove successful probes and cleanup untried entries.
+	 */
+	list_for_each_entry_safe(mm, tmpmm, &success_list, uprobes_list)
+		delete_uprobe(mm, uprobe);
+	list_for_each_entry_safe(mm, tmpmm, &try_list, uprobes_list) {
+		list_del(&mm->uprobes_list);
+		mmput(mm);
+	}
+	erase_uprobe(uprobe);
+	goto put_unlock;
+
+consumers_add:
+	add_consumer(uprobe, consumer);
+
+put_unlock:
+	mutex_unlock(&uprobes_mutex);
+	put_uprobe(uprobe); /* drop access ref */
+	return ret;
+}
+
+/*
+ * unregister_uprobe - unregister a already registered probe.
+ * @inode: the file in which the probe has to be removed.
+ * @offset: offset from the start of the file.
+ * @consumer: identify which probe if multiple probes are colocated.
+ */
+void unregister_uprobe(struct inode *inode, loff_t offset,
+				struct uprobe_consumer *consumer)
+{
+	struct prio_tree_iter iter;
+	struct list_head tmp_list;
+	struct address_space *mapping;
+	struct mm_struct *mm, *tmpmm;
+	struct vm_area_struct *vma;
+	struct uprobe *uprobe;
+
+	if (!inode || !consumer)
+		return;
+
+	uprobe = find_uprobe(inode, offset);
+	if (!uprobe) {
+		printk(KERN_ERR "No uprobe found with inode:offset %p %lld\n",
+				inode, offset);
+		return;
+	}
+
+	if (!del_consumer(uprobe, consumer)) {
+		printk(KERN_ERR "No uprobe found with consumer %p\n",
+				consumer);
+		return;
+	}
+
+	INIT_LIST_HEAD(&tmp_list);
+
+	mapping = inode->i_mapping;
+
+	mutex_lock(&uprobes_mutex);
+	if (uprobe->consumers)
+		goto put_unlock;
+
+	spin_lock(&mapping->i_mmap_lock);
+	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, 0, 0) {
+		if (!atomic_inc_not_zero(&vma->vm_mm->mm_users))
+			continue;
+
+		mm = vma->vm_mm;
+
+		if (!atomic_read(&mm->uprobes_count)) {
+			mmput(mm);
+			continue;
+		}
+
+		if (valid_vma(vma)) {
+			loff_t vaddr;
+
+			vaddr = vma->vm_start + offset;
+			vaddr -= vma->vm_pgoff << PAGE_SHIFT;
+			if (vaddr > ULONG_MAX) {
+				/*
+				 * We cannot have a virtual address that is
+				 * greater than ULONG_MAX
+				 */
+				mmput(mm);
+				continue;
+			}
+			mm->uprobes_vaddr = (unsigned long) vaddr;
+			list_add(&mm->uprobes_list, &tmp_list);
+		} else
+			mmput(mm);
+	}
+	spin_unlock(&mapping->i_mmap_lock);
+	list_for_each_entry_safe(mm, tmpmm, &tmp_list, uprobes_list)
+		delete_uprobe(mm, uprobe);
+
+	erase_uprobe(uprobe);
+
+put_unlock:
+	mutex_unlock(&uprobes_mutex);
+	put_uprobe(uprobe); /* drop access ref */
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
