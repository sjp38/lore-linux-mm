Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 58C538D003E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 09:40:52 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp05.au.ibm.com (8.14.4/8.13.1) with ESMTP id p2EDYx58004021
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 00:34:59 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2EDebrf2535570
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 00:40:37 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2EDeZIY031521
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 00:40:37 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Mon, 14 Mar 2011 19:04:54 +0530
Message-Id: <20110314133454.27435.81020.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v2 2.6.38-rc8-tip 5/20]  5: Uprobes: register/unregister probes.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>


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
 include/linux/uprobes.h  |   32 ++++++++
 kernel/uprobes.c         |  195 +++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 221 insertions(+), 11 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 26bc4e2..96e4a77 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -315,6 +315,11 @@ struct mm_struct {
 #endif
 	/* How many tasks sharing this mm are OOM_DISABLE */
 	atomic_t oom_disable_count;
+#ifdef CONFIG_UPROBES
+	unsigned long uprobes_vaddr;
+	struct list_head uprobes_list;
+	atomic_t uprobes_count;
+#endif
 };
 
 /* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index f422bc6..8654a06 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -31,6 +31,7 @@
  * ARCH_SUPPORTS_UPROBES is not defined.
  */
 typedef u8 uprobe_opcode_t;
+struct uprobe_arch_info	{};		/* arch specific info*/
 
 /* Post-execution fixups.  Some architectures may define others. */
 #endif /* CONFIG_ARCH_SUPPORTS_UPROBES */
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
@@ -79,4 +93,22 @@ struct uprobe_consumer {
  *	You may modify @user_bkpt->insn (e.g., the x86_64 port does this
  *	for rip-relative instructions).
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
index 6e692a8..4dbb90f 100644
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
 static int valid_vma(struct vm_area_struct *vma)
 {
 	if (!vma->vm_file)
@@ -445,3 +434,187 @@ static int del_consumer(struct uprobe *uprobe,
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
+/* Returns 0 if it can install one probe */
+int register_uprobe(struct inode *inode, loff_t offset,
+				struct uprobe_consumer *consumer)
+{
+	struct prio_tree_iter iter;
+	struct list_head tmp_list;
+	struct address_space *mapping;
+	struct mm_struct *mm, *tmpmm;
+	struct vm_area_struct *vma;
+	struct uprobe *uprobe;
+	int ret = -1;
+
+	if (!inode || !consumer || consumer->next)
+		return -EINVAL;
+	uprobe = uprobes_add(inode, offset);
+	INIT_LIST_HEAD(&tmp_list);
+
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
+		list_add(&mm->uprobes_list, &tmp_list);
+	}
+	spin_unlock(&mapping->i_mmap_lock);
+
+	if (list_empty(&tmp_list)) {
+		ret = 0;
+		goto consumers_add;
+	}
+	list_for_each_entry_safe(mm, tmpmm, &tmp_list, uprobes_list) {
+		down_read(&mm->mmap_sem);
+		if (!install_uprobe(mm, uprobe))
+			ret = 0;
+		list_del(&mm->uprobes_list);
+		up_read(&mm->mmap_sem);
+		mmput(mm);
+	}
+
+consumers_add:
+	add_consumer(uprobe, consumer);
+	mutex_unlock(&uprobes_mutex);
+	put_uprobe(uprobe);
+	return ret;
+}
+
+void unregister_uprobe(struct inode *inode, loff_t offset,
+				struct uprobe_consumer *consumer)
+{
+	struct prio_tree_iter iter;
+	struct list_head tmp_list;
+	struct address_space *mapping;
+	struct mm_struct *mm, *tmpmm;
+	struct vm_area_struct *vma;
+	struct uprobe *uprobe;
+	unsigned long flags;
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
+	list_for_each_entry_safe(mm, tmpmm, &tmp_list, uprobes_list) {
+		down_read(&mm->mmap_sem);
+		remove_uprobe(mm, uprobe);
+		list_del(&mm->uprobes_list);
+		up_read(&mm->mmap_sem);
+		mmput(mm);
+	}
+
+	/*
+	 * There could be other threads that could be spinning on
+	 * treelock; some of these threads could be interested in this
+	 * uprobe.  Give these threads a chance to run.
+	 */
+	synchronize_sched();
+	spin_lock_irqsave(&treelock, flags);
+	rb_erase(&uprobe->rb_node, &uprobes_tree);
+	spin_unlock_irqrestore(&treelock, flags);
+	iput(uprobe->inode);
+
+put_unlock:
+	mutex_unlock(&uprobes_mutex);
+	put_uprobe(uprobe);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
