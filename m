Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9E2986B025E
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 05:31:53 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 143so25320749pfx.0
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 02:31:53 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id f8si3371092pff.71.2016.07.07.02.31.51
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 02:31:52 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [RFC v2 02/13] lockdep: Add a function building a chain between two hlocks
Date: Thu,  7 Jul 2016 18:29:52 +0900
Message-Id: <1467883803-29132-3-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
References: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, npiggin@kernel.dk, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org

add_chain_cache() can only be used by current context since it
depends on a task's held_locks which is not protected by lock.
However, it would be useful if a dependency chain can be built
in any context. This patch makes the chain building not depend
on its context.

Especially, crossrelease feature wants to do this. Crossrelease
feature introduces a additional dependency chain consisting of 2
lock classes using 2 hlock instances, to connect dependency
between different contexts.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 kernel/locking/lockdep.c | 57 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 57 insertions(+)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index efd001c..4d51208 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -2010,6 +2010,63 @@ struct lock_class *lock_chain_get_class(struct lock_chain *chain, int i)
 	return lock_classes + chain_hlocks[chain->base + i];
 }
 
+/*
+ * This can make it possible to build a chain between just two
+ * specified hlocks rather than between already held locks of
+ * the current task and newly held lock, which can be done by
+ * add_chain_cache().
+ *
+ * add_chain_cache() must be done within the lock owner's context,
+ * however this can be called in any context if two racy-less hlock
+ * instances were already taken by caller. Thus this can be useful
+ * when building a chain between two hlocks regardless of context.
+ */
+static inline int add_chain_cache_2hlocks(struct held_lock *prev,
+					  struct held_lock *next,
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
+	chain->irq_context = next->irq_context;
+	chain->depth = 2;
+	if (likely(nr_chain_hlocks + chain->depth <= MAX_LOCKDEP_CHAIN_HLOCKS)) {
+		chain->base = nr_chain_hlocks;
+		nr_chain_hlocks += chain->depth;
+		chain_hlocks[chain->base] = prev->class_idx - 1;
+		chain_hlocks[chain->base + 1] = next->class_idx -1;
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
