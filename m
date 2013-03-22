Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 80C516B0075
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 16:24:35 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 07/10] mbind: add hugepage migration code to mbind()
Date: Fri, 22 Mar 2013 16:23:52 -0400
Message-Id: <1363983835-20184-8-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org

This patch extends do_mbind() to handle vma with VM_HUGETLB set.
We will be able to migrate hugepage with mbind(2) after
applying the enablement patch which comes later in this series.

ChangeLog v2:
 - updated description and renamed patch title

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/hugetlb.h |  3 +++
 mm/hugetlb.c            |  2 +-
 mm/mempolicy.c          | 10 ++++------
 mm/migrate.c            |  7 ++++++-
 4 files changed, 14 insertions(+), 8 deletions(-)

diff --git v3.9-rc3.orig/include/linux/hugetlb.h v3.9-rc3/include/linux/hugetlb.h
index 3c62b82..981eff8 100644
--- v3.9-rc3.orig/include/linux/hugetlb.h
+++ v3.9-rc3/include/linux/hugetlb.h
@@ -261,6 +261,8 @@ struct huge_bootmem_page {
 #endif
 };
 
+struct page *alloc_huge_page(struct vm_area_struct *vma,
+				unsigned long addr, int avoid_reserve);
 struct page *alloc_huge_page_node(struct hstate *h, int nid);
 
 /* arch callback */
@@ -356,6 +358,7 @@ static inline int hstate_index(struct hstate *h)
 
 #else
 struct hstate {};
+#define alloc_huge_page(v, a, r) NULL
 #define alloc_huge_page_node(h, nid) NULL
 #define alloc_bootmem_huge_page(h) NULL
 #define hstate_file(f) NULL
diff --git v3.9-rc3.orig/mm/hugetlb.c v3.9-rc3/mm/hugetlb.c
index 99ef969..d9d3dd7 100644
--- v3.9-rc3.orig/mm/hugetlb.c
+++ v3.9-rc3/mm/hugetlb.c
@@ -1117,7 +1117,7 @@ static void vma_commit_reservation(struct hstate *h,
 	}
 }
 
-static struct page *alloc_huge_page(struct vm_area_struct *vma,
+struct page *alloc_huge_page(struct vm_area_struct *vma,
 				    unsigned long addr, int avoid_reserve)
 {
 	struct hugepage_subpool *spool = subpool_vma(vma);
diff --git v3.9-rc3.orig/mm/mempolicy.c v3.9-rc3/mm/mempolicy.c
index b9e323e..ffba2ee 100644
--- v3.9-rc3.orig/mm/mempolicy.c
+++ v3.9-rc3/mm/mempolicy.c
@@ -1173,6 +1173,8 @@ static struct page *new_vma_page(struct page *page, unsigned long private, int *
 		vma = vma->vm_next;
 	}
 
+	if (PageHuge(page))
+		return alloc_huge_page(vma, address, 1);
 	/*
 	 * if !vma, alloc_page_vma() will use task or system default policy
 	 */
@@ -1277,14 +1279,10 @@ static long do_mbind(unsigned long start, unsigned long len,
 	if (!err) {
 		int nr_failed = 0;
 
-		if (!list_empty(&pagelist)) {
-			WARN_ON_ONCE(flags & MPOL_MF_LAZY);
-			nr_failed = migrate_pages(&pagelist, new_vma_page,
+		WARN_ON_ONCE(flags & MPOL_MF_LAZY);
+		nr_failed = migrate_movable_pages(&pagelist, new_vma_page,
 					(unsigned long)vma,
 					MIGRATE_SYNC, MR_MEMPOLICY_MBIND);
-			if (nr_failed)
-				putback_lru_pages(&pagelist);
-		}
 
 		if (nr_failed && (flags & MPOL_MF_STRICT))
 			err = -EIO;
diff --git v3.9-rc3.orig/mm/migrate.c v3.9-rc3/mm/migrate.c
index ef8e4e3..e64cd55 100644
--- v3.9-rc3.orig/mm/migrate.c
+++ v3.9-rc3/mm/migrate.c
@@ -951,7 +951,12 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	struct page *new_hpage = get_new_page(hpage, private, &result);
 	struct anon_vma *anon_vma = NULL;
 
-	if (!new_hpage)
+	/*
+	 * Getting a new hugepage with alloc_huge_page() (which can happen
+	 * when migration is caused by mbind()) can return ERR_PTR value,
+	 * so we need take care of the case here.
+	 */
+	if (!new_hpage || IS_ERR_VALUE(new_hpage))
 		return -ENOMEM;
 
 	rc = -EAGAIN;
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
