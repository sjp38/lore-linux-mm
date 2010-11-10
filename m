Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BBF446B004A
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 01:32:40 -0500 (EST)
Date: Wed, 10 Nov 2010 17:32:29 +1100
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: [patch] mm: vmscan implement per-zone shrinkers
Message-ID: <20101110063229.GA5700@amd>
References: <20101109123246.GA11477@amd>
 <20101110051813.GS2715@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101110051813.GS2715@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Nick Piggin <npiggin@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 10, 2010 at 04:18:13PM +1100, Dave Chinner wrote:
> On Tue, Nov 09, 2010 at 11:32:46PM +1100, Nick Piggin wrote:
> > Hi,
> > 
> > I'm doing some works that require per-zone shrinkers, I'd like to get
> > the vmscan part signed off and merged by interested mm people, please.
> > 
> 
> There are still plenty of unresolved issues with this general
> approach to scaling object caches that I'd like to see sorted out
> before we merge any significant shrinker API changes. Some things of

No changes, it just adds new APIs.


> the top of my head:
> 
> 	- how to solve impendence mismatches between VM scalability
> 	  techniques and subsystem scalabilty techniques that result
> 	  in shrinker cross-muliplication explosions. e.g. XFS
> 	  tracks reclaimable inodes in per-allocation group trees,
> 	  so we'd get AG x per-zone LRU trees using this shrinker
> 	  method.  Think of the overhead on a 1000AG filesystem on a
> 	  1000 node machine with 3-5 zones per node....

That's an interesting question, but no reason to hold anything up.
It's up to the subsystem to handle it, or if they can't handle it
sanely, you can elect to get no different behaviour than today.

I would say that per-zone is important for the above case, because it
shrinks properly, based on memory pressure and pressure settings (eg.
zone reclaim), and also obviously so that the reclaim threads are
scanning node-local-memory so it doesn't have to pull objects from
all over the interconnect.

With 1000 nodes and 1000AG filesystem, probably NxM is overkill, but
there is no reason you couldn't have one LRU per X AGs.

All this is obviously implementation details -- pagecache reclaim does
not want to know about this, so it doesn't affect the API.


> 	- changes from global LRU behaviour to something that is not
> 	  at all global - effect on workloads that depend on large
> 	  scale caches that span multiple nodes is largely unknown.
> 	  It will change IO patterns and affect system balance and
> 	  performance of the system. How do we
> 	  test/categorise/understand these problems and address such
> 	  balance issues?

You've brought this up before several times and I've answered it.

The default configuration basically doesn't change much. Caches are
allowed to fill up all zones and nodes, exactly the same as today.

On the reclaim side, when you have a global shortage, it will evenly
shrink objects from all zones, so it still approximates LRU behaviour
because number of objects far exceeds number of zones. This is exactly
how per-zone pagecache scanning works too.


> 	- your use of this shrinker architecture for VFS
> 	  inode/dentry cache scalability requires adding lists and
> 	  locks to the MM struct zone for each object cache type
> 	  (inode, dentry, etc). As such, it is not a generic
> 	  solution because it cannot be used for per-instance caches
> 	  like the per-mount inode caches XFS uses.

Of course it doesn't. You can use kmalloc.

 
> 	  i.e. nothing can actually use this infrastructure change
> 	  without tying itself directly into the VM implementation,
> 	  and even then not every existing shrinker can use this
> 	  method of scaling. i.e. some level of abstraction from the
> 	  VM implementation is needed in the shrinker API.

"zones" is the abstraction. The thing which all allocation and
management of memory is based on, everywhere you do any allocations
in the kernel. A *shrinker* implementation, a thing which is called
in response to memory shortage in a given zone, has to know about
zones. End of story. "Tied to the memory management implementation"
is true to the extent that it is part of the memory management
implementation.
 

> 	- it has been pointed out that slab caches are generally
> 	  allocated out of a single zone per node, so per-zone
> 	  shrinker granularity seems unnecessary.

No they are not, that's just total FUD. Where was that "pointed out"?

Slabs are generally allocated from every zone except for highmem and
movable, and moreover there is nothing to prevent a shrinker
implementation from needing to shrink highmem and movable pages as
well.


> 	- doesn't solve the unbound direct reclaim shrinker
> 	  parallelism that is already causing excessive LRU lock
> 	  contention on 8p single node systems. While
> 	  per-LRU/per-node solves the larger scalability issue, it
> 	  doesn't address scalability within the node. This is soon
> 	  going to be 24p per node and that's more than enough to
> 	  cause severe problems with a single lock and list...

It doesn't aim to solve that. It doesn't prevent that from being
solved either (and improving parallelism in a subsystem generally,
you know, helps with lock contention due to lots of threads in there,
right?).


> > [And before anybody else kindly suggests per-node shrinkers, please go
> > back and read all the discussion about this first.]
> 
> I don't care for any particular solution, but I want these issues
> resolved before we make any move forward. per-node abstractions is
> just one possible way that has been suggested to address some of
> these issues, so it shouldn't be dismissed out of hand like this.

Well if you listen to my follow ups to the FUD that keeps appearing,
maybe we can "move forward".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
