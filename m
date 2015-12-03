Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 94E676B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 09:17:33 -0500 (EST)
Received: by padhx2 with SMTP id hx2so69932746pad.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 06:17:33 -0800 (PST)
Received: from m50-134.163.com (m50-134.163.com. [123.125.50.134])
        by mx.google.com with ESMTP id v88si12268982pfi.250.2015.12.03.06.17.30
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 06:17:31 -0800 (PST)
From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH] mm/memcontrol.c: use list_{first,next}_entry
Date: Thu,  3 Dec 2015 22:16:55 +0800
Message-Id: <9e62e3006561653fcbf0c49cf0b9c2b653a8ed0e.1449152124.git.geliangtang@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>
Cc: Geliang Tang <geliangtang@163.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

To make the intention clearer, use list_{first,next}_entry instead
of list_entry.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 mm/memcontrol.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 79a29d5..a6301ea 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5395,16 +5395,12 @@ static void uncharge_list(struct list_head *page_list)
 	unsigned long nr_file = 0;
 	unsigned long nr_huge = 0;
 	unsigned long pgpgout = 0;
-	struct list_head *next;
 	struct page *page;
 
-	next = page_list->next;
+	page = list_first_entry(page_list, struct page, lru);
 	do {
 		unsigned int nr_pages = 1;
 
-		page = list_entry(next, struct page, lru);
-		next = page->lru.next;
-
 		VM_BUG_ON_PAGE(PageLRU(page), page);
 		VM_BUG_ON_PAGE(page_count(page), page);
 
@@ -5440,7 +5436,8 @@ static void uncharge_list(struct list_head *page_list)
 		page->mem_cgroup = NULL;
 
 		pgpgout++;
-	} while (next != page_list);
+	} while (!list_is_last(&page->lru, page_list) &&
+		 (page = list_next_entry(page, lru)));
 
 	if (memcg)
 		uncharge_batch(memcg, pgpgout, nr_anon, nr_file,
-- 
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
