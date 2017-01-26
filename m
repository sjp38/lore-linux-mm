Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 802116B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 02:53:32 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id d185so299660711pgc.2
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 23:53:32 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id b1si730906plm.7.2017.01.25.23.53.30
        for <linux-mm@kvack.org>;
        Wed, 25 Jan 2017 23:53:31 -0800 (PST)
Date: Thu, 26 Jan 2017 16:53:27 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v5 01/13] lockdep: Refactor lookup_chain_cache()
Message-ID: <20170126075326.GB16086@X58A-UD3R>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-2-git-send-email-byungchul.park@lge.com>
 <20170119091627.GG15084@tardis.cn.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170119091627.GG15084@tardis.cn.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boqun Feng <boqun.feng@gmail.com>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

I added a comment that you recommanded after modifying a bit, like the
following. Please let me know if the my sentence is rather awkward.

Thank you.

----->8-----
commit bb8ad95a4944eec6ab72e950ef063960791b0d8c
Author: Byungchul Park <byungchul.park@lge.com>
Date:   Tue Jan 24 16:44:16 2017 +0900

    lockdep: Refactor lookup_chain_cache()
    
    Currently, lookup_chain_cache() provides both 'lookup' and 'add'
    functionalities in a function. However, each is useful. So this
    patch makes lookup_chain_cache() only do 'lookup' functionality and
    makes add_chain_cahce() only do 'add' functionality. And it's more
    readable than before.
    
    Signed-off-by: Byungchul Park <byungchul.park@lge.com>

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 4d7ffc0..0c6e6b7 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -2110,14 +2110,15 @@ static int check_no_collision(struct task_struct *curr,
 }
 
 /*
- * Look up a dependency chain. If the key is not present yet then
- * add it and return 1 - in this case the new dependency chain is
- * validated. If the key is already hashed, return 0.
- * (On return with 1 graph_lock is held.)
+ * Adds a dependency chain into chain hashtable. And must be called with
+ * graph_lock held.
+ *
+ * Return 0 if fail, and graph_lock is released.
+ * Return 1 if succeed, with graph_lock held.
  */
-static inline int lookup_chain_cache(struct task_struct *curr,
-				     struct held_lock *hlock,
-				     u64 chain_key)
+static inline int add_chain_cache(struct task_struct *curr,
+				  struct held_lock *hlock,
+				  u64 chain_key)
 {
 	struct lock_class *class = hlock_class(hlock);
 	struct hlist_head *hash_head = chainhashentry(chain_key);
@@ -2125,49 +2126,18 @@ static inline int lookup_chain_cache(struct task_struct *curr,
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
-			if (!check_no_collision(curr, hlock, chain))
-				return 0;
 
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
 	if (unlikely(nr_lock_chains >= MAX_LOCKDEP_CHAINS)) {
 		if (!debug_locks_off_graph_unlock())
 			return 0;
@@ -2219,6 +2189,75 @@ static inline int lookup_chain_cache(struct task_struct *curr,
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
+		if (!check_no_collision(curr, hlock, chain))
+			return 0;
+
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
@@ -2229,11 +2268,11 @@ static int validate_chain(struct task_struct *curr, struct lockdep_map *lock,
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
@@ -2264,9 +2303,10 @@ static int validate_chain(struct task_struct *curr, struct lockdep_map *lock,
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
