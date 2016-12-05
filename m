Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id BF8316B0266
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 04:18:35 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id v84so538728637oie.0
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 01:18:35 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0061.outbound.protection.outlook.com. [104.47.2.61])
        by mx.google.com with ESMTPS id w3si6653044ota.265.2016.12.05.01.18.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 05 Dec 2016 01:18:35 -0800 (PST)
From: Huang Shijie <shijie.huang@arm.com>
Subject: [PATCH v3 3/4] mm: hugetlb: change the return type for some functions
Date: Mon, 5 Dec 2016 17:17:10 +0800
Message-ID: <1480929431-22348-4-git-send-email-shijie.huang@arm.com>
In-Reply-To: <1480929431-22348-1-git-send-email-shijie.huang@arm.com>
References: <1480929431-22348-1-git-send-email-shijie.huang@arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, catalin.marinas@arm.com
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org, vbabka@suze.cz, Huang Shijie <shijie.huang@arm.com>

This patch changes the return type to "struct page*" for
alloc_fresh_gigantic_page()/alloc_fresh_huge_page().

This patch makes preparation for later patch.

Signed-off-by: Huang Shijie <shijie.huang@arm.com>
---
 mm/hugetlb.c | 29 ++++++++++++++---------------
 1 file changed, 14 insertions(+), 15 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index b7c73a1..1395bef 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1148,7 +1148,7 @@ static struct page *alloc_fresh_gigantic_page_node(struct hstate *h,
 	return page;
 }
 
-static int alloc_fresh_gigantic_page(struct hstate *h,
+static struct page *alloc_fresh_gigantic_page(struct hstate *h,
 				nodemask_t *nodes_allowed, bool do_prep)
 {
 	struct page *page = NULL;
@@ -1157,10 +1157,10 @@ static int alloc_fresh_gigantic_page(struct hstate *h,
 	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
 		page = alloc_fresh_gigantic_page_node(h, node, do_prep);
 		if (page)
-			return 1;
+			return page;
 	}
 
-	return 0;
+	return NULL;
 }
 
 static inline bool gigantic_page_supported(void) { return true; }
@@ -1173,8 +1173,8 @@ static inline bool gigantic_page_supported(void) { return false; }
 static inline void free_gigantic_page(struct page *page, unsigned int order) { }
 static inline void destroy_compound_gigantic_page(struct page *page,
 						unsigned int order) { }
-static inline int alloc_fresh_gigantic_page(struct hstate *h,
-		nodemask_t *nodes_allowed, bool do_prep) { return 0; }
+static inline struct page *alloc_fresh_gigantic_page(struct hstate *h,
+		nodemask_t *nodes_allowed, bool do_prep) { return NULL; }
 #endif
 
 static void update_and_free_page(struct hstate *h, struct page *page)
@@ -1387,26 +1387,24 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
 	return page;
 }
 
-static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
+static struct page *alloc_fresh_huge_page(struct hstate *h,
+					nodemask_t *nodes_allowed)
 {
-	struct page *page;
+	struct page *page = NULL;
 	int nr_nodes, node;
-	int ret = 0;
 
 	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
 		page = alloc_fresh_huge_page_node(h, node);
-		if (page) {
-			ret = 1;
+		if (page)
 			break;
-		}
 	}
 
-	if (ret)
+	if (page)
 		count_vm_event(HTLB_BUDDY_PGALLOC);
 	else
 		count_vm_event(HTLB_BUDDY_PGALLOC_FAIL);
 
-	return ret;
+	return page;
 }
 
 /*
@@ -2321,9 +2319,10 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 		cond_resched();
 
 		if (hstate_is_gigantic(h))
-			ret = alloc_fresh_gigantic_page(h, nodes_allowed, true);
+			ret = !!alloc_fresh_gigantic_page(h, nodes_allowed,
+							true);
 		else
-			ret = alloc_fresh_huge_page(h, nodes_allowed);
+			ret = !!alloc_fresh_huge_page(h, nodes_allowed);
 		spin_lock(&hugetlb_lock);
 		if (!ret)
 			goto out;
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
