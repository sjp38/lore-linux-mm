Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id A2C646B0092
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 10:33:57 -0400 (EDT)
Received: by mail-lb0-f181.google.com with SMTP id l4so958085lbv.12
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 07:33:57 -0700 (PDT)
Received: from galahad.ideasonboard.com (galahad.ideasonboard.com. [185.26.127.97])
        by mx.google.com with ESMTPS id z7si2939409lag.18.2014.10.23.07.33.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Oct 2014 07:33:55 -0700 (PDT)
From: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Subject: [PATCH 1/4] mm: cma: Don't crash on allocation if CMA area can't be activated
Date: Thu, 23 Oct 2014 17:33:45 +0300
Message-Id: <1414074828-4488-2-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
In-Reply-To: <1414074828-4488-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
References: <1414074828-4488-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

If activation of the CMA area fails its mutex won't be initialized,
leading to an oops at allocation time when trying to lock the mutex. Fix
this by failing allocation if the area hasn't been successfully actived,
and detect that condition by moving the CMA bitmap allocation after page
block reservation completion.

Signed-off-by: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
---
 mm/cma.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/mm/cma.c b/mm/cma.c
index 963bc4a..16c6650 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -93,11 +93,6 @@ static int __init cma_activate_area(struct cma *cma)
 	unsigned i = cma->count >> pageblock_order;
 	struct zone *zone;
 
-	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
-
-	if (!cma->bitmap)
-		return -ENOMEM;
-
 	WARN_ON_ONCE(!pfn_valid(pfn));
 	zone = page_zone(pfn_to_page(pfn));
 
@@ -114,17 +109,17 @@ static int __init cma_activate_area(struct cma *cma)
 			 * to be in the same zone.
 			 */
 			if (page_zone(pfn_to_page(pfn)) != zone)
-				goto err;
+				return -EINVAL;
 		}
 		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
 	} while (--i);
 
+	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
+	if (!cma->bitmap)
+		return -ENOMEM;
+
 	mutex_init(&cma->lock);
 	return 0;
-
-err:
-	kfree(cma->bitmap);
-	return -EINVAL;
 }
 
 static int __init cma_init_reserved_areas(void)
@@ -313,7 +308,7 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
 	struct page *page = NULL;
 	int ret;
 
-	if (!cma || !cma->count)
+	if (!cma || !cma->count || !cma->bitmap)
 		return NULL;
 
 	pr_debug("%s(cma %p, count %d, align %d)\n", __func__, (void *)cma,
-- 
2.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
