Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 099C86B006C
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 11:27:48 -0500 (EST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH 2/6] staging: ramster: local compression + tmem
Date: Fri, 27 Jan 2012 08:27:39 -0800
Message-Id: <1327681659-9394-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, gregkh@suse.de, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, kurt.hackel@oracle.com, sjenning@linux.vnet.ibm.com, chris.mason@oracle.com, dan.magenheimer@oracle.com

Copy files from drivers/staging/zcache.  Ramster compresses pages
locally before transmitting them to another node, so we can
leverage the zcache and tmem code directly.  Note: there are
no ramster-specific changes yet to these files.

(Why copy?  The ramster tmem.c/tmem.h changes are definitely shareable
between zcache and ramster; the eventual destination for tmem.c
is the linux lib directory.  Ramster changes to zcache are more substantial
and zcache is currently undergoing some significant unrelated changes
(including a new allocator and breaking zcache-main.c into smaller files),
so it seemed best to branch temporarily and merge later.)

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
---
 drivers/staging/ramster/Kconfig       |   13 +
 drivers/staging/ramster/Makefile      |    3 +
 drivers/staging/ramster/tmem.c        |  770 +++++++++++++
 drivers/staging/ramster/tmem.h        |  206 ++++
 drivers/staging/ramster/zcache-main.c | 1988 +++++++++++++++++++++++++++++++++
 5 files changed, 2980 insertions(+), 0 deletions(-)
 create mode 100644 drivers/staging/ramster/Kconfig
 create mode 100644 drivers/staging/ramster/Makefile
 create mode 100644 drivers/staging/ramster/tmem.c
 create mode 100644 drivers/staging/ramster/tmem.h
 create mode 100644 drivers/staging/ramster/zcache-main.c

diff --git a/drivers/staging/ramster/Kconfig b/drivers/staging/ramster/Kconfig
new file mode 100644
index 0000000..7fabcb2
--- /dev/null
+++ b/drivers/staging/ramster/Kconfig
@@ -0,0 +1,13 @@
+config ZCACHE
+	tristate "Dynamic compression of swap pages and clean pagecache pages"
+	depends on CLEANCACHE || FRONTSWAP
+	select XVMALLOC
+	select LZO_COMPRESS
+	select LZO_DECOMPRESS
+	default n
+	help
+	  Zcache doubles RAM efficiency while providing a significant
+	  performance boosts on many workloads.  Zcache uses lzo1x
+	  compression and an in-kernel implementation of transcendent
+	  memory to store clean page cache pages and swap in RAM,
+	  providing a noticeable reduction in disk I/O.
diff --git a/drivers/staging/ramster/Makefile b/drivers/staging/ramster/Makefile
new file mode 100644
index 0000000..60daa27
--- /dev/null
+++ b/drivers/staging/ramster/Makefile
@@ -0,0 +1,3 @@
+zcache-y	:=	zcache-main.o tmem.o
+
+obj-$(CONFIG_ZCACHE)	+=	zcache.o
diff --git a/drivers/staging/ramster/tmem.c b/drivers/staging/ramster/tmem.c
new file mode 100644
index 0000000..1ca66ea
--- /dev/null
+++ b/drivers/staging/ramster/tmem.c
@@ -0,0 +1,770 @@
+/*
+ * In-kernel transcendent memory (generic implementation)
+ *
+ * Copyright (c) 2009-2011, Dan Magenheimer, Oracle Corp.
+ *
+ * The primary purpose of Transcedent Memory ("tmem") is to map object-oriented
+ * "handles" (triples containing a pool id, and object id, and an index), to
+ * pages in a page-accessible memory (PAM).  Tmem references the PAM pages via
+ * an abstract "pampd" (PAM page-descriptor), which can be operated on by a
+ * set of functions (pamops).  Each pampd contains some representation of
+ * PAGE_SIZE bytes worth of data. Tmem must support potentially millions of
+ * pages and must be able to insert, find, and delete these pages at a
+ * potential frequency of thousands per second concurrently across many CPUs,
+ * (and, if used with KVM, across many vcpus across many guests).
+ * Tmem is tracked with a hierarchy of data structures, organized by
+ * the elements in a handle-tuple: pool_id, object_id, and page index.
+ * One or more "clients" (e.g. guests) each provide one or more tmem_pools.
+ * Each pool, contains a hash table of rb_trees of tmem_objs.  Each
+ * tmem_obj contains a radix-tree-like tree of pointers, with intermediate
+ * nodes called tmem_objnodes.  Each leaf pointer in this tree points to
+ * a pampd, which is accessible only through a small set of callbacks
+ * registered by the PAM implementation (see tmem_register_pamops). Tmem
+ * does all memory allocation via a set of callbacks registered by the tmem
+ * host implementation (e.g. see tmem_register_hostops).
+ */
+
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/atomic.h>
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
+ * callbacks for a page-accessible memory (PAM) implementation
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
+ * Each hashbucket also has a lock to manage concurrent access.
+ *
+ * The following routines manage tmem_objs.  When any tmem_obj is accessed,
+ * the hashbucket lock must be held.
+ */
+
+/* searches for object==oid in pool, returns locked object if found */
+static struct tmem_obj *tmem_obj_find(struct tmem_hashbucket *hb,
+					struct tmem_oid *oidp)
+{
+	struct rb_node *rbnode;
+	struct tmem_obj *obj;
+
+	rbnode = hb->obj_rb_root.rb_node;
+	while (rbnode) {
+		BUG_ON(RB_EMPTY_NODE(rbnode));
+		obj = rb_entry(rbnode, struct tmem_obj, rb_tree_node);
+		switch (tmem_oid_compare(oidp, &obj->oid)) {
+		case 0: /* equal */
+			goto out;
+		case -1:
+			rbnode = rbnode->rb_left;
+			break;
+		case 1:
+			rbnode = rbnode->rb_right;
+			break;
+		}
+	}
+	obj = NULL;
+out:
+	return obj;
+}
+
+static void tmem_pampd_destroy_all_in_obj(struct tmem_obj *);
+
+/* free an object that has no more pampds in it */
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
+		tmem_pampd_destroy_all_in_obj(obj);
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
+ * initialize, and insert an tmem_object_root (called only if find failed)
+ */
+static void tmem_obj_init(struct tmem_obj *obj, struct tmem_hashbucket *hb,
+					struct tmem_pool *pool,
+					struct tmem_oid *oidp)
+{
+	struct rb_root *root = &hb->obj_rb_root;
+	struct rb_node **new = &(root->rb_node), *parent = NULL;
+	struct tmem_obj *this;
+
+	BUG_ON(pool == NULL);
+	atomic_inc(&pool->obj_count);
+	obj->objnode_tree_height = 0;
+	obj->objnode_tree_root = NULL;
+	obj->pool = pool;
+	obj->oid = *oidp;
+	obj->objnode_count = 0;
+	obj->pampd_count = 0;
+	(*tmem_pamops.new_obj)(obj);
+	SET_SENTINEL(obj, OBJ);
+	while (*new) {
+		BUG_ON(RB_EMPTY_NODE(*new));
+		this = rb_entry(*new, struct tmem_obj, rb_tree_node);
+		parent = *new;
+		switch (tmem_oid_compare(oidp, &this->oid)) {
+		case 0:
+			BUG(); /* already present; should never happen! */
+			break;
+		case -1:
+			new = &(*new)->rb_left;
+			break;
+		case 1:
+			new = &(*new)->rb_right;
+			break;
+		}
+	}
+	rb_link_node(&obj->rb_tree_node, parent, new);
+	rb_insert_color(&obj->rb_tree_node, root);
+}
+
+/*
+ * Tmem is managed as a set of tmem_pools with certain attributes, such as
+ * "ephemeral" vs "persistent".  These attributes apply to all tmem_objs
+ * and all pampds that belong to a tmem_pool.  A tmem_pool is created
+ * or deleted relatively rarely (for example, when a filesystem is
+ * mounted or unmounted.
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
+			tmem_pampd_destroy_all_in_obj(obj);
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
+ * lookup index in object and return associated pampd (or NULL if not found)
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
+static void *tmem_pampd_replace_in_obj(struct tmem_obj *obj, uint32_t index,
+					void *new_pampd)
+{
+	struct tmem_objnode **slot;
+	void *ret = NULL;
+
+	slot = (struct tmem_objnode **)__tmem_pampd_lookup_in_obj(obj, index);
+	if ((slot != NULL) && (*slot != NULL)) {
+		void *old_pampd = *(void **)slot;
+		*(void **)slot = new_pampd;
+		(*tmem_pamops.free)(old_pampd, obj->pool, NULL, 0);
+		ret = new_pampd;
+	}
+	return ret;
+}
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
+/* recursively walk the objnode_tree destroying pampds and objnodes */
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
+						obj->pool, NULL, 0);
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
+static void tmem_pampd_destroy_all_in_obj(struct tmem_obj *obj)
+{
+	if (obj->objnode_tree_root == NULL)
+		return;
+	if (obj->objnode_tree_height == 0) {
+		obj->pampd_count--;
+		(*tmem_pamops.free)(obj->objnode_tree_root, obj->pool, NULL, 0);
+	} else {
+		tmem_objnode_node_destroy(obj, obj->objnode_tree_root,
+					obj->objnode_tree_height);
+		tmem_objnode_free(obj->objnode_tree_root);
+		obj->objnode_tree_height = 0;
+	}
+	obj->objnode_tree_root = NULL;
+	(*tmem_pamops.free_obj)(obj->pool, obj);
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
+ * "Put" a page, e.g. copy a page from the kernel into newly allocated
+ * PAM space (if such space is available).  Tmem_put is complicated by
+ * a corner case: What if a page with matching handle already exists in
+ * tmem?  To guarantee coherency, one of two actions is necessary: Either
+ * the data for the page must be overwritten, or the page must be
+ * "flushed" so that the data is not accessible to a subsequent "get".
+ * Since these "duplicate puts" are relatively rare, this implementation
+ * always flushes for simplicity.
+ */
+int tmem_put(struct tmem_pool *pool, struct tmem_oid *oidp, uint32_t index,
+		char *data, size_t size, bool raw, bool ephemeral)
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
+			(*tmem_pamops.free)(pampd, pool, oidp, index);
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
+	pampd = (*tmem_pamops.create)(data, size, raw, ephemeral,
+					obj->pool, &obj->oid, index);
+	if (unlikely(pampd == NULL))
+		goto free;
+	ret = tmem_pampd_add_to_obj(obj, index, pampd);
+	if (unlikely(ret == -ENOMEM))
+		/* may have partially built objnode tree ("stump") */
+		goto delete_and_free;
+	goto out;
+
+delete_and_free:
+	(void)tmem_pampd_delete_from_obj(obj, index);
+free:
+	if (pampd)
+		(*tmem_pamops.free)(pampd, pool, NULL, 0);
+	if (objnew) {
+		tmem_obj_free(objnew, hb);
+		(*tmem_hostops.obj_free)(objnew, pool);
+	}
+out:
+	spin_unlock(&hb->lock);
+	return ret;
+}
+
+/*
+ * "Get" a page, e.g. if one can be found, copy the tmem page with the
+ * matching handle from PAM space to the kernel.  By tmem definition,
+ * when a "get" is successful on an ephemeral page, the page is "flushed",
+ * and when a "get" is successful on a persistent page, the page is retained
+ * in tmem.  Note that to preserve
+ * coherency, "get" can never be skipped if tmem contains the data.
+ * That is, if a get is done with a certain handle and fails, any
+ * subsequent "get" must also fail (unless of course there is a
+ * "put" done with the same handle).
+
+ */
+int tmem_get(struct tmem_pool *pool, struct tmem_oid *oidp, uint32_t index,
+		char *data, size_t *size, bool raw, int get_and_free)
+{
+	struct tmem_obj *obj;
+	void *pampd;
+	bool ephemeral = is_ephemeral(pool);
+	int ret = -1;
+	struct tmem_hashbucket *hb;
+	bool free = (get_and_free == 1) || ((get_and_free == 0) && ephemeral);
+	bool lock_held = false;
+
+	hb = &pool->hashbucket[tmem_oid_hash(oidp)];
+	spin_lock(&hb->lock);
+	lock_held = true;
+	obj = tmem_obj_find(hb, oidp);
+	if (obj == NULL)
+		goto out;
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
+	if (tmem_pamops.is_remote(pampd)) {
+		lock_held = false;
+		spin_unlock(&hb->lock);
+	}
+	if (free)
+		ret = (*tmem_pamops.get_data_and_free)(
+				data, size, raw, pampd, pool, oidp, index);
+	else
+		ret = (*tmem_pamops.get_data)(
+				data, size, raw, pampd, pool, oidp, index);
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
+	(*tmem_pamops.free)(pampd, pool, oidp, index);
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
+ * If a page in tmem matches the handle, replace the page so that any
+ * subsequent "get" gets the new page.  Returns 0 if
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
+	new_pampd = tmem_pampd_replace_in_obj(obj, index, new_pampd);
+	ret = (*tmem_pamops.replace_in_obj)(new_pampd, obj);
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
+	tmem_pampd_destroy_all_in_obj(obj);
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
diff --git a/drivers/staging/ramster/tmem.h b/drivers/staging/ramster/tmem.h
new file mode 100644
index 0000000..ed147c4
--- /dev/null
+++ b/drivers/staging/ramster/tmem.h
@@ -0,0 +1,206 @@
+/*
+ * tmem.h
+ *
+ * Transcendent memory
+ *
+ * Copyright (c) 2009-2011, Dan Magenheimer, Oracle Corp.
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
+ * These are pre-defined by the Xen<->Linux ABI
+ */
+#define TMEM_PUT_PAGE			4
+#define TMEM_GET_PAGE			5
+#define TMEM_FLUSH_PAGE			6
+#define TMEM_FLUSH_OBJECT		7
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
+#define SENTINELS
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
+#define ASSERT_SPINLOCK(_l)	WARN_ON(!spin_is_locked(_l))
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
+	void *extra; /* for private use by pampd implementation */
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
+/* pampd abstract datatype methods provided by the PAM implementation */
+struct tmem_pamops {
+	void *(*create)(char *, size_t, bool, int,
+			struct tmem_pool *, struct tmem_oid *, uint32_t);
+	int (*get_data)(char *, size_t *, bool, void *, struct tmem_pool *,
+				struct tmem_oid *, uint32_t);
+	int (*get_data_and_free)(char *, size_t *, bool, void *,
+				struct tmem_pool *, struct tmem_oid *,
+				uint32_t);
+	void (*free)(void *, struct tmem_pool *, struct tmem_oid *, uint32_t);
+	void (*free_obj)(struct tmem_pool *, struct tmem_obj *);
+	bool (*is_remote)(void *);
+	void (*new_obj)(struct tmem_obj *);
+	int (*replace_in_obj)(void *, struct tmem_obj *);
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
+			char *, size_t, bool, bool);
+extern int tmem_get(struct tmem_pool *, struct tmem_oid *, uint32_t index,
+			char *, size_t *, bool, int);
+extern int tmem_replace(struct tmem_pool *, struct tmem_oid *, uint32_t index,
+			void *);
+extern int tmem_flush_page(struct tmem_pool *, struct tmem_oid *,
+			uint32_t index);
+extern int tmem_flush_object(struct tmem_pool *, struct tmem_oid *);
+extern int tmem_destroy_pool(struct tmem_pool *);
+extern void tmem_new_pool(struct tmem_pool *, uint32_t);
+#endif /* _TMEM_H */
diff --git a/drivers/staging/ramster/zcache-main.c b/drivers/staging/ramster/zcache-main.c
new file mode 100644
index 0000000..49c8791
--- /dev/null
+++ b/drivers/staging/ramster/zcache-main.c
@@ -0,0 +1,1988 @@
+/*
+ * zcache.c
+ *
+ * Copyright (c) 2010,2011, Dan Magenheimer, Oracle Corp.
+ * Copyright (c) 2010,2011, Nitin Gupta
+ *
+ * Zcache provides an in-kernel "host implementation" for transcendent memory
+ * and, thus indirectly, for cleancache and frontswap.  Zcache includes two
+ * page-accessible memory [1] interfaces, both utilizing lzo1x compression:
+ * 1) "compression buddies" ("zbud") is used for ephemeral pages
+ * 2) xvmalloc is used for persistent pages.
+ * Xvmalloc (based on the TLSF allocator) has very low fragmentation
+ * so maximizes space efficiency, while zbud allows pairs (and potentially,
+ * in the future, more than a pair of) compressed pages to be closely linked
+ * so that reclaiming can be done via the kernel's physical-page-oriented
+ * "shrinker" interface.
+ *
+ * [1] For a definition of page-accessible memory (aka PAM), see:
+ *   http://marc.info/?l=linux-mm&m=127811271605009
+ */
+
+#include <linux/module.h>
+#include <linux/cpu.h>
+#include <linux/highmem.h>
+#include <linux/list.h>
+#include <linux/lzo.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/types.h>
+#include <linux/atomic.h>
+#include <linux/math64.h>
+#include "tmem.h"
+
+#include "../zram/xvmalloc.h" /* if built in drivers/staging */
+
+#if (!defined(CONFIG_CLEANCACHE) && !defined(CONFIG_FRONTSWAP))
+#error "zcache is useless without CONFIG_CLEANCACHE or CONFIG_FRONTSWAP"
+#endif
+#ifdef CONFIG_CLEANCACHE
+#include <linux/cleancache.h>
+#endif
+#ifdef CONFIG_FRONTSWAP
+#include <linux/frontswap.h>
+#endif
+
+#if 0
+/* this is more aggressive but may cause other problems? */
+#define ZCACHE_GFP_MASK	(GFP_ATOMIC | __GFP_NORETRY | __GFP_NOWARN)
+#else
+#define ZCACHE_GFP_MASK \
+	(__GFP_FS | __GFP_NORETRY | __GFP_NOWARN | __GFP_NOMEMALLOC)
+#endif
+
+#define MAX_POOLS_PER_CLIENT 16
+
+#define MAX_CLIENTS 16
+#define LOCAL_CLIENT ((uint16_t)-1)
+
+MODULE_LICENSE("GPL");
+
+struct zcache_client {
+	struct tmem_pool *tmem_pools[MAX_POOLS_PER_CLIENT];
+	struct xv_pool *xvpool;
+	bool allocated;
+	atomic_t refcount;
+};
+
+static struct zcache_client zcache_host;
+static struct zcache_client zcache_clients[MAX_CLIENTS];
+
+static inline uint16_t get_client_id_from_client(struct zcache_client *cli)
+{
+	BUG_ON(cli == NULL);
+	if (cli == &zcache_host)
+		return LOCAL_CLIENT;
+	return cli - &zcache_clients[0];
+}
+
+static inline bool is_local_client(struct zcache_client *cli)
+{
+	return cli == &zcache_host;
+}
+
+/**********
+ * Compression buddies ("zbud") provides for packing two (or, possibly
+ * in the future, more) compressed ephemeral pages into a single "raw"
+ * (physical) page and tracking them with data structures so that
+ * the raw pages can be easily reclaimed.
+ *
+ * A zbud page ("zbpg") is an aligned page containing a list_head,
+ * a lock, and two "zbud headers".  The remainder of the physical
+ * page is divided up into aligned 64-byte "chunks" which contain
+ * the compressed data for zero, one, or two zbuds.  Each zbpg
+ * resides on: (1) an "unused list" if it has no zbuds; (2) a
+ * "buddied" list if it is fully populated  with two zbuds; or
+ * (3) one of PAGE_SIZE/64 "unbuddied" lists indexed by how many chunks
+ * the one unbuddied zbud uses.  The data inside a zbpg cannot be
+ * read or written unless the zbpg's lock is held.
+ */
+
+#define ZBH_SENTINEL  0x43214321
+#define ZBPG_SENTINEL  0xdeadbeef
+
+#define ZBUD_MAX_BUDS 2
+
+struct zbud_hdr {
+	uint16_t client_id;
+	uint16_t pool_id;
+	struct tmem_oid oid;
+	uint32_t index;
+	uint16_t size; /* compressed size in bytes, zero means unused */
+	DECL_SENTINEL
+};
+
+struct zbud_page {
+	struct list_head bud_list;
+	spinlock_t lock;
+	struct zbud_hdr buddy[ZBUD_MAX_BUDS];
+	DECL_SENTINEL
+	/* followed by NUM_CHUNK aligned CHUNK_SIZE-byte chunks */
+};
+
+#define CHUNK_SHIFT	6
+#define CHUNK_SIZE	(1 << CHUNK_SHIFT)
+#define CHUNK_MASK	(~(CHUNK_SIZE-1))
+#define NCHUNKS		(((PAGE_SIZE - sizeof(struct zbud_page)) & \
+				CHUNK_MASK) >> CHUNK_SHIFT)
+#define MAX_CHUNK	(NCHUNKS-1)
+
+static struct {
+	struct list_head list;
+	unsigned count;
+} zbud_unbuddied[NCHUNKS];
+/* list N contains pages with N chunks USED and NCHUNKS-N unused */
+/* element 0 is never used but optimizing that isn't worth it */
+static unsigned long zbud_cumul_chunk_counts[NCHUNKS];
+
+struct list_head zbud_buddied_list;
+static unsigned long zcache_zbud_buddied_count;
+
+/* protects the buddied list and all unbuddied lists */
+static DEFINE_SPINLOCK(zbud_budlists_spinlock);
+
+static LIST_HEAD(zbpg_unused_list);
+static unsigned long zcache_zbpg_unused_list_count;
+
+/* protects the unused page list */
+static DEFINE_SPINLOCK(zbpg_unused_list_spinlock);
+
+static atomic_t zcache_zbud_curr_raw_pages;
+static atomic_t zcache_zbud_curr_zpages;
+static unsigned long zcache_zbud_curr_zbytes;
+static unsigned long zcache_zbud_cumul_zpages;
+static unsigned long zcache_zbud_cumul_zbytes;
+static unsigned long zcache_compress_poor;
+static unsigned long zcache_mean_compress_poor;
+
+/* forward references */
+static void *zcache_get_free_page(void);
+static void zcache_free_page(void *p);
+
+/*
+ * zbud helper functions
+ */
+
+static inline unsigned zbud_max_buddy_size(void)
+{
+	return MAX_CHUNK << CHUNK_SHIFT;
+}
+
+static inline unsigned zbud_size_to_chunks(unsigned size)
+{
+	BUG_ON(size == 0 || size > zbud_max_buddy_size());
+	return (size + CHUNK_SIZE - 1) >> CHUNK_SHIFT;
+}
+
+static inline int zbud_budnum(struct zbud_hdr *zh)
+{
+	unsigned offset = (unsigned long)zh & (PAGE_SIZE - 1);
+	struct zbud_page *zbpg = NULL;
+	unsigned budnum = -1U;
+	int i;
+
+	for (i = 0; i < ZBUD_MAX_BUDS; i++)
+		if (offset == offsetof(typeof(*zbpg), buddy[i])) {
+			budnum = i;
+			break;
+		}
+	BUG_ON(budnum == -1U);
+	return budnum;
+}
+
+static char *zbud_data(struct zbud_hdr *zh, unsigned size)
+{
+	struct zbud_page *zbpg;
+	char *p;
+	unsigned budnum;
+
+	ASSERT_SENTINEL(zh, ZBH);
+	budnum = zbud_budnum(zh);
+	BUG_ON(size == 0 || size > zbud_max_buddy_size());
+	zbpg = container_of(zh, struct zbud_page, buddy[budnum]);
+	ASSERT_SPINLOCK(&zbpg->lock);
+	p = (char *)zbpg;
+	if (budnum == 0)
+		p += ((sizeof(struct zbud_page) + CHUNK_SIZE - 1) &
+							CHUNK_MASK);
+	else if (budnum == 1)
+		p += PAGE_SIZE - ((size + CHUNK_SIZE - 1) & CHUNK_MASK);
+	return p;
+}
+
+/*
+ * zbud raw page management
+ */
+
+static struct zbud_page *zbud_alloc_raw_page(void)
+{
+	struct zbud_page *zbpg = NULL;
+	struct zbud_hdr *zh0, *zh1;
+	bool recycled = 0;
+
+	/* if any pages on the zbpg list, use one */
+	spin_lock(&zbpg_unused_list_spinlock);
+	if (!list_empty(&zbpg_unused_list)) {
+		zbpg = list_first_entry(&zbpg_unused_list,
+				struct zbud_page, bud_list);
+		list_del_init(&zbpg->bud_list);
+		zcache_zbpg_unused_list_count--;
+		recycled = 1;
+	}
+	spin_unlock(&zbpg_unused_list_spinlock);
+	if (zbpg == NULL)
+		/* none on zbpg list, try to get a kernel page */
+		zbpg = zcache_get_free_page();
+	if (likely(zbpg != NULL)) {
+		INIT_LIST_HEAD(&zbpg->bud_list);
+		zh0 = &zbpg->buddy[0]; zh1 = &zbpg->buddy[1];
+		spin_lock_init(&zbpg->lock);
+		if (recycled) {
+			ASSERT_INVERTED_SENTINEL(zbpg, ZBPG);
+			SET_SENTINEL(zbpg, ZBPG);
+			BUG_ON(zh0->size != 0 || tmem_oid_valid(&zh0->oid));
+			BUG_ON(zh1->size != 0 || tmem_oid_valid(&zh1->oid));
+		} else {
+			atomic_inc(&zcache_zbud_curr_raw_pages);
+			INIT_LIST_HEAD(&zbpg->bud_list);
+			SET_SENTINEL(zbpg, ZBPG);
+			zh0->size = 0; zh1->size = 0;
+			tmem_oid_set_invalid(&zh0->oid);
+			tmem_oid_set_invalid(&zh1->oid);
+		}
+	}
+	return zbpg;
+}
+
+static void zbud_free_raw_page(struct zbud_page *zbpg)
+{
+	struct zbud_hdr *zh0 = &zbpg->buddy[0], *zh1 = &zbpg->buddy[1];
+
+	ASSERT_SENTINEL(zbpg, ZBPG);
+	BUG_ON(!list_empty(&zbpg->bud_list));
+	ASSERT_SPINLOCK(&zbpg->lock);
+	BUG_ON(zh0->size != 0 || tmem_oid_valid(&zh0->oid));
+	BUG_ON(zh1->size != 0 || tmem_oid_valid(&zh1->oid));
+	INVERT_SENTINEL(zbpg, ZBPG);
+	spin_unlock(&zbpg->lock);
+	spin_lock(&zbpg_unused_list_spinlock);
+	list_add(&zbpg->bud_list, &zbpg_unused_list);
+	zcache_zbpg_unused_list_count++;
+	spin_unlock(&zbpg_unused_list_spinlock);
+}
+
+/*
+ * core zbud handling routines
+ */
+
+static unsigned zbud_free(struct zbud_hdr *zh)
+{
+	unsigned size;
+
+	ASSERT_SENTINEL(zh, ZBH);
+	BUG_ON(!tmem_oid_valid(&zh->oid));
+	size = zh->size;
+	BUG_ON(zh->size == 0 || zh->size > zbud_max_buddy_size());
+	zh->size = 0;
+	tmem_oid_set_invalid(&zh->oid);
+	INVERT_SENTINEL(zh, ZBH);
+	zcache_zbud_curr_zbytes -= size;
+	atomic_dec(&zcache_zbud_curr_zpages);
+	return size;
+}
+
+static void zbud_free_and_delist(struct zbud_hdr *zh)
+{
+	unsigned chunks;
+	struct zbud_hdr *zh_other;
+	unsigned budnum = zbud_budnum(zh), size;
+	struct zbud_page *zbpg =
+		container_of(zh, struct zbud_page, buddy[budnum]);
+
+	spin_lock(&zbpg->lock);
+	if (list_empty(&zbpg->bud_list)) {
+		/* ignore zombie page... see zbud_evict_pages() */
+		spin_unlock(&zbpg->lock);
+		return;
+	}
+	size = zbud_free(zh);
+	ASSERT_SPINLOCK(&zbpg->lock);
+	zh_other = &zbpg->buddy[(budnum == 0) ? 1 : 0];
+	if (zh_other->size == 0) { /* was unbuddied: unlist and free */
+		chunks = zbud_size_to_chunks(size) ;
+		spin_lock(&zbud_budlists_spinlock);
+		BUG_ON(list_empty(&zbud_unbuddied[chunks].list));
+		list_del_init(&zbpg->bud_list);
+		zbud_unbuddied[chunks].count--;
+		spin_unlock(&zbud_budlists_spinlock);
+		zbud_free_raw_page(zbpg);
+	} else { /* was buddied: move remaining buddy to unbuddied list */
+		chunks = zbud_size_to_chunks(zh_other->size) ;
+		spin_lock(&zbud_budlists_spinlock);
+		list_del_init(&zbpg->bud_list);
+		zcache_zbud_buddied_count--;
+		list_add_tail(&zbpg->bud_list, &zbud_unbuddied[chunks].list);
+		zbud_unbuddied[chunks].count++;
+		spin_unlock(&zbud_budlists_spinlock);
+		spin_unlock(&zbpg->lock);
+	}
+}
+
+static struct zbud_hdr *zbud_create(uint16_t client_id, uint16_t pool_id,
+					struct tmem_oid *oid,
+					uint32_t index, struct page *page,
+					void *cdata, unsigned size)
+{
+	struct zbud_hdr *zh0, *zh1, *zh = NULL;
+	struct zbud_page *zbpg = NULL, *ztmp;
+	unsigned nchunks;
+	char *to;
+	int i, found_good_buddy = 0;
+
+	nchunks = zbud_size_to_chunks(size) ;
+	for (i = MAX_CHUNK - nchunks + 1; i > 0; i--) {
+		spin_lock(&zbud_budlists_spinlock);
+		if (!list_empty(&zbud_unbuddied[i].list)) {
+			list_for_each_entry_safe(zbpg, ztmp,
+				    &zbud_unbuddied[i].list, bud_list) {
+				if (spin_trylock(&zbpg->lock)) {
+					found_good_buddy = i;
+					goto found_unbuddied;
+				}
+			}
+		}
+		spin_unlock(&zbud_budlists_spinlock);
+	}
+	/* didn't find a good buddy, try allocating a new page */
+	zbpg = zbud_alloc_raw_page();
+	if (unlikely(zbpg == NULL))
+		goto out;
+	/* ok, have a page, now compress the data before taking locks */
+	spin_lock(&zbpg->lock);
+	spin_lock(&zbud_budlists_spinlock);
+	list_add_tail(&zbpg->bud_list, &zbud_unbuddied[nchunks].list);
+	zbud_unbuddied[nchunks].count++;
+	zh = &zbpg->buddy[0];
+	goto init_zh;
+
+found_unbuddied:
+	ASSERT_SPINLOCK(&zbpg->lock);
+	zh0 = &zbpg->buddy[0]; zh1 = &zbpg->buddy[1];
+	BUG_ON(!((zh0->size == 0) ^ (zh1->size == 0)));
+	if (zh0->size != 0) { /* buddy0 in use, buddy1 is vacant */
+		ASSERT_SENTINEL(zh0, ZBH);
+		zh = zh1;
+	} else if (zh1->size != 0) { /* buddy1 in use, buddy0 is vacant */
+		ASSERT_SENTINEL(zh1, ZBH);
+		zh = zh0;
+	} else
+		BUG();
+	list_del_init(&zbpg->bud_list);
+	zbud_unbuddied[found_good_buddy].count--;
+	list_add_tail(&zbpg->bud_list, &zbud_buddied_list);
+	zcache_zbud_buddied_count++;
+
+init_zh:
+	SET_SENTINEL(zh, ZBH);
+	zh->size = size;
+	zh->index = index;
+	zh->oid = *oid;
+	zh->pool_id = pool_id;
+	zh->client_id = client_id;
+	/* can wait to copy the data until the list locks are dropped */
+	spin_unlock(&zbud_budlists_spinlock);
+
+	to = zbud_data(zh, size);
+	memcpy(to, cdata, size);
+	spin_unlock(&zbpg->lock);
+	zbud_cumul_chunk_counts[nchunks]++;
+	atomic_inc(&zcache_zbud_curr_zpages);
+	zcache_zbud_cumul_zpages++;
+	zcache_zbud_curr_zbytes += size;
+	zcache_zbud_cumul_zbytes += size;
+out:
+	return zh;
+}
+
+static int zbud_decompress(struct page *page, struct zbud_hdr *zh)
+{
+	struct zbud_page *zbpg;
+	unsigned budnum = zbud_budnum(zh);
+	size_t out_len = PAGE_SIZE;
+	char *to_va, *from_va;
+	unsigned size;
+	int ret = 0;
+
+	zbpg = container_of(zh, struct zbud_page, buddy[budnum]);
+	spin_lock(&zbpg->lock);
+	if (list_empty(&zbpg->bud_list)) {
+		/* ignore zombie page... see zbud_evict_pages() */
+		ret = -EINVAL;
+		goto out;
+	}
+	ASSERT_SENTINEL(zh, ZBH);
+	BUG_ON(zh->size == 0 || zh->size > zbud_max_buddy_size());
+	to_va = kmap_atomic(page, KM_USER0);
+	size = zh->size;
+	from_va = zbud_data(zh, size);
+	ret = lzo1x_decompress_safe(from_va, size, to_va, &out_len);
+	BUG_ON(ret != LZO_E_OK);
+	BUG_ON(out_len != PAGE_SIZE);
+	kunmap_atomic(to_va, KM_USER0);
+out:
+	spin_unlock(&zbpg->lock);
+	return ret;
+}
+
+/*
+ * The following routines handle shrinking of ephemeral pages by evicting
+ * pages "least valuable" first.
+ */
+
+static unsigned long zcache_evicted_raw_pages;
+static unsigned long zcache_evicted_buddied_pages;
+static unsigned long zcache_evicted_unbuddied_pages;
+
+static struct tmem_pool *zcache_get_pool_by_id(uint16_t cli_id,
+						uint16_t poolid);
+static void zcache_put_pool(struct tmem_pool *pool);
+
+/*
+ * Flush and free all zbuds in a zbpg, then free the pageframe
+ */
+static void zbud_evict_zbpg(struct zbud_page *zbpg)
+{
+	struct zbud_hdr *zh;
+	int i, j;
+	uint32_t pool_id[ZBUD_MAX_BUDS], client_id[ZBUD_MAX_BUDS];
+	uint32_t index[ZBUD_MAX_BUDS];
+	struct tmem_oid oid[ZBUD_MAX_BUDS];
+	struct tmem_pool *pool;
+
+	ASSERT_SPINLOCK(&zbpg->lock);
+	BUG_ON(!list_empty(&zbpg->bud_list));
+	for (i = 0, j = 0; i < ZBUD_MAX_BUDS; i++) {
+		zh = &zbpg->buddy[i];
+		if (zh->size) {
+			client_id[j] = zh->client_id;
+			pool_id[j] = zh->pool_id;
+			oid[j] = zh->oid;
+			index[j] = zh->index;
+			j++;
+			zbud_free(zh);
+		}
+	}
+	spin_unlock(&zbpg->lock);
+	for (i = 0; i < j; i++) {
+		pool = zcache_get_pool_by_id(client_id[i], pool_id[i]);
+		if (pool != NULL) {
+			tmem_flush_page(pool, &oid[i], index[i]);
+			zcache_put_pool(pool);
+		}
+	}
+	ASSERT_SENTINEL(zbpg, ZBPG);
+	spin_lock(&zbpg->lock);
+	zbud_free_raw_page(zbpg);
+}
+
+/*
+ * Free nr pages.  This code is funky because we want to hold the locks
+ * protecting various lists for as short a time as possible, and in some
+ * circumstances the list may change asynchronously when the list lock is
+ * not held.  In some cases we also trylock not only to avoid waiting on a
+ * page in use by another cpu, but also to avoid potential deadlock due to
+ * lock inversion.
+ */
+static void zbud_evict_pages(int nr)
+{
+	struct zbud_page *zbpg;
+	int i;
+
+	/* first try freeing any pages on unused list */
+retry_unused_list:
+	spin_lock_bh(&zbpg_unused_list_spinlock);
+	if (!list_empty(&zbpg_unused_list)) {
+		/* can't walk list here, since it may change when unlocked */
+		zbpg = list_first_entry(&zbpg_unused_list,
+				struct zbud_page, bud_list);
+		list_del_init(&zbpg->bud_list);
+		zcache_zbpg_unused_list_count--;
+		atomic_dec(&zcache_zbud_curr_raw_pages);
+		spin_unlock_bh(&zbpg_unused_list_spinlock);
+		zcache_free_page(zbpg);
+		zcache_evicted_raw_pages++;
+		if (--nr <= 0)
+			goto out;
+		goto retry_unused_list;
+	}
+	spin_unlock_bh(&zbpg_unused_list_spinlock);
+
+	/* now try freeing unbuddied pages, starting with least space avail */
+	for (i = 0; i < MAX_CHUNK; i++) {
+retry_unbud_list_i:
+		spin_lock_bh(&zbud_budlists_spinlock);
+		if (list_empty(&zbud_unbuddied[i].list)) {
+			spin_unlock_bh(&zbud_budlists_spinlock);
+			continue;
+		}
+		list_for_each_entry(zbpg, &zbud_unbuddied[i].list, bud_list) {
+			if (unlikely(!spin_trylock(&zbpg->lock)))
+				continue;
+			list_del_init(&zbpg->bud_list);
+			zbud_unbuddied[i].count--;
+			spin_unlock(&zbud_budlists_spinlock);
+			zcache_evicted_unbuddied_pages++;
+			/* want budlists unlocked when doing zbpg eviction */
+			zbud_evict_zbpg(zbpg);
+			local_bh_enable();
+			if (--nr <= 0)
+				goto out;
+			goto retry_unbud_list_i;
+		}
+		spin_unlock_bh(&zbud_budlists_spinlock);
+	}
+
+	/* as a last resort, free buddied pages */
+retry_bud_list:
+	spin_lock_bh(&zbud_budlists_spinlock);
+	if (list_empty(&zbud_buddied_list)) {
+		spin_unlock_bh(&zbud_budlists_spinlock);
+		goto out;
+	}
+	list_for_each_entry(zbpg, &zbud_buddied_list, bud_list) {
+		if (unlikely(!spin_trylock(&zbpg->lock)))
+			continue;
+		list_del_init(&zbpg->bud_list);
+		zcache_zbud_buddied_count--;
+		spin_unlock(&zbud_budlists_spinlock);
+		zcache_evicted_buddied_pages++;
+		/* want budlists unlocked when doing zbpg eviction */
+		zbud_evict_zbpg(zbpg);
+		local_bh_enable();
+		if (--nr <= 0)
+			goto out;
+		goto retry_bud_list;
+	}
+	spin_unlock_bh(&zbud_budlists_spinlock);
+out:
+	return;
+}
+
+static void zbud_init(void)
+{
+	int i;
+
+	INIT_LIST_HEAD(&zbud_buddied_list);
+	zcache_zbud_buddied_count = 0;
+	for (i = 0; i < NCHUNKS; i++) {
+		INIT_LIST_HEAD(&zbud_unbuddied[i].list);
+		zbud_unbuddied[i].count = 0;
+	}
+}
+
+#ifdef CONFIG_SYSFS
+/*
+ * These sysfs routines show a nice distribution of how many zbpg's are
+ * currently (and have ever been placed) in each unbuddied list.  It's fun
+ * to watch but can probably go away before final merge.
+ */
+static int zbud_show_unbuddied_list_counts(char *buf)
+{
+	int i;
+	char *p = buf;
+
+	for (i = 0; i < NCHUNKS; i++)
+		p += sprintf(p, "%u ", zbud_unbuddied[i].count);
+	return p - buf;
+}
+
+static int zbud_show_cumul_chunk_counts(char *buf)
+{
+	unsigned long i, chunks = 0, total_chunks = 0, sum_total_chunks = 0;
+	unsigned long total_chunks_lte_21 = 0, total_chunks_lte_32 = 0;
+	unsigned long total_chunks_lte_42 = 0;
+	char *p = buf;
+
+	for (i = 0; i < NCHUNKS; i++) {
+		p += sprintf(p, "%lu ", zbud_cumul_chunk_counts[i]);
+		chunks += zbud_cumul_chunk_counts[i];
+		total_chunks += zbud_cumul_chunk_counts[i];
+		sum_total_chunks += i * zbud_cumul_chunk_counts[i];
+		if (i == 21)
+			total_chunks_lte_21 = total_chunks;
+		if (i == 32)
+			total_chunks_lte_32 = total_chunks;
+		if (i == 42)
+			total_chunks_lte_42 = total_chunks;
+	}
+	p += sprintf(p, "<=21:%lu <=32:%lu <=42:%lu, mean:%lu\n",
+		total_chunks_lte_21, total_chunks_lte_32, total_chunks_lte_42,
+		chunks == 0 ? 0 : sum_total_chunks / chunks);
+	return p - buf;
+}
+#endif
+
+/**********
+ * This "zv" PAM implementation combines the TLSF-based xvMalloc
+ * with lzo1x compression to maximize the amount of data that can
+ * be packed into a physical page.
+ *
+ * Zv represents a PAM page with the index and object (plus a "size" value
+ * necessary for decompression) immediately preceding the compressed data.
+ */
+
+#define ZVH_SENTINEL  0x43214321
+
+struct zv_hdr {
+	uint32_t pool_id;
+	struct tmem_oid oid;
+	uint32_t index;
+	DECL_SENTINEL
+};
+
+/* rudimentary policy limits */
+/* total number of persistent pages may not exceed this percentage */
+static unsigned int zv_page_count_policy_percent = 75;
+/*
+ * byte count defining poor compression; pages with greater zsize will be
+ * rejected
+ */
+static unsigned int zv_max_zsize = (PAGE_SIZE / 8) * 7;
+/*
+ * byte count defining poor *mean* compression; pages with greater zsize
+ * will be rejected until sufficient better-compressed pages are accepted
+ * driving the mean below this threshold
+ */
+static unsigned int zv_max_mean_zsize = (PAGE_SIZE / 8) * 5;
+
+static unsigned long zv_curr_dist_counts[NCHUNKS];
+static unsigned long zv_cumul_dist_counts[NCHUNKS];
+
+static struct zv_hdr *zv_create(struct xv_pool *xvpool, uint32_t pool_id,
+				struct tmem_oid *oid, uint32_t index,
+				void *cdata, unsigned clen)
+{
+	struct page *page;
+	struct zv_hdr *zv = NULL;
+	uint32_t offset;
+	int alloc_size = clen + sizeof(struct zv_hdr);
+	int chunks = (alloc_size + (CHUNK_SIZE - 1)) >> CHUNK_SHIFT;
+	int ret;
+
+	BUG_ON(!irqs_disabled());
+	BUG_ON(chunks >= NCHUNKS);
+	ret = xv_malloc(xvpool, alloc_size,
+			&page, &offset, ZCACHE_GFP_MASK);
+	if (unlikely(ret))
+		goto out;
+	zv_curr_dist_counts[chunks]++;
+	zv_cumul_dist_counts[chunks]++;
+	zv = kmap_atomic(page, KM_USER0) + offset;
+	zv->index = index;
+	zv->oid = *oid;
+	zv->pool_id = pool_id;
+	SET_SENTINEL(zv, ZVH);
+	memcpy((char *)zv + sizeof(struct zv_hdr), cdata, clen);
+	kunmap_atomic(zv, KM_USER0);
+out:
+	return zv;
+}
+
+static void zv_free(struct xv_pool *xvpool, struct zv_hdr *zv)
+{
+	unsigned long flags;
+	struct page *page;
+	uint32_t offset;
+	uint16_t size = xv_get_object_size(zv);
+	int chunks = (size + (CHUNK_SIZE - 1)) >> CHUNK_SHIFT;
+
+	ASSERT_SENTINEL(zv, ZVH);
+	BUG_ON(chunks >= NCHUNKS);
+	zv_curr_dist_counts[chunks]--;
+	size -= sizeof(*zv);
+	BUG_ON(size == 0);
+	INVERT_SENTINEL(zv, ZVH);
+	page = virt_to_page(zv);
+	offset = (unsigned long)zv & ~PAGE_MASK;
+	local_irq_save(flags);
+	xv_free(xvpool, page, offset);
+	local_irq_restore(flags);
+}
+
+static void zv_decompress(struct page *page, struct zv_hdr *zv)
+{
+	size_t clen = PAGE_SIZE;
+	char *to_va;
+	unsigned size;
+	int ret;
+
+	ASSERT_SENTINEL(zv, ZVH);
+	size = xv_get_object_size(zv) - sizeof(*zv);
+	BUG_ON(size == 0);
+	to_va = kmap_atomic(page, KM_USER0);
+	ret = lzo1x_decompress_safe((char *)zv + sizeof(*zv),
+					size, to_va, &clen);
+	kunmap_atomic(to_va, KM_USER0);
+	BUG_ON(ret != LZO_E_OK);
+	BUG_ON(clen != PAGE_SIZE);
+}
+
+#ifdef CONFIG_SYSFS
+/*
+ * show a distribution of compression stats for zv pages.
+ */
+
+static int zv_curr_dist_counts_show(char *buf)
+{
+	unsigned long i, n, chunks = 0, sum_total_chunks = 0;
+	char *p = buf;
+
+	for (i = 0; i < NCHUNKS; i++) {
+		n = zv_curr_dist_counts[i];
+		p += sprintf(p, "%lu ", n);
+		chunks += n;
+		sum_total_chunks += i * n;
+	}
+	p += sprintf(p, "mean:%lu\n",
+		chunks == 0 ? 0 : sum_total_chunks / chunks);
+	return p - buf;
+}
+
+static int zv_cumul_dist_counts_show(char *buf)
+{
+	unsigned long i, n, chunks = 0, sum_total_chunks = 0;
+	char *p = buf;
+
+	for (i = 0; i < NCHUNKS; i++) {
+		n = zv_cumul_dist_counts[i];
+		p += sprintf(p, "%lu ", n);
+		chunks += n;
+		sum_total_chunks += i * n;
+	}
+	p += sprintf(p, "mean:%lu\n",
+		chunks == 0 ? 0 : sum_total_chunks / chunks);
+	return p - buf;
+}
+
+/*
+ * setting zv_max_zsize via sysfs causes all persistent (e.g. swap)
+ * pages that don't compress to less than this value (including metadata
+ * overhead) to be rejected.  We don't allow the value to get too close
+ * to PAGE_SIZE.
+ */
+static ssize_t zv_max_zsize_show(struct kobject *kobj,
+				    struct kobj_attribute *attr,
+				    char *buf)
+{
+	return sprintf(buf, "%u\n", zv_max_zsize);
+}
+
+static ssize_t zv_max_zsize_store(struct kobject *kobj,
+				    struct kobj_attribute *attr,
+				    const char *buf, size_t count)
+{
+	unsigned long val;
+	int err;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	err = strict_strtoul(buf, 10, &val);
+	if (err || (val == 0) || (val > (PAGE_SIZE / 8) * 7))
+		return -EINVAL;
+	zv_max_zsize = val;
+	return count;
+}
+
+/*
+ * setting zv_max_mean_zsize via sysfs causes all persistent (e.g. swap)
+ * pages that don't compress to less than this value (including metadata
+ * overhead) to be rejected UNLESS the mean compression is also smaller
+ * than this value.  In other words, we are load-balancing-by-zsize the
+ * accepted pages.  Again, we don't allow the value to get too close
+ * to PAGE_SIZE.
+ */
+static ssize_t zv_max_mean_zsize_show(struct kobject *kobj,
+				    struct kobj_attribute *attr,
+				    char *buf)
+{
+	return sprintf(buf, "%u\n", zv_max_mean_zsize);
+}
+
+static ssize_t zv_max_mean_zsize_store(struct kobject *kobj,
+				    struct kobj_attribute *attr,
+				    const char *buf, size_t count)
+{
+	unsigned long val;
+	int err;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	err = strict_strtoul(buf, 10, &val);
+	if (err || (val == 0) || (val > (PAGE_SIZE / 8) * 7))
+		return -EINVAL;
+	zv_max_mean_zsize = val;
+	return count;
+}
+
+/*
+ * setting zv_page_count_policy_percent via sysfs sets an upper bound of
+ * persistent (e.g. swap) pages that will be retained according to:
+ *     (zv_page_count_policy_percent * totalram_pages) / 100)
+ * when that limit is reached, further puts will be rejected (until
+ * some pages have been flushed).  Note that, due to compression,
+ * this number may exceed 100; it defaults to 75 and we set an
+ * arbitary limit of 150.  A poor choice will almost certainly result
+ * in OOM's, so this value should only be changed prudently.
+ */
+static ssize_t zv_page_count_policy_percent_show(struct kobject *kobj,
+						 struct kobj_attribute *attr,
+						 char *buf)
+{
+	return sprintf(buf, "%u\n", zv_page_count_policy_percent);
+}
+
+static ssize_t zv_page_count_policy_percent_store(struct kobject *kobj,
+						  struct kobj_attribute *attr,
+						  const char *buf, size_t count)
+{
+	unsigned long val;
+	int err;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	err = strict_strtoul(buf, 10, &val);
+	if (err || (val == 0) || (val > 150))
+		return -EINVAL;
+	zv_page_count_policy_percent = val;
+	return count;
+}
+
+static struct kobj_attribute zcache_zv_max_zsize_attr = {
+		.attr = { .name = "zv_max_zsize", .mode = 0644 },
+		.show = zv_max_zsize_show,
+		.store = zv_max_zsize_store,
+};
+
+static struct kobj_attribute zcache_zv_max_mean_zsize_attr = {
+		.attr = { .name = "zv_max_mean_zsize", .mode = 0644 },
+		.show = zv_max_mean_zsize_show,
+		.store = zv_max_mean_zsize_store,
+};
+
+static struct kobj_attribute zcache_zv_page_count_policy_percent_attr = {
+		.attr = { .name = "zv_page_count_policy_percent",
+			  .mode = 0644 },
+		.show = zv_page_count_policy_percent_show,
+		.store = zv_page_count_policy_percent_store,
+};
+#endif
+
+/*
+ * zcache core code starts here
+ */
+
+/* useful stats not collected by cleancache or frontswap */
+static unsigned long zcache_flush_total;
+static unsigned long zcache_flush_found;
+static unsigned long zcache_flobj_total;
+static unsigned long zcache_flobj_found;
+static unsigned long zcache_failed_eph_puts;
+static unsigned long zcache_failed_pers_puts;
+
+/*
+ * Tmem operations assume the poolid implies the invoking client.
+ * Zcache only has one client (the kernel itself): LOCAL_CLIENT.
+ * RAMster has each client numbered by cluster node, and a KVM version
+ * of zcache would have one client per guest and each client might
+ * have a poolid==N.
+ */
+static struct tmem_pool *zcache_get_pool_by_id(uint16_t cli_id, uint16_t poolid)
+{
+	struct tmem_pool *pool = NULL;
+	struct zcache_client *cli = NULL;
+
+	if (cli_id == LOCAL_CLIENT)
+		cli = &zcache_host;
+	else {
+		if (cli_id >= MAX_CLIENTS)
+			goto out;
+		cli = &zcache_clients[cli_id];
+		if (cli == NULL)
+			goto out;
+		atomic_inc(&cli->refcount);
+	}
+	if (poolid < MAX_POOLS_PER_CLIENT) {
+		pool = cli->tmem_pools[poolid];
+		if (pool != NULL)
+			atomic_inc(&pool->refcount);
+	}
+out:
+	return pool;
+}
+
+static void zcache_put_pool(struct tmem_pool *pool)
+{
+	struct zcache_client *cli = NULL;
+
+	if (pool == NULL)
+		BUG();
+	cli = pool->client;
+	atomic_dec(&pool->refcount);
+	atomic_dec(&cli->refcount);
+}
+
+int zcache_new_client(uint16_t cli_id)
+{
+	struct zcache_client *cli = NULL;
+	int ret = -1;
+
+	if (cli_id == LOCAL_CLIENT)
+		cli = &zcache_host;
+	else if ((unsigned int)cli_id < MAX_CLIENTS)
+		cli = &zcache_clients[cli_id];
+	if (cli == NULL)
+		goto out;
+	if (cli->allocated)
+		goto out;
+	cli->allocated = 1;
+#ifdef CONFIG_FRONTSWAP
+	cli->xvpool = xv_create_pool();
+	if (cli->xvpool == NULL)
+		goto out;
+#endif
+	ret = 0;
+out:
+	return ret;
+}
+
+/* counters for debugging */
+static unsigned long zcache_failed_get_free_pages;
+static unsigned long zcache_failed_alloc;
+static unsigned long zcache_put_to_flush;
+
+/*
+ * for now, used named slabs so can easily track usage; later can
+ * either just use kmalloc, or perhaps add a slab-like allocator
+ * to more carefully manage total memory utilization
+ */
+static struct kmem_cache *zcache_objnode_cache;
+static struct kmem_cache *zcache_obj_cache;
+static atomic_t zcache_curr_obj_count = ATOMIC_INIT(0);
+static unsigned long zcache_curr_obj_count_max;
+static atomic_t zcache_curr_objnode_count = ATOMIC_INIT(0);
+static unsigned long zcache_curr_objnode_count_max;
+
+/*
+ * to avoid memory allocation recursion (e.g. due to direct reclaim), we
+ * preload all necessary data structures so the hostops callbacks never
+ * actually do a malloc
+ */
+struct zcache_preload {
+	void *page;
+	struct tmem_obj *obj;
+	int nr;
+	struct tmem_objnode *objnodes[OBJNODE_TREE_MAX_PATH];
+};
+static DEFINE_PER_CPU(struct zcache_preload, zcache_preloads) = { 0, };
+
+static int zcache_do_preload(struct tmem_pool *pool)
+{
+	struct zcache_preload *kp;
+	struct tmem_objnode *objnode;
+	struct tmem_obj *obj;
+	void *page;
+	int ret = -ENOMEM;
+
+	if (unlikely(zcache_objnode_cache == NULL))
+		goto out;
+	if (unlikely(zcache_obj_cache == NULL))
+		goto out;
+	preempt_disable();
+	kp = &__get_cpu_var(zcache_preloads);
+	while (kp->nr < ARRAY_SIZE(kp->objnodes)) {
+		preempt_enable_no_resched();
+		objnode = kmem_cache_alloc(zcache_objnode_cache,
+				ZCACHE_GFP_MASK);
+		if (unlikely(objnode == NULL)) {
+			zcache_failed_alloc++;
+			goto out;
+		}
+		preempt_disable();
+		kp = &__get_cpu_var(zcache_preloads);
+		if (kp->nr < ARRAY_SIZE(kp->objnodes))
+			kp->objnodes[kp->nr++] = objnode;
+		else
+			kmem_cache_free(zcache_objnode_cache, objnode);
+	}
+	preempt_enable_no_resched();
+	obj = kmem_cache_alloc(zcache_obj_cache, ZCACHE_GFP_MASK);
+	if (unlikely(obj == NULL)) {
+		zcache_failed_alloc++;
+		goto out;
+	}
+	page = (void *)__get_free_page(ZCACHE_GFP_MASK);
+	if (unlikely(page == NULL)) {
+		zcache_failed_get_free_pages++;
+		kmem_cache_free(zcache_obj_cache, obj);
+		goto out;
+	}
+	preempt_disable();
+	kp = &__get_cpu_var(zcache_preloads);
+	if (kp->obj == NULL)
+		kp->obj = obj;
+	else
+		kmem_cache_free(zcache_obj_cache, obj);
+	if (kp->page == NULL)
+		kp->page = page;
+	else
+		free_page((unsigned long)page);
+	ret = 0;
+out:
+	return ret;
+}
+
+static void *zcache_get_free_page(void)
+{
+	struct zcache_preload *kp;
+	void *page;
+
+	kp = &__get_cpu_var(zcache_preloads);
+	page = kp->page;
+	BUG_ON(page == NULL);
+	kp->page = NULL;
+	return page;
+}
+
+static void zcache_free_page(void *p)
+{
+	free_page((unsigned long)p);
+}
+
+/*
+ * zcache implementation for tmem host ops
+ */
+
+static struct tmem_objnode *zcache_objnode_alloc(struct tmem_pool *pool)
+{
+	struct tmem_objnode *objnode = NULL;
+	unsigned long count;
+	struct zcache_preload *kp;
+
+	kp = &__get_cpu_var(zcache_preloads);
+	if (kp->nr <= 0)
+		goto out;
+	objnode = kp->objnodes[kp->nr - 1];
+	BUG_ON(objnode == NULL);
+	kp->objnodes[kp->nr - 1] = NULL;
+	kp->nr--;
+	count = atomic_inc_return(&zcache_curr_objnode_count);
+	if (count > zcache_curr_objnode_count_max)
+		zcache_curr_objnode_count_max = count;
+out:
+	return objnode;
+}
+
+static void zcache_objnode_free(struct tmem_objnode *objnode,
+					struct tmem_pool *pool)
+{
+	atomic_dec(&zcache_curr_objnode_count);
+	BUG_ON(atomic_read(&zcache_curr_objnode_count) < 0);
+	kmem_cache_free(zcache_objnode_cache, objnode);
+}
+
+static struct tmem_obj *zcache_obj_alloc(struct tmem_pool *pool)
+{
+	struct tmem_obj *obj = NULL;
+	unsigned long count;
+	struct zcache_preload *kp;
+
+	kp = &__get_cpu_var(zcache_preloads);
+	obj = kp->obj;
+	BUG_ON(obj == NULL);
+	kp->obj = NULL;
+	count = atomic_inc_return(&zcache_curr_obj_count);
+	if (count > zcache_curr_obj_count_max)
+		zcache_curr_obj_count_max = count;
+	return obj;
+}
+
+static void zcache_obj_free(struct tmem_obj *obj, struct tmem_pool *pool)
+{
+	atomic_dec(&zcache_curr_obj_count);
+	BUG_ON(atomic_read(&zcache_curr_obj_count) < 0);
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
+/*
+ * zcache implementations for PAM page descriptor ops
+ */
+
+static atomic_t zcache_curr_eph_pampd_count = ATOMIC_INIT(0);
+static unsigned long zcache_curr_eph_pampd_count_max;
+static atomic_t zcache_curr_pers_pampd_count = ATOMIC_INIT(0);
+static unsigned long zcache_curr_pers_pampd_count_max;
+
+/* forward reference */
+static int zcache_compress(struct page *from, void **out_va, size_t *out_len);
+
+static void *zcache_pampd_create(char *data, size_t size, bool raw, int eph,
+				struct tmem_pool *pool, struct tmem_oid *oid,
+				 uint32_t index)
+{
+	void *pampd = NULL, *cdata;
+	size_t clen;
+	int ret;
+	unsigned long count;
+	struct page *page = (struct page *)(data);
+	struct zcache_client *cli = pool->client;
+	uint16_t client_id = get_client_id_from_client(cli);
+	unsigned long zv_mean_zsize;
+	unsigned long curr_pers_pampd_count;
+	u64 total_zsize;
+
+	if (eph) {
+		ret = zcache_compress(page, &cdata, &clen);
+		if (ret == 0)
+			goto out;
+		if (clen == 0 || clen > zbud_max_buddy_size()) {
+			zcache_compress_poor++;
+			goto out;
+		}
+		pampd = (void *)zbud_create(client_id, pool->pool_id, oid,
+						index, page, cdata, clen);
+		if (pampd != NULL) {
+			count = atomic_inc_return(&zcache_curr_eph_pampd_count);
+			if (count > zcache_curr_eph_pampd_count_max)
+				zcache_curr_eph_pampd_count_max = count;
+		}
+	} else {
+		curr_pers_pampd_count =
+			atomic_read(&zcache_curr_pers_pampd_count);
+		if (curr_pers_pampd_count >
+		    (zv_page_count_policy_percent * totalram_pages) / 100)
+			goto out;
+		ret = zcache_compress(page, &cdata, &clen);
+		if (ret == 0)
+			goto out;
+		/* reject if compression is too poor */
+		if (clen > zv_max_zsize) {
+			zcache_compress_poor++;
+			goto out;
+		}
+		/* reject if mean compression is too poor */
+		if ((clen > zv_max_mean_zsize) && (curr_pers_pampd_count > 0)) {
+			total_zsize = xv_get_total_size_bytes(cli->xvpool);
+			zv_mean_zsize = div_u64(total_zsize,
+						curr_pers_pampd_count);
+			if (zv_mean_zsize > zv_max_mean_zsize) {
+				zcache_mean_compress_poor++;
+				goto out;
+			}
+		}
+		pampd = (void *)zv_create(cli->xvpool, pool->pool_id,
+						oid, index, cdata, clen);
+		if (pampd == NULL)
+			goto out;
+		count = atomic_inc_return(&zcache_curr_pers_pampd_count);
+		if (count > zcache_curr_pers_pampd_count_max)
+			zcache_curr_pers_pampd_count_max = count;
+	}
+out:
+	return pampd;
+}
+
+/*
+ * fill the pageframe corresponding to the struct page with the data
+ * from the passed pampd
+ */
+static int zcache_pampd_get_data(char *data, size_t *bufsize, bool raw,
+					void *pampd, struct tmem_pool *pool,
+					struct tmem_oid *oid, uint32_t index)
+{
+	int ret = 0;
+
+	BUG_ON(is_ephemeral(pool));
+	zv_decompress((struct page *)(data), pampd);
+	return ret;
+}
+
+/*
+ * fill the pageframe corresponding to the struct page with the data
+ * from the passed pampd
+ */
+static int zcache_pampd_get_data_and_free(char *data, size_t *bufsize, bool raw,
+					void *pampd, struct tmem_pool *pool,
+					struct tmem_oid *oid, uint32_t index)
+{
+	int ret = 0;
+
+	BUG_ON(!is_ephemeral(pool));
+	zbud_decompress((struct page *)(data), pampd);
+	zbud_free_and_delist((struct zbud_hdr *)pampd);
+	atomic_dec(&zcache_curr_eph_pampd_count);
+	return ret;
+}
+
+/*
+ * free the pampd and remove it from any zcache lists
+ * pampd must no longer be pointed to from any tmem data structures!
+ */
+static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
+				struct tmem_oid *oid, uint32_t index)
+{
+	struct zcache_client *cli = pool->client;
+
+	if (is_ephemeral(pool)) {
+		zbud_free_and_delist((struct zbud_hdr *)pampd);
+		atomic_dec(&zcache_curr_eph_pampd_count);
+		BUG_ON(atomic_read(&zcache_curr_eph_pampd_count) < 0);
+	} else {
+		zv_free(cli->xvpool, (struct zv_hdr *)pampd);
+		atomic_dec(&zcache_curr_pers_pampd_count);
+		BUG_ON(atomic_read(&zcache_curr_pers_pampd_count) < 0);
+	}
+}
+
+static void zcache_pampd_free_obj(struct tmem_pool *pool, struct tmem_obj *obj)
+{
+}
+
+static void zcache_pampd_new_obj(struct tmem_obj *obj)
+{
+}
+
+static int zcache_pampd_replace_in_obj(void *pampd, struct tmem_obj *obj)
+{
+	return -1;
+}
+
+static bool zcache_pampd_is_remote(void *pampd)
+{
+	return 0;
+}
+
+static struct tmem_pamops zcache_pamops = {
+	.create = zcache_pampd_create,
+	.get_data = zcache_pampd_get_data,
+	.get_data_and_free = zcache_pampd_get_data_and_free,
+	.free = zcache_pampd_free,
+	.free_obj = zcache_pampd_free_obj,
+	.new_obj = zcache_pampd_new_obj,
+	.replace_in_obj = zcache_pampd_replace_in_obj,
+	.is_remote = zcache_pampd_is_remote,
+};
+
+/*
+ * zcache compression/decompression and related per-cpu stuff
+ */
+
+#define LZO_WORKMEM_BYTES LZO1X_1_MEM_COMPRESS
+#define LZO_DSTMEM_PAGE_ORDER 1
+static DEFINE_PER_CPU(unsigned char *, zcache_workmem);
+static DEFINE_PER_CPU(unsigned char *, zcache_dstmem);
+
+static int zcache_compress(struct page *from, void **out_va, size_t *out_len)
+{
+	int ret = 0;
+	unsigned char *dmem = __get_cpu_var(zcache_dstmem);
+	unsigned char *wmem = __get_cpu_var(zcache_workmem);
+	char *from_va;
+
+	BUG_ON(!irqs_disabled());
+	if (unlikely(dmem == NULL || wmem == NULL))
+		goto out;  /* no buffer, so can't compress */
+	from_va = kmap_atomic(from, KM_USER0);
+	mb();
+	ret = lzo1x_1_compress(from_va, PAGE_SIZE, dmem, out_len, wmem);
+	BUG_ON(ret != LZO_E_OK);
+	*out_va = dmem;
+	kunmap_atomic(from_va, KM_USER0);
+	ret = 1;
+out:
+	return ret;
+}
+
+
+static int zcache_cpu_notifier(struct notifier_block *nb,
+				unsigned long action, void *pcpu)
+{
+	int cpu = (long)pcpu;
+	struct zcache_preload *kp;
+
+	switch (action) {
+	case CPU_UP_PREPARE:
+		per_cpu(zcache_dstmem, cpu) = (void *)__get_free_pages(
+			GFP_KERNEL | __GFP_REPEAT,
+			LZO_DSTMEM_PAGE_ORDER),
+		per_cpu(zcache_workmem, cpu) =
+			kzalloc(LZO1X_MEM_COMPRESS,
+				GFP_KERNEL | __GFP_REPEAT);
+		break;
+	case CPU_DEAD:
+	case CPU_UP_CANCELED:
+		free_pages((unsigned long)per_cpu(zcache_dstmem, cpu),
+				LZO_DSTMEM_PAGE_ORDER);
+		per_cpu(zcache_dstmem, cpu) = NULL;
+		kfree(per_cpu(zcache_workmem, cpu));
+		per_cpu(zcache_workmem, cpu) = NULL;
+		kp = &per_cpu(zcache_preloads, cpu);
+		while (kp->nr) {
+			kmem_cache_free(zcache_objnode_cache,
+					kp->objnodes[kp->nr - 1]);
+			kp->objnodes[kp->nr - 1] = NULL;
+			kp->nr--;
+		}
+		if (kp->obj) {
+			kmem_cache_free(zcache_obj_cache, kp->obj);
+			kp->obj = NULL;
+		}
+		if (kp->page) {
+			free_page((unsigned long)kp->page);
+			kp->page = NULL;
+		}
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
+#ifdef CONFIG_SYSFS
+#define ZCACHE_SYSFS_RO(_name) \
+	static ssize_t zcache_##_name##_show(struct kobject *kobj, \
+				struct kobj_attribute *attr, char *buf) \
+	{ \
+		return sprintf(buf, "%lu\n", zcache_##_name); \
+	} \
+	static struct kobj_attribute zcache_##_name##_attr = { \
+		.attr = { .name = __stringify(_name), .mode = 0444 }, \
+		.show = zcache_##_name##_show, \
+	}
+
+#define ZCACHE_SYSFS_RO_ATOMIC(_name) \
+	static ssize_t zcache_##_name##_show(struct kobject *kobj, \
+				struct kobj_attribute *attr, char *buf) \
+	{ \
+	    return sprintf(buf, "%d\n", atomic_read(&zcache_##_name)); \
+	} \
+	static struct kobj_attribute zcache_##_name##_attr = { \
+		.attr = { .name = __stringify(_name), .mode = 0444 }, \
+		.show = zcache_##_name##_show, \
+	}
+
+#define ZCACHE_SYSFS_RO_CUSTOM(_name, _func) \
+	static ssize_t zcache_##_name##_show(struct kobject *kobj, \
+				struct kobj_attribute *attr, char *buf) \
+	{ \
+	    return _func(buf); \
+	} \
+	static struct kobj_attribute zcache_##_name##_attr = { \
+		.attr = { .name = __stringify(_name), .mode = 0444 }, \
+		.show = zcache_##_name##_show, \
+	}
+
+ZCACHE_SYSFS_RO(curr_obj_count_max);
+ZCACHE_SYSFS_RO(curr_objnode_count_max);
+ZCACHE_SYSFS_RO(flush_total);
+ZCACHE_SYSFS_RO(flush_found);
+ZCACHE_SYSFS_RO(flobj_total);
+ZCACHE_SYSFS_RO(flobj_found);
+ZCACHE_SYSFS_RO(failed_eph_puts);
+ZCACHE_SYSFS_RO(failed_pers_puts);
+ZCACHE_SYSFS_RO(zbud_curr_zbytes);
+ZCACHE_SYSFS_RO(zbud_cumul_zpages);
+ZCACHE_SYSFS_RO(zbud_cumul_zbytes);
+ZCACHE_SYSFS_RO(zbud_buddied_count);
+ZCACHE_SYSFS_RO(zbpg_unused_list_count);
+ZCACHE_SYSFS_RO(evicted_raw_pages);
+ZCACHE_SYSFS_RO(evicted_unbuddied_pages);
+ZCACHE_SYSFS_RO(evicted_buddied_pages);
+ZCACHE_SYSFS_RO(failed_get_free_pages);
+ZCACHE_SYSFS_RO(failed_alloc);
+ZCACHE_SYSFS_RO(put_to_flush);
+ZCACHE_SYSFS_RO(compress_poor);
+ZCACHE_SYSFS_RO(mean_compress_poor);
+ZCACHE_SYSFS_RO_ATOMIC(zbud_curr_raw_pages);
+ZCACHE_SYSFS_RO_ATOMIC(zbud_curr_zpages);
+ZCACHE_SYSFS_RO_ATOMIC(curr_obj_count);
+ZCACHE_SYSFS_RO_ATOMIC(curr_objnode_count);
+ZCACHE_SYSFS_RO_CUSTOM(zbud_unbuddied_list_counts,
+			zbud_show_unbuddied_list_counts);
+ZCACHE_SYSFS_RO_CUSTOM(zbud_cumul_chunk_counts,
+			zbud_show_cumul_chunk_counts);
+ZCACHE_SYSFS_RO_CUSTOM(zv_curr_dist_counts,
+			zv_curr_dist_counts_show);
+ZCACHE_SYSFS_RO_CUSTOM(zv_cumul_dist_counts,
+			zv_cumul_dist_counts_show);
+
+static struct attribute *zcache_attrs[] = {
+	&zcache_curr_obj_count_attr.attr,
+	&zcache_curr_obj_count_max_attr.attr,
+	&zcache_curr_objnode_count_attr.attr,
+	&zcache_curr_objnode_count_max_attr.attr,
+	&zcache_flush_total_attr.attr,
+	&zcache_flobj_total_attr.attr,
+	&zcache_flush_found_attr.attr,
+	&zcache_flobj_found_attr.attr,
+	&zcache_failed_eph_puts_attr.attr,
+	&zcache_failed_pers_puts_attr.attr,
+	&zcache_compress_poor_attr.attr,
+	&zcache_mean_compress_poor_attr.attr,
+	&zcache_zbud_curr_raw_pages_attr.attr,
+	&zcache_zbud_curr_zpages_attr.attr,
+	&zcache_zbud_curr_zbytes_attr.attr,
+	&zcache_zbud_cumul_zpages_attr.attr,
+	&zcache_zbud_cumul_zbytes_attr.attr,
+	&zcache_zbud_buddied_count_attr.attr,
+	&zcache_zbpg_unused_list_count_attr.attr,
+	&zcache_evicted_raw_pages_attr.attr,
+	&zcache_evicted_unbuddied_pages_attr.attr,
+	&zcache_evicted_buddied_pages_attr.attr,
+	&zcache_failed_get_free_pages_attr.attr,
+	&zcache_failed_alloc_attr.attr,
+	&zcache_put_to_flush_attr.attr,
+	&zcache_zbud_unbuddied_list_counts_attr.attr,
+	&zcache_zbud_cumul_chunk_counts_attr.attr,
+	&zcache_zv_curr_dist_counts_attr.attr,
+	&zcache_zv_cumul_dist_counts_attr.attr,
+	&zcache_zv_max_zsize_attr.attr,
+	&zcache_zv_max_mean_zsize_attr.attr,
+	&zcache_zv_page_count_policy_percent_attr.attr,
+	NULL,
+};
+
+static struct attribute_group zcache_attr_group = {
+	.attrs = zcache_attrs,
+	.name = "zcache",
+};
+
+#endif /* CONFIG_SYSFS */
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
+ * zcache shrinker interface (only useful for ephemeral pages, so zbud only)
+ */
+static int shrink_zcache_memory(struct shrinker *shrink,
+				struct shrink_control *sc)
+{
+	int ret = -1;
+	int nr = sc->nr_to_scan;
+	gfp_t gfp_mask = sc->gfp_mask;
+
+	if (nr >= 0) {
+		if (!(gfp_mask & __GFP_FS))
+			/* does this case really need to be skipped? */
+			goto out;
+		zbud_evict_pages(nr);
+	}
+	ret = (int)atomic_read(&zcache_zbud_curr_raw_pages);
+out:
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
+static int zcache_put_page(int cli_id, int pool_id, struct tmem_oid *oidp,
+				uint32_t index, struct page *page)
+{
+	struct tmem_pool *pool;
+	int ret = -1;
+
+	BUG_ON(!irqs_disabled());
+	pool = zcache_get_pool_by_id(cli_id, pool_id);
+	if (unlikely(pool == NULL))
+		goto out;
+	if (!zcache_freeze && zcache_do_preload(pool) == 0) {
+		/* preload does preempt_disable on success */
+		ret = tmem_put(pool, oidp, index, (char *)(page),
+				PAGE_SIZE, 0, is_ephemeral(pool));
+		if (ret < 0) {
+			if (is_ephemeral(pool))
+				zcache_failed_eph_puts++;
+			else
+				zcache_failed_pers_puts++;
+		}
+		zcache_put_pool(pool);
+		preempt_enable_no_resched();
+	} else {
+		zcache_put_to_flush++;
+		if (atomic_read(&pool->obj_count) > 0)
+			/* the put fails whether the flush succeeds or not */
+			(void)tmem_flush_page(pool, oidp, index);
+		zcache_put_pool(pool);
+	}
+out:
+	return ret;
+}
+
+static int zcache_get_page(int cli_id, int pool_id, struct tmem_oid *oidp,
+				uint32_t index, struct page *page)
+{
+	struct tmem_pool *pool;
+	int ret = -1;
+	unsigned long flags;
+	size_t size = PAGE_SIZE;
+
+	local_irq_save(flags);
+	pool = zcache_get_pool_by_id(cli_id, pool_id);
+	if (likely(pool != NULL)) {
+		if (atomic_read(&pool->obj_count) > 0)
+			ret = tmem_get(pool, oidp, index, (char *)(page),
+					&size, 0, is_ephemeral(pool));
+		zcache_put_pool(pool);
+	}
+	local_irq_restore(flags);
+	return ret;
+}
+
+static int zcache_flush_page(int cli_id, int pool_id,
+				struct tmem_oid *oidp, uint32_t index)
+{
+	struct tmem_pool *pool;
+	int ret = -1;
+	unsigned long flags;
+
+	local_irq_save(flags);
+	zcache_flush_total++;
+	pool = zcache_get_pool_by_id(cli_id, pool_id);
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
+static int zcache_flush_object(int cli_id, int pool_id,
+				struct tmem_oid *oidp)
+{
+	struct tmem_pool *pool;
+	int ret = -1;
+	unsigned long flags;
+
+	local_irq_save(flags);
+	zcache_flobj_total++;
+	pool = zcache_get_pool_by_id(cli_id, pool_id);
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
+static int zcache_destroy_pool(int cli_id, int pool_id)
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
+	pr_info("zcache: destroyed pool id=%d, cli_id=%d\n",
+			pool_id, cli_id);
+out:
+	return ret;
+}
+
+static int zcache_new_pool(uint16_t cli_id, uint32_t flags)
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
+		pr_info("zcache: pool creation failed: out of memory\n");
+		goto out;
+	}
+
+	for (poolid = 0; poolid < MAX_POOLS_PER_CLIENT; poolid++)
+		if (cli->tmem_pools[poolid] == NULL)
+			break;
+	if (poolid >= MAX_POOLS_PER_CLIENT) {
+		pr_info("zcache: pool creation failed: max exceeded\n");
+		kfree(pool);
+		poolid = -1;
+		goto out;
+	}
+	atomic_set(&pool->refcount, 0);
+	pool->client = cli;
+	pool->pool_id = poolid;
+	tmem_new_pool(pool, flags);
+	cli->tmem_pools[poolid] = pool;
+	pr_info("zcache: created %s tmem pool, id=%d, client=%d\n",
+		flags & TMEM_POOL_PERSIST ? "persistent" : "ephemeral",
+		poolid, cli_id);
+out:
+	if (cli != NULL)
+		atomic_dec(&cli->refcount);
+	return poolid;
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
+#ifdef CONFIG_CLEANCACHE
+static void zcache_cleancache_put_page(int pool_id,
+					struct cleancache_filekey key,
+					pgoff_t index, struct page *page)
+{
+	u32 ind = (u32) index;
+	struct tmem_oid oid = *(struct tmem_oid *)&key;
+
+	if (likely(ind == index))
+		(void)zcache_put_page(LOCAL_CLIENT, pool_id, &oid, index, page);
+}
+
+static int zcache_cleancache_get_page(int pool_id,
+					struct cleancache_filekey key,
+					pgoff_t index, struct page *page)
+{
+	u32 ind = (u32) index;
+	struct tmem_oid oid = *(struct tmem_oid *)&key;
+	int ret = -1;
+
+	if (likely(ind == index))
+		ret = zcache_get_page(LOCAL_CLIENT, pool_id, &oid, index, page);
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
+		(void)zcache_destroy_pool(LOCAL_CLIENT, pool_id);
+}
+
+static int zcache_cleancache_init_fs(size_t pagesize)
+{
+	BUG_ON(sizeof(struct cleancache_filekey) !=
+				sizeof(struct tmem_oid));
+	BUG_ON(pagesize != PAGE_SIZE);
+	return zcache_new_pool(LOCAL_CLIENT, 0);
+}
+
+static int zcache_cleancache_init_shared_fs(char *uuid, size_t pagesize)
+{
+	/* shared pools are unsupported and map to private */
+	BUG_ON(sizeof(struct cleancache_filekey) !=
+				sizeof(struct tmem_oid));
+	BUG_ON(pagesize != PAGE_SIZE);
+	return zcache_new_pool(LOCAL_CLIENT, 0);
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
+#endif
+
+#ifdef CONFIG_FRONTSWAP
+/* a single tmem poolid is used for all frontswap "types" (swapfiles) */
+static int zcache_frontswap_poolid = -1;
+
+/*
+ * Swizzling increases objects per swaptype, increasing tmem concurrency
+ * for heavy swaploads.  Later, larger nr_cpus -> larger SWIZ_BITS
+ * Setting SWIZ_BITS to 27 basically reconstructs the swap entry from
+ * frontswap_get_page()
+ */
+#define SWIZ_BITS		27
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
+static int zcache_frontswap_put_page(unsigned type, pgoff_t offset,
+				   struct page *page)
+{
+	u64 ind64 = (u64)offset;
+	u32 ind = (u32)offset;
+	struct tmem_oid oid = oswiz(type, ind);
+	int ret = -1;
+	unsigned long flags;
+
+	BUG_ON(!PageLocked(page));
+	if (likely(ind64 == ind)) {
+		local_irq_save(flags);
+		ret = zcache_put_page(LOCAL_CLIENT, zcache_frontswap_poolid,
+					&oid, iswiz(ind), page);
+		local_irq_restore(flags);
+	}
+	return ret;
+}
+
+/* returns 0 if the page was successfully gotten from frontswap, -1 if
+ * was not present (should never happen!) */
+static int zcache_frontswap_get_page(unsigned type, pgoff_t offset,
+				   struct page *page)
+{
+	u64 ind64 = (u64)offset;
+	u32 ind = (u32)offset;
+	struct tmem_oid oid = oswiz(type, ind);
+	int ret = -1;
+
+	BUG_ON(!PageLocked(page));
+	if (likely(ind64 == ind))
+		ret = zcache_get_page(LOCAL_CLIENT, zcache_frontswap_poolid,
+					&oid, iswiz(ind), page);
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
+			zcache_new_pool(LOCAL_CLIENT, TMEM_POOL_PERSIST);
+}
+
+static struct frontswap_ops zcache_frontswap_ops = {
+	.put_page = zcache_frontswap_put_page,
+	.get_page = zcache_frontswap_get_page,
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
+#endif
+
+/*
+ * zcache initialization
+ * NOTE FOR NOW zcache MUST BE PROVIDED AS A KERNEL BOOT PARAMETER OR
+ * NOTHING HAPPENS!
+ */
+
+static int zcache_enabled;
+
+static int __init enable_zcache(char *s)
+{
+	zcache_enabled = 1;
+	return 1;
+}
+__setup("zcache", enable_zcache);
+
+/* allow independent dynamic disabling of cleancache and frontswap */
+
+static int use_cleancache = 1;
+
+static int __init no_cleancache(char *s)
+{
+	use_cleancache = 0;
+	return 1;
+}
+
+__setup("nocleancache", no_cleancache);
+
+static int use_frontswap = 1;
+
+static int __init no_frontswap(char *s)
+{
+	use_frontswap = 0;
+	return 1;
+}
+
+__setup("nofrontswap", no_frontswap);
+
+static int __init zcache_init(void)
+{
+	int ret = 0;
+
+#ifdef CONFIG_SYSFS
+	ret = sysfs_create_group(mm_kobj, &zcache_attr_group);
+	if (ret) {
+		pr_err("zcache: can't create sysfs\n");
+		goto out;
+	}
+#endif /* CONFIG_SYSFS */
+#if defined(CONFIG_CLEANCACHE) || defined(CONFIG_FRONTSWAP)
+	if (zcache_enabled) {
+		unsigned int cpu;
+
+		tmem_register_hostops(&zcache_hostops);
+		tmem_register_pamops(&zcache_pamops);
+		ret = register_cpu_notifier(&zcache_cpu_notifier_block);
+		if (ret) {
+			pr_err("zcache: can't register cpu notifier\n");
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
+		pr_err("zcache: can't create client\n");
+		goto out;
+	}
+#endif
+#ifdef CONFIG_CLEANCACHE
+	if (zcache_enabled && use_cleancache) {
+		struct cleancache_ops old_ops;
+
+		zbud_init();
+		register_shrinker(&zcache_shrinker);
+		old_ops = zcache_cleancache_register_ops();
+		pr_info("zcache: cleancache enabled using kernel "
+			"transcendent memory and compression buddies\n");
+		if (old_ops.init_fs != NULL)
+			pr_warning("zcache: cleancache_ops overridden");
+	}
+#endif
+#ifdef CONFIG_FRONTSWAP
+	if (zcache_enabled && use_frontswap) {
+		struct frontswap_ops old_ops;
+
+		old_ops = zcache_frontswap_register_ops();
+		pr_info("zcache: frontswap enabled using kernel "
+			"transcendent memory and xvmalloc\n");
+		if (old_ops.init != NULL)
+			pr_warning("zcache: frontswap_ops overridden");
+	}
+#endif
+out:
+	return ret;
+}
+
+module_init(zcache_init)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
