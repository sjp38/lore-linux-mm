Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id E46D16B006C
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 18:02:42 -0400 (EDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH 2/3] staging: zcache: move to new zcache codebase
Date: Fri, 17 Aug 2012 15:02:31 -0700
Message-Id: <1345240952-28302-3-git-send-email-dan.magenheimer@oracle.com>
In-Reply-To: <1345240952-28302-1-git-send-email-dan.magenheimer@oracle.com>
References: <1345240952-28302-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org, dan.magenheimer@oracle.com

The original zcache in staging was a "demo" version and this is a massive
rewrite.  Alas, no history of changes was recorded during the rewrite and
recreating a sane one would be a Sisyphean task but, since zcache is still
in staging, presumably this is acceptable.

This commit also provides the hooks for ramster in zcache, but the ramster
code will be provided in another commit.

Some of the highlights of this rewritten codebase for zcache:
(Note: If you are not familiar with the tmem terminology, you can review
it here: http://lwn.net/Articles/454795/ )
 1. Merge of zcache and ramster.  Zcache and ramster had a great deal of
    duplicate code which is now merged.  In essence, zcache *is* ramster
    but with no remote machine available, but !CONFIG_RAMSTER will avoid
    compiling lots of ramster-specific code.
 2. Allocator.  Previously, persistent pools used zsmalloc and ephemeral pools
    used zbud.  Now a completely rewritten zbud is used for both.  Notably
    this zbud maintains all persistent (frontswap) and ephemeral (cleancache)
    pageframes in separate queues in LRU order.
 3. Interaction with page allocator.  Zbud does no page allocation/freeing,
    it is done entirely in zcache where it can be tracked more effectively.
 4. Better pre-allocation.  Previously, on put, if a new pageframe could not be
    pre-allocated, the put would fail, even if the allocator had plenty of
    partial pages where the data could be stored; this is now fixed.
 5. Ouroboros ("eating its own tail") allocation.  If no pageframe can be
    allocated AND no partial pages are available, the least-recently-used
    ephemeral pageframe is reclaimed immediately (including flushing tmem
    pointers to it) and re-used.  This ensures that most-recently-used
    cleancache pages are more likely to be retained than LRU pages and also
    that, as in the core mm subsystem, anonymous pages have a higher priority
    than clean page cache pages.
 6. Zcache and zbud now use debugfs instead of sysfs.  Ramster uses debugfs
    where possible and sysfs where necessary.  (Some ramster configuration
    is done from userspace so some sysfs is necessary.)
 7. Modularization.  As some have observed, the monolithic zcache-main.c code
    included zbud code, which has now been separated into its own code module.
    Much ramster-specific code in the old ramster zcache-main.c has also been
    moved into ramster.c so that it does not get compiled with !CONFIG_RAMSTER.
 8. Rebased to 3.5.

This new codebase also provides hooks for several future new features:
 A. WasActive patch, requires some mm/frontswap changes previously posted.
    A new version of this patch will be provided separately.
    See ifdef __PG_WAS_ACTIVE
 B. Exclusive gets.  It seems tmem _can_ support exclusive gets with a
    minor change to both zcache and a small backwards-compatible change
    to frontswap.c.  Explanation and frontswap patch will be provided
    separately.  See ifdef FRONTSWAP_HAS_EXCLUSIVE_GETS
 C. Ouroboros writeback.  Since persistent (frontswap) pages may now also be
    reclaimed in LRU order, the foundation is in place to properly writeback
    these pages back into the swap cache and then the swap disk.  This is still
    under development and requires some other mm changes which are prototyped.
    See ifdef FRONTSWAP_HAS_UNUSE.

A new feature that desperately needs attention (if someone is looking for
a way to contribute) is kernel module support.  A preliminary version of
a patch was posted by Erlangen University and needs to be integrated and
tested for zcache and brought up to kernel standards.

If anybody is interested on helping out with any of these, let me know!

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
---
 drivers/staging/Kconfig              |    2 +
 drivers/staging/Makefile             |    1 +
 drivers/staging/zcache/Kconfig       |   15 +
 drivers/staging/zcache/Makefile      |    2 +
 drivers/staging/zcache/ramster.h     |   59 ++
 drivers/staging/zcache/tmem.c        |  894 +++++++++++++++++
 drivers/staging/zcache/tmem.h        |  259 +++++
 drivers/staging/zcache/zbud.c        | 1060 ++++++++++++++++++++
 drivers/staging/zcache/zbud.h        |   33 +
 drivers/staging/zcache/zcache-main.c | 1812 ++++++++++++++++++++++++++++++++++
 drivers/staging/zcache/zcache.h      |   53 +
 11 files changed, 4190 insertions(+), 0 deletions(-)
 create mode 100644 drivers/staging/zcache/Kconfig
 create mode 100644 drivers/staging/zcache/Makefile
 create mode 100644 drivers/staging/zcache/ramster.h
 create mode 100644 drivers/staging/zcache/tmem.c
 create mode 100644 drivers/staging/zcache/tmem.h
 create mode 100644 drivers/staging/zcache/zbud.c
 create mode 100644 drivers/staging/zcache/zbud.h
 create mode 100644 drivers/staging/zcache/zcache-main.c
 create mode 100644 drivers/staging/zcache/zcache.h

diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index ff8870b..ae2fbe9 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -128,4 +128,6 @@ source "drivers/staging/ipack/Kconfig"
 
 source "drivers/staging/gdm72xx/Kconfig"
 
+source "drivers/staging/zcache/Kconfig"
+
 endif # STAGING
diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index c03bf4a..5975796 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -56,3 +56,4 @@ obj-$(CONFIG_PHONE)		+= telephony/
 obj-$(CONFIG_USB_WPAN_HCD)	+= ozwpan/
 obj-$(CONFIG_USB_G_CCG)		+= ccg/
 obj-$(CONFIG_WIMAX_GDM72XX)	+= gdm72xx/
+obj-$(CONFIG_ZCACHE)		+= zcache/
diff --git a/drivers/staging/zcache/Kconfig b/drivers/staging/zcache/Kconfig
new file mode 100644
index 0000000..0cd7460
--- /dev/null
+++ b/drivers/staging/zcache/Kconfig
@@ -0,0 +1,15 @@
+config ZCACHE
+	bool "Dynamic compression of swap pages and clean pagecache pages"
+	# X86 dependency is because zsmalloc uses non-portable pte/tlb
+	# functions
+	depends on CRYPTO=y
+	select CLEANCACHE
+	select FRONTSWAP
+	select CRYPTO_LZO
+	default n
+	help
+	  Zcache doubles RAM efficiency while providing a significant
+	  performance boosts on many workloads.  Zcache uses
+	  compression and an in-kernel implementation of transcendent
+	  memory to store clean page cache pages and swap in RAM,
+	  providing a noticeable reduction in disk I/O.
diff --git a/drivers/staging/zcache/Makefile b/drivers/staging/zcache/Makefile
new file mode 100644
index 0000000..30ac53b
--- /dev/null
+++ b/drivers/staging/zcache/Makefile
@@ -0,0 +1,2 @@
+zcache-y	:=		zcache-main.o tmem.o zbud.o
+obj-$(CONFIG_ZCACHE)	+=	zcache.o
diff --git a/drivers/staging/zcache/ramster.h b/drivers/staging/zcache/ramster.h
new file mode 100644
index 0000000..1b71aea
--- /dev/null
+++ b/drivers/staging/zcache/ramster.h
@@ -0,0 +1,59 @@
+
+/*
+ * zcache/ramster.h
+ *
+ * Placeholder to resolve ramster references when !CONFIG_RAMSTER
+ * Real ramster.h lives in ramster subdirectory.
+ *
+ * Copyright (c) 2009-2012, Dan Magenheimer, Oracle Corp.
+ */
+
+#ifndef _ZCACHE_RAMSTER_H_
+#define _ZCACHE_RAMSTER_H_
+
+#ifdef CONFIG_RAMSTER
+#include "ramster/ramster.h"
+#else
+static inline void ramster_init(bool x, bool y, bool z)
+{
+}
+
+static inline void ramster_register_pamops(struct tmem_pamops *p)
+{
+}
+
+static inline int ramster_remotify_pageframe(bool b)
+{
+	return 0;
+}
+
+static inline void *ramster_pampd_free(void *v, struct tmem_pool *p,
+			struct tmem_oid *o, uint32_t u, bool b)
+{
+	return NULL;
+}
+
+static inline int ramster_do_preload_flnode(struct tmem_pool *p)
+{
+	return -1;
+}
+
+static inline bool pampd_is_remote(void *v)
+{
+	return false;
+}
+
+static inline void ramster_count_foreign_pages(bool b, int i)
+{
+}
+
+static inline void ramster_cpu_up(int cpu)
+{
+}
+
+static inline void ramster_cpu_down(int cpu)
+{
+}
+#endif
+
+#endif /* _ZCACHE_RAMSTER_H */
diff --git a/drivers/staging/zcache/tmem.c b/drivers/staging/zcache/tmem.c
new file mode 100644
index 0000000..a2b7e03
--- /dev/null
+++ b/drivers/staging/zcache/tmem.c
@@ -0,0 +1,894 @@
+/*
+ * In-kernel transcendent memory (generic implementation)
+ *
+ * Copyright (c) 2009-2012, Dan Magenheimer, Oracle Corp.
+ *
+ * The primary purpose of Transcedent Memory ("tmem") is to map object-oriented
+ * "handles" (triples containing a pool id, and object id, and an index), to
+ * pages in a page-accessible memory (PAM).  Tmem references the PAM pages via
+ * an abstract "pampd" (PAM page-descriptor), which can be operated on by a
+ * set of functions (pamops).  Each pampd contains some representation of
+ * PAGE_SIZE bytes worth of data. For those familiar with key-value stores,
+ * the tmem handle is a three-level hierarchical key, and the value is always
+ * reconstituted (but not necessarily stored) as PAGE_SIZE bytes and is
+ * referenced in the datastore by the pampd.  The hierarchy is required
+ * to ensure that certain invalidation functions can be performed efficiently
+ * (i.e. flush all indexes associated with this object_id, or
+ * flush all objects associated with this pool).
+ *
+ * Tmem must support potentially millions of pages and must be able to insert,
+ * find, and delete these pages at a potential frequency of thousands per
+ * second concurrently across many CPUs, (and, if used with KVM, across many
+ * vcpus across many guests).  Tmem is tracked with a hierarchy of data
+ * structures, organized by the elements in the handle-tuple: pool_id,
+ * object_id, and page index.  One or more "clients" (e.g. guests) each
+ * provide one or more tmem_pools.  Each pool, contains a hash table of
+ * rb_trees of tmem_objs.  Each tmem_obj contains a radix-tree-like tree
+ * of pointers, with intermediate nodes called tmem_objnodes.  Each leaf
+ * pointer in this tree points to a pampd, which is accessible only through
+ * a small set of callbacks registered by the PAM implementation (see
+ * tmem_register_pamops). Tmem only needs to memory allocation for objs
+ * and objnodes and this is done via a set of callbacks that must be
+ * registered by the tmem host implementation (e.g. see tmem_register_hostops).
+ */
+
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/atomic.h>
+#ifdef CONFIG_RAMSTER
+#include <linux/delay.h>
+#endif
+
+#include "tmem.h"
+
+/* data structure sentinels used for debugging... see tmem.h */
+#define POOL_SENTINEL 0x87658765
+#define OBJ_SENTINEL 0x12345678
+#define OBJNODE_SENTINEL 0xfedcba09
+
+/*
+ * A tmem host implementation must use this function to register callbacks
+ * for memory allocation.
+ */
+static struct tmem_hostops tmem_hostops;
+
+static void tmem_objnode_tree_init(void);
+
+void tmem_register_hostops(struct tmem_hostops *m)
+{
+	tmem_objnode_tree_init();
+	tmem_hostops = *m;
+}
+
+/*
+ * A tmem host implementation must use this function to register
+ * callbacks for a page-accessible memory (PAM) implementation.
+ */
+static struct tmem_pamops tmem_pamops;
+
+void tmem_register_pamops(struct tmem_pamops *m)
+{
+	tmem_pamops = *m;
+}
+
+/*
+ * Oid's are potentially very sparse and tmem_objs may have an indeterminately
+ * short life, being added and deleted at a relatively high frequency.
+ * So an rb_tree is an ideal data structure to manage tmem_objs.  But because
+ * of the potentially huge number of tmem_objs, each pool manages a hashtable
+ * of rb_trees to reduce search, insert, delete, and rebalancing time.
+ * Each hashbucket also has a lock to manage concurrent access and no
+ * searches, inserts, or deletions can be performed unless the lock is held.
+ * As a result, care must be taken to ensure tmem routines are not called
+ * recursively; the vast majority of the time, a recursive call may work
+ * but a deadlock will occur a small fraction of the time due to the
+ * hashbucket lock.
+ *
+ * The following routines manage tmem_objs.  In all of these routines,
+ * the hashbucket lock is already held.
+ */
+
+/* Search for object==oid in pool, returns object if found. */
+static struct tmem_obj *__tmem_obj_find(struct tmem_hashbucket *hb,
+					struct tmem_oid *oidp,
+					struct rb_node **parent,
+					struct rb_node ***link)
+{
+	struct rb_node *_parent = NULL, **rbnode;
+	struct tmem_obj *obj = NULL;
+
+	rbnode = &hb->obj_rb_root.rb_node;
+	while (*rbnode) {
+		BUG_ON(RB_EMPTY_NODE(*rbnode));
+		_parent = *rbnode;
+		obj = rb_entry(*rbnode, struct tmem_obj,
+			       rb_tree_node);
+		switch (tmem_oid_compare(oidp, &obj->oid)) {
+		case 0: /* equal */
+			goto out;
+		case -1:
+			rbnode = &(*rbnode)->rb_left;
+			break;
+		case 1:
+			rbnode = &(*rbnode)->rb_right;
+			break;
+		}
+	}
+
+	if (parent)
+		*parent = _parent;
+	if (link)
+		*link = rbnode;
+	obj = NULL;
+out:
+	return obj;
+}
+
+static struct tmem_obj *tmem_obj_find(struct tmem_hashbucket *hb,
+					struct tmem_oid *oidp)
+{
+	return __tmem_obj_find(hb, oidp, NULL, NULL);
+}
+
+static void tmem_pampd_destroy_all_in_obj(struct tmem_obj *, bool);
+
+/* Free an object that has no more pampds in it. */
+static void tmem_obj_free(struct tmem_obj *obj, struct tmem_hashbucket *hb)
+{
+	struct tmem_pool *pool;
+
+	BUG_ON(obj == NULL);
+	ASSERT_SENTINEL(obj, OBJ);
+	BUG_ON(obj->pampd_count > 0);
+	pool = obj->pool;
+	BUG_ON(pool == NULL);
+	if (obj->objnode_tree_root != NULL) /* may be "stump" with no leaves */
+		tmem_pampd_destroy_all_in_obj(obj, false);
+	BUG_ON(obj->objnode_tree_root != NULL);
+	BUG_ON((long)obj->objnode_count != 0);
+	atomic_dec(&pool->obj_count);
+	BUG_ON(atomic_read(&pool->obj_count) < 0);
+	INVERT_SENTINEL(obj, OBJ);
+	obj->pool = NULL;
+	tmem_oid_set_invalid(&obj->oid);
+	rb_erase(&obj->rb_tree_node, &hb->obj_rb_root);
+}
+
+/*
+ * Initialize, and insert an tmem_object_root (called only if find failed).
+ */
+static void tmem_obj_init(struct tmem_obj *obj, struct tmem_hashbucket *hb,
+					struct tmem_pool *pool,
+					struct tmem_oid *oidp)
+{
+	struct rb_root *root = &hb->obj_rb_root;
+	struct rb_node **new = NULL, *parent = NULL;
+
+	BUG_ON(pool == NULL);
+	atomic_inc(&pool->obj_count);
+	obj->objnode_tree_height = 0;
+	obj->objnode_tree_root = NULL;
+	obj->pool = pool;
+	obj->oid = *oidp;
+	obj->objnode_count = 0;
+	obj->pampd_count = 0;
+#ifdef CONFIG_RAMSTER
+	if (tmem_pamops.new_obj != NULL)
+		(*tmem_pamops.new_obj)(obj);
+#endif
+	SET_SENTINEL(obj, OBJ);
+
+	if (__tmem_obj_find(hb, oidp, &parent, &new))
+		BUG();
+
+	rb_link_node(&obj->rb_tree_node, parent, new);
+	rb_insert_color(&obj->rb_tree_node, root);
+}
+
+/*
+ * Tmem is managed as a set of tmem_pools with certain attributes, such as
+ * "ephemeral" vs "persistent".  These attributes apply to all tmem_objs
+ * and all pampds that belong to a tmem_pool.  A tmem_pool is created
+ * or deleted relatively rarely (for example, when a filesystem is
+ * mounted or unmounted).
+ */
+
+/* flush all data from a pool and, optionally, free it */
+static void tmem_pool_flush(struct tmem_pool *pool, bool destroy)
+{
+	struct rb_node *rbnode;
+	struct tmem_obj *obj;
+	struct tmem_hashbucket *hb = &pool->hashbucket[0];
+	int i;
+
+	BUG_ON(pool == NULL);
+	for (i = 0; i < TMEM_HASH_BUCKETS; i++, hb++) {
+		spin_lock(&hb->lock);
+		rbnode = rb_first(&hb->obj_rb_root);
+		while (rbnode != NULL) {
+			obj = rb_entry(rbnode, struct tmem_obj, rb_tree_node);
+			rbnode = rb_next(rbnode);
+			tmem_pampd_destroy_all_in_obj(obj, true);
+			tmem_obj_free(obj, hb);
+			(*tmem_hostops.obj_free)(obj, pool);
+		}
+		spin_unlock(&hb->lock);
+	}
+	if (destroy)
+		list_del(&pool->pool_list);
+}
+
+/*
+ * A tmem_obj contains a radix-tree-like tree in which the intermediate
+ * nodes are called tmem_objnodes.  (The kernel lib/radix-tree.c implementation
+ * is very specialized and tuned for specific uses and is not particularly
+ * suited for use from this code, though some code from the core algorithms has
+ * been reused, thus the copyright notices below).  Each tmem_objnode contains
+ * a set of pointers which point to either a set of intermediate tmem_objnodes
+ * or a set of of pampds.
+ *
+ * Portions Copyright (C) 2001 Momchil Velikov
+ * Portions Copyright (C) 2001 Christoph Hellwig
+ * Portions Copyright (C) 2005 SGI, Christoph Lameter <clameter@sgi.com>
+ */
+
+struct tmem_objnode_tree_path {
+	struct tmem_objnode *objnode;
+	int offset;
+};
+
+/* objnode height_to_maxindex translation */
+static unsigned long tmem_objnode_tree_h2max[OBJNODE_TREE_MAX_PATH + 1];
+
+static void tmem_objnode_tree_init(void)
+{
+	unsigned int ht, tmp;
+
+	for (ht = 0; ht < ARRAY_SIZE(tmem_objnode_tree_h2max); ht++) {
+		tmp = ht * OBJNODE_TREE_MAP_SHIFT;
+		if (tmp >= OBJNODE_TREE_INDEX_BITS)
+			tmem_objnode_tree_h2max[ht] = ~0UL;
+		else
+			tmem_objnode_tree_h2max[ht] =
+			    (~0UL >> (OBJNODE_TREE_INDEX_BITS - tmp - 1)) >> 1;
+	}
+}
+
+static struct tmem_objnode *tmem_objnode_alloc(struct tmem_obj *obj)
+{
+	struct tmem_objnode *objnode;
+
+	ASSERT_SENTINEL(obj, OBJ);
+	BUG_ON(obj->pool == NULL);
+	ASSERT_SENTINEL(obj->pool, POOL);
+	objnode = (*tmem_hostops.objnode_alloc)(obj->pool);
+	if (unlikely(objnode == NULL))
+		goto out;
+	objnode->obj = obj;
+	SET_SENTINEL(objnode, OBJNODE);
+	memset(&objnode->slots, 0, sizeof(objnode->slots));
+	objnode->slots_in_use = 0;
+	obj->objnode_count++;
+out:
+	return objnode;
+}
+
+static void tmem_objnode_free(struct tmem_objnode *objnode)
+{
+	struct tmem_pool *pool;
+	int i;
+
+	BUG_ON(objnode == NULL);
+	for (i = 0; i < OBJNODE_TREE_MAP_SIZE; i++)
+		BUG_ON(objnode->slots[i] != NULL);
+	ASSERT_SENTINEL(objnode, OBJNODE);
+	INVERT_SENTINEL(objnode, OBJNODE);
+	BUG_ON(objnode->obj == NULL);
+	ASSERT_SENTINEL(objnode->obj, OBJ);
+	pool = objnode->obj->pool;
+	BUG_ON(pool == NULL);
+	ASSERT_SENTINEL(pool, POOL);
+	objnode->obj->objnode_count--;
+	objnode->obj = NULL;
+	(*tmem_hostops.objnode_free)(objnode, pool);
+}
+
+/*
+ * Lookup index in object and return associated pampd (or NULL if not found).
+ */
+static void **__tmem_pampd_lookup_in_obj(struct tmem_obj *obj, uint32_t index)
+{
+	unsigned int height, shift;
+	struct tmem_objnode **slot = NULL;
+
+	BUG_ON(obj == NULL);
+	ASSERT_SENTINEL(obj, OBJ);
+	BUG_ON(obj->pool == NULL);
+	ASSERT_SENTINEL(obj->pool, POOL);
+
+	height = obj->objnode_tree_height;
+	if (index > tmem_objnode_tree_h2max[obj->objnode_tree_height])
+		goto out;
+	if (height == 0 && obj->objnode_tree_root) {
+		slot = &obj->objnode_tree_root;
+		goto out;
+	}
+	shift = (height-1) * OBJNODE_TREE_MAP_SHIFT;
+	slot = &obj->objnode_tree_root;
+	while (height > 0) {
+		if (*slot == NULL)
+			goto out;
+		slot = (struct tmem_objnode **)
+			((*slot)->slots +
+			 ((index >> shift) & OBJNODE_TREE_MAP_MASK));
+		shift -= OBJNODE_TREE_MAP_SHIFT;
+		height--;
+	}
+out:
+	return slot != NULL ? (void **)slot : NULL;
+}
+
+static void *tmem_pampd_lookup_in_obj(struct tmem_obj *obj, uint32_t index)
+{
+	struct tmem_objnode **slot;
+
+	slot = (struct tmem_objnode **)__tmem_pampd_lookup_in_obj(obj, index);
+	return slot != NULL ? *slot : NULL;
+}
+
+#ifdef CONFIG_RAMSTER
+static void *tmem_pampd_replace_in_obj(struct tmem_obj *obj, uint32_t index,
+					void *new_pampd, bool no_free)
+{
+	struct tmem_objnode **slot;
+	void *ret = NULL;
+
+	slot = (struct tmem_objnode **)__tmem_pampd_lookup_in_obj(obj, index);
+	if ((slot != NULL) && (*slot != NULL)) {
+		void *old_pampd = *(void **)slot;
+		*(void **)slot = new_pampd;
+		if (!no_free)
+			(*tmem_pamops.free)(old_pampd, obj->pool,
+						NULL, 0, false);
+		ret = new_pampd;
+	}
+	return ret;
+}
+#endif
+
+static int tmem_pampd_add_to_obj(struct tmem_obj *obj, uint32_t index,
+					void *pampd)
+{
+	int ret = 0;
+	struct tmem_objnode *objnode = NULL, *newnode, *slot;
+	unsigned int height, shift;
+	int offset = 0;
+
+	/* if necessary, extend the tree to be higher  */
+	if (index > tmem_objnode_tree_h2max[obj->objnode_tree_height]) {
+		height = obj->objnode_tree_height + 1;
+		if (index > tmem_objnode_tree_h2max[height])
+			while (index > tmem_objnode_tree_h2max[height])
+				height++;
+		if (obj->objnode_tree_root == NULL) {
+			obj->objnode_tree_height = height;
+			goto insert;
+		}
+		do {
+			newnode = tmem_objnode_alloc(obj);
+			if (!newnode) {
+				ret = -ENOMEM;
+				goto out;
+			}
+			newnode->slots[0] = obj->objnode_tree_root;
+			newnode->slots_in_use = 1;
+			obj->objnode_tree_root = newnode;
+			obj->objnode_tree_height++;
+		} while (height > obj->objnode_tree_height);
+	}
+insert:
+	slot = obj->objnode_tree_root;
+	height = obj->objnode_tree_height;
+	shift = (height-1) * OBJNODE_TREE_MAP_SHIFT;
+	while (height > 0) {
+		if (slot == NULL) {
+			/* add a child objnode.  */
+			slot = tmem_objnode_alloc(obj);
+			if (!slot) {
+				ret = -ENOMEM;
+				goto out;
+			}
+			if (objnode) {
+
+				objnode->slots[offset] = slot;
+				objnode->slots_in_use++;
+			} else
+				obj->objnode_tree_root = slot;
+		}
+		/* go down a level */
+		offset = (index >> shift) & OBJNODE_TREE_MAP_MASK;
+		objnode = slot;
+		slot = objnode->slots[offset];
+		shift -= OBJNODE_TREE_MAP_SHIFT;
+		height--;
+	}
+	BUG_ON(slot != NULL);
+	if (objnode) {
+		objnode->slots_in_use++;
+		objnode->slots[offset] = pampd;
+	} else
+		obj->objnode_tree_root = pampd;
+	obj->pampd_count++;
+out:
+	return ret;
+}
+
+static void *tmem_pampd_delete_from_obj(struct tmem_obj *obj, uint32_t index)
+{
+	struct tmem_objnode_tree_path path[OBJNODE_TREE_MAX_PATH + 1];
+	struct tmem_objnode_tree_path *pathp = path;
+	struct tmem_objnode *slot = NULL;
+	unsigned int height, shift;
+	int offset;
+
+	BUG_ON(obj == NULL);
+	ASSERT_SENTINEL(obj, OBJ);
+	BUG_ON(obj->pool == NULL);
+	ASSERT_SENTINEL(obj->pool, POOL);
+	height = obj->objnode_tree_height;
+	if (index > tmem_objnode_tree_h2max[height])
+		goto out;
+	slot = obj->objnode_tree_root;
+	if (height == 0 && obj->objnode_tree_root) {
+		obj->objnode_tree_root = NULL;
+		goto out;
+	}
+	shift = (height - 1) * OBJNODE_TREE_MAP_SHIFT;
+	pathp->objnode = NULL;
+	do {
+		if (slot == NULL)
+			goto out;
+		pathp++;
+		offset = (index >> shift) & OBJNODE_TREE_MAP_MASK;
+		pathp->offset = offset;
+		pathp->objnode = slot;
+		slot = slot->slots[offset];
+		shift -= OBJNODE_TREE_MAP_SHIFT;
+		height--;
+	} while (height > 0);
+	if (slot == NULL)
+		goto out;
+	while (pathp->objnode) {
+		pathp->objnode->slots[pathp->offset] = NULL;
+		pathp->objnode->slots_in_use--;
+		if (pathp->objnode->slots_in_use) {
+			if (pathp->objnode == obj->objnode_tree_root) {
+				while (obj->objnode_tree_height > 0 &&
+				  obj->objnode_tree_root->slots_in_use == 1 &&
+				  obj->objnode_tree_root->slots[0]) {
+					struct tmem_objnode *to_free =
+						obj->objnode_tree_root;
+
+					obj->objnode_tree_root =
+							to_free->slots[0];
+					obj->objnode_tree_height--;
+					to_free->slots[0] = NULL;
+					to_free->slots_in_use = 0;
+					tmem_objnode_free(to_free);
+				}
+			}
+			goto out;
+		}
+		tmem_objnode_free(pathp->objnode); /* 0 slots used, free it */
+		pathp--;
+	}
+	obj->objnode_tree_height = 0;
+	obj->objnode_tree_root = NULL;
+
+out:
+	if (slot != NULL)
+		obj->pampd_count--;
+	BUG_ON(obj->pampd_count < 0);
+	return slot;
+}
+
+/* Recursively walk the objnode_tree destroying pampds and objnodes. */
+static void tmem_objnode_node_destroy(struct tmem_obj *obj,
+					struct tmem_objnode *objnode,
+					unsigned int ht)
+{
+	int i;
+
+	if (ht == 0)
+		return;
+	for (i = 0; i < OBJNODE_TREE_MAP_SIZE; i++) {
+		if (objnode->slots[i]) {
+			if (ht == 1) {
+				obj->pampd_count--;
+				(*tmem_pamops.free)(objnode->slots[i],
+						obj->pool, NULL, 0, true);
+				objnode->slots[i] = NULL;
+				continue;
+			}
+			tmem_objnode_node_destroy(obj, objnode->slots[i], ht-1);
+			tmem_objnode_free(objnode->slots[i]);
+			objnode->slots[i] = NULL;
+		}
+	}
+}
+
+static void tmem_pampd_destroy_all_in_obj(struct tmem_obj *obj,
+						bool pool_destroy)
+{
+	if (obj->objnode_tree_root == NULL)
+		return;
+	if (obj->objnode_tree_height == 0) {
+		obj->pampd_count--;
+		(*tmem_pamops.free)(obj->objnode_tree_root,
+					obj->pool, NULL, 0, true);
+	} else {
+		tmem_objnode_node_destroy(obj, obj->objnode_tree_root,
+					obj->objnode_tree_height);
+		tmem_objnode_free(obj->objnode_tree_root);
+		obj->objnode_tree_height = 0;
+	}
+	obj->objnode_tree_root = NULL;
+#ifdef CONFIG_RAMSTER
+	if (tmem_pamops.free_obj != NULL)
+		(*tmem_pamops.free_obj)(obj->pool, obj, pool_destroy);
+#endif
+}
+
+/*
+ * Tmem is operated on by a set of well-defined actions:
+ * "put", "get", "flush", "flush_object", "new pool" and "destroy pool".
+ * (The tmem ABI allows for subpages and exchanges but these operations
+ * are not included in this implementation.)
+ *
+ * These "tmem core" operations are implemented in the following functions.
+ */
+
+/*
+ * "Put" a page, e.g. associate the passed pampd with the passed handle.
+ * Tmem_put is complicated by a corner case: What if a page with matching
+ * handle already exists in tmem?  To guarantee coherency, one of two
+ * actions is necessary: Either the data for the page must be overwritten,
+ * or the page must be "flushed" so that the data is not accessible to a
+ * subsequent "get".  Since these "duplicate puts" are relatively rare,
+ * this implementation always flushes for simplicity.
+ */
+int tmem_put(struct tmem_pool *pool, struct tmem_oid *oidp, uint32_t index,
+		bool raw, void *pampd_to_use)
+{
+	struct tmem_obj *obj = NULL, *objfound = NULL, *objnew = NULL;
+	void *pampd = NULL, *pampd_del = NULL;
+	int ret = -ENOMEM;
+	struct tmem_hashbucket *hb;
+
+	hb = &pool->hashbucket[tmem_oid_hash(oidp)];
+	spin_lock(&hb->lock);
+	obj = objfound = tmem_obj_find(hb, oidp);
+	if (obj != NULL) {
+		pampd = tmem_pampd_lookup_in_obj(objfound, index);
+		if (pampd != NULL) {
+			/* if found, is a dup put, flush the old one */
+			pampd_del = tmem_pampd_delete_from_obj(obj, index);
+			BUG_ON(pampd_del != pampd);
+			(*tmem_pamops.free)(pampd, pool, oidp, index, true);
+			if (obj->pampd_count == 0) {
+				objnew = obj;
+				objfound = NULL;
+			}
+			pampd = NULL;
+		}
+	} else {
+		obj = objnew = (*tmem_hostops.obj_alloc)(pool);
+		if (unlikely(obj == NULL)) {
+			ret = -ENOMEM;
+			goto out;
+		}
+		tmem_obj_init(obj, hb, pool, oidp);
+	}
+	BUG_ON(obj == NULL);
+	BUG_ON(((objnew != obj) && (objfound != obj)) || (objnew == objfound));
+	pampd = pampd_to_use;
+	BUG_ON(pampd_to_use == NULL);
+	ret = tmem_pampd_add_to_obj(obj, index, pampd);
+	if (unlikely(ret == -ENOMEM))
+		/* may have partially built objnode tree ("stump") */
+		goto delete_and_free;
+	(*tmem_pamops.create_finish)(pampd, is_ephemeral(pool));
+	goto out;
+
+delete_and_free:
+	(void)tmem_pampd_delete_from_obj(obj, index);
+	if (pampd)
+		(*tmem_pamops.free)(pampd, pool, NULL, 0, true);
+	if (objnew) {
+		tmem_obj_free(objnew, hb);
+		(*tmem_hostops.obj_free)(objnew, pool);
+	}
+out:
+	spin_unlock(&hb->lock);
+	return ret;
+}
+
+#ifdef CONFIG_RAMSTER
+/*
+ * For ramster only:  The following routines provide a two-step sequence
+ * to allow the caller to replace a pampd in the tmem data structures with
+ * another pampd. Here, we lookup the passed handle and, if found, return the
+ * associated pampd and object, leaving the hashbucket locked and returning
+ * a reference to it.  The caller is expected to immediately call the
+ * matching tmem_localify_finish routine which will handles the replacement
+ * and unlocks the hashbucket.
+ */
+void *tmem_localify_get_pampd(struct tmem_pool *pool, struct tmem_oid *oidp,
+				uint32_t index, struct tmem_obj **ret_obj,
+				void **saved_hb)
+{
+	struct tmem_hashbucket *hb;
+	struct tmem_obj *obj = NULL;
+	void *pampd = NULL;
+
+	hb = &pool->hashbucket[tmem_oid_hash(oidp)];
+	spin_lock(&hb->lock);
+	obj = tmem_obj_find(hb, oidp);
+	if (likely(obj != NULL))
+		pampd = tmem_pampd_lookup_in_obj(obj, index);
+	*ret_obj = obj;
+	*saved_hb = (void *)hb;
+	/* note, hashbucket remains locked */
+	return pampd;
+}
+
+void tmem_localify_finish(struct tmem_obj *obj, uint32_t index,
+			  void *pampd, void *saved_hb, bool delete)
+{
+	struct tmem_hashbucket *hb = (struct tmem_hashbucket *)saved_hb;
+
+	BUG_ON(!spin_is_locked(&hb->lock));
+	if (pampd != NULL) {
+		BUG_ON(obj == NULL);
+		(void)tmem_pampd_replace_in_obj(obj, index, pampd, 1);
+		(*tmem_pamops.create_finish)(pampd, is_ephemeral(obj->pool));
+	} else if (delete) {
+		BUG_ON(obj == NULL);
+		(void)tmem_pampd_delete_from_obj(obj, index);
+	}
+	spin_unlock(&hb->lock);
+}
+
+/*
+ * For ramster only.  Helper function to support asynchronous tmem_get.
+ */
+static int tmem_repatriate(void **ppampd, struct tmem_hashbucket *hb,
+				struct tmem_pool *pool, struct tmem_oid *oidp,
+				uint32_t index, bool free, char *data)
+{
+	void *old_pampd = *ppampd, *new_pampd = NULL;
+	bool intransit = false;
+	int ret = 0;
+
+	if (!is_ephemeral(pool))
+		new_pampd = (*tmem_pamops.repatriate_preload)(
+				old_pampd, pool, oidp, index, &intransit);
+	if (intransit)
+		ret = -EAGAIN;
+	else if (new_pampd != NULL)
+		*ppampd = new_pampd;
+	/* must release the hb->lock else repatriate can't sleep */
+	spin_unlock(&hb->lock);
+	if (!intransit)
+		ret = (*tmem_pamops.repatriate)(old_pampd, new_pampd, pool,
+						oidp, index, free, data);
+	if (ret == -EAGAIN) {
+		/* rare I think, but should cond_resched()??? */
+		usleep_range(10, 1000);
+	} else if (ret == -ENOTCONN || ret == -EHOSTDOWN) {
+		ret = -1;
+	} else if (ret != 0 && ret != -ENOENT) {
+		ret = -1;
+	}
+	/* note hb->lock has now been unlocked */
+	return ret;
+}
+
+/*
+ * For ramster only.  If a page in tmem matches the handle, replace the
+ * page so that any subsequent "get" gets the new page.  Returns 0 if
+ * there was a page to replace, else returns -1.
+ */
+int tmem_replace(struct tmem_pool *pool, struct tmem_oid *oidp,
+			uint32_t index, void *new_pampd)
+{
+	struct tmem_obj *obj;
+	int ret = -1;
+	struct tmem_hashbucket *hb;
+
+	hb = &pool->hashbucket[tmem_oid_hash(oidp)];
+	spin_lock(&hb->lock);
+	obj = tmem_obj_find(hb, oidp);
+	if (obj == NULL)
+		goto out;
+	new_pampd = tmem_pampd_replace_in_obj(obj, index, new_pampd, 0);
+	/* if we bug here, pamops wasn't properly set up for ramster */
+	BUG_ON(tmem_pamops.replace_in_obj == NULL);
+	ret = (*tmem_pamops.replace_in_obj)(new_pampd, obj);
+out:
+	spin_unlock(&hb->lock);
+	return ret;
+}
+#endif
+
+/*
+ * "Get" a page, e.g. if a pampd can be found matching the passed handle,
+ * use a pamops callback to recreated the page from the pampd with the
+ * matching handle.  By tmem definition, when a "get" is successful on
+ * an ephemeral page, the page is "flushed", and when a "get" is successful
+ * on a persistent page, the page is retained in tmem.  Note that to preserve
+ * coherency, "get" can never be skipped if tmem contains the data.
+ * That is, if a get is done with a certain handle and fails, any
+ * subsequent "get" must also fail (unless of course there is a
+ * "put" done with the same handle).
+ */
+int tmem_get(struct tmem_pool *pool, struct tmem_oid *oidp, uint32_t index,
+		char *data, size_t *sizep, bool raw, int get_and_free)
+{
+	struct tmem_obj *obj;
+	void *pampd = NULL;
+	bool ephemeral = is_ephemeral(pool);
+	int ret = -1;
+	struct tmem_hashbucket *hb;
+	bool free = (get_and_free == 1) || ((get_and_free == 0) && ephemeral);
+	bool lock_held = false;
+	void **ppampd;
+
+	do {
+		hb = &pool->hashbucket[tmem_oid_hash(oidp)];
+		spin_lock(&hb->lock);
+		lock_held = true;
+		obj = tmem_obj_find(hb, oidp);
+		if (obj == NULL)
+			goto out;
+		ppampd = __tmem_pampd_lookup_in_obj(obj, index);
+		if (ppampd == NULL)
+			goto out;
+#ifdef CONFIG_RAMSTER
+		if ((tmem_pamops.is_remote != NULL) &&
+		     tmem_pamops.is_remote(*ppampd)) {
+			ret = tmem_repatriate(ppampd, hb, pool, oidp,
+						index, free, data);
+			/* tmem_repatriate releases hb->lock */
+			lock_held = false;
+			*sizep = PAGE_SIZE;
+			if (ret != -EAGAIN)
+				goto out;
+		}
+#endif
+	} while (ret == -EAGAIN);
+	if (free)
+		pampd = tmem_pampd_delete_from_obj(obj, index);
+	else
+		pampd = tmem_pampd_lookup_in_obj(obj, index);
+	if (pampd == NULL)
+		goto out;
+	if (free) {
+		if (obj->pampd_count == 0) {
+			tmem_obj_free(obj, hb);
+			(*tmem_hostops.obj_free)(obj, pool);
+			obj = NULL;
+		}
+	}
+	if (free)
+		ret = (*tmem_pamops.get_data_and_free)(
+				data, sizep, raw, pampd, pool, oidp, index);
+	else
+		ret = (*tmem_pamops.get_data)(
+				data, sizep, raw, pampd, pool, oidp, index);
+	if (ret < 0)
+		goto out;
+	ret = 0;
+out:
+	if (lock_held)
+		spin_unlock(&hb->lock);
+	return ret;
+}
+
+/*
+ * If a page in tmem matches the handle, "flush" this page from tmem such
+ * that any subsequent "get" does not succeed (unless, of course, there
+ * was another "put" with the same handle).
+ */
+int tmem_flush_page(struct tmem_pool *pool,
+				struct tmem_oid *oidp, uint32_t index)
+{
+	struct tmem_obj *obj;
+	void *pampd;
+	int ret = -1;
+	struct tmem_hashbucket *hb;
+
+	hb = &pool->hashbucket[tmem_oid_hash(oidp)];
+	spin_lock(&hb->lock);
+	obj = tmem_obj_find(hb, oidp);
+	if (obj == NULL)
+		goto out;
+	pampd = tmem_pampd_delete_from_obj(obj, index);
+	if (pampd == NULL)
+		goto out;
+	(*tmem_pamops.free)(pampd, pool, oidp, index, true);
+	if (obj->pampd_count == 0) {
+		tmem_obj_free(obj, hb);
+		(*tmem_hostops.obj_free)(obj, pool);
+	}
+	ret = 0;
+
+out:
+	spin_unlock(&hb->lock);
+	return ret;
+}
+
+/*
+ * "Flush" all pages in tmem matching this oid.
+ */
+int tmem_flush_object(struct tmem_pool *pool, struct tmem_oid *oidp)
+{
+	struct tmem_obj *obj;
+	struct tmem_hashbucket *hb;
+	int ret = -1;
+
+	hb = &pool->hashbucket[tmem_oid_hash(oidp)];
+	spin_lock(&hb->lock);
+	obj = tmem_obj_find(hb, oidp);
+	if (obj == NULL)
+		goto out;
+	tmem_pampd_destroy_all_in_obj(obj, false);
+	tmem_obj_free(obj, hb);
+	(*tmem_hostops.obj_free)(obj, pool);
+	ret = 0;
+
+out:
+	spin_unlock(&hb->lock);
+	return ret;
+}
+
+/*
+ * "Flush" all pages (and tmem_objs) from this tmem_pool and disable
+ * all subsequent access to this tmem_pool.
+ */
+int tmem_destroy_pool(struct tmem_pool *pool)
+{
+	int ret = -1;
+
+	if (pool == NULL)
+		goto out;
+	tmem_pool_flush(pool, 1);
+	ret = 0;
+out:
+	return ret;
+}
+
+static LIST_HEAD(tmem_global_pool_list);
+
+/*
+ * Create a new tmem_pool with the provided flag and return
+ * a pool id provided by the tmem host implementation.
+ */
+void tmem_new_pool(struct tmem_pool *pool, uint32_t flags)
+{
+	int persistent = flags & TMEM_POOL_PERSIST;
+	int shared = flags & TMEM_POOL_SHARED;
+	struct tmem_hashbucket *hb = &pool->hashbucket[0];
+	int i;
+
+	for (i = 0; i < TMEM_HASH_BUCKETS; i++, hb++) {
+		hb->obj_rb_root = RB_ROOT;
+		spin_lock_init(&hb->lock);
+	}
+	INIT_LIST_HEAD(&pool->pool_list);
+	atomic_set(&pool->obj_count, 0);
+	SET_SENTINEL(pool, POOL);
+	list_add_tail(&pool->pool_list, &tmem_global_pool_list);
+	pool->persistent = persistent;
+	pool->shared = shared;
+}
diff --git a/drivers/staging/zcache/tmem.h b/drivers/staging/zcache/tmem.h
new file mode 100644
index 0000000..adbe5a8
--- /dev/null
+++ b/drivers/staging/zcache/tmem.h
@@ -0,0 +1,259 @@
+/*
+ * tmem.h
+ *
+ * Transcendent memory
+ *
+ * Copyright (c) 2009-2012, Dan Magenheimer, Oracle Corp.
+ */
+
+#ifndef _TMEM_H_
+#define _TMEM_H_
+
+#include <linux/types.h>
+#include <linux/highmem.h>
+#include <linux/hash.h>
+#include <linux/atomic.h>
+
+/*
+ * These are defined by the Xen<->Linux ABI so should remain consistent
+ */
+#define TMEM_POOL_PERSIST		1
+#define TMEM_POOL_SHARED		2
+#define TMEM_POOL_PRECOMPRESSED		4
+#define TMEM_POOL_PAGESIZE_SHIFT	4
+#define TMEM_POOL_PAGESIZE_MASK		0xf
+#define TMEM_POOL_RESERVED_BITS		0x00ffff00
+
+/*
+ * sentinels have proven very useful for debugging but can be removed
+ * or disabled before final merge.
+ */
+#undef SENTINELS
+#ifdef SENTINELS
+#define DECL_SENTINEL uint32_t sentinel;
+#define SET_SENTINEL(_x, _y) (_x->sentinel = _y##_SENTINEL)
+#define INVERT_SENTINEL(_x, _y) (_x->sentinel = ~_y##_SENTINEL)
+#define ASSERT_SENTINEL(_x, _y) WARN_ON(_x->sentinel != _y##_SENTINEL)
+#define ASSERT_INVERTED_SENTINEL(_x, _y) WARN_ON(_x->sentinel != ~_y##_SENTINEL)
+#else
+#define DECL_SENTINEL
+#define SET_SENTINEL(_x, _y) do { } while (0)
+#define INVERT_SENTINEL(_x, _y) do { } while (0)
+#define ASSERT_SENTINEL(_x, _y) do { } while (0)
+#define ASSERT_INVERTED_SENTINEL(_x, _y) do { } while (0)
+#endif
+
+#define ASSERT_SPINLOCK(_l)	lockdep_assert_held(_l)
+
+/*
+ * A pool is the highest-level data structure managed by tmem and
+ * usually corresponds to a large independent set of pages such as
+ * a filesystem.  Each pool has an id, and certain attributes and counters.
+ * It also contains a set of hash buckets, each of which contains an rbtree
+ * of objects and a lock to manage concurrency within the pool.
+ */
+
+#define TMEM_HASH_BUCKET_BITS	8
+#define TMEM_HASH_BUCKETS	(1<<TMEM_HASH_BUCKET_BITS)
+
+struct tmem_hashbucket {
+	struct rb_root obj_rb_root;
+	spinlock_t lock;
+};
+
+struct tmem_pool {
+	void *client; /* "up" for some clients, avoids table lookup */
+	struct list_head pool_list;
+	uint32_t pool_id;
+	bool persistent;
+	bool shared;
+	atomic_t obj_count;
+	atomic_t refcount;
+	struct tmem_hashbucket hashbucket[TMEM_HASH_BUCKETS];
+	DECL_SENTINEL
+};
+
+#define is_persistent(_p)  (_p->persistent)
+#define is_ephemeral(_p)   (!(_p->persistent))
+
+/*
+ * An object id ("oid") is large: 192-bits (to ensure, for example, files
+ * in a modern filesystem can be uniquely identified).
+ */
+
+struct tmem_oid {
+	uint64_t oid[3];
+};
+
+static inline void tmem_oid_set_invalid(struct tmem_oid *oidp)
+{
+	oidp->oid[0] = oidp->oid[1] = oidp->oid[2] = -1UL;
+}
+
+static inline bool tmem_oid_valid(struct tmem_oid *oidp)
+{
+	return oidp->oid[0] != -1UL || oidp->oid[1] != -1UL ||
+		oidp->oid[2] != -1UL;
+}
+
+static inline int tmem_oid_compare(struct tmem_oid *left,
+					struct tmem_oid *right)
+{
+	int ret;
+
+	if (left->oid[2] == right->oid[2]) {
+		if (left->oid[1] == right->oid[1]) {
+			if (left->oid[0] == right->oid[0])
+				ret = 0;
+			else if (left->oid[0] < right->oid[0])
+				ret = -1;
+			else
+				return 1;
+		} else if (left->oid[1] < right->oid[1])
+			ret = -1;
+		else
+			ret = 1;
+	} else if (left->oid[2] < right->oid[2])
+		ret = -1;
+	else
+		ret = 1;
+	return ret;
+}
+
+static inline unsigned tmem_oid_hash(struct tmem_oid *oidp)
+{
+	return hash_long(oidp->oid[0] ^ oidp->oid[1] ^ oidp->oid[2],
+				TMEM_HASH_BUCKET_BITS);
+}
+
+#ifdef CONFIG_RAMSTER
+struct tmem_xhandle {
+	uint8_t client_id;
+	uint8_t xh_data_cksum;
+	uint16_t xh_data_size;
+	uint16_t pool_id;
+	struct tmem_oid oid;
+	uint32_t index;
+	void *extra;
+};
+
+static inline struct tmem_xhandle tmem_xhandle_fill(uint16_t client_id,
+					struct tmem_pool *pool,
+					struct tmem_oid *oidp,
+					uint32_t index)
+{
+	struct tmem_xhandle xh;
+	xh.client_id = client_id;
+	xh.xh_data_cksum = (uint8_t)-1;
+	xh.xh_data_size = (uint16_t)-1;
+	xh.pool_id = pool->pool_id;
+	xh.oid = *oidp;
+	xh.index = index;
+	return xh;
+}
+#endif
+
+
+/*
+ * A tmem_obj contains an identifier (oid), pointers to the parent
+ * pool and the rb_tree to which it belongs, counters, and an ordered
+ * set of pampds, structured in a radix-tree-like tree.  The intermediate
+ * nodes of the tree are called tmem_objnodes.
+ */
+
+struct tmem_objnode;
+
+struct tmem_obj {
+	struct tmem_oid oid;
+	struct tmem_pool *pool;
+	struct rb_node rb_tree_node;
+	struct tmem_objnode *objnode_tree_root;
+	unsigned int objnode_tree_height;
+	unsigned long objnode_count;
+	long pampd_count;
+#ifdef CONFIG_RAMSTER
+	/*
+	 * for current design of ramster, all pages belonging to
+	 * an object reside on the same remotenode and extra is
+	 * used to record the number of the remotenode so a
+	 * flush-object operation can specify it
+	 */
+	void *extra; /* for private use by pampd implementation */
+#endif
+	DECL_SENTINEL
+};
+
+#define OBJNODE_TREE_MAP_SHIFT 6
+#define OBJNODE_TREE_MAP_SIZE (1UL << OBJNODE_TREE_MAP_SHIFT)
+#define OBJNODE_TREE_MAP_MASK (OBJNODE_TREE_MAP_SIZE-1)
+#define OBJNODE_TREE_INDEX_BITS (8 /* CHAR_BIT */ * sizeof(unsigned long))
+#define OBJNODE_TREE_MAX_PATH \
+		(OBJNODE_TREE_INDEX_BITS/OBJNODE_TREE_MAP_SHIFT + 2)
+
+struct tmem_objnode {
+	struct tmem_obj *obj;
+	DECL_SENTINEL
+	void *slots[OBJNODE_TREE_MAP_SIZE];
+	unsigned int slots_in_use;
+};
+
+struct tmem_handle {
+	struct tmem_oid oid; /* 24 bytes */
+	uint32_t index;
+	uint16_t pool_id;
+	uint16_t client_id;
+};
+
+
+/* pampd abstract datatype methods provided by the PAM implementation */
+struct tmem_pamops {
+	void (*create_finish)(void *, bool);
+	int (*get_data)(char *, size_t *, bool, void *, struct tmem_pool *,
+				struct tmem_oid *, uint32_t);
+	int (*get_data_and_free)(char *, size_t *, bool, void *,
+				struct tmem_pool *, struct tmem_oid *,
+				uint32_t);
+	void (*free)(void *, struct tmem_pool *,
+				struct tmem_oid *, uint32_t, bool);
+#ifdef CONFIG_RAMSTER
+	void (*new_obj)(struct tmem_obj *);
+	void (*free_obj)(struct tmem_pool *, struct tmem_obj *, bool);
+	void *(*repatriate_preload)(void *, struct tmem_pool *,
+					struct tmem_oid *, uint32_t, bool *);
+	int (*repatriate)(void *, void *, struct tmem_pool *,
+				struct tmem_oid *, uint32_t, bool, void *);
+	bool (*is_remote)(void *);
+	int (*replace_in_obj)(void *, struct tmem_obj *);
+#endif
+};
+extern void tmem_register_pamops(struct tmem_pamops *m);
+
+/* memory allocation methods provided by the host implementation */
+struct tmem_hostops {
+	struct tmem_obj *(*obj_alloc)(struct tmem_pool *);
+	void (*obj_free)(struct tmem_obj *, struct tmem_pool *);
+	struct tmem_objnode *(*objnode_alloc)(struct tmem_pool *);
+	void (*objnode_free)(struct tmem_objnode *, struct tmem_pool *);
+};
+extern void tmem_register_hostops(struct tmem_hostops *m);
+
+/* core tmem accessor functions */
+extern int tmem_put(struct tmem_pool *, struct tmem_oid *, uint32_t index,
+			bool, void *);
+extern int tmem_get(struct tmem_pool *, struct tmem_oid *, uint32_t index,
+			char *, size_t *, bool, int);
+extern int tmem_flush_page(struct tmem_pool *, struct tmem_oid *,
+			uint32_t index);
+extern int tmem_flush_object(struct tmem_pool *, struct tmem_oid *);
+extern int tmem_destroy_pool(struct tmem_pool *);
+extern void tmem_new_pool(struct tmem_pool *, uint32_t);
+#ifdef CONFIG_RAMSTER
+extern int tmem_replace(struct tmem_pool *, struct tmem_oid *, uint32_t index,
+			void *);
+extern void *tmem_localify_get_pampd(struct tmem_pool *, struct tmem_oid *,
+				   uint32_t index, struct tmem_obj **,
+				   void **);
+extern void tmem_localify_finish(struct tmem_obj *, uint32_t index,
+				 void *, void *, bool);
+#endif
+#endif /* _TMEM_H */
diff --git a/drivers/staging/zcache/zbud.c b/drivers/staging/zcache/zbud.c
new file mode 100644
index 0000000..a7c4361
--- /dev/null
+++ b/drivers/staging/zcache/zbud.c
@@ -0,0 +1,1060 @@
+/*
+ * zbud.c - Compression buddies allocator
+ *
+ * Copyright (c) 2010-2012, Dan Magenheimer, Oracle Corp.
+ *
+ * Compression buddies ("zbud") provides for efficiently packing two
+ * (or, possibly in the future, more) compressed pages ("zpages") into
+ * a single "raw" pageframe and for tracking both zpages and pageframes
+ * so that whole pageframes can be easily reclaimed in LRU-like order.
+ * It is designed to be used in conjunction with transcendent memory
+ * ("tmem"); for example separate LRU lists are maintained for persistent
+ * vs. ephemeral pages.
+ *
+ * A zbudpage is an overlay for a struct page and thus each zbudpage
+ * refers to a physical pageframe of RAM.  When the caller passes a
+ * struct page from the kernel's page allocator, zbud "transforms" it
+ * to a zbudpage which sets/uses a different set of fields than the
+ * struct-page and thus must "untransform" it back by reinitializing
+ * certain fields before the struct-page can be freed.  The fields
+ * of a zbudpage include a page lock for controlling access to the
+ * corresponding pageframe, and there is a size field for each zpage.
+ * Each zbudpage also lives on two linked lists: a "budlist" which is
+ * used to support efficient buddying of zpages; and an "lru" which
+ * is used for reclaiming pageframes in approximately least-recently-used
+ * order.
+ *
+ * A zbudpageframe is a pageframe divided up into aligned 64-byte "chunks"
+ * which contain the compressed data for zero, one, or two zbuds.  Contained
+ * with the compressed data is a tmem_handle which is a key to allow
+ * the same data to be found via the tmem interface so the zpage can
+ * be invalidated (for ephemeral pages) or repatriated to the swap cache
+ * (for persistent pages).  The contents of a zbudpageframe must never
+ * be accessed without holding the page lock for the corresponding
+ * zbudpage and, to accomodate highmem machines, the contents may
+ * only be examined or changes when kmapped.  Thus, when in use, a
+ * kmapped zbudpageframe is referred to in the zbud code as "void *zbpg".
+ *
+ * Note that the term "zbud" refers to the combination of a zpage and
+ * a tmem_handle that is stored as one of possibly two "buddied" zpages;
+ * it also generically refers to this allocator... sorry for any confusion.
+ *
+ * A zbudref is a pointer to a struct zbudpage (which can be cast to a
+ * struct page), with the LSB either cleared or set to indicate, respectively,
+ * the first or second zpage in the zbudpageframe. Since a zbudref can be
+ * cast to a pointer, it is used as the tmem "pampd" pointer and uniquely
+ * references a stored tmem page and so is the only zbud data structure
+ * externally visible to zbud.c/zbud.h.
+ *
+ * Since we wish to reclaim entire pageframes but zpages may be randomly
+ * added and deleted to any given pageframe, we approximate LRU by
+ * promoting a pageframe to MRU when a zpage is added to it, but
+ * leaving it at the current place in the list when a zpage is deleted
+ * from it.  As a side effect, zpages that are difficult to buddy (e.g.
+ * very large paages) will be reclaimed faster than average, which seems
+ * reasonable.
+ *
+ * In the current implementation, no more than two zpages may be stored in
+ * any pageframe and no zpage ever crosses a pageframe boundary.  While
+ * other zpage allocation mechanisms may allow greater density, this two
+ * zpage-per-pageframe limit both ensures simple reclaim of pageframes
+ * (including garbage collection of references to the contents of those
+ * pageframes from tmem data structures) AND avoids the need for compaction.
+ * With additional complexity, zbud could be modified to support storing
+ * up to three zpages per pageframe or, to handle larger average zpages,
+ * up to three zpages per pair of pageframes, but it is not clear if the
+ * additional complexity would be worth it.  So consider it an exercise
+ * for future developers.
+ *
+ * Note also that zbud does no page allocation or freeing.  This is so
+ * that the caller has complete control over and, for accounting, visibility
+ * into if/when pages are allocated and freed.
+ *
+ * Finally, note that zbud limits the size of zpages it can store; the
+ * caller must check the zpage size with zbud_max_buddy_size before
+ * storing it, else BUGs will result.  User beware.
+ */
+
+#include <linux/module.h>
+#include <linux/highmem.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/pagemap.h>
+#include <linux/atomic.h>
+#include <linux/bug.h>
+#include "tmem.h"
+#include "zcache.h"
+#include "zbud.h"
+
+/*
+ * We need to ensure that a struct zbudpage is never larger than a
+ * struct page.  This is checked with a BUG_ON in zbud_init.
+ *
+ * The unevictable field indicates that a zbud is being added to the
+ * zbudpage.  Since this is a two-phase process (due to tmem locking),
+ * this field locks the zbudpage against eviction when a zbud match
+ * or creation is in process.  Since this addition process may occur
+ * in parallel for two zbuds in one zbudpage, the field is a counter
+ * that must not exceed two.
+ */
+struct zbudpage {
+	union {
+		struct page page;
+		struct {
+			unsigned long space_for_flags;
+			struct {
+				unsigned zbud0_size:12;
+				unsigned zbud1_size:12;
+				unsigned unevictable:2;
+			};
+			struct list_head budlist;
+			struct list_head lru;
+		};
+	};
+};
+
+struct zbudref {
+	union {
+		struct zbudpage *zbudpage;
+		unsigned long zbudref;
+	};
+};
+
+#define CHUNK_SHIFT	6
+#define CHUNK_SIZE	(1 << CHUNK_SHIFT)
+#define CHUNK_MASK	(~(CHUNK_SIZE-1))
+#define NCHUNKS		(PAGE_SIZE >> CHUNK_SHIFT)
+#define MAX_CHUNK	(NCHUNKS-1)
+
+/*
+ * The following functions deal with the difference between struct
+ * page and struct zbudpage.  Note the hack of using the pageflags
+ * from struct page; this is to avoid duplicating all the complex
+ * pageflag macros.
+ */
+static inline void zbudpage_spin_lock(struct zbudpage *zbudpage)
+{
+	struct page *page = (struct page *)zbudpage;
+
+	while (unlikely(test_and_set_bit_lock(PG_locked, &page->flags))) {
+		do {
+			cpu_relax();
+		} while (test_bit(PG_locked, &page->flags));
+	}
+}
+
+static inline void zbudpage_spin_unlock(struct zbudpage *zbudpage)
+{
+	struct page *page = (struct page *)zbudpage;
+
+	clear_bit(PG_locked, &page->flags);
+}
+
+static inline int zbudpage_spin_trylock(struct zbudpage *zbudpage)
+{
+	return trylock_page((struct page *)zbudpage);
+}
+
+static inline int zbudpage_is_locked(struct zbudpage *zbudpage)
+{
+	return PageLocked((struct page *)zbudpage);
+}
+
+static inline void *kmap_zbudpage_atomic(struct zbudpage *zbudpage)
+{
+	return kmap_atomic((struct page *)zbudpage);
+}
+
+/*
+ * A dying zbudpage is an ephemeral page in the process of being evicted.
+ * Any data contained in the zbudpage is invalid and we are just waiting for
+ * the tmem pampds to be invalidated before freeing the page
+ */
+static inline int zbudpage_is_dying(struct zbudpage *zbudpage)
+{
+	struct page *page = (struct page *)zbudpage;
+
+	return test_bit(PG_reclaim, &page->flags);
+}
+
+static inline void zbudpage_set_dying(struct zbudpage *zbudpage)
+{
+	struct page *page = (struct page *)zbudpage;
+
+	set_bit(PG_reclaim, &page->flags);
+}
+
+static inline void zbudpage_clear_dying(struct zbudpage *zbudpage)
+{
+	struct page *page = (struct page *)zbudpage;
+
+	clear_bit(PG_reclaim, &page->flags);
+}
+
+/*
+ * A zombie zbudpage is a persistent page in the process of being evicted.
+ * The data contained in the zbudpage is valid and we are just waiting for
+ * the tmem pampds to be invalidated before freeing the page
+ */
+static inline int zbudpage_is_zombie(struct zbudpage *zbudpage)
+{
+	struct page *page = (struct page *)zbudpage;
+
+	return test_bit(PG_dirty, &page->flags);
+}
+
+static inline void zbudpage_set_zombie(struct zbudpage *zbudpage)
+{
+	struct page *page = (struct page *)zbudpage;
+
+	set_bit(PG_dirty, &page->flags);
+}
+
+static inline void zbudpage_clear_zombie(struct zbudpage *zbudpage)
+{
+	struct page *page = (struct page *)zbudpage;
+
+	clear_bit(PG_dirty, &page->flags);
+}
+
+static inline void kunmap_zbudpage_atomic(void *zbpg)
+{
+	kunmap_atomic(zbpg);
+}
+
+/*
+ * zbud "translation" and helper functions
+ */
+
+static inline struct zbudpage *zbudref_to_zbudpage(struct zbudref *zref)
+{
+	unsigned long zbud = (unsigned long)zref;
+	zbud &= ~1UL;
+	return (struct zbudpage *)zbud;
+}
+
+static inline struct zbudref *zbudpage_to_zbudref(struct zbudpage *zbudpage,
+							unsigned budnum)
+{
+	unsigned long zbud = (unsigned long)zbudpage;
+	BUG_ON(budnum > 1);
+	zbud |= budnum;
+	return (struct zbudref *)zbud;
+}
+
+static inline int zbudref_budnum(struct zbudref *zbudref)
+{
+	unsigned long zbud = (unsigned long)zbudref;
+	return zbud & 1UL;
+}
+
+static inline unsigned zbud_max_size(void)
+{
+	return MAX_CHUNK << CHUNK_SHIFT;
+}
+
+static inline unsigned zbud_size_to_chunks(unsigned size)
+{
+	BUG_ON(size == 0 || size > zbud_max_size());
+	return (size + CHUNK_SIZE - 1) >> CHUNK_SHIFT;
+}
+
+/* can only be used between kmap_zbudpage_atomic/kunmap_zbudpage_atomic! */
+static inline char *zbud_data(void *zbpg,
+			unsigned budnum, unsigned size)
+{
+	char *p;
+
+	BUG_ON(size == 0 || size > zbud_max_size());
+	p = (char *)zbpg;
+	if (budnum == 1)
+		p += PAGE_SIZE - ((size + CHUNK_SIZE - 1) & CHUNK_MASK);
+	return p;
+}
+
+/*
+ * These are all informative and exposed through debugfs... except for
+ * the arrays... anyone know how to do that?  To avoid confusion for
+ * debugfs viewers, some of these should also be atomic_long_t, but
+ * I don't know how to expose atomics via debugfs either...
+ */
+static unsigned long zbud_eph_pageframes;
+static unsigned long zbud_pers_pageframes;
+static unsigned long zbud_eph_zpages;
+static unsigned long zbud_pers_zpages;
+static u64 zbud_eph_zbytes;
+static u64 zbud_pers_zbytes;
+static unsigned long zbud_eph_evicted_pageframes;
+static unsigned long zbud_pers_evicted_pageframes;
+static unsigned long zbud_eph_cumul_zpages;
+static unsigned long zbud_pers_cumul_zpages;
+static u64 zbud_eph_cumul_zbytes;
+static u64 zbud_pers_cumul_zbytes;
+static unsigned long zbud_eph_cumul_chunk_counts[NCHUNKS];
+static unsigned long zbud_pers_cumul_chunk_counts[NCHUNKS];
+static unsigned long zbud_eph_buddied_count;
+static unsigned long zbud_pers_buddied_count;
+static unsigned long zbud_eph_unbuddied_count;
+static unsigned long zbud_pers_unbuddied_count;
+static unsigned long zbud_eph_zombie_count;
+static unsigned long zbud_pers_zombie_count;
+static atomic_t zbud_eph_zombie_atomic;
+static atomic_t zbud_pers_zombie_atomic;
+
+#ifdef CONFIG_DEBUG_FS
+#include <linux/debugfs.h>
+#define	zdfs	debugfs_create_size_t
+#define	zdfs64	debugfs_create_u64
+static int zbud_debugfs_init(void)
+{
+	struct dentry *root = debugfs_create_dir("zbud", NULL);
+	if (root == NULL)
+		return -ENXIO;
+
+	/*
+	 * would be nice to dump the sizes of the unbuddied
+	 * arrays, like was done with sysfs, but it doesn't
+	 * look like debugfs is flexible enough to do that
+	 */
+	zdfs64("eph_zbytes", S_IRUGO, root, &zbud_eph_zbytes);
+	zdfs64("eph_cumul_zbytes", S_IRUGO, root, &zbud_eph_cumul_zbytes);
+	zdfs64("pers_zbytes", S_IRUGO, root, &zbud_pers_zbytes);
+	zdfs64("pers_cumul_zbytes", S_IRUGO, root, &zbud_pers_cumul_zbytes);
+	zdfs("eph_cumul_zpages", S_IRUGO, root, &zbud_eph_cumul_zpages);
+	zdfs("eph_evicted_pageframes", S_IRUGO, root,
+				&zbud_eph_evicted_pageframes);
+	zdfs("eph_zpages", S_IRUGO, root, &zbud_eph_zpages);
+	zdfs("eph_pageframes", S_IRUGO, root, &zbud_eph_pageframes);
+	zdfs("eph_buddied_count", S_IRUGO, root, &zbud_eph_buddied_count);
+	zdfs("eph_unbuddied_count", S_IRUGO, root, &zbud_eph_unbuddied_count);
+	zdfs("pers_cumul_zpages", S_IRUGO, root, &zbud_pers_cumul_zpages);
+	zdfs("pers_evicted_pageframes", S_IRUGO, root,
+				&zbud_pers_evicted_pageframes);
+	zdfs("pers_zpages", S_IRUGO, root, &zbud_pers_zpages);
+	zdfs("pers_pageframes", S_IRUGO, root, &zbud_pers_pageframes);
+	zdfs("pers_buddied_count", S_IRUGO, root, &zbud_pers_buddied_count);
+	zdfs("pers_unbuddied_count", S_IRUGO, root, &zbud_pers_unbuddied_count);
+	zdfs("pers_zombie_count", S_IRUGO, root, &zbud_pers_zombie_count);
+	return 0;
+}
+#undef	zdfs
+#undef	zdfs64
+#endif
+
+/* protects the buddied list and all unbuddied lists */
+static DEFINE_SPINLOCK(zbud_eph_lists_lock);
+static DEFINE_SPINLOCK(zbud_pers_lists_lock);
+
+struct zbud_unbuddied {
+	struct list_head list;
+	unsigned count;
+};
+
+/* list N contains pages with N chunks USED and NCHUNKS-N unused */
+/* element 0 is never used but optimizing that isn't worth it */
+static struct zbud_unbuddied zbud_eph_unbuddied[NCHUNKS];
+static struct zbud_unbuddied zbud_pers_unbuddied[NCHUNKS];
+static LIST_HEAD(zbud_eph_lru_list);
+static LIST_HEAD(zbud_pers_lru_list);
+static LIST_HEAD(zbud_eph_buddied_list);
+static LIST_HEAD(zbud_pers_buddied_list);
+static LIST_HEAD(zbud_eph_zombie_list);
+static LIST_HEAD(zbud_pers_zombie_list);
+
+/*
+ * Given a struct page, transform it to a zbudpage so that it can be
+ * used by zbud and initialize fields as necessary.
+ */
+static inline struct zbudpage *zbud_init_zbudpage(struct page *page, bool eph)
+{
+	struct zbudpage *zbudpage = (struct zbudpage *)page;
+
+	BUG_ON(page == NULL);
+	INIT_LIST_HEAD(&zbudpage->budlist);
+	INIT_LIST_HEAD(&zbudpage->lru);
+	zbudpage->zbud0_size = 0;
+	zbudpage->zbud1_size = 0;
+	zbudpage->unevictable = 0;
+	if (eph)
+		zbud_eph_pageframes++;
+	else
+		zbud_pers_pageframes++;
+	return zbudpage;
+}
+
+/* "Transform" a zbudpage back to a struct page suitable to free. */
+static inline struct page *zbud_unuse_zbudpage(struct zbudpage *zbudpage,
+								bool eph)
+{
+	struct page *page = (struct page *)zbudpage;
+
+	BUG_ON(!list_empty(&zbudpage->budlist));
+	BUG_ON(!list_empty(&zbudpage->lru));
+	BUG_ON(zbudpage->zbud0_size != 0);
+	BUG_ON(zbudpage->zbud1_size != 0);
+	BUG_ON(!PageLocked(page));
+	BUG_ON(zbudpage->unevictable != 0);
+	BUG_ON(zbudpage_is_dying(zbudpage));
+	BUG_ON(zbudpage_is_zombie(zbudpage));
+	if (eph)
+		zbud_eph_pageframes--;
+	else
+		zbud_pers_pageframes--;
+	zbudpage_spin_unlock(zbudpage);
+	reset_page_mapcount(page);
+	init_page_count(page);
+	page->index = 0;
+	return page;
+}
+
+/* Mark a zbud as unused and do accounting */
+static inline void zbud_unuse_zbud(struct zbudpage *zbudpage,
+					int budnum, bool eph)
+{
+	unsigned size;
+
+	BUG_ON(!zbudpage_is_locked(zbudpage));
+	if (budnum == 0) {
+		size = zbudpage->zbud0_size;
+		zbudpage->zbud0_size = 0;
+	} else {
+		size = zbudpage->zbud1_size;
+		zbudpage->zbud1_size = 0;
+	}
+	if (eph) {
+		zbud_eph_zbytes -= size;
+		zbud_eph_zpages--;
+	} else {
+		zbud_pers_zbytes -= size;
+		zbud_pers_zpages--;
+	}
+}
+
+/*
+ * Given a zbudpage/budnum/size, a tmem handle, and a kmapped pointer
+ * to some data, set up the zbud appropriately including data copying
+ * and accounting.  Note that if cdata is NULL, the data copying is
+ * skipped.  (This is useful for lazy writes such as for RAMster.)
+ */
+static void zbud_init_zbud(struct zbudpage *zbudpage, struct tmem_handle *th,
+				bool eph, void *cdata,
+				unsigned budnum, unsigned size)
+{
+	char *to;
+	void *zbpg;
+	struct tmem_handle *to_th;
+	unsigned nchunks = zbud_size_to_chunks(size);
+
+	BUG_ON(!zbudpage_is_locked(zbudpage));
+	zbpg = kmap_zbudpage_atomic(zbudpage);
+	to = zbud_data(zbpg, budnum, size);
+	to_th = (struct tmem_handle *)to;
+	to_th->index = th->index;
+	to_th->oid = th->oid;
+	to_th->pool_id = th->pool_id;
+	to_th->client_id = th->client_id;
+	to += sizeof(struct tmem_handle);
+	if (cdata != NULL)
+		memcpy(to, cdata, size - sizeof(struct tmem_handle));
+	kunmap_zbudpage_atomic(zbpg);
+	if (budnum == 0)
+		zbudpage->zbud0_size = size;
+	else
+		zbudpage->zbud1_size = size;
+	if (eph) {
+		zbud_eph_cumul_chunk_counts[nchunks]++;
+		zbud_eph_zpages++;
+		zbud_eph_cumul_zpages++;
+		zbud_eph_zbytes += size;
+		zbud_eph_cumul_zbytes += size;
+	} else {
+		zbud_pers_cumul_chunk_counts[nchunks]++;
+		zbud_pers_zpages++;
+		zbud_pers_cumul_zpages++;
+		zbud_pers_zbytes += size;
+		zbud_pers_cumul_zbytes += size;
+	}
+}
+
+/*
+ * Given a locked dying zbudpage, read out the tmem handles from the data,
+ * unlock the page, then use the handles to tell tmem to flush out its
+ * references
+ */
+static void zbud_evict_tmem(struct zbudpage *zbudpage)
+{
+	int i, j;
+	uint32_t pool_id[2], client_id[2];
+	uint32_t index[2];
+	struct tmem_oid oid[2];
+	struct tmem_pool *pool;
+	void *zbpg;
+	struct tmem_handle *th;
+	unsigned size;
+
+	/* read out the tmem handles from the data and set aside */
+	zbpg = kmap_zbudpage_atomic(zbudpage);
+	for (i = 0, j = 0; i < 2; i++) {
+		size = (i == 0) ? zbudpage->zbud0_size : zbudpage->zbud1_size;
+		if (size) {
+			th = (struct tmem_handle *)zbud_data(zbpg, i, size);
+			client_id[j] = th->client_id;
+			pool_id[j] = th->pool_id;
+			oid[j] = th->oid;
+			index[j] = th->index;
+			j++;
+			zbud_unuse_zbud(zbudpage, i, true);
+		}
+	}
+	kunmap_zbudpage_atomic(zbpg);
+	zbudpage_spin_unlock(zbudpage);
+	/* zbudpage is now an unlocked dying... tell tmem to flush pointers */
+	for (i = 0; i < j; i++) {
+		pool = zcache_get_pool_by_id(client_id[i], pool_id[i]);
+		if (pool != NULL) {
+			tmem_flush_page(pool, &oid[i], index[i]);
+			zcache_put_pool(pool);
+		}
+	}
+}
+
+/*
+ * Externally callable zbud handling routines.
+ */
+
+/*
+ * Return the maximum size compressed page that can be stored (secretly
+ * setting aside space for the tmem handle.
+ */
+unsigned int zbud_max_buddy_size(void)
+{
+	return zbud_max_size() - sizeof(struct tmem_handle);
+}
+
+/*
+ * Given a zbud reference, free the corresponding zbud from all lists,
+ * mark it as unused, do accounting, and if the freeing of the zbud
+ * frees up an entire pageframe, return it to the caller (else NULL).
+ */
+struct page *zbud_free_and_delist(struct zbudref *zref, bool eph,
+				  unsigned int *zsize, unsigned int *zpages)
+{
+	unsigned long budnum = zbudref_budnum(zref);
+	struct zbudpage *zbudpage = zbudref_to_zbudpage(zref);
+	struct page *page = NULL;
+	unsigned chunks, bud_size, other_bud_size;
+	spinlock_t *lists_lock =
+		eph ? &zbud_eph_lists_lock : &zbud_pers_lists_lock;
+	struct zbud_unbuddied *unbud =
+		eph ? zbud_eph_unbuddied : zbud_pers_unbuddied;
+
+
+	spin_lock(lists_lock);
+	zbudpage_spin_lock(zbudpage);
+	if (zbudpage_is_dying(zbudpage)) {
+		/* ignore dying zbudpage... see zbud_evict_pageframe_lru() */
+		zbudpage_spin_unlock(zbudpage);
+		spin_unlock(lists_lock);
+		*zpages = 0;
+		*zsize = 0;
+		goto out;
+	}
+	if (budnum == 0) {
+		bud_size = zbudpage->zbud0_size;
+		other_bud_size = zbudpage->zbud1_size;
+	} else {
+		bud_size = zbudpage->zbud1_size;
+		other_bud_size = zbudpage->zbud0_size;
+	}
+	*zsize = bud_size - sizeof(struct tmem_handle);
+	*zpages = 1;
+	zbud_unuse_zbud(zbudpage, budnum, eph);
+	if (other_bud_size == 0) { /* was unbuddied: unlist and free */
+		chunks = zbud_size_to_chunks(bud_size) ;
+		if (zbudpage_is_zombie(zbudpage)) {
+			if (eph)
+				zbud_pers_zombie_count =
+				  atomic_dec_return(&zbud_eph_zombie_atomic);
+			else
+				zbud_pers_zombie_count =
+				  atomic_dec_return(&zbud_pers_zombie_atomic);
+			zbudpage_clear_zombie(zbudpage);
+		} else {
+			BUG_ON(list_empty(&unbud[chunks].list));
+			list_del_init(&zbudpage->budlist);
+			unbud[chunks].count--;
+		}
+		list_del_init(&zbudpage->lru);
+		spin_unlock(lists_lock);
+		if (eph)
+			zbud_eph_unbuddied_count--;
+		else
+			zbud_pers_unbuddied_count--;
+		page = zbud_unuse_zbudpage(zbudpage, eph);
+	} else { /* was buddied: move remaining buddy to unbuddied list */
+		chunks = zbud_size_to_chunks(other_bud_size) ;
+		if (!zbudpage_is_zombie(zbudpage)) {
+			list_del_init(&zbudpage->budlist);
+			list_add_tail(&zbudpage->budlist, &unbud[chunks].list);
+			unbud[chunks].count++;
+		}
+		if (eph) {
+			zbud_eph_buddied_count--;
+			zbud_eph_unbuddied_count++;
+		} else {
+			zbud_pers_unbuddied_count++;
+			zbud_pers_buddied_count--;
+		}
+		/* don't mess with lru, no need to move it */
+		zbudpage_spin_unlock(zbudpage);
+		spin_unlock(lists_lock);
+	}
+out:
+	return page;
+}
+
+/*
+ * Given a tmem handle, and a kmapped pointer to compressed data of
+ * the given size, try to find an unbuddied zbudpage in which to
+ * create a zbud. If found, put it there, mark the zbudpage unevictable,
+ * and return a zbudref to it.  Else return NULL.
+ */
+struct zbudref *zbud_match_prep(struct tmem_handle *th, bool eph,
+				void *cdata, unsigned size)
+{
+	struct zbudpage *zbudpage = NULL, *zbudpage2;
+	unsigned long budnum = 0UL;
+	unsigned nchunks;
+	int i, found_good_buddy = 0;
+	spinlock_t *lists_lock =
+		eph ? &zbud_eph_lists_lock : &zbud_pers_lists_lock;
+	struct zbud_unbuddied *unbud =
+		eph ? zbud_eph_unbuddied : zbud_pers_unbuddied;
+
+	size += sizeof(struct tmem_handle);
+	nchunks = zbud_size_to_chunks(size);
+	for (i = MAX_CHUNK - nchunks + 1; i > 0; i--) {
+		spin_lock(lists_lock);
+		if (!list_empty(&unbud[i].list)) {
+			list_for_each_entry_safe(zbudpage, zbudpage2,
+				    &unbud[i].list, budlist) {
+				if (zbudpage_spin_trylock(zbudpage)) {
+					found_good_buddy = i;
+					goto found_unbuddied;
+				}
+			}
+		}
+		spin_unlock(lists_lock);
+	}
+	zbudpage = NULL;
+	goto out;
+
+found_unbuddied:
+	BUG_ON(!zbudpage_is_locked(zbudpage));
+	BUG_ON(!((zbudpage->zbud0_size == 0) ^ (zbudpage->zbud1_size == 0)));
+	if (zbudpage->zbud0_size == 0)
+		budnum = 0UL;
+	else if (zbudpage->zbud1_size == 0)
+		budnum = 1UL;
+	list_del_init(&zbudpage->budlist);
+	if (eph) {
+		list_add_tail(&zbudpage->budlist, &zbud_eph_buddied_list);
+		unbud[found_good_buddy].count--;
+		zbud_eph_unbuddied_count--;
+		zbud_eph_buddied_count++;
+		/* "promote" raw zbudpage to most-recently-used */
+		list_del_init(&zbudpage->lru);
+		list_add_tail(&zbudpage->lru, &zbud_eph_lru_list);
+	} else {
+		list_add_tail(&zbudpage->budlist, &zbud_pers_buddied_list);
+		unbud[found_good_buddy].count--;
+		zbud_pers_unbuddied_count--;
+		zbud_pers_buddied_count++;
+		/* "promote" raw zbudpage to most-recently-used */
+		list_del_init(&zbudpage->lru);
+		list_add_tail(&zbudpage->lru, &zbud_pers_lru_list);
+	}
+	zbud_init_zbud(zbudpage, th, eph, cdata, budnum, size);
+	zbudpage->unevictable++;
+	BUG_ON(zbudpage->unevictable == 3);
+	zbudpage_spin_unlock(zbudpage);
+	spin_unlock(lists_lock);
+out:
+	return zbudpage_to_zbudref(zbudpage, budnum);
+
+}
+
+/*
+ * Given a tmem handle, and a kmapped pointer to compressed data of
+ * the given size, and a newly allocated struct page, create an unevictable
+ * zbud in that new page and return a zbudref to it.
+ */
+struct zbudref *zbud_create_prep(struct tmem_handle *th, bool eph,
+					void *cdata, unsigned size,
+					struct page *newpage)
+{
+	struct zbudpage *zbudpage;
+	unsigned long budnum = 0;
+	unsigned nchunks;
+	spinlock_t *lists_lock =
+		eph ? &zbud_eph_lists_lock : &zbud_pers_lists_lock;
+	struct zbud_unbuddied *unbud =
+		eph ? zbud_eph_unbuddied : zbud_pers_unbuddied;
+
+#if 0
+	/* this may be worth it later to support decompress-in-place? */
+	static unsigned long counter;
+	budnum = counter++ & 1;	/* alternate using zbud0 and zbud1 */
+#endif
+
+	if (size  > zbud_max_buddy_size())
+		return NULL;
+	if (newpage == NULL)
+		return NULL;
+
+	size += sizeof(struct tmem_handle);
+	nchunks = zbud_size_to_chunks(size) ;
+	spin_lock(lists_lock);
+	zbudpage = zbud_init_zbudpage(newpage, eph);
+	zbudpage_spin_lock(zbudpage);
+	list_add_tail(&zbudpage->budlist, &unbud[nchunks].list);
+	if (eph) {
+		list_add_tail(&zbudpage->lru, &zbud_eph_lru_list);
+		zbud_eph_unbuddied_count++;
+	} else {
+		list_add_tail(&zbudpage->lru, &zbud_pers_lru_list);
+		zbud_pers_unbuddied_count++;
+	}
+	unbud[nchunks].count++;
+	zbud_init_zbud(zbudpage, th, eph, cdata, budnum, size);
+	zbudpage->unevictable++;
+	BUG_ON(zbudpage->unevictable == 3);
+	zbudpage_spin_unlock(zbudpage);
+	spin_unlock(lists_lock);
+	return zbudpage_to_zbudref(zbudpage, budnum);
+}
+
+/*
+ * Finish creation of a zbud by, assuming another zbud isn't being created
+ * in parallel, marking it evictable.
+ */
+void zbud_create_finish(struct zbudref *zref, bool eph)
+{
+	struct zbudpage *zbudpage = zbudref_to_zbudpage(zref);
+	spinlock_t *lists_lock =
+		eph ? &zbud_eph_lists_lock : &zbud_pers_lists_lock;
+
+	spin_lock(lists_lock);
+	zbudpage_spin_lock(zbudpage);
+	BUG_ON(zbudpage_is_dying(zbudpage));
+	zbudpage->unevictable--;
+	BUG_ON((int)zbudpage->unevictable < 0);
+	zbudpage_spin_unlock(zbudpage);
+	spin_unlock(lists_lock);
+}
+
+/*
+ * Given a zbudref and a struct page, decompress the data from
+ * the zbud into the physical page represented by the struct page
+ * by upcalling to zcache_decompress
+ */
+int zbud_decompress(struct page *data_page, struct zbudref *zref, bool eph,
+			void (*decompress)(char *, unsigned int, char *))
+{
+	struct zbudpage *zbudpage = zbudref_to_zbudpage(zref);
+	unsigned long budnum = zbudref_budnum(zref);
+	void *zbpg;
+	char *to_va, *from_va;
+	unsigned size;
+	int ret = -1;
+	spinlock_t *lists_lock =
+		eph ? &zbud_eph_lists_lock : &zbud_pers_lists_lock;
+
+	spin_lock(lists_lock);
+	zbudpage_spin_lock(zbudpage);
+	if (zbudpage_is_dying(zbudpage)) {
+		/* ignore dying zbudpage... see zbud_evict_pageframe_lru() */
+		goto out;
+	}
+	zbpg = kmap_zbudpage_atomic(zbudpage);
+	to_va = kmap_atomic(data_page);
+	if (budnum == 0)
+		size = zbudpage->zbud0_size;
+	else
+		size = zbudpage->zbud1_size;
+	BUG_ON(size == 0 || size > zbud_max_size());
+	from_va = zbud_data(zbpg, budnum, size);
+	from_va += sizeof(struct tmem_handle);
+	size -= sizeof(struct tmem_handle);
+	decompress(from_va, size, to_va);
+	kunmap_atomic(to_va);
+	kunmap_zbudpage_atomic(zbpg);
+	ret = 0;
+out:
+	zbudpage_spin_unlock(zbudpage);
+	spin_unlock(lists_lock);
+	return ret;
+}
+
+/*
+ * Given a zbudref and a kernel pointer, copy the data from
+ * the zbud to the kernel pointer.
+ */
+int zbud_copy_from_zbud(char *to_va, struct zbudref *zref,
+				size_t *sizep, bool eph)
+{
+	struct zbudpage *zbudpage = zbudref_to_zbudpage(zref);
+	unsigned long budnum = zbudref_budnum(zref);
+	void *zbpg;
+	char *from_va;
+	unsigned size;
+	int ret = -1;
+	spinlock_t *lists_lock =
+		eph ? &zbud_eph_lists_lock : &zbud_pers_lists_lock;
+
+	spin_lock(lists_lock);
+	zbudpage_spin_lock(zbudpage);
+	if (zbudpage_is_dying(zbudpage)) {
+		/* ignore dying zbudpage... see zbud_evict_pageframe_lru() */
+		goto out;
+	}
+	zbpg = kmap_zbudpage_atomic(zbudpage);
+	if (budnum == 0)
+		size = zbudpage->zbud0_size;
+	else
+		size = zbudpage->zbud1_size;
+	BUG_ON(size == 0 || size > zbud_max_size());
+	from_va = zbud_data(zbpg, budnum, size);
+	from_va += sizeof(struct tmem_handle);
+	size -= sizeof(struct tmem_handle);
+	*sizep = size;
+	memcpy(to_va, from_va, size);
+
+	kunmap_zbudpage_atomic(zbpg);
+	ret = 0;
+out:
+	zbudpage_spin_unlock(zbudpage);
+	spin_unlock(lists_lock);
+	return ret;
+}
+
+/*
+ * Given a zbudref and a kernel pointer, copy the data from
+ * the kernel pointer to the zbud.
+ */
+int zbud_copy_to_zbud(struct zbudref *zref, char *from_va, bool eph)
+{
+	struct zbudpage *zbudpage = zbudref_to_zbudpage(zref);
+	unsigned long budnum = zbudref_budnum(zref);
+	void *zbpg;
+	char *to_va;
+	unsigned size;
+	int ret = -1;
+	spinlock_t *lists_lock =
+		eph ? &zbud_eph_lists_lock : &zbud_pers_lists_lock;
+
+	spin_lock(lists_lock);
+	zbudpage_spin_lock(zbudpage);
+	if (zbudpage_is_dying(zbudpage)) {
+		/* ignore dying zbudpage... see zbud_evict_pageframe_lru() */
+		goto out;
+	}
+	zbpg = kmap_zbudpage_atomic(zbudpage);
+	if (budnum == 0)
+		size = zbudpage->zbud0_size;
+	else
+		size = zbudpage->zbud1_size;
+	BUG_ON(size == 0 || size > zbud_max_size());
+	to_va = zbud_data(zbpg, budnum, size);
+	to_va += sizeof(struct tmem_handle);
+	size -= sizeof(struct tmem_handle);
+	memcpy(to_va, from_va, size);
+
+	kunmap_zbudpage_atomic(zbpg);
+	ret = 0;
+out:
+	zbudpage_spin_unlock(zbudpage);
+	spin_unlock(lists_lock);
+	return ret;
+}
+
+/*
+ * Choose an ephemeral LRU zbudpage that is evictable (not locked), ensure
+ * there are no references to it remaining, and return the now unused
+ * (and re-init'ed) struct page and the total amount of compressed
+ * data that was evicted.
+ */
+struct page *zbud_evict_pageframe_lru(unsigned int *zsize, unsigned int *zpages)
+{
+	struct zbudpage *zbudpage = NULL, *zbudpage2;
+	struct zbud_unbuddied *unbud = zbud_eph_unbuddied;
+	struct page *page = NULL;
+	bool irqs_disabled = irqs_disabled();
+
+	/*
+	 * Since this can be called indirectly from cleancache_put, which
+	 * has interrupts disabled, as well as frontswap_put, which does not,
+	 * we need to be able to handle both cases, even though it is ugly.
+	 */
+	if (irqs_disabled)
+		spin_lock(&zbud_eph_lists_lock);
+	else
+		spin_lock_bh(&zbud_eph_lists_lock);
+	*zsize = 0;
+	if (list_empty(&zbud_eph_lru_list))
+		goto unlock_out;
+	list_for_each_entry_safe(zbudpage, zbudpage2, &zbud_eph_lru_list, lru) {
+		/* skip a locked zbudpage */
+		if (unlikely(!zbudpage_spin_trylock(zbudpage)))
+			continue;
+		/* skip an unevictable zbudpage */
+		if (unlikely(zbudpage->unevictable != 0)) {
+			zbudpage_spin_unlock(zbudpage);
+			continue;
+		}
+		/* got a locked evictable page */
+		goto evict_page;
+
+	}
+unlock_out:
+	/* no unlocked evictable pages, give up */
+	if (irqs_disabled)
+		spin_unlock(&zbud_eph_lists_lock);
+	else
+		spin_unlock_bh(&zbud_eph_lists_lock);
+	goto out;
+
+evict_page:
+	list_del_init(&zbudpage->budlist);
+	list_del_init(&zbudpage->lru);
+	zbudpage_set_dying(zbudpage);
+	/*
+	 * the zbudpage is now "dying" and attempts to read, write,
+	 * or delete data from it will be ignored
+	 */
+	if (zbudpage->zbud0_size != 0 && zbudpage->zbud1_size !=  0) {
+		*zsize = zbudpage->zbud0_size + zbudpage->zbud1_size -
+				(2 * sizeof(struct tmem_handle));
+		*zpages = 2;
+	} else if (zbudpage->zbud0_size != 0) {
+		unbud[zbud_size_to_chunks(zbudpage->zbud0_size)].count--;
+		*zsize = zbudpage->zbud0_size - sizeof(struct tmem_handle);
+		*zpages = 1;
+	} else if (zbudpage->zbud1_size != 0) {
+		unbud[zbud_size_to_chunks(zbudpage->zbud1_size)].count--;
+		*zsize = zbudpage->zbud1_size - sizeof(struct tmem_handle);
+		*zpages = 1;
+	} else {
+		BUG();
+	}
+	spin_unlock(&zbud_eph_lists_lock);
+	zbud_eph_evicted_pageframes++;
+	if (*zpages == 1)
+		zbud_eph_unbuddied_count--;
+	else
+		zbud_eph_buddied_count--;
+	zbud_evict_tmem(zbudpage);
+	zbudpage_spin_lock(zbudpage);
+	zbudpage_clear_dying(zbudpage);
+	page = zbud_unuse_zbudpage(zbudpage, true);
+	if (!irqs_disabled)
+		local_bh_enable();
+out:
+	return page;
+}
+
+/*
+ * Choose a persistent LRU zbudpage that is evictable (not locked), zombify it,
+ * read the tmem_handle(s) out of it into the passed array, and return the
+ * number of zbuds.  Caller must perform necessary tmem functions and,
+ * indirectly, zbud functions to fetch any valid data and cause the
+ * now-zombified zbudpage to eventually be freed.  We track the zombified
+ * zbudpage count so it is possible to observe if there is a leak.
+ FIXME: describe (ramster) case where data pointers are passed in for memcpy
+ */
+unsigned int zbud_make_zombie_lru(struct tmem_handle *th, unsigned char **data,
+					unsigned int *zsize, bool eph)
+{
+	struct zbudpage *zbudpage = NULL, *zbudpag2;
+	struct tmem_handle *thfrom;
+	char *from_va;
+	void *zbpg;
+	unsigned size;
+	int ret = 0, i;
+	spinlock_t *lists_lock =
+		eph ? &zbud_eph_lists_lock : &zbud_pers_lists_lock;
+	struct list_head *lru_list =
+		eph ? &zbud_eph_lru_list : &zbud_pers_lru_list;
+
+	spin_lock_bh(lists_lock);
+	if (list_empty(lru_list))
+		goto out;
+	list_for_each_entry_safe(zbudpage, zbudpag2, lru_list, lru) {
+		/* skip a locked zbudpage */
+		if (unlikely(!zbudpage_spin_trylock(zbudpage)))
+			continue;
+		/* skip an unevictable zbudpage */
+		if (unlikely(zbudpage->unevictable != 0)) {
+			zbudpage_spin_unlock(zbudpage);
+			continue;
+		}
+		/* got a locked evictable page */
+		goto zombify_page;
+	}
+	/* no unlocked evictable pages, give up */
+	goto out;
+
+zombify_page:
+	/* got an unlocked evictable page, zombify it */
+	list_del_init(&zbudpage->budlist);
+	zbudpage_set_zombie(zbudpage);
+	/* FIXME what accounting do I need to do here? */
+	list_del_init(&zbudpage->lru);
+	if (eph) {
+		list_add_tail(&zbudpage->lru, &zbud_eph_zombie_list);
+		zbud_eph_zombie_count =
+				atomic_inc_return(&zbud_eph_zombie_atomic);
+	} else {
+		list_add_tail(&zbudpage->lru, &zbud_pers_zombie_list);
+		zbud_pers_zombie_count =
+				atomic_inc_return(&zbud_pers_zombie_atomic);
+	}
+	/* FIXME what accounting do I need to do here? */
+	zbpg = kmap_zbudpage_atomic(zbudpage);
+	for (i = 0; i < 2; i++) {
+		size = (i == 0) ? zbudpage->zbud0_size : zbudpage->zbud1_size;
+		if (size) {
+			from_va = zbud_data(zbpg, i, size);
+			thfrom = (struct tmem_handle *)from_va;
+			from_va += sizeof(struct tmem_handle);
+			size -= sizeof(struct tmem_handle);
+			if (th != NULL)
+				th[ret] = *thfrom;
+			if (data != NULL)
+				memcpy(data[ret], from_va, size);
+			if (zsize != NULL)
+				*zsize++ = size;
+			ret++;
+		}
+	}
+	kunmap_zbudpage_atomic(zbpg);
+	zbudpage_spin_unlock(zbudpage);
+out:
+	spin_unlock_bh(lists_lock);
+	return ret;
+}
+
+void __init zbud_init(void)
+{
+	int i;
+
+#ifdef CONFIG_DEBUG_FS
+	zbud_debugfs_init();
+#endif
+	BUG_ON((sizeof(struct tmem_handle) * 2 > CHUNK_SIZE));
+	BUG_ON(sizeof(struct zbudpage) > sizeof(struct page));
+	for (i = 0; i < NCHUNKS; i++) {
+		INIT_LIST_HEAD(&zbud_eph_unbuddied[i].list);
+		INIT_LIST_HEAD(&zbud_pers_unbuddied[i].list);
+	}
+}
diff --git a/drivers/staging/zcache/zbud.h b/drivers/staging/zcache/zbud.h
new file mode 100644
index 0000000..891e8a7
--- /dev/null
+++ b/drivers/staging/zcache/zbud.h
@@ -0,0 +1,33 @@
+/*
+ * zbud.h
+ *
+ * Copyright (c) 2010-2012, Dan Magenheimer, Oracle Corp.
+ *
+ */
+
+#ifndef _ZBUD_H_
+#define _ZBUD_H_
+
+#include "tmem.h"
+
+struct zbudref;
+
+extern unsigned int zbud_max_buddy_size(void);
+extern struct zbudref *zbud_match_prep(struct tmem_handle *th, bool eph,
+						void *cdata, unsigned size);
+extern struct zbudref *zbud_create_prep(struct tmem_handle *th, bool eph,
+						void *cdata, unsigned size,
+						struct page *newpage);
+extern void zbud_create_finish(struct zbudref *, bool);
+extern int zbud_decompress(struct page *, struct zbudref *, bool,
+				void (*func)(char *, unsigned int, char *));
+extern int zbud_copy_from_zbud(char *, struct zbudref *, size_t *, bool);
+extern int zbud_copy_to_zbud(struct zbudref *, char *, bool);
+extern struct page *zbud_free_and_delist(struct zbudref *, bool eph,
+						unsigned int *, unsigned int *);
+extern struct page *zbud_evict_pageframe_lru(unsigned int *, unsigned int *);
+extern unsigned int zbud_make_zombie_lru(struct tmem_handle *, unsigned char **,
+						unsigned int *, bool);
+extern void zbud_init(void);
+
+#endif /* _ZBUD_H_ */
diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
new file mode 100644
index 0000000..24b3d4a
--- /dev/null
+++ b/drivers/staging/zcache/zcache-main.c
@@ -0,0 +1,1812 @@
+/*
+ * zcache.c
+ *
+ * Copyright (c) 2010-2012, Dan Magenheimer, Oracle Corp.
+ * Copyright (c) 2010,2011, Nitin Gupta
+ *
+ * Zcache provides an in-kernel "host implementation" for transcendent memory
+ * ("tmem") and, thus indirectly, for cleancache and frontswap.  Zcache uses
+ * lzo1x compression to improve density and an embedded allocator called
+ * "zbud" which "buddies" two compressed pages semi-optimally in each physical
+ * pageframe.  Zbud is integrally tied into tmem to allow pageframes to
+ * be "reclaimed" efficiently.
+ */
+
+#include <linux/module.h>
+#include <linux/cpu.h>
+#include <linux/highmem.h>
+#include <linux/list.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/types.h>
+#include <linux/atomic.h>
+#include <linux/math64.h>
+#include <linux/crypto.h>
+
+#include <linux/cleancache.h>
+#include <linux/frontswap.h>
+#include "tmem.h"
+#include "zcache.h"
+#include "zbud.h"
+#include "ramster.h"
+#ifdef CONFIG_RAMSTER
+static int ramster_enabled;
+#else
+#define ramster_enabled 0
+#endif
+
+#ifndef __PG_WAS_ACTIVE
+static inline bool PageWasActive(struct page *page)
+{
+	return true;
+}
+
+static inline void SetPageWasActive(struct page *page)
+{
+}
+#endif
+
+#ifdef FRONTSWAP_HAS_EXCLUSIVE_GETS
+static bool frontswap_has_exclusive_gets __read_mostly = true;
+#else
+static bool frontswap_has_exclusive_gets __read_mostly;
+static inline void frontswap_tmem_exclusive_gets(bool b)
+{
+}
+#endif
+
+static int zcache_enabled __read_mostly;
+static int disable_cleancache __read_mostly;
+static int disable_frontswap __read_mostly;
+static int disable_frontswap_ignore_nonactive __read_mostly;
+static int disable_cleancache_ignore_nonactive __read_mostly;
+static char *namestr __read_mostly = "zcache";
+
+#define ZCACHE_GFP_MASK \
+	(__GFP_FS | __GFP_NORETRY | __GFP_NOWARN | __GFP_NOMEMALLOC)
+
+MODULE_LICENSE("GPL");
+
+/* crypto API for zcache  */
+#define ZCACHE_COMP_NAME_SZ CRYPTO_MAX_ALG_NAME
+static char zcache_comp_name[ZCACHE_COMP_NAME_SZ] __read_mostly;
+static struct crypto_comp * __percpu *zcache_comp_pcpu_tfms __read_mostly;
+
+enum comp_op {
+	ZCACHE_COMPOP_COMPRESS,
+	ZCACHE_COMPOP_DECOMPRESS
+};
+
+static inline int zcache_comp_op(enum comp_op op,
+				const u8 *src, unsigned int slen,
+				u8 *dst, unsigned int *dlen)
+{
+	struct crypto_comp *tfm;
+	int ret = -1;
+
+	BUG_ON(!zcache_comp_pcpu_tfms);
+	tfm = *per_cpu_ptr(zcache_comp_pcpu_tfms, get_cpu());
+	BUG_ON(!tfm);
+	switch (op) {
+	case ZCACHE_COMPOP_COMPRESS:
+		ret = crypto_comp_compress(tfm, src, slen, dst, dlen);
+		break;
+	case ZCACHE_COMPOP_DECOMPRESS:
+		ret = crypto_comp_decompress(tfm, src, slen, dst, dlen);
+		break;
+	default:
+		ret = -EINVAL;
+	}
+	put_cpu();
+	return ret;
+}
+
+/*
+ * policy parameters
+ */
+
+/*
+ * byte count defining poor compression; pages with greater zsize will be
+ * rejected
+ */
+static unsigned int zbud_max_zsize __read_mostly = (PAGE_SIZE / 8) * 7;
+/*
+ * byte count defining poor *mean* compression; pages with greater zsize
+ * will be rejected until sufficient better-compressed pages are accepted
+ * driving the mean below this threshold
+ */
+static unsigned int zbud_max_mean_zsize __read_mostly = (PAGE_SIZE / 8) * 5;
+
+/*
+ * for now, used named slabs so can easily track usage; later can
+ * either just use kmalloc, or perhaps add a slab-like allocator
+ * to more carefully manage total memory utilization
+ */
+static struct kmem_cache *zcache_objnode_cache;
+static struct kmem_cache *zcache_obj_cache;
+
+static DEFINE_PER_CPU(struct zcache_preload, zcache_preloads) = { 0, };
+
+/* we try to keep these statistics SMP-consistent */
+static long zcache_obj_count;
+static atomic_t zcache_obj_atomic = ATOMIC_INIT(0);
+static long zcache_obj_count_max;
+static long zcache_objnode_count;
+static atomic_t zcache_objnode_atomic = ATOMIC_INIT(0);
+static long zcache_objnode_count_max;
+static u64 zcache_eph_zbytes;
+static atomic_long_t zcache_eph_zbytes_atomic = ATOMIC_INIT(0);
+static u64 zcache_eph_zbytes_max;
+static u64 zcache_pers_zbytes;
+static atomic_long_t zcache_pers_zbytes_atomic = ATOMIC_INIT(0);
+static u64 zcache_pers_zbytes_max;
+static long zcache_eph_pageframes;
+static atomic_t zcache_eph_pageframes_atomic = ATOMIC_INIT(0);
+static long zcache_eph_pageframes_max;
+static long zcache_pers_pageframes;
+static atomic_t zcache_pers_pageframes_atomic = ATOMIC_INIT(0);
+static long zcache_pers_pageframes_max;
+static long zcache_pageframes_alloced;
+static atomic_t zcache_pageframes_alloced_atomic = ATOMIC_INIT(0);
+static long zcache_pageframes_freed;
+static atomic_t zcache_pageframes_freed_atomic = ATOMIC_INIT(0);
+static long zcache_eph_zpages;
+static atomic_t zcache_eph_zpages_atomic = ATOMIC_INIT(0);
+static long zcache_eph_zpages_max;
+static long zcache_pers_zpages;
+static atomic_t zcache_pers_zpages_atomic = ATOMIC_INIT(0);
+static long zcache_pers_zpages_max;
+
+/* but for the rest of these, counting races are ok */
+static unsigned long zcache_flush_total;
+static unsigned long zcache_flush_found;
+static unsigned long zcache_flobj_total;
+static unsigned long zcache_flobj_found;
+static unsigned long zcache_failed_eph_puts;
+static unsigned long zcache_failed_pers_puts;
+static unsigned long zcache_failed_getfreepages;
+static unsigned long zcache_failed_alloc;
+static unsigned long zcache_put_to_flush;
+static unsigned long zcache_compress_poor;
+static unsigned long zcache_mean_compress_poor;
+static unsigned long zcache_eph_ate_tail;
+static unsigned long zcache_eph_ate_tail_failed;
+static unsigned long zcache_pers_ate_eph;
+static unsigned long zcache_pers_ate_eph_failed;
+static unsigned long zcache_evicted_eph_zpages;
+static unsigned long zcache_evicted_eph_pageframes;
+static unsigned long zcache_last_active_file_pageframes;
+static unsigned long zcache_last_inactive_file_pageframes;
+static unsigned long zcache_last_active_anon_pageframes;
+static unsigned long zcache_last_inactive_anon_pageframes;
+static unsigned long zcache_eph_nonactive_puts_ignored;
+static unsigned long zcache_pers_nonactive_puts_ignored;
+
+#ifdef CONFIG_DEBUG_FS
+#include <linux/debugfs.h>
+#define	zdfs	debugfs_create_size_t
+#define	zdfs64	debugfs_create_u64
+static int zcache_debugfs_init(void)
+{
+	struct dentry *root = debugfs_create_dir("zcache", NULL);
+	if (root == NULL)
+		return -ENXIO;
+
+	zdfs("obj_count", S_IRUGO, root, &zcache_obj_count);
+	zdfs("obj_count_max", S_IRUGO, root, &zcache_obj_count_max);
+	zdfs("objnode_count", S_IRUGO, root, &zcache_objnode_count);
+	zdfs("objnode_count_max", S_IRUGO, root, &zcache_objnode_count_max);
+	zdfs("flush_total", S_IRUGO, root, &zcache_flush_total);
+	zdfs("flush_found", S_IRUGO, root, &zcache_flush_found);
+	zdfs("flobj_total", S_IRUGO, root, &zcache_flobj_total);
+	zdfs("flobj_found", S_IRUGO, root, &zcache_flobj_found);
+	zdfs("failed_eph_puts", S_IRUGO, root, &zcache_failed_eph_puts);
+	zdfs("failed_pers_puts", S_IRUGO, root, &zcache_failed_pers_puts);
+	zdfs("failed_get_free_pages", S_IRUGO, root,
+				&zcache_failed_getfreepages);
+	zdfs("failed_alloc", S_IRUGO, root, &zcache_failed_alloc);
+	zdfs("put_to_flush", S_IRUGO, root, &zcache_put_to_flush);
+	zdfs("compress_poor", S_IRUGO, root, &zcache_compress_poor);
+	zdfs("mean_compress_poor", S_IRUGO, root, &zcache_mean_compress_poor);
+	zdfs("eph_ate_tail", S_IRUGO, root, &zcache_eph_ate_tail);
+	zdfs("eph_ate_tail_failed", S_IRUGO, root, &zcache_eph_ate_tail_failed);
+	zdfs("pers_ate_eph", S_IRUGO, root, &zcache_pers_ate_eph);
+	zdfs("pers_ate_eph_failed", S_IRUGO, root, &zcache_pers_ate_eph_failed);
+	zdfs("evicted_eph_zpages", S_IRUGO, root, &zcache_evicted_eph_zpages);
+	zdfs("evicted_eph_pageframes", S_IRUGO, root,
+				&zcache_evicted_eph_pageframes);
+	zdfs("eph_pageframes", S_IRUGO, root, &zcache_eph_pageframes);
+	zdfs("eph_pageframes_max", S_IRUGO, root, &zcache_eph_pageframes_max);
+	zdfs("pers_pageframes", S_IRUGO, root, &zcache_pers_pageframes);
+	zdfs("pers_pageframes_max", S_IRUGO, root, &zcache_pers_pageframes_max);
+	zdfs("eph_zpages", S_IRUGO, root, &zcache_eph_zpages);
+	zdfs("eph_zpages_max", S_IRUGO, root, &zcache_eph_zpages_max);
+	zdfs("pers_zpages", S_IRUGO, root, &zcache_pers_zpages);
+	zdfs("pers_zpages_max", S_IRUGO, root, &zcache_pers_zpages_max);
+	zdfs("last_active_file_pageframes", S_IRUGO, root,
+				&zcache_last_active_file_pageframes);
+	zdfs("last_inactive_file_pageframes", S_IRUGO, root,
+				&zcache_last_inactive_file_pageframes);
+	zdfs("last_active_anon_pageframes", S_IRUGO, root,
+				&zcache_last_active_anon_pageframes);
+	zdfs("last_inactive_anon_pageframes", S_IRUGO, root,
+				&zcache_last_inactive_anon_pageframes);
+	zdfs("eph_nonactive_puts_ignored", S_IRUGO, root,
+				&zcache_eph_nonactive_puts_ignored);
+	zdfs("pers_nonactive_puts_ignored", S_IRUGO, root,
+				&zcache_pers_nonactive_puts_ignored);
+	zdfs64("eph_zbytes", S_IRUGO, root, &zcache_eph_zbytes);
+	zdfs64("eph_zbytes_max", S_IRUGO, root, &zcache_eph_zbytes_max);
+	zdfs64("pers_zbytes", S_IRUGO, root, &zcache_pers_zbytes);
+	zdfs64("pers_zbytes_max", S_IRUGO, root, &zcache_pers_zbytes_max);
+	return 0;
+}
+#undef	zdebugfs
+#undef	zdfs64
+#endif
+
+#define ZCACHE_DEBUG
+#ifdef ZCACHE_DEBUG
+/* developers can call this in case of ooms, e.g. to find memory leaks */
+void zcache_dump(void)
+{
+	pr_info("zcache: obj_count=%lu\n", zcache_obj_count);
+	pr_info("zcache: obj_count_max=%lu\n", zcache_obj_count_max);
+	pr_info("zcache: objnode_count=%lu\n", zcache_objnode_count);
+	pr_info("zcache: objnode_count_max=%lu\n", zcache_objnode_count_max);
+	pr_info("zcache: flush_total=%lu\n", zcache_flush_total);
+	pr_info("zcache: flush_found=%lu\n", zcache_flush_found);
+	pr_info("zcache: flobj_total=%lu\n", zcache_flobj_total);
+	pr_info("zcache: flobj_found=%lu\n", zcache_flobj_found);
+	pr_info("zcache: failed_eph_puts=%lu\n", zcache_failed_eph_puts);
+	pr_info("zcache: failed_pers_puts=%lu\n", zcache_failed_pers_puts);
+	pr_info("zcache: failed_get_free_pages=%lu\n",
+				zcache_failed_getfreepages);
+	pr_info("zcache: failed_alloc=%lu\n", zcache_failed_alloc);
+	pr_info("zcache: put_to_flush=%lu\n", zcache_put_to_flush);
+	pr_info("zcache: compress_poor=%lu\n", zcache_compress_poor);
+	pr_info("zcache: mean_compress_poor=%lu\n",
+				zcache_mean_compress_poor);
+	pr_info("zcache: eph_ate_tail=%lu\n", zcache_eph_ate_tail);
+	pr_info("zcache: eph_ate_tail_failed=%lu\n",
+				zcache_eph_ate_tail_failed);
+	pr_info("zcache: pers_ate_eph=%lu\n", zcache_pers_ate_eph);
+	pr_info("zcache: pers_ate_eph_failed=%lu\n",
+				zcache_pers_ate_eph_failed);
+	pr_info("zcache: evicted_eph_zpages=%lu\n", zcache_evicted_eph_zpages);
+	pr_info("zcache: evicted_eph_pageframes=%lu\n",
+				zcache_evicted_eph_pageframes);
+	pr_info("zcache: eph_pageframes=%lu\n", zcache_eph_pageframes);
+	pr_info("zcache: eph_pageframes_max=%lu\n", zcache_eph_pageframes_max);
+	pr_info("zcache: pers_pageframes=%lu\n", zcache_pers_pageframes);
+	pr_info("zcache: pers_pageframes_max=%lu\n",
+				zcache_pers_pageframes_max);
+	pr_info("zcache: eph_zpages=%lu\n", zcache_eph_zpages);
+	pr_info("zcache: eph_zpages_max=%lu\n", zcache_eph_zpages_max);
+	pr_info("zcache: pers_zpages=%lu\n", zcache_pers_zpages);
+	pr_info("zcache: pers_zpages_max=%lu\n", zcache_pers_zpages_max);
+	pr_info("zcache: eph_zbytes=%llu\n",
+				(unsigned long long)zcache_eph_zbytes);
+	pr_info("zcache: eph_zbytes_max=%llu\n",
+				(unsigned long long)zcache_eph_zbytes_max);
+	pr_info("zcache: pers_zbytes=%llu\n",
+				(unsigned long long)zcache_pers_zbytes);
+	pr_info("zcache: pers_zbytes_max=%llu\n",
+			(unsigned long long)zcache_pers_zbytes_max);
+}
+#endif
+
+/*
+ * zcache core code starts here
+ */
+
+static struct zcache_client zcache_host;
+static struct zcache_client zcache_clients[MAX_CLIENTS];
+
+static inline bool is_local_client(struct zcache_client *cli)
+{
+	return cli == &zcache_host;
+}
+
+static struct zcache_client *zcache_get_client_by_id(uint16_t cli_id)
+{
+	struct zcache_client *cli = &zcache_host;
+
+	if (cli_id != LOCAL_CLIENT) {
+		if (cli_id >= MAX_CLIENTS)
+			goto out;
+		cli = &zcache_clients[cli_id];
+	}
+out:
+	return cli;
+}
+
+/*
+ * Tmem operations assume the poolid implies the invoking client.
+ * Zcache only has one client (the kernel itself): LOCAL_CLIENT.
+ * RAMster has each client numbered by cluster node, and a KVM version
+ * of zcache would have one client per guest and each client might
+ * have a poolid==N.
+ */
+struct tmem_pool *zcache_get_pool_by_id(uint16_t cli_id, uint16_t poolid)
+{
+	struct tmem_pool *pool = NULL;
+	struct zcache_client *cli = NULL;
+
+	cli = zcache_get_client_by_id(cli_id);
+	if (cli == NULL)
+		goto out;
+	if (!is_local_client(cli))
+		atomic_inc(&cli->refcount);
+	if (poolid < MAX_POOLS_PER_CLIENT) {
+		pool = cli->tmem_pools[poolid];
+		if (pool != NULL)
+			atomic_inc(&pool->refcount);
+	}
+out:
+	return pool;
+}
+
+void zcache_put_pool(struct tmem_pool *pool)
+{
+	struct zcache_client *cli = NULL;
+
+	if (pool == NULL)
+		BUG();
+	cli = pool->client;
+	atomic_dec(&pool->refcount);
+	if (!is_local_client(cli))
+		atomic_dec(&cli->refcount);
+}
+
+int zcache_new_client(uint16_t cli_id)
+{
+	struct zcache_client *cli;
+	int ret = -1;
+
+	cli = zcache_get_client_by_id(cli_id);
+	if (cli == NULL)
+		goto out;
+	if (cli->allocated)
+		goto out;
+	cli->allocated = 1;
+	ret = 0;
+out:
+	return ret;
+}
+
+/*
+ * zcache implementation for tmem host ops
+ */
+
+static struct tmem_objnode *zcache_objnode_alloc(struct tmem_pool *pool)
+{
+	struct tmem_objnode *objnode = NULL;
+	struct zcache_preload *kp;
+	int i;
+
+	kp = &__get_cpu_var(zcache_preloads);
+	for (i = 0; i < ARRAY_SIZE(kp->objnodes); i++) {
+		objnode = kp->objnodes[i];
+		if (objnode != NULL) {
+			kp->objnodes[i] = NULL;
+			break;
+		}
+	}
+	BUG_ON(objnode == NULL);
+	zcache_objnode_count = atomic_inc_return(&zcache_objnode_atomic);
+	if (zcache_objnode_count > zcache_objnode_count_max)
+		zcache_objnode_count_max = zcache_objnode_count;
+	return objnode;
+}
+
+static void zcache_objnode_free(struct tmem_objnode *objnode,
+					struct tmem_pool *pool)
+{
+	zcache_objnode_count =
+		atomic_dec_return(&zcache_objnode_atomic);
+	BUG_ON(zcache_objnode_count < 0);
+	kmem_cache_free(zcache_objnode_cache, objnode);
+}
+
+static struct tmem_obj *zcache_obj_alloc(struct tmem_pool *pool)
+{
+	struct tmem_obj *obj = NULL;
+	struct zcache_preload *kp;
+
+	kp = &__get_cpu_var(zcache_preloads);
+	obj = kp->obj;
+	BUG_ON(obj == NULL);
+	kp->obj = NULL;
+	zcache_obj_count = atomic_inc_return(&zcache_obj_atomic);
+	if (zcache_obj_count > zcache_obj_count_max)
+		zcache_obj_count_max = zcache_obj_count;
+	return obj;
+}
+
+static void zcache_obj_free(struct tmem_obj *obj, struct tmem_pool *pool)
+{
+	zcache_obj_count =
+		atomic_dec_return(&zcache_obj_atomic);
+	BUG_ON(zcache_obj_count < 0);
+	kmem_cache_free(zcache_obj_cache, obj);
+}
+
+static struct tmem_hostops zcache_hostops = {
+	.obj_alloc = zcache_obj_alloc,
+	.obj_free = zcache_obj_free,
+	.objnode_alloc = zcache_objnode_alloc,
+	.objnode_free = zcache_objnode_free,
+};
+
+static struct page *zcache_alloc_page(void)
+{
+	struct page *page = alloc_page(ZCACHE_GFP_MASK);
+
+	if (page != NULL)
+		zcache_pageframes_alloced =
+			atomic_inc_return(&zcache_pageframes_alloced_atomic);
+	return page;
+}
+
+static void zcache_unacct_page(void)
+{
+	zcache_pageframes_freed =
+		atomic_inc_return(&zcache_pageframes_freed_atomic);
+}
+
+static void zcache_free_page(struct page *page)
+{
+	long curr_pageframes;
+	static long max_pageframes, min_pageframes, total_freed;
+
+	if (page == NULL)
+		BUG();
+	__free_page(page);
+	zcache_pageframes_freed =
+		atomic_inc_return(&zcache_pageframes_freed_atomic);
+	curr_pageframes = zcache_pageframes_alloced -
+			atomic_read(&zcache_pageframes_freed_atomic) -
+			atomic_read(&zcache_eph_pageframes_atomic) -
+			atomic_read(&zcache_pers_pageframes_atomic);
+	if (curr_pageframes > max_pageframes)
+		max_pageframes = curr_pageframes;
+	if (curr_pageframes < min_pageframes)
+		min_pageframes = curr_pageframes;
+#ifdef ZCACHE_DEBUG
+	if (curr_pageframes > 2L || curr_pageframes < -2L) {
+		/* pr_info here */
+	}
+#endif
+}
+
+/*
+ * zcache implementations for PAM page descriptor ops
+ */
+
+/* forward reference */
+static void zcache_compress(struct page *from,
+				void **out_va, unsigned *out_len);
+
+static struct page *zcache_evict_eph_pageframe(void);
+
+static void *zcache_pampd_eph_create(char *data, size_t size, bool raw,
+					struct tmem_handle *th)
+{
+	void *pampd = NULL, *cdata = data;
+	unsigned clen = size;
+	struct page *page = (struct page *)(data), *newpage;
+
+	if (!raw) {
+		zcache_compress(page, &cdata, &clen);
+		if (clen > zbud_max_buddy_size()) {
+			zcache_compress_poor++;
+			goto out;
+		}
+	} else {
+		BUG_ON(clen > zbud_max_buddy_size());
+	}
+
+	/* look for space via an existing match first */
+	pampd = (void *)zbud_match_prep(th, true, cdata, clen);
+	if (pampd != NULL)
+		goto got_pampd;
+
+	/* no match, now we need to find (or free up) a full page */
+	newpage = zcache_alloc_page();
+	if (newpage != NULL)
+		goto create_in_new_page;
+
+	zcache_failed_getfreepages++;
+	/* can't allocate a page, evict an ephemeral page via LRU */
+	newpage = zcache_evict_eph_pageframe();
+	if (newpage == NULL) {
+		zcache_eph_ate_tail_failed++;
+		goto out;
+	}
+	zcache_eph_ate_tail++;
+
+create_in_new_page:
+	pampd = (void *)zbud_create_prep(th, true, cdata, clen, newpage);
+	BUG_ON(pampd == NULL);
+	zcache_eph_pageframes =
+		atomic_inc_return(&zcache_eph_pageframes_atomic);
+	if (zcache_eph_pageframes > zcache_eph_pageframes_max)
+		zcache_eph_pageframes_max = zcache_eph_pageframes;
+
+got_pampd:
+	zcache_eph_zbytes =
+		atomic_long_add_return(clen, &zcache_eph_zbytes_atomic);
+	if (zcache_eph_zbytes > zcache_eph_zbytes_max)
+		zcache_eph_zbytes_max = zcache_eph_zbytes;
+	zcache_eph_zpages = atomic_inc_return(&zcache_eph_zpages_atomic);
+	if (zcache_eph_zpages > zcache_eph_zpages_max)
+		zcache_eph_zpages_max = zcache_eph_zpages;
+	if (ramster_enabled && raw)
+		ramster_count_foreign_pages(true, 1);
+out:
+	return pampd;
+}
+
+static void *zcache_pampd_pers_create(char *data, size_t size, bool raw,
+					struct tmem_handle *th)
+{
+	void *pampd = NULL, *cdata = data;
+	unsigned clen = size;
+	struct page *page = (struct page *)(data), *newpage;
+	unsigned long zbud_mean_zsize;
+	unsigned long curr_pers_zpages, total_zsize;
+
+	if (data == NULL) {
+		BUG_ON(!ramster_enabled);
+		goto create_pampd;
+	}
+	curr_pers_zpages = zcache_pers_zpages;
+/* FIXME CONFIG_RAMSTER... subtract atomic remote_pers_pages here? */
+	if (!raw)
+		zcache_compress(page, &cdata, &clen);
+	/* reject if compression is too poor */
+	if (clen > zbud_max_zsize) {
+		zcache_compress_poor++;
+		goto out;
+	}
+	/* reject if mean compression is too poor */
+	if ((clen > zbud_max_mean_zsize) && (curr_pers_zpages > 0)) {
+		total_zsize = zcache_pers_zbytes;
+		if ((long)total_zsize < 0)
+			total_zsize = 0;
+		zbud_mean_zsize = div_u64(total_zsize,
+					curr_pers_zpages);
+		if (zbud_mean_zsize > zbud_max_mean_zsize) {
+			zcache_mean_compress_poor++;
+			goto out;
+		}
+	}
+
+create_pampd:
+	/* look for space via an existing match first */
+	pampd = (void *)zbud_match_prep(th, false, cdata, clen);
+	if (pampd != NULL)
+		goto got_pampd;
+
+	/* no match, now we need to find (or free up) a full page */
+	newpage = zcache_alloc_page();
+	if (newpage != NULL)
+		goto create_in_new_page;
+	/*
+	 * FIXME do the following only if eph is oversized?
+	 * if (zcache_eph_pageframes >
+	 * (global_page_state(NR_LRU_BASE + LRU_ACTIVE_FILE) +
+	 * global_page_state(NR_LRU_BASE + LRU_INACTIVE_FILE)))
+	 */
+	zcache_failed_getfreepages++;
+	/* can't allocate a page, evict an ephemeral page via LRU */
+	newpage = zcache_evict_eph_pageframe();
+	if (newpage == NULL) {
+		zcache_pers_ate_eph_failed++;
+		goto out;
+	}
+	zcache_pers_ate_eph++;
+
+create_in_new_page:
+	pampd = (void *)zbud_create_prep(th, false, cdata, clen, newpage);
+	BUG_ON(pampd == NULL);
+	zcache_pers_pageframes =
+		atomic_inc_return(&zcache_pers_pageframes_atomic);
+	if (zcache_pers_pageframes > zcache_pers_pageframes_max)
+		zcache_pers_pageframes_max = zcache_pers_pageframes;
+
+got_pampd:
+	zcache_pers_zpages = atomic_inc_return(&zcache_pers_zpages_atomic);
+	if (zcache_pers_zpages > zcache_pers_zpages_max)
+		zcache_pers_zpages_max = zcache_pers_zpages;
+	zcache_pers_zbytes =
+		atomic_long_add_return(clen, &zcache_pers_zbytes_atomic);
+	if (zcache_pers_zbytes > zcache_pers_zbytes_max)
+		zcache_pers_zbytes_max = zcache_pers_zbytes;
+	if (ramster_enabled && raw)
+		ramster_count_foreign_pages(false, 1);
+out:
+	return pampd;
+}
+
+/*
+ * This is called directly from zcache_put_page to pre-allocate space
+ * to store a zpage.
+ */
+void *zcache_pampd_create(char *data, unsigned int size, bool raw,
+					int eph, struct tmem_handle *th)
+{
+	void *pampd = NULL;
+	struct zcache_preload *kp;
+	struct tmem_objnode *objnode;
+	struct tmem_obj *obj;
+	int i;
+
+	BUG_ON(!irqs_disabled());
+	/* pre-allocate per-cpu metadata */
+	BUG_ON(zcache_objnode_cache == NULL);
+	BUG_ON(zcache_obj_cache == NULL);
+	kp = &__get_cpu_var(zcache_preloads);
+	for (i = 0; i < ARRAY_SIZE(kp->objnodes); i++) {
+		objnode = kp->objnodes[i];
+		if (objnode == NULL) {
+			objnode = kmem_cache_alloc(zcache_objnode_cache,
+							ZCACHE_GFP_MASK);
+			if (unlikely(objnode == NULL)) {
+				zcache_failed_alloc++;
+				goto out;
+			}
+			kp->objnodes[i] = objnode;
+		}
+	}
+	if (kp->obj == NULL) {
+		obj = kmem_cache_alloc(zcache_obj_cache, ZCACHE_GFP_MASK);
+		kp->obj = obj;
+	}
+	if (unlikely(kp->obj == NULL)) {
+		zcache_failed_alloc++;
+		goto out;
+	}
+	/*
+	 * ok, have all the metadata pre-allocated, now do the data
+	 * but since how we allocate the data is dependent on ephemeral
+	 * or persistent, we split the call here to different sub-functions
+	 */
+	if (eph)
+		pampd = zcache_pampd_eph_create(data, size, raw, th);
+	else
+		pampd = zcache_pampd_pers_create(data, size, raw, th);
+out:
+	return pampd;
+}
+
+/*
+ * This is a pamops called via tmem_put and is necessary to "finish"
+ * a pampd creation.
+ */
+void zcache_pampd_create_finish(void *pampd, bool eph)
+{
+	zbud_create_finish((struct zbudref *)pampd, eph);
+}
+
+/*
+ * This is passed as a function parameter to zbud_decompress so that
+ * zbud need not be familiar with the details of crypto. It assumes that
+ * the bytes from_va and to_va through from_va+size-1 and to_va+size-1 are
+ * kmapped.  It must be successful, else there is a logic bug somewhere.
+ */
+static void zcache_decompress(char *from_va, unsigned int size, char *to_va)
+{
+	int ret;
+	unsigned int outlen = PAGE_SIZE;
+
+	ret = zcache_comp_op(ZCACHE_COMPOP_DECOMPRESS, from_va, size,
+				to_va, &outlen);
+	BUG_ON(ret);
+	BUG_ON(outlen != PAGE_SIZE);
+}
+
+/*
+ * Decompress from the kernel va to a pageframe
+ */
+void zcache_decompress_to_page(char *from_va, unsigned int size,
+					struct page *to_page)
+{
+	char *to_va = kmap_atomic(to_page);
+	zcache_decompress(from_va, size, to_va);
+	kunmap_atomic(to_va);
+}
+
+/*
+ * fill the pageframe corresponding to the struct page with the data
+ * from the passed pampd
+ */
+static int zcache_pampd_get_data(char *data, size_t *sizep, bool raw,
+					void *pampd, struct tmem_pool *pool,
+					struct tmem_oid *oid, uint32_t index)
+{
+	int ret;
+	bool eph = !is_persistent(pool);
+
+	BUG_ON(preemptible());
+	BUG_ON(eph);	/* fix later if shared pools get implemented */
+	BUG_ON(pampd_is_remote(pampd));
+	if (raw)
+		ret = zbud_copy_from_zbud(data, (struct zbudref *)pampd,
+						sizep, eph);
+	else {
+		ret = zbud_decompress((struct page *)(data),
+					(struct zbudref *)pampd, false,
+					zcache_decompress);
+		*sizep = PAGE_SIZE;
+	}
+	return ret;
+}
+
+/*
+ * fill the pageframe corresponding to the struct page with the data
+ * from the passed pampd
+ */
+static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
+					void *pampd, struct tmem_pool *pool,
+					struct tmem_oid *oid, uint32_t index)
+{
+	int ret;
+	bool eph = !is_persistent(pool);
+	struct page *page = NULL;
+	unsigned int zsize, zpages;
+
+	BUG_ON(preemptible());
+	BUG_ON(pampd_is_remote(pampd));
+	if (raw)
+		ret = zbud_copy_from_zbud(data, (struct zbudref *)pampd,
+						sizep, eph);
+	else {
+		ret = zbud_decompress((struct page *)(data),
+					(struct zbudref *)pampd, eph,
+					zcache_decompress);
+		*sizep = PAGE_SIZE;
+	}
+	page = zbud_free_and_delist((struct zbudref *)pampd, eph,
+					&zsize, &zpages);
+	if (eph) {
+		if (page)
+			zcache_eph_pageframes =
+			    atomic_dec_return(&zcache_eph_pageframes_atomic);
+		zcache_eph_zpages =
+		    atomic_sub_return(zpages, &zcache_eph_zpages_atomic);
+		zcache_eph_zbytes =
+		    atomic_long_sub_return(zsize, &zcache_eph_zbytes_atomic);
+	} else {
+		if (page)
+			zcache_pers_pageframes =
+			    atomic_dec_return(&zcache_pers_pageframes_atomic);
+		zcache_pers_zpages =
+		    atomic_sub_return(zpages, &zcache_pers_zpages_atomic);
+		zcache_pers_zbytes =
+		    atomic_long_sub_return(zsize, &zcache_pers_zbytes_atomic);
+	}
+	if (!is_local_client(pool->client))
+		ramster_count_foreign_pages(eph, -1);
+	if (page)
+		zcache_free_page(page);
+	return ret;
+}
+
+/*
+ * free the pampd and remove it from any zcache lists
+ * pampd must no longer be pointed to from any tmem data structures!
+ */
+static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
+			      struct tmem_oid *oid, uint32_t index, bool acct)
+{
+	struct page *page = NULL;
+	unsigned int zsize, zpages;
+
+	BUG_ON(preemptible());
+	if (pampd_is_remote(pampd)) {
+		BUG_ON(!ramster_enabled);
+		pampd = ramster_pampd_free(pampd, pool, oid, index, acct);
+		if (pampd == NULL)
+			return;
+	}
+	if (is_ephemeral(pool)) {
+		page = zbud_free_and_delist((struct zbudref *)pampd,
+						true, &zsize, &zpages);
+		if (page)
+			zcache_eph_pageframes =
+			    atomic_dec_return(&zcache_eph_pageframes_atomic);
+		zcache_eph_zpages =
+		    atomic_sub_return(zpages, &zcache_eph_zpages_atomic);
+		zcache_eph_zbytes =
+		    atomic_long_sub_return(zsize, &zcache_eph_zbytes_atomic);
+		/* FIXME CONFIG_RAMSTER... check acct parameter? */
+	} else {
+		page = zbud_free_and_delist((struct zbudref *)pampd,
+						false, &zsize, &zpages);
+		if (page)
+			zcache_pers_pageframes =
+			    atomic_dec_return(&zcache_pers_pageframes_atomic);
+		zcache_pers_zpages =
+		     atomic_sub_return(zpages, &zcache_pers_zpages_atomic);
+		zcache_pers_zbytes =
+		    atomic_long_sub_return(zsize, &zcache_pers_zbytes_atomic);
+	}
+	if (!is_local_client(pool->client))
+		ramster_count_foreign_pages(is_ephemeral(pool), -1);
+	if (page)
+		zcache_free_page(page);
+}
+
+static struct tmem_pamops zcache_pamops = {
+	.create_finish = zcache_pampd_create_finish,
+	.get_data = zcache_pampd_get_data,
+	.get_data_and_free = zcache_pampd_get_data_and_free,
+	.free = zcache_pampd_free,
+};
+
+/*
+ * zcache compression/decompression and related per-cpu stuff
+ */
+
+static DEFINE_PER_CPU(unsigned char *, zcache_dstmem);
+#define ZCACHE_DSTMEM_ORDER 1
+
+static void zcache_compress(struct page *from, void **out_va, unsigned *out_len)
+{
+	int ret;
+	unsigned char *dmem = __get_cpu_var(zcache_dstmem);
+	char *from_va;
+
+	BUG_ON(!irqs_disabled());
+	/* no buffer or no compressor so can't compress */
+	BUG_ON(dmem == NULL);
+	*out_len = PAGE_SIZE << ZCACHE_DSTMEM_ORDER;
+	from_va = kmap_atomic(from);
+	mb();
+	ret = zcache_comp_op(ZCACHE_COMPOP_COMPRESS, from_va, PAGE_SIZE, dmem,
+				out_len);
+	BUG_ON(ret);
+	*out_va = dmem;
+	kunmap_atomic(from_va);
+}
+
+static int zcache_comp_cpu_up(int cpu)
+{
+	struct crypto_comp *tfm;
+
+	tfm = crypto_alloc_comp(zcache_comp_name, 0, 0);
+	if (IS_ERR(tfm))
+		return NOTIFY_BAD;
+	*per_cpu_ptr(zcache_comp_pcpu_tfms, cpu) = tfm;
+	return NOTIFY_OK;
+}
+
+static void zcache_comp_cpu_down(int cpu)
+{
+	struct crypto_comp *tfm;
+
+	tfm = *per_cpu_ptr(zcache_comp_pcpu_tfms, cpu);
+	crypto_free_comp(tfm);
+	*per_cpu_ptr(zcache_comp_pcpu_tfms, cpu) = NULL;
+}
+
+static int zcache_cpu_notifier(struct notifier_block *nb,
+				unsigned long action, void *pcpu)
+{
+	int ret, i, cpu = (long)pcpu;
+	struct zcache_preload *kp;
+
+	switch (action) {
+	case CPU_UP_PREPARE:
+		ret = zcache_comp_cpu_up(cpu);
+		if (ret != NOTIFY_OK) {
+			pr_err("%s: can't allocate compressor xform\n",
+				namestr);
+			return ret;
+		}
+		per_cpu(zcache_dstmem, cpu) = (void *)__get_free_pages(
+			GFP_KERNEL | __GFP_REPEAT, ZCACHE_DSTMEM_ORDER);
+		if (ramster_enabled)
+			ramster_cpu_up(cpu);
+		break;
+	case CPU_DEAD:
+	case CPU_UP_CANCELED:
+		zcache_comp_cpu_down(cpu);
+		free_pages((unsigned long)per_cpu(zcache_dstmem, cpu),
+			ZCACHE_DSTMEM_ORDER);
+		per_cpu(zcache_dstmem, cpu) = NULL;
+		kp = &per_cpu(zcache_preloads, cpu);
+		for (i = 0; i < ARRAY_SIZE(kp->objnodes); i++) {
+			if (kp->objnodes[i])
+				kmem_cache_free(zcache_objnode_cache,
+						kp->objnodes[i]);
+		}
+		if (kp->obj) {
+			kmem_cache_free(zcache_obj_cache, kp->obj);
+			kp->obj = NULL;
+		}
+		if (ramster_enabled)
+			ramster_cpu_down(cpu);
+		break;
+	default:
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block zcache_cpu_notifier_block = {
+	.notifier_call = zcache_cpu_notifier
+};
+
+/*
+ * The following code interacts with the zbud eviction and zbud
+ * zombify code to access LRU pages
+ */
+
+static struct page *zcache_evict_eph_pageframe(void)
+{
+	struct page *page;
+	unsigned int zsize = 0, zpages = 0;
+
+	page = zbud_evict_pageframe_lru(&zsize, &zpages);
+	if (page == NULL)
+		goto out;
+	zcache_eph_zbytes = atomic_long_sub_return(zsize,
+					&zcache_eph_zbytes_atomic);
+	zcache_eph_zpages = atomic_sub_return(zpages,
+					&zcache_eph_zpages_atomic);
+	zcache_evicted_eph_zpages++;
+	zcache_eph_pageframes =
+		atomic_dec_return(&zcache_eph_pageframes_atomic);
+	zcache_evicted_eph_pageframes++;
+out:
+	return page;
+}
+
+static void unswiz(struct tmem_oid oid, u32 index,
+				unsigned *type, pgoff_t *offset);
+#ifdef FRONTSWAP_HAS_UNUSE
+/*
+ *  Choose an LRU persistent pageframe and attempt to "unuse" it by
+ *  calling frontswap_unuse on both zpages.
+ *
+ *  This is work-in-progress.
+ */
+
+static int zcache_frontswap_unuse(void)
+{
+	struct tmem_handle th[2];
+	int ret = -ENOMEM;
+	int nzbuds, unuse_ret;
+	unsigned type;
+	struct page *newpage1 = NULL, *newpage2 = NULL;
+	struct page *evictpage1 = NULL, *evictpage2 = NULL;
+	pgoff_t offset;
+
+	newpage1 = alloc_page(ZCACHE_GFP_MASK);
+	newpage2 = alloc_page(ZCACHE_GFP_MASK);
+	if (newpage1 == NULL)
+		evictpage1 = zcache_evict_eph_pageframe();
+	if (newpage2 == NULL)
+		evictpage2 = zcache_evict_eph_pageframe();
+	if (evictpage1 == NULL || evictpage2 == NULL)
+		goto free_and_out;
+	/* ok, we have two pages pre-allocated */
+	nzbuds = zbud_make_zombie_lru(&th[0], NULL, NULL, false);
+	if (nzbuds == 0) {
+		ret = -ENOENT;
+		goto free_and_out;
+	}
+	unswiz(th[0].oid, th[0].index, &type, &offset);
+	unuse_ret = frontswap_unuse(type, offset,
+				newpage1 != NULL ? newpage1 : evictpage1,
+				ZCACHE_GFP_MASK);
+	if (unuse_ret != 0)
+		goto free_and_out;
+	else if (evictpage1 != NULL)
+		zcache_unacct_page();
+	newpage1 = NULL;
+	evictpage1 = NULL;
+	if (nzbuds == 2) {
+		unswiz(th[1].oid, th[1].index, &type, &offset);
+		unuse_ret = frontswap_unuse(type, offset,
+				newpage2 != NULL ? newpage2 : evictpage2,
+				ZCACHE_GFP_MASK);
+		if (unuse_ret != 0) {
+			goto free_and_out;
+		} else if (evictpage2 != NULL) {
+			zcache_unacct_page();
+		}
+	}
+	ret = 0;
+	goto out;
+
+free_and_out:
+	if (newpage1 != NULL)
+		__free_page(newpage1);
+	if (newpage2 != NULL)
+		__free_page(newpage2);
+	if (evictpage1 != NULL)
+		zcache_free_page(evictpage1);
+	if (evictpage2 != NULL)
+		zcache_free_page(evictpage2);
+out:
+	return ret;
+}
+#endif
+
+/*
+ * When zcache is disabled ("frozen"), pools can be created and destroyed,
+ * but all puts (and thus all other operations that require memory allocation)
+ * must fail.  If zcache is unfrozen, accepts puts, then frozen again,
+ * data consistency requires all puts while frozen to be converted into
+ * flushes.
+ */
+static bool zcache_freeze;
+
+/*
+ * This zcache shrinker interface reduces the number of ephemeral pageframes
+ * used by zcache to approximately the same as the total number of LRU_FILE
+ * pageframes in use.
+ */
+static int shrink_zcache_memory(struct shrinker *shrink,
+				struct shrink_control *sc)
+{
+	static bool in_progress;
+	int ret = -1;
+	int nr = sc->nr_to_scan;
+	int nr_evict = 0;
+	int nr_unuse = 0;
+	struct page *page;
+	int unuse_ret;
+
+	if (nr <= 0)
+		goto skip_evict;
+
+	/* don't allow more than one eviction thread at a time */
+	if (in_progress)
+		goto skip_evict;
+
+	in_progress = true;
+
+	/* we are going to ignore nr, and target a different value */
+	zcache_last_active_file_pageframes =
+		global_page_state(NR_LRU_BASE + LRU_ACTIVE_FILE);
+	zcache_last_inactive_file_pageframes =
+		global_page_state(NR_LRU_BASE + LRU_INACTIVE_FILE);
+	nr_evict = zcache_eph_pageframes - zcache_last_active_file_pageframes +
+		zcache_last_inactive_file_pageframes;
+	while (nr_evict-- > 0) {
+		page = zcache_evict_eph_pageframe();
+		if (page == NULL)
+			break;
+		zcache_free_page(page);
+	}
+
+	zcache_last_active_anon_pageframes =
+		global_page_state(NR_LRU_BASE + LRU_ACTIVE_ANON);
+	zcache_last_inactive_anon_pageframes =
+		global_page_state(NR_LRU_BASE + LRU_INACTIVE_ANON);
+	nr_unuse = zcache_pers_pageframes - zcache_last_active_anon_pageframes +
+		zcache_last_inactive_anon_pageframes;
+#ifdef FRONTSWAP_HAS_UNUSE
+	/* rate limit for testing */
+	if (nr_unuse > 32)
+		nr_unuse = 32;
+	while (nr_unuse-- > 0) {
+		unuse_ret = zcache_frontswap_unuse();
+		if (unuse_ret == -ENOMEM)
+			break;
+	}
+#endif
+	in_progress = false;
+
+skip_evict:
+	/* resample: has changed, but maybe not all the way yet */
+	zcache_last_active_file_pageframes =
+		global_page_state(NR_LRU_BASE + LRU_ACTIVE_FILE);
+	zcache_last_inactive_file_pageframes =
+		global_page_state(NR_LRU_BASE + LRU_INACTIVE_FILE);
+	ret = zcache_eph_pageframes - zcache_last_active_file_pageframes +
+		zcache_last_inactive_file_pageframes;
+	if (ret < 0)
+		ret = 0;
+	return ret;
+}
+
+static struct shrinker zcache_shrinker = {
+	.shrink = shrink_zcache_memory,
+	.seeks = DEFAULT_SEEKS,
+};
+
+/*
+ * zcache shims between cleancache/frontswap ops and tmem
+ */
+
+/* FIXME rename these core routines to zcache_tmemput etc? */
+int zcache_put_page(int cli_id, int pool_id, struct tmem_oid *oidp,
+				uint32_t index, void *page,
+				unsigned int size, bool raw, int ephemeral)
+{
+	struct tmem_pool *pool;
+	struct tmem_handle th;
+	int ret = -1;
+	void *pampd = NULL;
+
+	BUG_ON(!irqs_disabled());
+	pool = zcache_get_pool_by_id(cli_id, pool_id);
+	if (unlikely(pool == NULL))
+		goto out;
+	if (!zcache_freeze) {
+		ret = 0;
+		th.client_id = cli_id;
+		th.pool_id = pool_id;
+		th.oid = *oidp;
+		th.index = index;
+		pampd = zcache_pampd_create((char *)page, size, raw,
+				ephemeral, &th);
+		if (pampd == NULL) {
+			ret = -ENOMEM;
+			if (ephemeral)
+				zcache_failed_eph_puts++;
+			else
+				zcache_failed_pers_puts++;
+		} else {
+			if (ramster_enabled)
+				ramster_do_preload_flnode(pool);
+			ret = tmem_put(pool, oidp, index, 0, pampd);
+			if (ret < 0)
+				BUG();
+		}
+		zcache_put_pool(pool);
+	} else {
+		zcache_put_to_flush++;
+		if (ramster_enabled)
+			ramster_do_preload_flnode(pool);
+		if (atomic_read(&pool->obj_count) > 0)
+			/* the put fails whether the flush succeeds or not */
+			(void)tmem_flush_page(pool, oidp, index);
+		zcache_put_pool(pool);
+	}
+out:
+	return ret;
+}
+
+int zcache_get_page(int cli_id, int pool_id, struct tmem_oid *oidp,
+				uint32_t index, void *page,
+				size_t *sizep, bool raw, int get_and_free)
+{
+	struct tmem_pool *pool;
+	int ret = -1;
+	bool eph;
+
+	if (!raw) {
+		BUG_ON(irqs_disabled());
+		BUG_ON(in_softirq());
+	}
+	pool = zcache_get_pool_by_id(cli_id, pool_id);
+	eph = is_ephemeral(pool);
+	if (likely(pool != NULL)) {
+		if (atomic_read(&pool->obj_count) > 0)
+			ret = tmem_get(pool, oidp, index, (char *)(page),
+					sizep, raw, get_and_free);
+		zcache_put_pool(pool);
+	}
+	WARN_ONCE((!is_ephemeral(pool) && (ret != 0)),
+			"zcache_get fails on persistent pool, "
+			"bad things are very likely to happen soon\n");
+#ifdef RAMSTER_TESTING
+	if (ret != 0 && ret != -1 && !(ret == -EINVAL && is_ephemeral(pool)))
+		pr_err("TESTING zcache_get tmem_get returns ret=%d\n", ret);
+#endif
+	return ret;
+}
+
+int zcache_flush_page(int cli_id, int pool_id,
+				struct tmem_oid *oidp, uint32_t index)
+{
+	struct tmem_pool *pool;
+	int ret = -1;
+	unsigned long flags;
+
+	local_irq_save(flags);
+	zcache_flush_total++;
+	pool = zcache_get_pool_by_id(cli_id, pool_id);
+	if (ramster_enabled)
+		ramster_do_preload_flnode(pool);
+	if (likely(pool != NULL)) {
+		if (atomic_read(&pool->obj_count) > 0)
+			ret = tmem_flush_page(pool, oidp, index);
+		zcache_put_pool(pool);
+	}
+	if (ret >= 0)
+		zcache_flush_found++;
+	local_irq_restore(flags);
+	return ret;
+}
+
+int zcache_flush_object(int cli_id, int pool_id,
+				struct tmem_oid *oidp)
+{
+	struct tmem_pool *pool;
+	int ret = -1;
+	unsigned long flags;
+
+	local_irq_save(flags);
+	zcache_flobj_total++;
+	pool = zcache_get_pool_by_id(cli_id, pool_id);
+	if (ramster_enabled)
+		ramster_do_preload_flnode(pool);
+	if (likely(pool != NULL)) {
+		if (atomic_read(&pool->obj_count) > 0)
+			ret = tmem_flush_object(pool, oidp);
+		zcache_put_pool(pool);
+	}
+	if (ret >= 0)
+		zcache_flobj_found++;
+	local_irq_restore(flags);
+	return ret;
+}
+
+static int zcache_client_destroy_pool(int cli_id, int pool_id)
+{
+	struct tmem_pool *pool = NULL;
+	struct zcache_client *cli = NULL;
+	int ret = -1;
+
+	if (pool_id < 0)
+		goto out;
+	if (cli_id == LOCAL_CLIENT)
+		cli = &zcache_host;
+	else if ((unsigned int)cli_id < MAX_CLIENTS)
+		cli = &zcache_clients[cli_id];
+	if (cli == NULL)
+		goto out;
+	atomic_inc(&cli->refcount);
+	pool = cli->tmem_pools[pool_id];
+	if (pool == NULL)
+		goto out;
+	cli->tmem_pools[pool_id] = NULL;
+	/* wait for pool activity on other cpus to quiesce */
+	while (atomic_read(&pool->refcount) != 0)
+		;
+	atomic_dec(&cli->refcount);
+	local_bh_disable();
+	ret = tmem_destroy_pool(pool);
+	local_bh_enable();
+	kfree(pool);
+	if (cli_id == LOCAL_CLIENT)
+		pr_info("%s: destroyed local pool id=%d\n", namestr, pool_id);
+	else
+		pr_info("%s: destroyed pool id=%d, client=%d\n",
+				namestr, pool_id, cli_id);
+out:
+	return ret;
+}
+
+int zcache_new_pool(uint16_t cli_id, uint32_t flags)
+{
+	int poolid = -1;
+	struct tmem_pool *pool;
+	struct zcache_client *cli = NULL;
+
+	if (cli_id == LOCAL_CLIENT)
+		cli = &zcache_host;
+	else if ((unsigned int)cli_id < MAX_CLIENTS)
+		cli = &zcache_clients[cli_id];
+	if (cli == NULL)
+		goto out;
+	atomic_inc(&cli->refcount);
+	pool = kmalloc(sizeof(struct tmem_pool), GFP_ATOMIC);
+	if (pool == NULL) {
+		pr_info("%s: pool creation failed: out of memory\n", namestr);
+		goto out;
+	}
+
+	for (poolid = 0; poolid < MAX_POOLS_PER_CLIENT; poolid++)
+		if (cli->tmem_pools[poolid] == NULL)
+			break;
+	if (poolid >= MAX_POOLS_PER_CLIENT) {
+		pr_info("%s: pool creation failed: max exceeded\n", namestr);
+		kfree(pool);
+		poolid = -1;
+		goto out;
+	}
+	atomic_set(&pool->refcount, 0);
+	pool->client = cli;
+	pool->pool_id = poolid;
+	tmem_new_pool(pool, flags);
+	cli->tmem_pools[poolid] = pool;
+	if (cli_id == LOCAL_CLIENT)
+		pr_info("%s: created %s local tmem pool, id=%d\n", namestr,
+			flags & TMEM_POOL_PERSIST ? "persistent" : "ephemeral",
+			poolid);
+	else
+		pr_info("%s: created %s tmem pool, id=%d, client=%d\n", namestr,
+			flags & TMEM_POOL_PERSIST ? "persistent" : "ephemeral",
+			poolid, cli_id);
+out:
+	if (cli != NULL)
+		atomic_dec(&cli->refcount);
+	return poolid;
+}
+
+static int zcache_local_new_pool(uint32_t flags)
+{
+	return zcache_new_pool(LOCAL_CLIENT, flags);
+}
+
+int zcache_autocreate_pool(int cli_id, int pool_id, bool eph)
+{
+	struct tmem_pool *pool;
+	struct zcache_client *cli = NULL;
+	uint32_t flags = eph ? 0 : TMEM_POOL_PERSIST;
+	int ret = -1;
+
+	BUG_ON(!ramster_enabled);
+	if (cli_id == LOCAL_CLIENT)
+		goto out;
+	if (pool_id >= MAX_POOLS_PER_CLIENT)
+		goto out;
+	else if ((unsigned int)cli_id < MAX_CLIENTS)
+		cli = &zcache_clients[cli_id];
+	if ((eph && disable_cleancache) || (!eph && disable_frontswap)) {
+		pr_err("zcache_autocreate_pool: pool type disabled\n");
+		goto out;
+	}
+	if (!cli->allocated) {
+		if (zcache_new_client(cli_id)) {
+			pr_err("zcache_autocreate_pool: can't create client\n");
+			goto out;
+		}
+		cli = &zcache_clients[cli_id];
+	}
+	atomic_inc(&cli->refcount);
+	pool = cli->tmem_pools[pool_id];
+	if (pool != NULL) {
+		if (pool->persistent && eph) {
+			pr_err("zcache_autocreate_pool: type mismatch\n");
+			goto out;
+		}
+		ret = 0;
+		goto out;
+	}
+	pool = kmalloc(sizeof(struct tmem_pool), GFP_KERNEL);
+	if (pool == NULL) {
+		pr_info("%s: pool creation failed: out of memory\n", namestr);
+		goto out;
+	}
+	atomic_set(&pool->refcount, 0);
+	pool->client = cli;
+	pool->pool_id = pool_id;
+	tmem_new_pool(pool, flags);
+	cli->tmem_pools[pool_id] = pool;
+	pr_info("%s: AUTOcreated %s tmem poolid=%d, for remote client=%d\n",
+		namestr, flags & TMEM_POOL_PERSIST ? "persistent" : "ephemeral",
+		pool_id, cli_id);
+	ret = 0;
+out:
+	if (cli != NULL)
+		atomic_dec(&cli->refcount);
+	return ret;
+}
+
+/**********
+ * Two kernel functionalities currently can be layered on top of tmem.
+ * These are "cleancache" which is used as a second-chance cache for clean
+ * page cache pages; and "frontswap" which is used for swap pages
+ * to avoid writes to disk.  A generic "shim" is provided here for each
+ * to translate in-kernel semantics to zcache semantics.
+ */
+
+static void zcache_cleancache_put_page(int pool_id,
+					struct cleancache_filekey key,
+					pgoff_t index, struct page *page)
+{
+	u32 ind = (u32) index;
+	struct tmem_oid oid = *(struct tmem_oid *)&key;
+
+	if (!disable_cleancache_ignore_nonactive && !PageWasActive(page)) {
+		zcache_eph_nonactive_puts_ignored++;
+		return;
+	}
+	if (likely(ind == index))
+		(void)zcache_put_page(LOCAL_CLIENT, pool_id, &oid, index,
+					page, PAGE_SIZE, false, 1);
+}
+
+static int zcache_cleancache_get_page(int pool_id,
+					struct cleancache_filekey key,
+					pgoff_t index, struct page *page)
+{
+	u32 ind = (u32) index;
+	struct tmem_oid oid = *(struct tmem_oid *)&key;
+	size_t size;
+	int ret = -1;
+
+	if (likely(ind == index)) {
+		ret = zcache_get_page(LOCAL_CLIENT, pool_id, &oid, index,
+					page, &size, false, 0);
+		BUG_ON(ret >= 0 && size != PAGE_SIZE);
+		if (ret == 0)
+			SetPageWasActive(page);
+	}
+	return ret;
+}
+
+static void zcache_cleancache_flush_page(int pool_id,
+					struct cleancache_filekey key,
+					pgoff_t index)
+{
+	u32 ind = (u32) index;
+	struct tmem_oid oid = *(struct tmem_oid *)&key;
+
+	if (likely(ind == index))
+		(void)zcache_flush_page(LOCAL_CLIENT, pool_id, &oid, ind);
+}
+
+static void zcache_cleancache_flush_inode(int pool_id,
+					struct cleancache_filekey key)
+{
+	struct tmem_oid oid = *(struct tmem_oid *)&key;
+
+	(void)zcache_flush_object(LOCAL_CLIENT, pool_id, &oid);
+}
+
+static void zcache_cleancache_flush_fs(int pool_id)
+{
+	if (pool_id >= 0)
+		(void)zcache_client_destroy_pool(LOCAL_CLIENT, pool_id);
+}
+
+static int zcache_cleancache_init_fs(size_t pagesize)
+{
+	BUG_ON(sizeof(struct cleancache_filekey) !=
+				sizeof(struct tmem_oid));
+	BUG_ON(pagesize != PAGE_SIZE);
+	return zcache_local_new_pool(0);
+}
+
+static int zcache_cleancache_init_shared_fs(char *uuid, size_t pagesize)
+{
+	/* shared pools are unsupported and map to private */
+	BUG_ON(sizeof(struct cleancache_filekey) !=
+				sizeof(struct tmem_oid));
+	BUG_ON(pagesize != PAGE_SIZE);
+	return zcache_local_new_pool(0);
+}
+
+static struct cleancache_ops zcache_cleancache_ops = {
+	.put_page = zcache_cleancache_put_page,
+	.get_page = zcache_cleancache_get_page,
+	.invalidate_page = zcache_cleancache_flush_page,
+	.invalidate_inode = zcache_cleancache_flush_inode,
+	.invalidate_fs = zcache_cleancache_flush_fs,
+	.init_shared_fs = zcache_cleancache_init_shared_fs,
+	.init_fs = zcache_cleancache_init_fs
+};
+
+struct cleancache_ops zcache_cleancache_register_ops(void)
+{
+	struct cleancache_ops old_ops =
+		cleancache_register_ops(&zcache_cleancache_ops);
+
+	return old_ops;
+}
+
+/* a single tmem poolid is used for all frontswap "types" (swapfiles) */
+static int zcache_frontswap_poolid __read_mostly = -1;
+
+/*
+ * Swizzling increases objects per swaptype, increasing tmem concurrency
+ * for heavy swaploads.  Later, larger nr_cpus -> larger SWIZ_BITS
+ * Setting SWIZ_BITS to 27 basically reconstructs the swap entry from
+ * frontswap_get_page(), but has side-effects. Hence using 8.
+ */
+#define SWIZ_BITS		8
+#define SWIZ_MASK		((1 << SWIZ_BITS) - 1)
+#define _oswiz(_type, _ind)	((_type << SWIZ_BITS) | (_ind & SWIZ_MASK))
+#define iswiz(_ind)		(_ind >> SWIZ_BITS)
+
+static inline struct tmem_oid oswiz(unsigned type, u32 ind)
+{
+	struct tmem_oid oid = { .oid = { 0 } };
+	oid.oid[0] = _oswiz(type, ind);
+	return oid;
+}
+
+static void unswiz(struct tmem_oid oid, u32 index,
+				unsigned *type, pgoff_t *offset)
+{
+	*type = (unsigned)(oid.oid[0] >> SWIZ_BITS);
+	*offset = (pgoff_t)((index << SWIZ_BITS) |
+			(oid.oid[0] & SWIZ_MASK));
+}
+
+static int zcache_frontswap_put_page(unsigned type, pgoff_t offset,
+					struct page *page)
+{
+	u64 ind64 = (u64)offset;
+	u32 ind = (u32)offset;
+	struct tmem_oid oid = oswiz(type, ind);
+	int ret = -1;
+	unsigned long flags;
+	int unuse_ret;
+
+	BUG_ON(!PageLocked(page));
+	if (!disable_frontswap_ignore_nonactive && !PageWasActive(page)) {
+		zcache_pers_nonactive_puts_ignored++;
+		ret = -ERANGE;
+		goto out;
+	}
+	if (likely(ind64 == ind)) {
+		local_irq_save(flags);
+		ret = zcache_put_page(LOCAL_CLIENT, zcache_frontswap_poolid,
+					&oid, iswiz(ind),
+					page, PAGE_SIZE, false, 0);
+		local_irq_restore(flags);
+	}
+out:
+	return ret;
+}
+
+/* returns 0 if the page was successfully gotten from frontswap, -1 if
+ * was not present (should never happen!) */
+static int zcache_frontswap_get_page(unsigned type, pgoff_t offset,
+					struct page *page)
+{
+	u64 ind64 = (u64)offset;
+	u32 ind = (u32)offset;
+	struct tmem_oid oid = oswiz(type, ind);
+	size_t size;
+	int ret = -1, get_and_free;
+
+	if (frontswap_has_exclusive_gets)
+		get_and_free = 1;
+	else
+		get_and_free = -1;
+	BUG_ON(!PageLocked(page));
+	if (likely(ind64 == ind)) {
+		ret = zcache_get_page(LOCAL_CLIENT, zcache_frontswap_poolid,
+					&oid, iswiz(ind),
+					page, &size, false, get_and_free);
+		BUG_ON(ret >= 0 && size != PAGE_SIZE);
+	}
+	return ret;
+}
+
+/* flush a single page from frontswap */
+static void zcache_frontswap_flush_page(unsigned type, pgoff_t offset)
+{
+	u64 ind64 = (u64)offset;
+	u32 ind = (u32)offset;
+	struct tmem_oid oid = oswiz(type, ind);
+
+	if (likely(ind64 == ind))
+		(void)zcache_flush_page(LOCAL_CLIENT, zcache_frontswap_poolid,
+					&oid, iswiz(ind));
+}
+
+/* flush all pages from the passed swaptype */
+static void zcache_frontswap_flush_area(unsigned type)
+{
+	struct tmem_oid oid;
+	int ind;
+
+	for (ind = SWIZ_MASK; ind >= 0; ind--) {
+		oid = oswiz(type, ind);
+		(void)zcache_flush_object(LOCAL_CLIENT,
+						zcache_frontswap_poolid, &oid);
+	}
+}
+
+static void zcache_frontswap_init(unsigned ignored)
+{
+	/* a single tmem poolid is used for all frontswap "types" (swapfiles) */
+	if (zcache_frontswap_poolid < 0)
+		zcache_frontswap_poolid =
+			zcache_local_new_pool(TMEM_POOL_PERSIST);
+}
+
+static struct frontswap_ops zcache_frontswap_ops = {
+	.store = zcache_frontswap_put_page,
+	.load = zcache_frontswap_get_page,
+	.invalidate_page = zcache_frontswap_flush_page,
+	.invalidate_area = zcache_frontswap_flush_area,
+	.init = zcache_frontswap_init
+};
+
+struct frontswap_ops zcache_frontswap_register_ops(void)
+{
+	struct frontswap_ops old_ops =
+		frontswap_register_ops(&zcache_frontswap_ops);
+
+	return old_ops;
+}
+
+/*
+ * zcache initialization
+ * NOTE FOR NOW zcache or ramster MUST BE PROVIDED AS A KERNEL BOOT PARAMETER
+ * OR NOTHING HAPPENS!
+ */
+
+static int __init enable_zcache(char *s)
+{
+	zcache_enabled = 1;
+	return 1;
+}
+__setup("zcache", enable_zcache);
+
+static int __init enable_ramster(char *s)
+{
+	zcache_enabled = 1;
+#ifdef CONFIG_RAMSTER
+	ramster_enabled = 1;
+#endif
+	return 1;
+}
+__setup("ramster", enable_ramster);
+
+/* allow independent dynamic disabling of cleancache and frontswap */
+
+static int __init no_cleancache(char *s)
+{
+	disable_cleancache = 1;
+	return 1;
+}
+
+__setup("nocleancache", no_cleancache);
+
+static int __init no_frontswap(char *s)
+{
+	disable_frontswap = 1;
+	return 1;
+}
+
+__setup("nofrontswap", no_frontswap);
+
+static int __init no_frontswap_exclusive_gets(char *s)
+{
+	frontswap_has_exclusive_gets = false;
+	return 1;
+}
+
+__setup("nofrontswapexclusivegets", no_frontswap_exclusive_gets);
+
+static int __init no_frontswap_ignore_nonactive(char *s)
+{
+	disable_frontswap_ignore_nonactive = 1;
+	return 1;
+}
+
+__setup("nofrontswapignorenonactive", no_frontswap_ignore_nonactive);
+
+static int __init no_cleancache_ignore_nonactive(char *s)
+{
+	disable_cleancache_ignore_nonactive = 1;
+	return 1;
+}
+
+__setup("nocleancacheignorenonactive", no_cleancache_ignore_nonactive);
+
+static int __init enable_zcache_compressor(char *s)
+{
+	strncpy(zcache_comp_name, s, ZCACHE_COMP_NAME_SZ);
+	zcache_enabled = 1;
+	return 1;
+}
+__setup("zcache=", enable_zcache_compressor);
+
+
+static int __init zcache_comp_init(void)
+{
+	int ret = 0;
+
+	/* check crypto algorithm */
+	if (*zcache_comp_name != '\0') {
+		ret = crypto_has_comp(zcache_comp_name, 0, 0);
+		if (!ret)
+			pr_info("zcache: %s not supported\n",
+					zcache_comp_name);
+	}
+	if (!ret)
+		strcpy(zcache_comp_name, "lzo");
+	ret = crypto_has_comp(zcache_comp_name, 0, 0);
+	if (!ret) {
+		ret = 1;
+		goto out;
+	}
+	pr_info("zcache: using %s compressor\n", zcache_comp_name);
+
+	/* alloc percpu transforms */
+	ret = 0;
+	zcache_comp_pcpu_tfms = alloc_percpu(struct crypto_comp *);
+	if (!zcache_comp_pcpu_tfms)
+		ret = 1;
+out:
+	return ret;
+}
+
+static int __init zcache_init(void)
+{
+	int ret = 0;
+
+	if (ramster_enabled) {
+		namestr = "ramster";
+		ramster_register_pamops(&zcache_pamops);
+	}
+#ifdef CONFIG_DEBUG_FS
+	zcache_debugfs_init();
+#endif
+	if (zcache_enabled) {
+		unsigned int cpu;
+
+		tmem_register_hostops(&zcache_hostops);
+		tmem_register_pamops(&zcache_pamops);
+		ret = register_cpu_notifier(&zcache_cpu_notifier_block);
+		if (ret) {
+			pr_err("%s: can't register cpu notifier\n", namestr);
+			goto out;
+		}
+		ret = zcache_comp_init();
+		if (ret) {
+			pr_err("%s: compressor initialization failed\n",
+				namestr);
+			goto out;
+		}
+		for_each_online_cpu(cpu) {
+			void *pcpu = (void *)(long)cpu;
+			zcache_cpu_notifier(&zcache_cpu_notifier_block,
+				CPU_UP_PREPARE, pcpu);
+		}
+	}
+	zcache_objnode_cache = kmem_cache_create("zcache_objnode",
+				sizeof(struct tmem_objnode), 0, 0, NULL);
+	zcache_obj_cache = kmem_cache_create("zcache_obj",
+				sizeof(struct tmem_obj), 0, 0, NULL);
+	ret = zcache_new_client(LOCAL_CLIENT);
+	if (ret) {
+		pr_err("%s: can't create client\n", namestr);
+		goto out;
+	}
+	zbud_init();
+	if (zcache_enabled && !disable_cleancache) {
+		struct cleancache_ops old_ops;
+
+		register_shrinker(&zcache_shrinker);
+		old_ops = zcache_cleancache_register_ops();
+		pr_info("%s: cleancache enabled using kernel transcendent "
+			"memory and compression buddies\n", namestr);
+#ifdef ZCACHE_DEBUG
+		pr_info("%s: cleancache: ignorenonactive = %d\n",
+			namestr, !disable_cleancache_ignore_nonactive);
+#endif
+		if (old_ops.init_fs != NULL)
+			pr_warn("%s: cleancache_ops overridden\n", namestr);
+	}
+	if (zcache_enabled && !disable_frontswap) {
+		struct frontswap_ops old_ops;
+
+		old_ops = zcache_frontswap_register_ops();
+		if (frontswap_has_exclusive_gets)
+			frontswap_tmem_exclusive_gets(true);
+		pr_info("%s: frontswap enabled using kernel transcendent "
+			"memory and compression buddies\n", namestr);
+#ifdef ZCACHE_DEBUG
+		pr_info("%s: frontswap: excl gets = %d active only = %d\n",
+			namestr, frontswap_has_exclusive_gets,
+			!disable_frontswap_ignore_nonactive);
+#endif
+		if (old_ops.init != NULL)
+			pr_warn("%s: frontswap_ops overridden\n", namestr);
+	}
+	if (ramster_enabled)
+		ramster_init(!disable_cleancache, !disable_frontswap,
+				frontswap_has_exclusive_gets);
+out:
+	return ret;
+}
+
+late_initcall(zcache_init);
diff --git a/drivers/staging/zcache/zcache.h b/drivers/staging/zcache/zcache.h
new file mode 100644
index 0000000..c59666e
--- /dev/null
+++ b/drivers/staging/zcache/zcache.h
@@ -0,0 +1,53 @@
+
+/*
+ * zcache.h
+ *
+ * Copyright (c) 2012, Dan Magenheimer, Oracle Corp.
+ */
+
+#ifndef _ZCACHE_H_
+#define _ZCACHE_H_
+
+struct zcache_preload {
+	struct tmem_obj *obj;
+	struct tmem_objnode *objnodes[OBJNODE_TREE_MAX_PATH];
+};
+
+struct tmem_pool;
+
+#define MAX_POOLS_PER_CLIENT 16
+
+#define MAX_CLIENTS 16
+#define LOCAL_CLIENT ((uint16_t)-1)
+
+struct zcache_client {
+	struct tmem_pool *tmem_pools[MAX_POOLS_PER_CLIENT];
+	bool allocated;
+	atomic_t refcount;
+};
+
+extern struct tmem_pool *zcache_get_pool_by_id(uint16_t cli_id,
+							uint16_t poolid);
+extern void zcache_put_pool(struct tmem_pool *pool);
+
+extern int zcache_put_page(int, int, struct tmem_oid *,
+				uint32_t, void *,
+				unsigned int, bool, int);
+extern int zcache_get_page(int, int, struct tmem_oid *, uint32_t,
+				void *, size_t *, bool, int);
+extern int zcache_flush_page(int, int, struct tmem_oid *, uint32_t);
+extern int zcache_flush_object(int, int, struct tmem_oid *);
+extern void zcache_decompress_to_page(char *, unsigned int, struct page *);
+
+#ifdef CONFIG_RAMSTER
+extern void *zcache_pampd_create(char *, unsigned int, bool, int,
+				struct tmem_handle *);
+extern int zcache_autocreate_pool(int, int, bool);
+#endif
+
+#define MAX_POOLS_PER_CLIENT 16
+
+#define MAX_CLIENTS 16
+#define LOCAL_CLIENT ((uint16_t)-1)
+
+#endif /* _ZCACHE_H_ */
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
