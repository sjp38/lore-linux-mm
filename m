Message-Id: <20071030160912.873260000@chello.nl>
References: <20071030160401.296770000@chello.nl>
Date: Tue, 30 Oct 2007 17:04:12 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 11/33] mm: memory reserve management
Content-Disposition: inline; filename=mm-reserve.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Generic reserve management code. 

It provides methods to reserve and charge. Upon this, generic alloc/free style
reserve pools could be build, which could fully replace mempool_t
functionality.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/reserve.h |   54 +++++
 mm/Makefile             |    2 
 mm/reserve.c            |  436 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 491 insertions(+), 1 deletion(-)

Index: linux-2.6/include/linux/reserve.h
===================================================================
--- /dev/null
+++ linux-2.6/include/linux/reserve.h
@@ -0,0 +1,54 @@
+/*
+ * Memory reserve management.
+ *
+ *  Copyright (C) 2007 Red Hat, Inc., Peter Zijlstra <pzijlstr@redhat.com>
+ *
+ * This file contains the public data structure and API definitions.
+ */
+
+#ifndef _LINUX_RESERVE_H
+#define _LINUX_RESERVE_H
+
+#include <linux/list.h>
+#include <linux/spinlock.h>
+
+struct mem_reserve {
+	struct mem_reserve *parent;
+	struct list_head children;
+	struct list_head siblings;
+
+	const char *name;
+
+	long pages;
+	long limit;
+	long usage;
+	spinlock_t lock;	/* protects limit and usage */
+};
+
+extern struct mem_reserve mem_reserve_root;
+
+void mem_reserve_init(struct mem_reserve *res, const char *name,
+		      struct mem_reserve *parent);
+int mem_reserve_connect(struct mem_reserve *new_child,
+	       		struct mem_reserve *node);
+int mem_reserve_disconnect(struct mem_reserve *node);
+
+int mem_reserve_pages_set(struct mem_reserve *res, long pages);
+int mem_reserve_pages_add(struct mem_reserve *res, long pages);
+int mem_reserve_pages_charge(struct mem_reserve *res, long pages,
+			     int overcommit);
+
+int mem_reserve_kmalloc_set(struct mem_reserve *res, long bytes);
+int mem_reserve_kmalloc_charge(struct mem_reserve *res, long bytes,
+			       int overcommit);
+
+struct kmem_cache;
+
+int mem_reserve_kmem_cache_set(struct mem_reserve *res,
+	       		       struct kmem_cache *s,
+			       int objects);
+int mem_reserve_kmem_cache_charge(struct mem_reserve *res,
+				  long objs,
+				  int overcommit);
+
+#endif /* _LINUX_RESERVE_H */
Index: linux-2.6/mm/Makefile
===================================================================
--- linux-2.6.orig/mm/Makefile
+++ linux-2.6/mm/Makefile
@@ -11,7 +11,7 @@ obj-y			:= bootmem.o filemap.o mempool.o
 			   page_alloc.o page-writeback.o pdflush.o \
 			   readahead.o swap.o truncate.o vmscan.o \
 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
-			   page_isolation.o $(mmu-y)
+			   page_isolation.o reserve.o $(mmu-y)
 
 obj-$(CONFIG_BOUNCE)	+= bounce.o
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
Index: linux-2.6/mm/reserve.c
===================================================================
--- /dev/null
+++ linux-2.6/mm/reserve.c
@@ -0,0 +1,436 @@
+/*
+ * Memory reserve management.
+ *
+ *  Copyright (C) 2007, Red Hat, Inc., Peter Zijlstra <pzijlstr@redhat.com>
+ *
+ * Description:
+ *
+ * Manage a set of memory reserves.
+ *
+ * A memory reserve is a reserve for a specified number of object of specified
+ * size. Since memory is managed in pages, this reserve demand is then
+ * translated into a page unit.
+ *
+ * So each reserve has a specified object limit, an object usage count and a
+ * number of pages required to back these objects.
+ *
+ * Usage is charged against a reserve, if the charge fails, the resource must
+ * not be allocated/used.
+ *
+ * The reserves are managed in a tree, and the resource demands (pages and
+ * limit) are propagated up the tree. Obviously the object limit will be
+ * meaningless as soon as the unit starts mixing, but the required page reserve
+ * (being of one unit) is still valid at the root.
+ *
+ * It is the page demand of the root node that is used to set the global
+ * reserve (adjust_memalloc_reserve() which sets zone->pages_emerg).
+ *
+ * As long as a subtree has the same usage unit, an aggregate node can be used
+ * to charge against, instead of the leaf nodes. However, do be consistent with
+ * who is charged, resource usage is not propagated up the tree (for
+ * performance reasons).
+ */
+
+#include <linux/reserve.h>
+#include <linux/mutex.h>
+#include <linux/mmzone.h>
+#include <linux/log2.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+
+static DEFINE_MUTEX(mem_reserve_mutex);
+
+/**
+ * @mem_reserve_root - the global reserve root
+ *
+ * The global reserve is empty, and has no limit unit, it merely
+ * acts as an aggregation point for reserves and an interface to
+ * adjust_memalloc_reserve().
+ */
+struct mem_reserve mem_reserve_root = {
+	.children = LIST_HEAD_INIT(mem_reserve_root.children),
+	.siblings = LIST_HEAD_INIT(mem_reserve_root.siblings),
+	.name = "total reserve",
+};
+
+EXPORT_SYMBOL_GPL(mem_reserve_root);
+
+/**
+ * mem_reserve_init - initialize a memory reserve object
+ * @res - the new reserve object
+ * @name - a name for this reserve
+ */
+void mem_reserve_init(struct mem_reserve *res, const char *name,
+		      struct mem_reserve *parent)
+{
+	memset(res, 0, sizeof(*res));
+	INIT_LIST_HEAD(&res->children);
+	INIT_LIST_HEAD(&res->siblings);
+	res->name = name;
+
+	if (parent)
+		mem_reserve_connect(res, parent);
+}
+
+EXPORT_SYMBOL_GPL(mem_reserve_init);
+
+/*
+ * propagate the pages and limit changes up the tree.
+ */
+static void __calc_reserve(struct mem_reserve *res, long pages, long limit)
+{
+	unsigned long flags;
+
+	for ( ; res; res = res->parent) {
+		res->pages += pages;
+
+		if (limit) {
+			spin_lock_irqsave(&res->lock, flags);
+			res->limit += limit;
+			spin_unlock_irqrestore(&res->lock, flags);
+		}
+	}
+}
+
+/**
+ * __mem_reserve_add - primitive to change the size of a reserve
+ * @res - reserve to change
+ * @pages - page delta
+ * @limit - usage limit delta
+ *
+ * Returns -ENOMEM when a size increase is not possible atm.
+ */
+static int __mem_reserve_add(struct mem_reserve *res, long pages, long limit)
+{
+	int ret = 0;
+	long reserve;
+
+	reserve = mem_reserve_root.pages;
+	__calc_reserve(res, pages, 0);
+	reserve = mem_reserve_root.pages - reserve;
+
+	if (reserve) {
+		ret = adjust_memalloc_reserve(reserve);
+		if (ret)
+			__calc_reserve(res, -pages, 0);
+	}
+
+	if (!ret)
+		__calc_reserve(res, 0, limit);
+
+	return ret;
+}
+
+/**
+ * __mem_reserve_charge - primitive to charge object usage to a reserve
+ * @res - reserve to charge
+ * @charge - size of the charge
+ * @overcommit - allow despite of limit (use with caution!)
+ *
+ * Returns non-zero on success, zero on failure.
+ */
+static
+int __mem_reserve_charge(struct mem_reserve *res, long charge, int overcommit)
+{
+	unsigned long flags;
+	int ret = 0;
+
+	spin_lock_irqsave(&res->lock, flags);
+	if (charge < 0 || res->usage + charge < res->limit || overcommit) {
+		res->usage += charge;
+		if (unlikely(res->usage < 0))
+			res->usage = 0;
+		ret = 1;
+	}
+	spin_unlock_irqrestore(&res->lock, flags);
+
+	return ret;
+}
+
+/**
+ * mem_reserve_connect - connect a reserve to another in a child-parent relation
+ * @new_child - the reserve node to connect (child)
+ * @node - the reserve node to connect to (parent)
+ *
+ * Returns -ENOMEM when the new connection would increase the reserve (parent
+ * is connected to mem_reserve_root) and there is no memory to do so.
+ *
+ * The child is _NOT_ connected on error.
+ */
+int mem_reserve_connect(struct mem_reserve *new_child, struct mem_reserve *node)
+{
+	int ret;
+
+	WARN_ON(!new_child->name);
+
+	mutex_lock(&mem_reserve_mutex);
+	new_child->parent = node;
+	list_add(&new_child->siblings, &node->children);
+	ret = __mem_reserve_add(node, new_child->pages, new_child->limit);
+	if (ret) {
+		new_child->parent = NULL;
+		list_del_init(&new_child->siblings);
+	}
+	mutex_unlock(&mem_reserve_mutex);
+
+	return ret;
+}
+
+EXPORT_SYMBOL_GPL(mem_reserve_connect);
+
+/**
+ * mem_reserve_disconnect - sever a nodes connection to the reserve tree
+ * @node - the node to disconnect
+ *
+ * Could, in theory, return -ENOMEM, but since disconnecting a node _should_
+ * only decrease the reserves that _should_ not happen.
+ */
+int mem_reserve_disconnect(struct mem_reserve *node)
+{
+	int ret;
+
+	BUG_ON(!node->parent);
+
+	mutex_lock(&mem_reserve_mutex);
+	ret = __mem_reserve_add(node->parent, -node->pages, -node->limit);
+	if (!ret) {
+		node->parent = NULL;
+		list_del_init(&node->siblings);
+	}
+	mutex_unlock(&mem_reserve_mutex);
+
+	return ret;
+}
+
+EXPORT_SYMBOL_GPL(mem_reserve_disconnect);
+
+#ifdef CONFIG_PROC_FS
+
+/*
+ * Simple output of the reserve tree in: /proc/reserve_info
+ * Example:
+ *
+ * localhost ~ # cat /proc/reserve_info
+ * total reserve                  8156K (0/544817)
+ *   total network reserve          8156K (0/544817)
+ *     network TX reserve             196K (0/49)
+ *       protocol TX pages              196K (0/49)
+ *     network RX reserve             7960K (0/544768)
+ *       IPv6 route cache               1372K (0/4096)
+ *       IPv4 route cache               5468K (0/16384)
+ *       SKB data reserve               1120K (0/524288)
+ *         IPv6 fragment cache            560K (0/262144)
+ *         IPv4 fragment cache            560K (0/262144)
+ */
+
+static void mem_reserve_show_item(struct seq_file *m, struct mem_reserve *res,
+				  int nesting)
+{
+	int i;
+	struct mem_reserve *child;
+
+	for (i = 0; i < nesting; i++)
+		seq_puts(m, "  ");
+
+	seq_printf(m, "%-30s %ldK (%ld/%ld)\n",
+		   res->name, res->pages << (PAGE_SHIFT - 10),
+		   res->usage, res->limit);
+
+	list_for_each_entry(child, &res->children, siblings)
+		mem_reserve_show_item(m, child, nesting+1);
+}
+
+static int mem_reserve_show(struct seq_file *m, void *v)
+{
+	mutex_lock(&mem_reserve_mutex);
+	mem_reserve_show_item(m, &mem_reserve_root, 0);
+	mutex_unlock(&mem_reserve_mutex);
+
+	return 0;
+}
+
+static int mem_reserve_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, mem_reserve_show, NULL);
+}
+
+static const struct file_operations mem_reserve_opterations = {
+	.open = mem_reserve_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+static __init int mem_reserve_proc_init(void)
+{
+	struct proc_dir_entry *entry;
+
+	entry = create_proc_entry("reserve_info", S_IRUSR, NULL);
+	if (entry)
+		entry->proc_fops = &mem_reserve_opterations;
+
+	return 0;
+}
+
+__initcall(mem_reserve_proc_init);
+
+#endif
+
+/*
+ * alloc_page helpers
+ */
+
+/**
+ * mem_reserve_pages_set - set reserves size in pages
+ * @res - reserve to set
+ * @pages - size in pages to set it to
+ *
+ * Returns -ENOMEM when it fails to set the reserve. On failure the old size
+ * is preserved.
+ */
+int mem_reserve_pages_set(struct mem_reserve *res, long pages)
+{
+	int ret;
+
+	mutex_lock(&mem_reserve_mutex);
+	pages -= res->pages;
+	ret = __mem_reserve_add(res, pages, pages);
+	mutex_unlock(&mem_reserve_mutex);
+
+	return ret;
+}
+
+EXPORT_SYMBOL_GPL(mem_reserve_pages_set);
+
+/**
+ * mem_reserve_pages_add - change the size in a relative way
+ * @res - reserve to change
+ * @pages - number of pages to add (or subtract when negative)
+ *
+ * Similar to mem_reserve_pages_set, except that the argument is relative instead
+ * of absolute.
+ *
+ * Returns -ENOMEM when it fails to increase.
+ */
+int mem_reserve_pages_add(struct mem_reserve *res, long pages)
+{
+	int ret;
+
+	mutex_lock(&mem_reserve_mutex);
+	ret = __mem_reserve_add(res, pages, pages);
+	mutex_unlock(&mem_reserve_mutex);
+
+	return ret;
+}
+
+/**
+ * mem_reserve_pages_charge - charge page usage to a reserve
+ * @res - reserve to charge
+ * @pages - size to charge
+ * @overcommit - disregard the usage limit (use with caution!)
+ *
+ * Returns non-zero on success.
+ */
+int mem_reserve_pages_charge(struct mem_reserve *res, long pages, int overcommit)
+{
+	return __mem_reserve_charge(res, pages, overcommit);
+}
+
+EXPORT_SYMBOL_GPL(mem_reserve_pages_charge);
+
+/*
+ * kmalloc helpers
+ */
+
+/**
+ * mem_reserve_kmalloc_set - set this reserve to bytes worth of kmalloc
+ * @res - reserve to change
+ * @bytes - size in bytes to reserve
+ *
+ * Returns -ENOMEM on failure.
+ */
+int mem_reserve_kmalloc_set(struct mem_reserve *res, long bytes)
+{
+	int ret;
+	long pages;
+
+	mutex_lock(&mem_reserve_mutex);
+	pages = kestimate(GFP_ATOMIC, bytes);
+	pages -= res->pages;
+	bytes -= res->limit;
+	ret = __mem_reserve_add(res, pages, bytes);
+	mutex_unlock(&mem_reserve_mutex);
+
+	return ret;
+}
+
+EXPORT_SYMBOL_GPL(mem_reserve_kmalloc_set);
+
+/**
+ * mem_reserve_kmalloc_charge - charge bytes to a reserve
+ * @res - reserve to charge
+ * @bytes - bytes to charge
+ * @overcommit - disregard the usage limit (use with caution!)
+ *
+ * Returns non-zero on success.
+ */
+int mem_reserve_kmalloc_charge(struct mem_reserve *res, long bytes,
+			       int overcommit)
+{
+	if (bytes < 0)
+		bytes = -roundup_pow_of_two(-bytes);
+	else
+		bytes = roundup_pow_of_two(bytes);
+
+	return __mem_reserve_charge(res, bytes, overcommit);
+}
+
+EXPORT_SYMBOL_GPL(mem_reserve_kmalloc_charge);
+
+/*
+ * kmem_cache helpers
+ */
+
+/**
+ * mem_reserve_kmem_cache_set - set reserve to @objects worth of kmem_cache_alloc of @s
+ * @res - reserve to set
+ * @s - kmem_cache to reserve from
+ * @objects - number of objects to reserve
+ *
+ * Returns -ENOMEM on failure.
+ */
+int mem_reserve_kmem_cache_set(struct mem_reserve *res, struct kmem_cache *s,
+			       int objects)
+{
+	int ret;
+	long pages;
+
+	mutex_lock(&mem_reserve_mutex);
+	pages = kmem_estimate_pages(s, GFP_ATOMIC, objects);
+	pages -= res->pages;
+	objects -= res->limit;
+	ret = __mem_reserve_add(res, pages, objects);
+	mutex_unlock(&mem_reserve_mutex);
+
+	return ret;
+}
+
+EXPORT_SYMBOL_GPL(mem_reserve_kmem_cache_set);
+
+/**
+ * mem_reserve_kmem_cache_charge - charge (or uncharge) usage of objs
+ * @res - reserve to charge
+ * @objs - objects to charge for
+ * @overcommit - disregard the usage limit (use with caution!)
+ *
+ * Returns non-zero on success.
+ */
+int mem_reserve_kmem_cache_charge(struct mem_reserve *res, long objs,
+				  int overcommit)
+{
+	return __mem_reserve_charge(res, objs, overcommit);
+}
+
+EXPORT_SYMBOL_GPL(mem_reserve_kmem_cache_charge);

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
