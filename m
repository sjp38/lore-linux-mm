Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1FA506B0328
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 04:32:41 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id f2so599951plj.15
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 01:32:41 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 81sor142453pfu.120.2018.01.03.01.32.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 01:32:39 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 6/6] hugetlb, mempolicy: fix the mbind hugetlb migration
Date: Wed,  3 Jan 2018 10:32:13 +0100
Message-Id: <20180103093213.26329-7-mhocko@kernel.org>
In-Reply-To: <20180103093213.26329-1-mhocko@kernel.org>
References: <20180103093213.26329-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

do_mbind migration code relies on alloc_huge_page_noerr for hugetlb
pages. alloc_huge_page_noerr uses alloc_huge_page which is a highlevel
allocation function which has to take care of reserves, overcommit or
hugetlb cgroup accounting.  None of that is really required for the page
migration because the new page is only temporal and either will replace
the original page or it will be dropped. This is essentially as for
other migration call paths and there shouldn't be any reason to handle
mbind in a special way.

The current implementation is even suboptimal because the migration
might fail just because the hugetlb cgroup limit is reached, or the
overcommit is saturated.

Fix this by making mbind like other hugetlb migration paths. Add
a new migration helper alloc_huge_page_vma as a wrapper around
alloc_huge_page_nodemask with additional mempolicy handling.

alloc_huge_page_noerr has no more users and it can go.

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/hugetlb.h |  5 ++---
 mm/hugetlb.c            | 33 +++++++++++++++++++--------------
 mm/mempolicy.c          |  3 +--
 3 files changed, 22 insertions(+), 19 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 66992348531e..612a29b7f6c6 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -356,10 +356,9 @@ struct huge_bootmem_page {
 struct page *alloc_huge_page(struct vm_area_struct *vma,
 				unsigned long addr, int avoid_reserve);
 struct page *alloc_huge_page_node(struct hstate *h, int nid);
-struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
-				unsigned long addr, int avoid_reserve);
 struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
 				nodemask_t *nmask);
+struct page *alloc_huge_page_vma(struct vm_area_struct *vma, unsigned long address);
 int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
 			pgoff_t idx);
 
@@ -537,7 +536,7 @@ struct hstate {};
 #define alloc_huge_page(v, a, r) NULL
 #define alloc_huge_page_node(h, nid) NULL
 #define alloc_huge_page_nodemask(h, preferred_nid, nmask) NULL
-#define alloc_huge_page_noerr(v, a, r) NULL
+#define alloc_huge_page_vma(vma, address) NULL
 #define alloc_bootmem_huge_page(h) NULL
 #define hstate_file(f) NULL
 #define hstate_sizelog(s) NULL
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 60acd3e93a95..ffcae114ceed 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1674,6 +1674,25 @@ struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
 	return alloc_migrate_huge_page(h, gfp_mask, preferred_nid, nmask);
 }
 
+/* mempolicy aware migration callback */
+struct page *alloc_huge_page_vma(struct vm_area_struct *vma, unsigned long address)
+{
+	struct mempolicy *mpol;
+	nodemask_t *nodemask;
+	struct page *page;
+	struct hstate *h;
+	gfp_t gfp_mask;
+	int node;
+
+	h = hstate_vma(vma);
+	gfp_mask = htlb_alloc_mask(h);
+	node = huge_node(vma, address, gfp_mask, &mpol, &nodemask);
+	page = alloc_huge_page_nodemask(h, node, nodemask);
+	mpol_cond_put(mpol);
+
+	return page;
+}
+
 /*
  * Increase the hugetlb pool such that it can accommodate a reservation
  * of size 'delta'.
@@ -2079,20 +2098,6 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
 	return ERR_PTR(-ENOSPC);
 }
 
-/*
- * alloc_huge_page()'s wrapper which simply returns the page if allocation
- * succeeds, otherwise NULL. This function is called from new_vma_page(),
- * where no ERR_VALUE is expected to be returned.
- */
-struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
-				unsigned long addr, int avoid_reserve)
-{
-	struct page *page = alloc_huge_page(vma, addr, avoid_reserve);
-	if (IS_ERR(page))
-		page = NULL;
-	return page;
-}
-
 int alloc_bootmem_huge_page(struct hstate *h)
 	__attribute__ ((weak, alias("__alloc_bootmem_huge_page")));
 int __alloc_bootmem_huge_page(struct hstate *h)
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index b6f4fcf9df64..30e68da64873 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1097,8 +1097,7 @@ static struct page *new_page(struct page *page, unsigned long start)
 	}
 
 	if (PageHuge(page)) {
-		BUG_ON(!vma);
-		return alloc_huge_page_noerr(vma, address, 1);
+		return alloc_huge_page_vma(vma, address);
 	} else if (PageTransHuge(page)) {
 		struct page *thp;
 
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
