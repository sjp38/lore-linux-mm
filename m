Return-Path: <SRS0=c8nW=TE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A9CCC43219
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 12:03:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C33FF206BB
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 12:03:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C33FF206BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 537006B0003; Sat,  4 May 2019 08:03:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BF906B0006; Sat,  4 May 2019 08:03:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 360286B0007; Sat,  4 May 2019 08:03:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id D9D506B0003
	for <linux-mm@kvack.org>; Sat,  4 May 2019 08:03:33 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id y9so1634596wmj.0
        for <linux-mm@kvack.org>; Sat, 04 May 2019 05:03:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6zlYKSvra8Ge6oP51tw9rB8tdDFeAs0/zZMk+VG+ESI=;
        b=d0ti1parNGFY7X9pBRrhDrvuuHob6nXn7MWL6jPmYAgihY34yHMYx3dPz7/cOW3Iva
         6CJxMEGnxUIXVVx8hl3Jan0+tG8vr+7apIcuRaRzdLWxeTRFpe3nO5Tiao8w2WTKXHdA
         xfmdjAoZ+k7IUZrgkDw1mRRO8w504HfpNLDoBuPkS/mFnj/OvFiVX/HOElXayCsReNQt
         lNQGKWIPgKE56uRwFmzt8oMOjIIEmyOJIEzaOOkEP+jMBCS7HDeKfurFuVk5Szr4bPCm
         fKE3b9JAf3KMiAGMzfqLD1mYXiqYqlZRolb2dbfiD972wVnbfiON1SRD2gOhA0P9ukQq
         2QGQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU8sl8zZTHo5GN0F7BRK8O5w8FIQXoylfDQrHJ+qO1M23z0wGEH
	Ta7SdJ1G2C5PNFkhiY3vLg1wfGmEwJmzggidc1VUrXFtZjvksBjp/Q6ZBG2aZHsg3RLrjA6KqS5
	O+l+S9nyrPTQNqB1Zm1pWJPea1alcgrmvEBEKtKEVl9ztdLF5FEGqinqVDqbRkkY=
X-Received: by 2002:a05:600c:1103:: with SMTP id b3mr2253820wma.119.1556971413401;
        Sat, 04 May 2019 05:03:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPOcrc7WAAB0p39hxck6yGYXxIaFkVZFmG+IAY3vL3WZYQOXJ4T/bVIDMg5Aat2wQhoNc2
X-Received: by 2002:a05:600c:1103:: with SMTP id b3mr2253758wma.119.1556971412151;
        Sat, 04 May 2019 05:03:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556971412; cv=none;
        d=google.com; s=arc-20160816;
        b=1GlAkI7j7vI75GCKqDsNVXEAksD8mRA1ZAK2ZF3OkQPmndWVkcNaJUZE1c8AQ5oJ8+
         giFVU+93LjoCt1lhYIAk5ylZJ446aWK+1FjseYdY7kldBOjW4vG4qQq6I+36KoBBf6fW
         0Q5d5YFYrvUmbSx0lpeKjiqoA1ObBm50nwEJqgozbfrlU1ZDwuyLI/CtI1+CfQ12gaqq
         CYerAhBj6Z5LyDddcL/T8BiC1QXhhzTNb3P2h3ndjdFmPADTSJevbwMU4FacI9l2tL+N
         Vzkv2Yam/jZerA4z/00UyHe+u4xMuM60iUKAFSgOau65CLmYc3pApyGvUrtXoqa8Cxiz
         YdpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6zlYKSvra8Ge6oP51tw9rB8tdDFeAs0/zZMk+VG+ESI=;
        b=qUzZ2OqYKTlcWCOcn0qTD2M4iXgX/5NF96e11KxLGMcwUE3/+Iz8vVOdgtzGR47qgv
         qhMHnBg7EovmTLd0A2PLuT+Ap3dV1ojAtFmjISzvni9pJsHhN3PqJhbmUeltv73fWQ5B
         8PI27AwUh6HfgGTYa4cY9zXcovUgGnJ8CXCMXuZHRRzGxw/2LzSKvTlRs7S8sY8/tv14
         2Nx6ZCsCkUz6L2+4MklJhrBb4Nl7ZPCZB8GBisWQiFMSRDDg+FXy25qbW6WOyxVtLxvF
         /wYIgYvgDU6BhiEHJ+ZubSde4JYhso9zdkpOPih5NaEByDhVDO+A2mmsdjJKZXQ9Rjmo
         N7Rg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z18si3547778wrr.275.2019.05.04.05.03.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 May 2019 05:03:32 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7C6F9AD8D;
	Sat,  4 May 2019 12:03:31 +0000 (UTC)
Date: Sat, 4 May 2019 08:03:27 -0400
From: Michal Hocko <mhocko@kernel.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	David Rientjes <rientjes@google.com>,
	Zi Yan <zi.yan@cs.rutgers.edu>,
	Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
	"Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/2] Revert "Revert "mm, thp: consolidate THP gfp
 handling into alloc_hugepage_direct_gfpmask""
Message-ID: <20190504120327.GQ29835@dhcp22.suse.cz>
References: <20190503223146.2312-1-aarcange@redhat.com>
 <20190503223146.2312-2-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190503223146.2312-2-aarcange@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 03-05-19 18:31:45, Andrea Arcangeli wrote:
> This reverts commit 356ff8a9a78fb35d6482584d260c3754dcbdf669.

This should really provide some changelog. I would go with the
following.

"
Consolidation of the THP allocation flags at the same place was meant to
be a clean up to easier handle otherwise scattered code which is
imposing a maintenance burden. There were no real problems observed with
the gfp mask consilidation but the reverting it was rushed through
without a larger consensus regardless.

This patch brings the consolidation back because this should make the
long term maintainability easier as well as it should allow future
changes to be less error prone.
"

Feel free to reuse or use your own wording

> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

With a changelog clarification feel free to add
Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/gfp.h | 12 ++++--------
>  mm/huge_memory.c    | 27 ++++++++++++++-------------
>  mm/mempolicy.c      | 32 +++-----------------------------
>  mm/shmem.c          |  2 +-
>  4 files changed, 22 insertions(+), 51 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index fdab7de7490d..e2a6aea3f8ec 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -510,22 +510,18 @@ alloc_pages(gfp_t gfp_mask, unsigned int order)
>  }
>  extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
>  			struct vm_area_struct *vma, unsigned long addr,
> -			int node, bool hugepage);
> -#define alloc_hugepage_vma(gfp_mask, vma, addr, order) \
> -	alloc_pages_vma(gfp_mask, order, vma, addr, numa_node_id(), true)
> +			int node);
>  #else
>  #define alloc_pages(gfp_mask, order) \
>  		alloc_pages_node(numa_node_id(), gfp_mask, order)
> -#define alloc_pages_vma(gfp_mask, order, vma, addr, node, false)\
> -	alloc_pages(gfp_mask, order)
> -#define alloc_hugepage_vma(gfp_mask, vma, addr, order) \
> +#define alloc_pages_vma(gfp_mask, order, vma, addr, node)\
>  	alloc_pages(gfp_mask, order)
>  #endif
>  #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
>  #define alloc_page_vma(gfp_mask, vma, addr)			\
> -	alloc_pages_vma(gfp_mask, 0, vma, addr, numa_node_id(), false)
> +	alloc_pages_vma(gfp_mask, 0, vma, addr, numa_node_id())
>  #define alloc_page_vma_node(gfp_mask, vma, addr, node)		\
> -	alloc_pages_vma(gfp_mask, 0, vma, addr, node, false)
> +	alloc_pages_vma(gfp_mask, 0, vma, addr, node)
>  
>  extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
>  extern unsigned long get_zeroed_page(gfp_t gfp_mask);
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 165ea46bf149..7efe68ba052a 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -641,30 +641,30 @@ static vm_fault_t __do_huge_pmd_anonymous_page(struct vm_fault *vmf,
>   *	    available
>   * never: never stall for any thp allocation
>   */
> -static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
> +static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma, unsigned long addr)
>  {
>  	const bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
> +	const gfp_t gfp_mask = GFP_TRANSHUGE_LIGHT | __GFP_THISNODE;
>  
>  	/* Always do synchronous compaction */
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
> -		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY);
> +		return GFP_TRANSHUGE | __GFP_THISNODE |
> +		       (vma_madvised ? 0 : __GFP_NORETRY);
>  
>  	/* Kick kcompactd and fail quickly */
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
> -		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM;
> +		return gfp_mask | __GFP_KSWAPD_RECLAIM;
>  
>  	/* Synchronous compaction if madvised, otherwise kick kcompactd */
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags))
> -		return GFP_TRANSHUGE_LIGHT |
> -			(vma_madvised ? __GFP_DIRECT_RECLAIM :
> -					__GFP_KSWAPD_RECLAIM);
> +		return gfp_mask | (vma_madvised ? __GFP_DIRECT_RECLAIM :
> +						  __GFP_KSWAPD_RECLAIM);
>  
>  	/* Only do synchronous compaction if madvised */
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
> -		return GFP_TRANSHUGE_LIGHT |
> -		       (vma_madvised ? __GFP_DIRECT_RECLAIM : 0);
> +		return gfp_mask | (vma_madvised ? __GFP_DIRECT_RECLAIM : 0);
>  
> -	return GFP_TRANSHUGE_LIGHT;
> +	return gfp_mask;
>  }
>  
>  /* Caller must hold page table lock. */
> @@ -736,8 +736,8 @@ vm_fault_t do_huge_pmd_anonymous_page(struct vm_fault *vmf)
>  			pte_free(vma->vm_mm, pgtable);
>  		return ret;
>  	}
> -	gfp = alloc_hugepage_direct_gfpmask(vma);
> -	page = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
> +	gfp = alloc_hugepage_direct_gfpmask(vma, haddr);
> +	page = alloc_pages_vma(gfp, HPAGE_PMD_ORDER, vma, haddr, numa_node_id());
>  	if (unlikely(!page)) {
>  		count_vm_event(THP_FAULT_FALLBACK);
>  		return VM_FAULT_FALLBACK;
> @@ -1340,8 +1340,9 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
>  alloc:
>  	if (__transparent_hugepage_enabled(vma) &&
>  	    !transparent_hugepage_debug_cow()) {
> -		huge_gfp = alloc_hugepage_direct_gfpmask(vma);
> -		new_page = alloc_hugepage_vma(huge_gfp, vma, haddr, HPAGE_PMD_ORDER);
> +		huge_gfp = alloc_hugepage_direct_gfpmask(vma, haddr);
> +		new_page = alloc_pages_vma(huge_gfp, HPAGE_PMD_ORDER, vma,
> +				haddr, numa_node_id());
>  	} else
>  		new_page = NULL;
>  
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 2219e747df49..74e44000ad61 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1142,8 +1142,8 @@ static struct page *new_page(struct page *page, unsigned long start)
>  	} else if (PageTransHuge(page)) {
>  		struct page *thp;
>  
> -		thp = alloc_hugepage_vma(GFP_TRANSHUGE, vma, address,
> -					 HPAGE_PMD_ORDER);
> +		thp = alloc_pages_vma(GFP_TRANSHUGE, HPAGE_PMD_ORDER, vma,
> +				address, numa_node_id());
>  		if (!thp)
>  			return NULL;
>  		prep_transhuge_page(thp);
> @@ -2037,7 +2037,6 @@ static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
>   * 	@vma:  Pointer to VMA or NULL if not available.
>   *	@addr: Virtual Address of the allocation. Must be inside the VMA.
>   *	@node: Which node to prefer for allocation (modulo policy).
> - *	@hugepage: for hugepages try only the preferred node if possible
>   *
>   * 	This function allocates a page from the kernel page pool and applies
>   *	a NUMA policy associated with the VMA or the current process.
> @@ -2048,7 +2047,7 @@ static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
>   */
>  struct page *
>  alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
> -		unsigned long addr, int node, bool hugepage)
> +		unsigned long addr, int node)
>  {
>  	struct mempolicy *pol;
>  	struct page *page;
> @@ -2066,31 +2065,6 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
>  		goto out;
>  	}
>  
> -	if (unlikely(IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && hugepage)) {
> -		int hpage_node = node;
> -
> -		/*
> -		 * For hugepage allocation and non-interleave policy which
> -		 * allows the current node (or other explicitly preferred
> -		 * node) we only try to allocate from the current/preferred
> -		 * node and don't fall back to other nodes, as the cost of
> -		 * remote accesses would likely offset THP benefits.
> -		 *
> -		 * If the policy is interleave, or does not allow the current
> -		 * node in its nodemask, we allocate the standard way.
> -		 */
> -		if (pol->mode == MPOL_PREFERRED && !(pol->flags & MPOL_F_LOCAL))
> -			hpage_node = pol->v.preferred_node;
> -
> -		nmask = policy_nodemask(gfp, pol);
> -		if (!nmask || node_isset(hpage_node, *nmask)) {
> -			mpol_cond_put(pol);
> -			page = __alloc_pages_node(hpage_node,
> -						gfp | __GFP_THISNODE, order);
> -			goto out;
> -		}
> -	}
> -
>  	nmask = policy_nodemask(gfp, pol);
>  	preferred_nid = policy_node(gfp, pol, node);
>  	page = __alloc_pages_nodemask(gfp, order, preferred_nid, nmask);
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 2275a0ff7c30..ed7ebc423c6b 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1464,7 +1464,7 @@ static struct page *shmem_alloc_hugepage(gfp_t gfp,
>  
>  	shmem_pseudo_vma_init(&pvma, info, hindex);
>  	page = alloc_pages_vma(gfp | __GFP_COMP | __GFP_NORETRY | __GFP_NOWARN,
> -			HPAGE_PMD_ORDER, &pvma, 0, numa_node_id(), true);
> +			HPAGE_PMD_ORDER, &pvma, 0, numa_node_id());
>  	shmem_pseudo_vma_destroy(&pvma);
>  	if (page)
>  		prep_transhuge_page(page);

-- 
Michal Hocko
SUSE Labs

