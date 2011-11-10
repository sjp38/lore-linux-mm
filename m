Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5A9B86B006C
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 14:02:37 -0500 (EST)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 11 Nov 2011 00:32:32 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAAJ2VHw4149378
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 00:32:31 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAAJ2UtD000493
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 06:02:31 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 11 Nov 2011 00:07:35 +0530
Message-Id: <20111110183735.11361.20471.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20111110183725.11361.57827.sendpatchset@srdronam.in.ibm.com>
References: <20111110183725.11361.57827.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v6 3.2-rc1 1/28]   uprobes: Auxillary routines to insert, find, delete uprobes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>


Uprobes are maintained in a rb-tree indexed by inode and offset (offset
from the start of the map). For a unique inode, offset combination,
there can be one unique uprobe in the rbtree. Provide routines that
insert a given uprobe, find a uprobe given a inode and offset.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---

Changelog: (from v5)
1. drop reference to inode before dropping reference to uprobe.

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
index 0000000..cacf333
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
+static DEFINE_SPINLOCK(uprobes_treelock);	/* serialize rbtree access */
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
+static struct uprobe *__find_uprobe(struct inode *inode, loff_t offset)
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
+static struct uprobe *find_uprobe(struct inode *inode, loff_t offset)
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
+	/* get access + creation ref */
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
+	/* a uprobe exists for this inode:offset combination */
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
+	iput(uprobe->inode);
+	put_uprobe(uprobe);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
