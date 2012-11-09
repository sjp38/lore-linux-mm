Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 4F5C56B002B
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 11:12:43 -0500 (EST)
Date: Fri, 9 Nov 2012 16:12:37 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 00/19] Foundation for automatic NUMA balancing
Message-ID: <20121109161236.GK8218@suse.de>
References: <1352193295-26815-1-git-send-email-mgorman@suse.de>
 <20121109144257.GA26870@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121109144257.GA26870@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Nov 09, 2012 at 03:42:57PM +0100, Andrea Arcangeli wrote:
> Hi Mel,
> 
> On Tue, Nov 06, 2012 at 09:14:36AM +0000, Mel Gorman wrote:
> > This series addresses part of the integration and sharing problem by
> > implementing a foundation that either the policy for schednuma or autonuma
> > can be rebased on. The actual policy it implements is a very stupid
> > greedy policy called "Migrate On Reference Of pte_numa Node (MORON)".
> > While stupid, it can be faster than the vanilla kernel and the expectation
> > is that any clever policy should be able to beat MORON. The advantage is
> > that it still defines how the policy needs to hook into the core code --
> > scheduler and mempolicy mostly so many optimisations (s uch as native THP
> > migration) can be shared between different policy implementations.
> 
> I haven't had much time to look into it yet, because I've been
> attending KVM Forum the last few days,

That's fine. I knew you were travelling and that there would be delay.

> but this foundation looks ok
> with me as a starting base and I ack it for merging it upstream. I'll
> try to rebase on top of this and send you some patches.
> 

Thanks, that's great news! It's not quite ready for merging yet. I found
a few bugs in the foundation that I ironed out since and I would like to
have better figures for specjbb.

With that in mind I'm still in the process of implementing something like
cpu-follow-memory on top. I'll post it early next week even if the figures
are crap for the purposes of illustration and to get the existing fixes
out there. Even you think the version of the cpu-follow implementation is
complete crap you'll at least see what I thought the integration points
would look like and we'll come up with an alternative.

My hope is that we layer the smallest amount on top each iteration with
benchmark validation at each step until we get something approaching
autonuma or schednumas in terms of performance. Which one we use as the
performance target will depend on whether schednuma or autonuma was better
on that particular test. I'll be using mmtests on a 4-node machine each
step but obviously other testers would be very welcome.

As things stand right now I just finished a script to show where threads
and running and what their per-node memory usage is and it's showing that
specjbb threads are not converging at all. I'm not losing sleep over it
just yet as I would be incredibly surprised if I got this right first time
even with having schednuma and autonuma to look at :) .

> > Patch 14 adds a MPOL_MF_LAZY mempolicy that an interested application can use.
> > 	On the next reference the memory should be migrated to the node that
> > 	references the memory.
> 
> This approach of starting with a stripped down foundation won't allow
> for easy backportability anyway, so merging the userland API at the
> first step shouldn't provide any benefit for the work that is ahead of
> us. I would leave this for later and not part of the foundation.
> 

This needs a bit more consensus. I'm happy to drop the userspace API
until all this settles down but will initially try and keep the internal
mempolicy aspects.  Initially I preserved the userspace API because
I understood Peter's logic that we should help application developers
as much as possible before depending entirely on the automatic approach
offered by both autonuma and schednuma.

Peter?

> All we need is a failsafe runtime and boot time turn off knob, just in
> case.

Yes, fully agreed. It's on the TODO list and I consider it a requirement
before it's merged. THP experience has told us that being able to turn
it off at runtime was very handy for debugging.

Thanks Andrea.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
