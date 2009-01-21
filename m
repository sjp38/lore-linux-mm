Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 429646B0044
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 16:39:20 -0500 (EST)
Date: Wed, 21 Jan 2009 22:38:13 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [RFC v4] wait: prevent waiter starvation in __wait_on_bit_lock
Message-ID: <20090121213813.GB23270@cmpxchg.org>
References: <20090117215110.GA3300@redhat.com> <20090118013802.GA12214@cmpxchg.org> <20090118023211.GA14539@redhat.com> <20090120203131.GA20985@cmpxchg.org> <20090121143602.GA16584@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090121143602.GA16584@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matthew Wilcox <matthew@wil.cx>, Chuck Lever <cel@citi.umich.edu>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 21, 2009 at 03:36:02PM +0100, Oleg Nesterov wrote:
> On 01/20, Johannes Weiner wrote:
> >
> > > But, more importantly, I'm afraid we can also have the false negative,
> > > this "if (!test_bit())" test lacks the barriers. This can't happen with
> > > sync_page_killable() because it always calls schedule(). But let's
> > > suppose we modify it to check signal_pending() first:
> > >
> > > 	static int sync_page_killable(void *word)
> > > 	{
> > > 		if (fatal_signal_pending(current))
> > > 			return -EINTR;
> > > 		return sync_page(word);
> > > 	}
> > >
> > > It is still correct, but unless I missed something now __wait_on_bit_lock()
> > > has problems again.
> >
> > Hm, this would require the lock bit to be set without someone else
> > doing the wakeup.  How could this happen?
> >
> > I could think of wake_up_page() happening BEFORE clear_bit_unlock()
> > and we have to be on the front of the waitqueue.  Then we are already
> > running, the wake up is a nop, the !test_bit() is false and noone
> > wakes up the next real contender.
> >
> > But the wake up side uses a smp barrier after clearing the bit, so if
> > the bit is not cleared we can expect a wake up, no?
> 
> Yes we have the barriers on the "wakeup", but this doesn't mean the
> woken task must see the result of clear_bit() (unless it was really
> unscheduled of course).
> 
> > Or do we still need a read-side barrier before the test bit?
> 
> Even this can't help afaics.
> 
> Because the the whole clear_bit + wakeup sequence can happen after
> the "if (!test_bit()) check and before finish_wait(). Please note
> that from the waker's pov we are sleeping in TASK_KILLABLE state,
> it will wake up us if we are at the front of the waitqueue.

Yes, you are right.  Thanks for the explanation!

I redid the patch and I *think* it is safe now and the race window for
a false wake up is pretty small.  But we check @ret twice... Oh well.

If the wake up happens now before the test_bit(), the added reader
barrier ensures we see the bit clear and do the wake up as needed.  If
it happens afterwards, we are definitely off the queue (finish_wait()
has removed us and it also comes with a barrier in form of a spin
lock/unlock).

And only in the second scenario there is a small chance of a bogus
wake up, when the next contender hasn't set the bit again yet.

Does this all make sense? :)

---
__wait_on_bit_lock() employs exclusive waiters, which means that every
contender has to make sure to wake up the next one in the queue after
releasing the lock.

The current implementation does not do this for failed acquisitions.
If the passed in action() returns a non-zero value, the lock is not
taken but the next waiter is not woken up either, leading to endless
waiting on an unlocked lock.

This failure mode was observed with lock_page_killable() as a user
which passes an action function that can fail and thereby prevent lock
acquisition.

Fix it in __wait_on_bit_lock() by passing on to the next contender
when we were woken by an unlock but won't take the lock ourselves.

Reported-by: Chris Mason <chris.mason@oracle.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/kernel/wait.c b/kernel/wait.c
index cd87131..e3aaa81 100644
--- a/kernel/wait.c
+++ b/kernel/wait.c
@@ -187,6 +187,31 @@ __wait_on_bit_lock(wait_queue_head_t *wq, struct wait_bit_queue *q,
 		}
 	} while (test_and_set_bit(q->key.bit_nr, q->key.flags));
 	finish_wait(wq, &q->wait);
+	if (unlikely(ret)) {
+		/*
+		 * Contenders are woken exclusively.  If we were woken
+		 * by an unlock we have to take the lock ourselves and
+		 * wake the next contender on unlock.  But the waiting
+		 * function failed, we do not take the lock and won't
+		 * unlock in the future.  Make sure the next contender
+		 * does not wait forever on an unlocked bit.
+		 *
+		 * We can also get here without being woken through
+		 * the waitqueue, so there is a small chance of doing a
+		 * bogus wake up between an unlock clearing the bit and
+		 * the next contender being woken up and setting it again.
+		 *
+		 * It does no harm, though, the scheduler will ignore it
+		 * as the process in question is already running.
+		 *
+		 * The unlock path clears the bit and then wakes up the
+		 * next contender.  If the next contender is us, the
+		 * barrier makes sure we also see the bit cleared.
+		 */
+		smp_rmb();
+		if (!test_bit(q->key.bit_nr, q->key.flags)))
+			__wake_up_bit(wq, q->key.flags, q->key.bit_nr);
+	}
 	return ret;
 }
 EXPORT_SYMBOL(__wait_on_bit_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
