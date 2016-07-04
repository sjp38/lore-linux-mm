Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id B30BE828E1
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 02:51:27 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id b13so332772023pat.3
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 23:51:27 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id 63si2653371pfq.112.2016.07.03.23.51.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Jul 2016 23:51:27 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id t190so15635852pfb.2
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 23:51:26 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH v2 3/8] mm/zsmalloc: take obj index back from find_alloced_obj
Date: Mon,  4 Jul 2016 14:49:54 +0800
Message-Id: <1467614999-4326-3-git-send-email-opensource.ganesh@gmail.com>
In-Reply-To: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
References: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com, Ganesh Mahendran <opensource.ganesh@gmail.com>

the obj index value should be updated after return from
find_alloced_obj() to avoid CPU buring caused by unnecessary
object scanning.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
----
v2:
  - update commit description

Hi, Minchan:
find_alloced_obj() already has the argument which use the obj_idx
name. So I use index as the local variable name in this function.
Is this OK?
---
 mm/zsmalloc.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 8915a1d..92b043c 100644
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
