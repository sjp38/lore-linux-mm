Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 49732828E5
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 03:58:14 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a69so147583695pfa.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 00:58:14 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id x133si11083598pfd.105.2016.06.17.00.58.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 00:58:13 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id fg1so5345819pad.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 00:58:13 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v3 9/9] mm/page_isolation: clean up confused code
Date: Fri, 17 Jun 2016 16:57:39 +0900
Message-Id: <1466150259-27727-10-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1466150259-27727-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1466150259-27727-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

When there is an isolated_page, post_alloc_hook() is called with
page but __free_pages() is called with isolated_page. Since they are
the same so no problem but it's very confusing. To reduce it,
this patch changes isolated_page to boolean type and uses page variable
consistently.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_isolation.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 4639163..064b7fb 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -81,7 +81,7 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 {
 	struct zone *zone;
 	unsigned long flags, nr_pages;
-	struct page *isolated_page = NULL;
+	bool isolated_page = false;
 	unsigned int order;
 	unsigned long page_idx, buddy_idx;
 	struct page *buddy;
@@ -109,7 +109,7 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 			if (pfn_valid_within(page_to_pfn(buddy)) &&
 			    !is_migrate_isolate_page(buddy)) {
 				__isolate_free_page(page, order);
-				isolated_page = page;
+				isolated_page = true;
 			}
 		}
 	}
@@ -129,7 +129,7 @@ out:
 	spin_unlock_irqrestore(&zone->lock, flags);
 	if (isolated_page) {
 		post_alloc_hook(page, order, __GFP_MOVABLE);
-		__free_pages(isolated_page, order);
+		__free_pages(page, order);
 	}
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
