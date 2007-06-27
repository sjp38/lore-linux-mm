Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0706271427400.31227@schroedinger.engr.sgi.com>
References: <20070625195224.21210.89898.sendpatchset@localhost>
	 <Pine.LNX.4.64.0706261517050.21844@schroedinger.engr.sgi.com>
	 <1182968078.4948.30.camel@localhost>
	 <Pine.LNX.4.64.0706271427400.31227@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 27 Jun 2007 19:36:47 -0400
Message-Id: <1182987407.7199.61.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "Paul E. McKenney" <paulmck@us.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, 2007-06-27 at 14:37 -0700, Christoph Lameter wrote:
> On Wed, 27 Jun 2007, Lee Schermerhorn wrote:
> 
> > Well, I DO need to ask Dr. RCU [Paul McK.] to take a look at the patch,
> > but this is how I understand RCU to work...
> 
> RCU is not in doubt here.
> 
> > > Just by looking at the description: It 
> > > cannot work. Any allocator use of a memory policy must use rcu locks 
> > > otherwise the memory policy can vanish from under us while allocating a 
> > > page. 
> > 
> > The only place we need to worry about is "get_file_policy()", and--that
> > is the only place one can attempt to lookup a shared policy w/o holding
> > the [user virtual] address space locked [mmap_sem] which pins the shared
> > mapping of the file, so the i_mmap_writable count can't go to zero, so
> > we can't attempt to free the policy.  And even then, it's only an issue
> > for file descriptor accessed page cache allocs.  Lookups called from the
> > fault path do have the user vas locked during the fault, so the policy
> > can't go away.  But, because __page_cache_alloc() calls
> > get_file_policy() to lookup the policy at the faulting page offset, it
> > uses RCU on the read side, anyway.   I should probably write up the
> > entire locking picture for this, huh?
> 
> The zonelist from MPOL_BIND is passed to __alloc_pages. As a result the 
> RCU lock must be held over the call into the page allocator with reclaim 
> etc etc. Note that the zonelist is part of the policy structure.

OK, I see your issue now.   Policies that are looked up in a shared
policy are automatically reference counted on lookup.  But, as I've seen
discussed in the other policy reference counting thread, I'm not
decrementing the count.  I think this will be easy to add into my
factored "alloc_page_pol"--the mpol_free(), that is.  However, it will
require that we actually take a reference on all the other policies when
we acquire them for allocation, so that we can free the reference when
the allocation completes.  Something you'd like to avoid, but I don't
see how we can for non-atomic allocations.  Might be able to special
case the system default policy and not reference count that, as it can
never go away--for now, anyway...

> 
> > > If we can make this work then RCU should be used for all policies so that 
> > > we can get rid of the requirement that policies can only be modified from 
> > > the task context that created it.
> > 
> > Yean, I think that's possible...
> 
> Great if you can me that work.

I was only considering the replacement of the pointer.  The indefinite
sleep in the allocation is a killer, tho'.

> 
> I just looked at the shmem implementation. Without RCU you must increment 
> a refcount in the policy structure. That is done on every 
> single allocation. Which will create yet another bouncing cacheline if you 
> do concurrent allocations from the same shmem segment. Performance did not 
> seem to have been such a concern for shmem policies since this was a one 
> off. Again this is a hack that you are trying to generalize. There is 
> trouble all over the place if you do that.

As I mentioned, the increment is already there and always was.  Just no
decrement.  

And I don't think that referencing counting a shared object is a hack.
It's standard procedure.  If it weren't for the possiblity of sleeping
indefinitely in allocation/reclaim [and reclaim delays are REALLY
indefinite!], you could use a deferred free, like RCU.  But, the only
time you know that the allocation is finished is when you return from
the alloc call, so you need to release the reference there.

As far as bouncing cache lines during an allocation:  for shared object
policy, either this [bouncing] dies out when all pages of the object are
finally allocated--i.e., it's start-up overhead, or we're constantly
recycling pages because they don't all fit in memory.  In the latter
case, the cache line bounce will be small compared to the reclaim and
rereading of the page from the file system or swap [shmem case].
Again, we may be able to special case the system default policy, and
task policy is private to a task/thread, so I don't think that's too
much of a problem, right?

> 
> I think one prerequisite to memory policy uses like this is work out how a 
> memory policy can be handled by the page allocator in such a way that
> 
> 1. The use is lightweight and does not impact performance.

I agree that use of memory policies should have a net decrease in
performance.  However, nothing is for free.  It's a tradeoff.  If you
don't need policies or if they hurt worse than they help, don't use
them.  No performance impact.  If locality matters and policies help
more than they cost, use them.  

> 
> 2. The policy that is passed to the allocators is context independent. 
>    I.e. it needs to be independent of the cpuset context and the process 
>    context. That would allow f.e. to store a policy and then apply it to
>    readahead.  AFAIK this means that the policy struct needs to contain
>    the memory policy plus the cpuset and the current node.

Maybe.  or maybe something different.  Laudable goals, anyway.  Let's
discuss in the NUMA BOF.

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
