Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 7A2866B005C
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 09:55:36 -0400 (EDT)
Date: Tue, 12 Jun 2012 14:55:29 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/6] mempolicy: remove all mempolicy sharing
Message-ID: <20120612135529.GA20467@suse.de>
References: <1339406250-10169-1-git-send-email-kosaki.motohiro@gmail.com>
 <1339406250-10169-3-git-send-email-kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1339406250-10169-3-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Christoph Lameter <cl@linux.com>, stable@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jun 11, 2012 at 05:17:26AM -0400, kosaki.motohiro@gmail.com wrote:
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> Dave Jones' system call fuzz testing tool "trinity" triggered the following
> bug error with slab debugging enabled
> 
> [ 7613.229315] =============================================================================
> [ 7613.229955] BUG numa_policy (Not tainted): Poison overwritten
> [ 7613.230560] -----------------------------------------------------------------------------
> [ 7613.230560]
> [ 7613.231834] INFO: 0xffff880146498250-0xffff880146498250. First byte 0x6a instead of 0x6b
> [ 7613.232518] INFO: Allocated in mpol_new+0xa3/0x140 age=46310 cpu=6 pid=32154
> [ 7613.233188]  __slab_alloc+0x3d3/0x445
> [ 7613.233877]  kmem_cache_alloc+0x29d/0x2b0
> [ 7613.234564]  mpol_new+0xa3/0x140
> [ 7613.235236]  sys_mbind+0x142/0x620
> [ 7613.235929]  system_call_fastpath+0x16/0x1b
> [ 7613.236640] INFO: Freed in __mpol_put+0x27/0x30 age=46268 cpu=6 pid=32154
> [ 7613.237354]  __slab_free+0x2e/0x1de
> [ 7613.238080]  kmem_cache_free+0x25a/0x260
> [ 7613.238799]  __mpol_put+0x27/0x30
> [ 7613.239515]  remove_vma+0x68/0x90
> [ 7613.240223]  exit_mmap+0x118/0x140
> [ 7613.240939]  mmput+0x73/0x110
> [ 7613.241651]  exit_mm+0x108/0x130
> [ 7613.242367]  do_exit+0x162/0xb90
> [ 7613.243074]  do_group_exit+0x4f/0xc0
> [ 7613.243790]  sys_exit_group+0x17/0x20
> [ 7613.244507]  system_call_fastpath+0x16/0x1b
> [ 7613.245212] INFO: Slab 0xffffea0005192600 objects=27 used=27 fp=0x          (null) flags=0x20000000004080
> [ 7613.246000] INFO: Object 0xffff880146498250 @offset=592 fp=0xffff88014649b9d0
> 
> The problem was created by a reference count imbalance. Example, In following case,
> mbind(addr, len) try to replace mempolicies of vma1 and vma2 and then they will
> be share the same mempolicy, and the new mempolicy has MPOL_F_SHARED flag.
> 
>   +-------------------+-------------------+
>   |     vma1          |     vma2(shmem)   |
>   +-------------------+-------------------+
>   |                                       |
>  addr                                 addr+len
> 

Your example is missing some important detail. When I was looking at this
I thought of the same scenario because initially I thought this might be
the problem Dave's test case was hitting. Obviously I then proceeded to
mess up anyway so take this with a grain of salt but why is this particular
situation not prevented by vma_merge? is_mergeable_vma() should have spotted
that the vm_files differed and mbind_range() should not have tried
sharing them.

> Look at alloc_pages_vma(), it uses get_vma_policy() and mpol_cond_put() pair
> for maintaining mempolicy refcount. The current rule is, get_vma_policy() does
> NOT increase a refcount if the policy is not attached shmem vma and mpol_cond_put()
> DOES decrease a refcount if mpol has MPOL_F_SHARED.
> 

The rules about refcounting are indeed annoying. It would be a lot easier
to understand if the reference counting was unconditional but then every
page allocation in a large VMA would also bounce the cacheline storing
the count which would just generate a new bug later.

> In above case, vma1 is not shmem vma and vma->policy has MPOL_F_SHARED! then,
> get_vma_policy() doesn't increase a refcount and mpol_cond_put() decrease a 
> refcount whenever alloc_page_vma() is called.
> 
> The bug was introduced by commit 52cd3b0740 (mempolicy: rework mempolicy Reference
> Counting) at 4 years ago.
> 
> More unfortunately mempolicy has one another serious broken. Currently,
> mempolicy rebind logic (it is called from cpuset rebinding) ignore a refcount
> of mempolicy and override it forcibly. Thus, any mempolicy sharing may
> cause mempolicy corruption. The bug was introduced by commit 68860ec10b
> (cpusets: automatic numa mempolicy rebinding) at 7 years ago.
> 

I suspect these bugs were not noticed because the shmem policies are
typically large and very long lived without much use of mbind() but
that's not an excuse.

> To disable policy sharing solves user visible breakage and this patch does it.
> Maybe, we need to rewrite MPOL_F_SHARED and mempolicy rebinding code and aim
> to proper cow logic eventually, but I think this is good first step.
> 
> Reported-by: Dave Jones <davej@redhat.com>,
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Christoph Lameter <cl@linux.com>,
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: <stable@vger.kernel.org>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/mempolicy.c |   49 ++++++++++++++++++++++++++++++++++++-------------
>  1 files changed, 36 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 0a60def..9505cb9 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -607,24 +607,38 @@ check_range(struct mm_struct *mm, unsigned long start, unsigned long end,
>  	return first;
>  }
>  
> -/* Apply policy to a single VMA */
> -static int policy_vma(struct vm_area_struct *vma, struct mempolicy *new)
> +/*
> + * Apply policy to a single VMA
> + * This must be called with the mmap_sem held for writing.
> + */
> +static int policy_vma(struct vm_area_struct *vma, struct mempolicy *pol)

If we're going to change this, change the policy_vma() name as well to
set_vma_policy. We currently have policy_vma() and vma_policy() which mean
totally different things which is partially why I deleted it entirely the
first time around. It's a small issue but it might make mempolicy.c 0.0001%
easier to follow.

>  {
> -	int err = 0;
> -	struct mempolicy *old = vma->vm_policy;
> +	int err;
> +	struct mempolicy *old;
> +	struct mempolicy *new;
>  
>  	pr_debug("vma %lx-%lx/%lx vm_ops %p vm_file %p set_policy %p\n",
>  		 vma->vm_start, vma->vm_end, vma->vm_pgoff,
>  		 vma->vm_ops, vma->vm_file,
>  		 vma->vm_ops ? vma->vm_ops->set_policy : NULL);
>  
> -	if (vma->vm_ops && vma->vm_ops->set_policy)
> +	new = mpol_dup(pol);
> +	if (IS_ERR(new))
> +		return PTR_ERR(new);
> +
> +	if (vma->vm_ops && vma->vm_ops->set_policy) {
>  		err = vma->vm_ops->set_policy(vma, new);
> -	if (!err) {
> -		mpol_get(new);
> -		vma->vm_policy = new;
> -		mpol_put(old);
> +		if (err)
> +			goto err_out;
>  	}
> +
> +	old = vma->vm_policy;
> +	vma->vm_policy = new; /* protected by mmap_sem */
> +	mpol_put(old);
> +
> +	return 0;
> + err_out:
> +	mpol_put(new);
>  	return err;
>  }
>  
> @@ -2147,15 +2161,24 @@ static void sp_delete(struct shared_policy *sp, struct sp_node *n)
>  static struct sp_node *sp_alloc(unsigned long start, unsigned long end,
>  				struct mempolicy *pol)
>  {
> -	struct sp_node *n = kmem_cache_alloc(sn_cache, GFP_KERNEL);
> +	struct sp_node *n;
> +	struct mempolicy *newpol;
>  
> +	n = kmem_cache_alloc(sn_cache, GFP_KERNEL);
>  	if (!n)
>  		return NULL;
> +
> +	newpol = mpol_dup(pol);
> +	if (IS_ERR(newpol)) {
> +		kmem_cache_free(sn_cache, n);
> +		return NULL;
> +	}
> +	newpol->flags |= MPOL_F_SHARED;
> +
>  	n->start = start;
>  	n->end = end;
> -	mpol_get(pol);
> -	pol->flags |= MPOL_F_SHARED;	/* for unref */
> -	n->policy = pol;
> +	n->policy = newpol;
> +
>  	return n;
>  }
>  

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
