Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F3ECD9000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 08:13:48 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp01.au.ibm.com (8.14.4/8.13.1) with ESMTP id p8KCCDYc025976
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 22:12:13 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8KCDibI1437746
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 22:13:44 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8KCDhb3021544
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 22:13:44 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 20 Sep 2011 17:30:06 +0530
Message-Id: <20110920120006.25326.81787.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v5 3.1.0-rc4-tip 2/26]   Uprobes: Allow multiple consumers for an uprobe.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>


Since there is a unique uprobe for a inode, offset combination, provide
an ability for users to have more than one consumer for a uprobe.

Each consumer will define a handler and a filter.  Handler specifies the
routine to run on hitting a probepoint.  Filter allows to selectively run
the handler on hitting the probepoint.  Handler/Filter will be relevant when
we handle probehit.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/uprobes.h |   13 +++++++++++++
 kernel/uprobes.c        |   41 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 54 insertions(+), 0 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index bfb85c4..bf31f7c 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -25,9 +25,22 @@
 
 #include <linux/rbtree.h>
 
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
 struct uprobe {
 	struct rb_node		rb_node;	/* node in the rb tree */
 	atomic_t		ref;
+	struct rw_semaphore	consumer_rwsem;
+	struct uprobe_consumer	*consumers;
 	struct inode		*inode;		/* Also hold a ref to inode */
 	loff_t			offset;
 };
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index e452147..ba9fd55 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -149,6 +149,7 @@ static struct uprobe *alloc_uprobe(struct inode *inode, loff_t offset)
 
 	uprobe->inode = igrab(inode);
 	uprobe->offset = offset;
+	init_rwsem(&uprobe->consumer_rwsem);
 
 	/* add to uprobes_tree, sorted on inode:offset */
 	cur_uprobe = insert_uprobe(uprobe);
@@ -162,6 +163,46 @@ static struct uprobe *alloc_uprobe(struct inode *inode, loff_t offset)
 	return uprobe;
 }
 
+/* Returns the previous consumer */
+static struct uprobe_consumer *add_consumer(struct uprobe *uprobe,
+				struct uprobe_consumer *consumer)
+{
+	down_write(&uprobe->consumer_rwsem);
+	consumer->next = uprobe->consumers;
+	uprobe->consumers = consumer;
+	up_write(&uprobe->consumer_rwsem);
+	return consumer->next;
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
+
 static void delete_uprobe(struct uprobe *uprobe)
 {
 	unsigned long flags;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
