Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 050906B0261
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 04:18:32 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 3so356573663pgd.3
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 01:18:31 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0066.outbound.protection.outlook.com. [104.47.0.66])
        by mx.google.com with ESMTPS id 19si13989333pfr.164.2016.12.05.01.18.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 05 Dec 2016 01:18:31 -0800 (PST)
From: Huang Shijie <shijie.huang@arm.com>
Subject: [PATCH v3 2/4] mm: hugetlb: add a new parameter for some functions
Date: Mon, 5 Dec 2016 17:17:09 +0800
Message-ID: <1480929431-22348-3-git-send-email-shijie.huang@arm.com>
In-Reply-To: <1480929431-22348-1-git-send-email-shijie.huang@arm.com>
References: <1480929431-22348-1-git-send-email-shijie.huang@arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, catalin.marinas@arm.com
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org, vbabka@suze.cz, Huang Shijie <shijie.huang@arm.com>

This patch adds a new parameter, the "do_prep", for these functions:
   alloc_fresh_gigantic_page_node()
   alloc_fresh_gigantic_page()

The prep_new_huge_page() does some initialization for the new page.
But sometime, we do not need it to do so, such as in the surplus case
in later patch.

With this parameter, the prep_new_huge_page() can be called by needed:
   If the "do_prep" is true, calls the prep_new_huge_page() in
   the alloc_fresh_gigantic_page_node();

This patch makes preparation for the later patches.

Signed-off-by: Huang Shijie <shijie.huang@arm.com>
---
 mm/hugetlb.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 5f4213d..b7c73a1 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1133,27 +1133,29 @@ static struct page *alloc_gigantic_page(int nid, unsigned int order)
 static void prep_new_huge_page(struct hstate *h, struct page *page, int nid);
 static void prep_compound_gigantic_page(struct page *page, unsigned int order);
 
-static struct page *alloc_fresh_gigantic_page_node(struct hstate *h, int nid)
+static struct page *alloc_fresh_gigantic_page_node(struct hstate *h,
+					int nid, bool do_prep)
 {
 	struct page *page;
 
 	page = alloc_gigantic_page(nid, huge_page_order(h));
 	if (page) {
 		prep_compound_gigantic_page(page, huge_page_order(h));
-		prep_new_huge_page(h, page, nid);
+		if (do_prep)
+			prep_new_huge_page(h, page, nid);
 	}
 
 	return page;
 }
 
 static int alloc_fresh_gigantic_page(struct hstate *h,
-				nodemask_t *nodes_allowed)
+				nodemask_t *nodes_allowed, bool do_prep)
 {
 	struct page *page = NULL;
 	int nr_nodes, node;
 
 	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
-		page = alloc_fresh_gigantic_page_node(h, node);
+		page = alloc_fresh_gigantic_page_node(h, node, do_prep);
 		if (page)
 			return 1;
 	}
@@ -1172,7 +1174,7 @@ static inline void free_gigantic_page(struct page *page, unsigned int order) { }
 static inline void destroy_compound_gigantic_page(struct page *page,
 						unsigned int order) { }
 static inline int alloc_fresh_gigantic_page(struct hstate *h,
-					nodemask_t *nodes_allowed) { return 0; }
+		nodemask_t *nodes_allowed, bool do_prep) { return 0; }
 #endif
 
 static void update_and_free_page(struct hstate *h, struct page *page)
@@ -2319,7 +2321,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 		cond_resched();
 
 		if (hstate_is_gigantic(h))
-			ret = alloc_fresh_gigantic_page(h, nodes_allowed);
+			ret = alloc_fresh_gigantic_page(h, nodes_allowed, true);
 		else
 			ret = alloc_fresh_huge_page(h, nodes_allowed);
 		spin_lock(&hugetlb_lock);
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
