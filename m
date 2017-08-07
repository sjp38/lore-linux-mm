Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 627C16B02FD
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 03:14:14 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u199so89892618pgb.13
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 00:14:14 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id p91si4959184plb.416.2017.08.07.00.14.12
        for <linux-mm@kvack.org>;
        Mon, 07 Aug 2017 00:14:13 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v8 02/14] lockdep: Add a function building a chain between two classes
Date: Mon,  7 Aug 2017 16:12:49 +0900
Message-Id: <1502089981-21272-3-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

Crossrelease needs to build a chain between two classes regardless of
their contexts. However, add_chain_cache() cannot be used for that
purpose since it assumes that it's called in the acquisition context
of the hlock. So this patch introduces a new function doing it.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 kernel/locking/lockdep.c | 70 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 70 insertions(+)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 9260b40..9d16723 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -2126,6 +2126,76 @@ static int check_no_collision(struct task_struct *curr,
 }
 
 /*
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
+#ifdef CONFIG_DEBUG_LOCKDEP
+	/*
+	 * Important for check_no_collision().
+	 */
+	else {
+		if (!debug_locks_off_graph_unlock())
+			return 0;
+
+		print_lockdep_off("BUG: MAX_LOCKDEP_CHAIN_HLOCKS too low!");
+		dump_stack();
+		return 0;
+	}
+#endif
+
+	hlist_add_head_rcu(&chain->entry, hash_head);
+	debug_atomic_inc(chain_lookup_misses);
+	inc_chains();
+
+	return 1;
+}
+
+/*
  * Adds a dependency chain into chain hashtable. And must be called with
  * graph_lock held.
  *
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
