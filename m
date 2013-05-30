Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 1E7A36B0032
	for <linux-mm@kvack.org>; Thu, 30 May 2013 14:31:03 -0400 (EDT)
Date: Thu, 30 May 2013 20:30:47 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH] mm: Fix RLIMIT_MEMLOCK
Message-ID: <20130530183047.GC27176@twins.programming.kicks-ass.net>
References: <20130523104154.GA23650@twins.programming.kicks-ass.net>
 <0000013ed1b8d0cc-ad2bb878-51bd-430c-8159-629b23ed1b44-000000@email.amazonses.com>
 <20130523152458.GD23650@twins.programming.kicks-ass.net>
 <0000013ed2297ba8-467d474a-7068-45b3-9fa3-82641e6aa363-000000@email.amazonses.com>
 <20130523163901.GG23650@twins.programming.kicks-ass.net>
 <0000013ed28b638a-066d7dc7-b590-49f8-9423-badb9537b8b6-000000@email.amazonses.com>
 <20130524140114.GK23650@twins.programming.kicks-ass.net>
 <0000013ed732b615-748f574f-ccb8-4de7-bbe4-d85d1cbf0c9d-000000@email.amazonses.com>
 <20130527064834.GA2781@laptop>
 <0000013eec0006ee-0f8caf7b-cc94-4f54-ae38-0ca6623b7841-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013eec0006ee-0f8caf7b-cc94-4f54-ae38-0ca6623b7841-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Vince Weaver <vincent.weaver@maine.edu>, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>, trinity@vger.kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, roland@kernel.org, infinipath@qlogic.com, linux-mm@kvack.org, linux-rdma@vger.kernel.org, Or Gerlitz <or.gerlitz@gmail.com>, Hugh Dickins <hughd@google.com>

On Tue, May 28, 2013 at 04:37:06PM +0000, Christoph Lameter wrote:
> On Mon, 27 May 2013, Peter Zijlstra wrote:
> 
> > Before your patch pinned was included in locked and thus RLIMIT_MEMLOCK
> > had a single resource counter. After your patch RLIMIT_MEMLOCK is
> > applied separately to both -- more or less.
> 
> Before the patch the count was doubled since a single page was counted
> twice: Once because it was mlocked (marked with PG_mlock) and then again
> because it was also pinned (the refcount was increased). Two different things.

Before the patch RLIMIT_MEMLOCK was a limit on the sum of both, after it
is no longer. This change was not described in the changelog.

This is a bug plain and simple and you refuse to acknowledge it.

> We have agreed for a long time that mlocked pages are movable. That is not
> true for pinned pages and therefore pinning pages therefore do not fall
> into that category (Hugh? AFAICR you came up with that rule?)

Into what category? RLIMIT_MEMLOCK should be a limit on the amount of
pages that are constrained to memory (can not be paged). How does a
pinned page not qualify for that?

> > NO, mlocked pages are pages that do not leave core memory; IOW do not
> > cause major faults. Pinning pages is a perfectly spec compliant mlock()
> > implementation.
> 
> That is not the definition that we have used so far.

There's two statements there; which one do you disagree with?

On the first; that is exactly the mlock() definition you want; excluding
major faults only means faults cannot be subject to IO, IOW pages must
remain in memory. Not excluding minor faults allows you to unmap and
migrate pages.

On the second; excluding any faults; that is what the mlock() specs
intended -- because that is the thing real-time people really want and
mlock is part of the real-time POSIX spec.

[ Hence the need to provide mpin() and munpin() syscalls before we make
  mlock() pages migratable, otherwise RT people are screwed. ]

Since excluding any fault per definition also excludes major faults,
the second is a clear superset of the first. Both ensure pages stay in
memory, thus both should count towards RLIMIT_MEMLOCK.

> But then you refuse to acknowledge the difference and want to conflate
> both.

You're the one that is confused. You're just repeating yourself without
providing argument or reason. 

> > > Pages can be both pinned and mlocked.
> >
> > Right, but apart for mlockall() this is a highly unlikely situation to
> > actually occur. And if you're using mlockall() you've effectively
> > disabled RLIMIT_MEMLOCK and thus nobody cares if the resource counter
> > goes funny.
> 
> mlockall() would never be used on all processes. You still need the
> RLIMIT_MLOCK to ensure that the box does not lock up.

You're so skilled at missing the point its not funny. 

The resource counter (formerly mm_struct::locked_vm, currently broken)
associated with RLIMIT_MEMLOCK is per process. Therefore when you use
mlockall() you've already done away with the limit, and thus the
resource counter value is irrelevant.

> > > I think we need to be first clear on what we want to accomplish and what
> > > these counters actually should count before changing things.
> >
> > Backward isn't it... _you_ changed it without consideration.
> 
> I applied the categorization that we had agreed on before during the
> development of page migratiob. Pinning is not compatible.

I've never agreed to any such thing, you changed my code without cc'ing
me and without describing the actual change.

Please explain how pinned pages are not stuck in memory and can be
paged? Once you've convinced me of that, I'll concede they should not be
counted towards RLIMIT_MEMLOCK.

> > The IB code does a big get_user_pages(), which last time I checked
> > pins a sequential range of pages. Therefore the VMA approach.
> 
> The IB code (and other code) can require the pinning of pages in various
> ways.

You can also mlock()/madvise()/mprotect() in various ways, this is a
non-argument against using VMAs.

Is there anything besides IB and perf that has user controlled page
pinning? If so, it needs fixing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
