Date: Mon, 29 Oct 2007 14:43:42 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [NUMA] Fix memory policy refcounting
In-Reply-To: <1193693646.6244.51.camel@localhost>
Message-ID: <Pine.LNX.4.64.0710291438470.3475@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0710261638020.29369@schroedinger.engr.sgi.com>
 <1193672929.5035.69.camel@localhost>  <Pine.LNX.4.64.0710291317060.1379@schroedinger.engr.sgi.com>
 <1193693646.6244.51.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: David Rientjes <rientjes@google.com>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Oct 2007, Lee Schermerhorn wrote:

> > > Yeah, yeah, yeah.  But I consider that to be cpusets' fault and not
> > > shared memory policy.  I still have use for the latter.  We need to find
> > > a way to accomodate all of our requirements, even if it means
> > > documenting that shared memory policy must be used very carefully with
> > > cpusets--or not at all with dynamically changing cpusets.  I can
> > > certainly live with that.
> > 
> > There is no reason that this issue should exist. We can have your shared 
> > policies with proper enforcement that no bad things happen if we get rid 
> > of get_policy etc and instead use the vma policy pointer to point to the 
> > shared policy. Take a refcount for each vma as it is setup to point to a 
> > shared policy and you will not have to take the refcount in the hot paths.
> 
> We support different policies on different ranges of a shared memory
> segment.  In the task which installs this policy, we split the vmas, but
> any other tasks which already have the segment attached or which
> subsequently attach don't split the vmas along policy bondaries.  This
> also makes numa_maps lie when we have multiple subrange policies.

Which would also be fixed if we would split the vmas properly.
 
> > > > We have already vma policy pointers that are currently unused for shmem areas
> > > > and could replicate shared policies by setting these pointers in each vma that
> > > > is pointing to a shmem area. 
> > > 
> > > Doesn't work for me. :(
> > 
> > Why not? Point them to the shared policy and add a refcount and things 
> > would be much easier.
> 
> I'd really like to avoid having to map multiple vmas when I attach a shm
> seg with different policies on different ranges, and  fix up all
> existing tasks attached to a shmem when installing policies on ranges of
> the segment.   Having the share policy lookup add a ref while holding
> the shared policy spinlock handles this fine now.

Why? Attaching a policy is a rare thing right?

> > The 
> > looping over reverse maps is a pretty standard way of doing things which 
> > would allow us to detect bad policies at the time they are created and not 
> > later.
> 
> I guess we could also do the rmap walk at attach time and reject the
> attach if the shmem policy is not valid in the attaching task's cpuset?
> And when we try to move the task to a new cpuset, reject the move if any
> policy would be invalid in the new cpuset?  

Yes reject or do some corrective action. At least be aware of the 
situation.

> Any policy that explicitly specifies nodes that are not valid in all
> cpusets containing tasks sharing a shmem segment would be problematic
> and should be avoided.  A possible solution to this is to do the
> cpuset-relative to physical nodeid translation at allocation time, but I
> don't think you want that in the allocation path!

The problem is that it can create subtle issues right now. If we would 
handle it through vma policy pointers then we would be able to detect many 
things and the refcount issues would go away.

> > Please be aware that refcounting in the hot paths is a bad thing to do. 
> > We are potentially bouncing a cacheline. I'd rather get rid of that 
> > completely.
> 
> I understand the goal.  Sometimes one must ref count for adequate
> protection to get the semantics/features one wants--that I want, anyway.
> Again, my tests showed no measureable overhead.  [Yes, lots of little
> "no measureable overhead" changes can add up...].

The refcounting in hot paths causes a lot of issues here not only scaling. 
Removing them would be the smart thing to do. The logic to update vmas, 
loop over rmaps etc etc all exists. The code would likely be minimal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
