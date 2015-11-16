Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6FD246B0253
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 09:11:34 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so176365429pac.3
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 06:11:34 -0800 (PST)
Received: from m50-133.163.com (m50-133.163.com. [123.125.50.133])
        by mx.google.com with ESMTP id ua10si50522391pab.236.2015.11.16.06.11.32
        for <linux-mm@kvack.org>;
        Mon, 16 Nov 2015 06:11:33 -0800 (PST)
From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH] mm/vmalloc: use list_{next,first}_entry
Date: Mon, 16 Nov 2015 22:10:38 +0800
Message-Id: <cb0e162334b44e7480a8a1d79b6059453887534d.1447682821.git.geliangtang@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Roman Pen <r.peniaev@gmail.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Geliang Tang <geliangtang@163.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

To make the intention clearer, use list_{next,first}_entry instead
of list_entry.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 mm/vmalloc.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index d045634..c89ce9d 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -441,8 +441,7 @@ nocache:
 		if (list_is_last(&first->list, &vmap_area_list))
 			goto found;
 
-		first = list_entry(first->list.next,
-				struct vmap_area, list);
+		first = list_next_entry(first, list);
 	}
 
 found:
@@ -2560,10 +2559,10 @@ static void *s_start(struct seq_file *m, loff_t *pos)
 	struct vmap_area *va;
 
 	spin_lock(&vmap_area_lock);
-	va = list_entry((&vmap_area_list)->next, typeof(*va), list);
+	va = list_first_entry(&vmap_area_list, typeof(*va), list);
 	while (n > 0 && &va->list != &vmap_area_list) {
 		n--;
-		va = list_entry(va->list.next, typeof(*va), list);
+		va = list_next_entry(va, list);
 	}
 	if (!n && &va->list != &vmap_area_list)
 		return va;
@@ -2577,7 +2576,7 @@ static void *s_next(struct seq_file *m, void *p, loff_t *pos)
 	struct vmap_area *va = p, *next;
 
 	++*pos;
-	next = list_entry(va->list.next, typeof(*va), list);
+	next = list_next_entry(va, list);
 	if (&next->list != &vmap_area_list)
 		return next;
 
-- 
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
