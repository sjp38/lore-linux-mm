Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id C759D6B003B
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 10:33:31 -0400 (EDT)
Date: Tue, 10 Sep 2013 15:33:26 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/9] migrate: add hugepage migration code to
 migrate_pages()
Message-ID: <20130910143326.GQ22421@suse.de>
References: <1376025702-14818-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1376025702-14818-4-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1376025702-14818-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Aug 09, 2013 at 01:21:36AM -0400, Naoya Horiguchi wrote:
> This patch extends check_range() to handle vma with VM_HUGETLB set.
> We will be able to migrate hugepage with migrate_pages(2) after
> applying the enablement patch which comes later in this series.
> 
> Note that for larger hugepages (covered by pud entries, 1GB for
> x86_64 for example), we simply skip it now.
> 
> Note that using pmd_huge/pud_huge assumes that hugepages are pointed to
> by pmd/pud. This is not true in some architectures implementing hugepage
> with other mechanisms like ia64, but it's OK because pmd_huge/pud_huge
> simply return 0 in such arch and page walker simply ignores such hugepages.
> 
> ChangeLog v4:
>  - refactored check_hugetlb_pmd_range for better readability
> 
> ChangeLog v3:
>  - revert introducing migrate_movable_pages
>  - use isolate_huge_page
> 
> ChangeLog v2:
>  - remove unnecessary extern
>  - fix page table lock in check_hugetlb_pmd_range
>  - updated description and renamed patch title
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: Andi Kleen <ak@linux.intel.com>
> Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> Acked-by: Hillf Danton <dhillf@gmail.com>
> ---
>  mm/mempolicy.c | 42 +++++++++++++++++++++++++++++++++++++-----
>  1 file changed, 37 insertions(+), 5 deletions(-)
> 
> diff --git v3.11-rc3.orig/mm/mempolicy.c v3.11-rc3/mm/mempolicy.c
> index 7431001..d96afc1 100644
> --- v3.11-rc3.orig/mm/mempolicy.c
> +++ v3.11-rc3/mm/mempolicy.c
> @@ -512,6 +512,30 @@ static int check_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  	return addr != end;
>  }
>  
> +static void check_hugetlb_pmd_range(struct vm_area_struct *vma, pmd_t *pmd,
> +		const nodemask_t *nodes, unsigned long flags,
> +				    void *private)
> +{
> +#ifdef CONFIG_HUGETLB_PAGE
> +	int nid;
> +	struct page *page;
> +
> +	spin_lock(&vma->vm_mm->page_table_lock);
> +	page = pte_page(huge_ptep_get((pte_t *)pmd));
> +	nid = page_to_nid(page);
> +	if (node_isset(nid, *nodes) == !!(flags & MPOL_MF_INVERT))
> +		goto unlock;
> +	/* With MPOL_MF_MOVE, we migrate only unshared hugepage. */
> +	if (flags & (MPOL_MF_MOVE_ALL) ||
> +	    (flags & MPOL_MF_MOVE && page_mapcount(page) == 1))
> +		isolate_huge_page(page, private);
> +unlock:
> +	spin_unlock(&vma->vm_mm->page_table_lock);
> +#else
> +	BUG();
> +#endif
> +}
> +
>  static inline int check_pmd_range(struct vm_area_struct *vma, pud_t *pud,
>  		unsigned long addr, unsigned long end,
>  		const nodemask_t *nodes, unsigned long flags,
> @@ -523,6 +547,11 @@ static inline int check_pmd_range(struct vm_area_struct *vma, pud_t *pud,
>  	pmd = pmd_offset(pud, addr);
>  	do {
>  		next = pmd_addr_end(addr, end);
> +		if (pmd_huge(*pmd) && is_vm_hugetlb_page(vma)) {
> +			check_hugetlb_pmd_range(vma, pmd, nodes,
> +						flags, private);
> +			continue;
> +		}
>  		split_huge_page_pmd(vma, addr, pmd);
>  		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
>  			continue;

If a hugepage is currently being migrated then a migration entry should
be in its place which is a type of swap entry. Will the pmd_huge check
still do the right thing if migration is already in progress?

>  		if (check_pmd_range(vma, pud, addr, next, nodes,
> @@ -635,9 +666,6 @@ check_range(struct mm_struct *mm, unsigned long start, unsigned long end,
>  				return ERR_PTR(-EFAULT);
>  		}
>  
> -		if (is_vm_hugetlb_page(vma))
> -			goto next;
> -
>  		if (flags & MPOL_MF_LAZY) {
>  			change_prot_numa(vma, start, endvma);
>  			goto next;
> @@ -986,7 +1014,11 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
>  
>  static struct page *new_node_page(struct page *page, unsigned long node, int **x)
>  {
> -	return alloc_pages_exact_node(node, GFP_HIGHUSER_MOVABLE, 0);
> +	if (PageHuge(page))
> +		return alloc_huge_page_node(page_hstate(compound_head(page)),
> +					node);
> +	else
> +		return alloc_pages_exact_node(node, GFP_HIGHUSER_MOVABLE, 0);
>  }
>  
>  /*
> @@ -1016,7 +1048,7 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
>  		err = migrate_pages(&pagelist, new_node_page, dest,
>  					MIGRATE_SYNC, MR_SYSCALL);
>  		if (err)
> -			putback_lru_pages(&pagelist);
> +			putback_movable_pages(&pagelist);
>  	}
>  
>  	return err;
> -- 
> 1.8.3.1
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
