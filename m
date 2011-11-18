Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 211B26B006E
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 06:33:24 -0500 (EST)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 18 Nov 2011 17:03:20 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAIBX5NK3973194
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 17:03:06 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAIBX4cq016987
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 22:33:05 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 18 Nov 2011 16:37:03 +0530
Message-Id: <20111118110703.10512.61655.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v7 3.2-rc2 2/30] uprobes: Allow multiple consumers for an uprobe.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>


Since there is a unique uprobe for a inode, offset combination, provide
an ability for users to have more than one consumer for a uprobe.

Each consumer will define a handler and an optional filter.  Handler
specifies the routine to run on hitting a probepoint.  Filter allows to
selectively run the handler on hitting the probepoint.  Handler/Filter
will be relevant on probehit.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---

Changelog:(Since v5)
modified del_consumer as per comments from Peter.

 include/linux/uprobes.h |   13 +++++++++++++
 kernel/uprobes.c        |   35 +++++++++++++++++++++++++++++++++++
 2 files changed, 48 insertions(+), 0 deletions(-)

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
index cacf333..2c92b9a 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -149,6 +149,7 @@ static struct uprobe *alloc_uprobe(struct inode *inode, loff_t offset)
 
 	uprobe->inode = igrab(inode);
 	uprobe->offset = offset;
+	init_rwsem(&uprobe->consumer_rwsem);
 
 	/* add to uprobes_tree, sorted on inode:offset */
 	cur_uprobe = insert_uprobe(uprobe);
@@ -162,6 +163,40 @@ static struct uprobe *alloc_uprobe(struct inode *inode, loff_t offset)
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
+	struct uprobe_consumer **con;
+	bool ret = false;
+
+	down_write(&uprobe->consumer_rwsem);
+	for (con = &uprobe->consumers; *con; con = &(*con)->next) {
+		if (*con == consumer) {
+			*con = consumer->next;
+			ret = true;
+			break;
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
