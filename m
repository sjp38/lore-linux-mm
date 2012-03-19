Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id AF6AD6B00EF
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 07:42:47 -0400 (EDT)
Message-ID: <4F671B90.3010209@redhat.com>
Date: Mon, 19 Mar 2012 13:42:08 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 00/26] sched/numa
References: <20120316144028.036474157@chello.nl>  <4F670325.7080700@redhat.com> <1332155527.18960.292.camel@twins>
In-Reply-To: <1332155527.18960.292.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/19/2012 01:12 PM, Peter Zijlstra wrote:
> On Mon, 2012-03-19 at 11:57 +0200, Avi Kivity wrote:
> > On 03/16/2012 04:40 PM, Peter Zijlstra wrote:
> > > The home-node migration handles both cpu and memory (anonymous only for now) in
> > > an integrated fashion. The memory migration uses migrate-on-fault to avoid
> > > doing a lot of work from the actual numa balancer kernl thread and only
> > > migrates the active memory.
> > >
> > 
> > IMO, this needs to be augmented with eager migration, for the following
> > reasons:
> > 
> > - lazy migration adds a bit of latency to page faults
>
> That's intentional, it keeps the work accounted to the tasks that need
> it.

The accounting part is good, the extra latency is not.  If you have
spare resources (processors or dma engines) you can employ for eager
migration why not make use of them.

> > - doesn't work well with large pages
>
> That's for someone who cares about large pages to sort, isn't it? Also,
> I thought you virt people only used THP anyway, and those work just fine
> (they get broken down, and presumably something will build them back up
> on the other side).

Extra work, and more slowness until they get rebuilt.  Why not migrate
entire large pages?

> [ note that I equally dislike the THP daemon, I would have much
> preferred that to be fault driven as well. ]

The scanning part has to be independent, no?

> > - doesn't work with dma engines
>
> How does that work anyway? You'd have to reprogram your dma engine, so
> either the ->migratepage() callback does that and we're good either way,
> or it simply doesn't work at all.

If it's called from the faulting task's context you have to sleep, and
the latency gets increased even more, plus you're dependant on the dma
engine's backlog.  If you do all that from a background thread you don't
have to block (you might have to cancel or discard a migration if the
page was changed while being copied).

> > So I think that in addition to migrate on fault we need a background
> > thread to do eager migration.  We might prioritize pages based on the
> > active bit in the PDE (cheaper to clear and scan than the PTE, but gives
> > less accurate information).
>
> I absolutely loathe background threads and page table scanners and will
> do pretty much everything to avoid them.
>
> The problem I have with farming work out to other entities is that its
> thereafter terribly hard to account it back to whoemever caused the
> actual work. Suppose your kworker thread consumes a lot of cpu time --
> this time is then obviously not available to your application -- but how
> do you find out what/who is causing this and cure it?

I agree with this, but it's really widespread throughout the kernel,
from interrupts to work items to background threads.  It needs to be
solved generically (IIRC vhost has some accouting fix for a similar issue).

Doing everything from task context solves the accounting problem but
introduces others.

> As to page table scanners, I simply don't see the point. They tend to
> require arch support (I see aa introduces yet another PTE bit -- this
> instantly limits the usefulness of the approach as lots of archs don't
> have spare bits).
>
> Also, if you go scan memory, you need some storage -- see how aa grows
> struct page, sure he wants to move that storage some place else, but the
> memory overhead is still there -- this means less memory to actually do
> useful stuff in (it also probably means more cache-misses since his
> proposed shadow array in pgdat is someplace else).

It's the standard space/time tradeoff.  Once solution wants more
storage, the other wants more faults.

Note scanners can use A/D bits which are cheaper than faults.

> Also, the only really 'hard' case for the whole auto-numa business is
> single processes that are bigger than a single node -- and those I pose
> are 'rare'.

I agree, especially as sizeof(node) keeps growing, while nr_nodes == 2
or 4, usually.

> Now if you want to be able to scan per-thread, you need per-thread
> page-tables and I really don't want to ever see that. That will blow
> memory overhead and context switch times.

I thought of only duplicating down to the PDE level, that gets rid of
almost all of the overhead.

> I guess you can limit the impact by only running the scanners on
> selected processes, but that requires you add interfaces and then either
> rely on admins or userspace to second guess application developers.
>
> So no, I don't like that at all.
>
> I'm still reading aa's patch, I haven't actually found anything I like
> or agree with in there, but who knows, there's still some way to go.

IMO we need some combination.  I like the explicit vnode approach and
binding threads explicitly to memory areas, but I think fault-time
migration is too slow.  But maybe migration will be very rare and it
won't matter.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
