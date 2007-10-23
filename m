Subject: Re: [PATCH/RFC 4/4] Mem Policy: Fixup Fallback for Default Shmem
	Policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0710121045380.8891@schroedinger.engr.sgi.com>
References: <20071012154854.8157.51441.sendpatchset@localhost>
	 <20071012154918.8157.26655.sendpatchset@localhost>
	 <Pine.LNX.4.64.0710121045380.8891@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 23 Oct 2007 13:32:31 -0400
Message-Id: <1193160751.5859.93.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, eric.whitney@hp.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

On Fri, 2007-10-12 at 10:57 -0700, Christoph Lameter wrote:
> On Fri, 12 Oct 2007, Lee Schermerhorn wrote:
> 
> > get_vma_policy() was not handling fallback to task policy correctly
> > when the get_policy() vm_op returns NULL.  The NULL overwrites
> > the 'pol' variable that was holding the fallback task mempolicy.
> > So, it was falling back directly to system default policy.
> > 
> > Fix get_vma_policy() to use only non-NULL policy returned from
> > the vma get_policy op and indicate that this policy does not need
> > another ref count.  
> 
> I still think there must be a thinko here. The function seems to be
> currently coded with the assumption that get_policy always returns a 
> policy. That policy may be the default policy?? 

My assumption is that the get_policy vm_op should either return a
[non-NULL] mempolicy corresponding to the specified address with the ref
count elevated for the caller, or NULL.  Never the default policy.
Fallback will be handled by get_vma_policy(). 

I was thinking that we HAD to do the fallback in get_vma_policy() to get
the reference counting correct for show_numa_maps().  But, based on your
other mail, I agree that we don't need to reference count another task's
task mempolicy, if we take the mmap_sem for write in do_set_mempolicy().
However, I still think that fallback is best handled in one place--for
consistency :-).
> 
> If it returns NULL then the tasks policy is applied to shmem segment. I 
> though we wanted a consistent application of policies to shmem segments? 
> Now one task or another may determine placement.

OK.  To address this, one must consider "when can the get_policy() vm
op" return a NULL?  To answer the question, first note that there are
[currently] a couple of configurations to consider:

1) direct shared mapping [MAP_SHARED] of tmpfs backed storage, or SysV
shm segments without the SHM_HUGETLB flag.  Either of these will get you
the shmem vm_ops--indirectly via the shm vm_ops in the case of a SysV
shm segment.  The shmem {set|get}_policy ops support different policies
on different ranges of the segment {actually on ranges of the tmpfs file
backing the segment} on a page granularity.  Now, before any of my
changes, if you never install a mempolicy on any range of a shmem
segment, the get_policy() op will return NULL.  This causes
get_vma_policy() fall back to task or system default policy, as
appropriate.  Always has.  

If you apply mempolicy, using mbind() or the libnuma wrapper equivalent,
to a subset of the shmem segment and then query the policy on any other
part of the segment not affected by the mempolicy, again the
get_policy() op will return NULL and again we'll fall back to task or
system default policy, as appropriate.  

2) A SysV shm segment with the SHM_HUGETLB option will use the hugetlbfs
vm_ops indirectly via the shm vm_ops.  However, the hugetlbfs vm_ops do
not support shared policy in the same sense as shmem segments.  This is
primarily because the hugetlbfs vm_ops do not specify any {set|
get}_policy() operations.  [I have a patch to address this in my "shared
policy" series that we've discussed in the past.  I hope to get back to
that series, eventually.]

When the file system backing the shm segment [hugetlbfs file, in this
case] does not support the get_policy() op, shm_get_policy() will just
return the VMA policy for the specified (vma,address).  Again, this can
be NULL.  Before the patch under discussion, shm_get_policy() would fall
back to the task policy if the vma policy was NULL.  My patch changes
this to just return NULL and let get_vma_policy() do the fallback.  This
makes it consistent with the shmem {get|set}_policy ops.

Note that I also made shm_get_policy() take a reference on any non-NULL
vma policy--again to be consistent with the shmem get_policy behavior.
And, in case you're wondering, shmem get_policy() MUST take the extra
reference therein while holding the spin lock on the shared policy
red-black tree because another task mapping the shmem segment could
change the policy at any time.

So, my "model" is:  the get_policy() op must return a non-NULL policy
with elevated reference count or NULL so that get_vma_policy() can
depend on consistent behavior; and a NULL return from the get_policy()
op means "fall back to surrounding context" just as for vma policy.

I think this is "consistent" behavior, for some definition thereof.

> 
> I still have no idea what your warrant is for being sure that the object 
> continues to exist before increasing the policy refcount in 
> get_vma_policy()? What pins the shared policy before we get the refcount?

For shmem shared policy, the rb-tree spin lock protects the policy while
we take the reference.  To be consistent with this, I require that the
shm get_policy op does the same when falling back to vma policy for shm
file systems that don't support get_policy() ops--only hugetlbfs at this
time.

We don't need to add a ref to the current task's policy, because it
can't change while we're using it--as long as we don't try to cache it
across system calls.  We don't need to add a ref to system default
policy because we never free it.  

I thought we had to ref count other task's policies, including their vma
policies, for show_numa_map() because they could change at any time.  In
your other mail, you showed how this isn't necessary because the task
calling show_numa_maps() is holding the target task's mmap_sem for read.
By patching do_set_mempolicy() to take the mmap_sem [for write!] we can
close this window w/o an extra reference.  However, there may be an
issue with this.  Read further.

The current task's vma policies, although subject to change by other
threads/tasks sharing the mm_struct, are protected by the mmap_sem()
while we take the reference, as you've pointed out in other mail.  Why
take the extra ref?  Back in June/July, we [you, Andi, myself] thought
that this was required for allocating under bind policy with the custom
zonelist because the allocation could sleep.   Now, if we hold the
mmap_sem over the allocation, we can probably dispense with the extra
reference on [non-shared] vma policies as well.

However, we still need to unref shared policies which one could consider
a subclass of vma policies.  With these recent patches and the prior
mempolicy ref count patches, we could assume that all policies except
the system default and the current task's mempolicy needed unref upon
return from get_vma_policy().  If we don't take an extra ref on other
task's mempolicy and non-shared vma policy, then we need to be able to
differentiate truly shared policies when we're done with them so that we
can unref them.

How about a funky flag in the higher order policy bits, like the
MPOL_CONTEXT flag in my cpuset-independent interleave patch, to indicate
shmem-style shared policy.  If the reasoning about mmap_sem above is
correct, and we only need to hold refs on shmem shared policy, we can
dispense with all of this extra reference counting and only unref the
shared policies.

Thoughts?


> Some more concerns below:
> 
> > Index: Linux/mm/mempolicy.c
> > ===================================================================
> > --- Linux.orig/mm/mempolicy.c	2007-10-12 10:50:05.000000000 -0400
> > +++ Linux/mm/mempolicy.c	2007-10-12 10:52:46.000000000 -0400
> > @@ -1112,19 +1112,25 @@ static struct mempolicy * get_vma_policy
> >  		struct vm_area_struct *vma, unsigned long addr)
> >  {
> >  	struct mempolicy *pol = task->mempolicy;
> > -	int shared_pol = 0;
> > +	int pol_needs_ref = (task != current);
> 
> If get_vma_policy is called from the numa_maps handler then we have taken 
> a refcount on the task struct. 
> 
> So this should be
> 	int pol_needs_ref = 0;

If we can pare down the extra refs to just shmem shared policy, I agree.
Otherwise, I'd like to keep the behavior such that only the current
task's policy and system default policy don't get extra refs.  This will
keep the checks fairly simple on unref at the expense of an unneeded
extra ref/unref for other task's policy--i.e., numa_maps which shouldn't
be a path that we need to optimize, I think.

> 
> >  
> >  	if (vma) {
> >  		if (vma->vm_ops && vma->vm_ops->get_policy) {
> > -			pol = vma->vm_ops->get_policy(vma, addr);
> > -			shared_pol = 1;	/* if pol non-NULL, add ref below */
> > +			struct mempolicy *vpol = vma->vm_ops->get_policy(vma,
> > +									addr);
> > +			if (vpol) {
> > +				pol = vpol;
> > +				pol_needs_ref = 0; /* get_policy() added ref */
> > +			}
> >  		} else if (vma->vm_policy &&
> > -				vma->vm_policy->policy != MPOL_DEFAULT)
> > +				vma->vm_policy->policy != MPOL_DEFAULT) {
> >  			pol = vma->vm_policy;
> > +			pol_needs_ref++;
> 
> Why do we need a ref here for a vma policy? The policy is pinned through 
> the ref to the task structure.

You mean the mmap_sem, right?  If this is the case, we apparently missed
this point when we discussed it back in June/July.  This was the one of
the main points of that discussion.

> 
> > +		}
> >  	}
> >  	if (!pol)
> >  		pol = &default_policy;
> > -	else if (!shared_pol && pol != current->mempolicy)
> > +	else if (pol_needs_ref)
> >  		mpol_get(pol);	/* vma or other task's policy */
> >  	return pol;
> 
> The mpol_get() here looks wrong. get_vma_policy determines the 
> current policy. The policy must already be pinned by increasing the 
> refcount or use in a certain task before get_vma_policy is ever called.

I see what you're saying.  A quick look through the cscope indicates
that the mmap_sem is held over faults, even when allocation sleeps.  If
this is true, again, we only need extra refs on shmem style shared
policies.  I'll rework the patches on that assumption, including backing
out some of the recent extra reference counting, to see what they look
like.  I'll also document the mempolicy stability assumptions on which
the reworked code is based.

Later,
Lee
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
