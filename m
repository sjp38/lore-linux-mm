Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 781E16B0044
	for <linux-mm@kvack.org>; Thu, 29 Jan 2009 03:35:48 -0500 (EST)
Date: Thu, 29 Jan 2009 09:31:08 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC v7] wait: prevent exclusive waiter starvation
Message-ID: <20090129083108.GA27495@redhat.com>
References: <20090123095904.GA22890@cmpxchg.org> <20090123113541.GB12684@redhat.com> <20090123133050.GA19226@redhat.com> <20090126215957.GA3889@cmpxchg.org> <20090127032359.GA17359@redhat.com> <20090127193434.GA19673@cmpxchg.org> <20090127200544.GA28843@redhat.com> <20090128091453.GA22036@cmpxchg.org> <20090129044227.GA5231@redhat.com> <20090128233734.81d8004a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090128233734.81d8004a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matthew Wilcox <matthew@wil.cx>, Chuck Lever <cel@citi.umich.edu>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On 01/28, Andrew Morton wrote:
>
> On Thu, 29 Jan 2009 05:42:27 +0100 Oleg Nesterov <oleg@redhat.com> wrote:
>
> > On 01/28, Johannes Weiner wrote:
> > >
> > > Add abort_exclusive_wait() which removes the process' wait descriptor
> > > from the waitqueue, iff still queued, or wakes up the next waiter
> > > otherwise.  It does so under the waitqueue lock.  Racing with a wake
> > > up means the aborting process is either already woken (removed from
> > > the queue) and will wake up the next waiter, or it will remove itself
> > > from the queue and the concurrent wake up will apply to the next
> > > waiter after it.
> > >
> > > Use abort_exclusive_wait() in __wait_event_interruptible_exclusive()
> > > and __wait_on_bit_lock() when they were interrupted by other means
> > > than a wake up through the queue.
> >
> > Imho, this all is right, and this patch should replace
> > lock_page_killable-avoid-lost-wakeups.patch (except for stable tree).
>
> I dropped lock_page_killable-avoid-lost-wakeups.patch a while ago.
>
> So I think we're saying that
> lock_page_killable-avoid-lost-wakeups.patch actually did fix the bug?

I think yes,

> And that "[RFC v7] wait: prevent exclusive waiter starvation" fixes it
> as well, and in a preferable manner, but not a manner which we consider
> suitable for -stable?  (why?)

I meant that lock_page_killable-avoid-lost-wakeups.patch is much simpler,
and thus it looks more "safe" for -stable.

But it is not optimal, and Johannes's patch is also more generic, it fixes
wait_event_interruptible_exclusive() as well.

> And hence that lock_page_killable-avoid-lost-wakeups.patch is the
> appropriate fix for -stable?
>
> If so, that's a bit unusual, and the -stable maintainers may choose to
> take the patch which we're putting into 2.6.29.

Well, I don't know ;)

But Johannes's looks good to me, if you already dropped the old patch,
then I think this one can go into -stable after some testing. Hopefully
maintainers can review it.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
