Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1906B6B0038
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 01:32:01 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so46067966pdr.2
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 22:32:00 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ut8si12783138pac.57.2015.07.09.22.31.58
        for <linux-mm@kvack.org>;
        Thu, 09 Jul 2015 22:32:00 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2] zsmalloc: consider ZS_ALMOST_FULL as migrate source
Date: Fri, 10 Jul 2015 14:31:59 +0900
Message-Id: <1436506319-12885-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan.kim@lge.com>

From: Minchan Kim <minchan.kim@lge.com>

There is no reason to prevent select ZS_ALMOST_FULL as migration
source if we cannot find source from ZS_ALMOST_EMPTY.

With this patch, zs_can_compact will return more exact result.

* From v1
  * remove unnecessary found variable - Sergey

Signed-off-by: Minchan Kim <minchan.kim@lge.com>
---
 mm/zsmalloc.c |   17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 8c78bcb..9012645 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1686,11 +1686,17 @@ static enum fullness_group putback_zspage(struct zs_pool *pool,
 
 static struct page *isolate_source_page(struct size_class *class)
 {
-	struct page *page;
+	int i;
+	struct page *page = NULL;
+
+	for (i = ZS_ALMOST_EMPTY; i >= ZS_ALMOST_FULL; i--) {
+		page = class->fullness_list[i];
+		if (!page)
+			continue;
 
-	page = class->fullness_list[ZS_ALMOST_EMPTY];
-	if (page)
-		remove_zspage(page, class, ZS_ALMOST_EMPTY);
+		remove_zspage(page, class, i);
+		break;
+	}
 
 	return page;
 }
@@ -1706,9 +1712,6 @@ static unsigned long zs_can_compact(struct size_class *class)
 {
 	unsigned long obj_wasted;
 
-	if (!zs_stat_get(class, CLASS_ALMOST_EMPTY))
-		return 0;
-
 	obj_wasted = zs_stat_get(class, OBJ_ALLOCATED) -
 		zs_stat_get(class, OBJ_USED);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
