Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 0268C6B0036
	for <linux-mm@kvack.org>; Tue, 28 May 2013 12:37:07 -0400 (EDT)
Date: Tue, 28 May 2013 16:37:06 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH] mm: Fix RLIMIT_MEMLOCK
In-Reply-To: <20130527064834.GA2781@laptop>
Message-ID: <0000013eec0006ee-0f8caf7b-cc94-4f54-ae38-0ca6623b7841-000000@email.amazonses.com>
References: <alpine.DEB.2.10.1305222344060.12929@vincent-weaver-1.um.maine.edu> <20130523044803.GA25399@ZenIV.linux.org.uk> <20130523104154.GA23650@twins.programming.kicks-ass.net> <0000013ed1b8d0cc-ad2bb878-51bd-430c-8159-629b23ed1b44-000000@email.amazonses.com>
 <20130523152458.GD23650@twins.programming.kicks-ass.net> <0000013ed2297ba8-467d474a-7068-45b3-9fa3-82641e6aa363-000000@email.amazonses.com> <20130523163901.GG23650@twins.programming.kicks-ass.net> <0000013ed28b638a-066d7dc7-b590-49f8-9423-badb9537b8b6-000000@email.amazonses.com>
 <20130524140114.GK23650@twins.programming.kicks-ass.net> <0000013ed732b615-748f574f-ccb8-4de7-bbe4-d85d1cbf0c9d-000000@email.amazonses.com> <20130527064834.GA2781@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Vince Weaver <vincent.weaver@maine.edu>, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>, trinity@vger.kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, roland@kernel.org, infinipath@qlogic.com, linux-mm@kvack.org, linux-rdma@vger.kernel.org, Or Gerlitz <or.gerlitz@gmail.com>, Hugh Dickins <hughd@google.com>

On Mon, 27 May 2013, Peter Zijlstra wrote:

> Before your patch pinned was included in locked and thus RLIMIT_MEMLOCK
> had a single resource counter. After your patch RLIMIT_MEMLOCK is
> applied separately to both -- more or less.

Before the patch the count was doubled since a single page was counted
twice: Once because it was mlocked (marked with PG_mlock) and then again
because it was also pinned (the refcount was increased). Two different things.

We have agreed for a long time that mlocked pages are movable. That is not
true for pinned pages and therefore pinning pages therefore do not fall
into that category (Hugh? AFAICR you came up with that rule?)

> NO, mlocked pages are pages that do not leave core memory; IOW do not
> cause major faults. Pinning pages is a perfectly spec compliant mlock()
> implementation.

That is not the definition that we have used so far.

> Now in an earlier discussion on the issue 'we' (I can't remember if you
> participated there, I remember Mel and Kosaki-San) agreed that for
> 'normal' (read not whacky real-time people) mlock can still be useful
> and we should introduce a pinned user API for the RT people.

Right. I remember that.

> > Pinned pages are pages that have an elevated refcount because the hardware
> > needs to use these pages for I/O. The elevated refcount may be temporary
> > (then we dont care about this) or for a longer time (such as the memory
> > registration of the IB subsystem). That is when we account the memory as
> > pinned. The elevated refcount stops page migration and other things from
> > trying to move that memory.
>
> Again I _know_ that!!!

But then you refuse to acknowledge the difference and want to conflate
both.

> > Pages can be both pinned and mlocked.
>
> Right, but apart for mlockall() this is a highly unlikely situation to
> actually occur. And if you're using mlockall() you've effectively
> disabled RLIMIT_MEMLOCK and thus nobody cares if the resource counter
> goes funny.

mlockall() would never be used on all processes. You still need the
RLIMIT_MLOCK to ensure that the box does not lock up.

> > I think we need to be first clear on what we want to accomplish and what
> > these counters actually should count before changing things.
>
> Backward isn't it... _you_ changed it without consideration.

I applied the categorization that we had agreed on before during the
development of page migratiob. Pinning is not compatible.

> The IB code does a big get_user_pages(), which last time I checked
> pins a sequential range of pages. Therefore the VMA approach.

The IB code (and other code) can require the pinning of pages in various
ways.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
