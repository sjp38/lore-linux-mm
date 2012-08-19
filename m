Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 5B45C6B0075
	for <linux-mm@kvack.org>; Sat, 18 Aug 2012 20:52:28 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jc3so2035235bkc.14
        for <linux-mm@kvack.org>; Sat, 18 Aug 2012 17:52:27 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v2 08/16] block,elevator: use new hashtable implementation
Date: Sun, 19 Aug 2012 02:52:22 +0200
Message-Id: <1345337550-24304-10-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1345337550-24304-1-git-send-email-levinsasha928@gmail.com>
References: <1345337550-24304-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com, Sasha Levin <levinsasha928@gmail.com>

Switch elevator to use the new hashtable implementation. This reduces the amount of
generic unrelated code in the elevator.

This also removes the dymanic allocation of the hash table. The size of the table is
constant so there's no point in paying the price of an extra dereference when accessing
it.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 block/blk.h              |    2 +-
 block/elevator.c         |   23 ++++-------------------
 include/linux/elevator.h |    5 ++++-
 3 files changed, 9 insertions(+), 21 deletions(-)

diff --git a/block/blk.h b/block/blk.h
index 2a0ea32..5650d48 100644
--- a/block/blk.h
+++ b/block/blk.h
@@ -61,7 +61,7 @@ static inline void blk_clear_rq_complete(struct request *rq)
 /*
  * Internal elevator interface
  */
-#define ELV_ON_HASH(rq)		(!hlist_unhashed(&(rq)->hash))
+#define ELV_ON_HASH(rq) hash_hashed(&(rq)->hash)
 
 void blk_insert_flush(struct request *rq);
 void blk_abort_flushes(struct request_queue *q);
diff --git a/block/elevator.c b/block/elevator.c
index 6a55d41..f462a83 100644
--- a/block/elevator.c
+++ b/block/elevator.c
@@ -46,11 +46,6 @@ static LIST_HEAD(elv_list);
 /*
  * Merge hash stuff.
  */
-static const int elv_hash_shift = 6;
-#define ELV_HASH_BLOCK(sec)	((sec) >> 3)
-#define ELV_HASH_FN(sec)	\
-		(hash_long(ELV_HASH_BLOCK((sec)), elv_hash_shift))
-#define ELV_HASH_ENTRIES	(1 << elv_hash_shift)
 #define rq_hash_key(rq)		(blk_rq_pos(rq) + blk_rq_sectors(rq))
 
 /*
@@ -142,7 +137,6 @@ static struct elevator_queue *elevator_alloc(struct request_queue *q,
 				  struct elevator_type *e)
 {
 	struct elevator_queue *eq;
-	int i;
 
 	eq = kmalloc_node(sizeof(*eq), GFP_KERNEL | __GFP_ZERO, q->node);
 	if (unlikely(!eq))
@@ -151,14 +145,7 @@ static struct elevator_queue *elevator_alloc(struct request_queue *q,
 	eq->type = e;
 	kobject_init(&eq->kobj, &elv_ktype);
 	mutex_init(&eq->sysfs_lock);
-
-	eq->hash = kmalloc_node(sizeof(struct hlist_head) * ELV_HASH_ENTRIES,
-					GFP_KERNEL, q->node);
-	if (!eq->hash)
-		goto err;
-
-	for (i = 0; i < ELV_HASH_ENTRIES; i++)
-		INIT_HLIST_HEAD(&eq->hash[i]);
+	hash_init(eq->hash);
 
 	return eq;
 err:
@@ -173,7 +160,6 @@ static void elevator_release(struct kobject *kobj)
 
 	e = container_of(kobj, struct elevator_queue, kobj);
 	elevator_put(e->type);
-	kfree(e->hash);
 	kfree(e);
 }
 
@@ -240,7 +226,7 @@ EXPORT_SYMBOL(elevator_exit);
 
 static inline void __elv_rqhash_del(struct request *rq)
 {
-	hlist_del_init(&rq->hash);
+	hash_del(&rq->hash);
 }
 
 static void elv_rqhash_del(struct request_queue *q, struct request *rq)
@@ -254,7 +240,7 @@ static void elv_rqhash_add(struct request_queue *q, struct request *rq)
 	struct elevator_queue *e = q->elevator;
 
 	BUG_ON(ELV_ON_HASH(rq));
-	hlist_add_head(&rq->hash, &e->hash[ELV_HASH_FN(rq_hash_key(rq))]);
+	hash_add(e->hash, &rq->hash, rq_hash_key(rq));
 }
 
 static void elv_rqhash_reposition(struct request_queue *q, struct request *rq)
@@ -266,11 +252,10 @@ static void elv_rqhash_reposition(struct request_queue *q, struct request *rq)
 static struct request *elv_rqhash_find(struct request_queue *q, sector_t offset)
 {
 	struct elevator_queue *e = q->elevator;
-	struct hlist_head *hash_list = &e->hash[ELV_HASH_FN(offset)];
 	struct hlist_node *entry, *next;
 	struct request *rq;
 
-	hlist_for_each_entry_safe(rq, entry, next, hash_list, hash) {
+	hash_for_each_possible_safe(e->hash, rq, entry, next, hash, offset) {
 		BUG_ON(!ELV_ON_HASH(rq));
 
 		if (unlikely(!rq_mergeable(rq))) {
diff --git a/include/linux/elevator.h b/include/linux/elevator.h
index c03af76..20b539c 100644
--- a/include/linux/elevator.h
+++ b/include/linux/elevator.h
@@ -2,6 +2,7 @@
 #define _LINUX_ELEVATOR_H
 
 #include <linux/percpu.h>
+#include <linux/hashtable.h>
 
 #ifdef CONFIG_BLOCK
 
@@ -96,6 +97,8 @@ struct elevator_type
 	struct list_head list;
 };
 
+#define ELV_HASH_BITS 6
+
 /*
  * each queue has an elevator_queue associated with it
  */
@@ -105,7 +108,7 @@ struct elevator_queue
 	void *elevator_data;
 	struct kobject kobj;
 	struct mutex sysfs_lock;
-	struct hlist_head *hash;
+	DEFINE_HASHTABLE(hash, ELV_HASH_BITS);
 	unsigned int registered:1;
 };
 
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
