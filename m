Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id F3BC16B0036
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 07:33:58 -0400 (EDT)
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MQC00C7C5GLWLL0@mailout1.samsung.com> for linux-mm@kvack.org;
 Mon, 22 Jul 2013 20:33:57 +0900 (KST)
From: Pintu Kumar <pintu.k@samsung.com>
Subject: [PATCH 2/2] mm: page_alloc: avoid slowpath for more than MAX_ORDER
 allocation.
Date: Mon, 22 Jul 2013 17:02:42 +0530
Message-id: <1374492762-17735-1-git-send-email-pintu.k@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, jiang.liu@huawei.com, minchan@kernel.org, cody@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: cpgs@samsung.com, pintu.k@samsung.com, pintu_agarwal@yahoo.com

It was observed that if order is passed as more than MAX_ORDER
allocation in __alloc_pages_nodemask, it will unnecessarily go to
slowpath and then return failure.
Since we know that more than MAX_ORDER will anyways fail, we can
avoid slowpath by returning failure in nodemask itself.

Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
---
 mm/page_alloc.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 202ab58..6d38e75 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1564,6 +1564,10 @@ __setup("fail_page_alloc=", setup_fail_page_alloc);
 
 static bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
 {
+	if (order >= MAX_ORDER) {
+		WARN_ON(!(gfp_mask & __GFP_NOWARN));
+		return false;
+	}
 	if (order < fail_page_alloc.min_order)
 		return false;
 	if (gfp_mask & __GFP_NOFAIL)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
