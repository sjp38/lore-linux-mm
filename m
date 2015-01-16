Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1BFDE6B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 15:01:08 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id bs8so6097925wib.1
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 12:01:07 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e19si10204889wjr.115.2015.01.16.12.01.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 16 Jan 2015 12:01:06 -0800 (PST)
Message-ID: <54B96E00.7040909@suse.cz>
Date: Fri, 16 Jan 2015 21:01:04 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH V3] mm/thp: Allocate transparent hugepages on local node
References: <1421393196-20915-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1421393196-20915-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/16/2015 08:26 AM, Aneesh Kumar K.V wrote:
> This make sure that we try to allocate hugepages from local node if
> allowed by mempolicy. If we can't, we fallback to small page allocation
> based on mempolicy. This is based on the observation that allocating pages
> on local node is more beneficial than allocating hugepages on remote node.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
> Changes from V2:
> * Rebase to latest linus tree (cb59670870d90ff8bc31f5f2efc407c6fe4938c0)
> 
>  include/linux/gfp.h |  4 ++++
>  mm/huge_memory.c    | 24 +++++++++---------------
>  mm/mempolicy.c      | 40 ++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 53 insertions(+), 15 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index b840e3b2770d..60110e06419d 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -335,11 +335,15 @@ alloc_pages(gfp_t gfp_mask, unsigned int order)
>  extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
>  			struct vm_area_struct *vma, unsigned long addr,
>  			int node);
> +extern struct page *alloc_hugepage_vma(gfp_t gfp, struct vm_area_struct *vma,
> +				       unsigned long addr, int order);
>  #else
>  #define alloc_pages(gfp_mask, order) \
>  		alloc_pages_node(numa_node_id(), gfp_mask, order)
>  #define alloc_pages_vma(gfp_mask, order, vma, addr, node)	\
>  	alloc_pages(gfp_mask, order)
> +#define alloc_hugepage_vma(gfp_mask, vma, addr, order)	\
> +	alloc_pages(gfp_mask, order)
>  #endif
>  #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
>  #define alloc_page_vma(gfp_mask, vma, addr)			\
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 817a875f2b8c..031fb1584bbf 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -766,15 +766,6 @@ static inline gfp_t alloc_hugepage_gfpmask(int defrag, gfp_t extra_gfp)
>  	return (GFP_TRANSHUGE & ~(defrag ? 0 : __GFP_WAIT)) | extra_gfp;
>  }
>  
> -static inline struct page *alloc_hugepage_vma(int defrag,
> -					      struct vm_area_struct *vma,
> -					      unsigned long haddr, int nd,
> -					      gfp_t extra_gfp)
> -{
> -	return alloc_pages_vma(alloc_hugepage_gfpmask(defrag, extra_gfp),
> -			       HPAGE_PMD_ORDER, vma, haddr, nd);
> -}
> -
>  /* Caller must hold page table lock. */
>  static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
>  		struct vm_area_struct *vma, unsigned long haddr, pmd_t *pmd,
> @@ -795,6 +786,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  			       unsigned long address, pmd_t *pmd,
>  			       unsigned int flags)
>  {
> +	gfp_t gfp;
>  	struct page *page;
>  	unsigned long haddr = address & HPAGE_PMD_MASK;
>  
> @@ -829,8 +821,8 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		}
>  		return 0;
>  	}
> -	page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
> -			vma, haddr, numa_node_id(), 0);
> +	gfp = alloc_hugepage_gfpmask(transparent_hugepage_defrag(vma), 0);
> +	page = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
>  	if (unlikely(!page)) {
>  		count_vm_event(THP_FAULT_FALLBACK);
>  		return VM_FAULT_FALLBACK;
> @@ -1118,10 +1110,12 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	spin_unlock(ptl);
>  alloc:
>  	if (transparent_hugepage_enabled(vma) &&
> -	    !transparent_hugepage_debug_cow())
> -		new_page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
> -					      vma, haddr, numa_node_id(), 0);
> -	else
> +	    !transparent_hugepage_debug_cow()) {
> +		gfp_t gfp;
> +
> +		gfp = alloc_hugepage_gfpmask(transparent_hugepage_defrag(vma), 0);
> +		new_page = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
> +	} else
>  		new_page = NULL;
>  
>  	if (unlikely(!new_page)) {
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 0e0961b8c39c..14604142c2c2 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -2030,6 +2030,46 @@ retry_cpuset:
>  	return page;
>  }
>  
> +struct page *alloc_hugepage_vma(gfp_t gfp, struct vm_area_struct *vma,
> +				unsigned long addr, int order)
> +{
> +	struct page *page;
> +	nodemask_t *nmask;
> +	struct mempolicy *pol;
> +	int node = numa_node_id();
> +	unsigned int cpuset_mems_cookie;
> +
> +retry_cpuset:
> +	pol = get_vma_policy(vma, addr);
> +	cpuset_mems_cookie = read_mems_allowed_begin();
> +
> +	if (pol->mode != MPOL_INTERLEAVE) {
> +		/*
> +		 * For interleave policy, we don't worry about
> +		 * current node. Otherwise if current node is
> +		 * in nodemask, try to allocate hugepage from
> +		 * current node. Don't fall back to other nodes
> +		 * for THP.
> +		 */
> +		nmask = policy_nodemask(gfp, pol);
> +		if (!nmask || node_isset(node, *nmask)) {
> +			mpol_cond_put(pol);
> +			page = alloc_pages_exact_node(node, gfp, order);
> +			if (unlikely(!page &&
> +				     read_mems_allowed_retry(cpuset_mems_cookie)))
> +				goto retry_cpuset;
> +			return page;
> +		}
> +	}
> +	mpol_cond_put(pol);
> +	/*
> +	 * if current node is not part of node mask, try
> +	 * the allocation from any node, and we can do retry
> +	 * in that case.
> +	 */
> +	return alloc_pages_vma(gfp, order, vma, addr, node);
> +}
> +
>  /**
>   * 	alloc_pages_current - Allocate pages.
>   *
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
