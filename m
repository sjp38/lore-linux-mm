Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6F8D06B038F
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 04:26:26 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 77so340540596pgc.5
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 01:26:26 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id l3si14020580pgl.298.2017.03.14.01.26.19
        for <linux-mm@kvack.org>;
        Tue, 14 Mar 2017 01:26:20 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v6 06/15] lockdep: Handle non(or multi)-acquisition of a crosslock
Date: Tue, 14 Mar 2017 17:18:53 +0900
Message-ID: <1489479542-27030-7-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
References: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

No acquisition might be in progress on commit of a crosslock. Completion
operations enabling crossrelease are the case like:

   CONTEXT X                         CONTEXT Y
   ---------                         ---------
   trigger completion context
                                     complete AX
                                        commit AX
   wait_for_complete AX
      acquire AX
      wait

   where AX is a crosslock.

When no acquisition is in progress, we should not perform commit because
the lock does not exist, which might cause incorrect memory access. So
we have to track the number of acquisitions of a crosslock to handle it.

Moreover, in case that more than one acquisition of a crosslock are
overlapped like:

   CONTEXT W        CONTEXT X        CONTEXT Y        CONTEXT Z
   ---------        ---------        ---------        ---------
   acquire AX (gen_id: 1)
                                     acquire A
                    acquire AX (gen_id: 10)
                                     acquire B
                                     commit AX
                                                      acquire C
                                                      commit AX

   where A, B and C are typical locks and AX is a crosslock.

Current crossrelease code performs commits in Y and Z with gen_id = 10.
However, we can use gen_id = 1 to do it, since not only 'acquire AX in X'
but 'acquire AX in W' also depends on each acquisition in Y and Z until
their commits. So make it use gen_id = 1 instead of 10 on their commits,
which adds an additional dependency 'AX -> A' in the example above.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/lockdep.h  | 22 +++++++++++++++++++-
 kernel/locking/lockdep.c | 52 ++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 62 insertions(+), 12 deletions(-)

diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index 9902b2a..5356f71 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -312,6 +312,19 @@ struct hist_lock {
  */
 struct cross_lock {
 	/*
+	 * When more than one acquisition of crosslocks are overlapped,
+	 * we have to perform commit for them based on cross_gen_id of
+	 * the first acquisition, which allows us to add more true
+	 * dependencies.
+	 *
+	 * Moreover, when no acquisition of a crosslock is in progress,
+	 * we should not perform commit because the lock might not exist
+	 * any more, which might cause incorrect memory access. So we
+	 * have to track the number of acquisitions of a crosslock.
+	 */
+	int nr_acquire;
+
+	/*
 	 * Seperate hlock instance. This will be used at commit step.
 	 *
 	 * TODO: Use a smaller data structure containing only necessary
@@ -510,9 +523,16 @@ extern void lockdep_init_map_crosslock(struct lockdep_map *lock,
 				       int subclass);
 extern void lock_commit_crosslock(struct lockdep_map *lock);
 
+/*
+ * What we essencially have to initialize is 'nr_acquire'. Other members
+ * will be initialized in add_xlock().
+ */
+#define STATIC_CROSS_LOCK_INIT() \
+	{ .nr_acquire = 0,}
+
 #define STATIC_CROSS_LOCKDEP_MAP_INIT(_name, _key) \
 	{ .map.name = (_name), .map.key = (void *)(_key), \
-	  .map.cross = 1, }
+	  .map.cross = 1, .xlock = STATIC_CROSS_LOCK_INIT(), }
 
 /*
  * To initialize a lockdep_map statically use this macro.
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index db15fce..ec4f6af 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -4780,11 +4780,28 @@ static int add_xlock(struct held_lock *hlock)
 
 	xlock = &((struct lockdep_map_cross *)hlock->instance)->xlock;
 
+	/*
+	 * When acquisitions for a crosslock are overlapped, we use
+	 * nr_acquire to perform commit for them, based on cross_gen_id
+	 * of the first acquisition, which allows to add additional
+	 * dependencies.
+	 *
+	 * Moreover, when no acquisition of a crosslock is in progress,
+	 * we should not perform commit because the lock might not exist
+	 * any more, which might cause incorrect memory access. So we
+	 * have to track the number of acquisitions of a crosslock.
+	 *
+	 * depend_after() is necessary to initialize only the first
+	 * valid xlock so that the xlock can be used on its commit.
+	 */
+	if (xlock->nr_acquire++ && depend_after(&xlock->hlock))
+		goto unlock;
+
 	gen_id = (unsigned int)atomic_inc_return(&cross_gen_id);
 	xlock->hlock = *hlock;
 	xlock->hlock.gen_id = gen_id;
+unlock:
 	graph_unlock();
-
 	return 1;
 }
 
@@ -4874,18 +4891,20 @@ static int commit_xhlocks(struct cross_lock *xlock)
 	if (!graph_lock())
 		return 0;
 
-	for (i = cur - 1; !xhlock_same(i, cur); i--) {
-		struct hist_lock *xhlock = &xhlock(i);
+	if (xlock->nr_acquire) {
+		for (i = cur - 1; !xhlock_same(i, cur); i--) {
+			struct hist_lock *xhlock = &xhlock(i);
 
-		if (!xhlock_used(xhlock))
-			break;
+			if (!xhlock_used(xhlock))
+				break;
 
-		if (before(xhlock->hlock.gen_id, xlock->hlock.gen_id))
-			break;
+			if (before(xhlock->hlock.gen_id, xlock->hlock.gen_id))
+				break;
 
-		if (same_context_xhlock(xhlock) &&
-		    !commit_xhlock(xlock, xhlock))
-			return 0;
+			if (same_context_xhlock(xhlock) &&
+			    !commit_xhlock(xlock, xhlock))
+				return 0;
+		}
 	}
 
 	graph_unlock();
@@ -4923,16 +4942,27 @@ void lock_commit_crosslock(struct lockdep_map *lock)
 EXPORT_SYMBOL_GPL(lock_commit_crosslock);
 
 /*
+ * return 0: Stop. Failed to acquire graph_lock.
  * return 1: Done. No more release ops is needed.
  * return 2: Need to do normal release operation.
  */
 static int lock_release_crosslock(struct lockdep_map *lock)
 {
-	return cross_lock(lock) ? 1 : 2;
+	if (cross_lock(lock)) {
+		if (!graph_lock())
+			return 0;
+		((struct lockdep_map_cross *)lock)->xlock.nr_acquire--;
+		graph_unlock();
+		return 1;
+	}
+	return 2;
 }
 
 static void cross_init(struct lockdep_map *lock, int cross)
 {
+	if (cross)
+		((struct lockdep_map_cross *)lock)->xlock.nr_acquire = 0;
+
 	lock->cross = cross;
 
 	/*
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
