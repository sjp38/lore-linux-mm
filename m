Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id D360A6B025E
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 02:09:01 -0500 (EST)
Received: by mail-pa0-f72.google.com with SMTP id ro13so82830927pac.7
        for <linux-mm@kvack.org>; Sun, 13 Nov 2016 23:09:01 -0800 (PST)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50082.outbound.protection.outlook.com. [40.107.5.82])
        by mx.google.com with ESMTPS id l11si21097457pgc.328.2016.11.13.23.09.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 13 Nov 2016 23:09:01 -0800 (PST)
From: Huang Shijie <shijie.huang@arm.com>
Subject: [PATCH v2 2/6] mm: hugetlb: add a new parameter for some functions
Date: Mon, 14 Nov 2016 15:07:35 +0800
Message-ID: <1479107259-2011-3-git-send-email-shijie.huang@arm.com>
In-Reply-To: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
References: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, catalin.marinas@arm.com
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org, Huang Shijie <shijie.huang@arm.com>

This patch adds a new parameter, the "no_init", for these functions:
   alloc_fresh_gigantic_page_node()
   alloc_fresh_gigantic_page()

The prep_new_huge_page() does some initialization for the new page.
But sometime, we do not need it to do so, such as in the surplus case
in later patch.

With this parameter, the prep_new_huge_page() can be called by needed:
   If the "no_init" is false, calls the prep_new_huge_page() in
   the alloc_fresh_gigantic_page_node();

This patch makes preparation for the later patches.

Signed-off-by: Huang Shijie <shijie.huang@arm.com>
---
 mm/hugetlb.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 496b703..db0177b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1127,27 +1127,29 @@ static struct page *alloc_gigantic_page(int nid, unsigned int order)
 static void prep_new_huge_page(struct hstate *h, struct page *page, int nid);
 static void prep_compound_gigantic_page(struct page *page, unsigned int order);
 
-static struct page *alloc_fresh_gigantic_page_node(struct hstate *h, int nid)
+static struct page *alloc_fresh_gigantic_page_node(struct hstate *h,
+					int nid, bool no_init)
 {
 	struct page *page;
 
 	page = alloc_gigantic_page(nid, huge_page_order(h));
 	if (page) {
 		prep_compound_gigantic_page(page, huge_page_order(h));
-		prep_new_huge_page(h, page, nid);
+		if (!no_init)
+			prep_new_huge_page(h, page, nid);
 	}
 
 	return page;
 }
 
 static int alloc_fresh_gigantic_page(struct hstate *h,
-				nodemask_t *nodes_allowed)
+				nodemask_t *nodes_allowed, bool no_init)
 {
 	struct page *page = NULL;
 	int nr_nodes, node;
 
 	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
-		page = alloc_fresh_gigantic_page_node(h, node);
+		page = alloc_fresh_gigantic_page_node(h, node, no_init);
 		if (page)
 			return 1;
 	}
@@ -1166,7 +1168,7 @@ static inline void free_gigantic_page(struct page *page, unsigned int order) { }
 static inline void destroy_compound_gigantic_page(struct page *page,
 						unsigned int order) { }
 static inline int alloc_fresh_gigantic_page(struct hstate *h,
-					nodemask_t *nodes_allowed) { return 0; }
+		nodemask_t *nodes_allowed, bool no_init) { return 0; }
 #endif
 
 static void update_and_free_page(struct hstate *h, struct page *page)
@@ -2313,7 +2315,8 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 		cond_resched();
 
 		if (hstate_is_gigantic(h))
-			ret = alloc_fresh_gigantic_page(h, nodes_allowed);
+			ret = alloc_fresh_gigantic_page(h, nodes_allowed,
+							false);
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
