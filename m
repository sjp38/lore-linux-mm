Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0D1806B0005
	for <linux-mm@kvack.org>; Fri, 25 Mar 2016 03:03:49 -0400 (EDT)
Received: by mail-oi0-f50.google.com with SMTP id r187so90154441oih.3
        for <linux-mm@kvack.org>; Fri, 25 Mar 2016 00:03:49 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id n2si4794426oei.24.2016.03.25.00.03.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 Mar 2016 00:03:48 -0700 (PDT)
Message-ID: <56F4E104.9090505@huawei.com>
Date: Fri, 25 Mar 2016 14:56:04 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm: fix invalid node in alloc_migrate_target()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Laura
 Abbott <lauraa@codeaurora.org>, zhuhui@xiaomi.com, wangxq10@lzu.edu.cn
Cc: Xishi Qiu <qiuxishi@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

It is incorrect to use next_node to find a target node, it will
return MAX_NUMNODES or invalid node. This will lead to crash in
buddy system allocation.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/page_isolation.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 92c4c36..31555b6 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -289,11 +289,11 @@ struct page *alloc_migrate_target(struct page *page, unsigned long private,
 	 * now as a simple work-around, we use the next node for destination.
 	 */
 	if (PageHuge(page)) {
-		nodemask_t src = nodemask_of_node(page_to_nid(page));
-		nodemask_t dst;
-		nodes_complement(dst, src);
+		int node = next_online_node(page_to_nid(page));
+		if (node == MAX_NUMNODES)
+			node = first_online_node;
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
-					    next_node(page_to_nid(page), dst));
+					    node);
 	}
 
 	if (PageHighMem(page))
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
