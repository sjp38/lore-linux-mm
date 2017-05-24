Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1DFBB6B0314
	for <linux-mm@kvack.org>; Wed, 24 May 2017 05:00:52 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id x25so108623785pgc.10
        for <linux-mm@kvack.org>; Wed, 24 May 2017 02:00:52 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id r63si23474570plb.129.2017.05.24.02.00.50
        for <linux-mm@kvack.org>;
        Wed, 24 May 2017 02:00:50 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v7 08/16] lockdep: Avoid adding redundant direct links of crosslocks
Date: Wed, 24 May 2017 17:59:41 +0900
Message-Id: <1495616389-29772-9-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1495616389-29772-1-git-send-email-byungchul.park@lge.com>
References: <1495616389-29772-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

We can skip adding a dependency 'AX -> B', in case that we ensure 'AX ->
the previous of B in hlocks' to be created, where AX is a crosslock and
B is a typical lock. Remember that two adjacent locks in hlocks generate
a dependency like 'prev -> next', that is, 'the previous of B in hlocks
-> B' in this case.

For example:

             in hlocks[]
             ------------
          ^  A (gen_id: 4) --+
          |                  | previous gen_id
          |  B (gen_id: 3) <-+
          |  C (gen_id: 3)
          |  D (gen_id: 2)
   oldest |  E (gen_id: 1)

             in xhlocks[]
             ------------
          ^  A (gen_id: 4, prev_gen_id: 3(B's gen id))
          |  B (gen_id: 3, prev_gen_id: 3(C's gen id))
          |  C (gen_id: 3, prev_gen_id: 2(D's gen id))
          |  D (gen_id: 2, prev_gen_id: 1(E's gen id))
   oldest |  E (gen_id: 1, prev_gen_id: NA)

On commit for a crosslock AX(gen_id = 3), it's engough to add 'AX -> C',
but adding 'AX -> B' and 'AX -> A' is unnecessary since 'AX -> C', 'C ->
B' and 'B -> A' cover them, which are guaranteed to be generated.

This patch intoduces a variable, prev_gen_id, to avoid adding this kind
of redundant dependencies. In other words, the previous in hlocks will
anyway handle it if the previous's gen_id >= the crosslock's gen_id.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/lockdep.h  | 11 +++++++++++
 kernel/locking/lockdep.c | 32 ++++++++++++++++++++++++++++++--
 2 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index f7c730a..e5c5cc4 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -284,6 +284,17 @@ struct held_lock {
  */
 struct hist_lock {
 	/*
+	 * We can skip adding a dependency 'a target crosslock -> this
+	 * lock', in case that we ensure 'the target crosslock -> the
+	 * previous lock in held_locks' to be created. Remember that
+	 * 'the previous lock in held_locks -> this lock' is guaranteed
+	 * to be created, and 'A -> B' and 'B -> C' cover 'A -> C'.
+	 *
+	 * Keep the previous's gen_id to make the decision.
+	 */
+	unsigned int		prev_gen_id;
+
+	/*
 	 * Id for each entry in the ring buffer. This is used to
 	 * decide whether the ring buffer was overwritten or not.
 	 *
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 09f5eec..a14d2ca 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -4778,7 +4778,7 @@ static inline int xhlock_valid(struct hist_lock *xhlock)
  *
  * Irq disable is only required.
  */
-static void add_xhlock(struct held_lock *hlock)
+static void add_xhlock(struct held_lock *hlock, unsigned int prev_gen_id)
 {
 	unsigned int idx = ++current->xhlock_idx;
 	struct hist_lock *xhlock = &xhlock(idx);
@@ -4793,6 +4793,11 @@ static void add_xhlock(struct held_lock *hlock)
 
 	/* Initialize hist_lock's members */
 	xhlock->hlock = *hlock;
+	/*
+	 * prev_gen_id is used to skip adding redundant dependencies,
+	 * which can be covered by the previous lock in held_locks.
+	 */
+	xhlock->prev_gen_id = prev_gen_id;
 	xhlock->hist_id = current->hist_id++;
 
 	xhlock->trace.nr_entries = 0;
@@ -4813,6 +4818,11 @@ static inline int same_context_xhlock(struct hist_lock *xhlock)
  */
 static void check_add_xhlock(struct held_lock *hlock)
 {
+	struct held_lock *prev;
+	struct held_lock *start;
+	unsigned int gen_id;
+	unsigned int gen_id_invalid;
+
 	/*
 	 * Record a hist_lock, only in case that acquisitions ahead
 	 * could depend on the held_lock. For example, if the held_lock
@@ -4822,7 +4832,22 @@ static void check_add_xhlock(struct held_lock *hlock)
 	if (!current->xhlocks || !depend_before(hlock))
 		return;
 
-	add_xhlock(hlock);
+	gen_id = (unsigned int)atomic_read(&cross_gen_id);
+	/*
+	 * gen_id_invalid should be old enough to be invalid.
+	 * Current gen_id - (UINIT_MAX / 4) would be a good
+	 * value to meet it.
+	 */
+	gen_id_invalid = gen_id - (UINT_MAX / 4);
+	start = current->held_locks;
+
+	for (prev = hlock - 1; prev >= start &&
+			!depend_before(prev); prev--);
+
+	if (prev < start)
+		add_xhlock(hlock, gen_id_invalid);
+	else if (prev->gen_id != gen_id)
+		add_xhlock(hlock, prev->gen_id);
 }
 
 /*
@@ -4979,6 +5004,9 @@ static void commit_xhlocks(struct cross_lock *xlock)
 
 			prev_hist_id = xhlock->hist_id;
 
+			if (!before(xhlock->prev_gen_id, xlock->hlock.gen_id))
+				continue;
+
 			/*
 			 * commit_xhlock() returns 0 with graph_lock already
 			 * released if fail.
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
