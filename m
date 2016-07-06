Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id B18A2828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 02:24:13 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id cx13so223653642pac.2
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 23:24:13 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id 63si2099268pfd.114.2016.07.05.23.24.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jul 2016 23:24:12 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id ts6so20295456pac.0
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 23:24:12 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH v3 1/8] mm/zsmalloc: use obj_index to keep consistent with others
Date: Wed,  6 Jul 2016 14:23:46 +0800
Message-Id: <1467786233-4481-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com, Ganesh Mahendran <opensource.ganesh@gmail.com>

This is a cleanup patch. Change "index" to "obj_index" to keep
consistent with others in zsmalloc.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>
----
v3: none
v2: none
---
 mm/zsmalloc.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index e425de4..3a37977 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1779,7 +1779,7 @@ struct zs_compact_control {
 	struct page *d_page;
 	 /* Starting object index within @s_page which used for live object
 	  * in the subpage. */
-	int index;
+	int obj_idx;
 };
 
 static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
@@ -1789,16 +1789,16 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 	unsigned long handle;
 	struct page *s_page = cc->s_page;
 	struct page *d_page = cc->d_page;
-	unsigned long index = cc->index;
+	int obj_idx = cc->obj_idx;
 	int ret = 0;
 
 	while (1) {
-		handle = find_alloced_obj(class, s_page, index);
+		handle = find_alloced_obj(class, s_page, obj_idx);
 		if (!handle) {
 			s_page = get_next_page(s_page);
 			if (!s_page)
 				break;
-			index = 0;
+			obj_idx = 0;
 			continue;
 		}
 
@@ -1812,7 +1812,7 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 		used_obj = handle_to_obj(handle);
 		free_obj = obj_malloc(class, get_zspage(d_page), handle);
 		zs_object_copy(class, free_obj, used_obj);
-		index++;
+		obj_idx++;
 		/*
 		 * record_obj updates handle's value to free_obj and it will
 		 * invalidate lock bit(ie, HANDLE_PIN_BIT) of handle, which
@@ -1827,7 +1827,7 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 
 	/* Remember last position in this iteration */
 	cc->s_page = s_page;
-	cc->index = index;
+	cc->obj_idx = obj_idx;
 
 	return ret;
 }
@@ -2282,7 +2282,7 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 		if (!zs_can_compact(class))
 			break;
 
-		cc.index = 0;
+		cc.obj_idx = 0;
 		cc.s_page = get_first_page(src_zspage);
 
 		while ((dst_zspage = isolate_zspage(class, false))) {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
