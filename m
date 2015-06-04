Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 638CE900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 09:07:40 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so30778692pdb.2
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 06:07:40 -0700 (PDT)
Received: from szxga03-in.huawei.com ([119.145.14.66])
        by mx.google.com with ESMTPS id su9si5811424pab.143.2015.06.04.06.07.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Jun 2015 06:07:39 -0700 (PDT)
Message-ID: <55704CED.1020702@huawei.com>
Date: Thu, 4 Jun 2015 21:04:45 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC PATCH 11/12] mm: add the PCP interface
References: <55704A7E.5030507@huawei.com>
In-Reply-To: <55704A7E.5030507@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Add the PCP interface for address range mirroring feature.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/page_alloc.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0fb55288..cf3b7cb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1401,11 +1401,16 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 			unsigned long count, struct list_head *list,
 			int migratetype, bool cold)
 {
-	int i;
+	int i, mt;
 
 	spin_lock(&zone->lock);
 	for (i = 0; i < count; ++i) {
-		struct page *page = __rmqueue(zone, order, migratetype);
+		struct page *page;
+
+		if (is_migrate_mirror(migratetype))
+			page = __rmqueue_smallest(zone, order, migratetype);
+		else
+			page = __rmqueue(zone, order, migratetype);
 		if (unlikely(page == NULL))
 			break;
 
@@ -1423,9 +1428,14 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 		else
 			list_add_tail(&page->lru, list);
 		list = &page->lru;
-		if (is_migrate_cma(get_freepage_migratetype(page)))
+
+		mt = get_freepage_migratetype(page);
+		if (is_migrate_cma(mt))
 			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
 					      -(1 << order));
+		if (is_migrate_mirror(mt))
+			__mod_zone_page_state(zone, NR_FREE_MIRROR_PAGES,
+					      -(1 << order));
 	}
 	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
 	spin_unlock(&zone->lock);
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
