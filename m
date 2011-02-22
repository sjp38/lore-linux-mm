Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 85C148D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 10:43:03 -0500 (EST)
Date: Tue, 22 Feb 2011 09:42:58 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/8] Change alloc_pages_vma to pass down the policy node
 for local policy
In-Reply-To: <1298315270-10434-3-git-send-email-andi@firstfloor.org>
Message-ID: <alpine.DEB.2.00.1102220941200.16060@router.home>
References: <1298315270-10434-1-git-send-email-andi@firstfloor.org> <1298315270-10434-3-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, lwoodman@redhat.com, Andi Kleen <ak@linux.intel.com>

On Mon, 21 Feb 2011, Andi Kleen wrote:

> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1524,10 +1524,9 @@ static nodemask_t *policy_nodemask(gfp_t gfp, struct mempolicy *policy)
>  }
>
>  /* Return a zonelist indicated by gfp for node representing a mempolicy */
> -static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy)
> +static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy,
> +	int nd)
>  {
> -	int nd = numa_node_id();
> -
>  	switch (policy->mode) {
>  	case MPOL_PREFERRED:
>  		if (!(policy->flags & MPOL_F_LOCAL))
> @@ -1679,7 +1678,7 @@ struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
>  		zl = node_zonelist(interleave_nid(*mpol, vma, addr,
>  				huge_page_shift(hstate_vma(vma))), gfp_flags);
>  	} else {
> -		zl = policy_zonelist(gfp_flags, *mpol);
> +		zl = policy_zonelist(gfp_flags, *mpol, numa_node_id());
>  		if ((*mpol)->mode == MPOL_BIND)
>  			*nodemask = &(*mpol)->v.nodes;
>  	}

If we do that then why not also consolidate the MPOL_INTERLEAVE
treatment also in policy_zonelist()? Looks awfully similar now and Would
simplify the code and likely get rid of some functions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
