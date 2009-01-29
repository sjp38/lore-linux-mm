Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7CD3C6B0044
	for <linux-mm@kvack.org>; Thu, 29 Jan 2009 02:38:16 -0500 (EST)
Date: Wed, 28 Jan 2009 23:37:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v7] wait: prevent exclusive waiter starvation
Message-Id: <20090128233734.81d8004a.akpm@linux-foundation.org>
In-Reply-To: <20090129044227.GA5231@redhat.com>
References: <20090121213813.GB23270@cmpxchg.org>
	<20090122202550.GA5726@redhat.com>
	<20090123095904.GA22890@cmpxchg.org>
	<20090123113541.GB12684@redhat.com>
	<20090123133050.GA19226@redhat.com>
	<20090126215957.GA3889@cmpxchg.org>
	<20090127032359.GA17359@redhat.com>
	<20090127193434.GA19673@cmpxchg.org>
	<20090127200544.GA28843@redhat.com>
	<20090128091453.GA22036@cmpxchg.org>
	<20090129044227.GA5231@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matthew Wilcox <matthew@wil.cx>, Chuck Lever <cel@citi.umich.edu>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 29 Jan 2009 05:42:27 +0100 Oleg Nesterov <oleg@redhat.com> wrote:

> On 01/28, Johannes Weiner wrote:
> >
> > Add abort_exclusive_wait() which removes the process' wait descriptor
> > from the waitqueue, iff still queued, or wakes up the next waiter
> > otherwise.  It does so under the waitqueue lock.  Racing with a wake
> > up means the aborting process is either already woken (removed from
> > the queue) and will wake up the next waiter, or it will remove itself
> > from the queue and the concurrent wake up will apply to the next
> > waiter after it.
> >
> > Use abort_exclusive_wait() in __wait_event_interruptible_exclusive()
> > and __wait_on_bit_lock() when they were interrupted by other means
> > than a wake up through the queue.
> 
> Imho, this all is right, and this patch should replace
> lock_page_killable-avoid-lost-wakeups.patch (except for stable tree).

I dropped lock_page_killable-avoid-lost-wakeups.patch a while ago.

So I think we're saying that
lock_page_killable-avoid-lost-wakeups.patch actually did fix the bug?

And that "[RFC v7] wait: prevent exclusive waiter starvation" fixes it
as well, and in a preferable manner, but not a manner which we consider
suitable for -stable?  (why?)

And hence that lock_page_killable-avoid-lost-wakeups.patch is the
appropriate fix for -stable?

If so, that's a bit unusual, and the -stable maintainers may choose to
take the patch which we're putting into 2.6.29.

Here, for the record (and for stable@kernel.org), is
lock_page_killable-avoid-lost-wakeups.patch:


From: Chris Mason <chris.mason@oracle.com>

lock_page and lock_page_killable both call __wait_on_bit_lock, and both
end up using prepare_to_wait_exclusive().  This means that when someone
does finally unlock the page, only one process is going to get woken up.

But lock_page_killable can exit without taking the lock.  If nobody else
comes in and locks the page, any other waiters will wait forever.

For example, procA holding the page lock, procB and procC are waiting on
the lock.

procA: lock_page() // success
procB: lock_page_killable(), sync_page_killable(), io_schedule()
procC: lock_page_killable(), sync_page_killable(), io_schedule()

procA: unlock, wake_up_page(page, PG_locked)
procA: wake up procB

happy admin: kill procB

procB: wakes into sync_page_killable(), notices the signal and returns
-EINTR

procB: __wait_on_bit_lock sees the action() func returns < 0 and does
not take the page lock

procB: lock_page_killable() returns < 0 and exits happily.

procC: sleeping in io_schedule() forever unless someone else locks the
page.

This was seen in production on systems where the database was shutting
down.  Testing shows the patch fixes things.

Chuck Lever did all the hard work here, with a page lock debugging
patch that proved we were missing a wakeup.

Every version of lock_page_killable() should need this.

Signed-off-by: Chris Mason <chris.mason@oracle.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Matthew Wilcox <matthew@wil.cx>
Cc: Chuck Lever <cel@citi.umich.edu>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: <stable@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/filemap.c |   13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff -puN mm/filemap.c~lock_page_killable-avoid-lost-wakeups mm/filemap.c
--- a/mm/filemap.c~lock_page_killable-avoid-lost-wakeups
+++ a/mm/filemap.c
@@ -623,9 +623,20 @@ EXPORT_SYMBOL(__lock_page);
 int __lock_page_killable(struct page *page)
 {
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
+	int ret;
 
-	return __wait_on_bit_lock(page_waitqueue(page), &wait,
+	ret = __wait_on_bit_lock(page_waitqueue(page), &wait,
 					sync_page_killable, TASK_KILLABLE);
+	/*
+	 * wait_on_bit_lock uses prepare_to_wait_exclusive, so if multiple
+	 * procs were waiting on this page, we were the only proc woken up.
+	 *
+	 * if ret != 0, we didn't actually get the lock.  We need to
+	 * make sure any other waiters don't sleep forever.
+	 */
+	if (ret)
+		wake_up_page(page, PG_locked);
+	return ret;
 }
 
 /**
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
