Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 54A566B008A
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 13:08:00 -0500 (EST)
Date: Tue, 7 Dec 2010 10:07:24 -0800
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V0 2/4] kztmem: in-kernel transcendent memory code
Message-ID: <20101207180724.GA28154@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: chris.mason@oracle.com, akpm@linux-foundation.org, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, kurt.hackel@oracle.com, npiggin@kernel.dk, riel@redhat.com, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, mel@csn.ul.ie, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

[PATCH V0 2/4] kztmem: in-kernel transcendent memory code

Transcendent memory ("tmem") is a clean API/ABI that provides
for an efficient address translation and a set of highly
concurrent access methods to copy data between a page-oriented
data source (e.g. cleancache or frontswap) and a page-addressable
memory ("PAM") data store.

To be functional, two sets of "ops" must be registered, one
to provide "host services" (memory allocation and "client"
information) and one to provide page-addressable memory
("PAM") hooks.

Further, the basic access methods (e.g. put, get, flush, etc)
are normally called from data sources via other sets of
ops.  A shim is included for the two known existing data
sources: cleancache and frontswap; other data sources may
be provided in the future.

Tmem supports one or more "clients", each which can provide
a set of "pools" to partition pages.  Each pool contains
a set of "objects"; each object holds pointers to some number
of PAM page descriptors ("pampd"), indexed by an "index" number.
This triple <pool id, object id, index> is sometimes referred
to as a "handle".  Tmem's primary function is to essentially
provide address translation of handles into pampds.

As an example, for cleancache, a pool maps to a filesystem,
an object maps to a file, and the index is the page offset
into the file.  And in this patch, each PAM descriptor points
to a compressed page of data.

Tmem supports two kinds of pages: "ephemeral" and "persistent".
Ephemeral pages may be asynchronously reclaimed "bottoms up"
so the data structures and concurrency model must allow for
this.  For example, each pampd must retain an up-pointer to
its containing object so that, on reclaim, all tmem data
structures can be made consistent.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

---

Diffstat:
 drivers/staging/kztmem/tmem.c            | 1375 +++++++++++++++++++++
 drivers/staging/kztmem/tmem.h            |  135 ++
 2 files changed, 1510 insertions(+)
--- linux-2.6.36/drivers/staging/kztmem/tmem.c	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.36-kztmem/drivers/staging/kztmem/tmem.c	2010-12-07 10:11:38.000000000 -0700
@@ -0,0 +1,1375 @@
+/*
+ * In-kernel transcendent memory (generic implementation)
+ *
+ * Copyright (c) 2009-2010, Dan Magenheimer, Oracle Corp.
+ *
+ * Transcendent memory must support potentially millions of pages and
+ * must be able to insert, find, and delete these pages at a potential
+ * frequency of thousands per second concurrently across many CPUs,
+ * and, if used with KVM, across many vcpus across many guests.
+ * Tmem is tracked with a hierarchy of data structures, organized by
+ * the elements in a handle-tuple: pool_id, object_id, and page index.
+ * One or more "clients" (e.g. guests) each provide one or more tmem_pools.
+ * Each pool, contains a hash table of rb_trees of tmem_objs.  Each tmem_obj
+ * contains a simplified radix tree ("sadix tree") of pointers.  Each of
+ * these pointers is a page-accessible-memory (PAM) page descriptor
+ * ("pampd") which is an abstract datatype, accessible only through
+ * a set of ops provided by the PAM implementation (see tmem_pamops).
+ * Tmem does all memory allocation via calls to a set of ops provided
+ * by the tmem host implementation (e.g. see tmem_hostops).
+ *
+ * Also in this file, a generic shim for interfacing the in-kernel
+ * API's for cleancache and frontswap and functions to register them.
+ */
+
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/hash.h>
+#include <asm/atomic.h>
+
+#include "tmem.h"
+
+#ifdef CONFIG_CLEANCACHE
+#include <linux/cleancache.h>
+#endif
+#ifdef CONFIG_FRONTSWAP
+#include <linux/frontswap.h>
+#endif
+
+/*
+ * "WEIRD_BUG", best I can tell, seems to be a compiler bug in gcc 4.1.2
+ * It seems a local variable gets partially overwritten during/after an
+ * indirect function call.  Since the variable is a pointer, weird
+ * results happen.  To work around this, that local variable is saved
+ * in a per_cpu var and restored after it gets trashed.  The symptoms
+ * seem to dance around a bit, so I've left a lot of ifdefs lying about
+ * for this one, in case it is reproducible and someone wants a go at it.
+ */
+#define WEIRD_BUG
+#ifdef WEIRD_BUG
+#define BAD_OBJ(_obj) \
+	(!((unsigned long)_obj & 0x00000000ffffffff) || \
+				_obj->sentinel != OBJ_SENTINEL)
+#endif
+
+/*
+ * Defining TMEM_GLOBAL_LOCK eliminates concurrency in tmem.  It should
+ * not be needed, but it's implemented to rule out races as the cause of
+ * the other bugs.
+ */
+#define TMEM_GLOBAL_LOCK
+
+/*
+ * This define is clearly broken and will cause poor performance when
+ * many objects are in existence, but seems to work around some
+ * yet-to-be discovered bug in the rbtree code.  See tmem_oid_compare.
+ */
+#define BROKEN_OID_COMPARE
+
+/*
+ * Way too verbose unless debugging a very early problem
+ */
+#undef TMEM_TRACE
+
+static inline void tmem_trace(int op, uint32_t pool_id, struct tmem_oid *oidp,
+				uint32_t index)
+{
+#ifdef TMEM_TRACE
+	uint64_t oid = oidp->oid[0];
+
+	if (oidp->oid[1] || oidp->oid[2])
+		oid = -1ULL;
+	pr_err("tmem_trace:%d %d %llx %d\n", op, (int)pool_id,
+		(long long)oid, (int)index);
+#endif
+}
+
+/*
+ * Useful for verifying locking expectations.
+ */
+#define ASSERT(_x) WARN_ON(unlikely(!(_x)))	/* CHANGE TO BUG_ON LATER */
+
+#define ASSERT_SPINLOCK(_l) ASSERT(tmem_rwlock_held || spin_is_locked(_l))
+
+#define ASSERT_WRITELOCK(_l) ASSERT(tmem_rwlock_held || \
+			(_raw_read_trylock(_l) ? (_raw_read_unlock(_l), 0) : 1))
+
+/*
+ * sentinels have proven very useful for debugging but can be removed
+ * or disabled before final merge.  SENTINELS should be #define'd
+ * or #undef'd in tmem.h
+ */
+#ifdef SENTINELS
+#define SET_SENTINEL(_x, _y) (_x->sentinel = _y##_SENTINEL)
+#define INVERT_SENTINEL(_x, _y) (_x->sentinel = ~_y##_SENTINEL)
+#define ASSERT_SENTINEL(_x, _y) ASSERT(_x->sentinel == _y##_SENTINEL)
+#define ASSERT_INVERTED_SENTINEL(_x, _y) ASSERT(_x->sentinel == ~_y##_SENTINEL)
+#else
+#define SET_SENTINEL(_x, _y) do { } while (0)
+#define ASSERT_SENTINEL(_x, _y) do { } while (0)
+#define INVERT_SENTINEL(_x, _y) do { } while (0)
+#endif
+
+/* OK, the real code finally starts here */
+
+static struct tmem_hostops tmem_hostops;
+static struct tmem_pamops tmem_pamops;
+
+/* bookkeeping and debugging routines */
+
+static unsigned long tmem_stats[TMEM_STAT_NSTATS];
+
+unsigned long tmem_stat_get(int stat)
+{
+	ASSERT(stat < TMEM_STAT_NSTATS);
+	return tmem_stats[stat];
+}
+
+static inline void tmem_stat_inc(int stat)
+{
+	tmem_stats[stat]++;
+}
+
+/**********
+ * tmem_rwlock is held for reading during any tmem activity and held
+ * for writing for: (1) pool creation and flushing and (2) bulk ephemeral
+ * memory reclamation (e.g. by a "shrinker").  When held for the latter,
+ * "tmem_rwlock_held" is also set to avoid unnecessary locking when shrinking
+ * walks and prunes various data structures.
+ */
+static DEFINE_RWLOCK(tmem_rwlock);
+#ifdef TMEM_GLOBAL_LOCK
+static bool tmem_rwlock_held = 1;
+#define tmem_write_or_read_lock(_lock) write_lock(_lock)
+#define tmem_write_or_read_unlock(_lock) write_unlock(_lock)
+#else
+static bool tmem_rwlock_held; /* circumvent all other locks */
+#define tmem_write_or_read_lock(_lock) read_lock(_lock)
+#define tmem_write_or_read_unlock(_lock) read_unlock(_lock)
+#endif
+
+void tmem_shrink_lock(void)
+{
+	write_lock(&tmem_rwlock);
+#ifdef TMEM_GLOBAL_LOCK
+	tmem_rwlock_held = 1;
+#endif
+}
+
+int tmem_shrink_trylock(void)
+{
+	int locked = write_trylock(&tmem_rwlock);
+#ifdef TMEM_GLOBAL_LOCK
+	tmem_rwlock_held = locked;
+#endif
+	return locked;
+}
+
+void tmem_shrink_unlock(void)
+{
+#ifdef TMEM_GLOBAL_LOCK
+	tmem_rwlock_held = 0;
+#endif
+	write_unlock(&tmem_rwlock);
+}
+
+static inline void tmem_spin_lock(spinlock_t *lock)
+{
+	if (!tmem_rwlock_held)
+		spin_lock(lock);
+}
+
+static inline void tmem_spin_unlock(spinlock_t *lock)
+{
+	if (!tmem_rwlock_held)
+		spin_unlock(lock);
+}
+
+static inline bool tmem_spin_trylock(spinlock_t *lock)
+{
+	return tmem_rwlock_held ? 1 : spin_trylock(lock);
+}
+
+static inline void tmem_read_lock(rwlock_t *lock)
+{
+	if (!tmem_rwlock_held)
+		read_lock(lock);
+}
+
+static inline void tmem_read_unlock(rwlock_t *lock)
+{
+	if (!tmem_rwlock_held)
+		read_unlock(lock);
+}
+
+static inline void tmem_write_lock(rwlock_t *lock)
+{
+	if (!tmem_rwlock_held)
+		write_lock(lock);
+}
+
+static inline void tmem_write_unlock(rwlock_t *lock)
+{
+	if (!tmem_rwlock_held)
+		write_unlock(lock);
+}
+
+static inline bool tmem_read_trylock(rwlock_t *lock)
+{
+	return tmem_rwlock_held ? 1 : read_trylock(lock);
+}
+
+static inline bool tmem_write_trylock(rwlock_t *lock)
+{
+	return tmem_rwlock_held ? 1 : write_trylock(lock);
+}
+
+/**********
+ * The primary purpose of tmem is to map object-oriented "handles"
+ * (triples containing a pool id, and object id, and an index), to
+ * pages in a page-accessible memory (PAM).  Tmem references the
+ * PAM pages via an abstract "pampd" (PAM page-descriptor), which
+ * can be operated on by a set of functions (pamops).  Each pampd
+ * contains an index, an "up pointer" to the tmem_obj which points
+ * to it, and some representation of PAGE_SIZE bytes worth of data.
+ * The index, tmem_obj pointer, and the data are only accessible
+ * through pamops.
+ *
+ * The following functions manage pampds and call the pamops.
+ * Note that any pampd access requires the parent tmem_obj's
+ * obj_spinlock to be held (thus obviating the need for the RCU
+ * locking in a standard kernel radix tree).
+ */
+
+/*
+ * allocate a pampd, fill it with data from the passed page,
+ * and associate it with the passed object and index
+ */
+static void *tmem_pampd_create(struct tmem_obj *obj, uint32_t index,
+				 struct page *page)
+{
+	void *pampd = NULL;
+	struct tmem_pool *pool;
+
+	ASSERT(obj != NULL);
+	pool = obj->pool;
+	ASSERT(obj->pool != NULL);
+	pampd = (*tmem_pamops.create)(obj, index, page, obj->pool);
+#ifdef WEIRD_BUG
+	if (BAD_OBJ(obj)) {
+		static int cnt;
+		cnt++;
+		if (!(cnt&(cnt-1)))
+			pr_err("DJM wacko in tmem_pampd_create, now %p, "
+				"cnt=%d\n",obj,cnt);
+	}
+#endif
+	return pampd;
+}
+
+/*
+ * fill the pageframe corresponding to the struct page with the data
+ * from the passed pampd
+ */
+static void tmem_pampd_get_data(struct page *page, void *pampd,
+					struct tmem_pool *pool)
+{
+	(*tmem_pamops.get_data)(page, pampd, pool);
+}
+
+/*
+ * lookup index in object and return associated pampd
+ */
+static void *tmem_pampd_lookup_in_obj(struct tmem_obj *obj, uint32_t index)
+{
+	void *pampd;
+
+	ASSERT(obj != NULL);
+	ASSERT_SPINLOCK(&obj->obj_spinlock);
+	ASSERT_SENTINEL(obj, OBJ);
+	ASSERT(obj->pool != NULL);
+	ASSERT_SENTINEL(obj->pool, POOL);
+	pampd = sadix_tree_lookup(&obj->tree_root, index);
+	return pampd;
+}
+
+/*
+ * remove page from lists (already gone from parent object) and free it 
+ */
+static void tmem_pampd_delete(void *pampd, void *pool)
+{
+	struct tmem_obj *obj;
+	uint32_t index;
+
+	ASSERT(pampd != NULL);
+	obj = (*tmem_pamops.get_obj)(pampd, pool);
+	ASSERT(obj != NULL);
+	ASSERT_SENTINEL(obj, OBJ);
+	ASSERT(obj->pool != NULL);
+	ASSERT_SENTINEL(obj->pool, POOL);
+	index = (*tmem_pamops.get_index)(pampd, pool);
+	ASSERT(tmem_pampd_lookup_in_obj(obj, index) == NULL);
+	(*tmem_pamops.free)(pampd, pool);
+}
+
+/*
+ * called only indirectly by sadix_tree_destroy when an entire object
+ * and all of its associated pampd's are being destroyed
+ */
+static void tmem_pampd_destroy(void *pampd, void *pool)
+{
+	struct tmem_obj *obj;
+
+	ASSERT(pampd != NULL);
+	obj = (*tmem_pamops.get_obj)(pampd, pool);
+	ASSERT(obj != NULL);
+	ASSERT_SPINLOCK(&obj->obj_spinlock);
+	ASSERT_SENTINEL(obj, OBJ);
+	ASSERT(obj->pool != NULL);
+	ASSERT_SENTINEL(obj->pool, POOL);
+	obj->pampd_count--;
+	ASSERT(obj->pampd_count >= 0);
+	(*tmem_pamops.free)(pampd, pool);
+}
+
+static void tmem_obj_free(struct tmem_obj *);
+static void *tmem_pampd_delete_from_obj(struct tmem_obj *, uint32_t);
+
+/**********
+ * called by PAM-implementation memory shrinker/reclamation functions,
+ * removes the passed pampd from all tmem data structures and then
+ * calls back into the PAM-implemenatation (via pampops.prune) to free
+ * the space associated with the pampd. Should only be called when all
+ * tmem operations are locked out (ie. when the tmem_rwlock is held
+ * for writing).
+ */
+#ifdef WEIRD_BUG
+static DEFINE_PER_CPU(struct tmem_obj *, pampd_prune_saved_obj);
+#endif
+void tmem_pampd_prune(void *pampd)
+{
+	struct tmem_obj *obj;
+	void *pampd_del;
+	uint32_t index;
+
+#ifndef TMEM_GLOBAL_LOCK
+	ASSERT(!write_trylock(&tmem_rwlock));
+#endif
+	ASSERT(pampd != NULL);
+	obj = (*tmem_pamops.get_obj)(pampd, NULL);
+	ASSERT(obj != NULL);
+	ASSERT_SENTINEL(obj, OBJ);
+	ASSERT_SPINLOCK(&obj->obj_spinlock);
+	ASSERT_SENTINEL(obj->pool, POOL);
+	ASSERT(is_ephemeral(obj->pool));
+	index = (*tmem_pamops.get_index)(pampd, NULL);
+	pampd_del = tmem_pampd_delete_from_obj(obj, index);
+	ASSERT(pampd_del == pampd);
+#ifdef WEIRD_BUG
+	BUG_ON(BAD_OBJ(obj));
+	per_cpu(pampd_prune_saved_obj, smp_processor_id()) = obj;	
+	/* the local variable obj somehow gets overwritten between here */
+	(*tmem_pamops.prune)(pampd);
+	/* and here so reset it to a previously saved per-cpu value */
+	if (BAD_OBJ(obj)) {
+		static int cnt;
+		cnt++;
+		if (!(cnt&(cnt-1)))
+			pr_err("DJM obj fixing wacko obj 5, cnt=%d\n",cnt);
+		obj = get_cpu_var(pampd_prune_saved_obj);
+		BUG_ON(BAD_OBJ(obj));
+	}
+#else
+	(*tmem_pamops.prune)(pampd);
+#endif
+	if (obj->pampd_count == 0)
+		tmem_obj_free(obj);
+}
+
+/* forward references to actor functions, see comments below */
+static struct sadix_tree_node *tmem_stn_alloc(void *arg);
+static void tmem_stn_free(struct sadix_tree_node *tmem_stn);
+
+static int tmem_pampd_add_to_obj(struct tmem_obj *obj, uint32_t index,
+					void *pampd)
+{
+	int ret;
+
+	ASSERT_SPINLOCK(&obj->obj_spinlock);
+	ret = sadix_tree_insert(&obj->tree_root, index,
+				pampd, tmem_stn_alloc, obj);
+	if (!ret)
+		obj->pampd_count++;
+	ASSERT(ret == 0 || ret == -ENOMEM);
+	return ret;
+}
+
+static void *tmem_pampd_delete_from_obj(struct tmem_obj *obj, uint32_t index)
+{
+	void *pampd;
+
+	ASSERT(obj != NULL);
+	ASSERT_SPINLOCK(&obj->obj_spinlock);
+	ASSERT_SENTINEL(obj, OBJ);
+	ASSERT(obj->pool != NULL);
+	ASSERT_SENTINEL(obj->pool, POOL);
+	pampd = sadix_tree_delete(&obj->tree_root, index, tmem_stn_free);
+	if (pampd != NULL)
+		obj->pampd_count--;
+	ASSERT(obj->pampd_count >= 0);
+	return pampd;
+}
+
+/**********
+ * A tmem_obj is a simplified radix tree ("sadix tree"), which has intermediate
+ * nodes, called tmem_objnodes.  Each of these tmem_objnodes contains a set
+ * of pampds.  When sadix tree manipulation requires a tmem_objnode to
+ * be created or destroyed, the sadix tree implementation calls back to
+ * the two routines below.  Note that any access to the tmem_obj's sadix
+ * tree requires the tmem_obj's obj_spinlock to be held.
+ *
+ * NB: The host must call sadix_tree_init() before sadix trees are used.
+ */
+
+/* called only indirectly from sadix_tree_insert */
+static struct sadix_tree_node *tmem_stn_alloc(void *arg)
+{
+	struct tmem_objnode *objnode;
+	struct tmem_obj *obj = (struct tmem_obj *)arg;
+	struct sadix_tree_node *stn = NULL;
+
+	ASSERT_SENTINEL(obj, OBJ);
+	ASSERT(obj->pool != NULL);
+	ASSERT_SENTINEL(obj->pool, POOL);
+	objnode = (*tmem_hostops.objnode_alloc)(obj->pool);
+	if (unlikely(objnode == NULL))
+		goto out;
+	objnode->obj = obj;
+	SET_SENTINEL(objnode, OBJNODE);
+	memset(&objnode->tmem_stn, 0, sizeof(struct sadix_tree_node));
+	obj->objnode_count++;
+	stn = &objnode->tmem_stn;
+out:
+	return stn;
+}
+
+/* called only indirectly from sadix_tree_delete/destroy */
+static void tmem_stn_free(struct sadix_tree_node *tmem_stn)
+{
+	struct tmem_pool *pool;
+	struct tmem_objnode *objnode;
+	int i;
+
+	ASSERT(tmem_stn != NULL);
+	for (i = 0; i < SADIX_TREE_MAP_SIZE; i++)
+		ASSERT(tmem_stn->slots[i] == NULL);
+	objnode = container_of(tmem_stn, struct tmem_objnode, tmem_stn);
+	ASSERT_SENTINEL(objnode, OBJNODE);
+	INVERT_SENTINEL(objnode, OBJNODE);
+	ASSERT(objnode->obj != NULL);
+	ASSERT_SPINLOCK(&objnode->obj->obj_spinlock);
+	ASSERT_SENTINEL(objnode->obj, OBJ);
+	pool = objnode->obj->pool;
+	ASSERT(pool != NULL);
+	ASSERT_SENTINEL(pool, POOL);
+	objnode->obj->objnode_count--;
+	objnode->obj = NULL;
+	(*tmem_hostops.objnode_free)(objnode, pool);
+}
+
+/**********
+ * An object id ("oid") is large: 192-bits (to ensure, for example, files
+ * in a modern filesystem can be uniquely identified).  The following set
+ * of inlined oid helper functions simplify handling of oids.
+ */
+
+static inline int tmem_oid_compare(struct tmem_oid *left,
+					struct tmem_oid *right)
+{
+#ifdef BROKEN_OID_COMPARE
+#define WRONG left
+	/*
+	 * note left < left in three places, instead of left < right
+	 * results in -1 never getting returned.  This is clearly
+	 * wrong, but somehow three WRONGs make a right
+	 */
+#else
+#define WRONG right
+#endif
+	int ret;
+
+	if (left->oid[2] == right->oid[2]) {
+		if (left->oid[1] == right->oid[1]) {
+			if (left->oid[0] == right->oid[0])
+				ret = 0;
+			else if (left->oid[0] < WRONG->oid[0])
+				ret = -1;
+			else
+				return 1;
+		} else if (left->oid[1] < WRONG->oid[1])
+			ret = -1;
+		else
+			ret = 1;
+	} else if (left->oid[2] < WRONG->oid[2])
+		ret = -1;
+	else
+		ret = 1;
+	return ret;
+}
+
+static inline void tmem_oid_set_invalid(struct tmem_oid *oidp)
+{
+	oidp->oid[0] = oidp->oid[1] = oidp->oid[2] = -1UL;
+}
+
+static inline unsigned tmem_oid_hash(struct tmem_oid *oidp)
+{
+	return hash_long(oidp->oid[0] ^ oidp->oid[1] ^ oidp->oid[2],
+			BITS_PER_LONG) & OBJ_HASH_BUCKETS_MASK;
+}
+
+/**********
+ * Oid's are potentially very sparse and tmem_objs may have an indeterminately
+ * short life, being added and deleted at a relatively high frequency.
+ * So an rb_tree is an ideal data structure to manage tmem_objs.  But because
+ * of the potentially huge number of tmem_objs, each pool manages a hashtable
+ * of rb_trees to reduce search, insert, delete, and rebalancing time
+ * The following routines manage tmem_objs.  When any rb_tree is being
+ * accessed, the parent tmem_pool's rwlock must be held for reading, and
+ * if any rb_tree changes might occur, that rwlock must be held fro writing.
+ */
+
+/* searches for object==oid in pool, returns locked object if found */
+static struct tmem_obj *tmem_obj_find(struct tmem_pool *pool,
+					struct tmem_oid *oidp)
+{
+	struct rb_node *node;
+	struct tmem_obj *obj;
+
+restart_find:
+	tmem_read_lock(&pool->pool_rwlock);
+	node = pool->obj_rb_root[tmem_oid_hash(oidp)].rb_node;
+	while (node) {
+		ASSERT(!RB_EMPTY_NODE(node));
+		obj = rb_entry(node, struct tmem_obj, rb_tree_node);
+#ifdef WEIRD_BUG
+		WARN_ON(BAD_OBJ(obj));
+#endif
+		switch (tmem_oid_compare(&obj->oid, oidp)) {
+		case 0: /* equal */
+			if (!tmem_spin_trylock(&obj->obj_spinlock)) {
+#ifdef WEIRD_BUG
+				static int retries;
+				if (retries++ >= 10000000) {
+					pr_err("DJM broke out of obj_find\n");
+					tmem_read_unlock(&pool->pool_rwlock);
+					retries = 0;
+					goto out;
+				}
+#endif
+				tmem_read_unlock(&pool->pool_rwlock);
+				goto restart_find;
+			}
+			tmem_read_unlock(&pool->pool_rwlock);
+			goto out;
+		case -1:
+			node = node->rb_left;
+			break;
+		case 1:
+			node = node->rb_right;
+			break;
+		}
+	}
+	tmem_read_unlock(&pool->pool_rwlock);
+	obj = NULL;
+out:
+	return obj;
+}
+
+/* free an object that has no more pampds in it */
+static void tmem_obj_free(struct tmem_obj *obj)
+{
+	struct tmem_pool *pool;
+	struct tmem_oid old_oid;
+
+	ASSERT_SPINLOCK(&obj->obj_spinlock);
+	ASSERT(obj != NULL);
+	ASSERT_SENTINEL(obj, OBJ);
+	ASSERT(obj->pampd_count == 0);
+	pool = obj->pool;
+	ASSERT(pool != NULL);
+	ASSERT_WRITELOCK(&pool->pool_rwlock);
+	if (obj->tree_root.rnode != NULL) /* may be a "stump" with no leaves */
+		sadix_tree_destroy(&obj->tree_root, tmem_pampd_destroy,
+					tmem_stn_free, (void *)pool);
+#ifdef WEIRD_BUG
+	BUG_ON(BAD_OBJ(obj));
+#endif
+	ASSERT((long)obj->objnode_count == 0);
+	ASSERT(obj->tree_root.rnode == NULL);
+	pool->obj_count--;
+	ASSERT(pool->obj_count >= 0);
+	INVERT_SENTINEL(obj, OBJ);
+	obj->pool = NULL;
+	old_oid = obj->oid;
+	tmem_oid_set_invalid(&obj->oid);
+	rb_erase(&obj->rb_tree_node,
+			  &pool->obj_rb_root[tmem_oid_hash(&old_oid)]);
+	(*tmem_hostops.obj_free)(obj, obj->pool);
+}
+
+static int tmem_obj_rb_insert(struct rb_root *root, struct tmem_obj *obj)
+{
+	struct rb_node **new, *parent = NULL;
+	struct tmem_obj *this;
+	int ret = 0;
+
+	new = &(root->rb_node);
+	while (*new) {
+		ASSERT(!RB_EMPTY_NODE(*new));
+		this = rb_entry(*new, struct tmem_obj, rb_tree_node);
+#ifdef WEIRD_BUG
+		WARN_ON(BAD_OBJ(this));
+#endif
+		parent = *new;
+		switch (tmem_oid_compare(&obj->oid, &this->oid)) {
+		case 0:
+#ifndef BROKEN_OID_COMPARE
+			{
+			static int cnt;
+			cnt++;
+			if (!(cnt&(cnt-1)))
+				pr_err("DJM tmem_obj_rb_insert dup, "
+					"cnt=%d, oid=%lx.%lx.%lx\n", cnt,
+					(unsigned long)obj->oid.oid[0],
+					(unsigned long)obj->oid.oid[1],
+					(unsigned long)obj->oid.oid[2]);
+			}
+#else
+			WARN_ON(1);
+#endif
+			goto out;
+		case -1:
+			new = &((*new)->rb_left);
+			break;
+		case 1:
+			new = &((*new)->rb_right);
+			break;
+		}
+	}
+#ifdef WEIRD_BUG
+	WARN_ON(BAD_OBJ(obj));
+#endif
+	rb_link_node(&obj->rb_tree_node, parent, new);
+	rb_insert_color(&obj->rb_tree_node, root);
+	ret = 1;
+out:
+	return ret;
+}
+
+/*
+ * allocate, initialize, and insert an tmem_object_root
+ * (should be called only if find failed)
+ */
+static struct tmem_obj *tmem_obj_new(struct tmem_pool *pool,
+					struct tmem_oid *oidp)
+{
+	struct tmem_obj *obj = NULL;
+
+	ASSERT(pool != NULL);
+	ASSERT_WRITELOCK(&pool->pool_rwlock);
+	obj = (*tmem_hostops.obj_alloc)(pool);
+	if (unlikely(obj == NULL))
+		goto out;
+	pool->obj_count++;
+	INIT_SADIX_TREE(&obj->tree_root, 0);
+	spin_lock_init(&obj->obj_spinlock);
+	obj->pool = pool;
+	obj->oid = *oidp;
+	obj->objnode_count = 0;
+	obj->pampd_count = 0;
+	SET_SENTINEL(obj, OBJ);
+	tmem_spin_lock(&obj->obj_spinlock);
+	tmem_obj_rb_insert(&pool->obj_rb_root[tmem_oid_hash(oidp)], obj);
+	ASSERT_SPINLOCK(&obj->obj_spinlock);
+out:
+	return obj;
+}
+
+/* free an object after destroying any pampds in it */
+static void tmem_obj_destroy(struct tmem_obj *obj)
+{
+	ASSERT_WRITELOCK(&obj->pool->pool_rwlock);
+	sadix_tree_destroy(&obj->tree_root, tmem_pampd_destroy,
+				tmem_stn_free, (void *)obj->pool);
+	tmem_obj_free(obj);
+}
+
+/* destroys all objs in a pool */
+static void tmem_pool_destroy_objs(struct tmem_pool *pool)
+{
+	struct rb_node *node;
+	struct tmem_obj *obj;
+	int i;
+
+	tmem_write_lock(&pool->pool_rwlock);
+	pool->is_valid = 0;
+	for (i = 0; i < OBJ_HASH_BUCKETS; i++) {
+		node = rb_first(&pool->obj_rb_root[i]);
+		while (node != NULL) {
+			obj = rb_entry(node, struct tmem_obj, rb_tree_node);
+			tmem_spin_lock(&obj->obj_spinlock);
+			node = rb_next(node);
+			tmem_obj_destroy(obj);
+		}
+	}
+	tmem_write_unlock(&pool->pool_rwlock);
+}
+
+/**********
+ * Tmem is managed as a set of tmem_pools with certain attributes, such as
+ * "ephemeral" vs "persistent".  These attributes apply to all tmem_objs
+ * and all pampds that belong to a tmem_pool.  A tmem_pool is created
+ * or deleted relatively rarely (for example, when a filesystem is
+ * mounted or unmounted.
+ */
+
+static struct tmem_pool *tmem_pool_alloc(uint32_t flags, uint32_t *ppoolid)
+{
+	struct tmem_pool *pool;
+	int i;
+
+	pool = (*tmem_hostops.pool_alloc)(flags, ppoolid);
+	if (unlikely(pool == NULL))
+		goto out;
+	for (i = 0; i < OBJ_HASH_BUCKETS; i++)
+		pool->obj_rb_root[i] = RB_ROOT;
+	INIT_LIST_HEAD(&pool->pool_list);
+	rwlock_init(&pool->pool_rwlock);
+	pool->obj_count = 0;
+	SET_SENTINEL(pool, POOL);
+out:
+	return pool;
+}
+
+static void tmem_pool_free(struct tmem_pool *pool)
+{
+	ASSERT_SENTINEL(pool, POOL);
+	INVERT_SENTINEL(pool, POOL);
+	list_del(&pool->pool_list);
+	(*tmem_hostops.pool_free)(pool);
+}
+
+/* flush all data from a pool and, optionally, free it */
+static void tmem_pool_flush(struct tmem_pool *pool, bool destroy)
+{
+	ASSERT(pool != NULL);
+	pr_info("%s %s tmem pool ",
+		destroy ? "destroying" : "flushing",
+		is_persistent(pool) ? "persistent" : "ephemeral");
+	pr_info("pool_id=%d\n", pool->pool_id);
+	tmem_pool_destroy_objs(pool);
+	if (destroy)
+		tmem_pool_free(pool);
+}
+
+/**********
+ * tmem_freeze guarantees that no additional pages are stored in tmem.
+ * (Ideally, this would also guarantee that no additional memory
+ * allocations occur.  However, I think a get or flush which causes a
+ * tree rebalance may result in one or more tmem_objnode allocations.)
+ * While tmem_freeze is not currently used, it might be used in the future
+ * to "shut off" tmem when memory is known NOT to be under pressure.
+ * Note that disabling tmem simply by stopping all puts/gets may
+ * result in incoherency if any pages are retained in a tmem pool
+ * and tmem is later enabled.
+ */
+static bool tmem_freeze_val;
+
+bool tmem_freeze(bool freeze)
+{
+	int old_tmem_freeze_val = tmem_freeze_val;
+
+	tmem_freeze_val = freeze;
+	return old_tmem_freeze_val;
+}
+
+/**********
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
+#ifdef WEIRD_BUG
+static DEFINE_PER_CPU(struct tmem_obj *, tmem_put_saved_obj);
+#endif
+static int do_tmem_put(struct tmem_pool *pool,struct tmem_oid *oidp,
+				uint32_t index, struct page *page)
+{
+	struct tmem_obj *obj = NULL, *objfound = NULL, *objnew = NULL;
+	void *pampd = NULL, *pampd_del = NULL;
+	int ret = -ENOMEM;
+	bool ephemeral;
+
+	ASSERT(pool != NULL);
+	tmem_trace(TMEM_PUT_PAGE, pool->pool_id, oidp, index);
+	ephemeral = is_ephemeral(pool);
+	if (tmem_freeze_val) {
+		/* if frozen, all puts turn into flushes, return failure */
+		ret = -1;
+		obj = tmem_obj_find(pool, oidp);
+		if (obj == NULL)
+			goto out;
+		pampd = tmem_pampd_delete_from_obj(obj, index);
+		if (pampd == NULL) {
+			tmem_spin_unlock(&obj->obj_spinlock);
+			goto out;
+		}
+		tmem_pampd_delete(pampd, pool);
+		if (obj->pampd_count == 0) {
+			tmem_write_lock(&pool->pool_rwlock);
+			tmem_obj_free(obj);
+			tmem_write_unlock(&pool->pool_rwlock);
+		} else
+			tmem_spin_unlock(&obj->obj_spinlock);
+		goto out;
+	}
+	obj = objfound = tmem_obj_find(pool, oidp);
+	if (obj != NULL) {
+		ASSERT_SPINLOCK(&objfound->obj_spinlock);
+		pampd = tmem_pampd_lookup_in_obj(objfound, index);
+		if (pampd != NULL) {
+			/* if found, is a dup put, flush the old one */
+			pampd_del = tmem_pampd_delete_from_obj(obj, index);
+			ASSERT(pampd_del == pampd);
+			tmem_pampd_delete(pampd, pool);
+			if (obj->pampd_count == 0) {
+				objnew = obj;
+				objfound = NULL;
+			}
+			pampd = NULL;
+		}
+	} else {
+		tmem_write_lock(&pool->pool_rwlock);
+		obj = objnew = tmem_obj_new(pool, oidp);
+		if (unlikely(obj == NULL)) {
+			tmem_write_unlock(&pool->pool_rwlock);
+			ret = -ENOMEM;
+			goto out;
+		}
+		ASSERT_SPINLOCK(&objnew->obj_spinlock);
+		tmem_write_unlock(&pool->pool_rwlock);
+	}
+	ASSERT(obj != NULL);
+	ASSERT(((objnew == obj) || (objfound == obj)) &&
+		(objnew != objfound));
+	ASSERT_SPINLOCK(&obj->obj_spinlock);
+#ifdef WEIRD_BUG
+	BUG_ON(BAD_OBJ(obj));
+	per_cpu(tmem_put_saved_obj, smp_processor_id()) = obj;	
+	/* the local variable obj somehow gets overwritten between here */
+	pampd = tmem_pampd_create(obj, index, page);
+	/* and here so reset it to a previously saved per-cpu value */
+	if (BAD_OBJ(obj)) {
+		static int cnt;
+		cnt++;
+		if (!(cnt&(cnt-1)))
+			pr_err("DJM obj fixing wacko obj 1, cnt=%d\n",cnt);
+		obj = get_cpu_var(tmem_put_saved_obj);
+		BUG_ON(BAD_OBJ(obj));
+	}
+	if (unlikely(pampd == NULL))
+		goto free;
+	if (BAD_OBJ(obj)) {
+		static int cnt;
+		cnt++;
+		if (!(cnt&(cnt-1)))
+			pr_err("DJM obj fixing wacko obj 2, cnt=%d\n",cnt);
+		obj = get_cpu_var(tmem_put_saved_obj);
+		BUG_ON(BAD_OBJ(obj));
+	}
+	ret = tmem_pampd_add_to_obj(obj, index, pampd);
+	if (BAD_OBJ(obj)) {
+		static int cnt;
+		cnt++;
+		if (!(cnt&(cnt-1)))
+			pr_err("DJM obj fixing wacko obj 3, cnt=%d\n",cnt);
+		obj = get_cpu_var(tmem_put_saved_obj);
+		BUG_ON(BAD_OBJ(obj));
+	}
+	if (unlikely(ret == -ENOMEM))
+		/* warning may result in partially built sadix tree ("stump") */
+		goto delete_and_free;
+	/* for WEIRD_BUG, don't ASSERT objnew == obj etc */
+#else
+	pampd = tmem_pampd_create(obj, index, page);
+	if (unlikely(pampd == NULL))
+		goto free;
+	ret = tmem_pampd_add_to_obj(obj, index, pampd);
+	if (unlikely(ret == -ENOMEM))
+		/* warning may result in partially built sadix tree ("stump") */
+		goto delete_and_free;
+	ASSERT(((objnew == obj) || (objfound == obj)) &&
+			(objnew != objfound));
+#endif
+	tmem_spin_unlock(&obj->obj_spinlock);
+	ASSERT(ret == 0);
+	goto out;
+
+delete_and_free:
+	ASSERT((obj != NULL) && (pampd != NULL));
+	(void)tmem_pampd_delete_from_obj(obj, index);
+free:
+	if (pampd)
+		tmem_pampd_delete(pampd, pool);
+	if (objfound)
+		tmem_spin_unlock(&objfound->obj_spinlock);
+	if (objnew) {
+		tmem_write_lock(&pool->pool_rwlock);
+		tmem_obj_free(objnew);
+		tmem_write_unlock(&pool->pool_rwlock);
+	}
+	ASSERT(ret != -EEXIST);
+out:
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
+static int do_tmem_get(struct tmem_pool *pool, struct tmem_oid *oidp,
+				uint32_t index, struct page *page)
+{
+	struct tmem_obj *obj;
+	void *pampd;
+	bool ephemeral = is_ephemeral(pool);
+	uint32_t ret = -1;
+
+	tmem_trace(TMEM_GET_PAGE, pool->pool_id, oidp, index);
+	obj = tmem_obj_find(pool, oidp);
+	if (obj == NULL)
+		goto out;
+	ASSERT_SPINLOCK(&obj->obj_spinlock);
+	ephemeral = is_ephemeral(pool);
+	if (ephemeral)
+		pampd = tmem_pampd_delete_from_obj(obj, index);
+	else
+		pampd = tmem_pampd_lookup_in_obj(obj, index);
+	if (pampd == NULL) {
+		tmem_spin_unlock(&obj->obj_spinlock);
+		goto out;
+	}
+	tmem_pampd_get_data(page, pampd, pool);
+	if (ephemeral) {
+		tmem_pampd_delete(pampd, pool);
+		if (obj->pampd_count == 0) {
+			tmem_write_lock(&pool->pool_rwlock);
+			tmem_obj_free(obj);
+			obj = NULL;
+			tmem_write_unlock(&pool->pool_rwlock);
+		}
+	}
+	if (obj != NULL)
+		tmem_spin_unlock(&obj->obj_spinlock);
+	ret = 0;
+out:
+	return ret;
+}
+
+/*
+ * If a page in tmem matches the handle, "flush" this page from tmem such
+ * that any subsequent "get" does not succeed (unless, of course, there
+ * was another "put" with the same handle).
+ */
+static int do_tmem_flush_page(struct tmem_pool *pool,
+				struct tmem_oid *oidp, uint32_t index)
+{
+	struct tmem_obj *obj;
+	void *pampd;
+	int ret = -1;
+
+	tmem_trace(TMEM_FLUSH_PAGE, pool->pool_id, oidp, index);
+	tmem_stat_inc(TMEM_STAT_flush_total);
+	obj = tmem_obj_find(pool, oidp);
+	if (obj == NULL)
+		goto out;
+	pampd = tmem_pampd_delete_from_obj(obj, index);
+	if (pampd == NULL) {
+		tmem_spin_unlock(&obj->obj_spinlock);
+		goto out;
+	}
+	tmem_pampd_delete(pampd, pool);
+	if (obj->pampd_count == 0) {
+		tmem_write_lock(&pool->pool_rwlock);
+		tmem_obj_free(obj);
+		tmem_write_unlock(&pool->pool_rwlock);
+	} else {
+		tmem_spin_unlock(&obj->obj_spinlock);
+	}
+	tmem_stat_inc(TMEM_STAT_flush_found);
+	ret = 0;
+
+out:
+	return ret;
+}
+
+/*
+ * "Flush" all pages in tmem matching this oid.
+ */
+static int do_tmem_flush_object(struct tmem_pool *pool,
+					struct tmem_oid *oidp)
+{
+	struct tmem_obj *obj;
+	int ret = -1;
+
+	tmem_trace(TMEM_FLUSH_OBJECT, pool->pool_id, oidp, 0);
+	tmem_stat_inc(TMEM_STAT_flobj_total);
+	obj = tmem_obj_find(pool, oidp);
+	if (obj == NULL)
+		goto out;
+	tmem_write_lock(&pool->pool_rwlock);
+	tmem_obj_destroy(obj);
+	tmem_stat_inc(TMEM_STAT_flobj_found);
+	tmem_write_unlock(&pool->pool_rwlock);
+	ret = 0;
+
+out:
+	return ret;
+}
+
+/*
+ * "Flush" all pages (and tmem_objs) from this tmem_pool and disable
+ * all subsequent access to this tmem_pool.
+ */
+static int do_tmem_destroy_pool(uint32_t pool_id)
+{
+	struct tmem_pool *pool = (*tmem_hostops.get_pool_by_id)(pool_id);
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
+/*
+ * Create a new tmem_pool with the provided flag and return
+ * a pool id provided by the tmem host implementation.
+ */
+static int do_tmem_new_pool(uint32_t flags)
+{
+	struct tmem_pool *pool;
+	int persistent = flags & TMEM_POOL_PERSIST;
+	int poolid = -ENOMEM;
+
+	pool = tmem_pool_alloc(flags, &poolid);
+	if (unlikely(pool == NULL))
+		goto out;
+	list_add_tail(&pool->pool_list, &tmem_global_pool_list);
+	pool->pool_id = poolid;
+	pool->persistent = persistent;
+	pool->is_valid = 1;
+out:
+	return poolid;
+}
+
+/*
+ * A tmem host implementation must use this function to register callbacks
+ * for "host services" (memory allocation/free and pool id translation).
+ * NB: The host must call sadix_tree_init() before registering hostops!
+ */
+
+void tmem_register_hostops(struct tmem_hostops *m)
+{
+	tmem_hostops = *m;
+}
+
+/*
+ * A "tmem host implementation" must use this function to register
+ * callbacks for a page-accessible memory (PAM) implementation
+ */
+void tmem_register_pamops(struct tmem_pamops *m)
+{
+	tmem_pamops = *m;
+}
+
+/**********
+ * Two kernel functionalities currently can be layered on top of tmem.
+ * These are "cleancache" which is used as a second-chance cache for clean
+ * page cache pages; and "frontswap" which is used for swap pages
+ * to avoid writes to disk.  A generic "shim" is provided here for each
+ * to translate in-kernel semantics to tmem semantics.  A tmem host
+ * implementation could provide its own shim(s) or can use these
+ * defaults simply by calling tmem_cleancache/frontswap_register_ops.
+ */
+
+#ifdef CONFIG_CLEANCACHE
+static void tmem_cleancache_put_page(int pool_id,
+					struct cleancache_filekey key,
+					pgoff_t index, struct page *page)
+{
+	u32 ind = (u32) index;
+	struct tmem_oid oid = *(struct tmem_oid *)&key;
+	struct tmem_pool *pool;
+
+	tmem_write_or_read_lock(&tmem_rwlock);
+	pool = (*tmem_hostops.get_pool_by_id)(pool_id);
+	if (unlikely(pool == NULL || ind != index))
+		goto out;
+	(void)do_tmem_put(pool, &oid, index, page);
+out:
+	tmem_write_or_read_unlock(&tmem_rwlock);
+}
+
+static int tmem_cleancache_get_page(int pool_id,
+					struct cleancache_filekey key,
+					pgoff_t index, struct page *page)
+{
+	u32 ind = (u32) index;
+	struct tmem_oid oid = *(struct tmem_oid *)&key;
+	struct tmem_pool *pool;
+	int ret = -1;
+
+	tmem_write_or_read_lock(&tmem_rwlock);
+	pool = (*tmem_hostops.get_pool_by_id)(pool_id);
+	if (unlikely(pool == NULL || ind != index))
+		goto out;
+	ret = do_tmem_get(pool, &oid, index, page);
+out:
+	tmem_write_or_read_unlock(&tmem_rwlock);
+	return ret;
+}
+
+static void tmem_cleancache_flush_page(int pool_id,
+					struct cleancache_filekey key,
+					pgoff_t index)
+{
+	u32 ind = (u32) index;
+	struct tmem_oid oid = *(struct tmem_oid *)&key;
+	struct tmem_pool *pool;
+
+	tmem_write_or_read_lock(&tmem_rwlock);
+	pool = (*tmem_hostops.get_pool_by_id)(pool_id);
+	if (unlikely(pool == NULL || ind != index))
+		goto out;
+	(void)do_tmem_flush_page(pool, &oid, ind);
+out:
+	tmem_write_or_read_unlock(&tmem_rwlock);
+}
+
+static void tmem_cleancache_flush_inode(int pool_id,
+					struct cleancache_filekey key)
+{
+	struct tmem_oid oid = *(struct tmem_oid *)&key;
+	struct tmem_pool *pool;
+
+	tmem_write_or_read_lock(&tmem_rwlock);
+	pool = (*tmem_hostops.get_pool_by_id)(pool_id);
+	if (unlikely(pool == NULL))
+		goto out;
+	(void)do_tmem_flush_object(pool, &oid);
+out:
+	tmem_write_or_read_unlock(&tmem_rwlock);
+}
+
+static void tmem_cleancache_flush_fs(int pool_id)
+{
+	if (pool_id < 0)
+		return;
+	write_lock(&tmem_rwlock);
+	(void)do_tmem_destroy_pool(pool_id);
+	write_unlock(&tmem_rwlock);
+}
+
+static int tmem_cleancache_init_fs(size_t pagesize)
+{
+	int poolid;
+
+	BUG_ON(sizeof(struct cleancache_filekey) !=
+				sizeof(struct tmem_oid));
+	BUG_ON(pagesize != PAGE_SIZE);
+	write_lock(&tmem_rwlock);
+	poolid = do_tmem_new_pool(0);
+	write_unlock(&tmem_rwlock);
+	return poolid;
+}
+
+static int tmem_cleancache_init_shared_fs(char *uuid, size_t pagesize)
+{
+	int poolid;
+
+	/* shared pools are unsupported and map to private */
+	BUG_ON(sizeof(struct cleancache_filekey) !=
+				sizeof(struct tmem_oid));
+	BUG_ON(pagesize != PAGE_SIZE);
+	write_lock(&tmem_rwlock);
+	poolid = do_tmem_new_pool(0);
+	write_unlock(&tmem_rwlock);
+	return poolid;
+}
+
+static struct cleancache_ops tmem_cleancache_ops = {
+	.put_page = tmem_cleancache_put_page,
+	.get_page = tmem_cleancache_get_page,
+	.flush_page = tmem_cleancache_flush_page,
+	.flush_inode = tmem_cleancache_flush_inode,
+	.flush_fs = tmem_cleancache_flush_fs,
+	.init_shared_fs = tmem_cleancache_init_shared_fs,
+	.init_fs = tmem_cleancache_init_fs
+};
+
+struct cleancache_ops tmem_cleancache_register_ops(void)
+{
+	struct cleancache_ops old_ops =
+		cleancache_register_ops(&tmem_cleancache_ops);
+
+	return old_ops;
+}
+#endif
+
+#ifdef CONFIG_FRONTSWAP
+/* a single tmem poolid is used for all frontswap "types" (swapfiles) */
+static int tmem_frontswap_poolid = -1;
+
+/*
+ * Swizzling increases objects per swaptype, increasing tmem concurrency
+ * for heavy swaploads.  Later, larger nr_cpus -> larger SWIZ_BITS
+ */
+#define SWIZ_BITS		4
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
+/* returns 0 if the page was successfully put into frontswap, -1 if not */
+static int tmem_frontswap_put_page(unsigned type, pgoff_t offset,
+				   struct page *page)
+{
+	u64 ind64 = (u64)offset;
+	u32 ind = (u32)offset;
+	struct tmem_oid oid = oswiz(type, ind);
+	struct tmem_pool *pool;
+	int ret = -1;
+
+	tmem_write_or_read_lock(&tmem_rwlock);
+	pool = (*tmem_hostops.get_pool_by_id)(tmem_frontswap_poolid);
+	if (unlikely(pool == NULL || ind64 != ind))
+		goto out;
+	ret = do_tmem_put(pool, &oid, iswiz(ind), page);
+out:
+	tmem_write_or_read_unlock(&tmem_rwlock);
+	return ret;
+}
+
+/* returns 0 if the page was successfully gotten from frontswap, -1 if
+ * was not present (should never happen!) */
+static int tmem_frontswap_get_page(unsigned type, pgoff_t offset,
+				   struct page *page)
+{
+	u64 ind64 = (u64)offset;
+	u32 ind = (u32)offset;
+	struct tmem_oid oid = oswiz(type, ind);
+	struct tmem_pool *pool;
+	int ret = -1;
+
+	tmem_write_or_read_lock(&tmem_rwlock);
+	pool = (*tmem_hostops.get_pool_by_id)(tmem_frontswap_poolid);
+	if (unlikely(pool == NULL || ind64 != ind))
+		goto out;
+	ret = do_tmem_get(pool, &oid, iswiz(ind), page);
+out:
+	tmem_write_or_read_unlock(&tmem_rwlock);
+	return ret;
+}
+
+/* flush a single page from frontswap */
+static void tmem_frontswap_flush_page(unsigned type, pgoff_t offset)
+{
+	u64 ind64 = (u64)offset;
+	u32 ind = (u32)offset;
+	struct tmem_oid oid = oswiz(type, ind);
+	struct tmem_pool *pool;
+
+	tmem_write_or_read_lock(&tmem_rwlock);
+	pool = (*tmem_hostops.get_pool_by_id)(tmem_frontswap_poolid);
+	if (unlikely(pool == NULL || ind64 != ind))
+		goto out;
+	(void)do_tmem_flush_page(pool, &oid, iswiz(ind));
+out:
+	tmem_write_or_read_unlock(&tmem_rwlock);
+}
+
+/* flush all pages from the passed swaptype */
+static void tmem_frontswap_flush_area(unsigned type)
+{
+	struct tmem_oid oid;
+	struct tmem_pool *pool;
+	int ind;
+
+	pool = (*tmem_hostops.get_pool_by_id)(tmem_frontswap_poolid);
+	tmem_write_or_read_lock(&tmem_rwlock);
+	if (unlikely(pool == NULL))
+		goto out;
+	for (ind = SWIZ_MASK; ind >= 0; ind--) {
+		oid = oswiz(type, ind);
+		(void)do_tmem_flush_object(pool, &oid);
+	}
+out:
+	tmem_write_or_read_unlock(&tmem_rwlock);
+}
+
+static void tmem_frontswap_init(unsigned ignored)
+{
+	/* a single tmem poolid is used for all frontswap "types" (swapfiles) */
+	write_lock(&tmem_rwlock);
+	if (tmem_frontswap_poolid < 0)
+		tmem_frontswap_poolid = do_tmem_new_pool(TMEM_POOL_PERSIST);
+	write_unlock(&tmem_rwlock);
+}
+
+static struct frontswap_ops tmem_frontswap_ops = {
+	.put_page = tmem_frontswap_put_page,
+	.get_page = tmem_frontswap_get_page,
+	.flush_page = tmem_frontswap_flush_page,
+	.flush_area = tmem_frontswap_flush_area,
+	.init = tmem_frontswap_init
+};
+
+struct frontswap_ops tmem_frontswap_register_ops(void)
+{
+	struct frontswap_ops old_ops =
+		frontswap_register_ops(&tmem_frontswap_ops);
+
+	return old_ops;
+}
+#endif
--- linux-2.6.36/drivers/staging/kztmem/tmem.h	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.36-kztmem/drivers/staging/kztmem/tmem.h	2010-12-07 10:06:43.000000000 -0700
@@ -0,0 +1,135 @@
+/*
+ * tmem.h
+ *
+ * Copyright (c) 2010, Dan Magenheimer, Oracle Corp.
+ */
+
+#ifndef _TMEM_H_
+#define _TMEM_H_
+
+#include <linux/types.h>
+#include <linux/highmem.h>
+#include "sadix-tree.h"
+
+#define SENTINELS
+#ifdef SENTINELS
+#define DECL_SENTINEL uint32_t sentinel;
+#define SET_SENTINEL(_x, _y) (_x->sentinel = _y##_SENTINEL)
+#define INVERT_SENTINEL(_x, _y) (_x->sentinel = ~_y##_SENTINEL)
+#define ASSERT_SENTINEL(_x, _y) ASSERT(_x->sentinel == _y##_SENTINEL)
+#define ASSERT_INVERTED_SENTINEL(_x, _y) ASSERT(_x->sentinel == ~_y##_SENTINEL)
+#else
+#define DECL_SENTINEL
+#define SET_SENTINEL(_x, _y) do { } while (0)
+#define ASSERT_SENTINEL(_x, _y) do { } while (0)
+#define INVERT_SENTINEL(_x, _y) do { } while (0)
+#endif
+
+/*
+ * These are pre-defined by the Xen<->Linux ABI
+ */
+#define TMEM_PUT_PAGE			4
+#define TMEM_GET_PAGE			5
+#define TMEM_FLUSH_PAGE			6
+#define TMEM_FLUSH_OBJECT		7
+#define TMEM_POOL_PERSIST		1
+#define TMEM_POOL_PRECOMPRESSED		4
+#define TMEM_POOL_PAGESIZE_SHIFT	4
+#define TMEM_POOL_PAGESIZE_MASK		0xf
+#define TMEM_POOL_RESERVED_BITS		0x00ffff00
+
+struct tmem_pool;
+struct tmem_obj;
+struct tmem_objnode;
+
+struct tmem_pamops {
+	void (*get_data)(struct page *, void *, void *);
+	uint32_t (*get_index)(void *, void *);
+	struct tmem_obj *(*get_obj)(void *, void *);
+	void (*free)(void *, struct tmem_pool *);
+	void (*prune)(void *);
+	void *(*create)(void *, uint32_t, struct page *, void *);
+};
+
+struct tmem_hostops {
+	struct tmem_pool *(*get_pool_by_id)(uint32_t);
+	struct tmem_obj *(*obj_alloc)(struct tmem_pool *);
+	void (*obj_free)(struct tmem_obj *, struct tmem_pool *);
+	struct tmem_objnode *(*objnode_alloc)(struct tmem_pool *);
+	void (*objnode_free)(struct tmem_objnode *, struct tmem_pool *);
+	struct tmem_pool *(*pool_alloc)(uint32_t, uint32_t *);
+	void (*pool_free)(struct tmem_pool *);
+};
+
+#define OBJ_HASH_BUCKETS 256 /* must be power of two */
+#define OBJ_HASH_BUCKETS_MASK (OBJ_HASH_BUCKETS-1)
+
+#define SENTINELS
+#ifdef SENTINELS
+#define DECL_SENTINEL uint32_t sentinel;
+#else
+#define DECL_SENTINEL
+#endif
+
+#define POOL_SENTINEL 0x87658765
+#define OBJ_SENTINEL 0x12345678
+#define OBJNODE_SENTINEL 0xfedcba09
+
+struct tmem_pool {
+	bool persistent;
+	bool is_valid;
+	void *client; /* "up" for some clients, avoids table lookup */
+	struct list_head pool_list;
+	uint32_t pool_id;
+	rwlock_t pool_rwlock;
+	struct rb_root
+	  obj_rb_root[OBJ_HASH_BUCKETS]; /* protected by pool_rwlock */
+	long obj_count;  /* atomicity: pool_rwlock held for write */
+	DECL_SENTINEL
+};
+static LIST_HEAD(tmem_global_pool_list);
+
+#define is_persistent(_p)  (_p->persistent)
+#define is_ephemeral(_p)   (!(_p->persistent))
+
+struct tmem_oid {
+	uint64_t oid[3];
+};
+
+struct tmem_obj {
+	DECL_SENTINEL
+	struct tmem_oid oid;
+	struct rb_node rb_tree_node; /* protected by pool->pool_rwlock */
+	unsigned long objnode_count; /* atomicity depends on obj_spinlock */
+	long pampd_count; /* atomicity depends on obj_spinlock */
+	struct sadix_tree_root tree_root; /* tree of pages within object */
+	struct tmem_pool *pool;
+	spinlock_t obj_spinlock;
+};
+
+struct tmem_objnode {
+	struct tmem_obj *obj;
+	DECL_SENTINEL
+	struct sadix_tree_node tmem_stn;
+};
+
+extern void tmem_register_hostops(struct tmem_hostops *m);
+extern void tmem_register_pamops(struct tmem_pamops *m);
+extern struct frontswap_ops tmem_frontswap_register_ops(void);
+extern struct cleancache_ops tmem_cleancache_register_ops(void);
+extern void tmem_pampd_prune(void *);
+extern void tmem_shrink_lock(void);
+extern int tmem_shrink_trylock(void);
+extern void tmem_shrink_unlock(void);
+extern bool tmem_freeze(bool);
+
+/* bookkeeping */
+#define TMEM_STAT_flush_total		0
+#define TMEM_STAT_flush_found		1
+#define TMEM_STAT_flobj_total		2
+#define TMEM_STAT_flobj_found		3
+#define TMEM_STAT_MAX_STAT		3
+#define TMEM_STAT_NSTATS		(TMEM_STAT_MAX_STAT+1)
+extern unsigned long tmem_stat_get(int);
+
+#endif /* _TMEM_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
