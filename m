Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id F04566B0510
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 12:31:09 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u20so1715945pgb.10
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 09:31:09 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id q129si4890012pga.763.2017.08.25.09.31.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 09:31:08 -0700 (PDT)
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH 2/2 v2] sched/wait: Introduce lock breaker in wake_up_page_bit
Date: Fri, 25 Aug 2017 09:13:55 -0700
Message-Id: <cd8ce7fbca9c126f7f928b8fa48d7a9197955b45.1503677178.git.tim.c.chen@linux.intel.com>
In-Reply-To: <83f675ad385d67760da4b99cd95ee912ca7c0b44.1503677178.git.tim.c.chen@linux.intel.com>
References: <83f675ad385d67760da4b99cd95ee912ca7c0b44.1503677178.git.tim.c.chen@linux.intel.com>
In-Reply-To: <83f675ad385d67760da4b99cd95ee912ca7c0b44.1503677178.git.tim.c.chen@linux.intel.com>
References: <83f675ad385d67760da4b99cd95ee912ca7c0b44.1503677178.git.tim.c.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Kan Liang <kan.liang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Christopher Lameter <cl@linux.com>, "Eric W . Biederman" <ebiederm@xmission.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Now that we have added breaks in the wait queue scan and allow bookmark
on scan position, we put this logic in the wake_up_page_bit function.

We can have very long page wait list in large system where multiple
pages share the same wait list. We break the wake up walk here to allow
other cpus a chance to access the list, and not to disable the interrupts
when traversing the list for too long.  This reduces the interrupt and
rescheduling latency, and excessive page wait queue lock hold time.

We have to add logic to detect any new arrivals to appropriately clear
the wait bit on the page only when there are no new waiters for a page.
The break in wait list walk open windows for new arrivals for a page
on the wait list during the wake ups. They could be added at the head
or tail of the wait queue depending on whether they are exclusive in
prepare_to_wait_event. So we can't clear the PageWaiters flag if there
are new arrivals during the wake up process.  Otherwise we will skip
the wake_up_page when there are still entries to be woken up.

v2:
Remove bookmark_wake_function

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 include/linux/wait.h |  7 +++++++
 kernel/sched/wait.c  |  7 +++++++
 mm/filemap.c         | 36 ++++++++++++++++++++++++++++++++++--
 3 files changed, 48 insertions(+), 2 deletions(-)

diff --git a/include/linux/wait.h b/include/linux/wait.h
index 80034e8..b926960 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -19,6 +19,7 @@ int default_wake_function(struct wait_queue_entry *wq_entry, unsigned mode, int
 #define WQ_FLAG_EXCLUSIVE	0x01
 #define WQ_FLAG_WOKEN		0x02
 #define WQ_FLAG_BOOKMARK	0x04
+#define WQ_FLAG_ARRIVALS	0x08
 
 /*
  * A single wait-queue entry structure:
@@ -32,6 +33,8 @@ struct wait_queue_entry {
 
 struct wait_queue_head {
 	spinlock_t		lock;
+	unsigned int		waker;
+	unsigned int		flags;
 	struct list_head	head;
 };
 typedef struct wait_queue_head wait_queue_head_t;
@@ -52,6 +55,8 @@ struct task_struct;
 
 #define __WAIT_QUEUE_HEAD_INITIALIZER(name) {					\
 	.lock		= __SPIN_LOCK_UNLOCKED(name.lock),			\
+	.waker		= 0,							\
+	.flags		= 0,							\
 	.head		= { &(name).head, &(name).head } }
 
 #define DECLARE_WAIT_QUEUE_HEAD(name) \
@@ -185,6 +190,8 @@ __remove_wait_queue(struct wait_queue_head *wq_head, struct wait_queue_entry *wq
 
 void __wake_up(struct wait_queue_head *wq_head, unsigned int mode, int nr, void *key);
 void __wake_up_locked_key(struct wait_queue_head *wq_head, unsigned int mode, void *key);
+void __wake_up_locked_key_bookmark(struct wait_queue_head *wq_head,
+		unsigned int mode, void *key, wait_queue_entry_t *bookmark);
 void __wake_up_sync_key(struct wait_queue_head *wq_head, unsigned int mode, int nr, void *key);
 void __wake_up_locked(struct wait_queue_head *wq_head, unsigned int mode, int nr);
 void __wake_up_sync(struct wait_queue_head *wq_head, unsigned int mode, int nr);
diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
index 789dc24..81e7e55 100644
--- a/kernel/sched/wait.c
+++ b/kernel/sched/wait.c
@@ -162,6 +162,13 @@ void __wake_up_locked_key(struct wait_queue_head *wq_head, unsigned int mode, vo
 }
 EXPORT_SYMBOL_GPL(__wake_up_locked_key);
 
+void __wake_up_locked_key_bookmark(struct wait_queue_head *wq_head,
+		unsigned int mode, void *key, wait_queue_entry_t *bookmark)
+{
+	__wake_up_common(wq_head, mode, 1, 0, key, bookmark);
+}
+EXPORT_SYMBOL_GPL(__wake_up_locked_key_bookmark);
+
 /**
  * __wake_up_sync_key - wake up threads blocked on a waitqueue.
  * @wq_head: the waitqueue
diff --git a/mm/filemap.c b/mm/filemap.c
index a497024..a6c7917 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -920,13 +920,41 @@ static void wake_up_page_bit(struct page *page, int bit_nr)
 	wait_queue_head_t *q = page_waitqueue(page);
 	struct wait_page_key key;
 	unsigned long flags;
+	wait_queue_entry_t bookmark;
 
 	key.page = page;
 	key.bit_nr = bit_nr;
 	key.page_match = 0;
 
+	bookmark.flags = 0;
+	bookmark.private = NULL;
+	bookmark.func = NULL;
+	INIT_LIST_HEAD(&bookmark.entry);
+
+	spin_lock_irqsave(&q->lock, flags);
+	/* q->flags will be set to WQ_FLAG_ARRIVALS if items added to wait queue */
+	if (!q->waker)
+		q->flags &= ~WQ_FLAG_ARRIVALS;
+	++ q->waker;
+	__wake_up_locked_key_bookmark(q, TASK_NORMAL, &key, &bookmark);
+	if (!(bookmark.flags & WQ_FLAG_BOOKMARK))
+		goto finish;
+	/*
+	 * Take a breather from holding the lock,
+	 * allow pages that finish wake up asynchronously
+	 * to acquire the lock and remove themselves
+	 * from wait queue
+	 */
+	spin_unlock_irqrestore(&q->lock, flags);
+
+again:
 	spin_lock_irqsave(&q->lock, flags);
-	__wake_up_locked_key(q, TASK_NORMAL, &key);
+	__wake_up_locked_key_bookmark(q, TASK_NORMAL, &key, &bookmark);
+	if (bookmark.flags & WQ_FLAG_BOOKMARK) {
+		spin_unlock_irqrestore(&q->lock, flags);
+		goto again;
+	}
+finish:
 	/*
 	 * It is possible for other pages to have collided on the waitqueue
 	 * hash, so in that case check for a page match. That prevents a long-
@@ -936,7 +964,8 @@ static void wake_up_page_bit(struct page *page, int bit_nr)
 	 * and removed them from the waitqueue, but there are still other
 	 * page waiters.
 	 */
-	if (!waitqueue_active(q) || !key.page_match) {
+	if (!waitqueue_active(q) ||
+	    (!key.page_match && (q->waker == 1) && !(q->flags & WQ_FLAG_ARRIVALS))) {
 		ClearPageWaiters(page);
 		/*
 		 * It's possible to miss clearing Waiters here, when we woke
@@ -946,6 +975,7 @@ static void wake_up_page_bit(struct page *page, int bit_nr)
 		 * That's okay, it's a rare case. The next waker will clear it.
 		 */
 	}
+	-- q->waker;
 	spin_unlock_irqrestore(&q->lock, flags);
 }
 
@@ -976,6 +1006,7 @@ static inline int wait_on_page_bit_common(wait_queue_head_t *q,
 				__add_wait_queue_entry_tail_exclusive(q, wait);
 			else
 				__add_wait_queue(q, wait);
+			q->flags = WQ_FLAG_ARRIVALS;
 			SetPageWaiters(page);
 		}
 
@@ -1041,6 +1072,7 @@ void add_page_wait_queue(struct page *page, wait_queue_entry_t *waiter)
 	spin_lock_irqsave(&q->lock, flags);
 	__add_wait_queue(q, waiter);
 	SetPageWaiters(page);
+	q->flags = WQ_FLAG_ARRIVALS;
 	spin_unlock_irqrestore(&q->lock, flags);
 }
 EXPORT_SYMBOL_GPL(add_page_wait_queue);
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
