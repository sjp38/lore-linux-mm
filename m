Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD6046B0260
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 02:09:05 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id g186so69217744pgc.2
        for <linux-mm@kvack.org>; Sun, 13 Nov 2016 23:09:05 -0800 (PST)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10062.outbound.protection.outlook.com. [40.107.1.62])
        by mx.google.com with ESMTPS id w3si21126101pgb.4.2016.11.13.23.09.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 13 Nov 2016 23:09:05 -0800 (PST)
From: Huang Shijie <shijie.huang@arm.com>
Subject: [PATCH v2 3/6] mm: hugetlb: change the return type for alloc_fresh_gigantic_page
Date: Mon, 14 Nov 2016 15:07:36 +0800
Message-ID: <1479107259-2011-4-git-send-email-shijie.huang@arm.com>
In-Reply-To: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
References: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, catalin.marinas@arm.com
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org, Huang Shijie <shijie.huang@arm.com>

This patch changes the return type to "struct page*" for
alloc_fresh_gigantic_page().

This patch makes preparation for later patch.

Signed-off-by: Huang Shijie <shijie.huang@arm.com>
---
 mm/hugetlb.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index db0177b..6995087 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1142,7 +1142,7 @@ static struct page *alloc_fresh_gigantic_page_node(struct hstate *h,
 	return page;
 }
 
-static int alloc_fresh_gigantic_page(struct hstate *h,
+static struct page *alloc_fresh_gigantic_page(struct hstate *h,
 				nodemask_t *nodes_allowed, bool no_init)
 {
 	struct page *page = NULL;
@@ -1151,10 +1151,10 @@ static int alloc_fresh_gigantic_page(struct hstate *h,
 	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
 		page = alloc_fresh_gigantic_page_node(h, node, no_init);
 		if (page)
-			return 1;
+			return page;
 	}
 
-	return 0;
+	return NULL;
 }
 
 static inline bool gigantic_page_supported(void) { return true; }
@@ -1167,8 +1167,8 @@ static inline bool gigantic_page_supported(void) { return false; }
 static inline void free_gigantic_page(struct page *page, unsigned int order) { }
 static inline void destroy_compound_gigantic_page(struct page *page,
 						unsigned int order) { }
-static inline int alloc_fresh_gigantic_page(struct hstate *h,
-		nodemask_t *nodes_allowed, bool no_init) { return 0; }
+static inline struct page *alloc_fresh_gigantic_page(struct hstate *h,
+		nodemask_t *nodes_allowed, bool no_init) { return NULL; }
 #endif
 
 static void update_and_free_page(struct hstate *h, struct page *page)
@@ -2315,7 +2315,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 		cond_resched();
 
 		if (hstate_is_gigantic(h))
-			ret = alloc_fresh_gigantic_page(h, nodes_allowed,
+			ret = !!alloc_fresh_gigantic_page(h, nodes_allowed,
 							false);
 		else
 			ret = alloc_fresh_huge_page(h, nodes_allowed);
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
