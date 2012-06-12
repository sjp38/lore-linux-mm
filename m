Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id B13156B005C
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 10:20:17 -0400 (EDT)
Date: Tue, 12 Jun 2012 15:20:12 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 5/6] mempolicy: fix a memory corruption by refcount
 imbalance in alloc_pages_vma()
Message-ID: <20120612142012.GB20467@suse.de>
References: <1339406250-10169-1-git-send-email-kosaki.motohiro@gmail.com>
 <1339406250-10169-6-git-send-email-kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1339406250-10169-6-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Christoph Lameter <cl@linux.com>, stable@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Miao Xie <miaox@cn.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Mon, Jun 11, 2012 at 05:17:29AM -0400, kosaki.motohiro@gmail.com wrote:
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> commit cc9a6c8776 (cpuset: mm: reduce large amounts of memory barrier related
> damage v3) introduced a memory corruption.
> 

Ouch. No biscuits for Mel.

> shmem_alloc_page() passes pseudo vma and it has one significant unique
> combination, vma->vm_ops=NULL and (vma->policy->flags & MPOL_F_SHARED).
> 
> Now, get_vma_policy() does NOT increase a policy ref when vma->vm_ops=NULL
> and mpol_cond_put() DOES decrease a policy ref when a policy has MPOL_F_SHARED.
> Therefore, when alloc_pages_vma() goes 'goto retry_cpuset' path, a policy
> refcount will be decreased too much and therefore it will make a memory corruption.
> 

Yes, this is true. Hitting the bug requires that the cpuset is being
updated during the allocation so it's not a common but it is real. I'm
surprised I did not hit this while I was running the cpuset stress test
that originally introduced [get|put]_mems_allowed().

> This patch fixes it.
> 
> Cc: Dave Jones <davej@redhat.com>,
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Christoph Lameter <cl@linux.com>,
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: <stable@vger.kernel.org>
> Cc: Miao Xie <miaox@cn.fujitsu.com>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Andi Kleen <ak@linux.intel.com>
> ---
>  mm/mempolicy.c |   13 ++++++++++++-
>  mm/shmem.c     |    9 +++++----
>  2 files changed, 17 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 7fb7d51..0da0969 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1544,18 +1544,29 @@ struct mempolicy *get_vma_policy(struct task_struct *task,
>  		struct vm_area_struct *vma, unsigned long addr)
>  {
>  	struct mempolicy *pol = task->mempolicy;
> +	int got_ref;
>  
>  	if (vma) {
>  		if (vma->vm_ops && vma->vm_ops->get_policy) {
>  			struct mempolicy *vpol = vma->vm_ops->get_policy(vma,
>  									addr);
> -			if (vpol)
> +			if (vpol) {
>  				pol = vpol;
> +				got_ref = 1;
> +			}
>  		} else if (vma->vm_policy)
>  			pol = vma->vm_policy;
>  	}
>  	if (!pol)
>  		pol = &default_policy;
> +
> +	/*
> +	 * shmem_alloc_page() passes MPOL_F_SHARED policy with vma->vm_ops=NULL.
> +	 * Thus, we need to take additional ref for avoiding refcount imbalance.
> +	 */
> +	if (!got_ref && mpol_needs_cond_ref(pol))
> +		mpol_get(pol);
> +
>  	return pol;
>  }
>  
> diff --git a/mm/shmem.c b/mm/shmem.c
> index d576b84..eb5f1eb 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -919,6 +919,7 @@ static struct page *shmem_alloc_page(gfp_t gfp,
>  			struct shmem_inode_info *info, pgoff_t index)
>  {
>  	struct vm_area_struct pvma;
> +	struct page *page;
>  
>  	/* Create a pseudo vma that just contains the policy */
>  	pvma.vm_start = 0;
> @@ -926,10 +927,10 @@ static struct page *shmem_alloc_page(gfp_t gfp,
>  	pvma.vm_ops = NULL;
>  	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, index);
>  
> -	/*
> -	 * alloc_page_vma() will drop the shared policy reference
> -	 */
> -	return alloc_page_vma(gfp, &pvma, 0);
> +	page = alloc_page_vma(gfp, &pvma, 0);
> +
> +	mpol_put(pvma.vm_policy);
> +	return page;
>  }

Why does dequeue_huge_page_vma() not need to be changed as well? It's
currently using mpol_cond_put() but if there is a goto retry_cpuset then
will it have not take an additional reference count and leak?

Would it be more straight forward to put the mpol_cond_put() and __mpol_put()
calls after the "goto retry_cpuset" checks instead?

>  #else /* !CONFIG_NUMA */
>  #ifdef CONFIG_TMPFS
> -- 
> 1.7.1
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
