Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4760E6B01B5
	for <linux-mm@kvack.org>; Sat, 22 May 2010 06:21:58 -0400 (EDT)
Received: by mail-pw0-f41.google.com with SMTP id 7so844726pwi.14
        for <linux-mm@kvack.org>; Sat, 22 May 2010 03:21:57 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 2/2] cache last free vmap_area to avoid restarting beginning
Date: Sat, 22 May 2010 19:21:35 +0900
Message-Id: <cd3012337e8cbf420626ed65ab10771f729c888a.1274522869.git.minchan.kim@gmail.com>
In-Reply-To: <52219510083a624ff3d60d5671f826c33f8ef23c.1274522869.git.minchan.kim@gmail.com>
References: <52219510083a624ff3d60d5671f826c33f8ef23c.1274522869.git.minchan.kim@gmail.com>
In-Reply-To: <52219510083a624ff3d60d5671f826c33f8ef23c.1274522869.git.minchan.kim@gmail.com>
References: <52219510083a624ff3d60d5671f826c33f8ef23c.1274522869.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steven Whitehouse <swhiteho@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

This patch is improved version to fix my TODO list which is suggested by Nick.

- invalidating the cache in the case of vstart being decreased.
- Don't unconditionally reset the cache to the last vm area freed,
 because you might have a higher area freed after a lower area. Only
 reset if the freed area is lower.
- Do keep a cached hole size, so smaller lookups can restart a full
 search.

And it's based on Nick's version.

Steven. Could you test this patch on your machine?

== CUT HERE ==

Steven Whitehouse reported that GFS2 had a regression about vmalloc.
He measured some test module to compare vmalloc speed on the two cases.

1. lazy TLB flush
2. disable lazy TLB flush by hard coding

1)
vmalloc took 148798983 us
vmalloc took 151664529 us
vmalloc took 152416398 us
vmalloc took 151837733 us

2)
vmalloc took 15363634 us
vmalloc took 15358026 us
vmalloc took 15240955 us
vmalloc took 15402302 us

You can refer test module and Steven's patch
with https://bugzilla.redhat.com/show_bug.cgi?id=581459.

The cause is that lazy TLB flush can delay release vmap_area.
OTOH, To find free vmap_area is always started from beginnig of rbnode.
So before lazy TLB flush happens, searching free vmap_area could take
long time.

Steven's experiment can do 9 times faster than old.
But Always disable lazy TLB flush is not good.

This patch caches next free vmap_area to accelerate.
In my test case, following as.

The result is following as.

1) vanilla
elapsed time
vmalloc took 49121724 us
vmalloc took 50675245 us
vmalloc took 48987711 us
vmalloc took 54232479 us
vmalloc took 50258117 us
vmalloc took 49424859 us

3) Steven's patch
elapsed time
vmalloc took 11363341 us
vmalloc took 12798868 us
vmalloc took 13247942 us
vmalloc took 11434647 us
vmalloc took 13221733 us
vmalloc took 12134019 us

2) my patch(vmap cache)
elapsed time
vmalloc took 5110283 us
vmalloc took 5148300 us
vmalloc took 5043622 us
vmalloc took 5093772 us
vmalloc took 5039565 us
vmalloc took 5079503 us

Signed-off-by: Nick Piggin <npiggin@suse.de>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/vmalloc.c |   61 ++++++++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 49 insertions(+), 12 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 651d1c1..23f714f 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -262,8 +262,13 @@ struct vmap_area {
 };
 
 static DEFINE_SPINLOCK(vmap_area_lock);
-static struct rb_root vmap_area_root = RB_ROOT;
 static LIST_HEAD(vmap_area_list);
+static struct rb_root vmap_area_root = RB_ROOT;
+
+static struct rb_node *free_vmap_cache;
+static unsigned long cached_hole_size;
+static unsigned long cached_start;
+
 static unsigned long vmap_area_pcpu_hole;
 
 static struct vmap_area *__find_vmap_area(unsigned long addr)
@@ -345,8 +350,11 @@ static struct vmap_area *__get_first_vmap_area(struct rb_node *n, unsigned long
 
 	if (first->va_end < addr) {
 		n = rb_next(&first->rb_node);
-		if (n)
+		if (n) {
 			first = rb_entry(n, struct vmap_area, rb_node);
+			if (addr + cached_hole_size < first->va_start)
+				cached_hole_size = first->va_start - addr;
+		}
 		else
 			first = NULL;						
 	}
@@ -365,6 +373,9 @@ static int __get_vmap_area_addr(struct vmap_area *first,
 	struct rb_node *n;
 
 	while (*addr + size > first->va_start && *addr + size <= vend) {
+		if (*addr + cached_hole_size < first->va_start)
+			cached_hole_size = first->va_start - *addr;
+
 		*addr = ALIGN(first->va_end + PAGE_SIZE, align);
 		if (*addr + size - 1 < *addr)
 			return 1;
@@ -385,7 +396,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 				unsigned long vstart, unsigned long vend,
 				int node, gfp_t gfp_mask)
 {
-	struct vmap_area *va;
+	struct vmap_area *va, *first = NULL;
 	struct rb_node *n;
 	unsigned long addr;
 	int purged = 0;
@@ -405,18 +416,28 @@ retry:
 	if (addr + size - 1 < addr)
 		goto overflow;
 
-	/* XXX: could have a last_hole cache */
-	n = vmap_area_root.rb_node;
-	if (n) {
-		int ret;
-		struct vmap_area *first = __get_first_vmap_area(n, addr, size);
+        if (size <= cached_hole_size || addr < cached_start) {
+                cached_hole_size = 0; 
+                cached_start = addr;
+                free_vmap_cache = NULL;
+        }  
+
+	/* find starting point for our search */
+	if (free_vmap_cache) {
+		first = rb_entry(free_vmap_cache, struct vmap_area, rb_node);
+		addr = ALIGN(first->va_end + PAGE_SIZE, align);
+	}
+	else {
+		n = vmap_area_root.rb_node;
+		if (!n)
+			goto found;
+
+		first = __get_first_vmap_area(n, addr, size);
 		if (!first)
 			goto found;
-		
-		ret = __get_vmap_area_addr(first, &addr, size, vend, align);
-		if (ret == VMAP_AREA_OVERFLOW)
-			goto overflow;
 	}
+	if (__get_vmap_area_addr(first, &addr, size, vend, align))
+		goto overflow;
 found:
 	if (addr + size > vend) {
 overflow:
@@ -440,6 +461,7 @@ overflow:
 	va->va_end = addr + size;
 	va->flags = 0;
 	__insert_vmap_area(va);
+	free_vmap_cache = &va->rb_node;
 	spin_unlock(&vmap_area_lock);
 
 	return va;
@@ -455,6 +477,21 @@ static void rcu_free_va(struct rcu_head *head)
 static void __free_vmap_area(struct vmap_area *va)
 {
 	BUG_ON(RB_EMPTY_NODE(&va->rb_node));
+	if (free_vmap_cache) {
+		if (va->va_end < cached_start) {
+			cached_hole_size = 0;
+			cached_start = 0;
+			free_vmap_cache = NULL;
+		} else {
+			struct vmap_area *cache;
+			cache = rb_entry(free_vmap_cache, struct vmap_area, rb_node);
+			if (va->va_start <= cache->va_start) {
+				free_vmap_cache = rb_prev(&va->rb_node);
+				cache = rb_entry(free_vmap_cache, struct vmap_area, rb_node);
+			}
+		}
+	}
+
 	rb_erase(&va->rb_node, &vmap_area_root);
 	RB_CLEAR_NODE(&va->rb_node);
 	list_del_rcu(&va->list);
-- 
1.7.0.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
