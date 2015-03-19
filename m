Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id 936086B006C
	for <linux-mm@kvack.org>; Sat, 21 Mar 2015 17:14:40 -0400 (EDT)
Received: by yhpt93 with SMTP id t93so53685862yhp.0
        for <linux-mm@kvack.org>; Sat, 21 Mar 2015 14:14:40 -0700 (PDT)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com. [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id hq9si3357387pac.15.2015.03.19.07.05.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Mar 2015 07:05:24 -0700 (PDT)
Received: by pdbcz9 with SMTP id cz9so77201855pdb.3
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 07:05:23 -0700 (PDT)
From: Roman Pen <r.peniaev@gmail.com>
Subject: [RFC v2 3/3] mm/vmalloc: get rid of dirty bitmap inside vmap_block structure
Date: Thu, 19 Mar 2015 23:04:41 +0900
Message-Id: <1426773881-5757-4-git-send-email-r.peniaev@gmail.com>
In-Reply-To: <1426773881-5757-1-git-send-email-r.peniaev@gmail.com>
References: <1426773881-5757-1-git-send-email-r.peniaev@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Roman Pen <r.peniaev@gmail.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Eric Dumazet <edumazet@google.com>, David Rientjes <rientjes@google.com>, WANG Chao <chaowang@redhat.com>, Fabian Frederick <fabf@skynet.be>, Christoph Lameter <cl@linux.com>, Gioh Kim <gioh.kim@lge.com>, Rob Jones <rob.jones@codethink.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In original implementation of vm_map_ram made by Nick Piggin there were two
bitmaps:  alloc_map and dirty_map.  None of them were used as supposed to be:
finding a suitable free hole for next allocation in block. vm_map_ram allocates
space sequentially in block and on free call marks pages as dirty, so freed
space can't be reused anymore.

Actually would be very interesting to know the real meaning of those bitmaps,
maybe implementation was incomplete, etc.

But long time ago Zhang Yanfei removed alloc_map by these two commits:

  mm/vmalloc.c: remove dead code in vb_alloc
     3fcd76e8028e0be37b02a2002b4f56755daeda06
  mm/vmalloc.c: remove alloc_map from vmap_block
     b8e748b6c32999f221ea4786557b8e7e6c4e4e7a

In current patch I replaced dirty_map with two range variables: dirty min and
max.  These variables store minimum and maximum position of dirty space in a
block, since we need only to know the dirty range, not exact position of dirty
pages.

Why it was made? Several reasons: at first glance it seems that vm_map_ram
allocator concerns about fragmentation thus it uses bitmaps for finding free
hole, but it is not true.  To avoid complexity seems it is better to use
something simple, like min or max range values.  Secondly, code also becomes
simpler, without iteration over bitmap, just comparing values in min and max
macros.  Thirdly, bitmap occupies up to 1024 bits (4MB is a max size of a
block).  Here I replaced the whole bitmap with two longs.

Finally vm_unmap_aliases should be slightly faster and the whole vmap_block
structure occupies less memory.

Signed-off-by: Roman Pen <r.peniaev@gmail.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric Dumazet <edumazet@google.com>
Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>
Cc: WANG Chao <chaowang@redhat.com>
Cc: Fabian Frederick <fabf@skynet.be>
Cc: Christoph Lameter <cl@linux.com>
Cc: Gioh Kim <gioh.kim@lge.com>
Cc: Rob Jones <rob.jones@codethink.co.uk>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/vmalloc.c | 35 +++++++++++++++++------------------
 1 file changed, 17 insertions(+), 18 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 9bd102c..5260e51 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -760,7 +760,7 @@ struct vmap_block {
 	spinlock_t lock;
 	struct vmap_area *va;
 	unsigned long free, dirty;
-	DECLARE_BITMAP(dirty_map, VMAP_BBMAP_BITS);
+	unsigned long dirty_min, dirty_max; /*< dirty range */
 	struct list_head free_list;
 	struct rcu_head rcu_head;
 	struct list_head purge;
@@ -846,7 +846,8 @@ static void *new_vmap_block(unsigned int order, gfp_t gfp_mask)
 	BUG_ON(VMAP_BBMAP_BITS <= (1UL << order));
 	vb->free = VMAP_BBMAP_BITS - (1UL << order);
 	vb->dirty = 0;
-	bitmap_zero(vb->dirty_map, VMAP_BBMAP_BITS);
+	vb->dirty_min = VMAP_BBMAP_BITS;
+	vb->dirty_max = 0;
 	INIT_LIST_HEAD(&vb->free_list);
 
 	vb_idx = addr_to_vb_idx(va->va_start);
@@ -897,7 +898,8 @@ static void purge_fragmented_blocks(int cpu)
 		if (vb->free + vb->dirty == VMAP_BBMAP_BITS && vb->dirty != VMAP_BBMAP_BITS) {
 			vb->free = 0; /* prevent further allocs after releasing lock */
 			vb->dirty = VMAP_BBMAP_BITS; /* prevent purging it again */
-			bitmap_fill(vb->dirty_map, VMAP_BBMAP_BITS);
+			vb->dirty_min = 0;
+			vb->dirty_max = VMAP_BBMAP_BITS;
 			spin_lock(&vbq->lock);
 			list_del_rcu(&vb->free_list);
 			spin_unlock(&vbq->lock);
@@ -990,6 +992,7 @@ static void vb_free(const void *addr, unsigned long size)
 	order = get_order(size);
 
 	offset = (unsigned long)addr & (VMAP_BLOCK_SIZE - 1);
+	offset >>= PAGE_SHIFT;
 
 	vb_idx = addr_to_vb_idx((unsigned long)addr);
 	rcu_read_lock();
@@ -1000,7 +1003,10 @@ static void vb_free(const void *addr, unsigned long size)
 	vunmap_page_range((unsigned long)addr, (unsigned long)addr + size);
 
 	spin_lock(&vb->lock);
-	BUG_ON(bitmap_allocate_region(vb->dirty_map, offset >> PAGE_SHIFT, order));
+
+	/* Expand dirty range */
+	vb->dirty_min = min(vb->dirty_min, offset);
+	vb->dirty_max = max(vb->dirty_max, offset + (1UL << order));
 
 	vb->dirty += 1UL << order;
 	if (vb->dirty == VMAP_BBMAP_BITS) {
@@ -1039,25 +1045,18 @@ void vm_unmap_aliases(void)
 
 		rcu_read_lock();
 		list_for_each_entry_rcu(vb, &vbq->free, free_list) {
-			int i, j;
-
 			spin_lock(&vb->lock);
-			i = find_first_bit(vb->dirty_map, VMAP_BBMAP_BITS);
-			if (i < VMAP_BBMAP_BITS) {
+			if (vb->dirty) {
+				unsigned long va_start = vb->va->va_start;
 				unsigned long s, e;
 
-				j = find_last_bit(vb->dirty_map,
-							VMAP_BBMAP_BITS);
-				j = j + 1; /* need exclusive index */
+				s = va_start + (vb->dirty_min << PAGE_SHIFT);
+				e = va_start + (vb->dirty_max << PAGE_SHIFT);
 
-				s = vb->va->va_start + (i << PAGE_SHIFT);
-				e = vb->va->va_start + (j << PAGE_SHIFT);
-				flush = 1;
+				start = min(s, start);
+				end   = max(e, end);
 
-				if (s < start)
-					start = s;
-				if (e > end)
-					end = e;
+				flush = 1;
 			}
 			spin_unlock(&vb->lock);
 		}
-- 
2.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
