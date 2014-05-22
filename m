Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2BA626B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 15:53:21 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id c13so3018044eek.12
        for <linux-mm@kvack.org>; Thu, 22 May 2014 12:53:20 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w47si2403468eep.66.2014.05.22.12.53.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 22 May 2014 12:53:19 -0700 (PDT)
Date: Thu, 22 May 2014 20:53:13 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: filemap: Avoid unnecessary barries and waitqueue
 lookups in unlock_page fastpath v5
Message-ID: <20140522195313.GN23991@suse.de>
References: <20140514192945.GA10830@redhat.com>
 <20140515104808.GF23991@suse.de>
 <20140515142414.16c47315a03160c58ceb9066@linux-foundation.org>
 <20140521121501.GT23991@suse.de>
 <20140521142622.049d0b3af5fc94912d5a1472@linux-foundation.org>
 <20140521213354.GL2485@laptop.programming.kicks-ass.net>
 <20140521145000.f130f8779f7641d0d8afcace@linux-foundation.org>
 <20140522064529.GI30445@twins.programming.kicks-ass.net>
 <20140522084643.GD23991@suse.de>
 <20140522104722.f76b5b8dc0ec28510687be2e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140522104722.f76b5b8dc0ec28510687be2e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On Thu, May 22, 2014 at 10:47:22AM -0700, Andrew Morton wrote:
> On Thu, 22 May 2014 09:46:43 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > > > If I'm still on track here, what happens if we switch to wake-all so we
> > > > can avoid the dangling flag?  I doubt if there are many collisions on
> > > > that hash table?
> > > 
> > > Wake-all will be ugly and loose a herd of waiters, all racing to
> > > acquire, all but one of whoem will loose the race. It also looses the
> > > fairness, its currently a FIFO queue. Wake-all will allow starvation.
> > > 
> > 
> > And the cost of the thundering herd of waiters may offset any benefit of
> > reducing the number of calls to page_waitqueue and waker functions.
> 
> Well, none of this has been demonstrated.
> 

True, but it's also the type of thing that would deserve a patch of its
own with some separation in case bisection fingerpoints to a patch that
is doing too much on its own.

> As I speculated earlier, hash chain collisions will probably be rare,

They are meant to be (well, they're documented to be). It's the primary
reason why I'm not concerned about "dangling waiters" being that common
a case.

> except for the case where a bunch of processes are waiting on the same
> page.  And in this case, perhaps wake-all is the desired behavior.
> 
> Take a look at do_read_cache_page().  It does lock_page(), but it
> doesn't actually *need* to.  It checks ->mapping and PG_uptodate and
> then...  unlocks the page!  We could have used wait_on_page_locked()
> there and permitted concurrent threads to run concurrently.
> 

It does that later when it calls wait_on_page_read but the flow is weird. It
looks like the first lock_page was to serialise against any IO and double
check it was not racing against a parallel reclaim although the elevated
reference count should have prevented that. Historical artifact maybe?
It looks like there could be some improvement there but also would deserve
a patch on its own.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
