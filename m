Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id ED3316B0072
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 16:24:33 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 05/10] migrate: add hugepage migration code to migrate_pages()
Date: Fri, 22 Mar 2013 16:23:50 -0400
Message-Id: <1363983835-20184-6-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org

This patch extends check_range() to handle vma with VM_HUGETLB set.
We will be able to migrate hugepage with migrate_pages(2) after
applying the enablement patch which comes later in this series.

Note that for larger hugepages (covered by pud entries, 1GB for
x86_64 for example), we simply skip it now.

ChangeLog v2:
 - remove unnecessary extern
 - fix page table lock in check_hugetlb_pmd_range
 - updated description and renamed patch title

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/hugetlb.h |  2 ++
 mm/hugetlb.c            | 10 ++++++++++
 mm/mempolicy.c          | 46 ++++++++++++++++++++++++++++++++++------------
 3 files changed, 46 insertions(+), 12 deletions(-)

diff --git v3.9-rc3.orig/include/linux/hugetlb.h v3.9-rc3/include/linux/hugetlb.h
index baa0aa0..3c62b82 100644
--- v3.9-rc3.orig/include/linux/hugetlb.h
+++ v3.9-rc3/include/linux/hugetlb.h
@@ -68,6 +68,7 @@ void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
 int dequeue_hwpoisoned_huge_page(struct page *page);
 void putback_active_hugepage(struct page *page);
 void putback_active_hugepages(struct list_head *l);
+void migrate_hugepage_add(struct page *page, struct list_head *list);
 void copy_huge_page(struct page *dst, struct page *src);
 
 extern unsigned long hugepages_treat_as_movable;
@@ -132,6 +133,7 @@ static inline int dequeue_hwpoisoned_huge_page(struct page *page)
 
 #define putback_active_hugepage(p) 0
 #define putback_active_hugepages(l) 0
+#define migrate_hugepage_add(p, l) 0
 static inline void copy_huge_page(struct page *dst, struct page *src)
 {
 }
diff --git v3.9-rc3.orig/mm/hugetlb.c v3.9-rc3/mm/hugetlb.c
index a787c44..99ef969 100644
--- v3.9-rc3.orig/mm/hugetlb.c
+++ v3.9-rc3/mm/hugetlb.c
@@ -3201,3 +3201,13 @@ void putback_active_hugepages(struct list_head *l)
 	list_for_each_entry_safe(page, page2, l, lru)
 		putback_active_hugepage(page);
 }
+
+void migrate_hugepage_add(struct page *page, struct list_head *list)
+{
+	VM_BUG_ON(!PageHead(page));
+	get_page(page);
+	spin_lock(&hugetlb_lock);
+	list_move_tail(&page->lru, list);
+	spin_unlock(&hugetlb_lock);
+	return;
+}
diff --git v3.9-rc3.orig/mm/mempolicy.c v3.9-rc3/mm/mempolicy.c
index 7431001..b9e323e 100644
--- v3.9-rc3.orig/mm/mempolicy.c
+++ v3.9-rc3/mm/mempolicy.c
@@ -512,6 +512,27 @@ static int check_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 	return addr != end;
 }
 
+static void check_hugetlb_pmd_range(struct vm_area_struct *vma, pmd_t *pmd,
+		const nodemask_t *nodes, unsigned long flags,
+				    void *private)
+{
+#ifdef CONFIG_HUGETLB_PAGE
+	int nid;
+	struct page *page;
+
+	spin_lock(&vma->vm_mm->page_table_lock);
+	page = pte_page(huge_ptep_get((pte_t *)pmd));
+	nid = page_to_nid(page);
+	if (node_isset(nid, *nodes) != !!(flags & MPOL_MF_INVERT)
+	    && ((flags & MPOL_MF_MOVE && page_mapcount(page) == 1)
+		|| flags & MPOL_MF_MOVE_ALL))
+		migrate_hugepage_add(page, private);
+	spin_unlock(&vma->vm_mm->page_table_lock);
+#else
+	BUG();
+#endif
+}
+
 static inline int check_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 		unsigned long addr, unsigned long end,
 		const nodemask_t *nodes, unsigned long flags,
@@ -523,6 +544,11 @@ static inline int check_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
+		if (pmd_huge(*pmd) && is_vm_hugetlb_page(vma)) {
+			check_hugetlb_pmd_range(vma, pmd, nodes,
+						flags, private);
+			continue;
+		}
 		split_huge_page_pmd(vma, addr, pmd);
 		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
 			continue;
@@ -544,6 +570,8 @@ static inline int check_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
 	pud = pud_offset(pgd, addr);
 	do {
 		next = pud_addr_end(addr, end);
+		if (pud_huge(*pud) && is_vm_hugetlb_page(vma))
+			continue;
 		if (pud_none_or_clear_bad(pud))
 			continue;
 		if (check_pmd_range(vma, pud, addr, next, nodes,
@@ -635,9 +663,6 @@ check_range(struct mm_struct *mm, unsigned long start, unsigned long end,
 				return ERR_PTR(-EFAULT);
 		}
 
-		if (is_vm_hugetlb_page(vma))
-			goto next;
-
 		if (flags & MPOL_MF_LAZY) {
 			change_prot_numa(vma, start, endvma);
 			goto next;
@@ -986,7 +1011,11 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
 
 static struct page *new_node_page(struct page *page, unsigned long node, int **x)
 {
-	return alloc_pages_exact_node(node, GFP_HIGHUSER_MOVABLE, 0);
+	if (PageHuge(page))
+		return alloc_huge_page_node(page_hstate(compound_head(page)),
+					node);
+	else
+		return alloc_pages_exact_node(node, GFP_HIGHUSER_MOVABLE, 0);
 }
 
 /*
@@ -998,7 +1027,6 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
 {
 	nodemask_t nmask;
 	LIST_HEAD(pagelist);
-	int err = 0;
 
 	nodes_clear(nmask);
 	node_set(source, nmask);
@@ -1012,14 +1040,8 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
 	check_range(mm, mm->mmap->vm_start, mm->task_size, &nmask,
 			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
 
-	if (!list_empty(&pagelist)) {
-		err = migrate_pages(&pagelist, new_node_page, dest,
+	return migrate_movable_pages(&pagelist, new_node_page, dest,
 					MIGRATE_SYNC, MR_SYSCALL);
-		if (err)
-			putback_lru_pages(&pagelist);
-	}
-
-	return err;
 }
 
 /*
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
