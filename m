Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 43F718D003E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 09:40:29 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp06.in.ibm.com (8.14.4/8.13.1) with ESMTP id p2EDeNU9012007
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:10:23 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2EDeNaC2334888
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:10:23 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2EDeLjJ010061
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 00:40:23 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Mon, 14 Mar 2011 19:04:44 +0530
Message-Id: <20110314133444.27435.50684.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v2 2.6.38-rc8-tip 4/20]  4: uprobes: Adding and remove a uprobe in a rb tree.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>


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
 include/linux/uprobes.h |   12 +++
 kernel/uprobes.c        |  225 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 233 insertions(+), 4 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 350ccb0..f422bc6 100644
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
index 4f0f61b..6e692a8 100644
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
 
+static int valid_vma(struct vm_area_struct *vma)
+{
+	if (!vma->vm_file)
+		return 0;
+
+	if ((vma->vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)) ==
+						(VM_READ|VM_EXEC))
+		return 1;
+
+	return 0;
+}
+
 /*
  * Called with tsk->mm->mmap_sem held (either for read or write and
  * with a reference to tsk->mm.
@@ -63,8 +81,7 @@ static int write_opcode(struct task_struct *tsk, struct uprobe * uprobe,
 	 * Since we are interested in text pages, Our pages of interest
 	 * should be mapped read-only.
 	 */
-	if ((vma->vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)) ==
-						(VM_READ|VM_EXEC))
+	if (!valid_vma(vma))
 		goto put_out;
 
 	/* Allocate a page */
@@ -140,8 +157,7 @@ int __weak read_opcode(struct task_struct *tsk, unsigned long vaddr,
 	 * Since we are interested in text pages, Our pages of interest
 	 * should be mapped read-only.
 	 */
-	if ((vma->vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)) ==
-						(VM_READ|VM_EXEC))
+	if (!valid_vma(vma))
 		goto put_out;
 
 	lock_page(page);
@@ -228,3 +244,204 @@ bool __weak is_bkpt_insn(u8 *insn)
 	memcpy(&opcode, insn, UPROBES_BKPT_INSN_SIZE);
 	return (opcode == UPROBES_BKPT_INSN);
 }
+
+static struct rb_root uprobes_tree = RB_ROOT;
+static DEFINE_MUTEX(uprobes_mutex);
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
+ * Check if a uprobe is already inserted;
+ *	If it does; return refcount incremented uprobe
+ *	else add the current uprobe and return NULL
+ * Acquires treelock.
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
+				atomic_inc(&u->ref);
+				goto unlock_return;
+			}
+		}
+	}
+	u = NULL;
+	rb_link_node(&uprobe->rb_node, parent, p);
+	rb_insert_color(&uprobe->rb_node, &uprobes_tree);
+	atomic_set(&uprobe->ref, 2);
+
+unlock_return:
+	spin_unlock_irqrestore(&treelock, flags);
+	return u;
+}
+
+/* Should be called lock-less */
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
+	__iget(inode);
+	uprobe = kzalloc(sizeof(struct uprobe), GFP_KERNEL);
+
+	if (!uprobe) {
+		iput(inode);
+		return NULL;
+	}
+	uprobe->inode = inode;
+	uprobe->offset = offset;
+
+	/* add to uprobes_tree, sorted on inode:offset */
+	cur_uprobe = insert_uprobe(uprobe);
+
+	/* a uprobe exists for this inode:offset combination*/
+	if (cur_uprobe) {
+		kfree(uprobe);
+		uprobe = cur_uprobe;
+		iput(inode);
+	} else
+		init_rwsem(&uprobe->consumer_rwsem);
+
+	return uprobe;
+}
+
+/* Acquires uprobe->consumer_rwsem */
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
+/* Acquires uprobe->consumer_rwsem */
+static void add_consumer(struct uprobe *uprobe,
+				struct uprobe_consumer *consumer)
+{
+	down_write(&uprobe->consumer_rwsem);
+	consumer->next = uprobe->consumers;
+	uprobe->consumers = consumer;
+	up_write(&uprobe->consumer_rwsem);
+	return;
+}
+
+/* Acquires uprobe->consumer_rwsem */
+static int del_consumer(struct uprobe *uprobe,
+				struct uprobe_consumer *consumer)
+{
+	struct uprobe_consumer *con;
+	int ret = 0;
+
+	down_write(&uprobe->consumer_rwsem);
+	con = uprobe->consumers;
+	if (consumer == con) {
+		uprobe->consumers = con->next;
+		if (!con->next)
+			put_uprobe(uprobe);
+		ret = 1;
+	} else {
+		for (; con; con = con->next) {
+			if (con->next == consumer) {
+				con->next = consumer->next;
+				ret = 1;
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
