Subject: Re: [PATCH 2/2] Mem Policy: Fixup Shm and Interleave Policy
	Reference Counting - V2
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0710111824290.1181@schroedinger.engr.sgi.com>
References: <20071010205837.7230.42818.sendpatchset@localhost>
	 <20071010205849.7230.81877.sendpatchset@localhost>
	 <Pine.LNX.4.64.0710101415470.32488@schroedinger.engr.sgi.com>
	 <1192129628.5036.23.camel@localhost>
	 <Pine.LNX.4.64.0710111824290.1181@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 12 Oct 2007 10:35:14 -0400
Message-Id: <1192199714.7901.20.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, ak@suse.de, gregkh@suse.de, linux-mm@kvack.org, mel@skynet.ie, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-10-11 at 18:42 -0700, Christoph Lameter wrote:
> On Thu, 11 Oct 2007, Lee Schermerhorn wrote:
> 
> > I have removed the 'RFC'.  Please review for possible merge.
> 
> I am still concerned with all this special casing which gets very 
> difficult to follow. Isnt there some way to simplify the refcount handling 
> here? It seems that the refcount fix introduced more bugs. One solution 
> would be to revert that patch instead.

I've tried to remove the special cases by making all [existing]
get_policy ops consistent and then documenting the rules on the
prototypes for any possible future ops.  The basic rule is--don't fall
back to task/sysdefault policy--let get_vma_policy() handle that.  This
is required to get the ref counting right.

If you apply the patch and look at get_vma_policy, you'll see that it
will only add a reference count for other task's policy or vma policy.
Now, the policy returned by the get_policy() op is essentially a vma
policy, but the policy op must add the ref itself 1) to prevent races
with other tasks, in the case of shared policy or 2) to be consistent
with #1 for SHM_HUGETLB segments which [currently] don't use shared
policy.

I try to avoid taking ref on current task's policy and sys default
policy because 1) it's not necessary and 2) these should be the vast
majority of the cases.  In previous discussions with yourself and Andi
[back in June/July] you agreed this was the way to go.  All my recent
changes have been an attempt to do this in the most consistent manner
possible.  

> 
> > V1 -> V2:
> > + remove include of <linux/mm.h> from mempolicy.h and use
> >   BUG_ON(), conditional on CONFIG_DEBUG_VM, in mpol_get()
> 
> Drop the BUG_ON completely? If this is a bug fix release then lets keep 
> this as minimal as possible.

I could, I guess, and just add it into my tree for testing.  But, I fear
that, in the future, someone might add some code like I removed from the
pci driver and break some other assumptions.  The bug on is only
compiled when DEBUG_VM is configured.  In that case, the overhead in
mpol_get() is the least of the additional overhead!

But if you REALLY don't like it [and I agree it's ugly, with the
explicit #ifdef], I guess I can remove it.  I'd sure like to hear other
opinions, tho'

> 
> Could you make this a series of separate patches. Each for one 
> issue?

Yeah.  I can do that.  I'm outta here for a week+ after today and won't
get to it until later in the month, as I have a lot of other things to
tie off today.

In the meantime, however, if anyone tries to apply a policy [mbind] to a
SHM_HUGETLB segment, they will BUG-out on the 2nd page fault with the
current upstream [2.6.23] code.  Kind of serious I think...


> 
> > get_vma_policy() assumes that shared policies are referenced by
> > the get_policy() vm_op, if any.  This is true for shmem_get_policy()
> > but not for shm_get_policy() when the "backing file" does not
> > support a get_policy() vm_op.  The latter is the case for SHM_HUGETLB
> > segments.  Because get_vma_policy() expects the get_policy() op to
> > have added a ref, it doesn't do so itself.  This results in 
> > premature freeing of the policy.  Add the mpol_get() to the 
> > shm_get_policy() op when the backing file doesn't support shared
> > policies.
> 
> Maybe get_vma_policy() should make no such assumption? Why is 
> get_vma_policy taking a refcount at all? The vma policies are guaranteed
> based on the process that is running. But what keeps the shared 
> policies from being freed? Isnt there an inherent race here that cannot be 
> remedied by taking a refcount?
> 
> > Further, shm_get_policy() was falling back to current task's task
> > policy if the backing file did not support get_policy() vm_op and
> > the vma policy was null.  This is not valid when get_vma_policy() is
> > called from show_numa_map() as task != current.  Also, this did
> > not match the behavior of the shmem_get_policy() vm_op which did
> > NOT fall back to task policy.  So, modify shm_get_policy() NOT to
> > fall back to current->mempolicy.
> 
> get_vma_policy() is passed a pointer to the task struct. It does *not* 
> fall back to the current tasks policy.
> 
> > Now, turns out that get_vma_policy() was not handling fallback to
> > task policy correctly when the get_policy() vm_op returns NULL.
> > Rather, it was falling back directly to system default policy.
> > So, fix get_vma_policy() to use only non-NULL policy returned from
> > the vma get_policy op and indicate that this policy does not need
> > another ref count.  
> 
> Nope. Its falling back to the task policy.

But, the get_policy() vm_op can overwrite 'pol' with a NULL return
value.  This can happen when you have a real shmem segment with default
policy == NULL/no policy.   See below:

> 
> static struct mempolicy * get_vma_policy(struct task_struct *task,
>                 struct vm_area_struct *vma, unsigned long addr)
> {
> -->     struct mempolicy *pol = task->mempolicy;
>         int shared_pol = 0;
> 
>         if (vma) {
>                 if (vma->vm_ops && vma->vm_ops->get_policy) {
>                         pol = vma->vm_ops->get_policy(vma, addr);
                          ^^^ possibly NULL for shmem w/ default policy
>                         shared_pol = 1; /* if pol non-NULL, add ref below */
>                 } else if (vma->vm_policy &&
>                                 vma->vm_policy->policy != MPOL_DEFAULT)
>                         pol = vma->vm_policy;
>         }
>         if (!pol)
>                 pol = &default_policy;
              ^^^ could get here w/ NULL shmem policy and
                 !NULL task policy.  Incorrect fallback.
>         else if (!shared_pol && pol != current->mempolicy)
>                 mpol_get(pol);  /* vma or other task's policy */
>         return pol;
> }
> 

Patch 2/2 clears all of this up.  I think.  I did test it, but could
have missed something... again.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
