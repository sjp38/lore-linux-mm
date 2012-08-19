Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 181126B0069
	for <linux-mm@kvack.org>; Sat, 18 Aug 2012 20:52:39 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jc3so2035235bkc.14
        for <linux-mm@kvack.org>; Sat, 18 Aug 2012 17:52:38 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v2 12/16] dm: use new hashtable implementation
Date: Sun, 19 Aug 2012 02:52:26 +0200
Message-Id: <1345337550-24304-14-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1345337550-24304-1-git-send-email-levinsasha928@gmail.com>
References: <1345337550-24304-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com, Sasha Levin <levinsasha928@gmail.com>

Switch dm to use the new hashtable implementation. This reduces the amount of
generic unrelated code in the dm.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 drivers/md/dm-snap.c                               |   24 ++++-----------
 drivers/md/persistent-data/dm-block-manager.c      |    1 -
 .../persistent-data/dm-persistent-data-internal.h  |   19 ------------
 .../md/persistent-data/dm-transaction-manager.c    |   30 ++++++--------------
 4 files changed, 16 insertions(+), 58 deletions(-)
 delete mode 100644 drivers/md/persistent-data/dm-persistent-data-internal.h

diff --git a/drivers/md/dm-snap.c b/drivers/md/dm-snap.c
index a143921..7ac121f 100644
--- a/drivers/md/dm-snap.c
+++ b/drivers/md/dm-snap.c
@@ -34,9 +34,7 @@ static const char dm_snapshot_merge_target_name[] = "snapshot-merge";
  */
 #define MIN_IOS 256
 
-#define DM_TRACKED_CHUNK_HASH_SIZE	16
-#define DM_TRACKED_CHUNK_HASH(x)	((unsigned long)(x) & \
-					 (DM_TRACKED_CHUNK_HASH_SIZE - 1))
+#define DM_TRACKED_CHUNK_HASH_BITS	4
 
 struct dm_exception_table {
 	uint32_t hash_mask;
@@ -80,7 +78,7 @@ struct dm_snapshot {
 	/* Chunks with outstanding reads */
 	spinlock_t tracked_chunk_lock;
 	mempool_t *tracked_chunk_pool;
-	struct hlist_head tracked_chunk_hash[DM_TRACKED_CHUNK_HASH_SIZE];
+	DEFINE_HASHTABLE(tracked_chunk_hash, DM_TRACKED_CHUNK_HASH_BITS);
 
 	/* The on disk metadata handler */
 	struct dm_exception_store *store;
@@ -203,8 +201,7 @@ static struct dm_snap_tracked_chunk *track_chunk(struct dm_snapshot *s,
 	c->chunk = chunk;
 
 	spin_lock_irqsave(&s->tracked_chunk_lock, flags);
-	hlist_add_head(&c->node,
-		       &s->tracked_chunk_hash[DM_TRACKED_CHUNK_HASH(chunk)]);
+	hash_add(s->tracked_chunk_hash, &c->node, chunk);
 	spin_unlock_irqrestore(&s->tracked_chunk_lock, flags);
 
 	return c;
@@ -216,7 +213,7 @@ static void stop_tracking_chunk(struct dm_snapshot *s,
 	unsigned long flags;
 
 	spin_lock_irqsave(&s->tracked_chunk_lock, flags);
-	hlist_del(&c->node);
+	hash_del(&c->node);
 	spin_unlock_irqrestore(&s->tracked_chunk_lock, flags);
 
 	mempool_free(c, s->tracked_chunk_pool);
@@ -230,8 +227,7 @@ static int __chunk_is_tracked(struct dm_snapshot *s, chunk_t chunk)
 
 	spin_lock_irq(&s->tracked_chunk_lock);
 
-	hlist_for_each_entry(c, hn,
-	    &s->tracked_chunk_hash[DM_TRACKED_CHUNK_HASH(chunk)], node) {
+	hash_for_each_possible(s->tracked_chunk_hash, c, hn, node, chunk) {
 		if (c->chunk == chunk) {
 			found = 1;
 			break;
@@ -1033,7 +1029,6 @@ static void stop_merge(struct dm_snapshot *s)
 static int snapshot_ctr(struct dm_target *ti, unsigned int argc, char **argv)
 {
 	struct dm_snapshot *s;
-	int i;
 	int r = -EINVAL;
 	char *origin_path, *cow_path;
 	unsigned args_used, num_flush_requests = 1;
@@ -1128,8 +1123,7 @@ static int snapshot_ctr(struct dm_target *ti, unsigned int argc, char **argv)
 		goto bad_tracked_chunk_pool;
 	}
 
-	for (i = 0; i < DM_TRACKED_CHUNK_HASH_SIZE; i++)
-		INIT_HLIST_HEAD(&s->tracked_chunk_hash[i]);
+	hash_init(s->tracked_chunk_hash);
 
 	spin_lock_init(&s->tracked_chunk_lock);
 
@@ -1253,9 +1247,6 @@ static void __handover_exceptions(struct dm_snapshot *snap_src,
 
 static void snapshot_dtr(struct dm_target *ti)
 {
-#ifdef CONFIG_DM_DEBUG
-	int i;
-#endif
 	struct dm_snapshot *s = ti->private;
 	struct dm_snapshot *snap_src = NULL, *snap_dest = NULL;
 
@@ -1286,8 +1277,7 @@ static void snapshot_dtr(struct dm_target *ti)
 	smp_mb();
 
 #ifdef CONFIG_DM_DEBUG
-	for (i = 0; i < DM_TRACKED_CHUNK_HASH_SIZE; i++)
-		BUG_ON(!hlist_empty(&s->tracked_chunk_hash[i]));
+	BUG_ON(!hash_empty(s->tracked_chunk_hash));
 #endif
 
 	mempool_destroy(s->tracked_chunk_pool);
diff --git a/drivers/md/persistent-data/dm-block-manager.c b/drivers/md/persistent-data/dm-block-manager.c
index 5ba2777..31edaf13 100644
--- a/drivers/md/persistent-data/dm-block-manager.c
+++ b/drivers/md/persistent-data/dm-block-manager.c
@@ -4,7 +4,6 @@
  * This file is released under the GPL.
  */
 #include "dm-block-manager.h"
-#include "dm-persistent-data-internal.h"
 #include "../dm-bufio.h"
 
 #include <linux/crc32c.h>
diff --git a/drivers/md/persistent-data/dm-persistent-data-internal.h b/drivers/md/persistent-data/dm-persistent-data-internal.h
deleted file mode 100644
index c49e26f..0000000
--- a/drivers/md/persistent-data/dm-persistent-data-internal.h
+++ /dev/null
@@ -1,19 +0,0 @@
-/*
- * Copyright (C) 2011 Red Hat, Inc.
- *
- * This file is released under the GPL.
- */
-
-#ifndef _DM_PERSISTENT_DATA_INTERNAL_H
-#define _DM_PERSISTENT_DATA_INTERNAL_H
-
-#include "dm-block-manager.h"
-
-static inline unsigned dm_hash_block(dm_block_t b, unsigned hash_mask)
-{
-	const unsigned BIG_PRIME = 4294967291UL;
-
-	return (((unsigned) b) * BIG_PRIME) & hash_mask;
-}
-
-#endif	/* _PERSISTENT_DATA_INTERNAL_H */
diff --git a/drivers/md/persistent-data/dm-transaction-manager.c b/drivers/md/persistent-data/dm-transaction-manager.c
index d247a35..a57c4ed 100644
--- a/drivers/md/persistent-data/dm-transaction-manager.c
+++ b/drivers/md/persistent-data/dm-transaction-manager.c
@@ -7,11 +7,11 @@
 #include "dm-space-map.h"
 #include "dm-space-map-disk.h"
 #include "dm-space-map-metadata.h"
-#include "dm-persistent-data-internal.h"
 
 #include <linux/export.h>
 #include <linux/slab.h>
 #include <linux/device-mapper.h>
+#include <linux/hashtable.h>
 
 #define DM_MSG_PREFIX "transaction manager"
 
@@ -25,8 +25,7 @@ struct shadow_info {
 /*
  * It would be nice if we scaled with the size of transaction.
  */
-#define HASH_SIZE 256
-#define HASH_MASK (HASH_SIZE - 1)
+#define DM_HASH_BITS 8
 
 struct dm_transaction_manager {
 	int is_clone;
@@ -36,7 +35,7 @@ struct dm_transaction_manager {
 	struct dm_space_map *sm;
 
 	spinlock_t lock;
-	struct hlist_head buckets[HASH_SIZE];
+	DEFINE_HASHTABLE(hash, DM_HASH_BITS);
 };
 
 /*----------------------------------------------------------------*/
@@ -44,12 +43,11 @@ struct dm_transaction_manager {
 static int is_shadow(struct dm_transaction_manager *tm, dm_block_t b)
 {
 	int r = 0;
-	unsigned bucket = dm_hash_block(b, HASH_MASK);
 	struct shadow_info *si;
 	struct hlist_node *n;
 
 	spin_lock(&tm->lock);
-	hlist_for_each_entry(si, n, tm->buckets + bucket, hlist)
+	hash_for_each_possible(tm->hash, si, n, hlist, b)
 		if (si->where == b) {
 			r = 1;
 			break;
@@ -65,15 +63,13 @@ static int is_shadow(struct dm_transaction_manager *tm, dm_block_t b)
  */
 static void insert_shadow(struct dm_transaction_manager *tm, dm_block_t b)
 {
-	unsigned bucket;
 	struct shadow_info *si;
 
 	si = kmalloc(sizeof(*si), GFP_NOIO);
 	if (si) {
 		si->where = b;
-		bucket = dm_hash_block(b, HASH_MASK);
 		spin_lock(&tm->lock);
-		hlist_add_head(&si->hlist, tm->buckets + bucket);
+		hash_add(tm->hash, &si->hlist, b);
 		spin_unlock(&tm->lock);
 	}
 }
@@ -82,18 +78,12 @@ static void wipe_shadow_table(struct dm_transaction_manager *tm)
 {
 	struct shadow_info *si;
 	struct hlist_node *n, *tmp;
-	struct hlist_head *bucket;
 	int i;
 
 	spin_lock(&tm->lock);
-	for (i = 0; i < HASH_SIZE; i++) {
-		bucket = tm->buckets + i;
-		hlist_for_each_entry_safe(si, n, tmp, bucket, hlist)
-			kfree(si);
-
-		INIT_HLIST_HEAD(bucket);
-	}
-
+	hash_for_each_safe(tm->hash, i, n, tmp, si, hlist)
+		kfree(si);
+	hash_init(tm->hash);
 	spin_unlock(&tm->lock);
 }
 
@@ -102,7 +92,6 @@ static void wipe_shadow_table(struct dm_transaction_manager *tm)
 static struct dm_transaction_manager *dm_tm_create(struct dm_block_manager *bm,
 						   struct dm_space_map *sm)
 {
-	int i;
 	struct dm_transaction_manager *tm;
 
 	tm = kmalloc(sizeof(*tm), GFP_KERNEL);
@@ -115,8 +104,7 @@ static struct dm_transaction_manager *dm_tm_create(struct dm_block_manager *bm,
 	tm->sm = sm;
 
 	spin_lock_init(&tm->lock);
-	for (i = 0; i < HASH_SIZE; i++)
-		INIT_HLIST_HEAD(tm->buckets + i);
+	hash_init(tm->hash);
 
 	return tm;
 }
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
