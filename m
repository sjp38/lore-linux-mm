Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 6FD106B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 21:15:42 -0400 (EDT)
Date: Wed, 14 Aug 2013 21:15:14 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1376529314-kmsjzry-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130814164100.e4ba87e694e3c6563c91bf0e@linux-foundation.org>
References: <1376025702-14818-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1376025702-14818-4-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130814164100.e4ba87e694e3c6563c91bf0e@linux-foundation.org>
Subject: Re: [PATCH 3/9] migrate: add hugepage migration code to
 migrate_pages()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, Aug 14, 2013 at 04:41:00PM -0700, Andrew Morton wrote:
> On Fri,  9 Aug 2013 01:21:36 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > +static void check_hugetlb_pmd_range(struct vm_area_struct *vma, pmd_t *pmd,
> > +		const nodemask_t *nodes, unsigned long flags,
> > +				    void *private)
> > +{
> > +#ifdef CONFIG_HUGETLB_PAGE
> > +	int nid;
> > +	struct page *page;
> > +
> > +	spin_lock(&vma->vm_mm->page_table_lock);
> > +	page = pte_page(huge_ptep_get((pte_t *)pmd));
> > +	nid = page_to_nid(page);
> > +	if (node_isset(nid, *nodes) == !!(flags & MPOL_MF_INVERT))
> > +		goto unlock;
> > +	/* With MPOL_MF_MOVE, we migrate only unshared hugepage. */
> > +	if (flags & (MPOL_MF_MOVE_ALL) ||
> > +	    (flags & MPOL_MF_MOVE && page_mapcount(page) == 1))
> > +		isolate_huge_page(page, private);
> > +unlock:
> > +	spin_unlock(&vma->vm_mm->page_table_lock);
> > +#else
> > +	BUG();
> > +#endif
> > +}
> 
> The function is poorly named.  What does it "check"?  And it does more
> than checking things - at actually makes alterations!

I named like this because it became a new member of check_range() family.
So it's better to rename all of the family. An attached patch does this.

> Can we have a better name here please, and some docmentation explaining
> what it does and why it does it?

I also added some comment on check_range().

Thanks,
Naoya
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Wed, 14 Aug 2013 20:28:35 -0400
Subject: [PATCH] mempolicy: rename check_*range to queue_pages_*range

The function check_range() (and its family) is not well-named, because
it does not only checking something, but moving pages from list to list
to do page migration for them.
So queue_pages_*range is more desirable name.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/mempolicy.c | 41 +++++++++++++++++++++++------------------
 1 file changed, 23 insertions(+), 18 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 4a03c14..dca5225 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -473,8 +473,11 @@ static const struct mempolicy_operations mpol_ops[MPOL_MAX] = {
 static void migrate_page_add(struct page *page, struct list_head *pagelist,
 				unsigned long flags);
 
-/* Scan through pages checking if pages follow certain conditions. */
-static int check_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
+/*
+ * Scan through pages checking if pages follow certain conditions,
+ * and move them to the pagelist if they do.
+ */
+static int queue_pages_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, unsigned long end,
 		const nodemask_t *nodes, unsigned long flags,
 		void *private)
@@ -512,8 +515,8 @@ static int check_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 	return addr != end;
 }
 
-static void check_hugetlb_pmd_range(struct vm_area_struct *vma, pmd_t *pmd,
-		const nodemask_t *nodes, unsigned long flags,
+static void queue_pages_hugetlb_pmd_range(struct vm_area_struct *vma,
+		pmd_t *pmd, const nodemask_t *nodes, unsigned long flags,
 				    void *private)
 {
 #ifdef CONFIG_HUGETLB_PAGE
@@ -536,7 +539,7 @@ static void check_hugetlb_pmd_range(struct vm_area_struct *vma, pmd_t *pmd,
 #endif
 }
 
-static inline int check_pmd_range(struct vm_area_struct *vma, pud_t *pud,
+static inline int queue_pages_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 		unsigned long addr, unsigned long end,
 		const nodemask_t *nodes, unsigned long flags,
 		void *private)
@@ -548,21 +551,21 @@ static inline int check_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 	do {
 		next = pmd_addr_end(addr, end);
 		if (pmd_huge(*pmd) && is_vm_hugetlb_page(vma)) {
-			check_hugetlb_pmd_range(vma, pmd, nodes,
+			queue_pages_hugetlb_pmd_range(vma, pmd, nodes,
 						flags, private);
 			continue;
 		}
 		split_huge_page_pmd(vma, addr, pmd);
 		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
 			continue;
-		if (check_pte_range(vma, pmd, addr, next, nodes,
+		if (queue_pages_pte_range(vma, pmd, addr, next, nodes,
 				    flags, private))
 			return -EIO;
 	} while (pmd++, addr = next, addr != end);
 	return 0;
 }
 
-static inline int check_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
+static inline int queue_pages_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
 		unsigned long addr, unsigned long end,
 		const nodemask_t *nodes, unsigned long flags,
 		void *private)
@@ -577,14 +580,14 @@ static inline int check_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
 			continue;
 		if (pud_none_or_clear_bad(pud))
 			continue;
-		if (check_pmd_range(vma, pud, addr, next, nodes,
+		if (queue_pages_pmd_range(vma, pud, addr, next, nodes,
 				    flags, private))
 			return -EIO;
 	} while (pud++, addr = next, addr != end);
 	return 0;
 }
 
-static inline int check_pgd_range(struct vm_area_struct *vma,
+static inline int queue_pages_pgd_range(struct vm_area_struct *vma,
 		unsigned long addr, unsigned long end,
 		const nodemask_t *nodes, unsigned long flags,
 		void *private)
@@ -597,7 +600,7 @@ static inline int check_pgd_range(struct vm_area_struct *vma,
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
-		if (check_pud_range(vma, pgd, addr, next, nodes,
+		if (queue_pages_pud_range(vma, pgd, addr, next, nodes,
 				    flags, private))
 			return -EIO;
 	} while (pgd++, addr = next, addr != end);
@@ -635,12 +638,14 @@ static unsigned long change_prot_numa(struct vm_area_struct *vma,
 #endif /* CONFIG_ARCH_USES_NUMA_PROT_NONE */
 
 /*
- * Check if all pages in a range are on a set of nodes.
- * If pagelist != NULL then isolate pages from the LRU and
- * put them on the pagelist.
+ * Walk through page tables and collect pages to be migrated.
+ *
+ * If pages found in a given range are on a set of nodes (determined by
+ * @nodes and @flags,) it's isolated and queued to the pagelist which is
+ * passed via @private.)
  */
 static struct vm_area_struct *
-check_range(struct mm_struct *mm, unsigned long start, unsigned long end,
+queue_pages_range(struct mm_struct *mm, unsigned long start, unsigned long end,
 		const nodemask_t *nodes, unsigned long flags, void *private)
 {
 	int err;
@@ -675,7 +680,7 @@ check_range(struct mm_struct *mm, unsigned long start, unsigned long end,
 		     ((flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) &&
 		      vma_migratable(vma))) {
 
-			err = check_pgd_range(vma, start, endvma, nodes,
+			err = queue_pages_pgd_range(vma, start, endvma, nodes,
 						flags, private);
 			if (err) {
 				first = ERR_PTR(err);
@@ -1041,7 +1046,7 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
 	 * space range and MPOL_MF_DISCONTIG_OK, this call can not fail.
 	 */
 	VM_BUG_ON(!(flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)));
-	check_range(mm, mm->mmap->vm_start, mm->task_size, &nmask,
+	queue_pages_range(mm, mm->mmap->vm_start, mm->task_size, &nmask,
 			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
 
 	if (!list_empty(&pagelist)) {
@@ -1279,7 +1284,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 	if (err)
 		goto mpol_out;
 
-	vma = check_range(mm, start, end, nmask,
+	vma = queue_pages_range(mm, start, end, nmask,
 			  flags | MPOL_MF_INVERT, &pagelist);
 
 	err = PTR_ERR(vma);	/* maybe ... */
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
