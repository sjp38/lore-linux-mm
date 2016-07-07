Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7D3086B0265
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 05:32:17 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j134so11377376oib.1
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 02:32:17 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id p191si2751627ioe.171.2016.07.07.02.32.16
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 02:32:16 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [RFC v2 01/13] lockdep: Refactor lookup_chain_cache()
Date: Thu,  7 Jul 2016 18:29:51 +0900
Message-Id: <1467883803-29132-2-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
References: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, npiggin@kernel.dk, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Currently, lookup_chain_cache() provides both "lookup" and "add"
functionalities in a function. However each one is useful indivisually.
Some features, e.g. crossrelease, can use each one indivisually.
Thus, splited these functionalities into 2 functions.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 kernel/locking/lockdep.c | 125 ++++++++++++++++++++++++++++++-----------------
 1 file changed, 79 insertions(+), 46 deletions(-)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 716547f..efd001c 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -2010,15 +2010,9 @@ struct lock_class *lock_chain_get_class(struct lock_chain *chain, int i)
 	return lock_classes + chain_hlocks[chain->base + i];
 }
 
-/*
- * Look up a dependency chain. If the key is not present yet then
- * add it and return 1 - in this case the new dependency chain is
- * validated. If the key is already hashed, return 0.
- * (On return with 1 graph_lock is held.)
- */
-static inline int lookup_chain_cache(struct task_struct *curr,
-				     struct held_lock *hlock,
-				     u64 chain_key)
+static inline int add_chain_cache(struct task_struct *curr,
+				  struct held_lock *hlock,
+				  u64 chain_key)
 {
 	struct lock_class *class = hlock_class(hlock);
 	struct hlist_head *hash_head = chainhashentry(chain_key);
@@ -2027,46 +2021,18 @@ static inline int lookup_chain_cache(struct task_struct *curr,
 	int i, j;
 
 	/*
+	 * Allocate a new chain entry from the static array, and add
+	 * it to the hash:
+	 */
+
+	/*
 	 * We might need to take the graph lock, ensure we've got IRQs
 	 * disabled to make this an IRQ-safe lock.. for recursion reasons
 	 * lockdep won't complain about its own locking errors.
 	 */
 	if (DEBUG_LOCKS_WARN_ON(!irqs_disabled()))
 		return 0;
-	/*
-	 * We can walk it lock-free, because entries only get added
-	 * to the hash:
-	 */
-	hlist_for_each_entry_rcu(chain, hash_head, entry) {
-		if (chain->chain_key == chain_key) {
-cache_hit:
-			debug_atomic_inc(chain_lookup_hits);
-			if (very_verbose(class))
-				printk("\nhash chain already cached, key: "
-					"%016Lx tail class: [%p] %s\n",
-					(unsigned long long)chain_key,
-					class->key, class->name);
-			return 0;
-		}
-	}
-	if (very_verbose(class))
-		printk("\nnew hash chain, key: %016Lx tail class: [%p] %s\n",
-			(unsigned long long)chain_key, class->key, class->name);
-	/*
-	 * Allocate a new chain entry from the static array, and add
-	 * it to the hash:
-	 */
-	if (!graph_lock())
-		return 0;
-	/*
-	 * We have to walk the chain again locked - to avoid duplicates:
-	 */
-	hlist_for_each_entry(chain, hash_head, entry) {
-		if (chain->chain_key == chain_key) {
-			graph_unlock();
-			goto cache_hit;
-		}
-	}
+
 	if (unlikely(nr_lock_chains >= MAX_LOCKDEP_CHAINS)) {
 		if (!debug_locks_off_graph_unlock())
 			return 0;
@@ -2102,6 +2068,72 @@ cache_hit:
 	return 1;
 }
 
+/*
+ * Look up a dependency chain.
+ */
+static inline struct lock_chain *lookup_chain_cache(u64 chain_key)
+{
+	struct hlist_head *hash_head = chainhashentry(chain_key);
+	struct lock_chain *chain;
+
+	/*
+	 * We can walk it lock-free, because entries only get added
+	 * to the hash:
+	 */
+	hlist_for_each_entry_rcu(chain, hash_head, entry) {
+		if (chain->chain_key == chain_key) {
+			debug_atomic_inc(chain_lookup_hits);
+			return chain;
+		}
+	}
+	return NULL;
+}
+
+/*
+ * If the key is not present yet in dependency chain cache then
+ * add it and return 1 - in this case the new dependency chain is
+ * validated. If the key is already hashed, return 0.
+ * (On return with 1 graph_lock is held.)
+ */
+static inline int lookup_chain_cache_add(struct task_struct *curr,
+					 struct held_lock *hlock,
+					 u64 chain_key)
+{
+	struct lock_class *class = hlock_class(hlock);
+	struct lock_chain *chain = lookup_chain_cache(chain_key);
+
+	if (chain) {
+cache_hit:
+		if (very_verbose(class))
+			printk("\nhash chain already cached, key: "
+					"%016Lx tail class: [%p] %s\n",
+					(unsigned long long)chain_key,
+					class->key, class->name);
+		return 0;
+	}
+
+	if (very_verbose(class))
+		printk("\nnew hash chain, key: %016Lx tail class: [%p] %s\n",
+			(unsigned long long)chain_key, class->key, class->name);
+
+	if (!graph_lock())
+		return 0;
+
+	/*
+	 * We have to walk the chain again locked - to avoid duplicates:
+	 */
+	chain = lookup_chain_cache(chain_key);
+	if (chain) {
+		graph_unlock();
+		goto cache_hit;
+	}
+
+	if (!add_chain_cache(curr, hlock, chain_key))
+		return 0;
+
+	return 1;
+}
+
 static int validate_chain(struct task_struct *curr, struct lockdep_map *lock,
 		struct held_lock *hlock, int chain_head, u64 chain_key)
 {
@@ -2112,11 +2144,11 @@ static int validate_chain(struct task_struct *curr, struct lockdep_map *lock,
 	 *
 	 * We look up the chain_key and do the O(N^2) check and update of
 	 * the dependencies only if this is a new dependency chain.
-	 * (If lookup_chain_cache() returns with 1 it acquires
+	 * (If lookup_chain_cache_add() return with 1 it acquires
 	 * graph_lock for us)
 	 */
 	if (!hlock->trylock && hlock->check &&
-	    lookup_chain_cache(curr, hlock, chain_key)) {
+	    lookup_chain_cache_add(curr, hlock, chain_key)) {
 		/*
 		 * Check whether last held lock:
 		 *
@@ -2147,9 +2179,10 @@ static int validate_chain(struct task_struct *curr, struct lockdep_map *lock,
 		if (!chain_head && ret != 2)
 			if (!check_prevs_add(curr, hlock))
 				return 0;
+
 		graph_unlock();
 	} else
-		/* after lookup_chain_cache(): */
+		/* after lookup_chain_cache_add(): */
 		if (unlikely(!debug_locks))
 			return 0;
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
