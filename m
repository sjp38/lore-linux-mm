Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 012B86B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 04:46:49 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id e53so2325329eek.22
        for <linux-mm@kvack.org>; Thu, 22 May 2014 01:46:49 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e49si13879677eep.39.2014.05.22.01.46.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 22 May 2014 01:46:48 -0700 (PDT)
Date: Thu, 22 May 2014 09:46:43 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: filemap: Avoid unnecessary barries and waitqueue
 lookups in unlock_page fastpath v5
Message-ID: <20140522084643.GD23991@suse.de>
References: <20140513141748.GD2485@laptop.programming.kicks-ass.net>
 <20140514161152.GA2615@redhat.com>
 <20140514192945.GA10830@redhat.com>
 <20140515104808.GF23991@suse.de>
 <20140515142414.16c47315a03160c58ceb9066@linux-foundation.org>
 <20140521121501.GT23991@suse.de>
 <20140521142622.049d0b3af5fc94912d5a1472@linux-foundation.org>
 <20140521213354.GL2485@laptop.programming.kicks-ass.net>
 <20140521145000.f130f8779f7641d0d8afcace@linux-foundation.org>
 <20140522064529.GI30445@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140522064529.GI30445@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On Thu, May 22, 2014 at 08:45:29AM +0200, Peter Zijlstra wrote:
> On Wed, May 21, 2014 at 02:50:00PM -0700, Andrew Morton wrote:
> > On Wed, 21 May 2014 23:33:54 +0200 Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > Alternative solution is not to merge the patch ;)
> 
> There is always that.. :-)
> 
> > > Yeah, so we only clear that bit when at 'unlock' we find there are no
> > > more pending waiters, so if the last unlock still had a waiter, we'll
> > > leave the bit set.
> > 
> > Confused.  If the last unlock had a waiter, that waiter will get woken
> > up so there are no waiters any more, so the last unlock clears the flag.
> > 
> > um, how do we determine that there are no more waiters?  By looking at
> > the waitqueue.  But that waitqueue is hashed, so it may contain waiters
> > for other pages so we're screwed?  But we could just go and wake up the
> > other-page waiters anyway and still clear PG_waiters?
> > 
> > um2, we're using exclusive waitqueues so we can't (or don't) wake all
> > waiters, so we're screwed again?
> 
> Ah, so leave it set. Then when we do an uncontended wakeup, that is a
> wakeup where there are _no_ waiters left, we'll iterate the entire
> hashed queue, looking for a matching page.
> 
> We'll find none, and only then clear the bit.
> 

Yes, sorry that was not clear.

> 
> > (This process is proving to be a hard way of writing Mel's changelog btw).
> 
> Agreed :/
> 

I've lost sight of what is obvious and what is not. The introduction
now reads

	This patch introduces a new page flag for 64-bit capable machines,
	PG_waiters, to signal there are *potentially* processes waiting on
	PG_lock or PG_writeback.  If there are no possible waiters then we
	avoid barriers, a waitqueue hash lookup and a failed wake_up in the
	unlock_page and end_page_writeback paths. There is no guarantee
	that waiters exist if PG_waiters is set as multiple pages can
	hash to the same waitqueue and we cannot accurately detect if a
	waking process is the last waiter without a reference count. When
	this happens, the bit is left set and the next unlock or writeback
	completion will lookup the waitqueue and clear the bit when there
	are no collisions. This adds a few branches to the fast path but
	avoids bouncing a dirty cache line between CPUs. 32-bit machines
	always take the slow path but the primary motivation for this
	patch is large machines so I do not think that is a concern.

> > If I'm still on track here, what happens if we switch to wake-all so we
> > can avoid the dangling flag?  I doubt if there are many collisions on
> > that hash table?
> 
> Wake-all will be ugly and loose a herd of waiters, all racing to
> acquire, all but one of whoem will loose the race. It also looses the
> fairness, its currently a FIFO queue. Wake-all will allow starvation.
> 

And the cost of the thundering herd of waiters may offset any benefit of
reducing the number of calls to page_waitqueue and waker functions.

> > If there *are* a lot of collisions, I bet it's because a great pile of
> > threads are all waiting on the same page.  If they're trying to lock
> > that page then wake-all is bad.  But if they're just waiting for IO
> > completion (probable) then it's OK.
> 
> Yeah, I'm not entirely sure on the rationale for adding PG_waiters to
> writeback completion, and yes PG_writeback is a wake-all.

tmpfs was the most obvious one. We were doing a useless lookup almost
every time writeback completed for async streaming writers. I suspected
it would also apply to normal filesystems if backed by fast storage.

There is not much to gain by continuing to use __wake_up_bit in the
writeback pathso when PG_waiters is available. Only the first waiters
incurs the SetPageWaiters penalty. In the uncontended case, neither
take locks (one approach checks waitqueue_active outside the lock, the
other checks PageWaiters). Both approaches end up taking q->lock either
in __wake_up_bit->__wake_up or __wake_up_page_bit but in some cases
__wake_up_page_bit.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
