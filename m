Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id ED9116B0044
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 17:01:57 -0500 (EST)
Date: Mon, 26 Jan 2009 22:59:57 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [RFC v5] wait: prevent exclusive waiter starvation
Message-ID: <20090126215957.GA3889@cmpxchg.org>
References: <20090117215110.GA3300@redhat.com> <20090118013802.GA12214@cmpxchg.org> <20090118023211.GA14539@redhat.com> <20090120203131.GA20985@cmpxchg.org> <20090121143602.GA16584@redhat.com> <20090121213813.GB23270@cmpxchg.org> <20090122202550.GA5726@redhat.com> <20090123095904.GA22890@cmpxchg.org> <20090123113541.GB12684@redhat.com> <20090123133050.GA19226@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090123133050.GA19226@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matthew Wilcox <matthew@wil.cx>, Chuck Lever <cel@citi.umich.edu>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 23, 2009 at 02:30:50PM +0100, Oleg Nesterov wrote:
> On 01/23, Oleg Nesterov wrote:
> >
> > It is no that I think this new helper is really needed for this
> > particular case, personally I agree with the patch you sent.
> >
> > But if we have other places with the similar problem, then perhaps
> > it is better to introduce the special finish_wait_exclusive() or
> > whatever.
> 
> To clarify, I suggest something like this.
> 
> 	int finish_wait_exclusive(wait_queue_head_t *q, wait_queue_t *wait,
> 					int ret, int state, void *key)
> 	{
> 		unsigned long flags;
> 
> 		__set_current_state(TASK_RUNNING);
> 
> 		if (ret || !list_empty_careful(&wait->task_list)) {
> 			spin_lock_irqsave(&q->lock, flags);
> 			if (list_empty(&wait->task_list))
> 				 __wake_up_common(q, state, 1, key);
> 			else
> 				list_del_init(&wait->task_list);
> 			spin_unlock_irqrestore(&q->lock, flags);
> 		}
> 
> 		return ret;
> 	}
> 
> Now, __wait_on_bit_lock() becomes:
> 
> 	int __sched
> 	__wait_on_bit_lock(wait_queue_head_t *wq, struct wait_bit_queue *q,
> 				int (*action)(void *), unsigned mode)
> 	{
> 		int ret = 0;
> 
> 		do {
> 			prepare_to_wait_exclusive(wq, &q->wait, mode);
> 			if (test_bit(q->key.bit_nr, q->key.flags) &&
> 			   (ret = (*action)(q->key.flags))
> 				break;
> 		} while (test_and_set_bit(q->key.bit_nr, q->key.flags));
> 
> 		return finish_wait_exclusive(wq, &q->wait, ret, mode, &q->key);
> 	}
> 
> And __wait_event_interruptible_exclusive:
> 
> 	#define __wait_event_interruptible_exclusive(wq, condition, ret)	\
> 	do {									\
> 		DEFINE_WAIT(__wait);						\
> 										\
> 		for (;;) {							\
> 			prepare_to_wait_exclusive(&wq, &__wait,			\
> 						TASK_INTERRUPTIBLE);		\
> 			if (condition)						\
> 				break;						\
> 			if (!signal_pending(current)) {				\
> 				schedule();					\
> 				continue;					\
> 			}							\
> 			ret = -ERESTARTSYS;					\
> 			break;							\
> 		}								\
> 		finish_wait_exclusive(&wq, &__wait,				\
> 					ret, TASK_INTERRUPTIBLE, NULL);		\
> 	} while (0)
> 
> But I can't convince myself this is what we really want. So I am not
> sending the patch. And yes, we have to check ret twice.

Another iteration.  I didn't use a general finish_wait_exclusive() but
a version of this function that just returns whether we were woken
through the queue or not.  The result is stable due to the waitqueue
lock.  The callsites use it only if interrupted and the normal
finish_wait() otherwise.

	Hannes

---
With exclusive waiters, every process woken up through the wait queue
must ensure that the next waiter down the line is woken when it has
finished.

However, if the waiting processes sleep interruptibly, they might
abort waiting prematurely.  And if this in turn races with an ongoing
wake up, the woken up process might be the one currently aborting the
wait and the next real contender is never woken up, doomed to stay on
the queue forever.

This has been observed with __wait_on_bit_lock() used by
lock_page_killable().  If the contender was killed and woken up at the
same time, the next contender would never be woken up: the previous
lock holder would wake the interrupted contender and the interrupted
contender would never do unlock_page() -> __wake_up_bit() because it
never took the lock in the first place.

To fix this, it must be ensured that when the interrupted task tries
to remove itself from the waitqueue (finish_wait) it has to check for
whether it was woken up through the queue, and if so, wake up the next
contender.

Add finish_wait_woken() which does the same as finish_wait() but also
returns whether the wait descriptor was already removed from the
queue.  Serialized by the waitqueue spinlock, this is safe indicator
for whether we have to wake up the next contender or the previously
running task will do it.

Then use this function for __wait_event_interruptible_exclusive() and
__wait_on_bit_lock() to wake up the next contender if needed.

Reported-by: Chris Mason <chris.mason@oracle.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/wait.h |    9 ++++++-
 kernel/wait.c        |   58 +++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 58 insertions(+), 9 deletions(-)

diff --git a/include/linux/wait.h b/include/linux/wait.h
index ef609f8..56c9402 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -333,16 +333,20 @@ do {									\
 	for (;;) {							\
 		prepare_to_wait_exclusive(&wq, &__wait,			\
 					TASK_INTERRUPTIBLE);		\
-		if (condition)						\
+		if (condition) {					\
+			finish_wait(&wq, &__wait);			\
 			break;						\
+		}							\
 		if (!signal_pending(current)) {				\
 			schedule();					\
 			continue;					\
 		}							\
 		ret = -ERESTARTSYS;					\
+		if (finish_wait_woken(&wq, &__wait))			\
+			__wake_up_common(&wq, TASK_INTERRUPTIBLE,	\
+							1, NULL);	\
 		break;							\
 	}								\
-	finish_wait(&wq, &__wait);					\
 } while (0)
 
 #define wait_event_interruptible_exclusive(wq, condition)		\
@@ -431,6 +435,7 @@ extern long interruptible_sleep_on_timeout(wait_queue_head_t *q,
 void prepare_to_wait(wait_queue_head_t *q, wait_queue_t *wait, int state);
 void prepare_to_wait_exclusive(wait_queue_head_t *q, wait_queue_t *wait, int state);
 void finish_wait(wait_queue_head_t *q, wait_queue_t *wait);
+int finish_wait_woken(wait_queue_head_t *q, wait_queue_t *wait);
 int autoremove_wake_function(wait_queue_t *wait, unsigned mode, int sync, void *key);
 int wake_bit_function(wait_queue_t *wait, unsigned mode, int sync, void *key);
 
diff --git a/kernel/wait.c b/kernel/wait.c
index cd87131..7fc0d57 100644
--- a/kernel/wait.c
+++ b/kernel/wait.c
@@ -91,6 +91,15 @@ prepare_to_wait_exclusive(wait_queue_head_t *q, wait_queue_t *wait, int state)
 }
 EXPORT_SYMBOL(prepare_to_wait_exclusive);
 
+/*
+ * finish_wait - clean up after waiting in a queue
+ * @q: waitqueue waited on
+ * @wait: wait descriptor
+ *
+ * Sets current thread back to running state and removes
+ * the wait descriptor from the given waitqueue if still
+ * queued.
+ */
 void finish_wait(wait_queue_head_t *q, wait_queue_t *wait)
 {
 	unsigned long flags;
@@ -117,6 +126,32 @@ void finish_wait(wait_queue_head_t *q, wait_queue_t *wait)
 }
 EXPORT_SYMBOL(finish_wait);
 
+/*
+ * finish_wait_woken - clean up after waiting in a queue
+ * @q: waitqueue waited on
+ * @wait: wait descriptor
+ *
+ * Sets current thread back to running state and removes
+ * the wait descriptor from the given waitqueue if still
+ * queued.
+ *
+ * Returns 1 if the waiting task was woken up through the
+ * wait descriptor in the queue, 0 otherwise.
+ */
+int finish_wait_woken(wait_queue_head_t *q, wait_queue_t *wait)
+{
+	int woken;
+	unsigned long flags;
+
+	__set_current_state(TASK_RUNNING);
+	spin_lock_irqsave(&q->lock, flags);
+	if (!(woken = list_empty(&wait->task_list)))
+		list_del_init(&wait->task_list);
+	spin_unlock_irqrestore(&q->lock, flags);
+	return woken;
+}
+EXPORT_SYMBOL(finish_wait_woken);
+
 int autoremove_wake_function(wait_queue_t *wait, unsigned mode, int sync, void *key)
 {
 	int ret = default_wake_function(wait, mode, sync, key);
@@ -177,17 +212,26 @@ int __sched
 __wait_on_bit_lock(wait_queue_head_t *wq, struct wait_bit_queue *q,
 			int (*action)(void *), unsigned mode)
 {
-	int ret = 0;
-
 	do {
+		int ret;
+
 		prepare_to_wait_exclusive(wq, &q->wait, mode);
-		if (test_bit(q->key.bit_nr, q->key.flags)) {
-			if ((ret = (*action)(q->key.flags)))
-				break;
-		}
+		if (!test_bit(q->key.bit_nr, q->key.flags))
+			continue;
+		if (!(ret = action(q->key.flags)))
+			continue;
+		/*
+		 * Exclusive waiting requires the woken up process
+		 * to ensure the next wake up.  The lock acquisition
+		 * failed here, no unlock is expected.  Make sure the
+		 * next process does not wait forever on the queue.
+		 */
+		if (finish_wait_woken(wq, &q->wait))
+			__wake_up_bit(wq, q->key.flags, q->key.bit_nr);
+		return ret;
 	} while (test_and_set_bit(q->key.bit_nr, q->key.flags));
 	finish_wait(wq, &q->wait);
-	return ret;
+	return 0;
 }
 EXPORT_SYMBOL(__wait_on_bit_lock);
 
-- 
1.6.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
