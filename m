Date: Tue, 23 Jan 2007 10:52:48 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070123185248.2640.87514.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070123185242.2640.8367.sendpatchset@schroedinger.engr.sgi.com>
References: <20070123185242.2640.8367.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 1/5] Add a map to to track dirty pages per node
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Paul Menage <menage@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>, Dave Chinner <dgc@sgi.com>, Andi Kleen <ak@suse.de>
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

Signed-off-by; Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20-rc5/fs/fs-writeback.c
===================================================================
--- linux-2.6.20-rc5.orig/fs/fs-writeback.c	2007-01-22 13:31:30.440219103 -0600
+++ linux-2.6.20-rc5/fs/fs-writeback.c	2007-01-23 12:21:44.669179863 -0600
@@ -22,6 +22,7 @@
 #include <linux/blkdev.h>
 #include <linux/backing-dev.h>
 #include <linux/buffer_head.h>
+#include <linux/cpuset.h>
 #include "internal.h"
 
 /**
@@ -349,6 +350,12 @@ sync_sb_inodes(struct super_block *sb, s
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
Index: linux-2.6.20-rc5/fs/inode.c
===================================================================
--- linux-2.6.20-rc5.orig/fs/inode.c	2007-01-22 13:31:30.449985520 -0600
+++ linux-2.6.20-rc5/fs/inode.c	2007-01-22 13:34:22.397545917 -0600
@@ -22,6 +22,7 @@
 #include <linux/bootmem.h>
 #include <linux/inotify.h>
 #include <linux/mount.h>
+#include <linux/cpuset.h>
 
 /*
  * This is needed for the following functions:
@@ -148,6 +149,7 @@ static struct inode *alloc_inode(struct 
 		mapping_set_gfp_mask(mapping, GFP_HIGHUSER);
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
 
Index: linux-2.6.20-rc5/include/linux/fs.h
===================================================================
--- linux-2.6.20-rc5.orig/include/linux/fs.h	2007-01-22 13:31:30.468541713 -0600
+++ linux-2.6.20-rc5/include/linux/fs.h	2007-01-23 12:33:26.331272886 -0600
@@ -447,6 +447,13 @@ struct address_space {
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
Index: linux-2.6.20-rc5/mm/page-writeback.c
===================================================================
--- linux-2.6.20-rc5.orig/mm/page-writeback.c	2007-01-22 13:31:30.498817606 -0600
+++ linux-2.6.20-rc5/mm/page-writeback.c	2007-01-23 12:22:15.322270609 -0600
@@ -33,6 +33,7 @@
 #include <linux/syscalls.h>
 #include <linux/buffer_head.h>
 #include <linux/pagevec.h>
+#include <linux/cpuset.h>
 
 /*
  * The maximum number of pages to writeout in a single bdflush/kupdate
@@ -776,6 +777,7 @@ int __set_page_dirty_nobuffers(struct pa
 			radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 		}
+		cpuset_update_dirty_nodes(mapping, page);
 		write_unlock_irq(&mapping->tree_lock);
 		if (mapping->host) {
 			/* !PageAnon && !swapper_space */
Index: linux-2.6.20-rc5/fs/buffer.c
===================================================================
--- linux-2.6.20-rc5.orig/fs/buffer.c	2007-01-22 13:31:30.459751937 -0600
+++ linux-2.6.20-rc5/fs/buffer.c	2007-01-23 12:22:15.352546714 -0600
@@ -42,6 +42,7 @@
 #include <linux/bitops.h>
 #include <linux/mpage.h>
 #include <linux/bit_spinlock.h>
+#include <linux/cpuset.h>
 
 static int fsync_buffers_list(spinlock_t *lock, struct list_head *list);
 static void invalidate_bh_lrus(void);
@@ -736,6 +737,7 @@ int __set_page_dirty_buffers(struct page
 		}
 		radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
+		cpuset_update_dirty_nodes(mapping, page);
 	}
 	write_unlock_irq(&mapping->tree_lock);
 	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
Index: linux-2.6.20-rc5/include/linux/cpuset.h
===================================================================
--- linux-2.6.20-rc5.orig/include/linux/cpuset.h	2007-01-22 13:31:30.477331488 -0600
+++ linux-2.6.20-rc5/include/linux/cpuset.h	2007-01-23 12:32:53.783494005 -0600
@@ -75,6 +75,44 @@ static inline int cpuset_do_slab_mem_spr
 
 extern void cpuset_track_online_nodes(void);
 
+/*
+ * We need macros since struct address_space is not defined yet
+ */
+#if MAX_NUMNODES <= BITS_PER_LONG
+#define cpuset_update_dirty_nodes(__mapping, __node)			\
+	do {								\
+		if (!node_isset((__node, (__mapping)->dirty_nodes)))	\
+			node_set((__node), (__mapping)->dirty_inodes);	\
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
@@ -146,6 +184,26 @@ static inline int cpuset_do_slab_mem_spr
 
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
Index: linux-2.6.20-rc5/kernel/cpuset.c
===================================================================
--- linux-2.6.20-rc5.orig/kernel/cpuset.c	2007-01-22 13:31:30.511513948 -0600
+++ linux-2.6.20-rc5/kernel/cpuset.c	2007-01-23 12:26:02.804117253 -0600
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
@@ -2530,6 +2531,63 @@ int cpuset_mem_spread_node(void)
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
Index: linux-2.6.20-rc5/include/linux/writeback.h
===================================================================
--- linux-2.6.20-rc5.orig/include/linux/writeback.h	2007-01-22 13:31:30.489051189 -0600
+++ linux-2.6.20-rc5/include/linux/writeback.h	2007-01-23 12:22:15.313480772 -0600
@@ -59,11 +59,12 @@ struct writeback_control {
 	unsigned for_reclaim:1;		/* Invoked from the page allocator */
 	unsigned for_writepages:1;	/* This is a writepages() call */
 	unsigned range_cyclic:1;	/* range_start is cyclic */
+	nodemask_t *nodes;		/* Set of nodes of interest */
 };
 
 /*
  * fs/fs-writeback.c
- */	
+ */
 void writeback_inodes(struct writeback_control *wbc);
 void wake_up_inode(struct inode *inode);
 int inode_wait(void *);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
