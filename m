Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 39FD96B006C
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 18:11:55 -0400 (EDT)
Received: by pdmh5 with SMTP id h5so21486389pdm.3
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 15:11:55 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id hp5si21092326pbb.179.2015.03.31.15.11.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 31 Mar 2015 15:11:54 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH 2/2] mm: __free_pages batch up 0-order pages for freeing
Date: Tue, 31 Mar 2015 18:11:33 -0400
Message-Id: <1427839895-16434-2-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1427839895-16434-1-git-send-email-sasha.levin@oracle.com>
References: <1427839895-16434-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mhocko@suse.cz, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Rather than calling free_hot_cold_page() for every page, batch them up in a
list and pass them on to free_hot_cold_page_list(). This will let us defer
them to a workqueue.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/page_alloc.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 812ca75..e58e795 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2997,12 +2997,16 @@ EXPORT_SYMBOL(get_zeroed_page);
 
 void __free_pages(struct page *page, unsigned int order)
 {
+	LIST_HEAD(hot_cold_pages);
+
 	if (put_page_testzero(page)) {
 		if (order == 0)
-			free_hot_cold_page(page, false);
+			list_add(&page->lru, &hot_cold_pages);
 		else
 			__free_pages_ok(page, order);
 	}
+
+	free_hot_cold_page_list(&hot_cold_pages, false);
 }
 
 EXPORT_SYMBOL(__free_pages);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
