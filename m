Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D7ED96B0044
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 23:47:07 -0500 (EST)
Date: Thu, 29 Jan 2009 05:42:27 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC v7] wait: prevent exclusive waiter starvation
Message-ID: <20090129044227.GA5231@redhat.com>
References: <20090121213813.GB23270@cmpxchg.org> <20090122202550.GA5726@redhat.com> <20090123095904.GA22890@cmpxchg.org> <20090123113541.GB12684@redhat.com> <20090123133050.GA19226@redhat.com> <20090126215957.GA3889@cmpxchg.org> <20090127032359.GA17359@redhat.com> <20090127193434.GA19673@cmpxchg.org> <20090127200544.GA28843@redhat.com> <20090128091453.GA22036@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090128091453.GA22036@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matthew Wilcox <matthew@wil.cx>, Chuck Lever <cel@citi.umich.edu>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On 01/28, Johannes Weiner wrote:
>
> Add abort_exclusive_wait() which removes the process' wait descriptor
> from the waitqueue, iff still queued, or wakes up the next waiter
> otherwise.  It does so under the waitqueue lock.  Racing with a wake
> up means the aborting process is either already woken (removed from
> the queue) and will wake up the next waiter, or it will remove itself
> from the queue and the concurrent wake up will apply to the next
> waiter after it.
>
> Use abort_exclusive_wait() in __wait_event_interruptible_exclusive()
> and __wait_on_bit_lock() when they were interrupted by other means
> than a wake up through the queue.

Imho, this all is right, and this patch should replace
lock_page_killable-avoid-lost-wakeups.patch (except for stable tree).

But I guess we need maintainer's opinion, we have them in cc ;)

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
