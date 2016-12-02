Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id AC5786B025E
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 08:58:50 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id xy5so45124865wjc.0
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 05:58:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id za10si5338727wjc.98.2016.12.02.05.58.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Dec 2016 05:58:49 -0800 (PST)
Date: Fri, 2 Dec 2016 14:58:46 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH V2 fix 4/6] mm: mempolicy: intruduce a helper
 huge_nodemask()
Message-ID: <20161202135845.GL6830@dhcp22.suse.cz>
References: <1479107259-2011-5-git-send-email-shijie.huang@arm.com>
 <1479279182-31294-1-git-send-email-shijie.huang@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1479279182-31294-1-git-send-email-shijie.huang@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <shijie.huang@arm.com>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On Wed 16-11-16 14:53:02, Huang Shijie wrote:
> This patch intruduces a new helper huge_nodemask(),
> we can use it to get the node mask.
> 
> This idea of the function is from the init_nodemask_of_mempolicy():
>    Return true if we can succeed in extracting the node_mask
> for 'bind' or 'interleave' policy or initializing the node_mask
> to contain the single node for 'preferred' or 'local' policy.

It is absolutely unclear how this is going to be used from this patch.
Please make sure to also use a newly added function in the same patch.

> 
> Signed-off-by: Huang Shijie <shijie.huang@arm.com>
> ---
> The previous version does not treat the MPOL_PREFERRED/MPOL_INTERLEAVE cases.
> This patch adds the code to set proper node mask for
> MPOL_PREFERRED/MPOL_INTERLEAVE.
> ---
>  include/linux/mempolicy.h |  8 ++++++++
>  mm/mempolicy.c            | 47 +++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 55 insertions(+)
> 
> diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
> index 5e5b296..7796a40 100644
> --- a/include/linux/mempolicy.h
> +++ b/include/linux/mempolicy.h
> @@ -145,6 +145,8 @@ extern void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new,
>  				enum mpol_rebind_step step);
>  extern void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new);
>  
> +extern bool huge_nodemask(struct vm_area_struct *vma,
> +				unsigned long addr, nodemask_t *mask);
>  extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
>  				unsigned long addr, gfp_t gfp_flags,
>  				struct mempolicy **mpol, nodemask_t **nodemask);
> @@ -261,6 +263,12 @@ static inline void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
>  {
>  }
>  
> +static inline bool huge_nodemask(struct vm_area_struct *vma,
> +				unsigned long addr, nodemask_t *mask)
> +{
> +	return false;
> +}
> +
>  static inline struct zonelist *huge_zonelist(struct vm_area_struct *vma,
>  				unsigned long addr, gfp_t gfp_flags,
>  				struct mempolicy **mpol, nodemask_t **nodemask)
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 6d3639e..5063a69 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1800,6 +1800,53 @@ static inline unsigned interleave_nid(struct mempolicy *pol,
>  
>  #ifdef CONFIG_HUGETLBFS
>  /*
> + * huge_nodemask(@vma, @addr, @mask)
> + * @vma: virtual memory area whose policy is sought
> + * @addr: address in @vma
> + * @mask: a nodemask pointer
> + *
> + * Return true if we can succeed in extracting the policy nodemask
> + * for 'bind' or 'interleave' policy into the argument @mask, or
> + * initializing the argument @mask to contain the single node for
> + * 'preferred' or 'local' policy.
> + */
> +bool huge_nodemask(struct vm_area_struct *vma, unsigned long addr,
> +			nodemask_t *mask)
> +{
> +	struct mempolicy *mpol;
> +	bool ret = true;
> +	int nid;
> +
> +	if (!mask)
> +		return false;
> +
> +	mpol = get_vma_policy(vma, addr);
> +
> +	switch (mpol->mode) {
> +	case MPOL_PREFERRED:
> +		if (mpol->flags & MPOL_F_LOCAL)
> +			nid = numa_node_id();
> +		else
> +			nid = mpol->v.preferred_node;
> +		init_nodemask_of_node(mask, nid);
> +		break;
> +
> +	case MPOL_BIND:
> +		/* Fall through */
> +	case MPOL_INTERLEAVE:
> +		*mask = mpol->v.nodes;
> +		break;
> +
> +	default:
> +		ret = false;
> +		break;
> +	}
> +	mpol_cond_put(mpol);
> +
> +	return ret;
> +}
> +
> +/*
>   * huge_zonelist(@vma, @addr, @gfp_flags, @mpol)
>   * @vma: virtual memory area whose policy is sought
>   * @addr: address in @vma for shared policy lookup and interleave policy
> -- 
> 2.5.5
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
