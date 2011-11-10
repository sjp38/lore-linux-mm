Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B64156B006C
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 14:03:17 -0500 (EST)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp07.au.ibm.com (8.14.4/8.13.1) with ESMTP id pAAJ30Eo017729
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 06:03:00 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAAJ2vpE2797658
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 06:03:00 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAAJ2tJW014639
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 06:02:56 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 11 Nov 2011 00:07:56 +0530
Message-Id: <20111110183756.11361.63109.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20111110183725.11361.57827.sendpatchset@srdronam.in.ibm.com>
References: <20111110183725.11361.57827.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v6 3.2-rc1 3/28]   Uprobes: register/unregister probes.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>


A probe is specified by a file:offset. Probe specifications are maintained
in a rb tree. A uprobe can be shared by many consumers.  While registering
a probe, a breakpoint is inserted for the first consumer, On subsequent
probes, the consumer gets appended to the existing list of consumers. While
unregistering a probe, breakpoint is removed if and only if the consumer
happens to be the only remaining consumer for the probe.  All other
unregisterations, the consumer is removed from the list of consumers.

Given a inode, we get a list of mm's that have mapped the inode. Do the
actual registration if mm maps the page where a probe needs to be
inserted/removed.

We use a temporary list to walk thro the vmas that map the inode.
- The number of maps that map the inode, is not known before we walk
  the rmap and keeps changing.
- extending vm_area_struct wasnt recommended.
- There can be more than one maps of the inode in the same mm.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---

Changelog: (Since v5)
1. Use i_size_read(inode) instead of inode->i_size.
2. Ensure uprobe->consumers is NULL, before __unregister_uprobe() is
   called.
3. remove restriction while unregistering.
4. Earlier code leaked inode references under some conditions while
   registering/unregistering.
5. continue the vma-rmap walk even if the intermediate vma doesnt
   meet the requirements.
6. validate the vma found by find_vma before inserting/removing the
   breakpoint
7. call del_consumer under mutex_lock.

 arch/Kconfig            |    9 +
 include/linux/uprobes.h |   16 ++
 kernel/Makefile         |    1 
 kernel/uprobes.c        |  323 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 349 insertions(+), 0 deletions(-)

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
index e898c5b..9fb670d 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -109,6 +109,7 @@ obj-$(CONFIG_USER_RETURN_NOTIFIER) += user-return-notifier.o
 obj-$(CONFIG_PADATA) += padata.o
 obj-$(CONFIG_CRASH_DUMP) += crash_dump.o
 obj-$(CONFIG_JUMP_LABEL) += jump_label.o
+obj-$(CONFIG_UPROBES) += uprobes.o
 
 ifneq ($(CONFIG_SCHED_OMIT_FRAME_POINTER),y)
 # According to Alan Modra <alan@linuxcare.com.au>, the -fno-omit-frame-pointer is
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index 2c92b9a..70ab372 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -24,11 +24,52 @@
 #include <linux/kernel.h>
 #include <linux/highmem.h>
 #include <linux/slab.h>
+#include <linux/sched.h>
 #include <linux/uprobes.h>
 
 static struct rb_root uprobes_tree = RB_ROOT;
 static DEFINE_SPINLOCK(uprobes_treelock);	/* serialize rbtree access */
 
+#define UPROBES_HASH_SZ	13
+/* serialize (un)register */
+static struct mutex uprobes_mutex[UPROBES_HASH_SZ];
+#define uprobes_hash(v)	(&uprobes_mutex[((unsigned long)(v)) %\
+						UPROBES_HASH_SZ])
+
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
+ * Relax restrictions while unregistering: vm_flags might have
+ * changed after breakpoint was inserted.
+ *	- is_reg: indicates if we are in register context.
+ *	- Return 1 if the specified virtual address is in an
+ *	  executable vma.
+ */
+static bool valid_vma(struct vm_area_struct *vma, bool is_reg)
+{
+	if (!vma->vm_file)
+		return false;
+
+	if (!is_reg)
+		return true;
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
@@ -197,6 +238,18 @@ static bool del_consumer(struct uprobe *uprobe,
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
@@ -207,3 +260,273 @@ static void delete_uprobe(struct uprobe *uprobe)
 	iput(uprobe->inode);
 	put_uprobe(uprobe);
 }
+
+static struct vma_info *__find_next_vma_info(struct list_head *head,
+			loff_t offset, struct address_space *mapping,
+			struct vma_info *vi, bool is_register)
+{
+	struct prio_tree_iter iter;
+	struct vm_area_struct *vma;
+	struct vma_info *tmpvi;
+	loff_t vaddr;
+	unsigned long pgoff = offset >> PAGE_SHIFT;
+	int existing_vma;
+
+	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+		if (!valid_vma(vma, is_register))
+			continue;
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
+
+		/*
+		 * Another vma needs a probe to be installed. However skip
+		 * installing the probe if the vma is about to be unlinked.
+		 */
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
+			loff_t offset, struct address_space *mapping,
+			bool is_register)
+{
+	struct vma_info *vi, *retvi;
+	vi = kzalloc(sizeof(struct vma_info), GFP_KERNEL);
+	if (!vi)
+		return ERR_PTR(-ENOMEM);
+
+	mutex_lock(&mapping->i_mmap_mutex);
+	retvi = __find_next_vma_info(head, offset, mapping, vi, is_register);
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
+	loff_t vaddr;
+	int ret = 0;
+
+	mapping = inode->i_mapping;
+	INIT_LIST_HEAD(&try_list);
+	while ((vi = find_next_vma_info(&try_list, offset,
+						mapping, true)) != NULL) {
+		if (IS_ERR(vi)) {
+			ret = -ENOMEM;
+			break;
+		}
+		mm = vi->mm;
+		down_read(&mm->mmap_sem);
+		vma = find_vma(mm, (unsigned long)vi->vaddr);
+		if (!vma || !valid_vma(vma, true)) {
+			list_del(&vi->probe_list);
+			kfree(vi);
+			up_read(&mm->mmap_sem);
+			mmput(mm);
+			continue;
+		}
+		vaddr = vma->vm_start + offset;
+		vaddr -= vma->vm_pgoff << PAGE_SHIFT;
+		if (vma->vm_file->f_mapping->host != inode ||
+						vaddr != vi->vaddr) {
+			list_del(&vi->probe_list);
+			kfree(vi);
+			up_read(&mm->mmap_sem);
+			mmput(mm);
+			continue;
+		}
+		ret = install_breakpoint(mm);
+		up_read(&mm->mmap_sem);
+		mmput(mm);
+		if (ret && ret == -EEXIST)
+			ret = 0;
+		if (!ret)
+			break;
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
+	loff_t vaddr;
+
+	mapping = inode->i_mapping;
+	INIT_LIST_HEAD(&try_list);
+	while ((vi = find_next_vma_info(&try_list, offset,
+						mapping, false)) != NULL) {
+		if (IS_ERR(vi))
+			break;
+		mm = vi->mm;
+		down_read(&mm->mmap_sem);
+		vma = find_vma(mm, (unsigned long)vi->vaddr);
+		if (!vma || !valid_vma(vma, false)) {
+			list_del(&vi->probe_list);
+			kfree(vi);
+			up_read(&mm->mmap_sem);
+			mmput(mm);
+			continue;
+		}
+		vaddr = vma->vm_start + offset;
+		vaddr -= vma->vm_pgoff << PAGE_SHIFT;
+		if (vma->vm_file->f_mapping->host != inode ||
+						vaddr != vi->vaddr) {
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
+	int ret = -EINVAL;
+
+	if (!consumer || consumer->next)
+		return ret;
+
+	inode = igrab(inode);
+	if (!inode)
+		return ret;
+
+	if (offset > i_size_read(inode))
+		goto reg_out;
+
+	ret = 0;
+	mutex_lock(uprobes_hash(inode));
+	uprobe = alloc_uprobe(inode, offset);
+	if (uprobe && !add_consumer(uprobe, consumer)) {
+		ret = __register_uprobe(inode, offset, uprobe);
+		if (ret) {
+			uprobe->consumers = NULL;
+			__unregister_uprobe(inode, offset, uprobe);
+		}
+	}
+
+	mutex_unlock(uprobes_hash(inode));
+	put_uprobe(uprobe);
+
+reg_out:
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
+	struct uprobe *uprobe = NULL;
+
+	inode = igrab(inode);
+	if (!inode || !consumer)
+		goto unreg_out;
+
+	uprobe = find_uprobe(inode, offset);
+	if (!uprobe)
+		goto unreg_out;
+
+	mutex_lock(uprobes_hash(inode));
+	if (!del_consumer(uprobe, consumer)) {
+		mutex_unlock(uprobes_hash(inode));
+		goto unreg_out;
+	}
+
+	if (!uprobe->consumers)
+		__unregister_uprobe(inode, offset, uprobe);
+
+	mutex_unlock(uprobes_hash(inode));
+
+unreg_out:
+	if (uprobe)
+		put_uprobe(uprobe);
+	if (inode)
+		iput(inode);
+}
+
+static int __init init_uprobes(void)
+{
+	int i;
+
+	for (i = 0; i < UPROBES_HASH_SZ; i++)
+		mutex_init(&uprobes_mutex[i]);
+
+	return 0;
+}
+
+static void __exit exit_uprobes(void)
+{
+}
+
+module_init(init_uprobes);
+module_exit(exit_uprobes);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
