Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 45ED26B025C
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 14:25:57 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id x125so47026417pfb.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 11:25:57 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id n63si25948660pfb.139.2016.01.29.11.25.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 11:25:56 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id n128so4158359pfn.3
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 11:25:56 -0800 (PST)
Date: Sat, 30 Jan 2016 03:25:51 +0800
From: ChengYi He <chengyihetaipei@gmail.com>
Subject: [RFC PATCH 2/2] mm/page_alloc: avoid splitting pages of order 2 and
 3 in migration fallback
Message-ID: <46b854accad3f40e4178cf3bbd215a4648551763.1454094692.git.chengyihetaipei@gmail.com>
References: <cover.1454094692.git.chengyihetaipei@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1454094692.git.chengyihetaipei@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Yaowei Bai <bywxiaobai@163.com>, Xishi Qiu <qiuxishi@huawei.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, chengyihetaipei@gmail.com

While buddy system fallbacks to allocate different migration type pages,
it prefers the largest feasible pages and might split the chosen page
into smalller ones. If the largest feasible pages are less than or equal
to orde-3 and migration fallback happens frequently, then order-2 and
order-3 pages can be exhausted easily. This patch aims to allocate the
smallest feasible pages for the fallback mechanism under this condition.

Signed-off-by: ChengYi He <chengyihetaipei@gmail.com>
---
 mm/page_alloc.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 50c325a..3fcb653 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1802,9 +1802,22 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 	struct page *page;
 
 	/* Find the largest possible block of pages in the other list */
-	for (current_order = MAX_ORDER-1;
-				current_order >= order && current_order <= MAX_ORDER-1;
-				--current_order) {
+	for (current_order = MAX_ORDER - 1;
+			current_order >= max_t(unsigned int, PAGE_ALLOC_COSTLY_ORDER + 1, order);
+			--current_order) {
+		page = __rmqueue_fallback_order(zone, order, start_migratetype,
+				current_order);
+
+		if (page)
+			return page;
+	}
+
+	/*
+	 * While current_order <= PAGE_ALLOC_COSTLY_ORDER, find the smallest
+	 * feasible pages in the other list to avoid splitting high order pages
+	 */
+	for (current_order = order; current_order <= PAGE_ALLOC_COSTLY_ORDER;
+			++current_order) {
 		page = __rmqueue_fallback_order(zone, order, start_migratetype,
 				current_order);
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
