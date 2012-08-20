Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 1A8046B005D
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 15:51:12 -0400 (EDT)
Date: Mon, 20 Aug 2012 19:51:10 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 5/5] mempolicy: fix a memory corruption by refcount
 imbalance in alloc_pages_vma()
In-Reply-To: <1345480594-27032-6-git-send-email-mgorman@suse.de>
Message-ID: <000001394596bd69-2c16d7fb-71b5-4009-95cc-7068103b2bfd-000000@email.amazonses.com>
References: <1345480594-27032-1-git-send-email-mgorman@suse.de> <1345480594-27032-6-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, Ben Hutchings <ben@decadent.org.uk>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, 20 Aug 2012, Mel Gorman wrote:

> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 45f9825..82e872f 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1545,15 +1545,28 @@ struct mempolicy *get_vma_policy(struct task_struct *task,
>  		struct vm_area_struct *vma, unsigned long addr)
>  {
>  	struct mempolicy *pol = task->mempolicy;
> +	int got_ref;

New variable. Need to set it to zero?

>
>  	if (vma) {
>  		if (vma->vm_ops && vma->vm_ops->get_policy) {
>  			struct mempolicy *vpol = vma->vm_ops->get_policy(vma,
>  									addr);
> -			if (vpol)
> +			if (vpol) {
>  				pol = vpol;
> -		} else if (vma->vm_policy)
> +				got_ref = 1;

Set the new variable. But it was not initialzed before. So now its 1 or
undefined?

> +			}
> +		} else if (vma->vm_policy) {
>  			pol = vma->vm_policy;
> +
> +			/*
> +			 * shmem_alloc_page() passes MPOL_F_SHARED policy with
> +			 * a pseudo vma whose vma->vm_ops=NULL. Take a reference
> +			 * count on these policies which will be dropped by
> +			 * mpol_cond_put() later
> +			 */
> +			if (mpol_needs_cond_ref(pol))
> +				mpol_get(pol);
> +		}
>  	}
>  	if (!pol)
>  		pol = &default_policy;
>

I do not see any use of got_ref. Can we get rid of the variable?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
