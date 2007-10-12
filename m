Date: Fri, 12 Oct 2007 10:57:36 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 4/4] Mem Policy: Fixup Fallback for Default Shmem
 Policy
In-Reply-To: <20071012154918.8157.26655.sendpatchset@localhost>
Message-ID: <Pine.LNX.4.64.0710121045380.8891@schroedinger.engr.sgi.com>
References: <20071012154854.8157.51441.sendpatchset@localhost>
 <20071012154918.8157.26655.sendpatchset@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, eric.whitney@hp.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

On Fri, 12 Oct 2007, Lee Schermerhorn wrote:

> get_vma_policy() was not handling fallback to task policy correctly
> when the get_policy() vm_op returns NULL.  The NULL overwrites
> the 'pol' variable that was holding the fallback task mempolicy.
> So, it was falling back directly to system default policy.
> 
> Fix get_vma_policy() to use only non-NULL policy returned from
> the vma get_policy op and indicate that this policy does not need
> another ref count.  

I still think there must be a thinko here. The function seems to be
currently coded with the assumption that get_policy always returns a 
policy. That policy may be the default policy?? 

If it returns NULL then the tasks policy is applied to shmem segment. I 
though we wanted a consistent application of policies to shmem segments? 
Now one task or another may determine placement.

I still have no idea what your warrant is for being sure that the object 
continues to exist before increasing the policy refcount in 
get_vma_policy()? What pins the shared policy before we get the refcount?

Some more concerns below:

> Index: Linux/mm/mempolicy.c
> ===================================================================
> --- Linux.orig/mm/mempolicy.c	2007-10-12 10:50:05.000000000 -0400
> +++ Linux/mm/mempolicy.c	2007-10-12 10:52:46.000000000 -0400
> @@ -1112,19 +1112,25 @@ static struct mempolicy * get_vma_policy
>  		struct vm_area_struct *vma, unsigned long addr)
>  {
>  	struct mempolicy *pol = task->mempolicy;
> -	int shared_pol = 0;
> +	int pol_needs_ref = (task != current);

If get_vma_policy is called from the numa_maps handler then we have taken 
a refcount on the task struct. 

So this should be
	int pol_needs_ref = 0;

>  
>  	if (vma) {
>  		if (vma->vm_ops && vma->vm_ops->get_policy) {
> -			pol = vma->vm_ops->get_policy(vma, addr);
> -			shared_pol = 1;	/* if pol non-NULL, add ref below */
> +			struct mempolicy *vpol = vma->vm_ops->get_policy(vma,
> +									addr);
> +			if (vpol) {
> +				pol = vpol;
> +				pol_needs_ref = 0; /* get_policy() added ref */
> +			}
>  		} else if (vma->vm_policy &&
> -				vma->vm_policy->policy != MPOL_DEFAULT)
> +				vma->vm_policy->policy != MPOL_DEFAULT) {
>  			pol = vma->vm_policy;
> +			pol_needs_ref++;

Why do we need a ref here for a vma policy? The policy is pinned through 
the ref to the task structure.

> +		}
>  	}
>  	if (!pol)
>  		pol = &default_policy;
> -	else if (!shared_pol && pol != current->mempolicy)
> +	else if (pol_needs_ref)
>  		mpol_get(pol);	/* vma or other task's policy */
>  	return pol;

The mpol_get() here looks wrong. get_vma_policy determines the 
current policy. The policy must already be pinned by increasing the 
refcount or use in a certain task before get_vma_policy is ever called.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
