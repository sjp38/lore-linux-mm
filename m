From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/8] migrate: add hugepage migration code to
 migrate_pages()
Date: Wed, 24 Jul 2013 11:33:18 +0800
Message-ID: <9357.13628209687$1374636822@news.gmane.org>
References: <1374183272-10153-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1374183272-10153-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1V1ppU-0006PZ-JN
	for glkm-linux-mm-2@m.gmane.org; Wed, 24 Jul 2013 05:33:33 +0200
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 610C16B0031
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 23:33:29 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 24 Jul 2013 13:30:25 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 259622CE804D
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 13:33:22 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6O3HvbG8978712
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 13:17:58 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6O3XJmL027467
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 13:33:21 +1000
Content-Disposition: inline
In-Reply-To: <1374183272-10153-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Jul 18, 2013 at 05:34:27PM -0400, Naoya Horiguchi wrote:
>This patch extends check_range() to handle vma with VM_HUGETLB set.
>We will be able to migrate hugepage with migrate_pages(2) after
>applying the enablement patch which comes later in this series.
>
>Note that for larger hugepages (covered by pud entries, 1GB for
>x86_64 for example), we simply skip it now.
>
>Note that using pmd_huge/pud_huge assumes that hugepages are pointed to
>by pmd/pud. This is not true in some architectures implementing hugepage
>with other mechanisms like ia64, but it's OK because pmd_huge/pud_huge
>simply return 0 in such arch and page walker simply ignores such hugepages.
>
>ChangeLog v3:
> - revert introducing migrate_movable_pages
> - use isolate_huge_page
>
>ChangeLog v2:
> - remove unnecessary extern
> - fix page table lock in check_hugetlb_pmd_range
> - updated description and renamed patch title
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>---
> mm/mempolicy.c | 39 ++++++++++++++++++++++++++++++++++-----
> 1 file changed, 34 insertions(+), 5 deletions(-)
>
>diff --git v3.11-rc1.orig/mm/mempolicy.c v3.11-rc1/mm/mempolicy.c
>index 7431001..f3b65c0 100644
>--- v3.11-rc1.orig/mm/mempolicy.c
>+++ v3.11-rc1/mm/mempolicy.c
>@@ -512,6 +512,27 @@ static int check_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
> 	return addr != end;
> }
>
>+static void check_hugetlb_pmd_range(struct vm_area_struct *vma, pmd_t *pmd,
>+		const nodemask_t *nodes, unsigned long flags,
>+				    void *private)
>+{
>+#ifdef CONFIG_HUGETLB_PAGE
>+	int nid;
>+	struct page *page;
>+
>+	spin_lock(&vma->vm_mm->page_table_lock);
>+	page = pte_page(huge_ptep_get((pte_t *)pmd));
>+	nid = page_to_nid(page);
>+	if (node_isset(nid, *nodes) != !!(flags & MPOL_MF_INVERT)
>+	    && ((flags & MPOL_MF_MOVE && page_mapcount(page) == 1)
>+		|| flags & MPOL_MF_MOVE_ALL))
>+		isolate_huge_page(page, private);
>+	spin_unlock(&vma->vm_mm->page_table_lock);
>+#else
>+	BUG();
>+#endif
>+}
>+
> static inline int check_pmd_range(struct vm_area_struct *vma, pud_t *pud,
> 		unsigned long addr, unsigned long end,
> 		const nodemask_t *nodes, unsigned long flags,
>@@ -523,6 +544,11 @@ static inline int check_pmd_range(struct vm_area_struct *vma, pud_t *pud,
> 	pmd = pmd_offset(pud, addr);
> 	do {
> 		next = pmd_addr_end(addr, end);
>+		if (pmd_huge(*pmd) && is_vm_hugetlb_page(vma)) {
>+			check_hugetlb_pmd_range(vma, pmd, nodes,
>+						flags, private);
>+			continue;
>+		}
> 		split_huge_page_pmd(vma, addr, pmd);
> 		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
> 			continue;
>@@ -544,6 +570,8 @@ static inline int check_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
> 	pud = pud_offset(pgd, addr);
> 	do {
> 		next = pud_addr_end(addr, end);
>+		if (pud_huge(*pud) && is_vm_hugetlb_page(vma))
>+			continue;
> 		if (pud_none_or_clear_bad(pud))
> 			continue;
> 		if (check_pmd_range(vma, pud, addr, next, nodes,
>@@ -635,9 +663,6 @@ check_range(struct mm_struct *mm, unsigned long start, unsigned long end,
> 				return ERR_PTR(-EFAULT);
> 		}
>
>-		if (is_vm_hugetlb_page(vma))
>-			goto next;
>-
> 		if (flags & MPOL_MF_LAZY) {
> 			change_prot_numa(vma, start, endvma);
> 			goto next;
>@@ -986,7 +1011,11 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
>
> static struct page *new_node_page(struct page *page, unsigned long node, int **x)
> {
>-	return alloc_pages_exact_node(node, GFP_HIGHUSER_MOVABLE, 0);
>+	if (PageHuge(page))
>+		return alloc_huge_page_node(page_hstate(compound_head(page)),
>+					node);
>+	else
>+		return alloc_pages_exact_node(node, GFP_HIGHUSER_MOVABLE, 0);
> }
>
> /*
>@@ -1016,7 +1045,7 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
> 		err = migrate_pages(&pagelist, new_node_page, dest,
> 					MIGRATE_SYNC, MR_SYSCALL);
> 		if (err)
>-			putback_lru_pages(&pagelist);
>+			putback_movable_pages(&pagelist);
> 	}
>
> 	return err;
>-- 
>1.8.3.1
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
