Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 92A1F6B0096
	for <linux-mm@kvack.org>; Sat, 17 Jan 2009 11:30:46 -0500 (EST)
Date: Sat, 17 Jan 2009 17:32:36 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] Avoid lost wakeups in lock_page_killable()
Message-ID: <20090117163236.GA2660@cmpxchg.org>
References: <1232116107.21473.14.camel@think.oraclecorp.com> <20090117124821.GA1859@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090117124821.GA1859@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matthew Wilcox <matthew@wil.cx>, "chuck.lever" <chuck.lever@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Jan 17, 2009 at 01:48:21PM +0100, Johannes Weiner wrote:
> On Fri, Jan 16, 2009 at 09:28:27AM -0500, Chris Mason wrote:
> > 
> > lock_page and lock_page_killable both call __wait_on_bit_lock, and
> > both end up using prepare_to_wait_exclusive().  This means that when
> > someone does finally unlock the page, only one process is going to get
> > woken up.
> > 
> > But lock_page_killable can exit without taking the lock.  If nobody
> > else comes in and locks the page, any other waiters will wait forever.
> > 
> > For example, procA holding the page lock, procB and procC are waiting on
> > the lock.
> > 
> > procA: lock_page() // success
> > procB: lock_page_killable(), sync_page_killable(), io_schedule()
> > procC: lock_page_killable(), sync_page_killable(), io_schedule()
> > 
> > procA: unlock, wake_up_page(page, PG_locked)
> > procA: wake up procB
> > 
> > happy admin: kill procB
> > 
> > procB: wakes into sync_page_killable(), notices the signal and returns
> > -EINTR
> > 
> > procB: __wait_on_bit_lock sees the action() func returns < 0 and does
> > not take the page lock
> > 
> > procB: lock_page_killable() returns < 0 and exits happily.
> > 
> > procC: sleeping in io_schedule() forever unless someone else locks the
> > page.
> > 
> > This was seen in production on systems where the database was shutting
> > down.  Testing shows the patch fixes things.
> > 
> > Chuck Lever did all the hard work here, with a page lock debugging
> > patch that proved we were missing a wakeup.  
> > 
> > Every version of lock_page_killable() should need this.
> > 
> > Signed-off-by: Chris Mason <chris.mason@oracle.com>
> > 
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index ceba0bd..e1184fa 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -623,9 +623,20 @@ EXPORT_SYMBOL(__lock_page);
> >  int __lock_page_killable(struct page *page)
> >  {
> >  	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
> > +	int ret;
> >  
> > -	return __wait_on_bit_lock(page_waitqueue(page), &wait,
> > +	ret = __wait_on_bit_lock(page_waitqueue(page), &wait,
> >  					sync_page_killable, TASK_KILLABLE);
> > +	/*
> > +	 * wait_on_bit_lock uses prepare_to_wait_exclusive, so if multiple
> > +	 * procs were waiting on this page, we were the only proc woken up.
> > +	 *
> > +	 * if ret != 0, we didn't actually get the lock.  We need to
> > +	 * make sure any other waiters don't sleep forever.
> > +	 */
> > +	if (ret)
> > +		wake_up_page(page, PG_locked);
> > +	return ret;
> >  }
> 
> Hmm, I wonder whether this is the right place to fix it up.  We
> inherit the problem from the wait layer as the exclusive waiting is
> hidden in __wait_on_bit_lock().  Would it make more sense to fix it up
> right there?
> 
> 	Hannes
> 
> diff --git a/kernel/wait.c b/kernel/wait.c
> index cd87131..77217e9 100644
> --- a/kernel/wait.c
> +++ b/kernel/wait.c
> @@ -194,10 +194,14 @@ EXPORT_SYMBOL(__wait_on_bit_lock);
>  int __sched out_of_line_wait_on_bit_lock(void *word, int bit,
>  					int (*action)(void *), unsigned mode)
>  {
> +	int ret;
>  	wait_queue_head_t *wq = bit_waitqueue(word, bit);
>  	DEFINE_WAIT_BIT(wait, word, bit);
>  
> -	return __wait_on_bit_lock(wq, &wait, action, mode);
> +	ret = __wait_on_bit_lock(wq, &wait, action, mode);
> +	if (ret)
> +		__wake_up_bit(wq, word, bit);
> +	return ret;
>  }
>  EXPORT_SYMBOL(out_of_line_wait_on_bit_lock);

This was of course the wrong place.  Sorry.  Next try.

Peter, this also fixes the spurious wake up as __wake_up_bit() checks
if there are waiters on the queue up front.

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

Fix it in __wait_on_bit_lock() by waking up the next contender when
acquisition fails, because the above layer won't do the unlock if the
lock isn't taken successfully.

Reported-by: Chris Mason <chris.mason@oracle.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 kernel/wait.c |    7 +++++++
 1 file changed, 7 insertions(+)

--- a/kernel/wait.c
+++ b/kernel/wait.c
@@ -187,6 +187,13 @@ __wait_on_bit_lock(wait_queue_head_t *wq
 		}
 	} while (test_and_set_bit(q->key.bit_nr, q->key.flags));
 	finish_wait(wq, &q->wait);
+	/*
+	 * Contenders are woken exclusively.  If we fail acquisition
+	 * here, make sure the next waiter on the line is woken and
+	 * gets to take the lock instead.
+	 */
+	if (ret)
+		__wake_up_bit(wq, q->key.flags, q->key.bit_nr);
 	return ret;
 }
 EXPORT_SYMBOL(__wait_on_bit_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
