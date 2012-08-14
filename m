Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id B17C26B002B
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 12:25:52 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jc3so297284bkc.14
        for <linux-mm@kvack.org>; Tue, 14 Aug 2012 09:25:52 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH 09/16] SUNRPC/cache: use new hashtable implementation
Date: Tue, 14 Aug 2012 18:24:43 +0200
Message-Id: <1344961490-4068-10-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1344961490-4068-1-git-send-email-levinsasha928@gmail.com>
References: <1344961490-4068-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com, Sasha Levin <levinsasha928@gmail.com>

Switch cache to use the new hashtable implementation. This reduces the amount of
generic unrelated code in the cache implementation.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 net/sunrpc/cache.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 2afd2a8..2d1f333 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -28,6 +28,7 @@
 #include <linux/workqueue.h>
 #include <linux/mutex.h>
 #include <linux/pagemap.h>
+#include <linux/hashtable.h>
 #include <asm/ioctls.h>
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/cache.h>
@@ -524,19 +525,18 @@ EXPORT_SYMBOL_GPL(cache_purge);
  * it to be revisited when cache info is available
  */
 
-#define	DFR_HASHSIZE	(PAGE_SIZE/sizeof(struct list_head))
-#define	DFR_HASH(item)	((((long)item)>>4 ^ (((long)item)>>13)) % DFR_HASHSIZE)
+#define	DFR_HASH_BITS	9
 
 #define	DFR_MAX	300	/* ??? */
 
 static DEFINE_SPINLOCK(cache_defer_lock);
 static LIST_HEAD(cache_defer_list);
-static struct hlist_head cache_defer_hash[DFR_HASHSIZE];
+static DEFINE_HASHTABLE(cache_defer_hash, DFR_HASH_BITS)
 static int cache_defer_cnt;
 
 static void __unhash_deferred_req(struct cache_deferred_req *dreq)
 {
-	hlist_del_init(&dreq->hash);
+	hash_del(&dreq->hash);
 	if (!list_empty(&dreq->recent)) {
 		list_del_init(&dreq->recent);
 		cache_defer_cnt--;
@@ -545,10 +545,7 @@ static void __unhash_deferred_req(struct cache_deferred_req *dreq)
 
 static void __hash_deferred_req(struct cache_deferred_req *dreq, struct cache_head *item)
 {
-	int hash = DFR_HASH(item);
-
-	INIT_LIST_HEAD(&dreq->recent);
-	hlist_add_head(&dreq->hash, &cache_defer_hash[hash]);
+	hash_add(cache_defer_hash, &dreq->hash, (unsigned long)item);
 }
 
 static void setup_deferral(struct cache_deferred_req *dreq,
@@ -600,7 +597,7 @@ static void cache_wait_req(struct cache_req *req, struct cache_head *item)
 		 * to clean up
 		 */
 		spin_lock(&cache_defer_lock);
-		if (!hlist_unhashed(&sleeper.handle.hash)) {
+		if (hash_hashed(&sleeper.handle.hash)) {
 			__unhash_deferred_req(&sleeper.handle);
 			spin_unlock(&cache_defer_lock);
 		} else {
@@ -671,12 +668,11 @@ static void cache_revisit_request(struct cache_head *item)
 	struct cache_deferred_req *dreq;
 	struct list_head pending;
 	struct hlist_node *lp, *tmp;
-	int hash = DFR_HASH(item);
 
 	INIT_LIST_HEAD(&pending);
 	spin_lock(&cache_defer_lock);
 
-	hlist_for_each_entry_safe(dreq, lp, tmp, &cache_defer_hash[hash], hash)
+	hash_for_each_possible_safe(cache_defer_hash, dreq, lp, tmp, hash, (unsigned long)item)
 		if (dreq->item == item) {
 			__unhash_deferred_req(dreq);
 			list_add(&dreq->recent, &pending);
@@ -1636,6 +1632,8 @@ static int create_cache_proc_entries(struct cache_detail *cd, struct net *net)
 void __init cache_initialize(void)
 {
 	INIT_DELAYED_WORK_DEFERRABLE(&cache_cleaner, do_cache_clean);
+
+	hash_init(cache_defer_hash);
 }
 
 int cache_register_net(struct cache_detail *cd, struct net *net)
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
