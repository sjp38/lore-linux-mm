Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 97CBB6B050C
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 12:31:09 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id a186so1775095pge.5
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 09:31:09 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id q129si4890012pga.763.2017.08.25.09.31.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 09:31:07 -0700 (PDT)
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH 1/2 v2] sched/wait: Break up long wake list walk
Date: Fri, 25 Aug 2017 09:13:54 -0700
Message-Id: <83f675ad385d67760da4b99cd95ee912ca7c0b44.1503677178.git.tim.c.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Kan Liang <kan.liang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Christopher Lameter <cl@linux.com>, "Eric W . Biederman" <ebiederm@xmission.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We encountered workloads that have very long wake up list on large
systems. A waker takes a long time to traverse the entire wake list and
execute all the wake functions.

We saw page wait list that are up to 3700+ entries long in tests of large
4 and 8 socket systems.  It took 0.8 sec to traverse such list during
wake up.  Any other CPU that contends for the list spin lock will spin
for a long time.  It is a result of the numa balancing migration of hot
pages that are shared by many threads.

Multiple CPUs waking are queued up behind the lock, and the last one queued
has to wait until all CPUs did all the wakeups.

The page wait list is traversed with interrupt disabled, which caused
various problems. This was the original cause that triggered the NMI
watch dog timer in: https://patchwork.kernel.org/patch/9800303/ . Only
extending the NMI watch dog timer there helped.

This patch bookmarks the waker's scan position in wake list and break
the wake up walk, to allow access to the list before the waker resume
its walk down the rest of the wait list.  It lowers the interrupt and
rescheduling latency.

This patch also provides a performance boost when combined with the next
patch to break up page wakeup list walk. We saw 22% improvement in the
will-it-scale file pread2 test on a Xeon Phi system running 256 threads.

Thanks.

Tim

v2:
Merged in Linus' changes to remove the bookmark_wake_function, and
simply access to flags.

Reported-by: Kan Liang <kan.liang@intel.com>
Tested-by: Kan Liang <kan.liang@intel.com>
Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 include/linux/wait.h |  1 +
 kernel/sched/wait.c  | 74 ++++++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 61 insertions(+), 14 deletions(-)

diff --git a/include/linux/wait.h b/include/linux/wait.h
index 5b74e36..80034e8 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -18,6 +18,7 @@ int default_wake_function(struct wait_queue_entry *wq_entry, unsigned mode, int
 /* wait_queue_entry::flags */
 #define WQ_FLAG_EXCLUSIVE	0x01
 #define WQ_FLAG_WOKEN		0x02
+#define WQ_FLAG_BOOKMARK	0x04
 
 /*
  * A single wait-queue entry structure:
diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
index 17f11c6..789dc24 100644
--- a/kernel/sched/wait.c
+++ b/kernel/sched/wait.c
@@ -53,6 +53,12 @@ void remove_wait_queue(struct wait_queue_head *wq_head, struct wait_queue_entry
 }
 EXPORT_SYMBOL(remove_wait_queue);
 
+/*
+ * Scan threshold to break wait queue walk.
+ * This allows a waker to take a break from holding the
+ * wait queue lock during the wait queue walk.
+ */
+#define WAITQUEUE_WALK_BREAK_CNT 64
 
 /*
  * The core wakeup function. Non-exclusive wakeups (nr_exclusive == 0) just
@@ -63,17 +69,64 @@ EXPORT_SYMBOL(remove_wait_queue);
  * started to run but is not in state TASK_RUNNING. try_to_wake_up() returns
  * zero in this (rare) case, and we handle it by continuing to scan the queue.
  */
-static void __wake_up_common(struct wait_queue_head *wq_head, unsigned int mode,
-			int nr_exclusive, int wake_flags, void *key)
+static int __wake_up_common(struct wait_queue_head *wq_head, unsigned int mode,
+			int nr_exclusive, int wake_flags, void *key,
+			wait_queue_entry_t *bookmark)
 {
 	wait_queue_entry_t *curr, *next;
+	int cnt = 0;
+
+	if (bookmark && (bookmark->flags & WQ_FLAG_BOOKMARK)) {
+		curr = list_next_entry(bookmark, entry);
 
-	list_for_each_entry_safe(curr, next, &wq_head->head, entry) {
+		list_del(&bookmark->entry);
+		bookmark->flags = 0;
+	} else
+		curr = list_first_entry(&wq_head->head, wait_queue_entry_t, entry);
+
+	if (&curr->entry == &wq_head->head)
+		return nr_exclusive;
+
+	list_for_each_entry_safe_from(curr, next, &wq_head->head, entry) {
 		unsigned flags = curr->flags;
 
+		if (flags & WQ_FLAG_BOOKMARK)
+			continue;
+
 		if (curr->func(curr, mode, wake_flags, key) &&
 				(flags & WQ_FLAG_EXCLUSIVE) && !--nr_exclusive)
 			break;
+
+		if (bookmark && (++cnt > WAITQUEUE_WALK_BREAK_CNT) &&
+				(&next->entry != &wq_head->head)) {
+			bookmark->flags = WQ_FLAG_BOOKMARK;
+			list_add_tail(&bookmark->entry, &next->entry);
+			break;
+		}
+	}
+	return nr_exclusive;
+}
+
+static void __wake_up_common_lock(struct wait_queue_head *wq_head, unsigned int mode,
+			int nr_exclusive, int wake_flags, void *key)
+{
+	unsigned long flags;
+	wait_queue_entry_t bookmark;
+
+	bookmark.flags = 0;
+	bookmark.private = NULL;
+	bookmark.func = NULL;
+	INIT_LIST_HEAD(&bookmark.entry);
+
+	spin_lock_irqsave(&wq_head->lock, flags);
+	nr_exclusive = __wake_up_common(wq_head, mode, nr_exclusive, wake_flags, key, &bookmark);
+	spin_unlock_irqrestore(&wq_head->lock, flags);
+
+	while (bookmark.flags & WQ_FLAG_BOOKMARK) {
+		spin_lock_irqsave(&wq_head->lock, flags);
+		nr_exclusive = __wake_up_common(wq_head, mode, nr_exclusive,
+						wake_flags, key, &bookmark);
+		spin_unlock_irqrestore(&wq_head->lock, flags);
 	}
 }
 
@@ -90,11 +143,7 @@ static void __wake_up_common(struct wait_queue_head *wq_head, unsigned int mode,
 void __wake_up(struct wait_queue_head *wq_head, unsigned int mode,
 			int nr_exclusive, void *key)
 {
-	unsigned long flags;
-
-	spin_lock_irqsave(&wq_head->lock, flags);
-	__wake_up_common(wq_head, mode, nr_exclusive, 0, key);
-	spin_unlock_irqrestore(&wq_head->lock, flags);
+	__wake_up_common_lock(wq_head, mode, nr_exclusive, 0, key);
 }
 EXPORT_SYMBOL(__wake_up);
 
@@ -103,13 +152,13 @@ EXPORT_SYMBOL(__wake_up);
  */
 void __wake_up_locked(struct wait_queue_head *wq_head, unsigned int mode, int nr)
 {
-	__wake_up_common(wq_head, mode, nr, 0, NULL);
+	__wake_up_common(wq_head, mode, nr, 0, NULL, NULL);
 }
 EXPORT_SYMBOL_GPL(__wake_up_locked);
 
 void __wake_up_locked_key(struct wait_queue_head *wq_head, unsigned int mode, void *key)
 {
-	__wake_up_common(wq_head, mode, 1, 0, key);
+	__wake_up_common(wq_head, mode, 1, 0, key, NULL);
 }
 EXPORT_SYMBOL_GPL(__wake_up_locked_key);
 
@@ -133,7 +182,6 @@ EXPORT_SYMBOL_GPL(__wake_up_locked_key);
 void __wake_up_sync_key(struct wait_queue_head *wq_head, unsigned int mode,
 			int nr_exclusive, void *key)
 {
-	unsigned long flags;
 	int wake_flags = 1; /* XXX WF_SYNC */
 
 	if (unlikely(!wq_head))
@@ -142,9 +190,7 @@ void __wake_up_sync_key(struct wait_queue_head *wq_head, unsigned int mode,
 	if (unlikely(nr_exclusive != 1))
 		wake_flags = 0;
 
-	spin_lock_irqsave(&wq_head->lock, flags);
-	__wake_up_common(wq_head, mode, nr_exclusive, wake_flags, key);
-	spin_unlock_irqrestore(&wq_head->lock, flags);
+	__wake_up_common_lock(wq_head, mode, nr_exclusive, wake_flags, key);
 }
 EXPORT_SYMBOL_GPL(__wake_up_sync_key);
 
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
