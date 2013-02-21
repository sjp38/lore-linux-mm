Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id C406C6B0008
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 14:42:43 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 1/9] migrate: add migrate_entry_wait_huge()
Date: Thu, 21 Feb 2013 14:41:40 -0500
Message-Id: <1361475708-25991-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org

When we have a page fault for the address which is backed by a hugepage
under migration, the kernel can't wait correctly until the migration
finishes. This is because pte_offset_map_lock() can't get a correct
migration entry for hugepage. This patch adds migration_entry_wait_huge()
to separate code path between normal pages and hugepages.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/hugetlb.h |  2 ++
 include/linux/swapops.h |  4 ++++
 mm/hugetlb.c            |  4 ++--
 mm/migrate.c            | 24 ++++++++++++++++++++++++
 4 files changed, 32 insertions(+), 2 deletions(-)

diff --git v3.8.orig/include/linux/hugetlb.h v3.8/include/linux/hugetlb.h
index 0c80d3f..40b27f6 100644
--- v3.8.orig/include/linux/hugetlb.h
+++ v3.8/include/linux/hugetlb.h
@@ -43,6 +43,7 @@ int hugetlb_mempolicy_sysctl_handler(struct ctl_table *, int,
 #endif
 
 int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
+int is_hugetlb_entry_migration(pte_t pte);
 int follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *,
 			struct page **, struct vm_area_struct **,
 			unsigned long *, int *, int, unsigned int flags);
@@ -109,6 +110,7 @@ static inline unsigned long hugetlb_total_pages(void)
 #define follow_hugetlb_page(m,v,p,vs,a,b,i,w)	({ BUG(); 0; })
 #define follow_huge_addr(mm, addr, write)	ERR_PTR(-EINVAL)
 #define copy_hugetlb_page_range(src, dst, vma)	({ BUG(); 0; })
+#define is_hugetlb_entry_migration(pte)		({ BUG(); 0; })
 #define hugetlb_prefault(mapping, vma)		({ BUG(); 0; })
 static inline void hugetlb_report_meminfo(struct seq_file *m)
 {
diff --git v3.8.orig/include/linux/swapops.h v3.8/include/linux/swapops.h
index 47ead51..f68efdd 100644
--- v3.8.orig/include/linux/swapops.h
+++ v3.8/include/linux/swapops.h
@@ -137,6 +137,8 @@ static inline void make_migration_entry_read(swp_entry_t *entry)
 
 extern void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
 					unsigned long address);
+extern void migration_entry_wait_huge(struct mm_struct *mm, pmd_t *pmd,
+					unsigned long address);
 #else
 
 #define make_migration_entry(page, write) swp_entry(0, 0)
@@ -148,6 +150,8 @@ static inline int is_migration_entry(swp_entry_t swp)
 static inline void make_migration_entry_read(swp_entry_t *entryp) { }
 static inline void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
 					 unsigned long address) { }
+static inline void migration_entry_wait_huge(struct mm_struct *mm, pmd_t *pmd,
+					 unsigned long address) { }
 static inline int is_write_migration_entry(swp_entry_t entry)
 {
 	return 0;
diff --git v3.8.orig/mm/hugetlb.c v3.8/mm/hugetlb.c
index 546db81..351025e 100644
--- v3.8.orig/mm/hugetlb.c
+++ v3.8/mm/hugetlb.c
@@ -2313,7 +2313,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	return -ENOMEM;
 }
 
-static int is_hugetlb_entry_migration(pte_t pte)
+int is_hugetlb_entry_migration(pte_t pte)
 {
 	swp_entry_t swp;
 
@@ -2823,7 +2823,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (ptep) {
 		entry = huge_ptep_get(ptep);
 		if (unlikely(is_hugetlb_entry_migration(entry))) {
-			migration_entry_wait(mm, (pmd_t *)ptep, address);
+			migration_entry_wait_huge(mm, (pmd_t *)ptep, address);
 			return 0;
 		} else if (unlikely(is_hugetlb_entry_hwpoisoned(entry)))
 			return VM_FAULT_HWPOISON_LARGE |
diff --git v3.8.orig/mm/migrate.c v3.8/mm/migrate.c
index 2fd8b4a..7d84f4c 100644
--- v3.8.orig/mm/migrate.c
+++ v3.8/mm/migrate.c
@@ -236,6 +236,30 @@ void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
 	pte_unmap_unlock(ptep, ptl);
 }
 
+void migration_entry_wait_huge(struct mm_struct *mm, pmd_t *pmd,
+				unsigned long address)
+{
+	spinlock_t *ptl = pte_lockptr(mm, pmd);
+	pte_t pte;
+	swp_entry_t entry;
+	struct page *page;
+
+	spin_lock(ptl);
+	pte = huge_ptep_get((pte_t *)pmd);
+	if (!is_hugetlb_entry_migration(pte))
+		goto out;
+	entry = pte_to_swp_entry(pte);
+	page = migration_entry_to_page(entry);
+	if (!get_page_unless_zero(page))
+		goto out;
+	spin_unlock(ptl);
+	wait_on_page_locked(page);
+	put_page(page);
+	return;
+out:
+	spin_unlock(ptl);
+}
+
 #ifdef CONFIG_BLOCK
 /* Returns true if all buffers are successfully locked */
 static bool buffer_migrate_lock_buffers(struct buffer_head *head,
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
