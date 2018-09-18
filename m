Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 387018E000C
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 07:59:08 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id r131-v6so1450511oie.14
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 04:59:08 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e15-v6si4429924oti.441.2018.09.18.04.59.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Sep 2018 04:59:06 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8IBs1mY058236
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 07:59:04 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mjwh5gxbr-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 07:59:03 -0400
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 18 Sep 2018 07:59:02 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH V3 1/2] mm: Add get_user_pages_cma_migrate
Date: Tue, 18 Sep 2018 17:28:38 +0530
In-Reply-To: <20180918115839.22154-1-aneesh.kumar@linux.ibm.com>
References: <20180918115839.22154-1-aneesh.kumar@linux.ibm.com>
Message-Id: <20180918115839.22154-2-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Michal Hocko <mhocko@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>

This helper does a get_user_pages_fast and if it find pages in the CMA area
it will try to migrate them before taking page reference. This makes sure that
we don't keep non-movable pages (due to page reference count) in the CMA area.
Not able to move pages out of CMA area result in CMA allocation failures.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 include/linux/hugetlb.h |   2 +
 include/linux/migrate.h |   3 +
 mm/hugetlb.c            |   4 +-
 mm/migrate.c            | 132 ++++++++++++++++++++++++++++++++++++++++
 4 files changed, 139 insertions(+), 2 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 6b68e345f0ca..1abccb1a1ecc 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -357,6 +357,8 @@ struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
 				nodemask_t *nmask);
 struct page *alloc_huge_page_vma(struct hstate *h, struct vm_area_struct *vma,
 				unsigned long address);
+struct page *alloc_migrate_huge_page(struct hstate *h, gfp_t gfp_mask,
+				     int nid, nodemask_t *nmask);
 int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
 			pgoff_t idx);
 
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index f2b4abbca55e..d82b35afd2eb 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -286,6 +286,9 @@ static inline int migrate_vma(const struct migrate_vma_ops *ops,
 }
 #endif /* IS_ENABLED(CONFIG_MIGRATE_VMA_HELPER) */
 
+extern int get_user_pages_cma_migrate(unsigned long start, int nr_pages, int write,
+				      struct page **pages);
+
 #endif /* CONFIG_MIGRATION */
 
 #endif /* _LINUX_MIGRATE_H */
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3c21775f196b..1abbfcb84f66 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1585,8 +1585,8 @@ static struct page *alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
 	return page;
 }
 
-static struct page *alloc_migrate_huge_page(struct hstate *h, gfp_t gfp_mask,
-		int nid, nodemask_t *nmask)
+struct page *alloc_migrate_huge_page(struct hstate *h, gfp_t gfp_mask,
+				     int nid, nodemask_t *nmask)
 {
 	struct page *page;
 
diff --git a/mm/migrate.c b/mm/migrate.c
index d6a2e89b086a..2f92534ea7a1 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -3006,3 +3006,135 @@ int migrate_vma(const struct migrate_vma_ops *ops,
 }
 EXPORT_SYMBOL(migrate_vma);
 #endif /* defined(MIGRATE_VMA_HELPER) */
+
+static struct page *new_non_cma_page(struct page *page, unsigned long private)
+{
+	/*
+	 * We want to make sure we allocate the new page from the same node
+	 * as the source page.
+	 */
+	int nid = page_to_nid(page);
+	gfp_t gfp_mask = GFP_USER | __GFP_THISNODE;
+
+	if (PageHighMem(page))
+		gfp_mask |= __GFP_HIGHMEM;
+
+	if (PageTransHuge(page)) {
+		struct page *thp;
+		gfp_t thp_gfpmask = GFP_TRANSHUGE | __GFP_THISNODE;
+
+		/*
+		 * Remove the movable mask so that we don't allocate from
+		 * CMA area again.
+		 */
+		thp_gfpmask &= ~__GFP_MOVABLE;
+		thp = __alloc_pages_node(nid, thp_gfpmask, HPAGE_PMD_ORDER);
+		if (!thp)
+			return NULL;
+		prep_transhuge_page(thp);
+		return thp;
+
+#ifdef  CONFIG_HUGETLB_PAGE
+	} else if (PageHuge(page)) {
+
+		struct hstate *h = page_hstate(page);
+		/*
+		 * We don't want to dequeue from the pool because pool pages will
+		 * mostly be from the CMA region.
+		 */
+		return alloc_migrate_huge_page(h, gfp_mask, nid, NULL);
+#endif
+	}
+
+	return __alloc_pages_node(nid, gfp_mask, 0);
+}
+
+/**
+ * get_user_pages_cma_migrate() - pin user pages in memory by migrating pages in CMA region
+ * @start:	starting user address
+ * @nr_pages:	number of pages from start to pin
+ * @write:	whether pages will be written to
+ * @pages:	array that receives pointers to the pages pinned.
+ *		Should be at least nr_pages long.
+ *
+ * Attempt to pin user pages in memory without taking mm->mmap_sem.
+ * If not successful, it will fall back to taking the lock and
+ * calling get_user_pages().
+ *
+ * If the pinned pages are backed by CMA region, we migrate those pages out,
+ * allocating new pages from non-CMA region. This helps in avoiding keeping
+ * pages pinned in the CMA region for a long time thereby resulting in
+ * CMA allocation failures.
+ *
+ * Returns number of pages pinned. This may be fewer than the number
+ * requested. If nr_pages is 0 or negative, returns 0. If no pages
+ * were pinned, returns -errno.
+ */
+
+int get_user_pages_cma_migrate(unsigned long start, int nr_pages, int write,
+			       struct page **pages)
+{
+	int i, ret;
+	bool drain_allow = true;
+	bool migrate_allow = true;
+	LIST_HEAD(cma_page_list);
+
+get_user_again:
+	ret = get_user_pages_fast(start, nr_pages, write, pages);
+	if (ret <= 0)
+		return ret;
+
+	for (i = 0; i < ret; ++i) {
+		/*
+		 * If we get a page from the CMA zone, since we are going to
+		 * be pinning these entries, we might as well move them out
+		 * of the CMA zone if possible.
+		 */
+		if (is_migrate_cma_page(pages[i]) && migrate_allow) {
+			if (PageHuge(pages[i]))
+				isolate_huge_page(pages[i], &cma_page_list);
+			else {
+				struct page *head = compound_head(pages[i]);
+
+				if (!PageLRU(head) && drain_allow) {
+					lru_add_drain_all();
+					drain_allow = false;
+				}
+
+				if (!isolate_lru_page(head)) {
+					list_add_tail(&head->lru, &cma_page_list);
+					mod_node_page_state(page_pgdat(head),
+							    NR_ISOLATED_ANON +
+							    page_is_file_cache(head),
+							    hpage_nr_pages(head));
+				}
+			}
+		}
+	}
+	if (!list_empty(&cma_page_list)) {
+		/*
+		 * drop the above get_user_pages reference.
+		 */
+		for (i = 0; i < ret; ++i)
+			put_page(pages[i]);
+
+		if (migrate_pages(&cma_page_list, new_non_cma_page,
+				  NULL, 0, MIGRATE_SYNC, MR_CONTIG_RANGE)) {
+			/*
+			 * some of the pages failed migration. Do get_user_pages
+			 * without migration.
+			 */
+			migrate_allow = false;
+
+			if (!list_empty(&cma_page_list))
+				putback_movable_pages(&cma_page_list);
+		}
+		/*
+		 * We did migrate all the pages, Try to get the page references again
+		 * migrating any new CMA pages which we failed to isolate earlier.
+		 */
+		drain_allow = true;
+		goto get_user_again;
+	}
+	return ret;
+}
-- 
2.17.1
