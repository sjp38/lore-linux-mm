Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BFBAA6B0047
	for <linux-mm@kvack.org>; Tue, 27 Jan 2009 14:36:36 -0500 (EST)
Date: Tue, 27 Jan 2009 20:34:34 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [RFC v6] wait: prevent exclusive waiter starvation
Message-ID: <20090127193434.GA19673@cmpxchg.org>
References: <20090118023211.GA14539@redhat.com> <20090120203131.GA20985@cmpxchg.org> <20090121143602.GA16584@redhat.com> <20090121213813.GB23270@cmpxchg.org> <20090122202550.GA5726@redhat.com> <20090123095904.GA22890@cmpxchg.org> <20090123113541.GB12684@redhat.com> <20090123133050.GA19226@redhat.com> <20090126215957.GA3889@cmpxchg.org> <20090127032359.GA17359@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090127032359.GA17359@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matthew Wilcox <matthew@wil.cx>, Chuck Lever <cel@citi.umich.edu>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 27, 2009 at 04:23:59AM +0100, Oleg Nesterov wrote:
> On 01/26, Johannes Weiner wrote:
> >
> > Another iteration.  I didn't use a general finish_wait_exclusive() but
> > a version of this function that just returns whether we were woken
> > through the queue or not.
> 
> But if your helper (finish_wait_woken) returns true, we always need
> to wakeup the next waiter, or we don't need to use it. So why not
> place the wakeup in the helper itself?

Good point.

> > --- a/include/linux/wait.h
> > +++ b/include/linux/wait.h
> > @@ -333,16 +333,20 @@ do {									\
> >  	for (;;) {							\
> >  		prepare_to_wait_exclusive(&wq, &__wait,			\
> >  					TASK_INTERRUPTIBLE);		\
> > -		if (condition)						\
> > +		if (condition) {					\
> > +			finish_wait(&wq, &__wait);			\
> >  			break;						\
> > +		}							\
> >  		if (!signal_pending(current)) {				\
> >  			schedule();					\
> >  			continue;					\
> >  		}							\
> >  		ret = -ERESTARTSYS;					\
> > +		if (finish_wait_woken(&wq, &__wait))			\
> > +			__wake_up_common(&wq, TASK_INTERRUPTIBLE,	\
> 
> No, we can't use __wake_up_common() without wq->lock.

Whoops.  Should have noticed that, sorry.

Okay, number six.  I renamed the helper to abort_exclusive_wait().
It does the wake up with __wake_up_locked() under the waitqueue lock.

I also hope that the changelog is now, unlike the previous one,
intelligible.

	Hannes

---
With exclusive waiters, every process woken up through the wait queue
must ensure that the next waiter down the line is woken when it has
finished.

Interruptible waiters don't do that when aborting due to a signal.
And if an aborting waiter is concurrently woken up through the
waitqueue, noone will ever wake up the next waiter.

This has been observed with __wait_on_bit_lock() used by
lock_page_killable(): the first contender on the queue was aborting
when the actual lock holder woke it up concurrently.  The aborted
contender didn't acquire the lock and therefor never did an unlock
followed by waking up the next waiter.

Add abort_exclusive_wait() which removes the process' wait descriptor
from the waitqueue, iff still queued, or wakes up the next waiter
otherwise.  It does so under the waitqueue lock.  Racing with a wake
up means the aborting process is either already woken (removed from
the queue) and will wake up the next waiter, or it will remove itself
from the queue and the concurrent wake up will apply to the next
waiter after it.

Use abort_exclusive_wait() in __wait_event_interruptible_exclusive()
and __wait_on_bit_lock() when they were interrupted by other means
than a wake up through the queue.

Reported-by: Chris Mason <chris.mason@oracle.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Mentored-by: Oleg Nesterov <oleg@redhat.com>
---
 include/linux/wait.h |    7 ++++-
 kernel/wait.c        |   57 +++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 55 insertions(+), 9 deletions(-)

diff --git a/include/linux/wait.h b/include/linux/wait.h
index ef609f8..57bfced 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -333,16 +333,18 @@ do {									\
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
+		abort_exclusive_wait(&wq, &__wait);			\
 		break;							\
 	}								\
-	finish_wait(&wq, &__wait);					\
 } while (0)
 
 #define wait_event_interruptible_exclusive(wq, condition)		\
@@ -431,6 +433,7 @@ extern long interruptible_sleep_on_timeout(wait_queue_head_t *q,
 void prepare_to_wait(wait_queue_head_t *q, wait_queue_t *wait, int state);
 void prepare_to_wait_exclusive(wait_queue_head_t *q, wait_queue_t *wait, int state);
 void finish_wait(wait_queue_head_t *q, wait_queue_t *wait);
+void abort_exclusive_wait(wait_queue_head_t *q, wait_queue_t *wait);
 int autoremove_wake_function(wait_queue_t *wait, unsigned mode, int sync, void *key);
 int wake_bit_function(wait_queue_t *wait, unsigned mode, int sync, void *key);
 
diff --git a/kernel/wait.c b/kernel/wait.c
index cd87131..21f88c4 100644
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
@@ -117,6 +126,38 @@ void finish_wait(wait_queue_head_t *q, wait_queue_t *wait)
 }
 EXPORT_SYMBOL(finish_wait);
 
+/*
+ * abort_exclusive_wait - abort exclusive waiting in a queue
+ * @q: waitqueue waited on
+ * @wait: wait descriptor
+ *
+ * Sets current thread back to running state and removes
+ * the wait descriptor from the given waitqueue if still
+ * queued.
+ *
+ * Wakes up the next waiter if the caller is concurrently
+ * woken up through the queue.
+ */
+void abort_exclusive_wait(wait_queue_head_t *q, wait_queue_t *wait)
+{
+	unsigned long flags;
+
+	__set_current_state(TASK_RUNNING);
+	spin_lock_irqsave(&q->lock, flags);
+	if (list_empty(&wait->task_list))
+		list_del_init(&wait->task_list);
+	/*
+	 * If we were woken through the waitqueue (waker removed
+	 * us from the list) we must ensure the next waiter down
+	 * the line is woken up.  The callsite will not do it as
+	 * it didn't finish waiting successfully.
+	 */
+	else if (waitqueue_active(q))
+		__wake_up_locked(q, TASK_INTERRUPTIBLE);
+	spin_unlock_irqrestore(&q->lock, flags);
+}
+EXPORT_SYMBOL(finish_wait_woken);
+
 int autoremove_wake_function(wait_queue_t *wait, unsigned mode, int sync, void *key)
 {
 	int ret = default_wake_function(wait, mode, sync, key);
@@ -177,17 +218,19 @@ int __sched
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
+		abort_exclusive_wait(wq, &q->wait);
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
