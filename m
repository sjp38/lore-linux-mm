Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0A806828EA
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 02:42:06 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ts6so190411813pac.1
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 23:42:06 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id 6si2590870pfe.203.2016.06.30.23.42.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jun 2016 23:42:05 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id i123so9304143pfg.3
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 23:42:05 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH 3/8] mm/zsmalloc: take obj index back from find_alloced_obj
Date: Fri,  1 Jul 2016 14:41:01 +0800
Message-Id: <1467355266-9735-3-git-send-email-opensource.ganesh@gmail.com>
In-Reply-To: <1467355266-9735-1-git-send-email-opensource.ganesh@gmail.com>
References: <1467355266-9735-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com, Ganesh Mahendran <opensource.ganesh@gmail.com>

the obj index value should be updated after return from
find_alloced_obj()

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
---
 mm/zsmalloc.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 405baa5..5c96ed1 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1744,15 +1744,16 @@ static void zs_object_copy(struct size_class *class, unsigned long dst,
  * return handle.
  */
 static unsigned long find_alloced_obj(struct size_class *class,
-					struct page *page, int index)
+					struct page *page, int *index)
 {
 	unsigned long head;
 	int offset = 0;
+	int objidx = *index;
 	unsigned long handle = 0;
 	void *addr = kmap_atomic(page);
 
 	offset = get_first_obj_offset(page);
-	offset += class->size * index;
+	offset += class->size * objidx;
 
 	while (offset < PAGE_SIZE) {
 		head = obj_to_head(page, addr + offset);
@@ -1764,9 +1765,11 @@ static unsigned long find_alloced_obj(struct size_class *class,
 		}
 
 		offset += class->size;
-		index++;
+		objidx++;
 	}
 
+	*index = objidx;
+
 	kunmap_atomic(addr);
 	return handle;
 }
@@ -1794,11 +1797,11 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 	unsigned long handle;
 	struct page *s_page = cc->s_page;
 	struct page *d_page = cc->d_page;
-	unsigned long index = cc->index;
+	unsigned int index = cc->index;
 	int ret = 0;
 
 	while (1) {
-		handle = find_alloced_obj(class, s_page, index);
+		handle = find_alloced_obj(class, s_page, &index);
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
