Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 093116B01C1
	for <linux-mm@kvack.org>; Mon, 31 May 2010 04:07:59 -0400 (EDT)
Date: Mon, 31 May 2010 18:07:57 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: vmap area cache
Message-ID: <20100531080757.GE9453@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Steven Whitehouse <swhiteho@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

Could you put this in your tree? It could do with a bit more testing. I
will update you with updates or results from Steven.

Thanks,
Nick
--

Provide a free area cache for the vmalloc virtual address allocator, based
on the approach taken in the user virtual memory allocator.

This reduces the number of rbtree operations and linear traversals over
the vmap extents to find a free area. The lazy vmap flushing makes this problem
worse because because freed but not yet flushed vmaps tend to build up in
the address space between flushes.

Steven noticed a performance problem with GFS2. Results are as follows...



 mm/vmalloc.c |  100 ++++++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 78 insertions(+), 22 deletions(-)

Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c
+++ linux-2.6/mm/vmalloc.c
@@ -262,8 +262,14 @@ struct vmap_area {
 };
 
 static DEFINE_SPINLOCK(vmap_area_lock);
-static struct rb_root vmap_area_root = RB_ROOT;
 static LIST_HEAD(vmap_area_list);
+static struct rb_root vmap_area_root = RB_ROOT;
+
+static struct rb_node *free_vmap_cache;
+static unsigned long cached_hole_size;
+static unsigned long cached_start;
+static unsigned long cached_align;
+
 static unsigned long vmap_area_pcpu_hole;
 
 static struct vmap_area *__find_vmap_area(unsigned long addr)
@@ -332,9 +338,11 @@ static struct vmap_area *alloc_vmap_area
 	struct rb_node *n;
 	unsigned long addr;
 	int purged = 0;
+	struct vmap_area *first;
 
 	BUG_ON(!size);
 	BUG_ON(size & ~PAGE_MASK);
+	BUG_ON(!is_power_of_2(align));
 
 	va = kmalloc_node(sizeof(struct vmap_area),
 			gfp_mask & GFP_RECLAIM_MASK, node);
@@ -342,17 +350,39 @@ static struct vmap_area *alloc_vmap_area
 		return ERR_PTR(-ENOMEM);
 
 retry:
-	addr = ALIGN(vstart, align);
-
 	spin_lock(&vmap_area_lock);
-	if (addr + size - 1 < addr)
-		goto overflow;
+	/* invalidate cache if we have more permissive parameters */
+	if (!free_vmap_cache ||
+			size <= cached_hole_size ||
+			vstart < cached_start ||
+			align < cached_align) {
+nocache:
+		cached_hole_size = 0;
+		free_vmap_cache = NULL;
+	}
+	/* record if we encounter less permissive parameters */
+	cached_start = vstart;
+	cached_align = align;
+
+	/* find starting point for our search */
+	if (free_vmap_cache) {
+		first = rb_entry(free_vmap_cache, struct vmap_area, rb_node);
+		addr = ALIGN(first->va_end + PAGE_SIZE, align);
+		if (addr < vstart)
+			goto nocache;
+		if (addr + size - 1 < addr)
+			goto overflow;
+
+	} else {
+		addr = ALIGN(vstart, align);
+		if (addr + size - 1 < addr)
+			goto overflow;
 
-	/* XXX: could have a last_hole cache */
-	n = vmap_area_root.rb_node;
-	if (n) {
-		struct vmap_area *first = NULL;
+		n = vmap_area_root.rb_node;
+		if (!n)
+			goto found;
 
+		first = NULL;
 		do {
 			struct vmap_area *tmp;
 			tmp = rb_entry(n, struct vmap_area, rb_node);
@@ -369,26 +399,36 @@ retry:
 		if (!first)
 			goto found;
 
-		if (first->va_end < addr) {
-			n = rb_next(&first->rb_node);
-			if (n)
-				first = rb_entry(n, struct vmap_area, rb_node);
-			else
-				goto found;
-		}
-
-		while (addr + size > first->va_start && addr + size <= vend) {
-			addr = ALIGN(first->va_end + PAGE_SIZE, align);
+		if (first->va_start < addr) {
+			addr = ALIGN(max(first->va_end + PAGE_SIZE, addr), align);
 			if (addr + size - 1 < addr)
 				goto overflow;
-
 			n = rb_next(&first->rb_node);
 			if (n)
 				first = rb_entry(n, struct vmap_area, rb_node);
 			else
 				goto found;
 		}
+		BUG_ON(first->va_start < addr);
+		if (addr + cached_hole_size < first->va_start)
+			cached_hole_size = first->va_start - addr;
 	}
+
+	/* from the starting point, walk areas until a suitable hole is found */
+	while (addr + size > first->va_start && addr + size <= vend) {
+		if (addr + cached_hole_size < first->va_start)
+			cached_hole_size = first->va_start - addr;
+		addr = ALIGN(first->va_end + PAGE_SIZE, align);
+		if (addr + size - 1 < addr)
+			goto overflow;
+
+		n = rb_next(&first->rb_node);
+		if (n)
+			first = rb_entry(n, struct vmap_area, rb_node);
+		else
+			goto found;
+	}
+
 found:
 	if (addr + size > vend) {
 overflow:
@@ -406,14 +446,17 @@ overflow:
 		return ERR_PTR(-EBUSY);
 	}
 
-	BUG_ON(addr & (align-1));
-
 	va->va_start = addr;
 	va->va_end = addr + size;
 	va->flags = 0;
 	__insert_vmap_area(va);
+	free_vmap_cache = &va->rb_node;
 	spin_unlock(&vmap_area_lock);
 
+	BUG_ON(va->va_start & (align-1));
+	BUG_ON(va->va_start < vstart);
+	BUG_ON(va->va_end > vend);
+
 	return va;
 }
 
@@ -427,6 +470,19 @@ static void rcu_free_va(struct rcu_head
 static void __free_vmap_area(struct vmap_area *va)
 {
 	BUG_ON(RB_EMPTY_NODE(&va->rb_node));
+
+	if (free_vmap_cache) {
+		if (va->va_end < cached_start) {
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
 	rb_erase(&va->rb_node, &vmap_area_root);
 	RB_CLEAR_NODE(&va->rb_node);
 	list_del_rcu(&va->list);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
