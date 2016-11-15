Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6630F6B0261
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 01:01:20 -0500 (EST)
Received: by mail-pa0-f69.google.com with SMTP id ro13so107844018pac.7
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 22:01:20 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e69si25061056pfk.231.2016.11.14.22.01.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 22:01:19 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAF5xARw044509
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 01:01:18 -0500
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26qpnawbyb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 01:01:18 -0500
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 15 Nov 2016 01:01:16 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 4/6] mm: mempolicy: intruduce a helper huge_nodemask()
In-Reply-To: <1479107259-2011-5-git-send-email-shijie.huang@arm.com>
References: <1479107259-2011-1-git-send-email-shijie.huang@arm.com> <1479107259-2011-5-git-send-email-shijie.huang@arm.com>
Date: Tue, 15 Nov 2016 11:31:06 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87oa1hb7tp.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <shijie.huang@arm.com>, akpm@linux-foundation.org, catalin.marinas@arm.com
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

Huang Shijie <shijie.huang@arm.com> writes:

> This patch intruduces a new helper huge_nodemask(),
> we can use it to get the node mask.
>
> This idea of the function is from the huge_zonelist().
>
> Signed-off-by: Huang Shijie <shijie.huang@arm.com>
> ---
>  include/linux/mempolicy.h |  8 ++++++++
>  mm/mempolicy.c            | 20 ++++++++++++++++++++
>  2 files changed, 28 insertions(+)
>
> diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
> index 5e5b296..01173c6 100644
> --- a/include/linux/mempolicy.h
> +++ b/include/linux/mempolicy.h
> @@ -145,6 +145,8 @@ extern void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new,
>  				enum mpol_rebind_step step);
>  extern void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new);
>
> +extern nodemask_t *huge_nodemask(struct vm_area_struct *vma,
> +				unsigned long addr);
>  extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
>  				unsigned long addr, gfp_t gfp_flags,
>  				struct mempolicy **mpol, nodemask_t **nodemask);
> @@ -261,6 +263,12 @@ static inline void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
>  {
>  }
>
> +static inline nodemask_t *huge_nodemask(struct vm_area_struct *vma,
> +				unsigned long addr)
> +{
> +	return NULL;
> +}
> +
>  static inline struct zonelist *huge_zonelist(struct vm_area_struct *vma,
>  				unsigned long addr, gfp_t gfp_flags,
>  				struct mempolicy **mpol, nodemask_t **nodemask)
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 6d3639e..4830dd6 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1800,6 +1800,26 @@ static inline unsigned interleave_nid(struct mempolicy *pol,
>
>  #ifdef CONFIG_HUGETLBFS
>  /*
> + * huge_nodemask(@vma, @addr)
> + * @vma: virtual memory area whose policy is sought
> + * @addr: address in @vma for shared policy lookup and interleave policy
> + *
> + * If the effective policy is BIND, returns a pointer to the mempolicy's
> + * @nodemask.
> + */
> +nodemask_t *huge_nodemask(struct vm_area_struct *vma, unsigned long addr)
> +{
> +	nodemask_t *nodes_mask = NULL;
> +	struct mempolicy *mpol = get_vma_policy(vma, addr);
> +
> +	if (mpol->mode == MPOL_BIND)
> +		nodes_mask = &mpol->v.nodes;
> +	mpol_cond_put(mpol);

What if it is MPOL_PREFERED or MPOL_INTERLEAVE ? we don't honor node
mask in that case ?


> +
> +	return nodes_mask;
> +}
> +
> +/*
>   * huge_zonelist(@vma, @addr, @gfp_flags, @mpol)
>   * @vma: virtual memory area whose policy is sought
>   * @addr: address in @vma for shared policy lookup and interleave policy
> -- 
> 2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
