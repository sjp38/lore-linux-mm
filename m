Date: Wed, 24 Oct 2007 06:09:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 4/4] Mem Policy: Fixup Fallback for Default Shmem
 Policy
In-Reply-To: <1193160751.5859.93.camel@localhost>
Message-ID: <Pine.LNX.4.64.0710240601590.24201@schroedinger.engr.sgi.com>
References: <20071012154854.8157.51441.sendpatchset@localhost>
 <20071012154918.8157.26655.sendpatchset@localhost>
 <Pine.LNX.4.64.0710121045380.8891@schroedinger.engr.sgi.com>
 <1193160751.5859.93.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, eric.whitney@hp.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

On Tue, 23 Oct 2007, Lee Schermerhorn wrote:

> > I still think there must be a thinko here. The function seems to be
> > currently coded with the assumption that get_policy always returns a 
> > policy. That policy may be the default policy?? 
> 
> My assumption is that the get_policy vm_op should either return a
> [non-NULL] mempolicy corresponding to the specified address with the ref
> count elevated for the caller, or NULL.  Never the default policy.
> Fallback will be handled by get_vma_policy(). 

Ok.

> So, my "model" is:  the get_policy() op must return a non-NULL policy
> with elevated reference count or NULL so that get_vma_policy() can
> depend on consistent behavior; and a NULL return from the get_policy()
> op means "fall back to surrounding context" just as for vma policy.
> 
> I think this is "consistent" behavior, for some definition thereof.

I still have concerns about ting the refcount. The get_policy() method may 
take a refcount if it can ensure that the object is not vanishing from 
under us. But I would think that a refcount needs to be taken when the 
possibility is created for a certain vma to reference a policy via
get_vma_policy and not when get_vma_policy itself runs.

> > I still have no idea what your warrant is for being sure that the object 
> > continues to exist before increasing the policy refcount in 
> > get_vma_policy()? What pins the shared policy before we get the refcount?
> 
> For shmem shared policy, the rb-tree spin lock protects the policy while
> we take the reference.  To be consistent with this, I require that the
> shm get_policy op does the same when falling back to vma policy for shm
> file systems that don't support get_policy() ops--only hugetlbfs at this
> time.

The rb tree lock is always taken when we run get_vma_policy()? You mean 
you can take the lock while the get_policy is run? This will make 
get_vma_policy even heavier?

> The current task's vma policies, although subject to change by other
> threads/tasks sharing the mm_struct, are protected by the mmap_sem()
> while we take the reference, as you've pointed out in other mail.  Why
> take the extra ref?  Back in June/July, we [you, Andi, myself] thought
> that this was required for allocating under bind policy with the custom
> zonelist because the allocation could sleep.   Now, if we hold the
> mmap_sem over the allocation, we can probably dispense with the extra
> reference on [non-shared] vma policies as well.

Right.
 
> However, we still need to unref shared policies which one could consider
> a subclass of vma policies.  With these recent patches and the prior
> mempolicy ref count patches, we could assume that all policies except
> the system default and the current task's mempolicy needed unref upon
> return from get_vma_policy().  If we don't take an extra ref on other
> task's mempolicy and non-shared vma policy, then we need to be able to
> differentiate truly shared policies when we're done with them so that we
> can unref them.

If you take the reference when a vma is established then you can avoid
dropping the refcount on the hot paths?

> How about a funky flag in the higher order policy bits, like the
> MPOL_CONTEXT flag in my cpuset-independent interleave patch, to indicate
> shmem-style shared policy.  If the reasoning about mmap_sem above is
> correct, and we only need to hold refs on shmem shared policy, we can
> dispense with all of this extra reference counting and only unref the
> shared policies.

Maybe. Would need to be further fleshed out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
