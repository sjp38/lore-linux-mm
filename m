Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id D879C6B0032
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 21:57:06 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 2/2] mm, vmalloc: use well-defined find_last_bit() func
Date: Fri,  2 Aug 2013 10:57:01 +0900
Message-Id: <1375408621-16563-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1375408621-16563-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1375408621-16563-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <js1304@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Our intention in here is to find last_bit within the region to flush.
There is well-defined function, find_last_bit() for this purpose and
it's performance may be slightly better than current implementation.
So change it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index d23c432..93d3182 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1016,15 +1016,16 @@ void vm_unmap_aliases(void)
 
 		rcu_read_lock();
 		list_for_each_entry_rcu(vb, &vbq->free, free_list) {
-			int i;
+			int i, j;
 
 			spin_lock(&vb->lock);
 			i = find_first_bit(vb->dirty_map, VMAP_BBMAP_BITS);
-			while (i < VMAP_BBMAP_BITS) {
+			if (i < VMAP_BBMAP_BITS) {
 				unsigned long s, e;
-				int j;
-				j = find_next_zero_bit(vb->dirty_map,
-					VMAP_BBMAP_BITS, i);
+
+				j = find_last_bit(vb->dirty_map,
+							VMAP_BBMAP_BITS);
+				j = j + 1; /* need exclusive index */
 
 				s = vb->va->va_start + (i << PAGE_SHIFT);
 				e = vb->va->va_start + (j << PAGE_SHIFT);
@@ -1034,10 +1035,6 @@ void vm_unmap_aliases(void)
 					start = s;
 				if (e > end)
 					end = e;
-
-				i = j;
-				i = find_next_bit(vb->dirty_map,
-							VMAP_BBMAP_BITS, i);
 			}
 			spin_unlock(&vb->lock);
 		}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
