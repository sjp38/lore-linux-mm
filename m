Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 687566B025E
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 05:06:17 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ts6so22715089pac.1
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 02:06:17 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id u124si3050210pfu.254.2016.07.07.02.06.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 02:06:16 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id dx3so1270443pab.2
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 02:06:16 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH v4 2/8] mm/zsmalloc: take obj index back from find_alloced_obj
Date: Thu,  7 Jul 2016 17:05:32 +0800
Message-Id: <1467882338-4300-2-git-send-email-opensource.ganesh@gmail.com>
In-Reply-To: <1467882338-4300-1-git-send-email-opensource.ganesh@gmail.com>
References: <1467882338-4300-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, mingo@redhat.com, rostedt@goodmis.org, Ganesh Mahendran <opensource.ganesh@gmail.com>

the obj index value should be updated after return from
find_alloced_obj() to avoid CPU burning caused by unnecessary
object scanning.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>
----
v4: none
v3: none
v2:
  - update commit description
---
 mm/zsmalloc.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 3a37977..1f144f1 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1744,10 +1744,11 @@ static void zs_object_copy(struct size_class *class, unsigned long dst,
  * return handle.
  */
 static unsigned long find_alloced_obj(struct size_class *class,
-					struct page *page, int index)
+					struct page *page, int *obj_idx)
 {
 	unsigned long head;
 	int offset = 0;
+	int index = *obj_idx;
 	unsigned long handle = 0;
 	void *addr = kmap_atomic(page);
 
@@ -1768,6 +1769,9 @@ static unsigned long find_alloced_obj(struct size_class *class,
 	}
 
 	kunmap_atomic(addr);
+
+	*obj_idx = index;
+
 	return handle;
 }
 
@@ -1793,7 +1797,7 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 	int ret = 0;
 
 	while (1) {
-		handle = find_alloced_obj(class, s_page, obj_idx);
+		handle = find_alloced_obj(class, s_page, &obj_idx);
 		if (!handle) {
 			s_page = get_next_page(s_page);
 			if (!s_page)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
