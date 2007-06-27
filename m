Date: Wed, 27 Jun 2007 14:37:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
In-Reply-To: <1182968078.4948.30.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706271427400.31227@schroedinger.engr.sgi.com>
References: <20070625195224.21210.89898.sendpatchset@localhost>
 <Pine.LNX.4.64.0706261517050.21844@schroedinger.engr.sgi.com>
 <1182968078.4948.30.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: "Paul E. McKenney" <paulmck@us.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, 27 Jun 2007, Lee Schermerhorn wrote:

> Well, I DO need to ask Dr. RCU [Paul McK.] to take a look at the patch,
> but this is how I understand RCU to work...

RCU is not in doubt here.

> > Just by looking at the description: It 
> > cannot work. Any allocator use of a memory policy must use rcu locks 
> > otherwise the memory policy can vanish from under us while allocating a 
> > page. 
> 
> The only place we need to worry about is "get_file_policy()", and--that
> is the only place one can attempt to lookup a shared policy w/o holding
> the [user virtual] address space locked [mmap_sem] which pins the shared
> mapping of the file, so the i_mmap_writable count can't go to zero, so
> we can't attempt to free the policy.  And even then, it's only an issue
> for file descriptor accessed page cache allocs.  Lookups called from the
> fault path do have the user vas locked during the fault, so the policy
> can't go away.  But, because __page_cache_alloc() calls
> get_file_policy() to lookup the policy at the faulting page offset, it
> uses RCU on the read side, anyway.   I should probably write up the
> entire locking picture for this, huh?

The zonelist from MPOL_BIND is passed to __alloc_pages. As a result the 
RCU lock must be held over the call into the page allocator with reclaim 
etc etc. Note that the zonelist is part of the policy structure.

> > If we can make this work then RCU should be used for all policies so that 
> > we can get rid of the requirement that policies can only be modified from 
> > the task context that created it.
> 
> Yean, I think that's possible...

Great if you can me that work.

I just looked at the shmem implementation. Without RCU you must increment 
a refcount in the policy structure. That is done on every 
single allocation. Which will create yet another bouncing cacheline if you 
do concurrent allocations from the same shmem segment. Performance did not 
seem to have been such a concern for shmem policies since this was a one 
off. Again this is a hack that you are trying to generalize. There is 
trouble all over the place if you do that.

I think one prerequisite to memory policy uses like this is work out how a 
memory policy can be handled by the page allocator in such a way that

1. The use is lightweight and does not impact performance.

2. The policy that is passed to the allocators is context independent. 
   I.e. it needs to be independent of the cpuset context and the process 
   context. That would allow f.e. to store a policy and then apply it to
   readahead. AFAIK this means that the policy struct needs to contain
   the memory policy plus the cpuset and the current node.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
