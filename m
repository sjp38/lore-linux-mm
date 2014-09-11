Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7B3916B0039
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 16:54:51 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id rl12so8950951iec.0
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 13:54:51 -0700 (PDT)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id q10si2520956icg.8.2014.09.11.13.54.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Sep 2014 13:54:50 -0700 (PDT)
Received: by mail-ig0-f171.google.com with SMTP id r10so1690919igi.16
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 13:54:50 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 02/10] zsmalloc: add fullness group list for ZS_FULL zspages
Date: Thu, 11 Sep 2014 16:53:53 -0400
Message-Id: <1410468841-320-3-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
References: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>

Move ZS_FULL into section of fullness_group entries that are tracked in
the class fullness_lists.  Without this change, full zspages are untracked
by zsmalloc; they are only moved back onto one of the tracked lists
(ZS_ALMOST_FULL or ZS_ALMOST_EMPTY) when a zsmalloc user frees one or more
of its contained objects.

This is required for zsmalloc shrinking, which needs to be able to search
all zspages in a zsmalloc pool, to find one to shrink.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 03aa72f..fedb70f 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -159,16 +159,19 @@
 					ZS_SIZE_CLASS_DELTA + 1)
 
 /*
- * We do not maintain any list for completely empty or full pages
+ * We do not maintain any list for completely empty zspages,
+ * since a zspage is freed when it becomes empty.
  */
 enum fullness_group {
 	ZS_ALMOST_FULL,
 	ZS_ALMOST_EMPTY,
+	ZS_FULL,
+
 	_ZS_NR_FULLNESS_GROUPS,
 
 	ZS_EMPTY,
-	ZS_FULL
 };
+#define _ZS_NR_AVAILABLE_FULLNESS_GROUPS ZS_FULL
 
 /*
  * We assign a page to ZS_ALMOST_EMPTY fullness group when:
@@ -722,12 +725,12 @@ cleanup:
 	return first_page;
 }
 
-static struct page *find_get_zspage(struct size_class *class)
+static struct page *find_available_zspage(struct size_class *class)
 {
 	int i;
 	struct page *page;
 
-	for (i = 0; i < _ZS_NR_FULLNESS_GROUPS; i++) {
+	for (i = 0; i < _ZS_NR_AVAILABLE_FULLNESS_GROUPS; i++) {
 		page = class->fullness_list[i];
 		if (page)
 			break;
@@ -1013,7 +1016,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 	BUG_ON(class_idx != class->index);
 
 	spin_lock(&class->lock);
-	first_page = find_get_zspage(class);
+	first_page = find_available_zspage(class);
 
 	if (!first_page) {
 		spin_unlock(&class->lock);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
