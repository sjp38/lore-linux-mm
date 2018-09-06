Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 898C16B771F
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 01:44:05 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id b8-v6so11746154oib.4
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 22:44:05 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 186-v6si2723486oih.244.2018.09.05.22.44.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 22:44:04 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w865hmRt036592
	for <linux-mm@kvack.org>; Thu, 6 Sep 2018 01:44:03 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2masqp1axm-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Sep 2018 01:44:03 -0400
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 6 Sep 2018 01:44:03 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [RFC PATCH V2 2/4] mm: Add get_user_pages_cma_migrate
Date: Thu,  6 Sep 2018 11:13:40 +0530
In-Reply-To: <20180906054342.25094-1-aneesh.kumar@linux.ibm.com>
References: <20180906054342.25094-1-aneesh.kumar@linux.ibm.com>
Message-Id: <20180906054342.25094-2-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Alexey Kardashevskiy <aik@ozlabs.ru>, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>

This helper does a get_user_pages_fast and if it find pages in the CMA area
it will try to migrate them before taking page reference. This makes sure that
we don't keep non-movable pages (due to page reference count) in the CMA area.
Not able to move pages out of CMA area result in CMA allocation failures.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 include/linux/migrate.h |   3 ++
 mm/migrate.c            | 108 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 111 insertions(+)

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
diff --git a/mm/migrate.c b/mm/migrate.c
index c27e97b5b69d..c26288d407ae 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -3008,3 +3008,111 @@ int migrate_vma(const struct migrate_vma_ops *ops,
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
+	if (PageHuge(page)) {
+
+		struct hstate *h = page_hstate(page);
+		/*
+		 * We don't want to dequeue from the pool because pool pages will
+		 * mostly be from the CMA region.
+		 */
+		return alloc_migrate_huge_page(h, gfp_mask, nid, NULL);
+
+	} else if (PageTransHuge(page)) {
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
+	}
+
+	return __alloc_pages_node(nid, gfp_mask, 0);
+}
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
