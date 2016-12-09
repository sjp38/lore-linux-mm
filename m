Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD6C6B0266
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 00:16:36 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q10so16719163pgq.7
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 21:16:36 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id z96si32038840plh.236.2016.12.08.21.16.34
        for <linux-mm@kvack.org>;
        Thu, 08 Dec 2016 21:16:35 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v4 04/15] lockdep: Add a function building a chain between two classes
Date: Fri,  9 Dec 2016 14:12:00 +0900
Message-Id: <1481260331-360-5-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

add_chain_cache() should be used in the context where the hlock is
owned since it might be racy in another context. However crossrelease
feature needs to build a chain between two locks regardless of context.
So introduce a new function making it possible.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 kernel/locking/lockdep.c | 56 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 56 insertions(+)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 5df56aa..111839f 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -2105,6 +2105,62 @@ static int check_no_collision(struct task_struct *curr,
 	return 1;
 }
 
+/*
+ * This is for building a chain between just two different classes,
+ * instead of adding a new hlock upon current, which is done by
+ * add_chain_cache().
+ *
+ * This can be called in any context with two classes, while
+ * add_chain_cache() must be done within the lock owener's context
+ * since it uses hlock which might be racy in another context.
+ */
+static inline int add_chain_cache_classes(unsigned int prev,
+					  unsigned int next,
+					  unsigned int irq_context,
+					  u64 chain_key)
+{
+	struct hlist_head *hash_head = chainhashentry(chain_key);
+	struct lock_chain *chain;
+
+	/*
+	 * Allocate a new chain entry from the static array, and add
+	 * it to the hash:
+	 */
+
+	/*
+	 * We might need to take the graph lock, ensure we've got IRQs
+	 * disabled to make this an IRQ-safe lock.. for recursion reasons
+	 * lockdep won't complain about its own locking errors.
+	 */
+	if (DEBUG_LOCKS_WARN_ON(!irqs_disabled()))
+		return 0;
+
+	if (unlikely(nr_lock_chains >= MAX_LOCKDEP_CHAINS)) {
+		if (!debug_locks_off_graph_unlock())
+			return 0;
+
+		print_lockdep_off("BUG: MAX_LOCKDEP_CHAINS too low!");
+		dump_stack();
+		return 0;
+	}
+
+	chain = lock_chains + nr_lock_chains++;
+	chain->chain_key = chain_key;
+	chain->irq_context = irq_context;
+	chain->depth = 2;
+	if (likely(nr_chain_hlocks + chain->depth <= MAX_LOCKDEP_CHAIN_HLOCKS)) {
+		chain->base = nr_chain_hlocks;
+		nr_chain_hlocks += chain->depth;
+		chain_hlocks[chain->base] = prev - 1;
+		chain_hlocks[chain->base + 1] = next -1;
+	}
+	hlist_add_head_rcu(&chain->entry, hash_head);
+	debug_atomic_inc(chain_lookup_misses);
+	inc_chains();
+
+	return 1;
+}
+
 static inline int add_chain_cache(struct task_struct *curr,
 				  struct held_lock *hlock,
 				  u64 chain_key)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
