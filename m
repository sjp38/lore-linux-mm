Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 71F106B0044
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 09:40:52 -0500 (EST)
Date: Wed, 21 Jan 2009 15:36:02 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v3] wait: prevent waiter starvation in
	__wait_on_bit_lock
Message-ID: <20090121143602.GA16584@redhat.com>
References: <20090117215110.GA3300@redhat.com> <20090118013802.GA12214@cmpxchg.org> <20090118023211.GA14539@redhat.com> <20090120203131.GA20985@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090120203131.GA20985@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matthew Wilcox <matthew@wil.cx>, Chuck Lever <cel@citi.umich.edu>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 01/20, Johannes Weiner wrote:
>
> > But, more importantly, I'm afraid we can also have the false negative,
> > this "if (!test_bit())" test lacks the barriers. This can't happen with
> > sync_page_killable() because it always calls schedule(). But let's
> > suppose we modify it to check signal_pending() first:
> >
> > 	static int sync_page_killable(void *word)
> > 	{
> > 		if (fatal_signal_pending(current))
> > 			return -EINTR;
> > 		return sync_page(word);
> > 	}
> >
> > It is still correct, but unless I missed something now __wait_on_bit_lock()
> > has problems again.
>
> Hm, this would require the lock bit to be set without someone else
> doing the wakeup.  How could this happen?
>
> I could think of wake_up_page() happening BEFORE clear_bit_unlock()
> and we have to be on the front of the waitqueue.  Then we are already
> running, the wake up is a nop, the !test_bit() is false and noone
> wakes up the next real contender.
>
> But the wake up side uses a smp barrier after clearing the bit, so if
> the bit is not cleared we can expect a wake up, no?

Yes we have the barriers on the "wakeup", but this doesn't mean the
woken task must see the result of clear_bit() (unless it was really
unscheduled of course).

> Or do we still need a read-side barrier before the test bit?

Even this can't help afaics.

Because the the whole clear_bit + wakeup sequence can happen after
the "if (!test_bit()) check and before finish_wait(). Please note
that from the waker's pov we are sleeping in TASK_KILLABLE state,
it will wake up us if we are at the front of the waitqueue.

(to clarify, I am talking about the imaginary sync_page_killable()
 above).

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
