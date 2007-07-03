Date: Tue, 3 Jul 2007 11:09:02 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC] Fix Mempolicy Ref Counts - was Re: [PATCH/RFC 0/11]
 Shared Policy Overview
In-Reply-To: <1183228446.6975.10.camel@localhost>
Message-ID: <Pine.LNX.4.64.0707031108160.6404@schroedinger.engr.sgi.com>
References: <20070625195224.21210.89898.sendpatchset@localhost>
 <200706290002.12113.ak@suse.de> <1183137257.5012.12.camel@localhost>
 <200706291942.06679.ak@suse.de> <1183228446.6975.10.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, "Paul E. McKenney" <paulmck@us.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Sat, 30 Jun 2007, Lee Schermerhorn wrote:

> Index: Linux/mm/mempolicy.c
> ===================================================================
> --- Linux.orig/mm/mempolicy.c	2007-06-30 12:56:51.000000000 -0400
> +++ Linux/mm/mempolicy.c	2007-06-30 13:49:12.000000000 -0400
> @@ -1077,16 +1077,20 @@ static struct mempolicy * get_vma_policy
>  		struct vm_area_struct *vma, unsigned long addr)
>  {
>  	struct mempolicy *pol = task->mempolicy;
> +	int shared_pol = 0;
>  
>  	if (vma) {
> -		if (vma->vm_ops && vma->vm_ops->get_policy)
> +		if (vma->vm_ops && vma->vm_ops->get_policy) {
>  			pol = vma->vm_ops->get_policy(vma, addr);
> -		else if (vma->vm_policy &&
> +			shared_pol = 1;	/* if non-NULL, that is */
> +		} else if (vma->vm_policy &&
>  				vma->vm_policy->policy != MPOL_DEFAULT)
>  			pol = vma->vm_policy;
>  	}
>  	if (!pol)
>  		pol = &default_policy;
> +	else if (!shared_pol && pol != current->mempolicy)
> +		mpol_get(pol);	/* vma or other task's policy */
>  	return pol;
>  }
>  
> @@ -1259,6 +1263,7 @@ struct page *
>  alloc_page_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long addr)
>  {
>  	struct mempolicy *pol = get_vma_policy(current, vma, addr);
> +	struct zonelist *zl;
>  
>  	cpuset_update_task_memory_state();
>  
> @@ -1268,7 +1273,19 @@ alloc_page_vma(gfp_t gfp, struct vm_area
>  		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT);
>  		return alloc_page_interleave(gfp, 0, nid);
>  	}
> -	return __alloc_pages(gfp, 0, zonelist_policy(gfp, pol));
> +	zl = zonelist_policy(gfp, pol);
> +	if (pol != &default_policy && pol != current->mempolicy) {
> +		/*
> +		 * slow path: ref counted policy -- shared or vma
> +		 */
> +		struct page *page =  __alloc_pages(gfp, 0, zl);
> +		__mpol_free(pol);
> +		return page;
> +	}
> +	/*
> +	 * fast path:  default or task policy
> +	 */
> +	return __alloc_pages(gfp, 0, zl);
>  }

Argh. Some hot paths are touched here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
