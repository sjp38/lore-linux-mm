Subject: Re: [NUMA] Fix memory policy refcounting
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0710291317060.1379@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0710261638020.29369@schroedinger.engr.sgi.com>
	 <1193672929.5035.69.camel@localhost>
	 <Pine.LNX.4.64.0710291317060.1379@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 29 Oct 2007 17:34:06 -0400
Message-Id: <1193693646.6244.51.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: David Rientjes <rientjes@google.com>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-10-29 at 13:24 -0700, Christoph Lameter wrote:
> On Mon, 29 Oct 2007, Lee Schermerhorn wrote:
> 
> > > 1. Reference counts were taken in get_vma_policy without necessarily
> > >    holding another lock that guaranteed the existence of the object
> > >    on which the reference count was taken.
> > 
> > Yes, this was true for the show_numa_maps() case, as we've discussed.  I
> > agree we need to take the mmap_sem for write in do_set_mempolicy() as we
> > do in do_mbind().
> 
> Yeah it seems that we were safe for shared policies since we took the 
> refcount twice?

I still don't see where we took the ref twice on shared policies.  My
comment was wrong.  It should have said "avoid extra ref" which is what
the code [in get_vma_policy()] does now, contradicting the comment.


> 
> > > 2. Adding a flag to all functions that can potentially take a refcount
> > >    on a memory. That flag is set if the refcount was taken. The code
> > >    using the memory policy can then just free the refcount if it was
> > >    actually taken.
> > 
> > This does add some additional code in the alloc path and adds an
> > additional arg to a lot of functions that I think we can remove by
> > marking shared policies as such and only derefing those.  
> 
> The get_policy function and friends may not only return shared policies 
> but also task etc policies.

Right, but they don't [don't need to] add extra ref's like the shared
policies do.  So, if we can id a shared policy, we unref only those.
I'll send out my RFC probably tomorrow am.  

> 
> > Yeah, yeah, yeah.  But I consider that to be cpusets' fault and not
> > shared memory policy.  I still have use for the latter.  We need to find
> > a way to accomodate all of our requirements, even if it means
> > documenting that shared memory policy must be used very carefully with
> > cpusets--or not at all with dynamically changing cpusets.  I can
> > certainly live with that.
> 
> There is no reason that this issue should exist. We can have your shared 
> policies with proper enforcement that no bad things happen if we get rid 
> of get_policy etc and instead use the vma policy pointer to point to the 
> shared policy. Take a refcount for each vma as it is setup to point to a 
> shared policy and you will not have to take the refcount in the hot paths.

We support different policies on different ranges of a shared memory
segment.  In the task which installs this policy, we split the vmas, but
any other tasks which already have the segment attached or which
subsequently attach don't split the vmas along policy bondaries.  This
also makes numa_maps lie when we have multiple subrange policies.

My run of your page fault test with and without the ref count patches
showed no add'l overhead for reference counting.  Of course, I can't go
up the number of nodes you can.  You could try it on one of your
platform with a high node count to see.  

> 
> > > The removal of shared policy support would result in the refcount issues
> > > going away and code would be much simpler. Semantics would be consistent in
> > > that memory policies only apply to a single process. Sharing of memory policies
> > > would only occur in a controlled way that does not require extra refcounting
> > > for the use of a policy.
> > 
> > Yes, and we'd loose control over placement of shared pages except by
> > hacking our task policy and prefaulting, or requiring every program that
> > attaches to be aware of the numa policy of the overall application.  I
> > find this as objectionable as you find shared policies.  
> 
> That is not true.

???

> 
> > > We have already vma policy pointers that are currently unused for shmem areas
> > > and could replicate shared policies by setting these pointers in each vma that
> > > is pointing to a shmem area. 
> > 
> > Doesn't work for me. :(
> 
> Why not? Point them to the shared policy and add a refcount and things 
> would be much easier.

I'd really like to avoid having to map multiple vmas when I attach a shm
seg with different policies on different ranges, and  fix up all
existing tasks attached to a shmem when installing policies on ranges of
the segment.   Having the share policy lookup add a ref while holding
the shared policy spinlock handles this fine now.

> 
> > > Changing a shared policy would then require
> > > iterating over all processes using the policy using the reverse maps. At that
> > > point cpuset constraints etc could be considered and eventually a policy change
> > > could even be rejected on the ground that a consistent change is not possible
> > > given the other constraints of the shmem area.
> > 
> > Policy remapping isn't already complex enough for you, huh? :-)
> 
> Policy remapping is one thing since we can correct the policy. Shared 
> policies cannot be correct if applied to multiple cpuset context. 

I agree.  Especially if the attaching task's aren't cooperating, and
when the cpuset is reconfigured or tasks moved.  I don't need it to work
in these cases. 


> The 
> looping over reverse maps is a pretty standard way of doing things which 
> would allow us to detect bad policies at the time they are created and not 
> later.

I guess we could also do the rmap walk at attach time and reject the
attach if the shmem policy is not valid in the attaching task's cpuset?
And when we try to move the task to a new cpuset, reject the move if any
policy would be invalid in the new cpuset?  

Maybe better to just document the constraints and the behavior that one
might expect if they violate the constraints.  For example, a
default/local policy would be valid in all cpusets.  My proposal for
"cpuset-independent interleave policy" [which is semantically the same
as David's "interleave over all allowed", altho' we propose different
syscall arg values to specify it, and David's method requires remapping
the interleave nodemask, I think, where mine doesn't--details] would be
valid in any cpuset.  In these cases, page placement might be different
than for a set of tasks in a single, static cpuset attached to shmem
segments, which might be "surprising" behavior for some tasks, but we
could document that.

Any policy that explicitly specifies nodes that are not valid in all
cpusets containing tasks sharing a shmem segment would be problematic
and should be avoided.  A possible solution to this is to do the
cpuset-relative to physical nodeid translation at allocation time, but I
don't think you want that in the allocation path!

> 
> > >  		}
> > >  	}
> > > -	mpol_free(mpol);	/* unref if mpol !NULL */
> > > +	if (ref)
> > > +		mpol_free(mpol);
> > This shouldn't be necessary if huge_zonelist only returns a non-NULL
> > mpol if the unref is required, as I had done.  mpol_free() on a NULL
> > mpol is a no-op, as the comment was intended to convey.  You could drop
> > the extra ref argument to huge_zonelist--not that this should be much of
> > a fast path.
> 
> True.
> 
> > > -	mpol_to_str(buffer, sizeof(buffer), pol);
> > > -	/*
> > > -	 * unref shared or other task's mempolicy
> > > -	 */
> > > -	if (pol != &default_policy && pol != current->mempolicy)
> > > -		__mpol_free(pol);
> > > +	mpol = get_vma_policy(priv->task, vma, vma->vm_start, &ref);
> > > +	mpol_to_str(buffer, sizeof(buffer), mpol);
> > > +	if (ref)
> > > +		mpol_free(mpol);
> > If we really want to add the ref argument to get_vma_policy(), we could
> > avoid bringing it down this deeply by requiring that all get_policy()
> > vm_ops add the extra ref [these are only used for shared memory policy
> > now] and set ref !0 when get_policy() returns a non-null policy.  This
> > would be an alternative to marking shared policies as such.
> 
> Please be aware that refcounting in the hot paths is a bad thing to do. 
> We are potentially bouncing a cacheline. I'd rather get rid of that 
> completely.

I understand the goal.  Sometimes one must ref count for adequate
protection to get the semantics/features one wants--that I want, anyway.
Again, my tests showed no measureable overhead.  [Yes, lots of little
"no measureable overhead" changes can add up...].

Anyway, let's keep chipping away.  I'll send out my series for RFC and
then do some more measurements.

Later,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
