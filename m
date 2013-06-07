Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 5A9236B0033
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 07:03:56 -0400 (EDT)
Date: Fri, 7 Jun 2013 13:03:44 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: Revert pinned_vm braindamage
Message-ID: <20130607110344.GA27176@twins.programming.kicks-ass.net>
References: <20130606124351.GZ27176@twins.programming.kicks-ass.net>
 <0000013f1ad00ec0-9574a936-3a75-4ccc-a84c-4a12a7ea106e-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013f1ad00ec0-9574a936-3a75-4ccc-a84c-4a12a7ea106e-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, roland@kernel.org, mingo@kernel.org, tglx@linutronix.de, kosaki.motohiro@gmail.com, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-rdma@vger.kernel.org

On Thu, Jun 06, 2013 at 06:46:50PM +0000, Christoph Lameter wrote:
> On Thu, 6 Jun 2013, Peter Zijlstra wrote:
> 
> > Since RLIMIT_MEMLOCK is very clearly a limit on the amount of pages the
> > process can 'lock' into memory it should very much include pinned pages
> > as well as mlock()ed pages. Neither can be paged.
> 
> So we we thought that this is the sum of the pages that a process has
> mlocked. Initiated by the process and/or environment explicitly. A user
> space initiated action.

Which we; also it remains fact that your changelog didn't mention this
change in semantics at all. Nor did you CC all affected parties.

However you twist this; your patch leaves an inconsistent mess. If you
really think they're two different things then you should have
introduced a second RLIMIT_MEMPIN to go along with your counter.

I'll argue against such a thing; for I think that limiting the total
amount of pages a user can exempt from paging is the far more
userful/natural thing to measure/limit.

> > Since nobody had anything constructive to say about the VM_PINNED
> > approach and the IB code hurts my head too much to make it work I
> > propose we revert said patch.
> 
> I said that the use of a PIN page flag would allow correct accounting if
> one wanted to interpret the limit the way you do.

You failed to explain how that would help any. With a pin page flag you
still need to find the mm to unaccount crap from. Also, all user
controlled address space ops operate on vmas. 

We had the VM_LOCKED far before we had the lock page flag. And you
cannot replace all VM_LOCKED utility with the pageflag either.

> > Once again the rationale; MLOCK(2) is part of POSIX Realtime Extentsion
> > (1003.1b-1993/1003.1i-1995). It states that the specified part of the
> > user address space should stay memory resident until either program exit
> > or a matching munlock() call.
> >
> > This definition basically excludes major faults from happening on the
> > pages -- a major fault being one where IO needs to happen to obtain the
> > page content; the direct implication being that page content must remain
> > in memory.
> 
> Exactly that is the definition.
> 
> > Linux has taken this literal and made mlock()ed pages subject to page
> > migration (albeit only for the explicit move_pages() syscall; but it
> > would very much like to make them subject to implicit page migration for
> > the purpose of compaction etc.).
> 
> Page migration is not a page fault? 

It introduces faults; what happens when a process hits the migration
pte? It gets a random delay and eventually services a minor fault to the
new page.

At which point the saw will have cut your finger off (going with the
most popular RT application ever -- that of a bandsaw and a laser beam).

> The ability to move a process
> completely (including its mlocked segments) is important for the manual
> migration of process memory. That is what page migration was made for. If
> mlocked pages are treated as pinnned pages then the complete process can
> no longer be moved from node to node.
> 
> > This view disregards the intention of the spec; since mlock() is part of
> > the realtime spec the intention is very much that the user address range
> > generate no faults; neither minor nor major -- any delay is
> > unacceptable.
> 
> Where does it say that no faults are generated? Dont we generate COW on
> mlocked ranges?

That's under user control. If the user uses fork() the user can avoid
those faults by pre-faulting the pages.

> > This leaves the RT people unhappy -- therefore _if_ we continue with
> > this Linux specific interpretation of mlock() we must introduce new
> > syscalls that implement the intended mlock() semantics.
> 
> Intended means Peter's semantics?

No, I don't actually write RT applications. But I've had plenty of
arguments with RT people when I explained to them what our mlock()
actually does vs what they expected it to do.

They're not happy. Aside from that; you HPC/HFT minimal latency lot
should very well appreciate the minimal interference stuff they do
actually expect.

> > It was found that there are useful purposes for this weaker mlock(), a
> > rationale to indeed have two sets of syscalls. The weaker mlock() can be
> > used in the context of security -- where we avoid sensitive data being
> > written to disk, and in the context of userspace deamons that are part
> > of the IO path -- which would otherwise form IO deadlocks.
> 
> Migratable mlocked pages enable complete process migration between nodes
> of a NUMA system for HPC workloads.

This might well be; and I'm not arguing we remove this. I'm merely
stating that it doesn't make everybody happy. Also what purpose do HPC
type applications have for mlock()?

> > The proposed second set of primitives would be mpin() and munpin() and
> > would implement the intended mlock() semantics.
> 
> I agree that we need mpin and munpin. But they should not be called mlock
> semantics.

Here we must disagree I fear; given that mlock() is of RT origin and RT
people very much want/expect mlock() to do what our proposed mpin() will
do.

> > Such pages would not be migratable in any way (a possible
> > implementation would be to 'pin' the pages using an extra refcount on
> > the page frame). From the above we can see that any mpin()ed page is
> > also an mlock()ed page, since mpin() will disallow any fault, and thus
> > will also disallow major faults.
> 
> That cannot be so since mlocked pages need to be migratable.

I'm talking about the proposed mpin() stuff.

> > While we still lack the formal mpin() and munpin() syscalls there are a
> > number of sites that have similar 'side effects' and result in user
> > controlled 'pinning' of pages. Namely IB and perf.
> 
> Right thats why we need this.

So I proposed most of the machinery that would be required to actually
implement the syscalls. Except that the IB code stumped me. In
particular I cannot easily find the userspace address to unpin for
ipath/qib release paths.

Once we have that we can trivially implement the syscalls.

> > For the purpose of RLIMIT_MEMLOCK we must use intent only as it is not
> > part of the formal spec. The only useful thing is to limit the amount of
> > pages a user can exempt from paging. This would therefore include all
> > pages either mlock()ed or mpin()ed.
> 
> RLIMIT_MEMLOCK is a limit on the pages that a process has mlocked into
> memory. 

See my argument above; I don't think userspace is served well with two
RLIMITs.

> Pinning is not initiated by user space but by the kernel. Either
> temporarily (page count increases are used all over the kernel for this)
> or for longer time frame (IB and Perf and likely more drivers that we have
> not found yet).

Here I disagree, I'll argue that all pins that require userspace action
to go away are userspace controlled pins. This makes IB/Perf user
controlled pins and should thus be treated the same as mpin()/munpin()
calls.

> > > > Back to the patch; a resource limit must have a resource counter to
> > enact the limit upon. Before the patch this was mm_struct::locked_vm.
> > After the patch there is no such thing left.
> 
> The limit was not checked correctly before the patch since pinned pages
> were accounted as mlocked.

This goes back to what you want the limit to mean; I think a single
limit counting all pages exempt from paging is the far more useful
limit.

Again, your changelog was completely devoid of any rlimit discussion.

> > I state that since mlockall() disables/invalidates RLIMIT_MEMLOCK the
> > actual resource counter value is irrelevant, and thus the reported
> > problem is a non-problem.
> 
> Where does it disable RLIMIT_MEMLOCK?

The only way to get an MCL_FUTURE is through CAP_IPC_LOCK. Practically
most MCL_CURRENT are also larger than RLIMIT_MEMLOCK and this also
requires CAP_IPC_LOCK.

Once you have CAP_IPC_LOCK, RLIMIT_MEMLOCK becomes irrelevant.

> > However, it would still be possible to observe weirdness in the very
> > unlikely event that a user would indeed call mlock() upon an address
> > range obtained from IB/perf. In this case he would be unduly constrained
> > and find his effective RLIMIT_MEMLOCK limit halved (at worst).
> 
> This is weird for other reasons as well since we are using two different
> methods: MLOCK leads to the page be marked as PG_mlock and be put on a
> special LRU list. Pinning is simply an increase in the refcounts. Its
> going to be difficult to keep accounting straight because a page can have
> both.

The way how the kernel implements these semantics is irrelevant.

> > I've yet to hear a coherent objection to the above. Christoph is always
> > quick to yell: 'but if fixes a double accounting issue' but is
> > completely deaf to the fact that he changed user visible semantics
> > without mention and regard.
> 
> The semantics we agreed upon for mlock were that they are migratable.
> Pinned pages cannot be migrated and therefore are not mlocked pages.
> It would be best to have two different mechanisms for this. 

Best for whoem? How is making two RLIMIT settings better than having
one?

For me the being able to migrate a page is a consequence of allowing
minor faults; not a fundamental property.

> Note that the
> pinning is always done by the kernel and/or device driver related to some
> other activity whereas mlocking is initiated by userspace. 

See my earlier argument. If unpinning requires userspace action; its a
userspace controlled pin. Also for perf the setup is very much also a
userspace action; an mmap() call, and I expect the same is true for IB;
although it might use different syscalls.

> We do not need a new API.

This is in direct contradiction with your earlier statement where you
say: "I agree that we need mpin and munpin.". 

Please make up your mind.

> If you want to avoid the moving of mlocked pages then disasble the
> mechanisms that need to move processes around.

This is not really a feasible option anymore; page migration is creeping
all over the place. Also who is to say people don't want to also run
something with huge pages along side their RT proglet. 

> Having the ability in
> general to move processes is a degree of control that we want. Pinning
> could be restricted to where it is required by the hardware.

Or software; you cannot blindly dismiss realtime guarantees the software
needs to provide.

> We could also add a process flag that exempts a certain process from page
> migration which may be the result of NUMA scheduler actions, explict
> requests from the user to migrate a process, defrag or compaction.

This too is a new API; and one I think is much less precise than mpin().
You wouldn't want an entire process to be exempt from paging. Only the
code and data involved with the realtime part of the process needs stay
put.

Furthermore, mpin() could simply migrate the pages into as few unmovable
page blocks as possible to minimise the impact on the rest of the vm.
Allocating entire processes as umovable and migrating any DSO it touches
into unmovable is a far more onerous endeavour.

With the pre-compaction of pinned memory, I don't see the VM impact of
pinned pages being much bigger than that of mlocked pages. The main
issue will be limiting the amount of memory exempt from paging, not
fragmentation per se.

Yes you can get some unmovable block fragmentation on unpin, but if its
a common thing a new pin will be able to fill those blocks again.

> Excessive amounts of pinned pages limit the ability of the kernel
> to manage its memory severely which may cause instabilities. mlocked pages
> are better because the kernel still has some options.

I'm not arguing which are better; I've even conceded we need mpin() and
can keep the current mlock() semantics. I'm arguing for what we _need_.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
