Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 33BED6B0031
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 14:46:52 -0400 (EDT)
Date: Thu, 6 Jun 2013 18:46:50 +0000
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] mm: Revert pinned_vm braindamage
In-Reply-To: <20130606124351.GZ27176@twins.programming.kicks-ass.net>
Message-ID: <0000013f1ad00ec0-9574a936-3a75-4ccc-a84c-4a12a7ea106e-000000@email.amazonses.com>
References: <20130606124351.GZ27176@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, roland@kernel.org, mingo@kernel.org, tglx@linutronix.de, kosaki.motohiro@gmail.com, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-rdma@vger.kernel.org

On Thu, 6 Jun 2013, Peter Zijlstra wrote:

> Since RLIMIT_MEMLOCK is very clearly a limit on the amount of pages the
> process can 'lock' into memory it should very much include pinned pages
> as well as mlock()ed pages. Neither can be paged.

So we we thought that this is the sum of the pages that a process has
mlocked. Initiated by the process and/or environment explicitly. A user
space initiated action.

> Since nobody had anything constructive to say about the VM_PINNED
> approach and the IB code hurts my head too much to make it work I
> propose we revert said patch.

I said that the use of a PIN page flag would allow correct accounting if
one wanted to interpret the limit the way you do.

> Once again the rationale; MLOCK(2) is part of POSIX Realtime Extentsion
> (1003.1b-1993/1003.1i-1995). It states that the specified part of the
> user address space should stay memory resident until either program exit
> or a matching munlock() call.
>
> This definition basically excludes major faults from happening on the
> pages -- a major fault being one where IO needs to happen to obtain the
> page content; the direct implication being that page content must remain
> in memory.

Exactly that is the definition.

> Linux has taken this literal and made mlock()ed pages subject to page
> migration (albeit only for the explicit move_pages() syscall; but it
> would very much like to make them subject to implicit page migration for
> the purpose of compaction etc.).

Page migration is not a page fault? The ability to move a process
completely (including its mlocked segments) is important for the manual
migration of process memory. That is what page migration was made for. If
mlocked pages are treated as pinnned pages then the complete process can
no longer be moved from node to node.

> This view disregards the intention of the spec; since mlock() is part of
> the realtime spec the intention is very much that the user address range
> generate no faults; neither minor nor major -- any delay is
> unacceptable.

Where does it say that no faults are generated? Dont we generate COW on
mlocked ranges?

> This leaves the RT people unhappy -- therefore _if_ we continue with
> this Linux specific interpretation of mlock() we must introduce new
> syscalls that implement the intended mlock() semantics.

Intended means Peter's semantics?

> It was found that there are useful purposes for this weaker mlock(), a
> rationale to indeed have two sets of syscalls. The weaker mlock() can be
> used in the context of security -- where we avoid sensitive data being
> written to disk, and in the context of userspace deamons that are part
> of the IO path -- which would otherwise form IO deadlocks.

Migratable mlocked pages enable complete process migration between nodes
of a NUMA system for HPC workloads.

> The proposed second set of primitives would be mpin() and munpin() and
> would implement the intended mlock() semantics.

I agree that we need mpin and munpin. But they should not be called mlock
semantics.

> Such pages would not be migratable in any way (a possible
> implementation would be to 'pin' the pages using an extra refcount on
> the page frame). From the above we can see that any mpin()ed page is
> also an mlock()ed page, since mpin() will disallow any fault, and thus
> will also disallow major faults.

That cannot be so since mlocked pages need to be migratable.

> While we still lack the formal mpin() and munpin() syscalls there are a
> number of sites that have similar 'side effects' and result in user
> controlled 'pinning' of pages. Namely IB and perf.

Right thats why we need this.

> For the purpose of RLIMIT_MEMLOCK we must use intent only as it is not
> part of the formal spec. The only useful thing is to limit the amount of
> pages a user can exempt from paging. This would therefore include all
> pages either mlock()ed or mpin()ed.

RLIMIT_MEMLOCK is a limit on the pages that a process has mlocked into
memory. Pinning is not initiated by user space but by the kernel. Either
temporarily (page count increases are used all over the kernel for this)
or for longer time frame (IB and Perf and likely more drivers that we have
not found yet).


> > > Back to the patch; a resource limit must have a resource counter to
> enact the limit upon. Before the patch this was mm_struct::locked_vm.
> After the patch there is no such thing left.

The limit was not checked correctly before the patch since pinned pages
were accounted as mlocked.

> I state that since mlockall() disables/invalidates RLIMIT_MEMLOCK the
> actual resource counter value is irrelevant, and thus the reported
> problem is a non-problem.

Where does it disable RLIMIT_MEMLOCK?

> However, it would still be possible to observe weirdness in the very
> unlikely event that a user would indeed call mlock() upon an address
> range obtained from IB/perf. In this case he would be unduly constrained
> and find his effective RLIMIT_MEMLOCK limit halved (at worst).

This is weird for other reasons as well since we are using two different
methods: MLOCK leads to the page be marked as PG_mlock and be put on a
special LRU list. Pinning is simply an increase in the refcounts. Its
going to be difficult to keep accounting straight because a page can have
both.

> I've yet to hear a coherent objection to the above. Christoph is always
> quick to yell: 'but if fixes a double accounting issue' but is
> completely deaf to the fact that he changed user visible semantics
> without mention and regard.

The semantics we agreed upon for mlock were that they are migratable.
Pinned pages cannot be migrated and therefore are not mlocked pages.

It would be best to have two different mechanisms for this. Note that the
pinning is always done by the kernel and/or device driver related to some
other activity whereas mlocking is initiated by userspace. We do not need
a new API.

If you want to avoid the moving of mlocked pages then disasble the
mechanisms that need to move processes around. Having the ability in
general to move processes is a degree of control that we want. Pinning
could be restricted to where it is required by the hardware.

We could also add a process flag that exempts a certain process from page
migration which may be the result of NUMA scheduler actions, explict
requests from the user to migrate a process, defrag or compaction.

Excessive amounts of pinned pages limit the ability of the kernel
to manage its memory severely which may cause instabilities. mlocked pages
are better because the kernel still has some options.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
