Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 63FD16B004A
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 06:06:13 -0500 (EST)
Date: Wed, 10 Nov 2010 22:05:49 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [patch] mm: vmscan implement per-zone shrinkers
Message-ID: <20101110110549.GV2715@dastard>
References: <20101109123246.GA11477@amd>
 <20101110051813.GS2715@dastard>
 <20101110063229.GA5700@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20101110063229.GA5700@amd>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 10, 2010 at 05:32:29PM +1100, Nick Piggin wrote:
> On Wed, Nov 10, 2010 at 04:18:13PM +1100, Dave Chinner wrote:
> > On Tue, Nov 09, 2010 at 11:32:46PM +1100, Nick Piggin wrote:
> > > Hi,
> > > 
> > > I'm doing some works that require per-zone shrinkers, I'd like to get
> > > the vmscan part signed off and merged by interested mm people, please.
> > > 
> > 
> > There are still plenty of unresolved issues with this general
> > approach to scaling object caches that I'd like to see sorted out
> > before we merge any significant shrinker API changes. Some things of
> 
> No changes, it just adds new APIs.
> 
> 
> > the top of my head:
> > 
> > 	- how to solve impendence mismatches between VM scalability
> > 	  techniques and subsystem scalabilty techniques that result
> > 	  in shrinker cross-muliplication explosions. e.g. XFS
> > 	  tracks reclaimable inodes in per-allocation group trees,
> > 	  so we'd get AG x per-zone LRU trees using this shrinker
> > 	  method.  Think of the overhead on a 1000AG filesystem on a
> > 	  1000 node machine with 3-5 zones per node....
> 
> That's an interesting question, but no reason to hold anything up.
> It's up to the subsystem to handle it, or if they can't handle it
> sanely, you can elect to get no different behaviour than today.

See, this is what I think is the problem - you answer any concerns
by saying that the problem is entirely the responsibility of the
subsystem to handle. You've decided how you want shrinkers to work,
and everything else is SEP (somebody else's problem).

> I would say that per-zone is important for the above case, because it
> shrinks properly, based on memory pressure and pressure settings (eg.
> zone reclaim), and also obviously so that the reclaim threads are
> scanning node-local-memory so it doesn't have to pull objects from
> all over the interconnect.
> 
> With 1000 nodes and 1000AG filesystem, probably NxM is overkill, but
> there is no reason you couldn't have one LRU per X AGs.

And when it's only 1 node or 50 nodes or 50 AGs or 5000 AGs? I don't
like encoding _guesses_ at what might be a good configuration for an
arbitrary NxM configuration because they are rarely right. That's
exactly what you are suggesting here - that I solve this problem by
making guesses at how it might scale and coming up with some
arbitrary mapping scheme to handle it.

> All this is obviously implementation details -- pagecache reclaim does
> not want to know about this, so it doesn't affect the API.

i.e. it's another SEP solution.

> > 	- changes from global LRU behaviour to something that is not
> > 	  at all global - effect on workloads that depend on large
> > 	  scale caches that span multiple nodes is largely unknown.
> > 	  It will change IO patterns and affect system balance and
> > 	  performance of the system. How do we
> > 	  test/categorise/understand these problems and address such
> > 	  balance issues?
> 
> You've brought this up before several times and I've answered it.
> 
> The default configuration basically doesn't change much. Caches are
> allowed to fill up all zones and nodes, exactly the same as today.
> 
> On the reclaim side, when you have a global shortage, it will evenly
> shrink objects from all zones, so it still approximates LRU behaviour
> because number of objects far exceeds number of zones. This is exactly
> how per-zone pagecache scanning works too.

The whole point of the zone-based reclaim is that shrinkers run
when there are _local_ shortages on the _local_ LRUs and this will
happen much more often than global shortages, especially on large
machines. It will result in a change of behaviour, no question about
it.

However, this is not reason for not moving to this model - what I'm
asking is what the plan for categorising problems that arise as a
result of such a change? How do we go about translating random
reports like "I do this and it goes X% slower on 2.6.xx" to "that's
a result of the new LRU reclaim model, and you should do <this> to
try to resolve it". How do we triage such reports? What are our
options to resolve such problems? Are there any knobs we should add
at the beginning to give users ways of changing the behaviour to be
more like the curent code? We've got lots of different knobs to
control page cache reclaim behaviour - won't some of them be
relevant to per-zone slab cache reclaim?

> > 	- your use of this shrinker architecture for VFS
> > 	  inode/dentry cache scalability requires adding lists and
> > 	  locks to the MM struct zone for each object cache type
> > 	  (inode, dentry, etc). As such, it is not a generic
> > 	  solution because it cannot be used for per-instance caches
> > 	  like the per-mount inode caches XFS uses.
> 
> Of course it doesn't. You can use kmalloc.

Right - another SEP solution.

The reason people are using shrinkers is that it is simple to
implement a basic one. But implementing a scalable shrinker right
now is fucking hard - look at all the problems we've had with XFS
mostly because of the current API and the unbound parallelism of
direct reclaim.

This new API is a whole new adventure that not many people are going
to have machines capable of executing behavioural testing or
stressing. If everyone is forced to implement their own "scalable
shrinker" we'll end up with a rat's nest of different
implementations with similar but subtly different sets of bugs...

> > 	  i.e. nothing can actually use this infrastructure change
> > 	  without tying itself directly into the VM implementation,
> > 	  and even then not every existing shrinker can use this
> > 	  method of scaling. i.e. some level of abstraction from the
> > 	  VM implementation is needed in the shrinker API.
> 
> "zones" is the abstraction. The thing which all allocation and
> management of memory is based on, everywhere you do any allocations
> in the kernel. A *shrinker* implementation, a thing which is called
> in response to memory shortage in a given zone, has to know about
> zones. End of story. "Tied to the memory management implementation"
> is true to the extent that it is part of the memory management
> implementation.
>  
> 
> > 	- it has been pointed out that slab caches are generally
> > 	  allocated out of a single zone per node, so per-zone
> > 	  shrinker granularity seems unnecessary.
> 
> No they are not, that's just total FUD. Where was that "pointed out"?

Christoph Hellwig mentioned it, I think Christoph Lameter asked
exactly this question, I've mentioned it, and you even mentioned at
one point that zones were effectively a per-node construct....

> Slabs are generally allocated from every zone except for highmem and
> movable, and moreover there is nothing to prevent a shrinker
> implementation from needing to shrink highmem and movable pages as
> well.
>
> > 	- doesn't solve the unbound direct reclaim shrinker
> > 	  parallelism that is already causing excessive LRU lock
> > 	  contention on 8p single node systems. While
> > 	  per-LRU/per-node solves the larger scalability issue, it
> > 	  doesn't address scalability within the node. This is soon
> > 	  going to be 24p per node and that's more than enough to
> > 	  cause severe problems with a single lock and list...
> 
> It doesn't aim to solve that. It doesn't prevent that from being
> solved either (and improving parallelism in a subsystem generally,
> you know, helps with lock contention due to lots of threads in there,
> right?).

Sure, but you keep missing the point that it's a problem that is
more important to solve for the typical 2S or 4S server than scaling
to 1000 nodes is.  An architecture that allows unbounded parallelism
is, IMO, fundamentally broken from a scalability point of view.
Such behaviour indicates that the effects of such levels of
parallelism weren't really considered with the subsystem was
designed.

I make this point because of the observation I made that shrinkers
are by far the most efficient when only a single thread is running
reclaim on a particular LRU.  Reclaim parallelism on a single LRU
only made reclaim go slower and consume more CPU, and direct reclaim
is definitely causing such parallelism and slowdowns (I can point
you to the XFS mailing list posting again if you want).

I've previously stated that reducing/controlling the level of
parallelism can be just as effective at providing serious
scalability improvements as fine grained locking. So you don't
simply scoff and mock me for suggesting it like you did last time,
here's a real live example:

249a8c11 "[XFS] Move AIL pushing into it's own thread"

This commit protected tail pushing in XFS from unbounded
parallelism. The problematic workload was a MPI job that was doing
synchronised closing of 6 files per thread on a 2048 CPU machine.
It was taking an *hour and half* to complete this because of lock
contention. The above patch moved the tail pushing into it's own
thread which shifted all the multiple thread queuing back onto the
pre-existing wait queueN? where parallelism is supposed to be
controlled. The result was that the same 12,000 file close operation
took less than 9s to run. i.e. 3 orders of magnitude improvement in
run time, simply by controlling the amount of parallelism on a
single critical structure.

>From that experience, what I suggest is that we provide the same
sort of _controlled parallelism_ for the generic shrinker
infrastructure. We abstract out the lists and locks completely, and
simply provide a "can you free this object" callback to the
subsystem. I suggested we move shrinker callbacks out of direct
reclaim to the (per-node) kswapd. having thought about it a bit
more, a simpler (and probably better) alternative would be to allow
only a single direct reclaimer to act on a specific LRU at a time,
as this would allow different LRUs to be reclaimed in parallel.
Either way, this bounds the amount of parallelism the shrinker will
place on the lists and locks, thereby solving both the internal node
scalability issues and the scaling to many nodes problems.

Such an abstraction also keeps all the details of how the objects
are stored in LRUs and selected for reclaim completely hidden from
the subsystems. They don't need to care about the actual
implementation at all, just use a few simple functions (register,
unregister, list add, list remove, free this object callback). And
it doesn't prevent the internal shrinker implementation from using a
list per zone, either, as you desire.

IOWs, I think the LRUs should not be handled separately from the
shrinker as the functionality of the two is intimately tied
together.  We should be able to use a single scalable LRU/shrinker
implementation for all caches that require such functionality.

[ And once we've got such an abstraction, the LRUs could even be
moved into the slab cache itself and we could finally begin to
think about solving some of the other slab reclaim wish list
items like defragmentation again. ]

Now, this doesn't solve the mismatches between VM and subsystem
scalability models. However, if the LRU+shrinker API is so simple
and "just scales" then all my concerns about forcing knowledge of
the MM zone architecture on all subsystem evaporate because it's all
abstracted away from the subsystems. i.e. the subsystems do not have
to try to for a square peg into a round hole anymore.  And with such
a simple abstraction, I'd even (ab)use it for XFS....

Yes, it may require some changes to the way the VM handles slab
cache reclaim, but I think changing the shrinker architecture as
I've proposed results in subsystem LRUs and shrinkers that are
simpler to implement, test and maintain whilst providing better
scalability in more conditions than your proposed approach. And it
also provides a way forward to implement other desired slab reclaim
functionality, too...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
