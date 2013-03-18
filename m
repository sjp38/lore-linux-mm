Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 9F77E6B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 11:40:59 -0400 (EDT)
Date: Mon, 18 Mar 2013 16:40:57 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 5/9] migrate: enable migrate_pages() to migrate hugepage
Message-ID: <20130318154057.GS10192@dhcp22.suse.cz>
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1361475708-25991-6-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1361475708-25991-6-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org

On Thu 21-02-13 14:41:44, Naoya Horiguchi wrote:
> This patch extends check_range() to handle vma with VM_HUGETLB set.
> With this changes, we can migrate hugepage with migrate_pages(2).
> Note that for larger hugepages (covered by pud entries, 1GB for
> x86_64 for example), we simply skip it now.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  include/linux/hugetlb.h |  6 ++++--
>  mm/hugetlb.c            | 10 ++++++++++
>  mm/mempolicy.c          | 46 ++++++++++++++++++++++++++++++++++------------
>  3 files changed, 48 insertions(+), 14 deletions(-)
> 
> diff --git v3.8.orig/include/linux/hugetlb.h v3.8/include/linux/hugetlb.h
> index 8f87115..eb33df5 100644
> --- v3.8.orig/include/linux/hugetlb.h
> +++ v3.8/include/linux/hugetlb.h
> @@ -69,6 +69,7 @@ void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
>  int dequeue_hwpoisoned_huge_page(struct page *page);
>  void putback_active_hugepage(struct page *page);
>  void putback_active_hugepages(struct list_head *l);
> +void migrate_hugepage_add(struct page *page, struct list_head *list);
>  void copy_huge_page(struct page *dst, struct page *src);
>  
>  extern unsigned long hugepages_treat_as_movable;
> @@ -88,8 +89,8 @@ struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
>  				pmd_t *pmd, int write);
>  struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
>  				pud_t *pud, int write);
> -int pmd_huge(pmd_t pmd);
> -int pud_huge(pud_t pmd);
> +extern int pmd_huge(pmd_t pmd);
> +extern int pud_huge(pud_t pmd);

extern is not needed here.

>  unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
>  		unsigned long address, unsigned long end, pgprot_t newprot);
>  
> @@ -134,6 +135,7 @@ static inline int dequeue_hwpoisoned_huge_page(struct page *page)
>  
>  #define putback_active_hugepage(p) 0
>  #define putback_active_hugepages(l) 0
> +#define migrate_hugepage_add(p, l) 0
>  static inline void copy_huge_page(struct page *dst, struct page *src)
>  {
>  }
> diff --git v3.8.orig/mm/hugetlb.c v3.8/mm/hugetlb.c
> index cb9d43b8..86ffcb7 100644
> --- v3.8.orig/mm/hugetlb.c
> +++ v3.8/mm/hugetlb.c
> @@ -3202,3 +3202,13 @@ void putback_active_hugepages(struct list_head *l)
>  	list_for_each_entry_safe(page, page2, l, lru)
>  		putback_active_hugepage(page);
>  }
> +
> +void migrate_hugepage_add(struct page *page, struct list_head *list)
> +{
> +	VM_BUG_ON(!PageHuge(page));
> +	get_page(page);
> +	spin_lock(&hugetlb_lock);

Why hugetlb_lock? Comment for this lock says that it protects
hugepage_freelists, nr_huge_pages, and free_huge_pages.

> +	list_move_tail(&page->lru, list);
> +	spin_unlock(&hugetlb_lock);
> +	return;
> +}
> diff --git v3.8.orig/mm/mempolicy.c v3.8/mm/mempolicy.c
> index e2df1c1..8627135 100644
> --- v3.8.orig/mm/mempolicy.c
> +++ v3.8/mm/mempolicy.c
> @@ -525,6 +525,27 @@ static int check_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
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
> +	spin_unlock(&vma->vm_mm->page_table_lock);

I am a bit confused why page_table_lock is used here and why it doesn't
cover the page usage.

> +	nid = page_to_nid(page);
> +	if (node_isset(nid, *nodes) != !!(flags & MPOL_MF_INVERT)
> +	    && ((flags & MPOL_MF_MOVE && page_mapcount(page) == 1)
> +		|| flags & MPOL_MF_MOVE_ALL))
> +		migrate_hugepage_add(page, private);
> +#else
> +	BUG();
> +#endif
> +}
> +
>  static inline int check_pmd_range(struct vm_area_struct *vma, pud_t *pud,
>  		unsigned long addr, unsigned long end,
>  		const nodemask_t *nodes, unsigned long flags,
> @@ -536,6 +557,11 @@ static inline int check_pmd_range(struct vm_area_struct *vma, pud_t *pud,
>  	pmd = pmd_offset(pud, addr);
>  	do {
>  		next = pmd_addr_end(addr, end);
> +		if (pmd_huge(*pmd) && is_vm_hugetlb_page(vma)) {

Why an explicit check for is_vm_hugetlb_page here? Isn't pmd_huge()
sufficient?

> +			check_hugetlb_pmd_range(vma, pmd, nodes,
> +						flags, private);
> +			continue;
> +		}
>  		split_huge_page_pmd(vma, addr, pmd);
>  		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
>  			continue;
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
