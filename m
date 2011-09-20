Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1DDA79000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 08:14:58 -0400 (EDT)
Received: from /spool/local
	by au.ibm.com with XMail ESMTP
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 20 Sep 2011 13:10:59 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8KCBXQj1233112
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 22:11:35 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8KCDQLu003127
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 22:13:28 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 20 Sep 2011 17:29:49 +0530
Message-Id: <20110920115949.25326.2469.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v5 3.1.0-rc4-tip 1/26]   uprobes: Auxillary routines to insert, find, delete uprobes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>


Uprobes are maintained in a rb-tree indexed by inode and offset (offset
from the start of the map). For a unique inode, offset combination,
there can be one unique uprobe in the rbtree. Provide routines that
insert a given uprobe, find a uprobe given a inode and offset.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/uprobes.h |   35 +++++++++
 kernel/uprobes.c        |  174 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 209 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/uprobes.h
 create mode 100644 kernel/uprobes.c

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
new file mode 100644
index 0000000..bfb85c4
--- /dev/null
+++ b/include/linux/uprobes.h
@@ -0,0 +1,35 @@
+#ifndef _LINUX_UPROBES_H
+#define _LINUX_UPROBES_H
+/*
+ * Userspace Probes (UProbes)
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ *
+ * Copyright (C) IBM Corporation, 2008-2011
+ * Authors:
+ *	Srikar Dronamraju
+ *	Jim Keniston
+ */
+
+#include <linux/rbtree.h>
+
+struct uprobe {
+	struct rb_node		rb_node;	/* node in the rb tree */
+	atomic_t		ref;
+	struct inode		*inode;		/* Also hold a ref to inode */
+	loff_t			offset;
+};
+
+#endif	/* _LINUX_UPROBES_H */
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
new file mode 100644
index 0000000..e452147
--- /dev/null
+++ b/kernel/uprobes.c
@@ -0,0 +1,174 @@
+/*
+ * Userspace Probes (UProbes)
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ *
+ * Copyright (C) IBM Corporation, 2008-2011
+ * Authors:
+ *	Srikar Dronamraju
+ *	Jim Keniston
+ */
+
+#include <linux/kernel.h>
+#include <linux/highmem.h>
+#include <linux/slab.h>
+#include <linux/uprobes.h>
+
+static struct rb_root uprobes_tree = RB_ROOT;
+static DEFINE_SPINLOCK(uprobes_treelock);	/* serialize (un)register */
+
+static int match_uprobe(struct uprobe *l, struct uprobe *r)
+{
+	if (l->inode < r->inode)
+		return -1;
+	if (l->inode > r->inode)
+		return 1;
+	else {
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
+static struct uprobe *__find_uprobe(struct inode * inode, loff_t offset)
+{
+	struct uprobe u = { .inode = inode, .offset = offset };
+	struct rb_node *n = uprobes_tree.rb_node;
+	struct uprobe *uprobe;
+	int match;
+
+	while (n) {
+		uprobe = rb_entry(n, struct uprobe, rb_node);
+		match = match_uprobe(&u, uprobe);
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
+	uprobe = __find_uprobe(inode, offset);
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
+		match = match_uprobe(uprobe, u);
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
+	uprobe->inode = igrab(inode);
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
+	}
+	return uprobe;
+}
+
+static void delete_uprobe(struct uprobe *uprobe)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&uprobes_treelock, flags);
+	rb_erase(&uprobe->rb_node, &uprobes_tree);
+	spin_unlock_irqrestore(&uprobes_treelock, flags);
+	put_uprobe(uprobe);
+	iput(uprobe->inode);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
