Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1FD666B0047
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 03:29:04 -0500 (EST)
Subject: Re: [PATCH 4/8] Use prepare_to_wait_exclusive() instead
 prepare_to_wait()
From: Mike Galbraith <efault@gmx.de>
In-Reply-To: <1260855146.6126.30.camel@marge.simson.net>
References: <20091214212936.BBBA.A69D9226@jp.fujitsu.com>
	 <4B264CCA.5010609@redhat.com> <20091215085631.CDAD.A69D9226@jp.fujitsu.com>
	 <1260855146.6126.30.camel@marge.simson.net>
Content-Type: text/plain
Date: Tue, 15 Dec 2009 09:28:59 +0100
Message-Id: <1260865739.30062.16.camel@marge.simson.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, 2009-12-15 at 06:32 +0100, Mike Galbraith wrote:
> On Tue, 2009-12-15 at 09:45 +0900, KOSAKI Motohiro wrote:
> > > On 12/14/2009 07:30 AM, KOSAKI Motohiro wrote:
> > > > if we don't use exclusive queue, wake_up() function wake _all_ waited
> > > > task. This is simply cpu wasting.
> > > >
> > > > Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> > > 
> > > >   		if (zone_watermark_ok(zone, sc->order, low_wmark_pages(zone),
> > > >   					0, 0)) {
> > > > -			wake_up(wq);
> > > > +			wake_up_all(wq);
> > > >   			finish_wait(wq,&wait);
> > > >   			sc->nr_reclaimed += sc->nr_to_reclaim;
> > > >   			return -ERESTARTSYS;
> > > 
> > > I believe we want to wake the processes up one at a time
> > > here.  If the queue of waiting processes is very large
> > > and the amount of excess free memory is fairly low, the
> > > first processes that wake up can take the amount of free
> > > memory back down below the threshold.  The rest of the
> > > waiters should stay asleep when this happens.
> > 
> > OK.
> > 
> > Actually, wake_up() and wake_up_all() aren't different so much.
> > Although we use wake_up(), the task wake up next task before
> > try to alloate memory. then, it's similar to wake_up_all().
> 
> What happens to waiters should running tasks not allocate for a while?
> 
> > However, there are few difference. recent scheduler latency improvement
> > effort reduce default scheduler latency target. it mean, if we have
> > lots tasks of running state, the task have very few time slice. too
> > frequently context switch decrease VM efficiency.
> > Thank you, Rik. I didn't notice wake_up() makes better performance than
> > wake_up_all() on current kernel.
> 
> Perhaps this is a spot where an explicit wake_up_all_nopreempt() would
> be handy....

Maybe something like below.  I can also imagine that under _heavy_ vm
pressure, it'd likely be good for throughput to not provide for sleeper
fairness for these wakeups as well, as that increases vruntime spread,
and thus increases preemption with no benefit in sight.

---
 include/linux/sched.h |    1 +
 include/linux/wait.h  |    3 +++
 kernel/sched.c        |   21 +++++++++++++++++++++
 kernel/sched_fair.c   |    2 +-
 4 files changed, 26 insertions(+), 1 deletion(-)

Index: linux-2.6/include/linux/sched.h
===================================================================
--- linux-2.6.orig/include/linux/sched.h
+++ linux-2.6/include/linux/sched.h
@@ -1065,6 +1065,7 @@ struct sched_domain;
  */
 #define WF_SYNC		0x01		/* waker goes to sleep after wakup */
 #define WF_FORK		0x02		/* child wakeup after fork */
+#define WF_NOPREEMPT	0x04		/* wakeup is not preemptive */
 
 struct sched_class {
 	const struct sched_class *next;
Index: linux-2.6/include/linux/wait.h
===================================================================
--- linux-2.6.orig/include/linux/wait.h
+++ linux-2.6/include/linux/wait.h
@@ -140,6 +140,7 @@ static inline void __remove_wait_queue(w
 }
 
 void __wake_up(wait_queue_head_t *q, unsigned int mode, int nr, void *key);
+void __wake_up_nopreempt(wait_queue_head_t *q, unsigned int mode, int nr, void *key);
 void __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, void *key);
 void __wake_up_sync_key(wait_queue_head_t *q, unsigned int mode, int nr,
 			void *key);
@@ -154,8 +155,10 @@ int out_of_line_wait_on_bit_lock(void *,
 wait_queue_head_t *bit_waitqueue(void *, int);
 
 #define wake_up(x)			__wake_up(x, TASK_NORMAL, 1, NULL)
+#define wake_up_nopreempt(x)		__wake_up_nopreempt(x, TASK_NORMAL, 1, NULL)
 #define wake_up_nr(x, nr)		__wake_up(x, TASK_NORMAL, nr, NULL)
 #define wake_up_all(x)			__wake_up(x, TASK_NORMAL, 0, NULL)
+#define wake_up_all_nopreempt(x)	__wake_up_nopreempt(x, TASK_NORMAL, 0, NULL)
 #define wake_up_locked(x)		__wake_up_locked((x), TASK_NORMAL)
 
 #define wake_up_interruptible(x)	__wake_up(x, TASK_INTERRUPTIBLE, 1, NULL)
Index: linux-2.6/kernel/sched.c
===================================================================
--- linux-2.6.orig/kernel/sched.c
+++ linux-2.6/kernel/sched.c
@@ -5682,6 +5682,27 @@ void __wake_up(wait_queue_head_t *q, uns
 }
 EXPORT_SYMBOL(__wake_up);
 
+/**
+ * __wake_up_nopreempt - wake up threads blocked on a waitqueue.
+ * @q: the waitqueue
+ * @mode: which threads
+ * @nr_exclusive: how many wake-one or wake-many threads to wake up
+ * @key: is directly passed to the wakeup function
+ *
+ * It may be assumed that this function implies a write memory barrier before
+ * changing the task state if and only if any tasks are woken up.
+ */
+void __wake_up_nopreempt(wait_queue_head_t *q, unsigned int mode,
+			int nr_exclusive, void *key)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&q->lock, flags);
+	__wake_up_common(q, mode, nr_exclusive, WF_NOPREEMPT, key);
+	spin_unlock_irqrestore(&q->lock, flags);
+}
+EXPORT_SYMBOL(__wake_up_nopreempt);
+
 /*
  * Same as __wake_up but called with the spinlock in wait_queue_head_t held.
  */
Index: linux-2.6/kernel/sched_fair.c
===================================================================
--- linux-2.6.orig/kernel/sched_fair.c
+++ linux-2.6/kernel/sched_fair.c
@@ -1709,7 +1709,7 @@ static void check_preempt_wakeup(struct
 			pse->avg_overlap < sysctl_sched_migration_cost)
 		goto preempt;
 
-	if (!sched_feat(WAKEUP_PREEMPT))
+	if (!sched_feat(WAKEUP_PREEMPT) || (wake_flags & WF_NOPREEMPT))
 		return;
 
 	update_curr(cfs_rq);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
