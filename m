Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id l3NNL94d028865
	for <linux-mm@kvack.org>; Mon, 23 Apr 2007 16:21:09 -0700
Received: from smtp.corp.google.com (spacemonkey2.corp.google.com [192.168.120.114])
	by zps37.corp.google.com with ESMTP id l3NNKkIm013587
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 Apr 2007 16:20:46 -0700
Received: from [10.253.168.165] (m682a36d0.tmodns.net [208.54.42.104])
	(authenticated bits=0)
	by smtp.corp.google.com (8.13.8/8.13.8) with ESMTP id l3NNKjTK024536
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 Apr 2007 16:20:46 -0700
Message-ID: <462D3F4C.2040007@google.com>
Date: Mon, 23 Apr 2007 16:20:44 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: [RFC 1/7] cpuset write dirty map
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Add a dirty map to struct address_space

In a NUMA system it is helpful to know where the dirty pages of a mapping
are located. That way we will be able to implement writeout for applications
that are constrained to a portion of the memory of the system as required by
cpusets.

This patch implements the management of dirty node maps for an address
space through the following functions:

cpuset_clear_dirty_nodes(mapping)	Clear the map of dirty nodes

cpuset_update_nodes(mapping, page)	Record a node in the dirty nodes map

cpuset_init_dirty_nodes(mapping)	First time init of the map


The dirty map may be stored either directly in the mapping (for NUMA
systems with less then BITS_PER_LONG nodes) or separately allocated
for systems with a large number of nodes (f.e. IA64 with 1024 nodes).

Updating the dirty map may involve allocating it first for large
configurations. Therefore we protect the allocation and setting
of a node in the map through the tree_lock. The tree_lock is
already taken when a page is dirtied so there is no additional
locking overhead if we insert the updating of the nodemask there.

The dirty map is only cleared (or freed) when the inode is cleared.
At that point no pages are attached to the inode anymore and therefore it can
be done without any locking. The dirty map therefore records all nodes that
have been used for dirty pages by that inode until the inode is no longer
used.

Originally by Christoph Lameter <clameter@sgi.com>

Signed-off-by: Ethan Solomita <solo@google.com>

---

diff -uprN -X linux-2.6.21-rc4-mm1/Documentation/dontdiff linux-2.6.21-rc4-mm1/fs/buffer.c 1/fs/buffer.c
--- linux-2.6.21-rc4-mm1/fs/buffer.c	2007-04-19 00:43:08.000000000 -0700
+++ 1/fs/buffer.c	2007-04-23 14:59:52.000000000 -0700
@@ -42,6 +42,7 @@
 #include <linux/bitops.h>
 #include <linux/mpage.h>
 #include <linux/bit_spinlock.h>
+#include <linux/cpuset.h>
 
 static int fsync_buffers_list(spinlock_t *lock, struct list_head *list);
 static void invalidate_bh_lrus(void);
@@ -747,6 +748,7 @@ int __set_page_dirty_buffers(struct page
 		radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 	}
+	cpuset_update_dirty_nodes(mapping, page);
 	write_unlock_irq(&mapping->tree_lock);
 	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 	return 1;
diff -uprN -X linux-2.6.21-rc4-mm1/Documentation/dontdiff linux-2.6.21-rc4-mm1/fs/fs-writeback.c 1/fs/fs-writeback.c
--- linux-2.6.21-rc4-mm1/fs/fs-writeback.c	2007-04-19 00:43:08.000000000 -0700
+++ 1/fs/fs-writeback.c	2007-04-23 14:28:13.000000000 -0700
@@ -22,6 +22,7 @@
 #include <linux/blkdev.h>
 #include <linux/backing-dev.h>
 #include <linux/buffer_head.h>
+#include <linux/cpuset.h>
 #include "internal.h"
 
 /**
@@ -363,6 +364,12 @@ int generic_sync_sb_inodes(struct super_
 			continue;		/* blockdev has wrong queue */
 		}
 
+		if (!cpuset_intersects_dirty_nodes(mapping, wbc->nodes)) {
+			/* No pages on the nodes under writeback */
+			list_move(&inode->i_list, &sb->s_dirty);
+			continue;
+		}
+
 		/* Was this inode dirtied after sync_sb_inodes was called? */
 		if (time_after(inode->dirtied_when, start))
 			break;
diff -uprN -X linux-2.6.21-rc4-mm1/Documentation/dontdiff linux-2.6.21-rc4-mm1/fs/inode.c 1/fs/inode.c
--- linux-2.6.21-rc4-mm1/fs/inode.c	2007-04-19 00:43:08.000000000 -0700
+++ 1/fs/inode.c	2007-04-23 14:28:13.000000000 -0700
@@ -22,6 +22,7 @@
 #include <linux/bootmem.h>
 #include <linux/inotify.h>
 #include <linux/mount.h>
+#include <linux/cpuset.h>
 
 /*
  * This is needed for the following functions:
@@ -148,6 +149,7 @@ static struct inode *alloc_inode(struct 
 		mapping_set_gfp_mask(mapping, GFP_HIGH_MOVABLE);
 		mapping->assoc_mapping = NULL;
 		mapping->backing_dev_info = &default_backing_dev_info;
+		cpuset_init_dirty_nodes(mapping);
 
 		/*
 		 * If the block_device provides a backing_dev_info for client
@@ -257,6 +259,7 @@ void clear_inode(struct inode *inode)
 		bd_forget(inode);
 	if (S_ISCHR(inode->i_mode) && inode->i_cdev)
 		cd_forget(inode);
+	cpuset_clear_dirty_nodes(inode->i_mapping);
 	inode->i_state = I_CLEAR;
 }
 
diff -uprN -X linux-2.6.21-rc4-mm1/Documentation/dontdiff linux-2.6.21-rc4-mm1/include/linux/cpuset.h 1/include/linux/cpuset.h
--- linux-2.6.21-rc4-mm1/include/linux/cpuset.h	2007-04-19 00:42:18.000000000 -0700
+++ 1/include/linux/cpuset.h	2007-04-23 14:28:13.000000000 -0700
@@ -75,6 +75,45 @@ static inline int cpuset_do_slab_mem_spr
 
 extern void cpuset_track_online_nodes(void);
 
+/*
+ * We need macros since struct address_space is not defined yet
+ */
+#if MAX_NUMNODES <= BITS_PER_LONG
+#define cpuset_update_dirty_nodes(__mapping, __page)			\
+	do {								\
+		int node = page_to_nid(__page);				\
+		if (!node_isset(node, (__mapping)->dirty_nodes))	\
+			node_set(node, (__mapping)->dirty_nodes);	\
+	} while (0)
+
+#define cpuset_clear_dirty_nodes(__mapping)				\
+		(__mapping)->dirty_nodes = NODE_MASK_NONE
+
+#define cpuset_init_dirty_nodes(__mapping)				\
+		(__mapping)->dirty_nodes = NODE_MASK_NONE
+
+#define cpuset_intersects_dirty_nodes(__mapping, __nodemask_ptr)	\
+		(!(__nodemask_ptr) ||					\
+			nodes_intersects((__mapping)->dirty_nodes,	\
+				*(__nodemask_ptr)))
+
+#else
+
+#define cpuset_init_dirty_nodes(__mapping)				\
+	(__mapping)->dirty_nodes = NULL
+
+struct address_space;
+
+extern void cpuset_update_dirty_nodes(struct address_space *a,
+					struct page *p);
+
+extern void cpuset_clear_dirty_nodes(struct address_space *a);
+
+extern int cpuset_intersects_dirty_nodes(struct address_space *a,
+					nodemask_t *mask);
+
+#endif
+
 #else /* !CONFIG_CPUSETS */
 
 static inline int cpuset_init_early(void) { return 0; }
@@ -146,6 +185,26 @@ static inline int cpuset_do_slab_mem_spr
 
 static inline void cpuset_track_online_nodes(void) {}
 
+struct address_space;
+
+static inline void cpuset_update_dirty_nodes(struct address_space *a,
+					struct page *p) {}
+
+static inline void cpuset_clear_dirty_nodes(struct address_space *a) {}
+
+static inline void cpuset_init_dirty_nodes(struct address_space *a) {}
+
+static inline int cpuset_dirty_node_set(struct inode *i, int node)
+{
+	return 1;
+}
+
+static inline int cpuset_intersects_dirty_nodes(struct address_space *a,
+		nodemask_t *n)
+{
+	return 1;
+}
+
 #endif /* !CONFIG_CPUSETS */
 
 #endif /* _LINUX_CPUSET_H */
diff -uprN -X linux-2.6.21-rc4-mm1/Documentation/dontdiff linux-2.6.21-rc4-mm1/include/linux/fs.h 1/include/linux/fs.h
--- linux-2.6.21-rc4-mm1/include/linux/fs.h	2007-04-19 00:43:16.000000000 -0700
+++ 1/include/linux/fs.h	2007-04-23 14:28:13.000000000 -0700
@@ -450,6 +450,13 @@ struct address_space {
 	spinlock_t		private_lock;	/* for use by the address_space */
 	struct list_head	private_list;	/* ditto */
 	struct address_space	*assoc_mapping;	/* ditto */
+#ifdef CONFIG_CPUSETS
+#if MAX_NUMNODES <= BITS_PER_LONG
+	nodemask_t		dirty_nodes;	/* nodes with dirty pages */
+#else
+	nodemask_t		*dirty_nodes;	/* pointer to map if dirty */
+#endif
+#endif
 } __attribute__((aligned(sizeof(long))));
 	/*
 	 * On most architectures that alignment is already the case; but
diff -uprN -X linux-2.6.21-rc4-mm1/Documentation/dontdiff linux-2.6.21-rc4-mm1/include/linux/writeback.h 1/include/linux/writeback.h
--- linux-2.6.21-rc4-mm1/include/linux/writeback.h	2007-04-19 00:43:17.000000000 -0700
+++ 1/include/linux/writeback.h	2007-04-23 14:28:13.000000000 -0700
@@ -59,6 +59,7 @@ struct writeback_control {
 	unsigned for_reclaim:1;		/* Invoked from the page allocator */
 	unsigned for_writepages:1;	/* This is a writepages() call */
 	unsigned range_cyclic:1;	/* range_start is cyclic */
+	nodemask_t *nodes;		/* Set of nodes of interest */
 };
 
 /*
diff -uprN -X linux-2.6.21-rc4-mm1/Documentation/dontdiff linux-2.6.21-rc4-mm1/kernel/cpuset.c 1/kernel/cpuset.c
--- linux-2.6.21-rc4-mm1/kernel/cpuset.c	2007-04-19 00:43:18.000000000 -0700
+++ 1/kernel/cpuset.c	2007-04-23 14:28:13.000000000 -0700
@@ -4,7 +4,7 @@
  *  Processor and Memory placement constraints for sets of tasks.
  *
  *  Copyright (C) 2003 BULL SA.
- *  Copyright (C) 2004-2006 Silicon Graphics, Inc.
+ *  Copyright (C) 2004-2007 Silicon Graphics, Inc.
  *
  *  Portions derived from Patrick Mochel's sysfs code.
  *  sysfs is Copyright (c) 2001-3 Patrick Mochel
@@ -12,6 +12,7 @@
  *  2003-10-10 Written by Simon Derr.
  *  2003-10-22 Updates by Stephen Hemminger.
  *  2004 May-July Rework by Paul Jackson.
+ *  2007 Cpuset writeback by Christoph Lameter.
  *
  *  This file is subject to the terms and conditions of the GNU General Public
  *  License.  See the file COPYING in the main directory of the Linux
@@ -2450,6 +2451,63 @@ int cpuset_mem_spread_node(void)
 }
 EXPORT_SYMBOL_GPL(cpuset_mem_spread_node);
 
+#if MAX_NUMNODES > BITS_PER_LONG
+
+/*
+ * Special functions for NUMA systems with a large number of nodes.
+ * The nodemask is pointed to from the address space structures.
+ * The attachment of the dirty_node mask is protected by the
+ * tree_lock. The nodemask is freed only when the inode is cleared
+ * (and therefore unused, thus no locking necessary).
+ */
+void cpuset_update_dirty_nodes(struct address_space *mapping,
+			struct page *page)
+{
+	nodemask_t *nodes = mapping->dirty_nodes;
+	int node = page_to_nid(page);
+
+	if (!nodes) {
+		nodes = kmalloc(sizeof(nodemask_t), GFP_ATOMIC);
+		if (!nodes)
+			return;
+
+		*nodes = NODE_MASK_NONE;
+		mapping->dirty_nodes = nodes;
+	}
+
+	if (!node_isset(node, *nodes))
+		node_set(node, *nodes);
+}
+
+void cpuset_clear_dirty_nodes(struct address_space *mapping)
+{
+	nodemask_t *nodes = mapping->dirty_nodes;
+
+	if (nodes) {
+		mapping->dirty_nodes = NULL;
+		kfree(nodes);
+	}
+}
+
+/*
+ * Called without the tree_lock. The nodemask is only freed when the inode
+ * is cleared and therefore this is safe.
+ */
+int cpuset_intersects_dirty_nodes(struct address_space *mapping,
+			nodemask_t *mask)
+{
+	nodemask_t *dirty_nodes = mapping->dirty_nodes;
+
+	if (!mask)
+		return 1;
+
+	if (!dirty_nodes)
+		return 0;
+
+	return nodes_intersects(*dirty_nodes, *mask);
+}
+#endif
+
 /**
  * cpuset_excl_nodes_overlap - Do we overlap @p's mem_exclusive ancestors?
  * @p: pointer to task_struct of some other task.
diff -uprN -X linux-2.6.21-rc4-mm1/Documentation/dontdiff linux-2.6.21-rc4-mm1/mm/page-writeback.c 1/mm/page-writeback.c
--- linux-2.6.21-rc4-mm1/mm/page-writeback.c	2007-04-19 00:43:18.000000000 -0700
+++ 1/mm/page-writeback.c	2007-04-23 14:28:13.000000000 -0700
@@ -33,6 +33,7 @@
 #include <linux/syscalls.h>
 #include <linux/buffer_head.h>
 #include <linux/pagevec.h>
+#include <linux/cpuset.h>
 
 /*
  * The maximum number of pages to writeout in a single bdflush/kupdate
@@ -835,6 +836,7 @@ int __set_page_dirty_nobuffers(struct pa
 			radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 		}
+		cpuset_update_dirty_nodes(mapping, page);
 		write_unlock_irq(&mapping->tree_lock);
 		if (mapping->host) {
 			/* !PageAnon && !swapper_space */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
