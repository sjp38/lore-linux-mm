Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5AFB928041F
	for <linux-mm@kvack.org>; Fri, 19 May 2017 07:59:22 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id b28so4758636wrb.2
        for <linux-mm@kvack.org>; Fri, 19 May 2017 04:59:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m17si7182873eda.177.2017.05.19.04.59.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 04:59:20 -0700 (PDT)
Date: Fri, 19 May 2017 13:59:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/6] mm, page_alloc: pass preferred nid instead of
 zonelist to allocator
Message-ID: <20170519115919.GC29839@dhcp22.suse.cz>
References: <20170517081140.30654-1-vbabka@suse.cz>
 <20170517081140.30654-4-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170517081140.30654-4-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed 17-05-17 10:11:37, Vlastimil Babka wrote:
> The main allocator function __alloc_pages_nodemask() takes a zonelist pointer
> as one of its parameters. All of its callers directly or indirectly obtain the
> zonelist via node_zonelist() using a preferred node id and gfp_mask. We can
> make the code a bit simpler by doing the zonelist lookup in
> __alloc_pages_nodemask(), passing it a preferred node id instead (gfp_mask is
> already another parameter).
> 
> There are some code size benefits thanks to removal of inlined node_zonelist():
> 
> bloat-o-meter add/remove: 2/2 grow/shrink: 4/36 up/down: 399/-1351 (-952)
> 
> This will also make things simpler if we proceed with converting cpusets to
> zonelists.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Makes sense to me
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/gfp.h       | 11 +++++------
>  include/linux/mempolicy.h |  6 +++---
>  mm/hugetlb.c              | 15 +++++++++------
>  mm/memory_hotplug.c       |  6 ++----
>  mm/mempolicy.c            | 41 +++++++++++++++++++----------------------
>  mm/page_alloc.c           | 10 +++++-----
>  6 files changed, 43 insertions(+), 46 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 2b1a44f5bdb6..666af3c39d00 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -432,14 +432,13 @@ static inline void arch_alloc_page(struct page *page, int order) { }
>  #endif
>  
>  struct page *
> -__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
> -		       struct zonelist *zonelist, nodemask_t *nodemask);
> +__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
> +							nodemask_t *nodemask);
>  
>  static inline struct page *
> -__alloc_pages(gfp_t gfp_mask, unsigned int order,
> -		struct zonelist *zonelist)
> +__alloc_pages(gfp_t gfp_mask, unsigned int order, int preferred_nid)
>  {
> -	return __alloc_pages_nodemask(gfp_mask, order, zonelist, NULL);
> +	return __alloc_pages_nodemask(gfp_mask, order, preferred_nid, NULL);
>  }
>  
>  /*
> @@ -452,7 +451,7 @@ __alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
>  	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
>  	VM_WARN_ON(!node_online(nid));
>  
> -	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
> +	return __alloc_pages(gfp_mask, order, nid);
>  }
>  
>  /*
> diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
> index 5f4d8281832b..ecb6cbeede5a 100644
> --- a/include/linux/mempolicy.h
> +++ b/include/linux/mempolicy.h
> @@ -146,7 +146,7 @@ extern void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new,
>  				enum mpol_rebind_step step);
>  extern void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new);
>  
> -extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
> +extern int huge_node(struct vm_area_struct *vma,
>  				unsigned long addr, gfp_t gfp_flags,
>  				struct mempolicy **mpol, nodemask_t **nodemask);
>  extern bool init_nodemask_of_mempolicy(nodemask_t *mask);
> @@ -269,13 +269,13 @@ static inline void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
>  {
>  }
>  
> -static inline struct zonelist *huge_zonelist(struct vm_area_struct *vma,
> +static inline int huge_node(struct vm_area_struct *vma,
>  				unsigned long addr, gfp_t gfp_flags,
>  				struct mempolicy **mpol, nodemask_t **nodemask)
>  {
>  	*mpol = NULL;
>  	*nodemask = NULL;
> -	return node_zonelist(0, gfp_flags);
> +	return 0;
>  }
>  
>  static inline bool init_nodemask_of_mempolicy(nodemask_t *m)
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index e5828875f7bb..9f1f399bb913 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -904,6 +904,8 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
>  	struct page *page = NULL;
>  	struct mempolicy *mpol;
>  	nodemask_t *nodemask;
> +	gfp_t gfp_mask;
> +	int nid;
>  	struct zonelist *zonelist;
>  	struct zone *zone;
>  	struct zoneref *z;
> @@ -924,12 +926,13 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
>  
>  retry_cpuset:
>  	cpuset_mems_cookie = read_mems_allowed_begin();
> -	zonelist = huge_zonelist(vma, address,
> -					htlb_alloc_mask(h), &mpol, &nodemask);
> +	gfp_mask = htlb_alloc_mask(h);
> +	nid = huge_node(vma, address, gfp_mask, &mpol, &nodemask);
> +	zonelist = node_zonelist(nid, gfp_mask);
>  
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
>  						MAX_NR_ZONES - 1, nodemask) {
> -		if (cpuset_zone_allowed(zone, htlb_alloc_mask(h))) {
> +		if (cpuset_zone_allowed(zone, gfp_mask)) {
>  			page = dequeue_huge_page_node(h, zone_to_nid(zone));
>  			if (page) {
>  				if (avoid_reserve)
> @@ -1545,13 +1548,13 @@ static struct page *__hugetlb_alloc_buddy_huge_page(struct hstate *h,
>  	do {
>  		struct page *page;
>  		struct mempolicy *mpol;
> -		struct zonelist *zl;
> +		int nid;
>  		nodemask_t *nodemask;
>  
>  		cpuset_mems_cookie = read_mems_allowed_begin();
> -		zl = huge_zonelist(vma, addr, gfp, &mpol, &nodemask);
> +		nid = huge_node(vma, addr, gfp, &mpol, &nodemask);
>  		mpol_cond_put(mpol);
> -		page = __alloc_pages_nodemask(gfp, order, zl, nodemask);
> +		page = __alloc_pages_nodemask(gfp, order, nid, nodemask);
>  		if (page)
>  			return page;
>  	} while (read_mems_allowed_retry(cpuset_mems_cookie));
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 717c5e301aa8..ba9e09817f37 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1596,11 +1596,9 @@ static struct page *new_node_page(struct page *page, unsigned long private,
>  		gfp_mask |= __GFP_HIGHMEM;
>  
>  	if (!nodes_empty(nmask))
> -		new_page = __alloc_pages_nodemask(gfp_mask, 0,
> -					node_zonelist(nid, gfp_mask), &nmask);
> +		new_page = __alloc_pages_nodemask(gfp_mask, 0, nid, &nmask);
>  	if (!new_page)
> -		new_page = __alloc_pages(gfp_mask, 0,
> -					node_zonelist(nid, gfp_mask));
> +		new_page = __alloc_pages(gfp_mask, 0, nid);
>  
>  	return new_page;
>  }
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index d77177c7283b..c60807625fd5 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1669,9 +1669,9 @@ static nodemask_t *policy_nodemask(gfp_t gfp, struct mempolicy *policy)
>  	return NULL;
>  }
>  
> -/* Return a zonelist indicated by gfp for node representing a mempolicy */
> -static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy,
> -	int nd)
> +/* Return the node id preferred by the given mempolicy, or the given id */
> +static int policy_node(gfp_t gfp, struct mempolicy *policy,
> +								int nd)
>  {
>  	if (policy->mode == MPOL_PREFERRED && !(policy->flags & MPOL_F_LOCAL))
>  		nd = policy->v.preferred_node;
> @@ -1684,7 +1684,7 @@ static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy,
>  		WARN_ON_ONCE(policy->mode == MPOL_BIND && (gfp & __GFP_THISNODE));
>  	}
>  
> -	return node_zonelist(nd, gfp);
> +	return nd;
>  }
>  
>  /* Do dynamic interleaving for a process */
> @@ -1791,38 +1791,37 @@ static inline unsigned interleave_nid(struct mempolicy *pol,
>  
>  #ifdef CONFIG_HUGETLBFS
>  /*
> - * huge_zonelist(@vma, @addr, @gfp_flags, @mpol)
> + * huge_node(@vma, @addr, @gfp_flags, @mpol)
>   * @vma: virtual memory area whose policy is sought
>   * @addr: address in @vma for shared policy lookup and interleave policy
>   * @gfp_flags: for requested zone
>   * @mpol: pointer to mempolicy pointer for reference counted mempolicy
>   * @nodemask: pointer to nodemask pointer for MPOL_BIND nodemask
>   *
> - * Returns a zonelist suitable for a huge page allocation and a pointer
> + * Returns a nid suitable for a huge page allocation and a pointer
>   * to the struct mempolicy for conditional unref after allocation.
>   * If the effective policy is 'BIND, returns a pointer to the mempolicy's
>   * @nodemask for filtering the zonelist.
>   *
>   * Must be protected by read_mems_allowed_begin()
>   */
> -struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
> -				gfp_t gfp_flags, struct mempolicy **mpol,
> -				nodemask_t **nodemask)
> +int huge_node(struct vm_area_struct *vma, unsigned long addr, gfp_t gfp_flags,
> +				struct mempolicy **mpol, nodemask_t **nodemask)
>  {
> -	struct zonelist *zl;
> +	int nid;
>  
>  	*mpol = get_vma_policy(vma, addr);
>  	*nodemask = NULL;	/* assume !MPOL_BIND */
>  
>  	if (unlikely((*mpol)->mode == MPOL_INTERLEAVE)) {
> -		zl = node_zonelist(interleave_nid(*mpol, vma, addr,
> -				huge_page_shift(hstate_vma(vma))), gfp_flags);
> +		nid = interleave_nid(*mpol, vma, addr,
> +					huge_page_shift(hstate_vma(vma)));
>  	} else {
> -		zl = policy_zonelist(gfp_flags, *mpol, numa_node_id());
> +		nid = policy_node(gfp_flags, *mpol, numa_node_id());
>  		if ((*mpol)->mode == MPOL_BIND)
>  			*nodemask = &(*mpol)->v.nodes;
>  	}
> -	return zl;
> +	return nid;
>  }
>  
>  /*
> @@ -1924,12 +1923,10 @@ bool mempolicy_nodemask_intersects(struct task_struct *tsk,
>  static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
>  					unsigned nid)
>  {
> -	struct zonelist *zl;
>  	struct page *page;
>  
> -	zl = node_zonelist(nid, gfp);
> -	page = __alloc_pages(gfp, order, zl);
> -	if (page && page_zone(page) == zonelist_zone(&zl->_zonerefs[0]))
> +	page = __alloc_pages(gfp, order, nid);
> +	if (page && page_to_nid(page) == nid)
>  		inc_zone_page_state(page, NUMA_INTERLEAVE_HIT);
>  	return page;
>  }
> @@ -1963,8 +1960,8 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
>  {
>  	struct mempolicy *pol;
>  	struct page *page;
> +	int preferred_nid;
>  	unsigned int cpuset_mems_cookie;
> -	struct zonelist *zl;
>  	nodemask_t *nmask;
>  
>  retry_cpuset:
> @@ -2007,8 +2004,8 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
>  	}
>  
>  	nmask = policy_nodemask(gfp, pol);
> -	zl = policy_zonelist(gfp, pol, node);
> -	page = __alloc_pages_nodemask(gfp, order, zl, nmask);
> +	preferred_nid = policy_node(gfp, pol, node);
> +	page = __alloc_pages_nodemask(gfp, order, preferred_nid, nmask);
>  	mpol_cond_put(pol);
>  out:
>  	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
> @@ -2055,7 +2052,7 @@ struct page *alloc_pages_current(gfp_t gfp, unsigned order)
>  		page = alloc_page_interleave(gfp, order, interleave_nodes(pol));
>  	else
>  		page = __alloc_pages_nodemask(gfp, order,
> -				policy_zonelist(gfp, pol, numa_node_id()),
> +				policy_node(gfp, pol, numa_node_id()),
>  				policy_nodemask(gfp, pol));
>  
>  	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 43aa767c3188..0aceca1076dc 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3962,12 +3962,12 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  }
>  
>  static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
> -		struct zonelist *zonelist, nodemask_t *nodemask,
> +		int preferred_nid, nodemask_t *nodemask,
>  		struct alloc_context *ac, gfp_t *alloc_mask,
>  		unsigned int *alloc_flags)
>  {
>  	ac->high_zoneidx = gfp_zone(gfp_mask);
> -	ac->zonelist = zonelist;
> +	ac->zonelist = node_zonelist(preferred_nid, gfp_mask);
>  	ac->nodemask = nodemask;
>  	ac->migratetype = gfpflags_to_migratetype(gfp_mask);
>  
> @@ -4012,8 +4012,8 @@ static inline void finalise_ac(gfp_t gfp_mask,
>   * This is the 'heart' of the zoned buddy allocator.
>   */
>  struct page *
> -__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
> -			struct zonelist *zonelist, nodemask_t *nodemask)
> +__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
> +							nodemask_t *nodemask)
>  {
>  	struct page *page;
>  	unsigned int alloc_flags = ALLOC_WMARK_LOW;
> @@ -4021,7 +4021,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  	struct alloc_context ac = { };
>  
>  	gfp_mask &= gfp_allowed_mask;
> -	if (!prepare_alloc_pages(gfp_mask, order, zonelist, nodemask, &ac, &alloc_mask, &alloc_flags))
> +	if (!prepare_alloc_pages(gfp_mask, order, preferred_nid, nodemask, &ac, &alloc_mask, &alloc_flags))
>  		return NULL;
>  
>  	finalise_ac(gfp_mask, order, &ac);
> -- 
> 2.12.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
