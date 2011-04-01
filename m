Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id ECF4A8D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 10:43:29 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp01.in.ibm.com (8.14.4/8.13.1) with ESMTP id p31Eh6IP017925
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 20:13:06 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p31Eh6Dv2924552
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 20:13:06 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p31Eh42A016997
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:43:05 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 01 Apr 2011 20:03:28 +0530
Message-Id: <20110401143328.15455.19094.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v3 2.6.39-rc1-tip 5/26]  5: uprobes: Adding and remove a uprobe in a rb tree.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>


Provides interfaces to add and remove uprobes from the global rb tree.
Also provides definitions for uprobe_consumer, interfaces to add and
remove a consumer to a uprobe.  There is a unique uprobe element in the
rbtree for each unique inode:offset pair.

Uprobe gets added to the global rb tree when the first consumer for that
uprobe gets registered. It gets removed from the tree only when all
registered consumers are unregistered.

Multiple consumers can share the same probe. Each consumer provides a
filter to limit the tasks on which the handler should run, a handler
that runs on probe hit and a value which helps filter callback to limit
the tasks on which the handler should run.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/uprobes.h |   12 ++
 kernel/uprobes.c        |  226 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 234 insertions(+), 4 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index ae134a5..bfe2e9e 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -23,6 +23,7 @@
  *	Jim Keniston
  */
 
+#include <linux/rbtree.h>
 #ifdef CONFIG_ARCH_SUPPORTS_UPROBES
 #include <asm/uprobes.h>
 #else
@@ -50,6 +51,17 @@ typedef u8 uprobe_opcode_t;
 /* Unexported functions & macros for use by arch-specific code */
 #define uprobe_opcode_sz (sizeof(uprobe_opcode_t))
 
+struct uprobe_consumer {
+	int (*handler)(struct uprobe_consumer *self, struct pt_regs *regs);
+	/*
+	 * filter is optional; If a filter exists, handler is run
+	 * if and only if filter returns true.
+	 */
+	bool (*filter)(struct uprobe_consumer *self, struct task_struct *task);
+
+	struct uprobe_consumer *next;
+};
+
 /*
  * Most architectures can use the default versions of @read_opcode(),
  * @set_bkpt(), @set_orig_insn(), and @is_bkpt_insn();
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index 9ef21a7..f37418b 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -33,10 +33,28 @@
 #include <linux/rmap.h> /* needed for anon_vma_prepare */
 
 struct uprobe {
+	struct rb_node		rb_node;	/* node in the rb tree */
+	atomic_t		ref;		/* lifetime muck */
+	struct rw_semaphore	consumer_rwsem;
+	struct uprobe_consumer	*consumers;
+	struct inode		*inode;		/* we hold a ref */
+	loff_t			offset;
 	u8			insn[MAX_UINSN_BYTES];
 	u16			fixups;
 };
 
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
 /*
  * NOTE:
  * Expect the breakpoint instruction to be the smallest size instruction for
@@ -83,8 +101,7 @@ static int write_opcode(struct task_struct *tsk, struct uprobe * uprobe,
 	 * adding probes in write mapped pages since the breakpoints
 	 * might end up in the file copy.
 	 */
-	if ((vma->vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)) !=
-						(VM_READ|VM_EXEC))
+	if (!valid_vma(vma))
 		goto put_out;
 
 	/* Allocate a page */
@@ -164,8 +181,7 @@ int __weak read_opcode(struct task_struct *tsk, unsigned long vaddr,
 	 * adding probes in write mapped pages since the breakpoints
 	 * might end up in the file copy.
 	 */
-	if ((vma->vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)) !=
-						(VM_READ|VM_EXEC))
+	if (!valid_vma(vma))
 		goto put_out;
 
 	lock_page(page);
@@ -252,3 +268,205 @@ bool __weak is_bkpt_insn(u8 *insn)
 	memcpy(&opcode, insn, UPROBES_BKPT_INSN_SIZE);
 	return (opcode == UPROBES_BKPT_INSN);
 }
+
+static struct rb_root uprobes_tree = RB_ROOT;
+static DEFINE_SPINLOCK(treelock);
+
+static int match_inode(struct uprobe *uprobe, struct inode *inode,
+						struct rb_node **p)
+{
+	struct rb_node *n = *p;
+
+	if (inode < uprobe->inode)
+		*p = n->rb_left;
+	else if (inode > uprobe->inode)
+		*p = n->rb_right;
+	else
+		return 1;
+	return 0;
+}
+
+static int match_offset(struct uprobe *uprobe, loff_t offset,
+						struct rb_node **p)
+{
+	struct rb_node *n = *p;
+
+	if (offset < uprobe->offset)
+		*p = n->rb_left;
+	else if (offset > uprobe->offset)
+		*p = n->rb_right;
+	else
+		return 1;
+	return 0;
+}
+
+
+/* Called with treelock held */
+static struct uprobe *__find_uprobe(struct inode * inode,
+			 loff_t offset, struct rb_node **near_match)
+{
+	struct rb_node *n = uprobes_tree.rb_node;
+	struct uprobe *uprobe, *u = NULL;
+
+	while (n) {
+		uprobe = rb_entry(n, struct uprobe, rb_node);
+		if (match_inode(uprobe, inode, &n)) {
+			if (near_match)
+				*near_match = n;
+			if (match_offset(uprobe, offset, &n)) {
+				/* get access ref */
+				atomic_inc(&uprobe->ref);
+				u = uprobe;
+				break;
+			}
+		}
+	}
+	return u;
+}
+
+/*
+ * Find a uprobe corresponding to a given inode:offset
+ * Acquires treelock
+ */
+static struct uprobe *find_uprobe(struct inode * inode, loff_t offset)
+{
+	struct uprobe *uprobe;
+	unsigned long flags;
+
+	spin_lock_irqsave(&treelock, flags);
+	uprobe = __find_uprobe(inode, offset, NULL);
+	spin_unlock_irqrestore(&treelock, flags);
+	return uprobe;
+}
+
+/*
+ * Acquires treelock.
+ * Matching uprobe already exists in rbtree;
+ *	increment (access refcount) and return the matching uprobe.
+ *
+ * No matching uprobe; insert the uprobe in rb_tree;
+ *	get a double refcount (access + creation) and return NULL.
+ */
+static struct uprobe *insert_uprobe(struct uprobe *uprobe)
+{
+	struct rb_node **p = &uprobes_tree.rb_node;
+	struct rb_node *parent = NULL;
+	struct uprobe *u;
+	unsigned long flags;
+
+	spin_lock_irqsave(&treelock, flags);
+	while (*p) {
+		parent = *p;
+		u = rb_entry(parent, struct uprobe, rb_node);
+		if (u->inode > uprobe->inode)
+			p = &(*p)->rb_left;
+		else if (u->inode < uprobe->inode)
+			p = &(*p)->rb_right;
+		else {
+			if (u->offset > uprobe->offset)
+				p = &(*p)->rb_left;
+			else if (u->offset < uprobe->offset)
+				p = &(*p)->rb_right;
+			else {
+				/* get access ref */
+				atomic_inc(&u->ref);
+				goto unlock_return;
+			}
+		}
+	}
+	u = NULL;
+	rb_link_node(&uprobe->rb_node, parent, p);
+	rb_insert_color(&uprobe->rb_node, &uprobes_tree);
+	/* get access + drop ref */
+	atomic_set(&uprobe->ref, 2);
+
+unlock_return:
+	spin_unlock_irqrestore(&treelock, flags);
+	return u;
+}
+
+static void put_uprobe(struct uprobe *uprobe)
+{
+	if (atomic_dec_and_test(&uprobe->ref))
+		kfree(uprobe);
+}
+
+static struct uprobe *uprobes_add(struct inode *inode, loff_t offset)
+{
+	struct uprobe *uprobe, *cur_uprobe;
+
+	uprobe = kzalloc(sizeof(struct uprobe), GFP_KERNEL);
+	if (!uprobe)
+		return NULL;
+
+	__iget(inode);
+	uprobe->inode = inode;
+	uprobe->offset = offset;
+	init_rwsem(&uprobe->consumer_rwsem);
+
+	/* add to uprobes_tree, sorted on inode:offset */
+	cur_uprobe = insert_uprobe(uprobe);
+
+	/* a uprobe exists for this inode:offset combination*/
+	if (cur_uprobe) {
+		kfree(uprobe);
+		uprobe = cur_uprobe;
+		iput(inode);
+	}
+	return uprobe;
+}
+
+static void handler_chain(struct uprobe *uprobe, struct pt_regs *regs)
+{
+	struct uprobe_consumer *consumer;
+
+	down_read(&uprobe->consumer_rwsem);
+	consumer = uprobe->consumers;
+	while (consumer) {
+		if (!consumer->filter || consumer->filter(consumer, current))
+			consumer->handler(consumer, regs);
+
+		consumer = consumer->next;
+	}
+	up_read(&uprobe->consumer_rwsem);
+}
+
+static void add_consumer(struct uprobe *uprobe,
+				struct uprobe_consumer *consumer)
+{
+	down_write(&uprobe->consumer_rwsem);
+	consumer->next = uprobe->consumers;
+	uprobe->consumers = consumer;
+	up_write(&uprobe->consumer_rwsem);
+}
+
+/*
+ * For uprobe @uprobe, delete the consumer @consumer.
+ * Return true if the @consumer is deleted successfully
+ * or return false.
+ */
+static bool del_consumer(struct uprobe *uprobe,
+				struct uprobe_consumer *consumer)
+{
+	struct uprobe_consumer *con;
+	bool ret = false;
+
+	down_write(&uprobe->consumer_rwsem);
+	con = uprobe->consumers;
+	if (consumer == con) {
+		uprobe->consumers = con->next;
+		if (!con->next)
+			put_uprobe(uprobe); /* drop creation ref */
+		ret = true;
+	} else {
+		for (; con; con = con->next) {
+			if (con->next == consumer) {
+				con->next = consumer->next;
+				ret = true;
+				break;
+			}
+		}
+	}
+	up_write(&uprobe->consumer_rwsem);
+	return ret;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
