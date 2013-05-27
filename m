Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 7FDC16B00F2
	for <linux-mm@kvack.org>; Mon, 27 May 2013 02:49:00 -0400 (EDT)
Date: Mon, 27 May 2013 08:48:34 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH] mm: Fix RLIMIT_MEMLOCK
Message-ID: <20130527064834.GA2781@laptop>
References: <alpine.DEB.2.10.1305222344060.12929@vincent-weaver-1.um.maine.edu>
 <20130523044803.GA25399@ZenIV.linux.org.uk>
 <20130523104154.GA23650@twins.programming.kicks-ass.net>
 <0000013ed1b8d0cc-ad2bb878-51bd-430c-8159-629b23ed1b44-000000@email.amazonses.com>
 <20130523152458.GD23650@twins.programming.kicks-ass.net>
 <0000013ed2297ba8-467d474a-7068-45b3-9fa3-82641e6aa363-000000@email.amazonses.com>
 <20130523163901.GG23650@twins.programming.kicks-ass.net>
 <0000013ed28b638a-066d7dc7-b590-49f8-9423-badb9537b8b6-000000@email.amazonses.com>
 <20130524140114.GK23650@twins.programming.kicks-ass.net>
 <0000013ed732b615-748f574f-ccb8-4de7-bbe4-d85d1cbf0c9d-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013ed732b615-748f574f-ccb8-4de7-bbe4-d85d1cbf0c9d-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Vince Weaver <vincent.weaver@maine.edu>, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>, trinity@vger.kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, roland@kernel.org, infinipath@qlogic.com, linux-mm@kvack.org, linux-rdma@vger.kernel.org, Or Gerlitz <or.gerlitz@gmail.com>

On Fri, May 24, 2013 at 03:40:26PM +0000, Christoph Lameter wrote:
> On Fri, 24 May 2013, Peter Zijlstra wrote:
> 
> > Patch bc3e53f682 ("mm: distinguish between mlocked and pinned pages")
> > broke RLIMIT_MEMLOCK.
> 
> Nope the patch fixed a problem with double accounting.

And introduces another problem by now under-counting in a much more
likely scenario.

Before your patch pinned was included in locked and thus RLIMIT_MEMLOCK
had a single resource counter. After your patch RLIMIT_MEMLOCK is
applied separately to both -- more or less.

Your patch changes RLIMIT_MEMLOCK semantics, doesn't mention this in the
Changelog which makes one think this was unintentional. And you're
refusing to acknowledge that this might be a problem.

The fact that RLIMIT_MEMLOCK is the only consumer of the counter tells
me you simply didn't seem to care and did a sloppy patch 'solving' your
immediate issue.

The below discussion of what mlock vs pinned should mean for
RLIMIT_MEMLOCK should have been part of that patch, since it changed the
previously established behaviour.

> The problem that we seem to have is to define what mlocked and pinned mean
> and how this relates to RLIMIT_MEMLOCK.
> 
> mlocked pages are pages that are movable (not pinned!!!) and that are
> marked in some way by user space actions as mlocked (POSIX semantics).
> They are marked with a special page flag (PG_mlocked).

NO, mlocked pages are pages that do not leave core memory; IOW do not
cause major faults. Pinning pages is a perfectly spec compliant mlock()
implementation.

See: http://pubs.opengroup.org/onlinepubs/7908799/xsh/mlock.html

The fact that we _want_ a weaker implementation because we like to move
them despite them being mlocked is us playing weasel words with the spec
:-) So much so that we have to introduce a means of actually pinning
them _before_ we start to actually migrate mlocked pages (or did
somebody actually change that too?).

RT people will be unhappy if they hit minor faults or have to wait
behind page-migration (esp. since the migrate code only removes the
migration PTE after all pages in the batch are migrated).

BTW, notice that mlock() is part of the REALTIME spec, and while its
wording is such that is allows us to make it unsuitable for actual
real-time usage this goes against the intent of the spec.

Now in an earlier discussion on the issue 'we' (I can't remember if you
participated there, I remember Mel and Kosaki-San) agreed that for
'normal' (read not whacky real-time people) mlock can still be useful
and we should introduce a pinned user API for the RT people.

> Pinned pages are pages that have an elevated refcount because the hardware
> needs to use these pages for I/O. The elevated refcount may be temporary
> (then we dont care about this) or for a longer time (such as the memory
> registration of the IB subsystem). That is when we account the memory as
> pinned. The elevated refcount stops page migration and other things from
> trying to move that memory.

Again I _know_ that!!!

> Pages can be both pinned and mlocked. 

Right, but apart for mlockall() this is a highly unlikely situation to
actually occur. And if you're using mlockall() you've effectively
disabled RLIMIT_MEMLOCK and thus nobody cares if the resource counter
goes funny.

> Before my patch some pages those two
> issues were conflated since the same counter was used and therefore these
> pages were counted twice. If an RDMA application was running using
> mlockall() and was performing large scale I/O then the counters could show
> extraordinary large numbers and the VM would start to behave erratically.
> 
> It is important for the VM to know which pages cannot be evicted but that
> involves many more pages due to dirty pages etc etc.

But the VM as such doesn't care, the VM doesn't use either locked_vm nor
pinned_vm for anything! The only user is RLIMIT_MEMLOCK and you silently
changed semantics.

> So far the assumption has been that RLIMIT_MEMLOCK is a limit on the pages
> that userspace has mlocked.
> 
> You want the counter to mean something different it seems. What is it?

It would've been so much better if you'd asked me that before you mucked
it up.

The intent of RLIMIT_MEMLOCK is clearly to limit the amount of memory
the user can lock into core memory as per the direct definition of
mlock. By this definition pinned should be included. This leaves us to
solve the issue of pinned mlocked memory.

> I think we need to be first clear on what we want to accomplish and what
> these counters actually should count before changing things.

Backward isn't it... _you_ changed it without consideration.

> Certainly would appreciate improvements in this area but resurrecting the
> conflation between mlocked and pinned pages is not the way to go.
> 
> > This patch proposes to properly fix the problem by introducing
> > VM_PINNED. This also provides the groundwork for a possible mpin()
> > syscall or MADV_PIN -- although these are not included.
> 
> Maybe add a new PIN page flag? Pages are not pinned per vma as the patch
> seems to assume.

The IB code does a big get_user_pages(), which last time I checked
pins a sequential range of pages. Therefore the VMA approach.

The perf thing is guaranteed to be virtually sequential and already is a
VMA -- its the result of a user mmap() call.

> > It recognises that pinned page semantics are a strict super-set of
> > locked page semantics -- a pinned page will not generate major faults
> > (and thus satisfies mlock() requirements).
> 
> Not exactly true. Pinned pages may not have the mlocked flag set and they
> are not managed on the unevictable LRU lists of the MM.

Re-read the spec; pinned pages stay in memory; therefore they qualify.
The fact that we've gone all 'smart' about dealing with such pages is
immaterial.

> > If people find this approach unworkable, I request we revert the above
> > mentioned patch to at least restore RLIMIT_MEMLOCK to a usable state
> > again.
> 
> Cannot do that. This will cause the breakage that the patch was fixing to
> resurface.

But fixes my borkage, which I argue is much more user visible since it
doesn't require CAP_IPC_LOCK :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
