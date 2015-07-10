Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 18B5C6B0253
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 21:32:12 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so174604562pdb.1
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 18:32:11 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id z8si11893179par.90.2015.07.09.18.32.10
        for <linux-mm@kvack.org>;
        Thu, 09 Jul 2015 18:32:11 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] zsmalloc: consider ZS_ALMOST_FULL as migrate source
Date: Fri, 10 Jul 2015 10:32:09 +0900
Message-Id: <1436491929-6617-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

There is no reason to prevent select ZS_ALMOST_FULL as migration
source if we cannot find source from ZS_ALMOST_EMPTY.

With this patch, zs_can_compact will return more exact result.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c |   19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 8c78bcb..7bd7dde 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1687,12 +1687,20 @@ static enum fullness_group putback_zspage(struct zs_pool *pool,
 static struct page *isolate_source_page(struct size_class *class)
 {
 	struct page *page;
+	int i;
+	bool found = false;
 
-	page = class->fullness_list[ZS_ALMOST_EMPTY];
-	if (page)
-		remove_zspage(page, class, ZS_ALMOST_EMPTY);
+	for (i = ZS_ALMOST_EMPTY; i >= ZS_ALMOST_FULL; i--) {
+		page = class->fullness_list[i];
+		if (!page)
+			continue;
 
-	return page;
+		remove_zspage(page, class, i);
+		found = true;
+		break;
+	}
+
+	return found ? page : NULL;
 }
 
 /*
@@ -1706,9 +1714,6 @@ static unsigned long zs_can_compact(struct size_class *class)
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
