Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id AD3456B0083
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 10:54:27 -0500 (EST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH 4/6] staging: ramster: ramster-specific changes to zcache/tmem
Date: Wed, 15 Feb 2012 07:54:18 -0800
Message-Id: <1329321260-15222-5-git-send-email-dan.magenheimer@oracle.com>
In-Reply-To: <1329321260-15222-1-git-send-email-dan.magenheimer@oracle.com>
References: <1329321260-15222-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, dan.magenheimer@oracle.com

RAMster implements peer-to-peer transcendent memory, allowing a "cluster"
of kernels to dynamically pool their RAM.

This patch incorporates changes transforming zcache to work with
a remote store.

In tmem.[ch], new "repatriate" (provoke async get) and "localify" (handle
incoming data resulting from an async get) routines combine with a handful
of changes to existing pamops interfaces allow the generic tmem code
to support asynchronous operations.  Also, a new tmem_xhandle struct
groups together key information that must be passed to remote tmem stores.

Zcache-main.c is augmented with a large amount of ramster-specific code
to handle remote operations and "foreign" pages on both ends of the
"remotify" protocol.  New "foreign" pools are auto-created on demand.
A "selfshrinker" thread periodically repatriates remote persistent pages
when local memory conditions allow.  For certain operations, a queue is
necessary to guarantee strict ordering as out-of-order puts/flushes can
cause strange race conditions.  Pampd pointers now either point to local
memory OR describe a remote page; to allow the same 64-bits to describe
either, the LSB is used to differentiate.  Some acrobatics must be performed
to ensure local memory is available to handle a remote persistent get,
or deal with the data directly anyway if the malloc failed.  Lots
of ramster-specific statistics are available via sysfs.

Note: Some debug ifdefs left in for now.
Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
---
 drivers/staging/ramster/Kconfig       |   18 +-
 drivers/staging/ramster/Makefile      |    4 +-
 drivers/staging/ramster/tmem.c        |  115 ++-
 drivers/staging/ramster/tmem.h        |   46 +-
 drivers/staging/ramster/zcache-main.c | 1844 ++++++++++++++++++++++++++++-----
 5 files changed, 1738 insertions(+), 289 deletions(-)

diff --git a/drivers/staging/ramster/Kconfig b/drivers/staging/ramster/Kconfig
index 7fabcb2..acfb974 100644
--- a/drivers/staging/ramster/Kconfig
+++ b/drivers/staging/ramster/Kconfig
@@ -1,13 +1,13 @@
-config ZCACHE
-	tristate "Dynamic compression of swap pages and clean pagecache pages"
-	depends on CLEANCACHE || FRONTSWAP
-	select XVMALLOC
+config RAMSTER
+	bool "Cross-machine RAM capacity sharing, aka peer-to-peer tmem"
+	depends on (CLEANCACHE || FRONTSWAP) && CONFIGFS_FS && !ZCACHE && !XVMALLOC && !HIGHMEM
 	select LZO_COMPRESS
 	select LZO_DECOMPRESS
 	default n
 	help
-	  Zcache doubles RAM efficiency while providing a significant
-	  performance boosts on many workloads.  Zcache uses lzo1x
-	  compression and an in-kernel implementation of transcendent
-	  memory to store clean page cache pages and swap in RAM,
-	  providing a noticeable reduction in disk I/O.
+	  RAMster allows RAM on other machines in a cluster to be utilized
+	  dynamically and symmetrically instead of swapping to a local swap
+	  disk, thus improving performance on memory-constrained workloads
+	  while minimizing total RAM across the cluster.  RAMster, like
+	  zcache, compresses swap pages into local RAM, but then remotifies
+	  the compressed pages to another node in the RAMster cluster.
diff --git a/drivers/staging/ramster/Makefile b/drivers/staging/ramster/Makefile
index 60daa27..bcc13c8 100644
--- a/drivers/staging/ramster/Makefile
+++ b/drivers/staging/ramster/Makefile
@@ -1,3 +1 @@
-zcache-y	:=	zcache-main.o tmem.o
-
-obj-$(CONFIG_ZCACHE)	+=	zcache.o
+obj-$(CONFIG_RAMSTER)	+=	zcache-main.o tmem.o r2net.o xvmalloc.o cluster/
diff --git a/drivers/staging/ramster/tmem.c b/drivers/staging/ramster/tmem.c
index 1ca66ea..8f2f689 100644
--- a/drivers/staging/ramster/tmem.c
+++ b/drivers/staging/ramster/tmem.c
@@ -27,6 +27,7 @@
 #include <linux/list.h>
 #include <linux/spinlock.h>
 #include <linux/atomic.h>
+#include <linux/delay.h>
 
 #include "tmem.h"
 
@@ -316,7 +317,7 @@ static void *tmem_pampd_lookup_in_obj(struct tmem_obj *obj, uint32_t index)
 }
 
 static void *tmem_pampd_replace_in_obj(struct tmem_obj *obj, uint32_t index,
-					void *new_pampd)
+					void *new_pampd, bool no_free)
 {
 	struct tmem_objnode **slot;
 	void *ret = NULL;
@@ -325,7 +326,9 @@ static void *tmem_pampd_replace_in_obj(struct tmem_obj *obj, uint32_t index,
 	if ((slot != NULL) && (*slot != NULL)) {
 		void *old_pampd = *(void **)slot;
 		*(void **)slot = new_pampd;
-		(*tmem_pamops.free)(old_pampd, obj->pool, NULL, 0);
+		if (!no_free)
+			(*tmem_pamops.free)(old_pampd, obj->pool,
+						NULL, 0, false);
 		ret = new_pampd;
 	}
 	return ret;
@@ -481,7 +484,7 @@ static void tmem_objnode_node_destroy(struct tmem_obj *obj,
 			if (ht == 1) {
 				obj->pampd_count--;
 				(*tmem_pamops.free)(objnode->slots[i],
-						obj->pool, NULL, 0);
+						obj->pool, NULL, 0, true);
 				objnode->slots[i] = NULL;
 				continue;
 			}
@@ -498,7 +501,8 @@ static void tmem_pampd_destroy_all_in_obj(struct tmem_obj *obj)
 		return;
 	if (obj->objnode_tree_height == 0) {
 		obj->pampd_count--;
-		(*tmem_pamops.free)(obj->objnode_tree_root, obj->pool, NULL, 0);
+		(*tmem_pamops.free)(obj->objnode_tree_root,
+					obj->pool, NULL, 0, true);
 	} else {
 		tmem_objnode_node_destroy(obj, obj->objnode_tree_root,
 					obj->objnode_tree_height);
@@ -529,7 +533,7 @@ static void tmem_pampd_destroy_all_in_obj(struct tmem_obj *obj)
  * always flushes for simplicity.
  */
 int tmem_put(struct tmem_pool *pool, struct tmem_oid *oidp, uint32_t index,
-		char *data, size_t size, bool raw, bool ephemeral)
+		char *data, size_t size, bool raw, int ephemeral)
 {
 	struct tmem_obj *obj = NULL, *objfound = NULL, *objnew = NULL;
 	void *pampd = NULL, *pampd_del = NULL;
@@ -545,7 +549,7 @@ int tmem_put(struct tmem_pool *pool, struct tmem_oid *oidp, uint32_t index,
 			/* if found, is a dup put, flush the old one */
 			pampd_del = tmem_pampd_delete_from_obj(obj, index);
 			BUG_ON(pampd_del != pampd);
-			(*tmem_pamops.free)(pampd, pool, oidp, index);
+			(*tmem_pamops.free)(pampd, pool, oidp, index, true);
 			if (obj->pampd_count == 0) {
 				objnew = obj;
 				objfound = NULL;
@@ -576,7 +580,7 @@ delete_and_free:
 	(void)tmem_pampd_delete_from_obj(obj, index);
 free:
 	if (pampd)
-		(*tmem_pamops.free)(pampd, pool, NULL, 0);
+		(*tmem_pamops.free)(pampd, pool, NULL, 0, true);
 	if (objnew) {
 		tmem_obj_free(objnew, hb);
 		(*tmem_hostops.obj_free)(objnew, pool);
@@ -586,6 +590,65 @@ out:
 	return ret;
 }
 
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
+	} else if (delete) {
+		BUG_ON(obj == NULL);
+		(void)tmem_pampd_delete_from_obj(obj, index);
+	}
+	spin_unlock(&hb->lock);
+}
+
+static int tmem_repatriate(void **ppampd, struct tmem_hashbucket *hb,
+				struct tmem_pool *pool, struct tmem_oid *oidp,
+				uint32_t index, bool free, char *data)
+{
+	void *old_pampd = *ppampd, *new_pampd = NULL;
+	bool intransit = false;
+	int ret = 0;
+
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
+	return ret;
+}
+
 /*
  * "Get" a page, e.g. if one can be found, copy the tmem page with the
  * matching handle from PAM space to the kernel.  By tmem definition,
@@ -607,14 +670,36 @@ int tmem_get(struct tmem_pool *pool, struct tmem_oid *oidp, uint32_t index,
 	int ret = -1;
 	struct tmem_hashbucket *hb;
 	bool free = (get_and_free == 1) || ((get_and_free == 0) && ephemeral);
-	bool lock_held = false;
+	bool lock_held = 0;
+	void **ppampd;
 
+again:
 	hb = &pool->hashbucket[tmem_oid_hash(oidp)];
 	spin_lock(&hb->lock);
-	lock_held = true;
+	lock_held = 1;
 	obj = tmem_obj_find(hb, oidp);
 	if (obj == NULL)
 		goto out;
+	ppampd = __tmem_pampd_lookup_in_obj(obj, index);
+	if (ppampd == NULL)
+		goto out;
+	if (tmem_pamops.is_remote(*ppampd)) {
+		ret = tmem_repatriate(ppampd, hb, pool, oidp,
+					index, free, data);
+		lock_held = 0; /* note hb->lock has been unlocked */
+		if (ret == -EAGAIN) {
+			/* rare I think, but should cond_resched()??? */
+			usleep_range(10, 1000);
+			goto again;
+		} else if (ret != 0) {
+			if (ret != -ENOENT)
+				pr_err("UNTESTED case in tmem_get, ret=%d\n",
+						ret);
+			ret = -1;
+			goto out;
+		}
+		goto out;
+	}
 	if (free)
 		pampd = tmem_pampd_delete_from_obj(obj, index);
 	else
@@ -628,10 +713,6 @@ int tmem_get(struct tmem_pool *pool, struct tmem_oid *oidp, uint32_t index,
 			obj = NULL;
 		}
 	}
-	if (tmem_pamops.is_remote(pampd)) {
-		lock_held = false;
-		spin_unlock(&hb->lock);
-	}
 	if (free)
 		ret = (*tmem_pamops.get_data_and_free)(
 				data, size, raw, pampd, pool, oidp, index);
@@ -668,7 +749,7 @@ int tmem_flush_page(struct tmem_pool *pool,
 	pampd = tmem_pampd_delete_from_obj(obj, index);
 	if (pampd == NULL)
 		goto out;
-	(*tmem_pamops.free)(pampd, pool, oidp, index);
+	(*tmem_pamops.free)(pampd, pool, oidp, index, true);
 	if (obj->pampd_count == 0) {
 		tmem_obj_free(obj, hb);
 		(*tmem_hostops.obj_free)(obj, pool);
@@ -682,8 +763,8 @@ out:
 
 /*
  * If a page in tmem matches the handle, replace the page so that any
- * subsequent "get" gets the new page.  Returns 0 if
- * there was a page to replace, else returns -1.
+ * subsequent "get" gets the new page.  Returns the new page if
+ * there was a page to replace, else returns NULL.
  */
 int tmem_replace(struct tmem_pool *pool, struct tmem_oid *oidp,
 			uint32_t index, void *new_pampd)
@@ -697,7 +778,7 @@ int tmem_replace(struct tmem_pool *pool, struct tmem_oid *oidp,
 	obj = tmem_obj_find(hb, oidp);
 	if (obj == NULL)
 		goto out;
-	new_pampd = tmem_pampd_replace_in_obj(obj, index, new_pampd);
+	new_pampd = tmem_pampd_replace_in_obj(obj, index, new_pampd, 0);
 	ret = (*tmem_pamops.replace_in_obj)(new_pampd, obj);
 out:
 	spin_unlock(&hb->lock);
diff --git a/drivers/staging/ramster/tmem.h b/drivers/staging/ramster/tmem.h
index ed147c4..47f1918 100644
--- a/drivers/staging/ramster/tmem.h
+++ b/drivers/staging/ramster/tmem.h
@@ -9,7 +9,6 @@
 #ifndef _TMEM_H_
 #define _TMEM_H_
 
-#include <linux/types.h>
 #include <linux/highmem.h>
 #include <linux/hash.h>
 #include <linux/atomic.h>
@@ -89,6 +88,31 @@ struct tmem_oid {
 	uint64_t oid[3];
 };
 
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
+
 static inline void tmem_oid_set_invalid(struct tmem_oid *oidp)
 {
 	oidp->oid[0] = oidp->oid[1] = oidp->oid[2] = -1UL;
@@ -147,7 +171,11 @@ struct tmem_obj {
 	unsigned int objnode_tree_height;
 	unsigned long objnode_count;
 	long pampd_count;
-	void *extra; /* for private use by pampd implementation */
+	/* for current design of ramster, all pages belonging to
+	 * an object reside on the same remotenode and extra is
+	 * used to record the number of the remotenode so a
+	 * flush-object operation can specify it */
+	void *extra; /* for use by pampd implementation */
 	DECL_SENTINEL
 };
 
@@ -174,9 +202,14 @@ struct tmem_pamops {
 	int (*get_data_and_free)(char *, size_t *, bool, void *,
 				struct tmem_pool *, struct tmem_oid *,
 				uint32_t);
-	void (*free)(void *, struct tmem_pool *, struct tmem_oid *, uint32_t);
+	void (*free)(void *, struct tmem_pool *,
+				struct tmem_oid *, uint32_t, bool);
 	void (*free_obj)(struct tmem_pool *, struct tmem_obj *);
 	bool (*is_remote)(void *);
+	void *(*repatriate_preload)(void *, struct tmem_pool *,
+					struct tmem_oid *, uint32_t, bool *);
+	int (*repatriate)(void *, void *, struct tmem_pool *,
+				struct tmem_oid *, uint32_t, bool, void *);
 	void (*new_obj)(struct tmem_obj *);
 	int (*replace_in_obj)(void *, struct tmem_obj *);
 };
@@ -193,11 +226,16 @@ extern void tmem_register_hostops(struct tmem_hostops *m);
 
 /* core tmem accessor functions */
 extern int tmem_put(struct tmem_pool *, struct tmem_oid *, uint32_t index,
-			char *, size_t, bool, bool);
+			char *, size_t, bool, int);
 extern int tmem_get(struct tmem_pool *, struct tmem_oid *, uint32_t index,
 			char *, size_t *, bool, int);
 extern int tmem_replace(struct tmem_pool *, struct tmem_oid *, uint32_t index,
 			void *);
+extern void *tmem_localify_get_pampd(struct tmem_pool *, struct tmem_oid *,
+				   uint32_t index, struct tmem_obj **,
+				   void **);
+extern void tmem_localify_finish(struct tmem_obj *, uint32_t index,
+				 void *, void *, bool);
 extern int tmem_flush_page(struct tmem_pool *, struct tmem_oid *,
 			uint32_t index);
 extern int tmem_flush_object(struct tmem_pool *, struct tmem_oid *);
diff --git a/drivers/staging/ramster/zcache-main.c b/drivers/staging/ramster/zcache-main.c
index 49c8791..36d53ed 100644
--- a/drivers/staging/ramster/zcache-main.c
+++ b/drivers/staging/ramster/zcache-main.c
@@ -1,7 +1,7 @@
 /*
  * zcache.c
  *
- * Copyright (c) 2010,2011, Dan Magenheimer, Oracle Corp.
+ * Copyright (c) 2010-2012, Dan Magenheimer, Oracle Corp.
  * Copyright (c) 2010,2011, Nitin Gupta
  *
  * Zcache provides an in-kernel "host implementation" for transcendent memory
@@ -17,6 +17,9 @@
  *
  * [1] For a definition of page-accessible memory (aka PAM), see:
  *   http://marc.info/?l=linux-mm&m=127811271605009
+ *  RAMSTER TODO:
+ *   - handle remotifying of buddied pages (see zbud_remotify_zbpg)
+ *   - kernel boot params: nocleancache/nofrontswap don't always work?!?
  */
 
 #include <linux/module.h>
@@ -30,11 +33,16 @@
 #include <linux/atomic.h>
 #include <linux/math64.h>
 #include "tmem.h"
+#include "zcache.h"
+#include "ramster.h"
+#include "cluster/tcp.h"
 
-#include "../zram/xvmalloc.h" /* if built in drivers/staging */
+#include "xvmalloc.h"	/* temporary until change to zsmalloc */
+
+#define	RAMSTER_TESTING
 
 #if (!defined(CONFIG_CLEANCACHE) && !defined(CONFIG_FRONTSWAP))
-#error "zcache is useless without CONFIG_CLEANCACHE or CONFIG_FRONTSWAP"
+#error "ramster is useless without CONFIG_CLEANCACHE or CONFIG_FRONTSWAP"
 #endif
 #ifdef CONFIG_CLEANCACHE
 #include <linux/cleancache.h>
@@ -43,6 +51,61 @@
 #include <linux/frontswap.h>
 #endif
 
+enum ramster_remotify_op {
+	RAMSTER_REMOTIFY_EPH_PUT,
+	RAMSTER_REMOTIFY_PERS_PUT,
+	RAMSTER_REMOTIFY_FLUSH_PAGE,
+	RAMSTER_REMOTIFY_FLUSH_OBJ,
+	RAMSTER_INTRANSIT_PERS
+};
+
+struct ramster_remotify_hdr {
+	enum ramster_remotify_op op;
+	struct list_head list;
+};
+
+#define ZBH_SENTINEL  0x43214321
+#define ZBPG_SENTINEL  0xdeadbeef
+
+#define ZBUD_MAX_BUDS 2
+
+struct zbud_hdr {
+	struct ramster_remotify_hdr rem_op;
+	uint16_t client_id;
+	uint16_t pool_id;
+	struct tmem_oid oid;
+	uint32_t index;
+	uint16_t size; /* compressed size in bytes, zero means unused */
+	DECL_SENTINEL
+};
+
+#define ZVH_SENTINEL  0x43214321
+static const int zv_max_page_size = (PAGE_SIZE / 8) * 7;
+
+struct zv_hdr {
+	struct ramster_remotify_hdr rem_op;
+	uint16_t client_id;
+	uint16_t pool_id;
+	struct tmem_oid oid;
+	uint32_t index;
+	DECL_SENTINEL
+};
+
+struct flushlist_node {
+	struct ramster_remotify_hdr rem_op;
+	struct tmem_xhandle xh;
+};
+
+union {
+	struct ramster_remotify_hdr rem_op;
+	struct zv_hdr zv;
+	struct zbud_hdr zbud;
+	struct flushlist_node flist;
+} remotify_list_node;
+
+static LIST_HEAD(zcache_rem_op_list);
+static DEFINE_SPINLOCK(zcache_rem_op_list_lock);
+
 #if 0
 /* this is more aggressive but may cause other problems? */
 #define ZCACHE_GFP_MASK	(GFP_ATOMIC | __GFP_NORETRY | __GFP_NOWARN)
@@ -98,20 +161,6 @@ static inline bool is_local_client(struct zcache_client *cli)
  * read or written unless the zbpg's lock is held.
  */
 
-#define ZBH_SENTINEL  0x43214321
-#define ZBPG_SENTINEL  0xdeadbeef
-
-#define ZBUD_MAX_BUDS 2
-
-struct zbud_hdr {
-	uint16_t client_id;
-	uint16_t pool_id;
-	struct tmem_oid oid;
-	uint32_t index;
-	uint16_t size; /* compressed size in bytes, zero means unused */
-	DECL_SENTINEL
-};
-
 struct zbud_page {
 	struct list_head bud_list;
 	spinlock_t lock;
@@ -141,20 +190,43 @@ static unsigned long zcache_zbud_buddied_count;
 /* protects the buddied list and all unbuddied lists */
 static DEFINE_SPINLOCK(zbud_budlists_spinlock);
 
-static LIST_HEAD(zbpg_unused_list);
-static unsigned long zcache_zbpg_unused_list_count;
-
-/* protects the unused page list */
-static DEFINE_SPINLOCK(zbpg_unused_list_spinlock);
-
 static atomic_t zcache_zbud_curr_raw_pages;
 static atomic_t zcache_zbud_curr_zpages;
 static unsigned long zcache_zbud_curr_zbytes;
 static unsigned long zcache_zbud_cumul_zpages;
 static unsigned long zcache_zbud_cumul_zbytes;
 static unsigned long zcache_compress_poor;
+static unsigned long zcache_policy_percent_exceeded;
 static unsigned long zcache_mean_compress_poor;
 
+/*
+ * RAMster counters
+ * - Remote pages are pages with a local pampd but the data is remote
+ * - Foreign pages are pages stored locally but belonging to another node
+ */
+static atomic_t ramster_remote_pers_pages = ATOMIC_INIT(0);
+static unsigned long ramster_pers_remotify_enable;
+static unsigned long ramster_eph_remotify_enable;
+static unsigned long ramster_eph_pages_remoted;
+static unsigned long ramster_eph_pages_remote_failed;
+static unsigned long ramster_pers_pages_remoted;
+static unsigned long ramster_pers_pages_remote_failed;
+static unsigned long ramster_pers_pages_remote_nomem;
+static unsigned long ramster_remote_objects_flushed;
+static unsigned long ramster_remote_object_flushes_failed;
+static unsigned long ramster_remote_pages_flushed;
+static unsigned long ramster_remote_page_flushes_failed;
+static unsigned long ramster_remote_eph_pages_succ_get;
+static unsigned long ramster_remote_pers_pages_succ_get;
+static unsigned long ramster_remote_eph_pages_unsucc_get;
+static unsigned long ramster_remote_pers_pages_unsucc_get;
+static atomic_t ramster_curr_flnode_count = ATOMIC_INIT(0);
+static unsigned long ramster_curr_flnode_count_max;
+static atomic_t ramster_foreign_eph_pampd_count = ATOMIC_INIT(0);
+static unsigned long ramster_foreign_eph_pampd_count_max;
+static atomic_t ramster_foreign_pers_pampd_count = ATOMIC_INIT(0);
+static unsigned long ramster_foreign_pers_pampd_count_max;
+
 /* forward references */
 static void *zcache_get_free_page(void);
 static void zcache_free_page(void *p);
@@ -210,6 +282,29 @@ static char *zbud_data(struct zbud_hdr *zh, unsigned size)
 	return p;
 }
 
+static void zbud_copy_from_pampd(char *data, size_t *size, struct zbud_hdr *zh)
+{
+	struct zbud_page *zbpg;
+	char *p;
+	unsigned budnum;
+
+	ASSERT_SENTINEL(zh, ZBH);
+	budnum = zbud_budnum(zh);
+	zbpg = container_of(zh, struct zbud_page, buddy[budnum]);
+	spin_lock(&zbpg->lock);
+	BUG_ON(zh->size > *size);
+	p = (char *)zbpg;
+	if (budnum == 0)
+		p += ((sizeof(struct zbud_page) + CHUNK_SIZE - 1) &
+							CHUNK_MASK);
+	else if (budnum == 1)
+		p += PAGE_SIZE - ((zh->size + CHUNK_SIZE - 1) & CHUNK_MASK);
+	/* client should be filled in by caller */
+	memcpy(data, p, zh->size);
+	*size = zh->size;
+	spin_unlock(&zbpg->lock);
+}
+
 /*
  * zbud raw page management
  */
@@ -218,38 +313,17 @@ static struct zbud_page *zbud_alloc_raw_page(void)
 {
 	struct zbud_page *zbpg = NULL;
 	struct zbud_hdr *zh0, *zh1;
-	bool recycled = 0;
-
-	/* if any pages on the zbpg list, use one */
-	spin_lock(&zbpg_unused_list_spinlock);
-	if (!list_empty(&zbpg_unused_list)) {
-		zbpg = list_first_entry(&zbpg_unused_list,
-				struct zbud_page, bud_list);
-		list_del_init(&zbpg->bud_list);
-		zcache_zbpg_unused_list_count--;
-		recycled = 1;
-	}
-	spin_unlock(&zbpg_unused_list_spinlock);
-	if (zbpg == NULL)
-		/* none on zbpg list, try to get a kernel page */
 		zbpg = zcache_get_free_page();
 	if (likely(zbpg != NULL)) {
 		INIT_LIST_HEAD(&zbpg->bud_list);
 		zh0 = &zbpg->buddy[0]; zh1 = &zbpg->buddy[1];
 		spin_lock_init(&zbpg->lock);
-		if (recycled) {
-			ASSERT_INVERTED_SENTINEL(zbpg, ZBPG);
-			SET_SENTINEL(zbpg, ZBPG);
-			BUG_ON(zh0->size != 0 || tmem_oid_valid(&zh0->oid));
-			BUG_ON(zh1->size != 0 || tmem_oid_valid(&zh1->oid));
-		} else {
-			atomic_inc(&zcache_zbud_curr_raw_pages);
-			INIT_LIST_HEAD(&zbpg->bud_list);
-			SET_SENTINEL(zbpg, ZBPG);
-			zh0->size = 0; zh1->size = 0;
-			tmem_oid_set_invalid(&zh0->oid);
-			tmem_oid_set_invalid(&zh1->oid);
-		}
+		atomic_inc(&zcache_zbud_curr_raw_pages);
+		INIT_LIST_HEAD(&zbpg->bud_list);
+		SET_SENTINEL(zbpg, ZBPG);
+		zh0->size = 0; zh1->size = 0;
+		tmem_oid_set_invalid(&zh0->oid);
+		tmem_oid_set_invalid(&zh1->oid);
 	}
 	return zbpg;
 }
@@ -265,10 +339,8 @@ static void zbud_free_raw_page(struct zbud_page *zbpg)
 	BUG_ON(zh1->size != 0 || tmem_oid_valid(&zh1->oid));
 	INVERT_SENTINEL(zbpg, ZBPG);
 	spin_unlock(&zbpg->lock);
-	spin_lock(&zbpg_unused_list_spinlock);
-	list_add(&zbpg->bud_list, &zbpg_unused_list);
-	zcache_zbpg_unused_list_count++;
-	spin_unlock(&zbpg_unused_list_spinlock);
+	atomic_dec(&zcache_zbud_curr_raw_pages);
+	zcache_free_page(zbpg);
 }
 
 /*
@@ -299,6 +371,10 @@ static void zbud_free_and_delist(struct zbud_hdr *zh)
 	struct zbud_page *zbpg =
 		container_of(zh, struct zbud_page, buddy[budnum]);
 
+	/* FIXME, should be BUG_ON, pool destruction path doesn't disable
+	 * interrupts tmem_destroy_pool()->tmem_pampd_destroy_all_in_obj()->
+	 * tmem_objnode_node_destroy()-> zcache_pampd_free() */
+	WARN_ON(!irqs_disabled());
 	spin_lock(&zbpg->lock);
 	if (list_empty(&zbpg->bud_list)) {
 		/* ignore zombie page... see zbud_evict_pages() */
@@ -358,8 +434,8 @@ static struct zbud_hdr *zbud_create(uint16_t client_id, uint16_t pool_id,
 	if (unlikely(zbpg == NULL))
 		goto out;
 	/* ok, have a page, now compress the data before taking locks */
-	spin_lock(&zbpg->lock);
 	spin_lock(&zbud_budlists_spinlock);
+	spin_lock(&zbpg->lock);
 	list_add_tail(&zbpg->bud_list, &zbud_unbuddied[nchunks].list);
 	zbud_unbuddied[nchunks].count++;
 	zh = &zbpg->buddy[0];
@@ -389,12 +465,10 @@ init_zh:
 	zh->oid = *oid;
 	zh->pool_id = pool_id;
 	zh->client_id = client_id;
-	/* can wait to copy the data until the list locks are dropped */
-	spin_unlock(&zbud_budlists_spinlock);
-
 	to = zbud_data(zh, size);
 	memcpy(to, cdata, size);
 	spin_unlock(&zbpg->lock);
+	spin_unlock(&zbud_budlists_spinlock);
 	zbud_cumul_chunk_counts[nchunks]++;
 	atomic_inc(&zcache_zbud_curr_zpages);
 	zcache_zbud_cumul_zpages++;
@@ -458,9 +532,9 @@ static void zbud_evict_zbpg(struct zbud_page *zbpg)
 	uint32_t index[ZBUD_MAX_BUDS];
 	struct tmem_oid oid[ZBUD_MAX_BUDS];
 	struct tmem_pool *pool;
+	unsigned long flags;
 
 	ASSERT_SPINLOCK(&zbpg->lock);
-	BUG_ON(!list_empty(&zbpg->bud_list));
 	for (i = 0, j = 0; i < ZBUD_MAX_BUDS; i++) {
 		zh = &zbpg->buddy[i];
 		if (zh->size) {
@@ -469,20 +543,18 @@ static void zbud_evict_zbpg(struct zbud_page *zbpg)
 			oid[j] = zh->oid;
 			index[j] = zh->index;
 			j++;
-			zbud_free(zh);
 		}
 	}
 	spin_unlock(&zbpg->lock);
 	for (i = 0; i < j; i++) {
 		pool = zcache_get_pool_by_id(client_id[i], pool_id[i]);
-		if (pool != NULL) {
-			tmem_flush_page(pool, &oid[i], index[i]);
-			zcache_put_pool(pool);
-		}
+		BUG_ON(pool == NULL);
+		local_irq_save(flags);
+		/* these flushes should dispose of any local storage */
+		tmem_flush_page(pool, &oid[i], index[i]);
+		local_irq_restore(flags);
+		zcache_put_pool(pool);
 	}
-	ASSERT_SENTINEL(zbpg, ZBPG);
-	spin_lock(&zbpg->lock);
-	zbud_free_raw_page(zbpg);
 }
 
 /*
@@ -496,26 +568,8 @@ static void zbud_evict_zbpg(struct zbud_page *zbpg)
 static void zbud_evict_pages(int nr)
 {
 	struct zbud_page *zbpg;
-	int i;
+	int i, newly_unused_pages = 0;
 
-	/* first try freeing any pages on unused list */
-retry_unused_list:
-	spin_lock_bh(&zbpg_unused_list_spinlock);
-	if (!list_empty(&zbpg_unused_list)) {
-		/* can't walk list here, since it may change when unlocked */
-		zbpg = list_first_entry(&zbpg_unused_list,
-				struct zbud_page, bud_list);
-		list_del_init(&zbpg->bud_list);
-		zcache_zbpg_unused_list_count--;
-		atomic_dec(&zcache_zbud_curr_raw_pages);
-		spin_unlock_bh(&zbpg_unused_list_spinlock);
-		zcache_free_page(zbpg);
-		zcache_evicted_raw_pages++;
-		if (--nr <= 0)
-			goto out;
-		goto retry_unused_list;
-	}
-	spin_unlock_bh(&zbpg_unused_list_spinlock);
 
 	/* now try freeing unbuddied pages, starting with least space avail */
 	for (i = 0; i < MAX_CHUNK; i++) {
@@ -528,15 +582,15 @@ retry_unbud_list_i:
 		list_for_each_entry(zbpg, &zbud_unbuddied[i].list, bud_list) {
 			if (unlikely(!spin_trylock(&zbpg->lock)))
 				continue;
-			list_del_init(&zbpg->bud_list);
 			zbud_unbuddied[i].count--;
 			spin_unlock(&zbud_budlists_spinlock);
 			zcache_evicted_unbuddied_pages++;
 			/* want budlists unlocked when doing zbpg eviction */
 			zbud_evict_zbpg(zbpg);
+			newly_unused_pages++;
 			local_bh_enable();
 			if (--nr <= 0)
-				goto out;
+				goto evict_unused;
 			goto retry_unbud_list_i;
 		}
 		spin_unlock_bh(&zbud_budlists_spinlock);
@@ -547,27 +601,413 @@ retry_bud_list:
 	spin_lock_bh(&zbud_budlists_spinlock);
 	if (list_empty(&zbud_buddied_list)) {
 		spin_unlock_bh(&zbud_budlists_spinlock);
-		goto out;
+		goto evict_unused;
 	}
 	list_for_each_entry(zbpg, &zbud_buddied_list, bud_list) {
 		if (unlikely(!spin_trylock(&zbpg->lock)))
 			continue;
-		list_del_init(&zbpg->bud_list);
 		zcache_zbud_buddied_count--;
 		spin_unlock(&zbud_budlists_spinlock);
 		zcache_evicted_buddied_pages++;
 		/* want budlists unlocked when doing zbpg eviction */
 		zbud_evict_zbpg(zbpg);
+		newly_unused_pages++;
 		local_bh_enable();
 		if (--nr <= 0)
-			goto out;
+			goto evict_unused;
 		goto retry_bud_list;
 	}
 	spin_unlock_bh(&zbud_budlists_spinlock);
+
+evict_unused:
+	return;
+}
+
+static DEFINE_PER_CPU(unsigned char *, zcache_remoteputmem);
+
+static int zbud_remotify_zbud(struct tmem_xhandle *xh, char *data,
+				size_t size)
+{
+	struct tmem_pool *pool;
+	int i, remotenode, ret = -1;
+	unsigned char cksum, *p;
+	unsigned long flags;
+
+	for (p = data, cksum = 0, i = 0; i < size; i++)
+		cksum += *p;
+	ret = ramster_remote_put(xh, data, size, true, &remotenode);
+	if (ret == 0) {
+		/* data was successfully remoted so change the local version
+		 * to point to the remote node where it landed */
+		pool = zcache_get_pool_by_id(LOCAL_CLIENT, xh->pool_id);
+		BUG_ON(pool == NULL);
+		local_irq_save(flags);
+		/* tmem_replace will also free up any local space */
+		(void)tmem_replace(pool, &xh->oid, xh->index,
+			pampd_make_remote(remotenode, size, cksum));
+		local_irq_restore(flags);
+		zcache_put_pool(pool);
+		ramster_eph_pages_remoted++;
+		ret = 0;
+	} else
+		ramster_eph_pages_remote_failed++;
+	return ret;
+}
+
+static int zbud_remotify_zbpg(struct zbud_page *zbpg)
+{
+	struct zbud_hdr *zh1, *zh2 = NULL;
+	struct tmem_xhandle xh1, xh2 = { 0 };
+	char *data1 = NULL, *data2 = NULL;
+	size_t size1 = 0, size2 = 0;
+	int ret = 0;
+	unsigned char *tmpmem = __get_cpu_var(zcache_remoteputmem);
+
+	ASSERT_SPINLOCK(&zbpg->lock);
+	if (zbpg->buddy[0].size == 0)
+		zh1 = &zbpg->buddy[1];
+	else if (zbpg->buddy[1].size == 0)
+		zh1 = &zbpg->buddy[0];
+	else {
+		zh1 = &zbpg->buddy[0];
+		zh2 = &zbpg->buddy[1];
+	}
+	/* don't remotify pages that are already remotified */
+	if (zh1->client_id != LOCAL_CLIENT)
+		zh1 = NULL;
+	if ((zh2 != NULL) && (zh2->client_id != LOCAL_CLIENT))
+		zh2 = NULL;
+
+	/* copy the data and metadata so can release lock */
+	if (zh1 != NULL) {
+		xh1.client_id = zh1->client_id;
+		xh1.pool_id = zh1->pool_id;
+		xh1.oid = zh1->oid;
+		xh1.index = zh1->index;
+		size1 = zh1->size;
+		data1 = zbud_data(zh1, size1);
+		memcpy(tmpmem, zbud_data(zh1, size1), size1);
+		data1 = tmpmem;
+		tmpmem += size1;
+	}
+	if (zh2 != NULL) {
+		xh2.client_id = zh2->client_id;
+		xh2.pool_id = zh2->pool_id;
+		xh2.oid = zh2->oid;
+		xh2.index = zh2->index;
+		size2 = zh2->size;
+		memcpy(tmpmem, zbud_data(zh2, size2), size2);
+		data2 = tmpmem;
+	}
+	spin_unlock(&zbpg->lock);
+	preempt_enable();
+
+	/* OK, no locks held anymore, remotify one or both zbuds */
+	if (zh1 != NULL)
+		ret = zbud_remotify_zbud(&xh1, data1, size1);
+	if (zh2 != NULL)
+		ret |= zbud_remotify_zbud(&xh2, data2, size2);
+	return ret;
+}
+
+void zbud_remotify_pages(int nr)
+{
+	struct zbud_page *zbpg;
+	int i, ret;
+
+	/*
+	 * for now just try remotifying unbuddied pages, starting with
+	 * least space avail
+	 */
+	for (i = 0; i < MAX_CHUNK; i++) {
+retry_unbud_list_i:
+		preempt_disable();  /* enable in zbud_remotify_zbpg */
+		spin_lock_bh(&zbud_budlists_spinlock);
+		if (list_empty(&zbud_unbuddied[i].list)) {
+			spin_unlock_bh(&zbud_budlists_spinlock);
+			preempt_enable();
+			continue; /* next i in for loop */
+		}
+		list_for_each_entry(zbpg, &zbud_unbuddied[i].list, bud_list) {
+			if (unlikely(!spin_trylock(&zbpg->lock)))
+				continue; /* next list_for_each_entry */
+			zbud_unbuddied[i].count--;
+			/* want budlists unlocked when doing zbpg remotify */
+			spin_unlock_bh(&zbud_budlists_spinlock);
+			ret = zbud_remotify_zbpg(zbpg);
+			/* preemption is re-enabled in zbud_remotify_zbpg */
+			if (ret == 0) {
+				if (--nr <= 0)
+					goto out;
+				goto retry_unbud_list_i;
+			}
+			/* if fail to remotify any page, quit */
+			pr_err("TESTING zbud_remotify_pages failed on page,"
+				" trying to re-add\n");
+			spin_lock_bh(&zbud_budlists_spinlock);
+			spin_lock(&zbpg->lock);
+			list_add_tail(&zbpg->bud_list, &zbud_unbuddied[i].list);
+			zbud_unbuddied[i].count++;
+			spin_unlock(&zbpg->lock);
+			spin_unlock_bh(&zbud_budlists_spinlock);
+			pr_err("TESTING zbud_remotify_pages failed on page,"
+				" finished re-add\n");
+			goto out;
+		}
+		spin_unlock_bh(&zbud_budlists_spinlock);
+		preempt_enable();
+	}
+
+next_buddied_zbpg:
+	preempt_disable();  /* enable in zbud_remotify_zbpg */
+	spin_lock_bh(&zbud_budlists_spinlock);
+	if (list_empty(&zbud_buddied_list))
+		goto unlock_out;
+	list_for_each_entry(zbpg, &zbud_buddied_list, bud_list) {
+		if (unlikely(!spin_trylock(&zbpg->lock)))
+			continue; /* next list_for_each_entry */
+		zcache_zbud_buddied_count--;
+		/* want budlists unlocked when doing zbpg remotify */
+		spin_unlock_bh(&zbud_budlists_spinlock);
+		ret = zbud_remotify_zbpg(zbpg);
+		/* preemption is re-enabled in zbud_remotify_zbpg */
+		if (ret == 0) {
+			if (--nr <= 0)
+				goto out;
+			goto next_buddied_zbpg;
+		}
+		/* if fail to remotify any page, quit */
+		pr_err("TESTING zbud_remotify_pages failed on BUDDIED page,"
+			" trying to re-add\n");
+		spin_lock_bh(&zbud_budlists_spinlock);
+		spin_lock(&zbpg->lock);
+		list_add_tail(&zbpg->bud_list, &zbud_buddied_list);
+		zcache_zbud_buddied_count++;
+		spin_unlock(&zbpg->lock);
+		spin_unlock_bh(&zbud_budlists_spinlock);
+		pr_err("TESTING zbud_remotify_pages failed on BUDDIED page,"
+			" finished re-add\n");
+		goto out;
+	}
+unlock_out:
+	spin_unlock_bh(&zbud_budlists_spinlock);
+	preempt_enable();
 out:
 	return;
 }
 
+/* the "flush list" asynchronously collects pages to remotely flush */
+#define FLUSH_ENTIRE_OBJECT ((uint32_t)-1)
+static void ramster_flnode_free(struct flushlist_node *,
+				struct tmem_pool *);
+
+static void zcache_remote_flush_page(struct flushlist_node *flnode)
+{
+	struct tmem_xhandle *xh;
+	int remotenode, ret;
+
+	preempt_disable();
+	xh = &flnode->xh;
+	remotenode = flnode->xh.client_id;
+	ret = ramster_remote_flush(xh, remotenode);
+	if (ret >= 0)
+		ramster_remote_pages_flushed++;
+	else
+		ramster_remote_page_flushes_failed++;
+	preempt_enable_no_resched();
+	ramster_flnode_free(flnode, NULL);
+}
+
+static void zcache_remote_flush_object(struct flushlist_node *flnode)
+{
+	struct tmem_xhandle *xh;
+	int remotenode, ret;
+
+	preempt_disable();
+	xh = &flnode->xh;
+	remotenode = flnode->xh.client_id;
+	ret = ramster_remote_flush_object(xh, remotenode);
+	if (ret >= 0)
+		ramster_remote_objects_flushed++;
+	else
+		ramster_remote_object_flushes_failed++;
+	preempt_enable_no_resched();
+	ramster_flnode_free(flnode, NULL);
+}
+
+static void zcache_remote_eph_put(struct zbud_hdr *zbud)
+{
+	/* FIXME */
+}
+
+static void zcache_remote_pers_put(struct zv_hdr *zv)
+{
+	struct tmem_xhandle xh;
+	uint16_t size;
+	bool ephemeral;
+	int remotenode, ret = -1;
+	char *data;
+	struct tmem_pool *pool;
+	unsigned long flags;
+	unsigned char cksum;
+	char *p;
+	int i;
+	unsigned char *tmpmem = __get_cpu_var(zcache_remoteputmem);
+
+	ASSERT_SENTINEL(zv, ZVH);
+	BUG_ON(zv->client_id != LOCAL_CLIENT);
+	local_bh_disable();
+	xh.client_id = zv->client_id;
+	xh.pool_id = zv->pool_id;
+	xh.oid = zv->oid;
+	xh.index = zv->index;
+	size = xv_get_object_size(zv) - sizeof(*zv);
+	BUG_ON(size == 0 || size > zv_max_page_size);
+	data = (char *)zv + sizeof(*zv);
+	for (p = data, cksum = 0, i = 0; i < size; i++)
+		cksum += *p;
+	memcpy(tmpmem, data, size);
+	data = tmpmem;
+	pool = zcache_get_pool_by_id(zv->client_id, zv->pool_id);
+	ephemeral = is_ephemeral(pool);
+	zcache_put_pool(pool);
+	/* now OK to release lock set in caller */
+	spin_unlock(&zcache_rem_op_list_lock);
+	local_bh_enable();
+	preempt_disable();
+	ret = ramster_remote_put(&xh, data, size, ephemeral, &remotenode);
+	preempt_enable_no_resched();
+	if (ret != 0) {
+		/*
+		 * This is some form of a memory leak... if the remote put
+		 * fails, there will never be another attempt to remotify
+		 * this page.  But since we've dropped the zv pointer,
+		 * the page may have been freed or the data replaced
+		 * so we can't just "put it back" in the remote op list.
+		 * Even if we could, not sure where to put it in the list
+		 * because there may be flushes that must be strictly
+		 * ordered vs the put.  So leave this as a FIXME for now.
+		 * But count them so we know if it becomes a problem.
+		 */
+		ramster_pers_pages_remote_failed++;
+		goto out;
+	} else
+		atomic_inc(&ramster_remote_pers_pages);
+	ramster_pers_pages_remoted++;
+	/*
+	 * data was successfully remoted so change the local version to
+	 * point to the remote node where it landed
+	 */
+	local_bh_disable();
+	pool = zcache_get_pool_by_id(LOCAL_CLIENT, xh.pool_id);
+	local_irq_save(flags);
+	(void)tmem_replace(pool, &xh.oid, xh.index,
+			pampd_make_remote(remotenode, size, cksum));
+	local_irq_restore(flags);
+	zcache_put_pool(pool);
+	local_bh_enable();
+out:
+	return;
+}
+
+static void zcache_do_remotify_ops(int nr)
+{
+	struct ramster_remotify_hdr *rem_op;
+	union remotify_list_node *u;
+
+	while (1) {
+		if (!nr)
+			goto out;
+		spin_lock(&zcache_rem_op_list_lock);
+		if (list_empty(&zcache_rem_op_list)) {
+			spin_unlock(&zcache_rem_op_list_lock);
+			goto out;
+		}
+		rem_op = list_first_entry(&zcache_rem_op_list,
+				struct ramster_remotify_hdr, list);
+		list_del_init(&rem_op->list);
+		if (rem_op->op != RAMSTER_REMOTIFY_PERS_PUT)
+			spin_unlock(&zcache_rem_op_list_lock);
+		u = (union remotify_list_node *)rem_op;
+		switch (rem_op->op) {
+		case RAMSTER_REMOTIFY_EPH_PUT:
+BUG();
+			zcache_remote_eph_put((struct zbud_hdr *)rem_op);
+			break;
+		case RAMSTER_REMOTIFY_PERS_PUT:
+			zcache_remote_pers_put((struct zv_hdr *)rem_op);
+			break;
+		case RAMSTER_REMOTIFY_FLUSH_PAGE:
+			zcache_remote_flush_page((struct flushlist_node *)u);
+			break;
+		case RAMSTER_REMOTIFY_FLUSH_OBJ:
+			zcache_remote_flush_object((struct flushlist_node *)u);
+			break;
+		default:
+			BUG();
+		}
+	}
+out:
+	return;
+}
+
+/*
+ * Communicate interface revision with userspace
+ */
+#include "cluster/ramster_nodemanager.h"
+static unsigned long ramster_interface_revision  = R2NM_API_VERSION;
+
+/*
+ * For now, just push over a few pages every few seconds to
+ * ensure that it basically works
+ */
+static struct workqueue_struct *ramster_remotify_workqueue;
+static void ramster_remotify_process(struct work_struct *work);
+static DECLARE_DELAYED_WORK(ramster_remotify_worker,
+		ramster_remotify_process);
+
+static void ramster_remotify_queue_delayed_work(unsigned long delay)
+{
+	if (!queue_delayed_work(ramster_remotify_workqueue,
+				&ramster_remotify_worker, delay))
+		pr_err("ramster_remotify: bad workqueue\n");
+}
+
+
+static int use_frontswap;
+static int use_cleancache;
+static int ramster_remote_target_nodenum = -1;
+static void ramster_remotify_process(struct work_struct *work)
+{
+	static bool remotify_in_progress;
+
+	BUG_ON(irqs_disabled());
+	if (remotify_in_progress)
+		ramster_remotify_queue_delayed_work(HZ);
+	else if (ramster_remote_target_nodenum != -1) {
+		remotify_in_progress = true;
+#ifdef CONFIG_CLEANCACHE
+	if (use_cleancache && ramster_eph_remotify_enable)
+		zbud_remotify_pages(5000); /* FIXME is this a good number? */
+#endif
+#ifdef CONFIG_FRONTSWAP
+	if (use_frontswap && ramster_pers_remotify_enable)
+		zcache_do_remotify_ops(500); /* FIXME is this a good number? */
+#endif
+		remotify_in_progress = false;
+		ramster_remotify_queue_delayed_work(HZ);
+	}
+}
+
+static void ramster_remotify_init(void)
+{
+	unsigned long n = 60UL;
+	ramster_remotify_workqueue =
+		create_singlethread_workqueue("ramster_remotify");
+	ramster_remotify_queue_delayed_work(n * HZ);
+}
+
+
 static void zbud_init(void)
 {
 	int i;
@@ -631,15 +1071,6 @@ static int zbud_show_cumul_chunk_counts(char *buf)
  * necessary for decompression) immediately preceding the compressed data.
  */
 
-#define ZVH_SENTINEL  0x43214321
-
-struct zv_hdr {
-	uint32_t pool_id;
-	struct tmem_oid oid;
-	uint32_t index;
-	DECL_SENTINEL
-};
-
 /* rudimentary policy limits */
 /* total number of persistent pages may not exceed this percentage */
 static unsigned int zv_page_count_policy_percent = 75;
@@ -655,10 +1086,11 @@ static unsigned int zv_max_zsize = (PAGE_SIZE / 8) * 7;
  */
 static unsigned int zv_max_mean_zsize = (PAGE_SIZE / 8) * 5;
 
-static unsigned long zv_curr_dist_counts[NCHUNKS];
-static unsigned long zv_cumul_dist_counts[NCHUNKS];
+static atomic_t zv_curr_dist_counts[NCHUNKS];
+static atomic_t zv_cumul_dist_counts[NCHUNKS];
+
 
-static struct zv_hdr *zv_create(struct xv_pool *xvpool, uint32_t pool_id,
+static struct zv_hdr *zv_create(struct zcache_client *cli, uint32_t pool_id,
 				struct tmem_oid *oid, uint32_t index,
 				void *cdata, unsigned clen)
 {
@@ -671,23 +1103,61 @@ static struct zv_hdr *zv_create(struct xv_pool *xvpool, uint32_t pool_id,
 
 	BUG_ON(!irqs_disabled());
 	BUG_ON(chunks >= NCHUNKS);
-	ret = xv_malloc(xvpool, alloc_size,
+	ret = xv_malloc(cli->xvpool, clen + sizeof(struct zv_hdr),
 			&page, &offset, ZCACHE_GFP_MASK);
 	if (unlikely(ret))
 		goto out;
-	zv_curr_dist_counts[chunks]++;
-	zv_cumul_dist_counts[chunks]++;
+	atomic_inc(&zv_curr_dist_counts[chunks]);
+	atomic_inc(&zv_cumul_dist_counts[chunks]);
 	zv = kmap_atomic(page, KM_USER0) + offset;
 	zv->index = index;
 	zv->oid = *oid;
 	zv->pool_id = pool_id;
 	SET_SENTINEL(zv, ZVH);
+	INIT_LIST_HEAD(&zv->rem_op.list);
+	zv->client_id = get_client_id_from_client(cli);
+	zv->rem_op.op = RAMSTER_REMOTIFY_PERS_PUT;
+	if (zv->client_id == LOCAL_CLIENT) {
+		spin_lock(&zcache_rem_op_list_lock);
+		list_add_tail(&zv->rem_op.list, &zcache_rem_op_list);
+		spin_unlock(&zcache_rem_op_list_lock);
+	}
 	memcpy((char *)zv + sizeof(struct zv_hdr), cdata, clen);
 	kunmap_atomic(zv, KM_USER0);
 out:
 	return zv;
 }
 
+/* similar to zv_create, but just reserve space, no data yet */
+static struct zv_hdr *zv_alloc(struct tmem_pool *pool,
+				struct tmem_oid *oid, uint32_t index,
+				unsigned clen)
+{
+	struct zcache_client *cli = pool->client;
+	struct page *page;
+	struct zv_hdr *zv = NULL;
+	uint32_t offset;
+	int ret;
+
+	BUG_ON(!irqs_disabled());
+	BUG_ON(!is_local_client(pool->client));
+	ret = xv_malloc(cli->xvpool, clen + sizeof(struct zv_hdr),
+			&page, &offset, ZCACHE_GFP_MASK);
+	if (unlikely(ret))
+		goto out;
+	zv = kmap_atomic(page, KM_USER0) + offset;
+	SET_SENTINEL(zv, ZVH);
+	INIT_LIST_HEAD(&zv->rem_op.list);
+	zv->client_id = LOCAL_CLIENT;
+	zv->rem_op.op = RAMSTER_INTRANSIT_PERS;
+	zv->index = index;
+	zv->oid = *oid;
+	zv->pool_id = pool->pool_id;
+	kunmap_atomic(zv, KM_USER0);
+out:
+	return zv;
+}
+
 static void zv_free(struct xv_pool *xvpool, struct zv_hdr *zv)
 {
 	unsigned long flags;
@@ -698,10 +1168,15 @@ static void zv_free(struct xv_pool *xvpool, struct zv_hdr *zv)
 
 	ASSERT_SENTINEL(zv, ZVH);
 	BUG_ON(chunks >= NCHUNKS);
-	zv_curr_dist_counts[chunks]--;
+	atomic_dec(&zv_curr_dist_counts[chunks]);
 	size -= sizeof(*zv);
+	spin_lock(&zcache_rem_op_list_lock);
+	size = xv_get_object_size(zv) - sizeof(*zv);
 	BUG_ON(size == 0);
 	INVERT_SENTINEL(zv, ZVH);
+	if (!list_empty(&zv->rem_op.list))
+		list_del_init(&zv->rem_op.list);
+	spin_unlock(&zcache_rem_op_list_lock);
 	page = virt_to_page(zv);
 	offset = (unsigned long)zv & ~PAGE_MASK;
 	local_irq_save(flags);
@@ -727,6 +1202,29 @@ static void zv_decompress(struct page *page, struct zv_hdr *zv)
 	BUG_ON(clen != PAGE_SIZE);
 }
 
+static void zv_copy_from_pampd(char *data, size_t *bufsize, struct zv_hdr *zv)
+{
+	unsigned size;
+
+	ASSERT_SENTINEL(zv, ZVH);
+	size = xv_get_object_size(zv) - sizeof(*zv);
+	BUG_ON(size == 0 || size > zv_max_page_size);
+	BUG_ON(size > *bufsize);
+	memcpy(data, (char *)zv + sizeof(*zv), size);
+	*bufsize = size;
+}
+
+static void zv_copy_to_pampd(struct zv_hdr *zv, char *data, size_t size)
+{
+	unsigned zv_size;
+
+	ASSERT_SENTINEL(zv, ZVH);
+	zv_size = xv_get_object_size(zv) - sizeof(*zv);
+	BUG_ON(zv_size != size);
+	BUG_ON(zv_size == 0 || zv_size > zv_max_page_size);
+	memcpy((char *)zv + sizeof(*zv), data, size);
+}
+
 #ifdef CONFIG_SYSFS
 /*
  * show a distribution of compression stats for zv pages.
@@ -738,7 +1236,7 @@ static int zv_curr_dist_counts_show(char *buf)
 	char *p = buf;
 
 	for (i = 0; i < NCHUNKS; i++) {
-		n = zv_curr_dist_counts[i];
+		n = atomic_read(&zv_curr_dist_counts[i]);
 		p += sprintf(p, "%lu ", n);
 		chunks += n;
 		sum_total_chunks += i * n;
@@ -754,7 +1252,7 @@ static int zv_cumul_dist_counts_show(char *buf)
 	char *p = buf;
 
 	for (i = 0; i < NCHUNKS; i++) {
-		n = zv_cumul_dist_counts[i];
+		n = atomic_read(&zv_cumul_dist_counts[i]);
 		p += sprintf(p, "%lu ", n);
 		chunks += n;
 		sum_total_chunks += i * n;
@@ -787,7 +1285,7 @@ static ssize_t zv_max_zsize_store(struct kobject *kobj,
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
-	err = strict_strtoul(buf, 10, &val);
+	err = kstrtoul(buf, 10, &val);
 	if (err || (val == 0) || (val > (PAGE_SIZE / 8) * 7))
 		return -EINVAL;
 	zv_max_zsize = val;
@@ -819,7 +1317,7 @@ static ssize_t zv_max_mean_zsize_store(struct kobject *kobj,
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
-	err = strict_strtoul(buf, 10, &val);
+	err = kstrtoul(buf, 10, &val);
 	if (err || (val == 0) || (val > (PAGE_SIZE / 8) * 7))
 		return -EINVAL;
 	zv_max_mean_zsize = val;
@@ -853,7 +1351,7 @@ static ssize_t zv_page_count_policy_percent_store(struct kobject *kobj,
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
-	err = strict_strtoul(buf, 10, &val);
+	err = kstrtoul(buf, 10, &val);
 	if (err || (val == 0) || (val > 150))
 		return -EINVAL;
 	zv_page_count_policy_percent = val;
@@ -890,6 +1388,7 @@ static unsigned long zcache_flush_found;
 static unsigned long zcache_flobj_total;
 static unsigned long zcache_flobj_found;
 static unsigned long zcache_failed_eph_puts;
+static unsigned long zcache_nonactive_puts;
 static unsigned long zcache_failed_pers_puts;
 
 /*
@@ -970,6 +1469,7 @@ static unsigned long zcache_put_to_flush;
  */
 static struct kmem_cache *zcache_objnode_cache;
 static struct kmem_cache *zcache_obj_cache;
+static struct kmem_cache *ramster_flnode_cache;
 static atomic_t zcache_curr_obj_count = ATOMIC_INIT(0);
 static unsigned long zcache_curr_obj_count_max;
 static atomic_t zcache_curr_objnode_count = ATOMIC_INIT(0);
@@ -985,6 +1485,7 @@ struct zcache_preload {
 	struct tmem_obj *obj;
 	int nr;
 	struct tmem_objnode *objnodes[OBJNODE_TREE_MAX_PATH];
+	struct flushlist_node *flnode;
 };
 static DEFINE_PER_CPU(struct zcache_preload, zcache_preloads) = { 0, };
 
@@ -993,6 +1494,7 @@ static int zcache_do_preload(struct tmem_pool *pool)
 	struct zcache_preload *kp;
 	struct tmem_objnode *objnode;
 	struct tmem_obj *obj;
+	struct flushlist_node *flnode;
 	void *page;
 	int ret = -ENOMEM;
 
@@ -1023,27 +1525,61 @@ static int zcache_do_preload(struct tmem_pool *pool)
 		zcache_failed_alloc++;
 		goto out;
 	}
-	page = (void *)__get_free_page(ZCACHE_GFP_MASK);
-	if (unlikely(page == NULL)) {
-		zcache_failed_get_free_pages++;
-		kmem_cache_free(zcache_obj_cache, obj);
+	flnode = kmem_cache_alloc(ramster_flnode_cache, ZCACHE_GFP_MASK);
+	if (unlikely(flnode == NULL)) {
+		zcache_failed_alloc++;
 		goto out;
 	}
+	if (is_ephemeral(pool)) {
+		page = (void *)__get_free_page(ZCACHE_GFP_MASK);
+		if (unlikely(page == NULL)) {
+			zcache_failed_get_free_pages++;
+			kmem_cache_free(zcache_obj_cache, obj);
+			kmem_cache_free(ramster_flnode_cache, flnode);
+			goto out;
+		}
+	}
 	preempt_disable();
 	kp = &__get_cpu_var(zcache_preloads);
 	if (kp->obj == NULL)
 		kp->obj = obj;
 	else
 		kmem_cache_free(zcache_obj_cache, obj);
-	if (kp->page == NULL)
-		kp->page = page;
+	if (kp->flnode == NULL)
+		kp->flnode = flnode;
 	else
-		free_page((unsigned long)page);
+		kmem_cache_free(ramster_flnode_cache, flnode);
+	if (is_ephemeral(pool)) {
+		if (kp->page == NULL)
+			kp->page = page;
+		else
+			free_page((unsigned long)page);
+	}
 	ret = 0;
 out:
 	return ret;
 }
 
+static int ramster_do_preload_flnode_only(struct tmem_pool *pool)
+{
+	struct zcache_preload *kp;
+	struct flushlist_node *flnode;
+	int ret = -ENOMEM;
+
+	BUG_ON(!irqs_disabled());
+	if (unlikely(ramster_flnode_cache == NULL))
+		BUG();
+	kp = &__get_cpu_var(zcache_preloads);
+	flnode = kmem_cache_alloc(ramster_flnode_cache, GFP_ATOMIC);
+	if (unlikely(flnode == NULL) && kp->flnode == NULL)
+		BUG();  /* FIXME handle more gracefully, but how??? */
+	else if (kp->flnode == NULL)
+		kp->flnode = flnode;
+	else
+		kmem_cache_free(ramster_flnode_cache, flnode);
+	return ret;
+}
+
 static void *zcache_get_free_page(void)
 {
 	struct zcache_preload *kp;
@@ -1116,6 +1652,30 @@ static void zcache_obj_free(struct tmem_obj *obj, struct tmem_pool *pool)
 	kmem_cache_free(zcache_obj_cache, obj);
 }
 
+static struct flushlist_node *ramster_flnode_alloc(struct tmem_pool *pool)
+{
+	struct flushlist_node *flnode = NULL;
+	struct zcache_preload *kp;
+	int count;
+
+	kp = &__get_cpu_var(zcache_preloads);
+	flnode = kp->flnode;
+	BUG_ON(flnode == NULL);
+	kp->flnode = NULL;
+	count = atomic_inc_return(&ramster_curr_flnode_count);
+	if (count > ramster_curr_flnode_count_max)
+		ramster_curr_flnode_count_max = count;
+	return flnode;
+}
+
+static void ramster_flnode_free(struct flushlist_node *flnode,
+				struct tmem_pool *pool)
+{
+	atomic_dec(&ramster_curr_flnode_count);
+	BUG_ON(atomic_read(&ramster_curr_flnode_count) < 0);
+	kmem_cache_free(ramster_flnode_cache, flnode);
+}
+
 static struct tmem_hostops zcache_hostops = {
 	.obj_alloc = zcache_obj_alloc,
 	.obj_free = zcache_obj_free,
@@ -1127,6 +1687,14 @@ static struct tmem_hostops zcache_hostops = {
  * zcache implementations for PAM page descriptor ops
  */
 
+
+static inline void dec_and_check(atomic_t *pvar)
+{
+	atomic_dec(pvar);
+	/* later when all accounting is fixed, make this a BUG */
+	WARN_ON_ONCE(atomic_read(pvar) < 0);
+}
+
 static atomic_t zcache_curr_eph_pampd_count = ATOMIC_INIT(0);
 static unsigned long zcache_curr_eph_pampd_count_max;
 static atomic_t zcache_curr_pers_pampd_count = ATOMIC_INIT(0);
@@ -1135,22 +1703,20 @@ static unsigned long zcache_curr_pers_pampd_count_max;
 /* forward reference */
 static int zcache_compress(struct page *from, void **out_va, size_t *out_len);
 
-static void *zcache_pampd_create(char *data, size_t size, bool raw, int eph,
+static int zcache_pampd_eph_create(char *data, size_t size, bool raw,
 				struct tmem_pool *pool, struct tmem_oid *oid,
-				 uint32_t index)
+				uint32_t index, void **pampd)
 {
-	void *pampd = NULL, *cdata;
-	size_t clen;
-	int ret;
-	unsigned long count;
-	struct page *page = (struct page *)(data);
+	int ret = -1;
+	void *cdata = data;
+	size_t clen = size;
 	struct zcache_client *cli = pool->client;
 	uint16_t client_id = get_client_id_from_client(cli);
-	unsigned long zv_mean_zsize;
-	unsigned long curr_pers_pampd_count;
-	u64 total_zsize;
+	struct page *page = NULL;
+	unsigned long count;
 
-	if (eph) {
+	if (!raw) {
+		page = virt_to_page(data);
 		ret = zcache_compress(page, &cdata, &clen);
 		if (ret == 0)
 			goto out;
@@ -1158,46 +1724,114 @@ static void *zcache_pampd_create(char *data, size_t size, bool raw, int eph,
 			zcache_compress_poor++;
 			goto out;
 		}
-		pampd = (void *)zbud_create(client_id, pool->pool_id, oid,
-						index, page, cdata, clen);
-		if (pampd != NULL) {
-			count = atomic_inc_return(&zcache_curr_eph_pampd_count);
-			if (count > zcache_curr_eph_pampd_count_max)
-				zcache_curr_eph_pampd_count_max = count;
-		}
-	} else {
-		curr_pers_pampd_count =
-			atomic_read(&zcache_curr_pers_pampd_count);
-		if (curr_pers_pampd_count >
-		    (zv_page_count_policy_percent * totalram_pages) / 100)
-			goto out;
-		ret = zcache_compress(page, &cdata, &clen);
-		if (ret == 0)
-			goto out;
-		/* reject if compression is too poor */
-		if (clen > zv_max_zsize) {
-			zcache_compress_poor++;
+	}
+	*pampd = (void *)zbud_create(client_id, pool->pool_id, oid,
+					index, page, cdata, clen);
+	if (*pampd == NULL) {
+		ret = -ENOMEM;
+		goto out;
+	}
+	ret = 0;
+	count = atomic_inc_return(&zcache_curr_eph_pampd_count);
+	if (count > zcache_curr_eph_pampd_count_max)
+		zcache_curr_eph_pampd_count_max = count;
+	if (client_id != LOCAL_CLIENT) {
+		count = atomic_inc_return(&ramster_foreign_eph_pampd_count);
+		if (count > ramster_foreign_eph_pampd_count_max)
+			ramster_foreign_eph_pampd_count_max = count;
+	}
+out:
+	return ret;
+}
+
+static int zcache_pampd_pers_create(char *data, size_t size, bool raw,
+				struct tmem_pool *pool, struct tmem_oid *oid,
+				uint32_t index, void **pampd)
+{
+	int ret = -1;
+	void *cdata = data;
+	size_t clen = size;
+	struct zcache_client *cli = pool->client;
+	struct page *page;
+	unsigned long count;
+	unsigned long zv_mean_zsize;
+	struct zv_hdr *zv;
+	long curr_pers_pampd_count;
+	u64 total_zsize;
+#ifdef RAMSTER_TESTING
+	static bool pampd_neg_warned;
+#endif
+
+	curr_pers_pampd_count = atomic_read(&zcache_curr_pers_pampd_count) -
+			atomic_read(&ramster_remote_pers_pages);
+#ifdef RAMSTER_TESTING
+	/* should always be positive, but warn if accounting is off */
+	if (!pampd_neg_warned) {
+		pr_warn("ramster: bad accounting for curr_pers_pampd_count\n");
+		pampd_neg_warned = true;
+	}
+#endif
+	if (curr_pers_pampd_count >
+		    (zv_page_count_policy_percent * totalram_pages) / 100) {
+		zcache_policy_percent_exceeded++;
+		goto out;
+	}
+	if (raw)
+		goto ok_to_create;
+	page = virt_to_page(data);
+	if (zcache_compress(page, &cdata, &clen) == 0)
+		goto out;
+	/* reject if compression is too poor */
+	if (clen > zv_max_zsize) {
+		zcache_compress_poor++;
+		goto out;
+	}
+	/* reject if mean compression is too poor */
+	if ((clen > zv_max_mean_zsize) && (curr_pers_pampd_count > 0)) {
+		total_zsize = xv_get_total_size_bytes(cli->xvpool);
+		zv_mean_zsize = div_u64(total_zsize, curr_pers_pampd_count);
+		if (zv_mean_zsize > zv_max_mean_zsize) {
+			zcache_mean_compress_poor++;
 			goto out;
 		}
-		/* reject if mean compression is too poor */
-		if ((clen > zv_max_mean_zsize) && (curr_pers_pampd_count > 0)) {
-			total_zsize = xv_get_total_size_bytes(cli->xvpool);
-			zv_mean_zsize = div_u64(total_zsize,
-						curr_pers_pampd_count);
-			if (zv_mean_zsize > zv_max_mean_zsize) {
-				zcache_mean_compress_poor++;
-				goto out;
-			}
-		}
-		pampd = (void *)zv_create(cli->xvpool, pool->pool_id,
-						oid, index, cdata, clen);
-		if (pampd == NULL)
-			goto out;
-		count = atomic_inc_return(&zcache_curr_pers_pampd_count);
-		if (count > zcache_curr_pers_pampd_count_max)
-			zcache_curr_pers_pampd_count_max = count;
 	}
+ok_to_create:
+	*pampd = (void *)zv_create(cli, pool->pool_id, oid, index, cdata, clen);
+	if (*pampd == NULL) {
+		ret = -ENOMEM;
+		goto out;
+	}
+	ret = 0;
+	count = atomic_inc_return(&zcache_curr_pers_pampd_count);
+	if (count > zcache_curr_pers_pampd_count_max)
+		zcache_curr_pers_pampd_count_max = count;
+	if (is_local_client(cli))
+		goto out;
+	zv = *(struct zv_hdr **)pampd;
+	count = atomic_inc_return(&ramster_foreign_pers_pampd_count);
+	if (count > ramster_foreign_pers_pampd_count_max)
+		ramster_foreign_pers_pampd_count_max = count;
 out:
+	return ret;
+}
+
+static void *zcache_pampd_create(char *data, size_t size, bool raw, int eph,
+				struct tmem_pool *pool, struct tmem_oid *oid,
+				uint32_t index)
+{
+	void *pampd = NULL;
+	int ret;
+	bool ephemeral;
+
+	BUG_ON(preemptible());
+	ephemeral = (eph == 1) || ((eph == 0) && is_ephemeral(pool));
+	if (ephemeral)
+		ret = zcache_pampd_eph_create(data, size, raw, pool,
+						oid, index, &pampd);
+	else
+		ret = zcache_pampd_pers_create(data, size, raw, pool,
+						oid, index, &pampd);
+	/* FIXME add some counters here for failed creates? */
 	return pampd;
 }
 
@@ -1211,75 +1845,343 @@ static int zcache_pampd_get_data(char *data, size_t *bufsize, bool raw,
 {
 	int ret = 0;
 
-	BUG_ON(is_ephemeral(pool));
-	zv_decompress((struct page *)(data), pampd);
+	BUG_ON(preemptible());
+	BUG_ON(is_ephemeral(pool)); /* Fix later for shared pools? */
+	BUG_ON(pampd_is_remote(pampd));
+	if (raw)
+		zv_copy_from_pampd(data, bufsize, pampd);
+	else
+		zv_decompress(virt_to_page(data), pampd);
 	return ret;
 }
 
-/*
- * fill the pageframe corresponding to the struct page with the data
- * from the passed pampd
- */
 static int zcache_pampd_get_data_and_free(char *data, size_t *bufsize, bool raw,
 					void *pampd, struct tmem_pool *pool,
 					struct tmem_oid *oid, uint32_t index)
 {
 	int ret = 0;
+	unsigned long flags;
+	struct zcache_client *cli = pool->client;
 
-	BUG_ON(!is_ephemeral(pool));
-	zbud_decompress((struct page *)(data), pampd);
-	zbud_free_and_delist((struct zbud_hdr *)pampd);
-	atomic_dec(&zcache_curr_eph_pampd_count);
+	BUG_ON(preemptible());
+	BUG_ON(pampd_is_remote(pampd));
+	if (is_ephemeral(pool)) {
+		local_irq_save(flags);
+		if (raw)
+			zbud_copy_from_pampd(data, bufsize, pampd);
+		else
+			ret = zbud_decompress(virt_to_page(data), pampd);
+		zbud_free_and_delist((struct zbud_hdr *)pampd);
+		local_irq_restore(flags);
+		if (!is_local_client(cli))
+			dec_and_check(&ramster_foreign_eph_pampd_count);
+		dec_and_check(&zcache_curr_eph_pampd_count);
+	} else {
+		if (is_local_client(cli))
+			BUG();
+		if (raw)
+			zv_copy_from_pampd(data, bufsize, pampd);
+		else
+			zv_decompress(virt_to_page(data), pampd);
+		zv_free(cli->xvpool, pampd);
+		if (!is_local_client(cli))
+			dec_and_check(&ramster_foreign_pers_pampd_count);
+		dec_and_check(&zcache_curr_pers_pampd_count);
+		ret = 0;
+	}
 	return ret;
 }
 
+static bool zcache_pampd_is_remote(void *pampd)
+{
+	return pampd_is_remote(pampd);
+}
+
 /*
  * free the pampd and remove it from any zcache lists
  * pampd must no longer be pointed to from any tmem data structures!
  */
 static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
-				struct tmem_oid *oid, uint32_t index)
+			      struct tmem_oid *oid, uint32_t index, bool acct)
 {
 	struct zcache_client *cli = pool->client;
-
-	if (is_ephemeral(pool)) {
+	bool eph = is_ephemeral(pool);
+	struct zv_hdr *zv;
+
+	BUG_ON(preemptible());
+	if (pampd_is_remote(pampd)) {
+		WARN_ON(acct == false);
+		if (oid == NULL) {
+			/*
+			 * a NULL oid means to ignore this pampd free
+			 * as the remote freeing will be handled elsewhere
+			 */
+		} else if (eph) {
+			/* FIXME remote flush optional but probably good idea */
+			/* FIXME get these working properly again */
+			dec_and_check(&zcache_curr_eph_pampd_count);
+		} else if (pampd_is_intransit(pampd)) {
+			/* did a pers remote get_and_free, so just free local */
+			pampd = pampd_mask_intransit_and_remote(pampd);
+			goto local_pers;
+		} else {
+			struct flushlist_node *flnode =
+				ramster_flnode_alloc(pool);
+
+			flnode->xh.client_id = pampd_remote_node(pampd);
+			flnode->xh.pool_id = pool->pool_id;
+			flnode->xh.oid = *oid;
+			flnode->xh.index = index;
+			flnode->rem_op.op = RAMSTER_REMOTIFY_FLUSH_PAGE;
+			spin_lock(&zcache_rem_op_list_lock);
+			list_add(&flnode->rem_op.list, &zcache_rem_op_list);
+			spin_unlock(&zcache_rem_op_list_lock);
+			dec_and_check(&zcache_curr_pers_pampd_count);
+			dec_and_check(&ramster_remote_pers_pages);
+		}
+	} else if (eph) {
 		zbud_free_and_delist((struct zbud_hdr *)pampd);
-		atomic_dec(&zcache_curr_eph_pampd_count);
-		BUG_ON(atomic_read(&zcache_curr_eph_pampd_count) < 0);
+		if (!is_local_client(pool->client))
+			dec_and_check(&ramster_foreign_eph_pampd_count);
+		if (acct)
+			/* FIXME get these working properly again */
+			dec_and_check(&zcache_curr_eph_pampd_count);
 	} else {
-		zv_free(cli->xvpool, (struct zv_hdr *)pampd);
-		atomic_dec(&zcache_curr_pers_pampd_count);
-		BUG_ON(atomic_read(&zcache_curr_pers_pampd_count) < 0);
+local_pers:
+		zv = (struct zv_hdr *)pampd;
+		if (!is_local_client(pool->client))
+			dec_and_check(&ramster_foreign_pers_pampd_count);
+		zv_free(cli->xvpool, zv);
+		if (acct)
+			/* FIXME get these working properly again */
+			dec_and_check(&zcache_curr_pers_pampd_count);
 	}
 }
 
-static void zcache_pampd_free_obj(struct tmem_pool *pool, struct tmem_obj *obj)
+static void zcache_pampd_free_obj(struct tmem_pool *pool,
+					struct tmem_obj *obj)
 {
+	struct flushlist_node *flnode;
+
+	BUG_ON(preemptible());
+	if (obj->extra == NULL)
+		return;
+	BUG_ON(!pampd_is_remote(obj->extra));
+	flnode = ramster_flnode_alloc(pool);
+	flnode->xh.client_id = pampd_remote_node(obj->extra);
+	flnode->xh.pool_id = pool->pool_id;
+	flnode->xh.oid = obj->oid;
+	flnode->xh.index = FLUSH_ENTIRE_OBJECT;
+	flnode->rem_op.op = RAMSTER_REMOTIFY_FLUSH_OBJ;
+	spin_lock(&zcache_rem_op_list_lock);
+	list_add(&flnode->rem_op.list, &zcache_rem_op_list);
+	spin_unlock(&zcache_rem_op_list_lock);
 }
 
-static void zcache_pampd_new_obj(struct tmem_obj *obj)
+void zcache_pampd_new_obj(struct tmem_obj *obj)
 {
+	obj->extra = NULL;
 }
 
-static int zcache_pampd_replace_in_obj(void *pampd, struct tmem_obj *obj)
+int zcache_pampd_replace_in_obj(void *new_pampd, struct tmem_obj *obj)
 {
-	return -1;
+	int ret = -1;
+
+	if (new_pampd != NULL) {
+		if (obj->extra == NULL)
+			obj->extra = new_pampd;
+		/* enforce that all remote pages in an object reside
+		 * in the same node! */
+		else if (pampd_remote_node(new_pampd) !=
+				pampd_remote_node((void *)(obj->extra)))
+			BUG();
+		ret = 0;
+	}
+	return ret;
 }
 
-static bool zcache_pampd_is_remote(void *pampd)
+/*
+ * Called by the message handler after a (still compressed) page has been
+ * fetched from the remote machine in response to an "is_remote" tmem_get
+ * or persistent tmem_localify.  For a tmem_get, "extra" is the address of
+ * the page that is to be filled to succesfully resolve the tmem_get; for
+ * a (persistent) tmem_localify, "extra" is NULL (as the data is placed only
+ * in the local zcache).  "data" points to "size" bytes of (compressed) data
+ * passed in the message.  In the case of a persistent remote get, if
+ * pre-allocation was successful (see zcache_repatriate_preload), the page
+ * is placed into both local zcache and at "extra".
+ */
+int zcache_localify(int pool_id, struct tmem_oid *oidp,
+			uint32_t index, char *data, size_t size,
+			void *extra)
 {
-	return 0;
+	int ret = -ENOENT;
+	unsigned long flags;
+	struct tmem_pool *pool;
+	bool ephemeral, delete = false;
+	size_t clen = PAGE_SIZE;
+	void *pampd, *saved_hb;
+	struct tmem_obj *obj;
+
+	pool = zcache_get_pool_by_id(LOCAL_CLIENT, pool_id);
+	if (unlikely(pool == NULL))
+		/* pool doesn't exist anymore */
+		goto out;
+	ephemeral = is_ephemeral(pool);
+	local_irq_save(flags);  /* FIXME: maybe only disable softirqs? */
+	pampd = tmem_localify_get_pampd(pool, oidp, index, &obj, &saved_hb);
+	if (pampd == NULL) {
+		/* hmmm... must have been a flush while waiting */
+#ifdef RAMSTER_TESTING
+		pr_err("UNTESTED pampd==NULL in zcache_localify\n");
+#endif
+		if (ephemeral)
+			ramster_remote_eph_pages_unsucc_get++;
+		else
+			ramster_remote_pers_pages_unsucc_get++;
+		obj = NULL;
+		goto finish;
+	} else if (unlikely(!pampd_is_remote(pampd))) {
+		/* hmmm... must have been a dup put while waiting */
+#ifdef RAMSTER_TESTING
+		pr_err("UNTESTED dup while waiting in zcache_localify\n");
+#endif
+		if (ephemeral)
+			ramster_remote_eph_pages_unsucc_get++;
+		else
+			ramster_remote_pers_pages_unsucc_get++;
+		obj = NULL;
+		pampd = NULL;
+		ret = -EEXIST;
+		goto finish;
+	} else if (size == 0) {
+		/* no remote data, delete the local is_remote pampd */
+		pampd = NULL;
+		if (ephemeral)
+			ramster_remote_eph_pages_unsucc_get++;
+		else
+			BUG();
+		delete = true;
+		goto finish;
+	}
+	if (!ephemeral && pampd_is_intransit(pampd)) {
+		/* localify to zcache */
+		pampd = pampd_mask_intransit_and_remote(pampd);
+		zv_copy_to_pampd(pampd, data, size);
+	} else {
+		pampd = NULL;
+		obj = NULL;
+	}
+	if (extra != NULL) {
+		/* decompress direct-to-memory to complete remotify */
+		ret = lzo1x_decompress_safe((char *)data, size,
+						(char *)extra, &clen);
+		BUG_ON(ret != LZO_E_OK);
+		BUG_ON(clen != PAGE_SIZE);
+	}
+	if (ephemeral)
+		ramster_remote_eph_pages_succ_get++;
+	else
+		ramster_remote_pers_pages_succ_get++;
+	ret = 0;
+finish:
+	tmem_localify_finish(obj, index, pampd, saved_hb, delete);
+	zcache_put_pool(pool);
+	local_irq_restore(flags);
+out:
+	return ret;
+}
+
+/*
+ * Called on a remote persistent tmem_get to attempt to preallocate
+ * local storage for the data contained in the remote persistent page.
+ * If succesfully preallocated, returns the pampd, marked as remote and
+ * in_transit.  Else returns NULL.  Note that the appropriate tmem data
+ * structure must be locked.
+ */
+static void *zcache_pampd_repatriate_preload(void *pampd,
+						struct tmem_pool *pool,
+						struct tmem_oid *oid,
+						uint32_t index,
+						bool *intransit)
+{
+	int clen = pampd_remote_size(pampd);
+	void *ret_pampd = NULL;
+	unsigned long flags;
+
+	if (!pampd_is_remote(pampd))
+		BUG();
+	if (is_ephemeral(pool))
+		BUG();
+	if (pampd_is_intransit(pampd)) {
+		/*
+		 * to avoid multiple allocations (and maybe a memory leak)
+		 * don't preallocate if already in the process of being
+		 * repatriated
+		 */
+		*intransit = true;
+		goto out;
+	}
+	*intransit = false;
+	local_irq_save(flags);
+	ret_pampd = (void *)zv_alloc(pool, oid, index, clen);
+	if (ret_pampd != NULL) {
+		/*
+		 *  a pampd is marked intransit if it is remote and space has
+		 *  been allocated for it locally (note, only happens for
+		 *  persistent pages, in which case the remote copy is freed)
+		 */
+		ret_pampd = pampd_mark_intransit(ret_pampd);
+		dec_and_check(&ramster_remote_pers_pages);
+	} else
+		ramster_pers_pages_remote_nomem++;
+	local_irq_restore(flags);
+out:
+	return ret_pampd;
+}
+
+/*
+ * Called on a remote tmem_get to invoke a message to fetch the page.
+ * Might sleep so no tmem locks can be held.  "extra" is passed
+ * all the way through the round-trip messaging to zcache_localify.
+ */
+static int zcache_pampd_repatriate(void *fake_pampd, void *real_pampd,
+				   struct tmem_pool *pool,
+				   struct tmem_oid *oid, uint32_t index,
+				   bool free, void *extra)
+{
+	struct tmem_xhandle xh;
+	int ret;
+
+	if (pampd_is_intransit(real_pampd))
+		/* have local space pre-reserved, so free remote copy */
+		free = true;
+	xh = tmem_xhandle_fill(LOCAL_CLIENT, pool, oid, index);
+	/* unreliable request/response for now */
+	ret = ramster_remote_async_get(&xh, free,
+					pampd_remote_node(fake_pampd),
+					pampd_remote_size(fake_pampd),
+					pampd_remote_cksum(fake_pampd),
+					extra);
+#ifdef RAMSTER_TESTING
+	if (ret != 0 && ret != -ENOENT)
+		pr_err("TESTING zcache_pampd_repatriate returns, ret=%d\n",
+			ret);
+#endif
+	return ret;
 }
 
 static struct tmem_pamops zcache_pamops = {
 	.create = zcache_pampd_create,
 	.get_data = zcache_pampd_get_data,
-	.get_data_and_free = zcache_pampd_get_data_and_free,
 	.free = zcache_pampd_free,
+	.get_data_and_free = zcache_pampd_get_data_and_free,
 	.free_obj = zcache_pampd_free_obj,
+	.is_remote = zcache_pampd_is_remote,
+	.repatriate_preload = zcache_pampd_repatriate_preload,
+	.repatriate = zcache_pampd_repatriate,
 	.new_obj = zcache_pampd_new_obj,
 	.replace_in_obj = zcache_pampd_replace_in_obj,
-	.is_remote = zcache_pampd_is_remote,
 };
 
 /*
@@ -1327,9 +2229,13 @@ static int zcache_cpu_notifier(struct notifier_block *nb,
 		per_cpu(zcache_workmem, cpu) =
 			kzalloc(LZO1X_MEM_COMPRESS,
 				GFP_KERNEL | __GFP_REPEAT);
+		per_cpu(zcache_remoteputmem, cpu) =
+			kzalloc(PAGE_SIZE, GFP_KERNEL | __GFP_REPEAT);
 		break;
 	case CPU_DEAD:
 	case CPU_UP_CANCELED:
+		kfree(per_cpu(zcache_remoteputmem, cpu));
+		per_cpu(zcache_remoteputmem, cpu) = NULL;
 		free_pages((unsigned long)per_cpu(zcache_dstmem, cpu),
 				LZO_DSTMEM_PAGE_ORDER);
 		per_cpu(zcache_dstmem, cpu) = NULL;
@@ -1346,6 +2252,10 @@ static int zcache_cpu_notifier(struct notifier_block *nb,
 			kmem_cache_free(zcache_obj_cache, kp->obj);
 			kp->obj = NULL;
 		}
+		if (kp->flnode) {
+			kmem_cache_free(ramster_flnode_cache, kp->flnode);
+			kp->flnode = NULL;
+		}
 		if (kp->page) {
 			free_page((unsigned long)kp->page);
 			kp->page = NULL;
@@ -1402,12 +2312,12 @@ ZCACHE_SYSFS_RO(flush_found);
 ZCACHE_SYSFS_RO(flobj_total);
 ZCACHE_SYSFS_RO(flobj_found);
 ZCACHE_SYSFS_RO(failed_eph_puts);
+ZCACHE_SYSFS_RO(nonactive_puts);
 ZCACHE_SYSFS_RO(failed_pers_puts);
 ZCACHE_SYSFS_RO(zbud_curr_zbytes);
 ZCACHE_SYSFS_RO(zbud_cumul_zpages);
 ZCACHE_SYSFS_RO(zbud_cumul_zbytes);
 ZCACHE_SYSFS_RO(zbud_buddied_count);
-ZCACHE_SYSFS_RO(zbpg_unused_list_count);
 ZCACHE_SYSFS_RO(evicted_raw_pages);
 ZCACHE_SYSFS_RO(evicted_unbuddied_pages);
 ZCACHE_SYSFS_RO(evicted_buddied_pages);
@@ -1416,6 +2326,7 @@ ZCACHE_SYSFS_RO(failed_alloc);
 ZCACHE_SYSFS_RO(put_to_flush);
 ZCACHE_SYSFS_RO(compress_poor);
 ZCACHE_SYSFS_RO(mean_compress_poor);
+ZCACHE_SYSFS_RO(policy_percent_exceeded);
 ZCACHE_SYSFS_RO_ATOMIC(zbud_curr_raw_pages);
 ZCACHE_SYSFS_RO_ATOMIC(zbud_curr_zpages);
 ZCACHE_SYSFS_RO_ATOMIC(curr_obj_count);
@@ -1439,7 +2350,9 @@ static struct attribute *zcache_attrs[] = {
 	&zcache_flush_found_attr.attr,
 	&zcache_flobj_found_attr.attr,
 	&zcache_failed_eph_puts_attr.attr,
+	&zcache_nonactive_puts_attr.attr,
 	&zcache_failed_pers_puts_attr.attr,
+	&zcache_policy_percent_exceeded_attr.attr,
 	&zcache_compress_poor_attr.attr,
 	&zcache_mean_compress_poor_attr.attr,
 	&zcache_zbud_curr_raw_pages_attr.attr,
@@ -1448,7 +2361,6 @@ static struct attribute *zcache_attrs[] = {
 	&zcache_zbud_cumul_zpages_attr.attr,
 	&zcache_zbud_cumul_zbytes_attr.attr,
 	&zcache_zbud_buddied_count_attr.attr,
-	&zcache_zbpg_unused_list_count_attr.attr,
 	&zcache_evicted_raw_pages_attr.attr,
 	&zcache_evicted_unbuddied_pages_attr.attr,
 	&zcache_evicted_buddied_pages_attr.attr,
@@ -1470,6 +2382,202 @@ static struct attribute_group zcache_attr_group = {
 	.name = "zcache",
 };
 
+#define RAMSTER_SYSFS_RO(_name) \
+	static ssize_t ramster_##_name##_show(struct kobject *kobj, \
+				struct kobj_attribute *attr, char *buf) \
+	{ \
+		return sprintf(buf, "%lu\n", ramster_##_name); \
+	} \
+	static struct kobj_attribute ramster_##_name##_attr = { \
+		.attr = { .name = __stringify(_name), .mode = 0444 }, \
+		.show = ramster_##_name##_show, \
+	}
+
+#define RAMSTER_SYSFS_RW(_name) \
+	static ssize_t ramster_##_name##_show(struct kobject *kobj, \
+				struct kobj_attribute *attr, char *buf) \
+	{ \
+		return sprintf(buf, "%lu\n", ramster_##_name); \
+	} \
+	static ssize_t ramster_##_name##_store(struct kobject *kobj, \
+		struct kobj_attribute *attr, const char *buf, size_t count) \
+	{ \
+		int err; \
+		unsigned long enable; \
+		err = kstrtoul(buf, 10, &enable); \
+		if (err) \
+			return -EINVAL; \
+		ramster_##_name = enable; \
+		return count; \
+	} \
+	static struct kobj_attribute ramster_##_name##_attr = { \
+		.attr = { .name = __stringify(_name), .mode = 0644 }, \
+		.show = ramster_##_name##_show, \
+		.store = ramster_##_name##_store, \
+	}
+
+#define RAMSTER_SYSFS_RO_ATOMIC(_name) \
+	static ssize_t ramster_##_name##_show(struct kobject *kobj, \
+				struct kobj_attribute *attr, char *buf) \
+	{ \
+	    return sprintf(buf, "%d\n", atomic_read(&ramster_##_name)); \
+	} \
+	static struct kobj_attribute ramster_##_name##_attr = { \
+		.attr = { .name = __stringify(_name), .mode = 0444 }, \
+		.show = ramster_##_name##_show, \
+	}
+
+RAMSTER_SYSFS_RO(interface_revision);
+RAMSTER_SYSFS_RO_ATOMIC(remote_pers_pages);
+RAMSTER_SYSFS_RW(pers_remotify_enable);
+RAMSTER_SYSFS_RW(eph_remotify_enable);
+RAMSTER_SYSFS_RO(eph_pages_remoted);
+RAMSTER_SYSFS_RO(eph_pages_remote_failed);
+RAMSTER_SYSFS_RO(pers_pages_remoted);
+RAMSTER_SYSFS_RO(pers_pages_remote_failed);
+RAMSTER_SYSFS_RO(pers_pages_remote_nomem);
+RAMSTER_SYSFS_RO(remote_pages_flushed);
+RAMSTER_SYSFS_RO(remote_page_flushes_failed);
+RAMSTER_SYSFS_RO(remote_objects_flushed);
+RAMSTER_SYSFS_RO(remote_object_flushes_failed);
+RAMSTER_SYSFS_RO(remote_eph_pages_succ_get);
+RAMSTER_SYSFS_RO(remote_eph_pages_unsucc_get);
+RAMSTER_SYSFS_RO(remote_pers_pages_succ_get);
+RAMSTER_SYSFS_RO(remote_pers_pages_unsucc_get);
+RAMSTER_SYSFS_RO_ATOMIC(foreign_eph_pampd_count);
+RAMSTER_SYSFS_RO(foreign_eph_pampd_count_max);
+RAMSTER_SYSFS_RO_ATOMIC(foreign_pers_pampd_count);
+RAMSTER_SYSFS_RO(foreign_pers_pampd_count_max);
+RAMSTER_SYSFS_RO_ATOMIC(curr_flnode_count);
+RAMSTER_SYSFS_RO(curr_flnode_count_max);
+
+#define MANUAL_NODES 8
+static bool ramster_nodes_manual_up[MANUAL_NODES];
+static ssize_t ramster_manual_node_up_show(struct kobject *kobj,
+				struct kobj_attribute *attr, char *buf)
+{
+	int i;
+	char *p = buf;
+	for (i = 0; i < MANUAL_NODES; i++)
+		if (ramster_nodes_manual_up[i])
+			p += sprintf(p, "%d ", i);
+	p += sprintf(p, "\n");
+	return p - buf;
+}
+
+static ssize_t ramster_manual_node_up_store(struct kobject *kobj,
+		struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	int err;
+	unsigned long node_num;
+
+	err = kstrtoul(buf, 10, &node_num);
+	if (err) {
+		pr_err("ramster: bad strtoul?\n");
+		return -EINVAL;
+	}
+	if (node_num >= MANUAL_NODES) {
+		pr_err("ramster: bad node_num=%lu?\n", node_num);
+		return -EINVAL;
+	}
+	if (ramster_nodes_manual_up[node_num]) {
+		pr_err("ramster: node %d already up, ignoring\n",
+							(int)node_num);
+	} else {
+		ramster_nodes_manual_up[node_num] = true;
+		r2net_hb_node_up_manual((int)node_num);
+	}
+	return count;
+}
+
+static struct kobj_attribute ramster_manual_node_up_attr = {
+	.attr = { .name = "manual_node_up", .mode = 0644 },
+	.show = ramster_manual_node_up_show,
+	.store = ramster_manual_node_up_store,
+};
+
+static ssize_t ramster_remote_target_nodenum_show(struct kobject *kobj,
+				struct kobj_attribute *attr, char *buf)
+{
+	if (ramster_remote_target_nodenum == -1UL)
+		return sprintf(buf, "unset\n");
+	else
+		return sprintf(buf, "%d\n", ramster_remote_target_nodenum);
+}
+
+static ssize_t ramster_remote_target_nodenum_store(struct kobject *kobj,
+		struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	int err;
+	unsigned long node_num;
+
+	err = kstrtoul(buf, 10, &node_num);
+	if (err) {
+		pr_err("ramster: bad strtoul?\n");
+		return -EINVAL;
+	} else if (node_num == -1UL) {
+		pr_err("ramster: disabling all remotification, "
+			"data may still reside on remote nodes however\n");
+		return -EINVAL;
+	} else if (node_num >= MANUAL_NODES) {
+		pr_err("ramster: bad node_num=%lu?\n", node_num);
+		return -EINVAL;
+	} else if (!ramster_nodes_manual_up[node_num]) {
+		pr_err("ramster: node %d not up, ignoring setting "
+			"of remotification target\n", (int)node_num);
+	} else if (r2net_remote_target_node_set((int)node_num) >= 0) {
+		pr_info("ramster: node %d set as remotification target\n",
+				(int)node_num);
+		ramster_remote_target_nodenum = (int)node_num;
+	} else {
+		pr_err("ramster: bad num to node node_num=%d?\n",
+				(int)node_num);
+		return -EINVAL;
+	}
+	return count;
+}
+
+static struct kobj_attribute ramster_remote_target_nodenum_attr = {
+	.attr = { .name = "remote_target_nodenum", .mode = 0644 },
+	.show = ramster_remote_target_nodenum_show,
+	.store = ramster_remote_target_nodenum_store,
+};
+
+
+static struct attribute *ramster_attrs[] = {
+	&ramster_interface_revision_attr.attr,
+	&ramster_pers_remotify_enable_attr.attr,
+	&ramster_eph_remotify_enable_attr.attr,
+	&ramster_remote_pers_pages_attr.attr,
+	&ramster_eph_pages_remoted_attr.attr,
+	&ramster_eph_pages_remote_failed_attr.attr,
+	&ramster_pers_pages_remoted_attr.attr,
+	&ramster_pers_pages_remote_failed_attr.attr,
+	&ramster_pers_pages_remote_nomem_attr.attr,
+	&ramster_remote_pages_flushed_attr.attr,
+	&ramster_remote_page_flushes_failed_attr.attr,
+	&ramster_remote_objects_flushed_attr.attr,
+	&ramster_remote_object_flushes_failed_attr.attr,
+	&ramster_remote_eph_pages_succ_get_attr.attr,
+	&ramster_remote_eph_pages_unsucc_get_attr.attr,
+	&ramster_remote_pers_pages_succ_get_attr.attr,
+	&ramster_remote_pers_pages_unsucc_get_attr.attr,
+	&ramster_foreign_eph_pampd_count_attr.attr,
+	&ramster_foreign_eph_pampd_count_max_attr.attr,
+	&ramster_foreign_pers_pampd_count_attr.attr,
+	&ramster_foreign_pers_pampd_count_max_attr.attr,
+	&ramster_curr_flnode_count_attr.attr,
+	&ramster_curr_flnode_count_max_attr.attr,
+	&ramster_manual_node_up_attr.attr,
+	&ramster_remote_target_nodenum_attr.attr,
+	NULL,
+};
+
+static struct attribute_group ramster_attr_group = {
+	.attrs = ramster_attrs,
+	.name = "ramster",
+};
+
 #endif /* CONFIG_SYSFS */
 /*
  * When zcache is disabled ("frozen"), pools can be created and destroyed,
@@ -1510,8 +2618,9 @@ static struct shrinker zcache_shrinker = {
  * zcache shims between cleancache/frontswap ops and tmem
  */
 
-static int zcache_put_page(int cli_id, int pool_id, struct tmem_oid *oidp,
-				uint32_t index, struct page *page)
+int zcache_put(int cli_id, int pool_id, struct tmem_oid *oidp,
+			uint32_t index, char *data, size_t size,
+			bool raw, int ephemeral)
 {
 	struct tmem_pool *pool;
 	int ret = -1;
@@ -1522,8 +2631,7 @@ static int zcache_put_page(int cli_id, int pool_id, struct tmem_oid *oidp,
 		goto out;
 	if (!zcache_freeze && zcache_do_preload(pool) == 0) {
 		/* preload does preempt_disable on success */
-		ret = tmem_put(pool, oidp, index, (char *)(page),
-				PAGE_SIZE, 0, is_ephemeral(pool));
+		ret = tmem_put(pool, oidp, index, data, size, raw, ephemeral);
 		if (ret < 0) {
 			if (is_ephemeral(pool))
 				zcache_failed_eph_puts++;
@@ -1543,27 +2651,38 @@ out:
 	return ret;
 }
 
-static int zcache_get_page(int cli_id, int pool_id, struct tmem_oid *oidp,
-				uint32_t index, struct page *page)
+int zcache_get(int cli_id, int pool_id, struct tmem_oid *oidp,
+			uint32_t index, char *data, size_t *sizep,
+			bool raw, int get_and_free)
 {
 	struct tmem_pool *pool;
 	int ret = -1;
-	unsigned long flags;
-	size_t size = PAGE_SIZE;
+	bool eph;
 
-	local_irq_save(flags);
+	if (!raw) {
+		BUG_ON(irqs_disabled());
+		BUG_ON(in_softirq());
+	}
 	pool = zcache_get_pool_by_id(cli_id, pool_id);
+	eph = is_ephemeral(pool);
 	if (likely(pool != NULL)) {
 		if (atomic_read(&pool->obj_count) > 0)
-			ret = tmem_get(pool, oidp, index, (char *)(page),
-					&size, 0, is_ephemeral(pool));
+			ret = tmem_get(pool, oidp, index, data, sizep,
+					raw, get_and_free);
 		zcache_put_pool(pool);
 	}
-	local_irq_restore(flags);
+	WARN_ONCE((!eph && (ret != 0)), "zcache_get fails on persistent pool, "
+			  "bad things are very likely to happen soon\n");
+#ifdef RAMSTER_TESTING
+	if (ret != 0 && ret != -1 && !(ret == -EINVAL && is_ephemeral(pool)))
+		pr_err("TESTING zcache_get tmem_get returns ret=%d\n", ret);
+#endif
+	if (ret == -EAGAIN)
+		BUG(); /* FIXME... don't need this anymore??? let's ensure */
 	return ret;
 }
 
-static int zcache_flush_page(int cli_id, int pool_id,
+int zcache_flush(int cli_id, int pool_id,
 				struct tmem_oid *oidp, uint32_t index)
 {
 	struct tmem_pool *pool;
@@ -1573,6 +2692,7 @@ static int zcache_flush_page(int cli_id, int pool_id,
 	local_irq_save(flags);
 	zcache_flush_total++;
 	pool = zcache_get_pool_by_id(cli_id, pool_id);
+	ramster_do_preload_flnode_only(pool);
 	if (likely(pool != NULL)) {
 		if (atomic_read(&pool->obj_count) > 0)
 			ret = tmem_flush_page(pool, oidp, index);
@@ -1584,8 +2704,7 @@ static int zcache_flush_page(int cli_id, int pool_id,
 	return ret;
 }
 
-static int zcache_flush_object(int cli_id, int pool_id,
-				struct tmem_oid *oidp)
+int zcache_flush_object(int cli_id, int pool_id, struct tmem_oid *oidp)
 {
 	struct tmem_pool *pool;
 	int ret = -1;
@@ -1594,6 +2713,7 @@ static int zcache_flush_object(int cli_id, int pool_id,
 	local_irq_save(flags);
 	zcache_flobj_total++;
 	pool = zcache_get_pool_by_id(cli_id, pool_id);
+	ramster_do_preload_flnode_only(pool);
 	if (likely(pool != NULL)) {
 		if (atomic_read(&pool->obj_count) > 0)
 			ret = tmem_flush_object(pool, oidp);
@@ -1605,7 +2725,7 @@ static int zcache_flush_object(int cli_id, int pool_id,
 	return ret;
 }
 
-static int zcache_destroy_pool(int cli_id, int pool_id)
+int zcache_client_destroy_pool(int cli_id, int pool_id)
 {
 	struct tmem_pool *pool = NULL;
 	struct zcache_client *cli = NULL;
@@ -1632,13 +2752,17 @@ static int zcache_destroy_pool(int cli_id, int pool_id)
 	ret = tmem_destroy_pool(pool);
 	local_bh_enable();
 	kfree(pool);
-	pr_info("zcache: destroyed pool id=%d, cli_id=%d\n",
-			pool_id, cli_id);
+	pr_info("ramster: destroyed pool id=%d cli_id=%d\n", pool_id, cli_id);
 out:
 	return ret;
 }
 
-static int zcache_new_pool(uint16_t cli_id, uint32_t flags)
+static int zcache_destroy_pool(int pool_id)
+{
+	return zcache_client_destroy_pool(LOCAL_CLIENT, pool_id);
+}
+
+int zcache_new_pool(uint16_t cli_id, uint32_t flags)
 {
 	int poolid = -1;
 	struct tmem_pool *pool;
@@ -1653,7 +2777,7 @@ static int zcache_new_pool(uint16_t cli_id, uint32_t flags)
 	atomic_inc(&cli->refcount);
 	pool = kmalloc(sizeof(struct tmem_pool), GFP_ATOMIC);
 	if (pool == NULL) {
-		pr_info("zcache: pool creation failed: out of memory\n");
+		pr_info("ramster: pool creation failed: out of memory\n");
 		goto out;
 	}
 
@@ -1661,7 +2785,7 @@ static int zcache_new_pool(uint16_t cli_id, uint32_t flags)
 		if (cli->tmem_pools[poolid] == NULL)
 			break;
 	if (poolid >= MAX_POOLS_PER_CLIENT) {
-		pr_info("zcache: pool creation failed: max exceeded\n");
+		pr_info("ramster: pool creation failed: max exceeded\n");
 		kfree(pool);
 		poolid = -1;
 		goto out;
@@ -1671,15 +2795,78 @@ static int zcache_new_pool(uint16_t cli_id, uint32_t flags)
 	pool->pool_id = poolid;
 	tmem_new_pool(pool, flags);
 	cli->tmem_pools[poolid] = pool;
-	pr_info("zcache: created %s tmem pool, id=%d, client=%d\n",
-		flags & TMEM_POOL_PERSIST ? "persistent" : "ephemeral",
-		poolid, cli_id);
+	if (cli_id == LOCAL_CLIENT)
+		pr_info("ramster: created %s tmem pool, id=%d, local client\n",
+			flags & TMEM_POOL_PERSIST ? "persistent" : "ephemeral",
+			poolid);
+	else
+		pr_info("ramster: created %s tmem pool, id=%d, client=%d\n",
+			flags & TMEM_POOL_PERSIST ? "persistent" : "ephemeral",
+			poolid, cli_id);
 out:
 	if (cli != NULL)
 		atomic_dec(&cli->refcount);
 	return poolid;
 }
 
+static int zcache_local_new_pool(uint32_t flags)
+{
+	return zcache_new_pool(LOCAL_CLIENT, flags);
+}
+
+int zcache_autocreate_pool(int cli_id, int pool_id, bool ephemeral)
+{
+	struct tmem_pool *pool;
+	struct zcache_client *cli = NULL;
+	uint32_t flags = ephemeral ? 0 : TMEM_POOL_PERSIST;
+	int ret = -1;
+
+	if (cli_id == LOCAL_CLIENT)
+		goto out;
+	if (pool_id >= MAX_POOLS_PER_CLIENT)
+		goto out;
+	else if ((unsigned int)cli_id < MAX_CLIENTS)
+		cli = &zcache_clients[cli_id];
+	if ((ephemeral && !use_cleancache) || (!ephemeral && !use_frontswap))
+		BUG(); /* FIXME, handle more gracefully later */
+	if (!cli->allocated) {
+		if (zcache_new_client(cli_id))
+			BUG(); /* FIXME, handle more gracefully later */
+		cli = &zcache_clients[cli_id];
+	}
+	atomic_inc(&cli->refcount);
+	pool = cli->tmem_pools[pool_id];
+	if (pool != NULL) {
+		if (pool->persistent && ephemeral) {
+			pr_err("zcache_autocreate_pool: type mismatch\n");
+			goto out;
+		}
+		ret = 0;
+		goto out;
+	}
+	pool = kmalloc(sizeof(struct tmem_pool), GFP_KERNEL);
+	if (pool == NULL) {
+		pr_info("ramster: pool creation failed: out of memory\n");
+		goto out;
+	}
+	atomic_set(&pool->refcount, 0);
+	pool->client = cli;
+	pool->pool_id = pool_id;
+	tmem_new_pool(pool, flags);
+	cli->tmem_pools[pool_id] = pool;
+	pr_info("ramster: AUTOcreated %s tmem poolid=%d, for remote client=%d\n",
+		flags & TMEM_POOL_PERSIST ? "persistent" : "ephemeral",
+		pool_id, cli_id);
+	ret = 0;
+out:
+	if (cli == NULL)
+		BUG(); /* FIXME, handle more gracefully later */
+		/* pr_err("zcache_autocreate_pool: failed\n"); */
+	if (cli != NULL)
+		atomic_dec(&cli->refcount);
+	return ret;
+}
+
 /**********
  * Two kernel functionalities currently can be layered on top of tmem.
  * These are "cleancache" which is used as a second-chance cache for clean
@@ -1696,8 +2883,18 @@ static void zcache_cleancache_put_page(int pool_id,
 	u32 ind = (u32) index;
 	struct tmem_oid oid = *(struct tmem_oid *)&key;
 
-	if (likely(ind == index))
-		(void)zcache_put_page(LOCAL_CLIENT, pool_id, &oid, index, page);
+#ifdef __PG_WAS_ACTIVE
+	if (!PageWasActive(page)) {
+		zcache_nonactive_puts++;
+		return;
+	}
+#endif
+	if (likely(ind == index)) {
+		char *kva = page_address(page);
+
+		(void)zcache_put(LOCAL_CLIENT, pool_id, &oid, index,
+			kva, PAGE_SIZE, 0, 1);
+	}
 }
 
 static int zcache_cleancache_get_page(int pool_id,
@@ -1708,8 +2905,19 @@ static int zcache_cleancache_get_page(int pool_id,
 	struct tmem_oid oid = *(struct tmem_oid *)&key;
 	int ret = -1;
 
-	if (likely(ind == index))
-		ret = zcache_get_page(LOCAL_CLIENT, pool_id, &oid, index, page);
+	preempt_disable();
+	if (likely(ind == index)) {
+		char *kva = page_address(page);
+		size_t size = PAGE_SIZE;
+
+		ret = zcache_get(LOCAL_CLIENT, pool_id, &oid, index,
+			kva, &size, 0, 0);
+#ifdef __PG_WAS_ACTIVE
+		if (ret == 0)
+			SetPageWasActive(page);
+#endif
+	}
+	preempt_enable();
 	return ret;
 }
 
@@ -1721,7 +2929,7 @@ static void zcache_cleancache_flush_page(int pool_id,
 	struct tmem_oid oid = *(struct tmem_oid *)&key;
 
 	if (likely(ind == index))
-		(void)zcache_flush_page(LOCAL_CLIENT, pool_id, &oid, ind);
+		(void)zcache_flush(LOCAL_CLIENT, pool_id, &oid, ind);
 }
 
 static void zcache_cleancache_flush_inode(int pool_id,
@@ -1735,7 +2943,7 @@ static void zcache_cleancache_flush_inode(int pool_id,
 static void zcache_cleancache_flush_fs(int pool_id)
 {
 	if (pool_id >= 0)
-		(void)zcache_destroy_pool(LOCAL_CLIENT, pool_id);
+		(void)zcache_destroy_pool(pool_id);
 }
 
 static int zcache_cleancache_init_fs(size_t pagesize)
@@ -1743,7 +2951,7 @@ static int zcache_cleancache_init_fs(size_t pagesize)
 	BUG_ON(sizeof(struct cleancache_filekey) !=
 				sizeof(struct tmem_oid));
 	BUG_ON(pagesize != PAGE_SIZE);
-	return zcache_new_pool(LOCAL_CLIENT, 0);
+	return zcache_local_new_pool(0);
 }
 
 static int zcache_cleancache_init_shared_fs(char *uuid, size_t pagesize)
@@ -1752,7 +2960,7 @@ static int zcache_cleancache_init_shared_fs(char *uuid, size_t pagesize)
 	BUG_ON(sizeof(struct cleancache_filekey) !=
 				sizeof(struct tmem_oid));
 	BUG_ON(pagesize != PAGE_SIZE);
-	return zcache_new_pool(LOCAL_CLIENT, 0);
+	return zcache_local_new_pool(0);
 }
 
 static struct cleancache_ops zcache_cleancache_ops = {
@@ -1781,10 +2989,8 @@ static int zcache_frontswap_poolid = -1;
 /*
  * Swizzling increases objects per swaptype, increasing tmem concurrency
  * for heavy swaploads.  Later, larger nr_cpus -> larger SWIZ_BITS
- * Setting SWIZ_BITS to 27 basically reconstructs the swap entry from
- * frontswap_get_page()
  */
-#define SWIZ_BITS		27
+#define SWIZ_BITS		8
 #define SWIZ_MASK		((1 << SWIZ_BITS) - 1)
 #define _oswiz(_type, _ind)	((_type << SWIZ_BITS) | (_ind & SWIZ_MASK))
 #define iswiz(_ind)		(_ind >> SWIZ_BITS)
@@ -1804,12 +3010,14 @@ static int zcache_frontswap_put_page(unsigned type, pgoff_t offset,
 	struct tmem_oid oid = oswiz(type, ind);
 	int ret = -1;
 	unsigned long flags;
+	char *kva;
 
 	BUG_ON(!PageLocked(page));
 	if (likely(ind64 == ind)) {
 		local_irq_save(flags);
-		ret = zcache_put_page(LOCAL_CLIENT, zcache_frontswap_poolid,
-					&oid, iswiz(ind), page);
+		kva = page_address(page);
+		ret = zcache_put(LOCAL_CLIENT, zcache_frontswap_poolid,
+				&oid, iswiz(ind), kva, PAGE_SIZE, 0, 0);
 		local_irq_restore(flags);
 	}
 	return ret;
@@ -1825,10 +3033,16 @@ static int zcache_frontswap_get_page(unsigned type, pgoff_t offset,
 	struct tmem_oid oid = oswiz(type, ind);
 	int ret = -1;
 
+	preempt_disable(); /* FIXME, remove this? */
 	BUG_ON(!PageLocked(page));
-	if (likely(ind64 == ind))
-		ret = zcache_get_page(LOCAL_CLIENT, zcache_frontswap_poolid,
-					&oid, iswiz(ind), page);
+	if (likely(ind64 == ind)) {
+		char *kva = page_address(page);
+		size_t size = PAGE_SIZE;
+
+		ret = zcache_get(LOCAL_CLIENT, zcache_frontswap_poolid,
+					&oid, iswiz(ind), kva, &size, 0, -1);
+	}
+	preempt_enable(); /* FIXME, remove this? */
 	return ret;
 }
 
@@ -1840,7 +3054,7 @@ static void zcache_frontswap_flush_page(unsigned type, pgoff_t offset)
 	struct tmem_oid oid = oswiz(type, ind);
 
 	if (likely(ind64 == ind))
-		(void)zcache_flush_page(LOCAL_CLIENT, zcache_frontswap_poolid,
+		(void)zcache_flush(LOCAL_CLIENT, zcache_frontswap_poolid,
 					&oid, iswiz(ind));
 }
 
@@ -1862,7 +3076,7 @@ static void zcache_frontswap_init(unsigned ignored)
 	/* a single tmem poolid is used for all frontswap "types" (swapfiles) */
 	if (zcache_frontswap_poolid < 0)
 		zcache_frontswap_poolid =
-			zcache_new_pool(LOCAL_CLIENT, TMEM_POOL_PERSIST);
+				zcache_local_new_pool(TMEM_POOL_PERSIST);
 }
 
 static struct frontswap_ops zcache_frontswap_ops = {
@@ -1883,19 +3097,125 @@ struct frontswap_ops zcache_frontswap_register_ops(void)
 #endif
 
 /*
+ * frontswap selfshrinking
+ */
+
+#ifdef CONFIG_FRONTSWAP
+/* In HZ, controls frequency of worker invocation. */
+static unsigned int selfshrink_interval __read_mostly = 5;
+
+static void selfshrink_process(struct work_struct *work);
+static DECLARE_DELAYED_WORK(selfshrink_worker, selfshrink_process);
+
+/* Enable/disable with sysfs. */
+static bool frontswap_selfshrinking __read_mostly;
+
+/* Enable/disable with kernel boot option. */
+static bool use_frontswap_selfshrink __initdata = true;
+
+/*
+ * The default values for the following parameters were deemed reasonable
+ * by experimentation, may be workload-dependent, and can all be
+ * adjusted via sysfs.
+ */
+
+/* Control rate for frontswap shrinking. Higher hysteresis is slower. */
+static unsigned int frontswap_hysteresis __read_mostly = 20;
+
+/*
+ * Number of selfshrink worker invocations to wait before observing that
+ * frontswap selfshrinking should commence. Note that selfshrinking does
+ * not use a separate worker thread.
+ */
+static unsigned int frontswap_inertia __read_mostly = 3;
+
+/* Countdown to next invocation of frontswap_shrink() */
+static unsigned long frontswap_inertia_counter;
+
+/*
+ * Invoked by the selfshrink worker thread, uses current number of pages
+ * in frontswap (frontswap_curr_pages()), previous status, and control
+ * values (hysteresis and inertia) to determine if frontswap should be
+ * shrunk and what the new frontswap size should be.  Note that
+ * frontswap_shrink is essentially a partial swapoff that immediately
+ * transfers pages from the "swap device" (frontswap) back into kernel
+ * RAM; despite the name, frontswap "shrinking" is very different from
+ * the "shrinker" interface used by the kernel MM subsystem to reclaim
+ * memory.
+ */
+static void frontswap_selfshrink(void)
+{
+	static unsigned long cur_frontswap_pages;
+	static unsigned long last_frontswap_pages;
+	static unsigned long tgt_frontswap_pages;
+
+	last_frontswap_pages = cur_frontswap_pages;
+	cur_frontswap_pages = frontswap_curr_pages();
+	if (!cur_frontswap_pages ||
+			(cur_frontswap_pages > last_frontswap_pages)) {
+		frontswap_inertia_counter = frontswap_inertia;
+		return;
+	}
+	if (frontswap_inertia_counter && --frontswap_inertia_counter)
+		return;
+	if (cur_frontswap_pages <= frontswap_hysteresis)
+		tgt_frontswap_pages = 0;
+	else
+		tgt_frontswap_pages = cur_frontswap_pages -
+			(cur_frontswap_pages / frontswap_hysteresis);
+	frontswap_shrink(tgt_frontswap_pages);
+}
+
+static int __init ramster_nofrontswap_selfshrink_setup(char *s)
+{
+	use_frontswap_selfshrink = false;
+	return 1;
+}
+
+__setup("noselfshrink", ramster_nofrontswap_selfshrink_setup);
+
+static void selfshrink_process(struct work_struct *work)
+{
+	if (frontswap_selfshrinking && frontswap_enabled) {
+		frontswap_selfshrink();
+		schedule_delayed_work(&selfshrink_worker,
+			selfshrink_interval * HZ);
+	}
+}
+
+static int ramster_enabled;
+
+static int __init ramster_selfshrink_init(void)
+{
+	frontswap_selfshrinking = ramster_enabled && use_frontswap_selfshrink;
+	if (frontswap_selfshrinking)
+		pr_info("ramster: Initializing frontswap "
+					"selfshrinking driver.\n");
+	else
+		return -ENODEV;
+
+	schedule_delayed_work(&selfshrink_worker, selfshrink_interval * HZ);
+
+	return 0;
+}
+
+subsys_initcall(ramster_selfshrink_init);
+#endif
+
+/*
  * zcache initialization
- * NOTE FOR NOW zcache MUST BE PROVIDED AS A KERNEL BOOT PARAMETER OR
+ * NOTE FOR NOW ramster MUST BE PROVIDED AS A KERNEL BOOT PARAMETER OR
  * NOTHING HAPPENS!
  */
 
-static int zcache_enabled;
+static int ramster_enabled;
 
-static int __init enable_zcache(char *s)
+static int __init enable_ramster(char *s)
 {
-	zcache_enabled = 1;
+	ramster_enabled = 1;
 	return 1;
 }
-__setup("zcache", enable_zcache);
+__setup("ramster", enable_ramster);
 
 /* allow independent dynamic disabling of cleancache and frontswap */
 
@@ -1903,16 +3223,22 @@ static int use_cleancache = 1;
 
 static int __init no_cleancache(char *s)
 {
+	pr_info("INIT no_cleancache called\n");
 	use_cleancache = 0;
 	return 1;
 }
 
-__setup("nocleancache", no_cleancache);
+/*
+ * FIXME: need to guarantee this gets checked before zcache_init is called
+ * What is the correct way to achieve this?
+ */
+early_param("nocleancache", no_cleancache);
 
 static int use_frontswap = 1;
 
 static int __init no_frontswap(char *s)
 {
+	pr_info("INIT no_frontswap called\n");
 	use_frontswap = 0;
 	return 1;
 }
@@ -1925,20 +3251,22 @@ static int __init zcache_init(void)
 
 #ifdef CONFIG_SYSFS
 	ret = sysfs_create_group(mm_kobj, &zcache_attr_group);
+	ret = sysfs_create_group(mm_kobj, &ramster_attr_group);
 	if (ret) {
-		pr_err("zcache: can't create sysfs\n");
+		pr_err("ramster: can't create sysfs\n");
 		goto out;
 	}
 #endif /* CONFIG_SYSFS */
 #if defined(CONFIG_CLEANCACHE) || defined(CONFIG_FRONTSWAP)
-	if (zcache_enabled) {
+	if (ramster_enabled) {
 		unsigned int cpu;
 
+		(void)r2net_register_handlers();
 		tmem_register_hostops(&zcache_hostops);
 		tmem_register_pamops(&zcache_pamops);
 		ret = register_cpu_notifier(&zcache_cpu_notifier_block);
 		if (ret) {
-			pr_err("zcache: can't register cpu notifier\n");
+			pr_err("ramster: can't register cpu notifier\n");
 			goto out;
 		}
 		for_each_online_cpu(cpu) {
@@ -1951,35 +3279,39 @@ static int __init zcache_init(void)
 				sizeof(struct tmem_objnode), 0, 0, NULL);
 	zcache_obj_cache = kmem_cache_create("zcache_obj",
 				sizeof(struct tmem_obj), 0, 0, NULL);
-	ret = zcache_new_client(LOCAL_CLIENT);
-	if (ret) {
-		pr_err("zcache: can't create client\n");
-		goto out;
-	}
+	ramster_flnode_cache = kmem_cache_create("ramster_flnode",
+				sizeof(struct flushlist_node), 0, 0, NULL);
 #endif
 #ifdef CONFIG_CLEANCACHE
-	if (zcache_enabled && use_cleancache) {
+	pr_info("INIT ramster_enabled=%d use_cleancache=%d\n",
+					ramster_enabled, use_cleancache);
+	if (ramster_enabled && use_cleancache) {
 		struct cleancache_ops old_ops;
 
 		zbud_init();
 		register_shrinker(&zcache_shrinker);
 		old_ops = zcache_cleancache_register_ops();
-		pr_info("zcache: cleancache enabled using kernel "
+		pr_info("ramster: cleancache enabled using kernel "
 			"transcendent memory and compression buddies\n");
 		if (old_ops.init_fs != NULL)
-			pr_warning("zcache: cleancache_ops overridden");
+			pr_warning("ramster: cleancache_ops overridden");
 	}
 #endif
 #ifdef CONFIG_FRONTSWAP
-	if (zcache_enabled && use_frontswap) {
+	pr_info("INIT ramster_enabled=%d use_frontswap=%d\n",
+					ramster_enabled, use_frontswap);
+	if (ramster_enabled && use_frontswap) {
 		struct frontswap_ops old_ops;
 
+		zcache_new_client(LOCAL_CLIENT);
 		old_ops = zcache_frontswap_register_ops();
-		pr_info("zcache: frontswap enabled using kernel "
+		pr_info("ramster: frontswap enabled using kernel "
 			"transcendent memory and xvmalloc\n");
 		if (old_ops.init != NULL)
-			pr_warning("zcache: frontswap_ops overridden");
+			pr_warning("ramster: frontswap_ops overridden");
 	}
+	if (ramster_enabled && (use_frontswap || use_cleancache))
+		ramster_remotify_init();
 #endif
 out:
 	return ret;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
