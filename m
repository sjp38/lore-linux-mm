Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7ECE99000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 08:14:09 -0400 (EDT)
Received: from /spool/local
	by au.ibm.com with XMail ESMTP
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 20 Sep 2011 13:10:16 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8KCCA1s1134764
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 22:12:10 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8KCE0D1009382
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 22:14:02 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 20 Sep 2011 17:30:22 +0530
Message-Id: <20110920120022.25326.35868.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v5 3.1.0-rc4-tip 3/26]   Uprobes: register/unregister probes.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>


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

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 arch/Kconfig            |    9 ++
 include/linux/uprobes.h |   16 +++
 kernel/Makefile         |    1 
 kernel/uprobes.c        |  263 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 289 insertions(+), 0 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 4b0669c..dedd489 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -61,6 +61,15 @@ config OPTPROBES
 	depends on KPROBES && HAVE_OPTPROBES
 	depends on !PREEMPT
 
+config UPROBES
+	bool "User-space probes (EXPERIMENTAL)"
+	help
+	  Uprobes enables kernel subsystems to establish probepoints
+	  in user applications and execute handler functions when
+	  the probepoints are hit.
+
+	  If in doubt, say "N".
+
 config HAVE_EFFICIENT_UNALIGNED_ACCESS
 	bool
 	help
diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index bf31f7c..6d5a3fe 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -45,4 +45,20 @@ struct uprobe {
 	loff_t			offset;
 };
 
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
+#endif /* CONFIG_UPROBES */
 #endif	/* _LINUX_UPROBES_H */
diff --git a/kernel/Makefile b/kernel/Makefile
index eca595e..aa810c8 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -108,6 +108,7 @@ obj-$(CONFIG_USER_RETURN_NOTIFIER) += user-return-notifier.o
 obj-$(CONFIG_PADATA) += padata.o
 obj-$(CONFIG_CRASH_DUMP) += crash_dump.o
 obj-$(CONFIG_JUMP_LABEL) += jump_label.o
+obj-$(CONFIG_UPROBES) += uprobes.o
 
 ifneq ($(CONFIG_SCHED_OMIT_FRAME_POINTER),y)
 # According to Alan Modra <alan@linuxcare.com.au>, the -fno-omit-frame-pointer is
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index ba9fd55..eeb6ed5 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -24,11 +24,40 @@
 #include <linux/kernel.h>
 #include <linux/highmem.h>
 #include <linux/slab.h>
+#include <linux/sched.h>
 #include <linux/uprobes.h>
 
 static struct rb_root uprobes_tree = RB_ROOT;
 static DEFINE_SPINLOCK(uprobes_treelock);	/* serialize (un)register */
 
+/*
+ * Maintain a temporary per vma info that can be used to search if a vma
+ * has already been handled. This structure is introduced since extending
+ * vm_area_struct wasnt recommended.
+ */
+struct vma_info {
+	struct list_head probe_list;
+	struct mm_struct *mm;
+	loff_t vaddr;
+};
+
+/*
+ * valid_vma: Verify if the specified vma is an executable vma
+ *	- Return 1 if the specified virtual address is in an
+ *	  executable vma.
+ */
+static bool valid_vma(struct vm_area_struct *vma)
+{
+	if (!vma->vm_file)
+		return false;
+
+	if ((vma->vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)) ==
+						(VM_READ|VM_EXEC))
+		return true;
+
+	return false;
+}
+
 static int match_uprobe(struct uprobe *l, struct uprobe *r)
 {
 	if (l->inode < r->inode)
@@ -203,6 +232,18 @@ static bool del_consumer(struct uprobe *uprobe,
 	return ret;
 }
 
+static int install_breakpoint(struct mm_struct *mm)
+{
+	/* Placeholder: Yet to be implemented */
+	return 0;
+}
+
+static void remove_breakpoint(struct mm_struct *mm)
+{
+	/* Placeholder: Yet to be implemented */
+	return;
+}
+
 static void delete_uprobe(struct uprobe *uprobe)
 {
 	unsigned long flags;
@@ -213,3 +254,225 @@ static void delete_uprobe(struct uprobe *uprobe)
 	put_uprobe(uprobe);
 	iput(uprobe->inode);
 }
+
+static struct vma_info *__find_next_vma_info(struct list_head *head,
+			loff_t offset, struct address_space *mapping,
+			struct vma_info *vi)
+{
+	struct prio_tree_iter iter;
+	struct vm_area_struct *vma;
+	struct vma_info *tmpvi;
+	loff_t vaddr;
+	unsigned long pgoff = offset >> PAGE_SHIFT;
+	int existing_vma;
+
+	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+		if (!vma || !valid_vma(vma))
+			return NULL;
+
+		existing_vma = 0;
+		vaddr = vma->vm_start + offset;
+		vaddr -= vma->vm_pgoff << PAGE_SHIFT;
+		list_for_each_entry(tmpvi, head, probe_list) {
+			if (tmpvi->mm == vma->vm_mm && tmpvi->vaddr == vaddr) {
+				existing_vma = 1;
+				break;
+			}
+		}
+		if (!existing_vma &&
+				atomic_inc_not_zero(&vma->vm_mm->mm_users)) {
+			vi->mm = vma->vm_mm;
+			vi->vaddr = vaddr;
+			list_add(&vi->probe_list, head);
+			return vi;
+		}
+	}
+	return NULL;
+}
+
+/*
+ * Iterate in the rmap prio tree  and find a vma where a probe has not
+ * yet been inserted.
+ */
+static struct vma_info *find_next_vma_info(struct list_head *head,
+			loff_t offset, struct address_space *mapping)
+{
+	struct vma_info *vi, *retvi;
+	vi = kzalloc(sizeof(struct vma_info), GFP_KERNEL);
+	if (!vi)
+		return ERR_PTR(-ENOMEM);
+
+	INIT_LIST_HEAD(&vi->probe_list);
+	mutex_lock(&mapping->i_mmap_mutex);
+	retvi = __find_next_vma_info(head, offset, mapping, vi);
+	mutex_unlock(&mapping->i_mmap_mutex);
+
+	if (!retvi)
+		kfree(vi);
+	return retvi;
+}
+
+static int __register_uprobe(struct inode *inode, loff_t offset,
+				struct uprobe *uprobe)
+{
+	struct list_head try_list;
+	struct vm_area_struct *vma;
+	struct address_space *mapping;
+	struct vma_info *vi, *tmpvi;
+	struct mm_struct *mm;
+	int ret = 0;
+
+	mapping = inode->i_mapping;
+	INIT_LIST_HEAD(&try_list);
+	while ((vi = find_next_vma_info(&try_list, offset,
+							mapping)) != NULL) {
+		if (IS_ERR(vi)) {
+			ret = -ENOMEM;
+			break;
+		}
+		mm = vi->mm;
+		down_read(&mm->mmap_sem);
+		vma = find_vma(mm, (unsigned long) vi->vaddr);
+		if (!vma || !valid_vma(vma)) {
+			list_del(&vi->probe_list);
+			kfree(vi);
+			up_read(&mm->mmap_sem);
+			mmput(mm);
+			continue;
+		}
+		ret = install_breakpoint(mm);
+		if (ret && (ret != -ESRCH || ret != -EEXIST)) {
+			up_read(&mm->mmap_sem);
+			mmput(mm);
+			break;
+		}
+		ret = 0;
+		up_read(&mm->mmap_sem);
+		mmput(mm);
+	}
+	list_for_each_entry_safe(vi, tmpvi, &try_list, probe_list) {
+		list_del(&vi->probe_list);
+		kfree(vi);
+	}
+	return ret;
+}
+
+static void __unregister_uprobe(struct inode *inode, loff_t offset,
+						struct uprobe *uprobe)
+{
+	struct list_head try_list;
+	struct address_space *mapping;
+	struct vma_info *vi, *tmpvi;
+	struct vm_area_struct *vma;
+	struct mm_struct *mm;
+
+	mapping = inode->i_mapping;
+	INIT_LIST_HEAD(&try_list);
+	while ((vi = find_next_vma_info(&try_list, offset,
+							mapping)) != NULL) {
+		if (IS_ERR(vi))
+			break;
+		mm = vi->mm;
+		down_read(&mm->mmap_sem);
+		vma = find_vma(mm, (unsigned long) vi->vaddr);
+		if (!vma || !valid_vma(vma)) {
+			list_del(&vi->probe_list);
+			kfree(vi);
+			up_read(&mm->mmap_sem);
+			mmput(mm);
+			continue;
+		}
+		remove_breakpoint(mm);
+		up_read(&mm->mmap_sem);
+		mmput(mm);
+	}
+
+	list_for_each_entry_safe(vi, tmpvi, &try_list, probe_list) {
+		list_del(&vi->probe_list);
+		kfree(vi);
+	}
+	delete_uprobe(uprobe);
+}
+
+/*
+ * register_uprobe - register a probe
+ * @inode: the file in which the probe has to be placed.
+ * @offset: offset from the start of the file.
+ * @consumer: information on howto handle the probe..
+ *
+ * Apart from the access refcount, register_uprobe() takes a creation
+ * refcount (thro alloc_uprobe) if and only if this @uprobe is getting
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
+	struct uprobe *uprobe;
+	int ret = 0;
+
+	inode = igrab(inode);
+	if (!inode || !consumer || consumer->next)
+		return -EINVAL;
+
+	if (offset > inode->i_size)
+		return -EINVAL;
+
+	mutex_lock(&inode->i_mutex);
+	uprobe = alloc_uprobe(inode, offset);
+	if (!uprobe)
+		return -ENOMEM;
+
+	if (!add_consumer(uprobe, consumer)) {
+		ret = __register_uprobe(inode, offset, uprobe);
+		if (ret)
+			__unregister_uprobe(inode, offset, uprobe);
+	}
+
+	mutex_unlock(&inode->i_mutex);
+	put_uprobe(uprobe);
+	iput(inode);
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
+	struct uprobe *uprobe;
+
+	inode = igrab(inode);
+	if (!inode || !consumer)
+		return;
+
+	if (offset > inode->i_size)
+		return;
+
+	uprobe = find_uprobe(inode, offset);
+	if (!uprobe)
+		return;
+
+	if (!del_consumer(uprobe, consumer)) {
+		put_uprobe(uprobe);
+		return;
+	}
+
+	mutex_lock(&inode->i_mutex);
+	if (!uprobe->consumers)
+		__unregister_uprobe(inode, offset, uprobe);
+
+	mutex_unlock(&inode->i_mutex);
+	put_uprobe(uprobe);
+	iput(inode);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
