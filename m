Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id CF2B76B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 17:50:03 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id y13so1775099pdi.2
        for <linux-mm@kvack.org>; Wed, 21 May 2014 14:50:03 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id dq2si7895718pbb.118.2014.05.21.14.50.02
        for <linux-mm@kvack.org>;
        Wed, 21 May 2014 14:50:02 -0700 (PDT)
Date: Wed, 21 May 2014 14:50:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: filemap: Avoid unnecessary barries and waitqueue
 lookups in unlock_page fastpath v5
Message-Id: <20140521145000.f130f8779f7641d0d8afcace@linux-foundation.org>
In-Reply-To: <20140521213354.GL2485@laptop.programming.kicks-ass.net>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
	<1399974350-11089-20-git-send-email-mgorman@suse.de>
	<20140513125313.GR23991@suse.de>
	<20140513141748.GD2485@laptop.programming.kicks-ass.net>
	<20140514161152.GA2615@redhat.com>
	<20140514192945.GA10830@redhat.com>
	<20140515104808.GF23991@suse.de>
	<20140515142414.16c47315a03160c58ceb9066@linux-foundation.org>
	<20140521121501.GT23991@suse.de>
	<20140521142622.049d0b3af5fc94912d5a1472@linux-foundation.org>
	<20140521213354.GL2485@laptop.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On Wed, 21 May 2014 23:33:54 +0200 Peter Zijlstra <peterz@infradead.org> wrote:

> On Wed, May 21, 2014 at 02:26:22PM -0700, Andrew Morton wrote:
> > > +static inline void
> > > +__prepare_to_wait(wait_queue_head_t *q, wait_queue_t *wait,
> > > +			struct page *page, int state, bool exclusive)
> > 
> > Putting MM stuff into core waitqueue code is rather bad.  I really
> > don't know how I'm going to explain this to my family.
> 
> Right, so we could avoid all that and make the functions in mm/filemap.c
> rather large and opencode a bunch of wait.c stuff.
> 

The world won't end if we do it Mel's way and it's probably the most
efficient.  But ugh.  This stuff does raise the "it had better be a
useful patch" bar.

> Which is pretty much what I initially pseudo proposed.

Alternative solution is not to merge the patch ;)

> > > +		__ClearPageWaiters(page);
> > 
> > We're freeing the page - if someone is still waiting on it then we have
> > a huge bug?  It's the mysterious collision thing again I hope?
> 
> Yeah, so we only clear that bit when at 'unlock' we find there are no
> more pending waiters, so if the last unlock still had a waiter, we'll
> leave the bit set.

Confused.  If the last unlock had a waiter, that waiter will get woken
up so there are no waiters any more, so the last unlock clears the flag.

um, how do we determine that there are no more waiters?  By looking at
the waitqueue.  But that waitqueue is hashed, so it may contain waiters
for other pages so we're screwed?  But we could just go and wake up the
other-page waiters anyway and still clear PG_waiters?

um2, we're using exclusive waitqueues so we can't (or don't) wake all
waiters, so we're screwed again?

(This process is proving to be a hard way of writing Mel's changelog btw).

If I'm still on track here, what happens if we switch to wake-all so we
can avoid the dangling flag?  I doubt if there are many collisions on
that hash table?

If there *are* a lot of collisions, I bet it's because a great pile of
threads are all waiting on the same page.  If they're trying to lock
that page then wake-all is bad.  But if they're just waiting for IO
completion (probable) then it's OK.

I'll stop now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
