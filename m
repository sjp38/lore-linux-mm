Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 11BEE6B0034
	for <linux-mm@kvack.org>; Fri, 24 May 2013 11:40:28 -0400 (EDT)
Date: Fri, 24 May 2013 15:40:26 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH] mm: Fix RLIMIT_MEMLOCK
In-Reply-To: <20130524140114.GK23650@twins.programming.kicks-ass.net>
Message-ID: <0000013ed732b615-748f574f-ccb8-4de7-bbe4-d85d1cbf0c9d-000000@email.amazonses.com>
References: <alpine.DEB.2.10.1305221523420.9944@vincent-weaver-1.um.maine.edu> <alpine.DEB.2.10.1305221953370.11450@vincent-weaver-1.um.maine.edu> <alpine.DEB.2.10.1305222344060.12929@vincent-weaver-1.um.maine.edu> <20130523044803.GA25399@ZenIV.linux.org.uk>
 <20130523104154.GA23650@twins.programming.kicks-ass.net> <0000013ed1b8d0cc-ad2bb878-51bd-430c-8159-629b23ed1b44-000000@email.amazonses.com> <20130523152458.GD23650@twins.programming.kicks-ass.net> <0000013ed2297ba8-467d474a-7068-45b3-9fa3-82641e6aa363-000000@email.amazonses.com>
 <20130523163901.GG23650@twins.programming.kicks-ass.net> <0000013ed28b638a-066d7dc7-b590-49f8-9423-badb9537b8b6-000000@email.amazonses.com> <20130524140114.GK23650@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Vince Weaver <vincent.weaver@maine.edu>, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>, trinity@vger.kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, roland@kernel.org, infinipath@qlogic.com, linux-mm@kvack.org, linux-rdma@vger.kernel.org, Or Gerlitz <or.gerlitz@gmail.com>

On Fri, 24 May 2013, Peter Zijlstra wrote:

> Patch bc3e53f682 ("mm: distinguish between mlocked and pinned pages")
> broke RLIMIT_MEMLOCK.

Nope the patch fixed a problem with double accounting.

The problem that we seem to have is to define what mlocked and pinned mean
and how this relates to RLIMIT_MEMLOCK.

mlocked pages are pages that are movable (not pinned!!!) and that are
marked in some way by user space actions as mlocked (POSIX semantics).
They are marked with a special page flag (PG_mlocked).

Pinned pages are pages that have an elevated refcount because the hardware
needs to use these pages for I/O. The elevated refcount may be temporary
(then we dont care about this) or for a longer time (such as the memory
registration of the IB subsystem). That is when we account the memory as
pinned. The elevated refcount stops page migration and other things from
trying to move that memory.

Pages can be both pinned and mlocked. Before my patch some pages those two
issues were conflated since the same counter was used and therefore these
pages were counted twice. If an RDMA application was running using
mlockall() and was performing large scale I/O then the counters could show
extraordinary large numbers and the VM would start to behave erratically.

It is important for the VM to know which pages cannot be evicted but that
involves many more pages due to dirty pages etc etc.

So far the assumption has been that RLIMIT_MEMLOCK is a limit on the pages
that userspace has mlocked.

You want the counter to mean something different it seems. What is it?

I think we need to be first clear on what we want to accomplish and what
these counters actually should count before changing things.

Certainly would appreciate improvements in this area but resurrecting the
conflation between mlocked and pinned pages is not the way to go.

> This patch proposes to properly fix the problem by introducing
> VM_PINNED. This also provides the groundwork for a possible mpin()
> syscall or MADV_PIN -- although these are not included.

Maybe add a new PIN page flag? Pages are not pinned per vma as the patch
seems to assume.

> It recognises that pinned page semantics are a strict super-set of
> locked page semantics -- a pinned page will not generate major faults
> (and thus satisfies mlock() requirements).

Not exactly true. Pinned pages may not have the mlocked flag set and they
are not managed on the unevictable LRU lists of the MM.

> If people find this approach unworkable, I request we revert the above
> mentioned patch to at least restore RLIMIT_MEMLOCK to a usable state
> again.

Cannot do that. This will cause the breakage that the patch was fixing to
resurface.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
