Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id A8CEF6B0261
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 23:47:26 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id u186so382292861ita.0
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 20:47:26 -0700 (PDT)
Received: from cliff.cs.toronto.edu (cliff.cs.toronto.edu. [128.100.3.120])
        by mx.google.com with ESMTPS id c135si19746230itb.118.2016.07.25.20.47.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 20:47:24 -0700 (PDT)
Message-Id: <a70675af07c08d96710548753e5b46b8e85b6409.1469489884.git.gamvrosi@gmail.com>
In-Reply-To: <cover.1469489884.git.gamvrosi@gmail.com>
References: <cover.1469489884.git.gamvrosi@gmail.com>
From: George Amvrosiadis <gamvrosi@gmail.com>
Subject: [PATCH 3/3] mm/duet: framework code
Date: Mon, 25 Jul 2016 23:47:24 -0400 (EDT)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: George Amvrosiadis <gamvrosi@gmail.com>

The Duet framework code:

- bittree.c: red-black bitmap tree that keeps track of items of interest
- debug.c: functions used to print information used to debug Duet
- hash.c: implementation of the global hash table where page events are stored
  for all tasks
- hook.c: the function invoked by the page cache hooks when Duet is online
- init.c: routines used to bring Duet online or offline
- path.c: routines performing resolution of UUIDs to paths using d_path
- task.c: implementation of Duet task fd operations

Signed-off-by: George Amvrosiadis <gamvrosi@gmail.com>
---
 init/Kconfig      |   2 +
 mm/Makefile       |   1 +
 mm/duet/Kconfig   |  31 +++
 mm/duet/Makefile  |   7 +
 mm/duet/bittree.c | 537 +++++++++++++++++++++++++++++++++++++++++++++++++
 mm/duet/common.h  | 211 ++++++++++++++++++++
 mm/duet/debug.c   |  98 +++++++++
 mm/duet/hash.c    | 315 +++++++++++++++++++++++++++++
 mm/duet/hook.c    |  81 ++++++++
 mm/duet/init.c    | 172 ++++++++++++++++
 mm/duet/path.c    | 184 +++++++++++++++++
 mm/duet/syscall.h |  61 ++++++
 mm/duet/task.c    | 584 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 13 files changed, 2284 insertions(+)
 create mode 100644 mm/duet/Kconfig
 create mode 100644 mm/duet/Makefile
 create mode 100644 mm/duet/bittree.c
 create mode 100644 mm/duet/common.h
 create mode 100644 mm/duet/debug.c
 create mode 100644 mm/duet/hash.c
 create mode 100644 mm/duet/hook.c
 create mode 100644 mm/duet/init.c
 create mode 100644 mm/duet/path.c
 create mode 100644 mm/duet/syscall.h
 create mode 100644 mm/duet/task.c

diff --git a/init/Kconfig b/init/Kconfig
index c02d897..6f94b5a 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -294,6 +294,8 @@ config USELIB
 	  earlier, you may need to enable this syscall.  Current systems
 	  running glibc can safely disable this.
 
+source mm/duet/Kconfig
+
 config AUDIT
 	bool "Auditing support"
 	depends on NET
diff --git a/mm/Makefile b/mm/Makefile
index 78c6f7d..074c15f 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -99,3 +99,4 @@ obj-$(CONFIG_USERFAULTFD) += userfaultfd.o
 obj-$(CONFIG_IDLE_PAGE_TRACKING) += page_idle.o
 obj-$(CONFIG_FRAME_VECTOR) += frame_vector.o
 obj-$(CONFIG_DEBUG_PAGE_REF) += debug_page_ref.o
+obj-$(CONFIG_DUET) += duet/
diff --git a/mm/duet/Kconfig b/mm/duet/Kconfig
new file mode 100644
index 0000000..2f3a0c5
--- /dev/null
+++ b/mm/duet/Kconfig
@@ -0,0 +1,31 @@
+config DUET
+	bool "Duet framework support"
+
+	help
+	  Duet is a framework aiming to reduce the IO footprint of analytics
+	  and maintenance work. By exposing page cache events to these tasks,
+	  it allows them to adapt their data processing order, in order to
+	  benefit from data available in the page cache. Duet's operation is
+	  based on hooks into the page cache.
+
+	  To compile support for Duet, say Y.
+
+config DUET_STATS
+	bool "Duet statistics collection"
+	depends on DUET
+	help
+	  This option enables support for the collection of statistics on the
+	  operation of Duet. It will print information about the data structures
+	  used internally, and profiling information about the framework.
+
+	  If unsure, say N.
+
+config DUET_DEBUG
+	bool "Duet debugging support"
+	depends on DUET
+	help
+	  Enable runtime debugging support for the Duet framework. This may
+	  enable additional and expensive checks with negative impact on
+	  performance.
+
+	  To compile debugging support for Duet, say Y. If unsure, say N.
diff --git a/mm/duet/Makefile b/mm/duet/Makefile
new file mode 100644
index 0000000..c0c9e11
--- /dev/null
+++ b/mm/duet/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for the linux Duet framework.
+#
+
+obj-$(CONFIG_DUET) += duet.o
+
+duet-y := init.o hash.o hook.o task.o bittree.o path.o debug.o
diff --git a/mm/duet/bittree.c b/mm/duet/bittree.c
new file mode 100644
index 0000000..3b20c35
--- /dev/null
+++ b/mm/duet/bittree.c
@@ -0,0 +1,537 @@
+/*
+ * Copyright (C) 2016 George Amvrosiadis.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License v2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+
+#include "common.h"
+
+#define BMAP_READ	0x01	/* Read bmaps (overrides other flags) */
+#define BMAP_CHECK	0x02	/* Check given bmap value expression */
+				/* Sets bmaps to match expression if not set */
+
+/* Bmap expressions can be formed using the following flags: */
+#define BMAP_DONE_SET	0x04	/* Set done bmap values */
+#define BMAP_DONE_RST	0x08	/* Reset done bmap values */
+#define BMAP_RELV_SET	0x10	/* Set relevant bmap values */
+#define BMAP_RELV_RST	0x20	/* Reset relevant bmap values */
+#define BMAP_SEEN_SET	0x40	/* Set seen bmap values */
+#define BMAP_SEEN_RST	0x80	/* Reset seen bmap values */
+
+/* Some macros to make our life easier */
+#define BMAP_ALL_SET	(BMAP_SEEN_SET | BMAP_RELV_SET | BMAP_DONE_SET)
+#define BMAP_ALL_RST	(BMAP_SEEN_RST | BMAP_RELV_RST | BMAP_DONE_RST)
+
+#define BITTREE_RANGE	PAGE_SIZE	/* Bytes per bitmap bit */
+#define BITS_PER_NODE	(32768 * 8)	/* 32KB bitmaps */
+
+#define UUID_IDX(uuid)	(((unsigned long long) uuid.gen << 32) | \
+			  (unsigned long long) uuid.ino)
+/*
+ * The following functions are wrappers for the basic bitmap functions.
+ * A bitmap is characterized by a starting offset (bstart). The wrappers
+ * translate an arbitrary idx to the appropriate bit.
+ */
+
+/* Sets (or resets) a single bit */
+static int bmap_set(unsigned long *bmap, __u64 start, __u64 idx, __u8 do_set)
+{
+	__u64 bofft = idx - start;
+
+	if (bofft + 1 >= start + (BITS_PER_NODE * BITTREE_RANGE))
+		return -1;
+
+	/* Convert range to bitmap granularity */
+	do_div(bofft, BITTREE_RANGE);
+
+	if (do_set)
+		bitmap_set(bmap, (unsigned int)bofft, 1);
+	else
+		bitmap_clear(bmap, (unsigned int)bofft, 1);
+
+	return 0;
+}
+
+/* Returns value of bit at idx */
+static int bmap_read(unsigned long *bmap, __u64 start, __u64 idx)
+{
+	__u64 bofft64 = idx - start;
+	unsigned long *p, mask;
+	unsigned int bofft;
+
+	if (bofft64 + 1 >= start + (BITS_PER_NODE * BITTREE_RANGE))
+		return -1;
+
+	/* Convert offset to bitmap granularity */
+	do_div(bofft64, BITTREE_RANGE);
+	bofft = (unsigned int)bofft64;
+
+	/* Check the bits */
+	p = bmap + BIT_WORD(bofft);
+	mask = BITMAP_FIRST_WORD_MASK(bofft) & BITMAP_LAST_WORD_MASK(bofft + 1);
+
+	if ((*p) & mask)
+		return 1;
+
+	return 0;
+}
+
+/* Checks whether a bit is set */
+static int bmap_chk(unsigned long *bmap, __u64 start, __u64 idx, __u8 do_set)
+{
+	__u64 bofft64 = idx - start;
+	unsigned long *p, mask;
+	unsigned int bofft;
+
+	if (bofft64 + 1 >= start + (BITS_PER_NODE * BITTREE_RANGE))
+		return -1;
+
+	/* Convert range to bitmap granularity */
+	do_div(bofft64, BITTREE_RANGE);
+
+	/* Now it is safe to cast these variables */
+	bofft = (unsigned int)bofft64;
+
+	/* Check the bit */
+	p = bmap + BIT_WORD(bofft);
+	mask = BITMAP_FIRST_WORD_MASK(bofft) & BITMAP_LAST_WORD_MASK(bofft + 1);
+
+	if (do_set && !((*p) & mask))
+		return 0;
+	else if (!do_set && !(~(*p) & mask))
+		return 0;
+
+	return 1;
+}
+
+/* Initializes a bitmap tree node */
+static struct bmap_rbnode *bnode_init(struct duet_bittree *bt, __u64 idx)
+{
+	struct bmap_rbnode *bnode = NULL;
+
+#ifdef CONFIG_DUET_STATS
+	if (bt) {
+		(bt->statcur)++;
+		if (bt->statcur > bt->statmax) {
+			bt->statmax = bt->statcur;
+			pr_info("duet: %llu BitTree nodes (%llub)\n",
+				bt->statmax, bt->statmax * BITS_PER_NODE / 8);
+		}
+	}
+#endif /* CONFIG_DUET_STATS */
+
+	bnode = kmalloc(sizeof(*bnode), GFP_NOWAIT);
+	if (!bnode)
+		return NULL;
+
+	bnode->done = kzalloc(sizeof(unsigned long) *
+			BITS_TO_LONGS(BITS_PER_NODE), GFP_NOWAIT);
+	if (!bnode->done) {
+		kfree(bnode);
+		return NULL;
+	}
+
+	/* Allocate relevant bitmap, if needed */
+	bnode->relv = kzalloc(sizeof(unsigned long) *
+		BITS_TO_LONGS(BITS_PER_NODE), GFP_NOWAIT);
+	if (!bnode->relv) {
+		kfree(bnode->done);
+		kfree(bnode);
+		return NULL;
+	}
+
+	bnode->seen = kzalloc(sizeof(unsigned long) *
+		BITS_TO_LONGS(BITS_PER_NODE), GFP_NOWAIT);
+	if (!bnode->seen) {
+		kfree(bnode->relv);
+		kfree(bnode->done);
+		kfree(bnode);
+		return NULL;
+	}
+
+	RB_CLEAR_NODE(&bnode->node);
+	bnode->idx = idx;
+	return bnode;
+}
+
+static void bnode_dispose(struct bmap_rbnode *bnode, struct rb_node *rbnode,
+	struct duet_bittree *bt)
+{
+#ifdef CONFIG_DUET_STATS
+	if (bt)
+		(bt->statcur)--;
+#endif /* CONFIG_DUET_STATS */
+	rb_erase(rbnode, &bt->root);
+	kfree(bnode->relv);
+	kfree(bnode->seen);
+	kfree(bnode->done);
+	kfree(bnode);
+}
+
+/*
+ * Traverses bitmap nodes to read/set/unset/check a specific bit across bitmaps.
+ * May insert/remove bitmap nodes as needed.
+ *
+ * If DUET_BMAP_READ is set:
+ * - the bitmap value for idx are read for one or all bitmaps
+ * Otherwise, if DUET_BMAP_CHECK flag is set:
+ * - return value 1 means the idx matches the given flags
+ * - return value 0 means the idx doesn't match the given flags
+ * Otherwise, if neither flag is set:
+ * - return value 0 means the idx was updated to match given flags
+ *
+ * In all cases, a return value -1 denotes an error.
+ */
+static int __update_tree(struct duet_bittree *bt, __u64 idx, __u8 flags)
+{
+	int found, ret, res;
+	__u64 node_offt, div_rem;
+	struct rb_node **link, *parent;
+	struct bmap_rbnode *bnode = NULL;
+	unsigned long iflags;
+
+	local_irq_save(iflags);
+	spin_lock(&bt->lock);
+
+	div64_u64_rem(idx, BITTREE_RANGE * BITS_PER_NODE, &div_rem);
+	node_offt = idx - div_rem;
+
+	/* Look up BitTree node */
+	found = 0;
+	link = &(bt->root).rb_node;
+	parent = NULL;
+
+	while (*link) {
+		parent = *link;
+		bnode = rb_entry(parent, struct bmap_rbnode, node);
+
+		if (bnode->idx > node_offt) {
+			link = &(*link)->rb_left;
+		} else if (bnode->idx < node_offt) {
+			link = &(*link)->rb_right;
+		} else {
+			found = 1;
+			break;
+		}
+	}
+
+	/* If we're just reading bitmap values, return them now */
+	if (flags & BMAP_READ) {
+		ret = 0;
+
+		if (!found)
+			goto done;
+
+		/* First read seen bit */
+		res = bmap_read(bnode->seen, bnode->idx, idx);
+		if (res == -1) {
+			ret = -1;
+			goto done;
+		}
+		ret |= res << 2;
+
+		/* Then read relevant bit */
+		res = bmap_read(bnode->relv, bnode->idx, idx);
+		if (res == -1) {
+			ret = -1;
+			goto done;
+		}
+		ret |= res << 1;
+
+		/* Read done bit */
+		res = bmap_read(bnode->done, bnode->idx, idx);
+		if (res == -1) {
+			ret = -1;
+			goto done;
+		}
+
+		ret |= res;
+		goto done;
+	}
+
+	/*
+	 * Take appropriate action based on whether we found the node
+	 * and whether we plan to update (SET/RST), or only CHECK it.
+	 *
+	 *   NULL  |       Found            !Found      |
+	 *  -------+------------------------------------+
+	 *    SET  |     Set Bits     |  Init new node  |
+	 *         |------------------+-----------------|
+	 *    RST  | Clear (dispose?) |     Nothing     |
+	 *  -------+------------------------------------+
+	 *
+	 *  CHECK  |       Found            !Found      |
+	 *  -------+------------------------------------+
+	 *    SET  |    Check Bits    |  Return false   |
+	 *         |------------------+-----------------|
+	 *    RST  |    Check Bits    |    Continue     |
+	 *  -------+------------------------------------+
+	 */
+
+	/* First handle setting (or checking set) bits */
+	if (flags & BMAP_ALL_SET) {
+		if (!found && !(flags & BMAP_CHECK)) {
+			/* Insert the new node */
+			bnode = bnode_init(bt, node_offt);
+			if (!bnode) {
+				ret = -1;
+				goto done;
+			}
+
+			rb_link_node(&bnode->node, parent, link);
+			rb_insert_color(&bnode->node, &bt->root);
+
+		} else if (!found && (flags & BMAP_CHECK)) {
+			/* Looking for set bits, node didn't exist */
+			ret = 0;
+			goto done;
+		}
+
+		/* Set the bits. Return -1 if something goes wrong. */
+		if (!(flags & BMAP_CHECK)) {
+			if ((flags & BMAP_SEEN_SET) &&
+			    bmap_set(bnode->seen, bnode->idx, idx, 1)) {
+				ret = -1;
+				goto done;
+			}
+
+			if ((flags & BMAP_RELV_SET) &&
+			    bmap_set(bnode->relv, bnode->idx, idx, 1)) {
+				ret = -1;
+				goto done;
+			}
+
+			if ((flags & BMAP_DONE_SET) &&
+			    bmap_set(bnode->done, bnode->idx, idx, 1)) {
+				ret = -1;
+				goto done;
+			}
+
+		/* Check the bits. Return if any bits are off */
+		} else {
+			if (flags & BMAP_SEEN_SET) {
+				ret = bmap_chk(bnode->seen, bnode->idx, idx, 1);
+				if (ret != 1)
+					goto done;
+			}
+
+			if (flags & BMAP_RELV_SET) {
+				ret = bmap_chk(bnode->relv, bnode->idx, idx, 1);
+				if (ret != 1)
+					goto done;
+			}
+
+			ret = bmap_chk(bnode->done, bnode->idx, idx, 1);
+			if (ret != 1)
+				goto done;
+		}
+	}
+
+	/* Now handle unsetting any bits */
+	if (found && (flags & BMAP_ALL_RST)) {
+		/* Clear the bits. Return -1 if something goes wrong. */
+		if (!(flags & BMAP_CHECK)) {
+			if ((flags & BMAP_SEEN_RST) &&
+			    bmap_set(bnode->seen, bnode->idx, idx, 0)) {
+				ret = -1;
+				goto done;
+			}
+
+			if ((flags & BMAP_RELV_RST) &&
+			    bmap_set(bnode->relv, bnode->idx, idx, 0)) {
+				ret = -1;
+				goto done;
+			}
+
+			if ((flags & BMAP_DONE_RST) &&
+			    bmap_set(bnode->done, bnode->idx, idx, 0)) {
+				ret = -1;
+				goto done;
+			}
+
+		/* Check the bits. Return if any bits are off */
+		} else {
+			if (flags & BMAP_SEEN_RST) {
+				ret = bmap_chk(bnode->seen, bnode->idx, idx, 0);
+				if (ret != 1)
+					goto done;
+			}
+
+			if (flags & BMAP_RELV_RST) {
+				ret = bmap_chk(bnode->relv, bnode->idx, idx, 0);
+				if (ret != 1)
+					goto done;
+			}
+
+			ret = bmap_chk(bnode->done, bnode->idx, idx, 0);
+			if (ret != 1)
+				goto done;
+		}
+
+		/* Dispose of the node if empty */
+		if (!(flags & BMAP_CHECK) &&
+		    bitmap_empty(bnode->done, BITS_PER_NODE) &&
+		    bitmap_empty(bnode->seen, BITS_PER_NODE) &&
+		    bitmap_empty(bnode->relv, BITS_PER_NODE))
+			bnode_dispose(bnode, parent, bt);
+	}
+
+	if (!(flags & BMAP_CHECK))
+		ret = 0;
+	else
+		ret = 1;
+
+done:
+	if (ret == -1)
+		pr_err("duet: blocks were not %s\n",
+			(flags & BMAP_READ) ? "read" :
+			((flags & BMAP_CHECK) ? "checked" : "modified"));
+	spin_unlock(&bt->lock);
+	local_irq_restore(iflags);
+	return ret;
+}
+
+/*
+ * Check if we have seen this inode before. If not, check if it is relevant.
+ * Then, check whether it's done.
+ */
+static int do_bittree_check(struct duet_bittree *bt, struct duet_uuid uuid,
+			    struct duet_task *task, struct inode *inode)
+{
+	int ret, bits;
+	unsigned long long idx = UUID_IDX(uuid);
+
+	bits = __update_tree(bt, idx, BMAP_READ);
+
+	if (!(bits & 0x4)) {
+		/* We have not seen this inode before */
+		if (inode) {
+			ret = do_find_path(task, inode, 0, NULL, 0);
+		} else if (task) {
+			ret = duet_find_path(task, uuid, 0, NULL, 0);
+		} else {
+			pr_err("duet: check failed, no task/inode\n");
+			return -1;
+		}
+
+		if (!ret) {
+			/* Mark as relevant and return not done */
+			ret = __update_tree(bt, idx,
+					    BMAP_SEEN_SET | BMAP_RELV_SET);
+			if (ret != -1)
+				ret = 0;
+
+		} else if (ret == -ENOENT) {
+			/* Mark as irrelevant and return done */
+			ret = __update_tree(bt, idx, BMAP_SEEN_SET);
+			if (ret != -1)
+				ret = 1;
+
+		} else {
+			pr_err("duet: inode relevance undetermined\n");
+			return -1;
+		}
+
+	} else {
+		/* We know this inode, return 1 if done, or irrelevant */
+		ret = ((bits & 0x1) || !(bits & 0x2)) ? 1 : 0;
+	}
+
+	return ret;
+}
+
+/* Checks if a given inode is done. Skips inode lookup. */
+int bittree_check_inode(struct duet_bittree *bt, struct duet_task *task,
+	struct inode *inode)
+{
+	struct duet_uuid uuid;
+
+	uuid.ino = inode->i_ino;
+	uuid.gen = inode->i_generation;
+
+	return do_bittree_check(bt, uuid, task, inode);
+}
+
+/* Checks if the given entries are done */
+int bittree_check(struct duet_bittree *bt, struct duet_uuid uuid,
+		  struct duet_task *task)
+{
+	return do_bittree_check(bt, uuid, task, NULL);
+}
+
+/* Mark done bit for given entries */
+int bittree_set(struct duet_bittree *bt, struct duet_uuid uuid)
+{
+	return __update_tree(bt, UUID_IDX(uuid), BMAP_DONE_SET);
+}
+
+/* Unmark done bit for given entries */
+int bittree_reset(struct duet_bittree *bt, struct duet_uuid uuid)
+{
+	return __update_tree(bt, UUID_IDX(uuid), BMAP_DONE_RST);
+}
+
+int bittree_print(struct duet_task *task)
+{
+	struct bmap_rbnode *bnode = NULL;
+	struct rb_node *node;
+	unsigned long iflags;
+
+	local_irq_save(iflags);
+	spin_lock(&task->bittree.lock);
+	pr_info("duet: Printing task bittree\n");
+	node = rb_first(&task->bittree.root);
+	while (node) {
+		bnode = rb_entry(node, struct bmap_rbnode, node);
+
+		/* Print node information */
+		pr_info("duet: Node key = %llu\n", bnode->idx);
+		pr_info("duet:   Done bits set: %d out of %d\n",
+			bitmap_weight(bnode->done, BITS_PER_NODE),
+			BITS_PER_NODE);
+		pr_info("duet:   Relv bits set: %d out of %d\n",
+			bitmap_weight(bnode->relv, BITS_PER_NODE),
+			BITS_PER_NODE);
+		pr_info("duet:   Seen bits set: %d out of %d\n",
+			bitmap_weight(bnode->seen, BITS_PER_NODE),
+			BITS_PER_NODE);
+
+		node = rb_next(node);
+	}
+	spin_unlock(&task->bittree.lock);
+	local_irq_restore(iflags);
+
+	pr_info("duet: Task #%d bitmap has %d out of %lu bits set\n",
+		task->id, bitmap_weight(task->bucket_bmap,
+		duet_env.itm_hash_size), duet_env.itm_hash_size);
+
+	return 0;
+}
+
+void bittree_init(struct duet_bittree *bittree)
+{
+	spin_lock_init(&bittree->lock);
+	bittree->root = RB_ROOT;
+#ifdef CONFIG_DUET_STATS
+	bittree->statcur = bittree->statmax = 0;
+#endif /* CONFIG_DUET_STATS */
+}
+
+void bittree_destroy(struct duet_bittree *bittree)
+{
+	struct rb_node *rbnode;
+	struct bmap_rbnode *bnode;
+
+	while (!RB_EMPTY_ROOT(&bittree->root)) {
+		rbnode = rb_first(&bittree->root);
+		bnode = rb_entry(rbnode, struct bmap_rbnode, node);
+		bnode_dispose(bnode, rbnode, bittree);
+	}
+}
diff --git a/mm/duet/common.h b/mm/duet/common.h
new file mode 100644
index 0000000..1dac66b
--- /dev/null
+++ b/mm/duet/common.h
@@ -0,0 +1,211 @@
+/*
+ * Copyright (C) 2016 George Amvrosiadis.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License v2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+#ifndef _COMMON_H
+#define _COMMON_H
+
+#include <linux/fs.h>
+#include <linux/mount.h>
+#include <linux/slab.h>
+#include <linux/vmalloc.h>
+#include <linux/bitmap.h>
+#include <linux/rculist.h>
+#include <linux/syscalls.h>
+#include <linux/duet.h>
+
+#ifdef DUET_DEBUG
+#define duet_dbg(...)	pr_info(__VA_ARGS__)
+#else
+#define duet_dbg(...)
+#endif
+
+/*
+ * Duet can be state-based, and/or event-based.
+ *
+ * Event-based Duet monitors events that occurred on a page, during its
+ * time in the page cache: ADDED, REMOVED, DIRTY, and FLUSHED.
+ *
+ * State-based Duet monitors changes in the page cache since the last time
+ * a notification was sent to the interested application. Registering for
+ * EXIST informs the application of page additions or removals from the cache
+ * (i.e. ADDED and REMOVED events cancel each other out if the application
+ * hasn't been told in the meantime). Registering for MODIFIED events is a
+ * similar model, where unreported DIRTY and FLUSHED events cancel each other.
+ */
+#define DUET_PAGE_ADDED		0x0001
+#define DUET_PAGE_REMOVED	0x0002
+#define DUET_PAGE_DIRTY		0x0004
+#define DUET_PAGE_FLUSHED	0x0008
+#define DUET_PAGE_MODIFIED	0x0010
+#define DUET_PAGE_EXISTS	0x0020
+#define DUET_FD_NONBLOCK	0x0040
+
+/* Used only for page state */
+#define DUET_MASK_VALID		0x8000
+
+/* Some useful flags for clearing bitmaps */
+#define BMAP_SEEN	0x1
+#define BMAP_RELV	0x2
+#define BMAP_DONE	0x4
+
+#define DUET_DEF_NUMTASKS	8
+#define DUET_INODE_FREEING	(I_WILL_FREE | I_FREEING | I_CLEAR)
+
+enum {
+	DUET_STATUS_OFF = 0,
+	DUET_STATUS_ON,
+	DUET_STATUS_INIT,
+	DUET_STATUS_CLEAN,
+};
+
+/*
+ * Item struct returned for processing.
+ * The UUID currently consists of the inode number, the inode generation
+ * (to help us identify cases of inode reuse), and the task id.
+ * For state-based duet, we mark a page if it EXISTS or is MODIFIED.
+ * For event-based duet, we mark a page added, removed, dirtied, and/or flushed.
+ * Acceptable event combinations will differ based on the task's subscription.
+ */
+struct duet_uuid {
+	unsigned long	ino;
+	__u32		gen;
+	__u8		tid;
+};
+
+struct duet_item {
+	struct duet_uuid	uuid;
+	unsigned long		idx;
+	__u16			state;
+};
+
+/*
+ * Red-black bitmap tree node.
+ * Represents the range starting from idx. For block tasks, only the done
+ * bitmap is used. For file tasks, the seen and relv (relevant) bitmaps are
+ * also used. The semantics of different states are listed below, where an
+ * item can be in the unknown state due to a bitmap reset, or because it hasn't
+ * been encountered yet.
+ * - !SEEN && !RELV && !DONE: Item in unknown state
+ * - !SEEN && !RELV &&  DONE: Item processed, but in unknown state
+ * -  SEEN && !RELV && !DONE: Item not relevant to the task
+ * -  SEEN &&  RELV && !DONE: Item is relevant, but not processed
+ * -  SEEN &&  RELV &&  DONE: Item is relevant, and has already been processed
+ */
+struct bmap_rbnode {
+	__u64		idx;
+	struct rb_node	node;
+	unsigned long	*seen;
+	unsigned long	*relv;
+	unsigned long	*done;
+};
+
+struct item_hnode {
+	struct hlist_bl_node	node;
+	struct duet_item	item;
+	__u8			refcount;
+	__u16			*state;		/* One entry per task */
+};
+
+struct duet_bittree {
+	spinlock_t		lock;
+	struct rb_root		root;
+#ifdef CONFIG_DUET_STATS
+	__u64			statcur;	/* Cur # of BitTree nodes */
+	__u64			statmax;	/* Max # of BitTree nodes */
+#endif /* CONFIG_DUET_STATS */
+};
+
+struct duet_task {
+	__u8			id;		/* Internal task ID */
+
+	int			fd;
+	struct filename		*name;
+	__u32			evtmask;	/* Mask of subscribed events */
+	struct path		*regpath;	/* Registered path */
+	char			*regpathname;	/* Registered path name */
+	__u16			regpathlen;	/* Length of path name */
+
+	/* Data structures linking task to framework */
+	struct list_head	task_list;
+	wait_queue_head_t	cleaner_queue;
+	atomic_t		refcount;
+	char			*pathbuf;	/* Buffer for getpath */
+	struct duet_bittree	bittree;	/* Progress bitmap */
+	wait_queue_head_t	event_queue;	/* for read() and poll() */
+
+	/* Hash table bucket bitmap */
+	spinlock_t		bbmap_lock;
+	unsigned long		*bucket_bmap;
+	unsigned long		bmap_cursor;
+};
+
+struct duet_info {
+	atomic_t		status;
+	__u8			numtasks;	/* Number of concurrent tasks */
+
+	/*
+	 * Access to the task list is synchronized via a mutex. However, any
+	 * operations that are on-going for a task (e.g. fetch) will increase
+	 * its refcount. This refcount is consulted when disposing of the task.
+	 */
+	struct mutex		task_list_mutex;
+	struct list_head	tasks;
+
+	/* ItemTable -- Global page state hash table */
+	struct hlist_bl_head	*itm_hash_table;
+	unsigned long		itm_hash_size;
+	unsigned long		itm_hash_shift;
+	unsigned long		itm_hash_mask;
+};
+
+extern struct duet_info duet_env;
+
+/* hook.c */
+void duet_hook(__u16 evtcode, void *data);
+
+/* hash.c */
+int hash_init(void);
+int hash_add(struct duet_task *task, struct duet_uuid uuid,
+	     unsigned long idx, __u16 evtmask, short in_scan);
+int hash_fetch(struct duet_task *task, struct duet_item *itm);
+void hash_print(struct duet_task *task);
+
+/* task.c -- not in linux/duet.h */
+struct duet_task *duet_find_task(__u8 id);
+void duet_task_dispose(struct duet_task *task);
+
+/* path.c */
+int do_find_path(struct duet_task *task, struct inode *inode,
+		 int getpath, char *buf, int bufsize);
+int duet_find_path(struct duet_task *task, struct duet_uuid uuid,
+		   int getpath, char *buf, int bufsize);
+
+/* bittree.c */
+int bittree_check_inode(struct duet_bittree *bt, struct duet_task *task,
+			struct inode *inode);
+int bittree_check(struct duet_bittree *bt, struct duet_uuid uuid,
+		  struct duet_task *task);
+int bittree_set(struct duet_bittree *bt, struct duet_uuid uuid);
+int bittree_reset(struct duet_bittree *bt, struct duet_uuid uuid);
+int bittree_print(struct duet_task *task);
+void bittree_init(struct duet_bittree *bittree);
+void bittree_destroy(struct duet_bittree *bittree);
+
+/* init.c */
+int duet_online(void);
+
+/* debug.c */
+int duet_print_bmap(__u8 id);
+int duet_print_item(__u8 id);
+int duet_print_list(struct duet_status_args __user *arg);
+
+#endif /* _COMMON_H */
diff --git a/mm/duet/debug.c b/mm/duet/debug.c
new file mode 100644
index 0000000..77a47b6
--- /dev/null
+++ b/mm/duet/debug.c
@@ -0,0 +1,98 @@
+/*
+ * Copyright (C) 2016 George Amvrosiadis.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License v2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+
+#include "common.h"
+#include "syscall.h"
+
+/* Do a preorder print of the BitTree */
+int duet_print_bmap(__u8 id)
+{
+	struct duet_task *task;
+
+	task = duet_find_task(id);
+	if (!task)
+		return -ENOENT;
+
+	if (bittree_print(task)) {
+		pr_err("duet: failed to print BitTree for task #%d\n",
+			task->id);
+		return -1;
+	}
+
+	/* decref and wake up cleaner if needed */
+	if (atomic_dec_and_test(&task->refcount))
+		wake_up(&task->cleaner_queue);
+
+	return 0;
+}
+
+/* Do a preorder print of the global hash table */
+int duet_print_item(__u8 id)
+{
+	struct duet_task *task;
+
+	task = duet_find_task(id);
+	if (!task)
+		return -ENOENT;
+
+	hash_print(task);
+
+	/* decref and wake up cleaner if needed */
+	if (atomic_dec_and_test(&task->refcount))
+		wake_up(&task->cleaner_queue);
+
+	return 0;
+}
+
+int duet_print_list(struct duet_status_args __user *arg)
+{
+	int i = 0;
+	struct duet_task *cur;
+	struct duet_status_args argh, *argp;
+
+	/* Copy in task list header (again) */
+	if (copy_from_user(&argh, arg, sizeof(argh)))
+		return -EFAULT;
+
+	/* Copy in entire task list */
+	argp = memdup_user(arg, sizeof(*argp) + (argh.numtasks *
+				sizeof(struct duet_task_attrs)));
+	if (IS_ERR(argp))
+		return PTR_ERR(argp);
+
+	/* Copy the info for the first numtasks */
+	mutex_lock(&duet_env.task_list_mutex);
+	list_for_each_entry(cur, &duet_env.tasks, task_list) {
+		argp->tasks[i].id = cur->id;
+		argp->tasks[i].fd = cur->fd;
+		memcpy(argp->tasks[i].name, cur->name->name, NAME_MAX);
+		argp->tasks[i].regmask = cur->evtmask;
+		memcpy(argp->tasks[i].path, cur->regpathname, cur->regpathlen);
+		i++;
+		if (i == argp->numtasks)
+			break;
+	}
+	mutex_unlock(&duet_env.task_list_mutex);
+
+	/* Copy out entire task list */
+	if (copy_to_user(arg, argp, sizeof(*argp) + (argp->numtasks *
+			 sizeof(struct duet_task_attrs)))) {
+		pr_err("duet_print_list: failed to copy out list\n");
+		kfree(argp);
+		return -EINVAL;
+	}
+
+	duet_dbg("duet_print_list: success sending task list\n");
+	kfree(argp);
+	return 0;
+}
diff --git a/mm/duet/hash.c b/mm/duet/hash.c
new file mode 100644
index 0000000..c2644d6
--- /dev/null
+++ b/mm/duet/hash.c
@@ -0,0 +1,315 @@
+/*
+ * Copyright (C) 2016 George Amvrosiadis.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License v2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+
+#include <linux/hash.h>
+#include "common.h"
+
+#define DUET_NEGATE_EXISTS	(DUET_PAGE_ADDED | DUET_PAGE_REMOVED)
+#define DUET_NEGATE_MODIFIED	(DUET_PAGE_DIRTY | DUET_PAGE_FLUSHED)
+
+/*
+ * Page state is retained in a global hash table shared by all tasks.
+ * Indexing is based on the page's inode number and offset.
+ */
+
+static unsigned long hash(unsigned long ino, unsigned long idx)
+{
+	unsigned long h;
+
+	h = (idx * ino ^ (GOLDEN_RATIO_PRIME + idx)) / L1_CACHE_BYTES;
+	h = h ^ ((h ^ GOLDEN_RATIO_PRIME) >> duet_env.itm_hash_shift);
+	return h & duet_env.itm_hash_mask;
+}
+
+int hash_init(void)
+{
+	/* Allocate power-of-2 number of buckets */
+	duet_env.itm_hash_shift = ilog2(totalram_pages);
+	duet_env.itm_hash_size = 1 << duet_env.itm_hash_shift;
+	duet_env.itm_hash_mask = duet_env.itm_hash_size - 1;
+
+	pr_debug("duet: allocated global hash table (%lu buckets)\n",
+		duet_env.itm_hash_size);
+	duet_env.itm_hash_table = vmalloc(sizeof(struct hlist_bl_head) *
+						duet_env.itm_hash_size);
+	if (!duet_env.itm_hash_table)
+		return 1;
+
+	memset(duet_env.itm_hash_table, 0, sizeof(struct hlist_bl_head) *
+						duet_env.itm_hash_size);
+	return 0;
+}
+
+/* Deallocate a hash table node */
+static void hnode_destroy(struct item_hnode *itnode)
+{
+	kfree(itnode->state);
+	kfree(itnode);
+}
+
+/* Allocate and initialize a new hash table node */
+static struct item_hnode *hnode_init(struct duet_uuid uuid, unsigned long idx)
+{
+	struct item_hnode *itnode = NULL;
+
+	itnode = kzalloc(sizeof(struct item_hnode), GFP_NOWAIT);
+	if (!itnode)
+		return NULL;
+
+	itnode->state = kcalloc(duet_env.numtasks, sizeof(*(itnode->state)),
+				GFP_NOWAIT);
+	if (!(itnode->state)) {
+		pr_err("duet: failed to allocate hash node state\n");
+		kfree(itnode);
+		return NULL;
+	}
+
+	(itnode->item).uuid = uuid;
+	(itnode->item).idx = idx;
+	itnode->refcount++;
+
+	return itnode;
+}
+
+/* Add one event into the hash table */
+int hash_add(struct duet_task *task, struct duet_uuid uuid, unsigned long idx,
+	__u16 evtmask, short in_scan)
+{
+	__u16 curmask = 0;
+	short found = 0;
+	unsigned long bnum, flags;
+	struct hlist_bl_head *b;
+	struct hlist_bl_node *n;
+	struct item_hnode *itnode;
+
+	evtmask &= task->evtmask;
+
+	/* Get the bucket */
+	bnum = hash(uuid.ino, idx);
+	b = duet_env.itm_hash_table + bnum;
+	local_irq_save(flags);
+	hlist_bl_lock(b);
+
+	/* Lookup the item in the bucket */
+	hlist_bl_for_each_entry(itnode, n, b, node) {
+		if ((itnode->item).uuid.ino == uuid.ino &&
+		    (itnode->item).uuid.gen == uuid.gen &&
+		    (itnode->item).idx == idx) {
+			found = 1;
+			break;
+		}
+	}
+
+	duet_dbg("duet: %s hash node (tid %d, ino%lu, gen%lu, idx%lu)\n",
+		found ? (in_scan ? "replacing" : "updating") : "inserting",
+		uuid.tid, uuid.ino, uuid.gen, idx);
+
+	if (found) {
+		curmask = itnode->state[task->id];
+
+		/* Only up the refcount if we are adding a new mask */
+		if (!(curmask & DUET_MASK_VALID) || in_scan) {
+			if (!in_scan)
+				itnode->refcount++;
+			curmask = evtmask | DUET_MASK_VALID;
+			goto check_dispose;
+		}
+
+		curmask |= evtmask | DUET_MASK_VALID;
+
+		/* Negate previous events and remove if needed */
+		if ((task->evtmask & DUET_PAGE_EXISTS) &&
+		   ((curmask & DUET_NEGATE_EXISTS) == DUET_NEGATE_EXISTS))
+			curmask &= ~DUET_NEGATE_EXISTS;
+
+		if ((task->evtmask & DUET_PAGE_MODIFIED) &&
+		   ((curmask & DUET_NEGATE_MODIFIED) == DUET_NEGATE_MODIFIED))
+			curmask &= ~DUET_NEGATE_MODIFIED;
+
+check_dispose:
+		if ((curmask == DUET_MASK_VALID) && (itnode->refcount == 1)) {
+			if (itnode->refcount != 1) {
+				itnode->state[task->id] = 0;
+			} else {
+				hlist_bl_del(&itnode->node);
+				hnode_destroy(itnode);
+			}
+
+			/* Are we still interested in this bucket? */
+			hlist_bl_for_each_entry(itnode, n, b, node) {
+				if (itnode->state[task->id] & DUET_MASK_VALID) {
+					found = 1;
+					break;
+				}
+			}
+
+			if (!found)
+				clear_bit(bnum, task->bucket_bmap);
+		} else {
+			itnode->state[task->id] = curmask;
+
+			/* Update bitmap */
+			set_bit(bnum, task->bucket_bmap);
+		}
+	} else if (!found) {
+		if (!evtmask)
+			goto done;
+
+		itnode = hnode_init(uuid, idx);
+		if (!itnode)
+			return 1;
+
+		itnode->state[task->id] = evtmask | DUET_MASK_VALID;
+		hlist_bl_add_head(&itnode->node, b);
+
+		/* Update bitmap */
+		set_bit(bnum, task->bucket_bmap);
+	}
+
+done:
+	hlist_bl_unlock(b);
+	local_irq_restore(flags);
+	return 0;
+}
+
+/* Fetch one item for a given task. Return found (1), empty (0), error (-1) */
+int hash_fetch(struct duet_task *task, struct duet_item *itm)
+{
+	int found;
+	unsigned long bnum, flags;
+	struct hlist_bl_head *b;
+	struct hlist_bl_node *n;
+	struct item_hnode *itnode;
+
+	local_irq_save(flags);
+again:
+	spin_lock(&task->bbmap_lock);
+	bnum = find_next_bit(task->bucket_bmap, duet_env.itm_hash_size,
+			     task->bmap_cursor);
+
+	if (bnum == duet_env.itm_hash_size) {
+		/* Reached end of bitmap */
+		found = 0;
+
+		if (task->bmap_cursor != 0) {
+			/* Started part way, try again */
+			bnum = find_next_bit(task->bucket_bmap,
+					     task->bmap_cursor, 0);
+
+			if (bnum != task->bmap_cursor)
+				found = 1;
+		}
+
+		if (!found) {
+			spin_unlock(&task->bbmap_lock);
+			local_irq_restore(flags);
+			return 1;
+		}
+	}
+
+	task->bmap_cursor = bnum;
+	clear_bit(bnum, task->bucket_bmap);
+	spin_unlock(&task->bbmap_lock);
+	b = duet_env.itm_hash_table + bnum;
+
+	/* Grab first item from bucket */
+	hlist_bl_lock(b);
+	if (!b->first) {
+		pr_err("duet: empty hash bucket marked in bitmap\n");
+		hlist_bl_unlock(b);
+		goto again;
+	}
+
+	found = 0;
+	hlist_bl_for_each_entry(itnode, n, b, node) {
+		if (itnode->state[task->id] & DUET_MASK_VALID) {
+			*itm = itnode->item;
+			itm->uuid.tid = task->id;
+			itm->state = itnode->state[task->id] &
+				     (~DUET_MASK_VALID);
+
+			itnode->refcount--;
+			/* Free or update node */
+			if (!itnode->refcount) {
+				hlist_bl_del(n);
+				hnode_destroy(itnode);
+			} else {
+				itnode->state[task->id] = 0;
+			}
+
+			found = 1;
+			break;
+		}
+	}
+
+	if (!found) {
+		hlist_bl_unlock(b);
+		goto again;
+	}
+
+	/* Are we still interested in this bucket? */
+	found = 0;
+	hlist_bl_for_each_entry(itnode, n, b, node) {
+		if (itnode->state[task->id] & DUET_MASK_VALID) {
+			found = 1;
+			break;
+		}
+	}
+
+	if (found)
+		set_bit(bnum, task->bucket_bmap);
+
+	hlist_bl_unlock(b);
+	local_irq_restore(flags);
+	return 0;
+}
+
+/* Warning: expensive printing function. Use with care. */
+void hash_print(struct duet_task *task)
+{
+	unsigned long loop, count, start, end, buckets, flags;
+	unsigned long long nodes, tnodes;
+	struct hlist_bl_head *b;
+	struct hlist_bl_node *n;
+	struct item_hnode *itnode;
+
+	count = duet_env.itm_hash_size / 100;
+	tnodes = nodes = buckets = start = end = 0;
+	pr_info("duet: Printing hash table\n");
+	for (loop = 0; loop < duet_env.itm_hash_size; loop++) {
+		if (loop - start >= count) {
+			pr_info("duet:   Buckets %lu - %lu: %llu nodes (task: %llu)\n",
+				start, end, nodes, tnodes);
+			start = end = loop;
+			nodes = tnodes = 0;
+		}
+
+		/* Count bucket nodes */
+		b = duet_env.itm_hash_table + loop;
+		local_irq_save(flags);
+		hlist_bl_lock(b);
+		hlist_bl_for_each_entry(itnode, n, b, node) {
+			nodes++;
+			if (itnode->state[task->id] & DUET_MASK_VALID)
+				tnodes++;
+		}
+		hlist_bl_unlock(b);
+		local_irq_restore(flags);
+
+		end = loop;
+	}
+
+	if (start != loop - 1)
+		pr_info("duet:   Buckets %lu - %lu: %llu nodes (task: %llu)\n",
+			start, end, nodes, tnodes);
+}
diff --git a/mm/duet/hook.c b/mm/duet/hook.c
new file mode 100644
index 0000000..3ac89f5
--- /dev/null
+++ b/mm/duet/hook.c
@@ -0,0 +1,81 @@
+/*
+ * Copyright (C) 2016 George Amvrosiadis.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License v2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+
+#include "common.h"
+
+/* Handle an event. We're in RCU context so whatever happens, stay awake! */
+void duet_hook(__u16 evtcode, void *data)
+{
+	struct page *page = NULL;
+	struct inode *inode = NULL;
+	struct duet_task *cur;
+	unsigned long page_idx = 0;
+	struct duet_uuid uuid;
+
+	/* Duet must be online */
+	if (!duet_online())
+		return;
+
+	/* Handle page event */
+	page = (struct page *)data;
+
+	/* Duet must be online, and the page must belong to a valid mapping */
+	if (!page || !page_mapping(page)) {
+		duet_dbg("duet: dropped event %x due to NULL mapping\n",
+			evtcode);
+		return;
+	}
+
+	inode = page_mapping(page)->host;
+	page_idx = page->index;
+
+	/* Check that we're referring to an actual inode and get its UUID */
+	if (!inode)
+		return;
+
+	uuid.ino = inode->i_ino;
+	uuid.gen = inode->i_generation;
+
+	/* Verify that the inode does not belong to a special file */
+	if (!S_ISREG(inode->i_mode) && !S_ISDIR(inode->i_mode))
+		return;
+
+	if (!inode->i_ino) {
+		pr_err("duet: inode not initialized\n");
+		return;
+	}
+
+	/* Look for tasks interested in this event type and invoke callbacks */
+	rcu_read_lock();
+	list_for_each_entry_rcu(cur, &duet_env.tasks, task_list) {
+		struct super_block *sb = cur->regpath->mnt->mnt_sb;
+
+		/* Verify that the event refers to the fs we're interested in */
+		if (sb && sb != inode->i_sb)
+			continue;
+
+		duet_dbg("duet: rcvd event %x on (ino %lu, gen %lu, idx %lu)\n",
+			evtcode, uuid.ino, uuid.gen, page_idx);
+
+		/* Use the inode bitmap to filter out event if applicable */
+		if (bittree_check_inode(&cur->bittree, cur, inode) == 1)
+			continue;
+
+		/* Update the hash table */
+		if (hash_add(cur, uuid, page_idx, evtcode, 0))
+			pr_err("duet: hash table add failed\n");
+
+		wake_up(&cur->event_queue);
+	}
+	rcu_read_unlock();
+}
diff --git a/mm/duet/init.c b/mm/duet/init.c
new file mode 100644
index 0000000..a9e5ea1
--- /dev/null
+++ b/mm/duet/init.c
@@ -0,0 +1,172 @@
+/*
+ * Copyright (C) 2016 George Amvrosiadis.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License v2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+
+#include "common.h"
+#include "syscall.h"
+
+struct duet_info duet_env;
+duet_hook_t *duet_hook_fp;
+EXPORT_SYMBOL(duet_hook_fp);
+
+int duet_online(void)
+{
+	return (atomic_read(&duet_env.status) == DUET_STATUS_ON);
+}
+
+int duet_bootstrap(__u16 numtasks)
+{
+	if (atomic_cmpxchg(&duet_env.status, DUET_STATUS_OFF, DUET_STATUS_INIT)
+	    != DUET_STATUS_OFF) {
+		pr_err("duet: framework on, bootstrap aborted\n");
+		return 1;
+	}
+
+	duet_env.numtasks = (numtasks ? numtasks : DUET_DEF_NUMTASKS);
+
+	/* Initialize global hash table */
+	if (hash_init()) {
+		pr_err("duet: failed to initialize hash table\n");
+		return 1;
+	}
+
+	/* Initialize task list */
+	INIT_LIST_HEAD(&duet_env.tasks);
+	mutex_init(&duet_env.task_list_mutex);
+	atomic_set(&duet_env.status, DUET_STATUS_ON);
+
+	rcu_assign_pointer(duet_hook_fp, duet_hook);
+	synchronize_rcu();
+	return 0;
+}
+
+int duet_shutdown(void)
+{
+	struct duet_task *task;
+
+	if (atomic_cmpxchg(&duet_env.status, DUET_STATUS_ON, DUET_STATUS_CLEAN)
+	    != DUET_STATUS_ON) {
+		pr_err("duet: framework off, shutdown aborted\n");
+		return 1;
+	}
+
+	rcu_assign_pointer(duet_hook_fp, NULL);
+	synchronize_rcu();
+
+	/* Remove all tasks */
+	mutex_lock(&duet_env.task_list_mutex);
+	while (!list_empty(&duet_env.tasks)) {
+		task = list_entry_rcu(duet_env.tasks.next, struct duet_task,
+				task_list);
+		list_del_rcu(&task->task_list);
+		mutex_unlock(&duet_env.task_list_mutex);
+
+		/* Make sure everyone's let go before we free it */
+		synchronize_rcu();
+		wait_event(task->cleaner_queue,
+			atomic_read(&task->refcount) == 0);
+		duet_task_dispose(task);
+
+		mutex_lock(&duet_env.task_list_mutex);
+	}
+	mutex_unlock(&duet_env.task_list_mutex);
+
+	/* Destroy global hash table */
+	vfree((void *)duet_env.itm_hash_table);
+
+	INIT_LIST_HEAD(&duet_env.tasks);
+	mutex_destroy(&duet_env.task_list_mutex);
+	atomic_set(&duet_env.status, DUET_STATUS_OFF);
+	return 0;
+}
+
+SYSCALL_DEFINE2(duet_status, u16, flags, struct duet_status_args __user *, arg)
+{
+	int ret = 0;
+	struct duet_status_args *sa;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	sa = memdup_user(arg, sizeof(*sa));
+	if (IS_ERR(sa))
+		return PTR_ERR(sa);
+
+	/* For now, we only support one struct size */
+	if (sa->size != sizeof(*sa)) {
+		pr_err("duet_status: invalid args struct size (%u)\n",
+			sa->size);
+		ret = -EINVAL;
+		goto done;
+	}
+
+	/* If we're cleaning up, only allow ops that affect Duet status */
+	if (atomic_read(&duet_env.status) != DUET_STATUS_ON && !(flags &
+	    (DUET_STATUS_START | DUET_STATUS_STOP | DUET_STATUS_REPORT))) {
+		pr_err("duet_status: ops rejected during shutdown\n");
+		ret = -EINVAL;
+		goto done;
+	}
+
+	switch (flags) {
+	case DUET_STATUS_START:
+		ret = duet_bootstrap(sa->maxtasks);
+
+		if (ret)
+			pr_err("duet: failed to enable framework\n");
+		else
+			pr_info("duet: framework enabled\n");
+
+		break;
+
+	case DUET_STATUS_STOP:
+		ret = duet_shutdown();
+
+		if (ret)
+			pr_err("duet: failed to disable framework\n");
+		else
+			pr_info("duet: framework disabled\n");
+
+		break;
+
+	case DUET_STATUS_REPORT:
+		ret = duet_online();
+		break;
+
+	case DUET_STATUS_PRINT_BMAP:
+		ret = duet_print_bmap(sa->id);
+		break;
+
+	case DUET_STATUS_PRINT_ITEM:
+		ret = duet_print_item(sa->id);
+		break;
+
+	case DUET_STATUS_PRINT_LIST:
+		ret = duet_print_list(arg);
+		goto done;
+
+	default:
+		pr_info("duet_status: invalid flags\n");
+		ret = -EINVAL;
+		goto done;
+	}
+
+	if (copy_to_user(arg, sa, sizeof(*sa))) {
+		pr_err("duet_status: copy_to_user failed\n");
+		ret = -EINVAL;
+		goto done;
+	}
+
+done:
+	kfree(sa);
+	return ret;
+}
diff --git a/mm/duet/path.c b/mm/duet/path.c
new file mode 100644
index 0000000..103ab42
--- /dev/null
+++ b/mm/duet/path.c
@@ -0,0 +1,184 @@
+/*
+ * Copyright (C) 2016 George Amvrosiadis.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License v2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+
+#include "common.h"
+#include "syscall.h"
+
+/* Scan through the page cache for a given inode */
+static int find_get_inode(struct super_block *sb, struct duet_uuid c_uuid,
+	struct inode **c_inode)
+{
+	struct inode *inode = NULL;
+
+	*c_inode = NULL;
+	spin_lock(&sb->s_inode_list_lock);
+	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
+		spin_lock(&inode->i_lock);
+		if (!*c_inode && inode->i_ino == c_uuid.ino &&
+		    inode->i_generation == c_uuid.gen &&
+		    !(inode->i_state & DUET_INODE_FREEING)) {
+			atomic_inc(&inode->i_count);
+			*c_inode = inode;
+			spin_unlock(&inode->i_lock);
+			spin_unlock(&sb->s_inode_list_lock);
+			return 0;
+		}
+		spin_unlock(&inode->i_lock);
+	}
+	spin_unlock(&sb->s_inode_list_lock);
+
+	/* We shouldn't get here unless we failed */
+	return 1;
+}
+
+int do_find_path(struct duet_task *task, struct inode *inode, int getpath,
+	char *buf, int bufsize)
+{
+	int len;
+	char *p;
+	struct path path;
+	struct dentry *alias, *i_dentry = NULL;
+
+	if (!task) {
+		pr_err("do_find_path: invalid task\n");
+		return -EINVAL;
+	}
+
+	if (getpath)
+		buf[0] = '\0';
+
+	/* Get the path for at least one alias of the inode */
+	if (hlist_empty(&inode->i_dentry))
+		return -ENOENT;
+
+	hlist_for_each_entry(alias, &inode->i_dentry, d_u.d_alias) {
+		if (IS_ROOT(alias) && (alias->d_flags & DCACHE_DISCONNECTED))
+			continue;
+
+		i_dentry = alias;
+
+		/* Now get the path */
+		len = PATH_MAX;
+		memset(task->pathbuf, 0, len);
+		path.mnt = task->regpath->mnt;
+		path.dentry = i_dentry;
+
+		p = d_path(&path, task->pathbuf, len);
+		if (IS_ERR(p)) {
+			pr_err("do_find_path: d_path failed\n");
+			continue;
+		} else if (!p) {
+			duet_dbg("do_find_path: dentry not found\n");
+			continue;
+		}
+
+		/* Is this path of interest? */
+		if (memcmp(task->regpathname, p, task->regpathlen - 1)) {
+			duet_dbg("do_find_path: no common ancestor\n");
+			continue;
+		}
+
+		/* Got one. If it fits, return it */
+		if (getpath && (bufsize < len - (p - task->pathbuf)))
+			return -ENOMEM;
+
+		duet_dbg("do_find_path: got %s\n", p);
+		if (getpath)
+			memcpy(buf, p, len - (p - task->pathbuf));
+
+		return 0;
+	}
+
+	/* We only get here if we got nothing */
+	return -ENOENT;
+}
+
+int duet_find_path(struct duet_task *task, struct duet_uuid uuid, int getpath,
+	char *buf, int bufsize)
+{
+	int ret = 0;
+	struct inode *ino;
+
+	if (!task) {
+		pr_err("duet_find_path: invalid task\n");
+		return -EINVAL;
+	}
+
+	/* First, we need to find struct inode for child and parent */
+	if (find_get_inode(task->regpath->mnt->mnt_sb, uuid, &ino)) {
+		duet_dbg("duet_find_path: child inode not found\n");
+		return -ENOENT;
+	}
+
+	ret = do_find_path(task, ino, getpath, buf, bufsize);
+
+	iput(ino);
+	return ret;
+}
+
+SYSCALL_DEFINE3(duet_get_path, struct duet_uuid_arg __user *, uuid,
+		char __user *, pathbuf, int, pathbufsize)
+{
+	int ret = 0;
+	struct duet_uuid_arg *ua;
+	struct duet_task *task;
+	char *buf;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	if (!duet_online())
+		return -ESRCH;
+
+	/* Do some basic sanity checking */
+	if (!uuid || pathbufsize <= 0)
+		return -EINVAL;
+
+	buf = kcalloc(pathbufsize, sizeof(char), GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	ua = memdup_user(uuid, sizeof(*uuid));
+	if (IS_ERR(ua)) {
+		kfree(buf);
+		return PTR_ERR(ua);
+	}
+
+	/* For now, we only support one struct size */
+	if (ua->size != sizeof(*ua)) {
+		pr_err("duet_get_path: invalid args struct size (%u)\n",
+			ua->size);
+		ret = -EINVAL;
+		goto done;
+	}
+
+	task = duet_find_task(ua->uuid.tid);
+	if (!task) {
+		ret = -ENOENT;
+		goto done;
+	}
+
+	ret = duet_find_path(task, ua->uuid, 1, buf, pathbufsize);
+
+	if (!ret && copy_to_user(pathbuf, buf, pathbufsize))
+		ret = -EFAULT;
+
+	/* decref and wake up cleaner if needed */
+	if (atomic_dec_and_test(&task->refcount))
+		wake_up(&task->cleaner_queue);
+
+done:
+	kfree(ua);
+	kfree(buf);
+	return ret;
+}
diff --git a/mm/duet/syscall.h b/mm/duet/syscall.h
new file mode 100644
index 0000000..1bc6830
--- /dev/null
+++ b/mm/duet/syscall.h
@@ -0,0 +1,61 @@
+/*
+ * Copyright (C) 2016 George Amvrosiadis.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License v2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+
+#include "common.h"
+
+/* Status syscall flags */
+#define DUET_STATUS_START	0x0001
+#define DUET_STATUS_STOP	0x0002
+#define DUET_STATUS_REPORT	0x0004
+#define DUET_STATUS_PRINT_BMAP	0x0008
+#define DUET_STATUS_PRINT_ITEM	0x0010
+#define DUET_STATUS_PRINT_LIST	0x0020
+
+struct duet_task_attrs {
+	__u8	id;
+	int	fd;
+	char	name[NAME_MAX];
+	__u32	regmask;
+	char	path[PATH_MAX];
+};
+
+struct duet_status_args {
+	__u32 size;						/* in */
+	union {
+		/* DUET_START args */
+		struct {
+			__u16 maxtasks;				/* in */
+		};
+
+		/* DUET_PRINT_BIT, DUET_PRINT_ITEM args */
+		struct {
+			__u8 id;				/* in */
+		};
+
+		/* DUET_PRINT_LIST args */
+		struct {
+			__u16 numtasks;				/* out */
+			struct duet_task_attrs tasks[0];	/* out */
+		};
+	};
+};
+
+/* Bmap syscall flags */
+#define DUET_BMAP_SET		0x0001
+#define DUET_BMAP_RESET		0x0002
+#define DUET_BMAP_CHECK		0x0004
+
+struct duet_uuid_arg {
+	__u32			size;
+	struct duet_uuid	uuid;
+};
diff --git a/mm/duet/task.c b/mm/duet/task.c
new file mode 100644
index 0000000..c91fad3
--- /dev/null
+++ b/mm/duet/task.c
@@ -0,0 +1,584 @@
+/*
+ * Copyright (C) 2016 George Amvrosiadis.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License v2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+
+#include <linux/namei.h>
+#include <linux/anon_inodes.h>
+#include "common.h"
+#include "syscall.h"
+
+/*
+ * To synchronize access to the task list and structures without compromising
+ * scalability, a two-level approach is used. At the task list level, which is
+ * rarely updated, RCU is used. For the task structures, we use traditional
+ * reference counting. The two techniques are interweaved to achieve overall
+ * consistency.
+ */
+
+static unsigned int duet_poll(struct file *file, poll_table *wait)
+{
+	__u8 *tid = file->private_data;
+	struct duet_task *task;
+	int ret = 0;
+
+	task = duet_find_task(*tid);
+	if (!task) {
+		pr_err("duet_poll: task not found\n");
+		return ret;
+	}
+
+	poll_wait(file, &task->event_queue, wait);
+	if (bitmap_weight(task->bucket_bmap, duet_env.itm_hash_size))
+		ret = POLLIN | POLLRDNORM;
+
+	return ret;
+}
+
+/*
+ * Copy an item to user space, returning how much we copied.
+ *
+ * We already checked that the event size is smaller than the
+ * buffer we had in duet_read() below.
+ */
+static ssize_t copy_item_to_user(struct duet_task *task,
+				 struct duet_item *item,
+				 char __user *buf)
+{
+	size_t item_size = sizeof(struct duet_item);
+
+	/* Send the item */
+	if (copy_to_user(buf, item, item_size))
+		return -EFAULT;
+
+	buf += item_size;
+
+	duet_dbg("duet_read: sending (ino%lu, gen%u, idx%lu, %x)\n",
+		 item->uuid.ino, item->uuid.gen, item->idx, item->state);
+
+	return item_size;
+}
+
+/*
+ * Sends out duet items. The number of bytes returned corresponds to the number
+ * of sizeof(struct duet_item) items fetched. Items are checked against the
+ * bitmap, and discarded if they have been marked; this can happen because an
+ * insertion can occur between the last read and the last bitmap set operation.
+ */
+static ssize_t duet_read(struct file *file, char __user *buf,
+			 size_t count, loff_t *pos)
+{
+	struct duet_task *task;
+	struct duet_item item;
+	char __user *start;
+	int ret, err;
+	__u8 *tid;
+	DEFINE_WAIT_FUNC(wait, woken_wake_function);
+
+	start = buf;
+	tid = file->private_data;
+
+	task = duet_find_task(*tid);
+	if (!task)
+		return -ENOENT;
+
+	add_wait_queue(&task->event_queue, &wait);
+	while (1) {
+		/* Fetch an item only if there's space to store it */
+		if (sizeof(struct duet_item) > count)
+			err = -EINVAL;
+		else
+			err = hash_fetch(task, &item);
+
+		if (!err) {
+			ret = copy_item_to_user(task, &item, buf);
+			if (ret < 0)
+				break;
+			buf += ret;
+			count -= ret;
+			continue;
+		}
+
+		ret = -EAGAIN;
+		if (file->f_flags & O_NONBLOCK)
+			break;
+		ret = -ERESTARTSYS;
+		if (signal_pending(current))
+			break;
+
+		if (start != buf)
+			break;
+
+		wait_woken(&wait, TASK_INTERRUPTIBLE, MAX_SCHEDULE_TIMEOUT);
+	}
+	remove_wait_queue(&task->event_queue, &wait);
+
+	if (start != buf && ret != -EFAULT)
+		ret = buf - start;
+
+	/* Decref and wake up cleaner if needed */
+	if (atomic_dec_and_test(&task->refcount))
+		wake_up(&task->cleaner_queue);
+
+	return ret;
+}
+
+/*
+ * Properly dismantle and dispose of a task struct.
+ * At this point we've guaranteed that noone else is accessing the
+ * task struct, so we don't need any locks
+ */
+void duet_task_dispose(struct duet_task *task)
+{
+	int ret = 0;
+	struct duet_item itm;
+
+	/* Dispose of the bitmap tree */
+	bittree_destroy(&task->bittree);
+
+	/* Dispose of hash table entries, bucket bitmap */
+	while (!ret)
+		ret = hash_fetch(task, &itm);
+	kfree(task->bucket_bmap);
+
+	putname(task->name);
+	path_put(task->regpath);
+	kfree(task->regpath);
+	kfree(task->regpathname);
+	kfree(task->pathbuf);
+	kfree(task);
+}
+
+static int duet_release(struct inode *ignored, struct file *file)
+{
+	__u8 *tid = file->private_data;
+	struct duet_task *cur;
+
+	/* Find the task in the list, then dispose of it */
+	mutex_lock(&duet_env.task_list_mutex);
+	list_for_each_entry_rcu(cur, &duet_env.tasks, task_list) {
+		if (cur->id == *tid) {
+#ifdef CONFIG_DUET_STATS
+			hash_print(cur);
+			bittree_print(cur);
+#endif /* CONFIG_DUET_STATS */
+			list_del_rcu(&cur->task_list);
+			mutex_unlock(&duet_env.task_list_mutex);
+
+			/* Wait until everyone's done with it */
+			synchronize_rcu();
+			wait_event(cur->cleaner_queue,
+				atomic_read(&cur->refcount) == 0);
+
+			pr_info("duet: deregistered task %d\n",	cur->id);
+
+			duet_task_dispose(cur);
+			kfree(tid);
+			return 0;
+		}
+	}
+	mutex_unlock(&duet_env.task_list_mutex);
+
+	return -ENOENT;
+}
+
+static const struct file_operations duet_fops = {
+	.show_fdinfo	= NULL,
+	.poll		= duet_poll,
+	.read		= duet_read,
+	.fasync		= NULL,
+	.release	= duet_release,
+	.unlocked_ioctl	= NULL,
+	.compat_ioctl	= NULL,
+	.llseek		= noop_llseek,
+};
+
+static int process_inode(struct duet_task *task, struct inode *inode)
+{
+	struct radix_tree_iter iter;
+	struct duet_uuid uuid;
+	void **slot;
+	__u16 state;
+
+	/* Use the inode bitmap to decide whether to skip inode */
+	if (bittree_check_inode(&task->bittree, task, inode) == 1)
+		return 0;
+
+	/* Go through all pages of this inode */
+	rcu_read_lock();
+	radix_tree_for_each_slot(slot, &inode->i_mapping->page_tree, &iter, 0) {
+		struct page *page;
+
+		page = radix_tree_deref_slot(slot);
+		if (unlikely(!page))
+			continue;
+
+		if (radix_tree_exception(page)) {
+			if (radix_tree_deref_retry(page)) {
+				slot = radix_tree_iter_retry(&iter);
+				continue;
+			}
+			/*
+			 * Shadow entry of recently evicted page, or swap entry
+			 * from shmem/tmpfs. Skip over it.
+			 */
+			continue;
+		}
+
+		state = DUET_PAGE_ADDED;
+		if (PageDirty(page))
+			state |= DUET_PAGE_DIRTY;
+		uuid.ino = inode->i_ino;
+		uuid.gen = inode->i_generation;
+		hash_add(task, uuid, page->index, state, 1);
+	}
+	rcu_read_unlock();
+
+	return 0;
+}
+
+/* Scan through the page cache for events of interest to the task */
+static int scan_page_cache(struct duet_task *task)
+{
+	struct inode *inode, *prev = NULL;
+	struct super_block *sb = task->regpath->mnt->mnt_sb;
+
+	pr_info("duet: page cache scan started\n");
+
+	spin_lock(&sb->s_inode_list_lock);
+	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
+		struct address_space *mapping = inode->i_mapping;
+
+		spin_lock(&inode->i_lock);
+		if (inode->i_state & DUET_INODE_FREEING ||
+		    mapping->nrpages == 0) {
+			spin_unlock(&inode->i_lock);
+			continue;
+		}
+		atomic_inc(&inode->i_count);
+		spin_unlock(&inode->i_lock);
+		spin_unlock(&sb->s_inode_list_lock);
+
+		/*
+		 * We are holding a reference to inode so it won't be removed
+		 * from s_inodes list while we don't hold the s_inode_list_lock.
+		 * We cannot iput the inode now, though, as we may be holding
+		 * the last reference. We will iput it after the iteration is
+		 * done.
+		 */
+
+		iput(prev);
+		prev = inode;
+
+		process_inode(task, inode);
+
+		spin_lock(&sb->s_inode_list_lock);
+	}
+	spin_unlock(&sb->s_inode_list_lock);
+	iput(prev);
+
+	pr_info("duet: page cache scan finished\n");
+
+	return 0;
+}
+
+/* Find task and increment its refcount */
+struct duet_task *duet_find_task(__u8 id)
+{
+	struct duet_task *cur, *task = NULL;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(cur, &duet_env.tasks, task_list) {
+		if (cur->id == id) {
+			task = cur;
+			atomic_inc(&task->refcount);
+			break;
+		}
+	}
+	rcu_read_unlock();
+
+	return task;
+}
+
+/* Allocate and initialize a task struct */
+static int duet_task_init(struct duet_task **task, struct filename *name,
+	__u32 regmask, struct path *path)
+{
+	int len;
+	char *p;
+	u32 evtmask = regmask;
+
+	/* Do some sanity checking on event mask. */
+	if (evtmask & DUET_PAGE_EXISTS) {
+		if (evtmask & (DUET_PAGE_ADDED | DUET_PAGE_REMOVED)) {
+			pr_debug("duet_task_init: invalid regmask\n");
+			return -EINVAL;
+		}
+		evtmask |= (DUET_PAGE_ADDED | DUET_PAGE_REMOVED);
+	}
+
+	if (evtmask & DUET_PAGE_MODIFIED) {
+		if (evtmask & (DUET_PAGE_DIRTY | DUET_PAGE_FLUSHED)) {
+			pr_debug("duet_task_init: invalid regmask\n");
+			goto err;
+		}
+		evtmask |= (DUET_PAGE_DIRTY | DUET_PAGE_FLUSHED);
+	}
+
+	/* Allocate task info struct */
+	*task = kzalloc(sizeof(**task), GFP_KERNEL);
+	if (!(*task))
+		return -ENOMEM;
+
+	/* Allocate temporary space for getpath file paths */
+	(*task)->pathbuf = kzalloc(PATH_MAX, GFP_KERNEL);
+	if (!(*task)->pathbuf) {
+		pr_err("duet_task_init: buffer allocation failed\n");
+		kfree(*task);
+		return -ENOMEM;
+	}
+
+	/* Find and store registered dir path */
+	(*task)->regpathname = kzalloc(PATH_MAX, GFP_KERNEL);
+	if (!(*task)->regpathname) {
+		pr_err("duet_task_init: path allocation failed\n");
+		kfree((*task)->pathbuf);
+		kfree(*task);
+		return -ENOMEM;
+	}
+
+	/* Populate registered dir path buffer */
+	len = PATH_MAX;
+	p = d_path(path, (*task)->pathbuf, len);
+	if (IS_ERR(p)) {
+		pr_err("duet_task_init: path registration failed\n");
+		goto err;
+	} else if (!p) {
+		pr_err("duet_task_init: (null) registered path\n");
+		goto err;
+	}
+
+	(*task)->regpathlen = len - (p - (*task)->pathbuf);
+	memcpy((*task)->regpathname, p, (*task)->regpathlen);
+
+	(*task)->id = 1;
+	(*task)->name = name;
+	(*task)->regpath = path;
+	(*task)->evtmask = (regmask & 0xffff);
+	atomic_set(&(*task)->refcount, 0);
+	INIT_LIST_HEAD(&(*task)->task_list);
+	init_waitqueue_head(&(*task)->cleaner_queue);
+	init_waitqueue_head(&(*task)->event_queue);
+	bittree_init(&(*task)->bittree);
+
+	/* Initialize hash table bitmap */
+	(*task)->bmap_cursor = 0;
+	spin_lock_init(&(*task)->bbmap_lock);
+	(*task)->bucket_bmap = kzalloc(sizeof(unsigned long) *
+		BITS_TO_LONGS(duet_env.itm_hash_size), GFP_KERNEL);
+	if (!(*task)->bucket_bmap) {
+		pr_err("duet_task_init: hash bitmap alloc failed\n");
+		kfree((*task)->regpathname);
+		kfree((*task)->pathbuf);
+		kfree(*task);
+		return -ENOMEM;
+	}
+
+	return 0;
+err:
+	pr_err("duet_task_init: error registering task\n");
+	kfree((*task)->regpathname);
+	kfree((*task)->pathbuf);
+	kfree(*task);
+	return -EINVAL;
+}
+
+/* Register the task with Duet */
+int duet_register_task(struct filename *name, __u32 regmask, struct path *path)
+{
+	int ret;
+	__u8 *tid;
+	struct duet_task *cur, *task = NULL;
+	struct list_head *last;
+
+	/* Do some sanity checking on the parameters passed */
+	if (!path || !regmask)
+		return -EINVAL;
+
+	if (!path->dentry || !path->dentry->d_inode) {
+		pr_err("duet_register_task: invalid path\n");
+		return -EINVAL;
+	}
+
+	if (!S_ISDIR(path->dentry->d_inode->i_mode)) {
+		pr_err("duet_register_task: path is not a dir\n");
+		return -EINVAL;
+	}
+
+	ret = duet_task_init(&task, name, regmask, path);
+	if (ret) {
+		pr_err("duet_register_task: initialization failed\n");
+		return ret;
+	}
+
+	/* Now get an anonymous inode to use for communication with Duet */
+	tid = kzalloc(sizeof(__u8), GFP_KERNEL);
+	if (!tid) {
+		duet_task_dispose(task);
+		return -ENOMEM;
+	}
+
+	ret = anon_inode_getfd("duet", &duet_fops, tid,
+		O_RDONLY | ((regmask & DUET_FD_NONBLOCK) ? O_NONBLOCK : 0));
+	if (ret < 0) {
+		duet_task_dispose(task);
+		kfree(tid);
+		return ret;
+	}
+
+	task->fd = ret;
+
+	/* Find a free task id for the new task. Tasks are sorted by id. */
+	mutex_lock(&duet_env.task_list_mutex);
+	last = &duet_env.tasks;
+	list_for_each_entry_rcu(cur, &duet_env.tasks, task_list) {
+		if (cur->id == task->id)
+			(task->id)++;
+		else if (cur->id > task->id)
+			break;
+
+		last = &cur->task_list;
+	}
+	list_add_rcu(&task->task_list, last);
+	mutex_unlock(&duet_env.task_list_mutex);
+
+	*tid = task->id;
+
+	/* Before we return, scan the page cache for pages of interest */
+	scan_page_cache(task);
+
+	pr_info("duet: task %d (fd %d) registered %s(%d) with mask %x\n",
+		task->id, task->fd, task->regpathname, task->regpathlen,
+		task->evtmask);
+
+	return ret;
+}
+
+SYSCALL_DEFINE3(duet_init, const char __user *, taskname, u32, regmask,
+		const char __user *, pathname)
+{
+	int ret;
+	unsigned int lookup_flags = LOOKUP_DIRECTORY;
+	struct filename *name = NULL;
+	struct path *path = NULL;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	if (!duet_online())
+		return -ESRCH;
+
+	/* Do some basic sanity checking */
+	if (!pathname || !regmask)
+		return -EINVAL;
+
+	if (taskname) {
+		name = getname(taskname);
+		if (IS_ERR(name))
+			return PTR_ERR(name);
+	}
+
+	path = kzalloc(sizeof(struct path), GFP_KERNEL);
+	if (!path) {
+		putname(name);
+		return -ENOMEM;
+	}
+
+	ret = user_path_at(AT_FDCWD, pathname, lookup_flags, path);
+	if (ret) {
+		pr_err("duet_init: user_path_at failed\n");
+		goto err;
+	}
+
+	/* Register the task with the framework */
+	ret = duet_register_task(name, regmask, path);
+	if (ret < 0) {
+		pr_err("duet_init: task registration failed\n");
+		goto err;
+	}
+
+	return ret;
+
+err:
+	putname(name);
+	path_put(path);
+	kfree(path);
+	return ret;
+}
+
+SYSCALL_DEFINE2(duet_bmap, u16, flags, struct duet_uuid_arg __user *, arg)
+{
+	int ret = 0;
+	struct duet_uuid_arg *ua;
+	struct duet_task *task;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	if (!duet_online())
+		return -ESRCH;
+
+	/* Do some basic sanity checking */
+	if (!arg)
+		return -EINVAL;
+
+	ua = memdup_user(arg, sizeof(*arg));
+	if (IS_ERR(ua))
+		return PTR_ERR(ua);
+
+	/* For now, we only support one struct size */
+	if (ua->size != sizeof(*ua)) {
+		pr_err("duet_bmap: invalid args struct size (%u)\n", ua->size);
+		ret = -EINVAL;
+		goto done;
+	}
+
+	task = duet_find_task(ua->uuid.tid);
+	if (!task)
+		return -ENOENT;
+
+	switch (flags) {
+	case DUET_BMAP_SET:
+		ret = bittree_set(&task->bittree, ua->uuid);
+		break;
+
+	case DUET_BMAP_RESET:
+		ret = bittree_reset(&task->bittree, ua->uuid);
+		break;
+
+	case DUET_BMAP_CHECK:
+		ret = bittree_check(&task->bittree, ua->uuid, task);
+		break;
+
+	default:
+		pr_err("duet_bmap: invalid flags\n");
+		ret = -EINVAL;
+		break;
+	}
+
+	/* decreg and wake up cleaner if needed */
+	if (atomic_dec_and_test(&task->refcount))
+		wake_up(&task->cleaner_queue);
+
+done:
+	kfree(ua);
+	return ret;
+}
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
