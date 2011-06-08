Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2EDD16B0083
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 06:37:22 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p58APix1004303
	for <linux-mm@kvack.org>; Wed, 8 Jun 2011 06:25:44 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p58AbJRA122146
	for <linux-mm@kvack.org>; Wed, 8 Jun 2011 06:37:19 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p58AbHHN014680
	for <linux-mm@kvack.org>; Wed, 8 Jun 2011 07:37:19 -0300
Date: Wed, 8 Jun 2011 16:00:19 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 3/22]  3: uprobes: Adding and remove a
 uprobe in a rb tree.
Message-ID: <20110608103019.GB6123@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
 <20110607125850.28590.10861.sendpatchset@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110607125850.28590.10861.sendpatchset@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

Changelog: Including a fix suggested by Stephen Wilson, to fix a small
	problem in match_uprobe, fix was to interchange the parameters
	Problem was reported by Josh Stone. (Thanks Josh, Stephen)

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
 kernel/uprobes.c        |  210 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 222 insertions(+), 0 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 232ccea..9187df3 100644
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
index 7ef916e..80ddaf3 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -35,6 +35,12 @@
 #include <linux/swap.h>	/* needed for try_to_free_swap */
 
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
@@ -307,3 +313,207 @@ bool __weak is_bkpt_insn(u8 *insn)
 	memcpy(&opcode, insn, UPROBES_BKPT_INSN_SIZE);
 	return (opcode == UPROBES_BKPT_INSN);
 }
+
+static struct rb_root uprobes_tree = RB_ROOT;
+static DEFINE_SPINLOCK(uprobes_treelock);	/* serialize (un)register */
+
+static int match_uprobe(struct uprobe *l, struct uprobe *r, int *match_inode)
+{
+	if (match_inode)
+		*match_inode = 0;
+
+	if (l->inode < r->inode)
+		return -1;
+	if (l->inode > r->inode)
+		return 1;
+	else {
+		if (match_inode)
+			*match_inode = 1;
+
+		if (l->offset < r->offset)
+			return -1;
+
+		if (l->offset > r->offset)
+			return 1;
+	}
+
+	return 0;
+}
+
+/* Called with uprobes_treelock held */
+static struct uprobe *__find_uprobe(struct inode * inode,
+			 loff_t offset, struct rb_node **close_match)
+{
+	struct uprobe u = { .inode = inode, .offset = offset };
+	struct rb_node *n = uprobes_tree.rb_node;
+	struct uprobe *uprobe;
+	int match, match_inode;
+
+	while (n) {
+		uprobe = rb_entry(n, struct uprobe, rb_node);
+		match = match_uprobe(&u, uprobe, &match_inode);
+		if (close_match && match_inode)
+			*close_match = n;
+
+		if (!match) {
+			atomic_inc(&uprobe->ref);
+			return uprobe;
+		}
+		if (match < 0)
+			n = n->rb_left;
+		else
+			n = n->rb_right;
+
+	}
+	return NULL;
+}
+
+/*
+ * Find a uprobe corresponding to a given inode:offset
+ * Acquires uprobes_treelock
+ */
+static struct uprobe *find_uprobe(struct inode * inode, loff_t offset)
+{
+	struct uprobe *uprobe;
+	unsigned long flags;
+
+	spin_lock_irqsave(&uprobes_treelock, flags);
+	uprobe = __find_uprobe(inode, offset, NULL);
+	spin_unlock_irqrestore(&uprobes_treelock, flags);
+	return uprobe;
+}
+
+static struct uprobe *__insert_uprobe(struct uprobe *uprobe)
+{
+	struct rb_node **p = &uprobes_tree.rb_node;
+	struct rb_node *parent = NULL;
+	struct uprobe *u;
+	int match;
+
+	while (*p) {
+		parent = *p;
+		u = rb_entry(parent, struct uprobe, rb_node);
+		match = match_uprobe(uprobe, u, NULL);
+		if (!match) {
+			atomic_inc(&u->ref);
+			return u;
+		}
+
+		if (match < 0)
+			p = &parent->rb_left;
+		else
+			p = &parent->rb_right;
+
+	}
+	u = NULL;
+	rb_link_node(&uprobe->rb_node, parent, p);
+	rb_insert_color(&uprobe->rb_node, &uprobes_tree);
+	/* get access + drop ref */
+	atomic_set(&uprobe->ref, 2);
+	return u;
+}
+
+/*
+ * Acquires uprobes_treelock.
+ * Matching uprobe already exists in rbtree;
+ *	increment (access refcount) and return the matching uprobe.
+ *
+ * No matching uprobe; insert the uprobe in rb_tree;
+ *	get a double refcount (access + creation) and return NULL.
+ */
+static struct uprobe *insert_uprobe(struct uprobe *uprobe)
+{
+	unsigned long flags;
+	struct uprobe *u;
+
+	spin_lock_irqsave(&uprobes_treelock, flags);
+	u = __insert_uprobe(uprobe);
+	spin_unlock_irqrestore(&uprobes_treelock, flags);
+	return u;
+}
+
+static void put_uprobe(struct uprobe *uprobe)
+{
+	if (atomic_dec_and_test(&uprobe->ref))
+		kfree(uprobe);
+}
+
+static struct uprobe *alloc_uprobe(struct inode *inode, loff_t offset)
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
