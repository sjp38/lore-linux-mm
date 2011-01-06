Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DE0A76B0088
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 17:26:28 -0500 (EST)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p06MQMCX013715
	for <linux-mm@kvack.org>; Thu, 6 Jan 2011 14:26:22 -0800
Received: from iwr19 (iwr19.prod.google.com [10.241.69.83])
	by hpaq13.eem.corp.google.com with ESMTP id p06MPonX009028
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 6 Jan 2011 14:26:20 -0800
Received: by iwr19 with SMTP id 19so20223115iwr.37
        for <linux-mm@kvack.org>; Thu, 06 Jan 2011 14:26:20 -0800 (PST)
Date: Thu, 6 Jan 2011 14:26:12 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH mmotm] mm: vmap area cache fix
Message-ID: <alpine.LSU.2.00.1101061411510.8820@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Steven Whitehouse <swhiteho@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, "Barry J. Marson" <bmarson@redhat.com>, Avi Kivity <avi@redhat.com>, Prarit Bhargava <prarit@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Nick,

I tried out the recent mmotm, and on one machine was fortunate to hit
the BUG_ON(first->va_start < addr) which seems to have been stalling
your vmap area cache patch ever since May.

I can get you addresses etc, I did dump a few out; but once I stared
at them, it was easier just to look at the code: and I cannot see how
you would be so sure that first->va_start < addr, once you've done
that addr = ALIGN(max(...), align) above, if align is over 0x1000
(align was 0x8000 or 0x4000 in the cases I hit: ioremaps like Steve).

I originally got around it by just changing the
		if (first->va_start < addr) {
to
		while (first->va_start < addr) {
without thinking about it any further; but that seemed unsatisfactory,
why would we want to loop here when we've got another very similar
loop just below it?

I am never going to admit how long I've spent trying to grasp your
"while (n)" rbtree loop just above this, the one with the peculiar
		if (!first && tmp->va_start < addr + size)
in.  That's unfamiliar to me, I'm guessing it's designed to save a
subsequent rb_next() in a few circumstances (at risk of then setting
a wrong cached_hole_size?); but they did appear few to me, and I didn't
feel I could sign off something with that in when I don't grasp it,
and it seems responsible for extra code and mistaken BUG_ON below it.

I've reverted to the familiar rbtree loop that find_vma() does (but
with va_end >= addr as you had, to respect the additional guard page):
and then (given that cached_hole_size starts out 0) I don't see the
need for any complications below it.  If you do want to keep that loop
as you had it, please add a comment to explain what it's trying to do,
and where addr is relative to first when you emerge from it.

Aren't your tests "size <= cached_hole_size" and 
"addr + size > first->va_start" forgetting the guard page we want
before the next area?  I've changed those.

I have not changed your many "addr + size - 1 < addr" overflow tests,
but have since come to wonder, shouldn't they be "addr + size < addr"
tests - won't the vend checks go wrong if addr + size is 0?

I have added a few comments - Wolfgang Wander's 2.6.13 description of
1363c3cd8603a913a27e2995dccbd70d5312d8e6 Avoiding mmap fragmentation
helped me a lot, perhaps a pointer to that would be good too.  And I
found it easier to understand when I renamed cached_start slightly
and moved the overflow label down.

This patch would go after your mm-vmap-area-cache.patch in mmotm.
Trivially, nobody is going to get that BUG_ON with this patch, and
it appears to work fine on my machines; but I have not given it
anything like the testing you did on your original, and may have
broken all the performance you were aiming for.  Please take a look
and test it out integrate with yours if you're satisfied - thanks.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/vmalloc.c |   89 +++++++++++++++++++++++--------------------------
 1 file changed, 42 insertions(+), 47 deletions(-)

--- mmotm.orig/mm/vmalloc.c	2010-12-24 19:31:46.000000000 -0800
+++ mmotm/mm/vmalloc.c	2011-01-03 22:56:05.000000000 -0800
@@ -267,7 +267,7 @@ static struct rb_root vmap_area_root = R
 /* The vmap cache globals are protected by vmap_area_lock */
 static struct rb_node *free_vmap_cache;
 static unsigned long cached_hole_size;
-static unsigned long cached_start;
+static unsigned long cached_vstart;
 static unsigned long cached_align;
 
 static unsigned long vmap_area_pcpu_hole;
@@ -351,17 +351,25 @@ static struct vmap_area *alloc_vmap_area
 
 retry:
 	spin_lock(&vmap_area_lock);
-	/* invalidate cache if we have more permissive parameters */
+	/*
+	 * Invalidate cache if we have more permissive parameters.
+	 * cached_hole_size notes the largest hole noticed _below_
+	 * the vmap_area cached in free_vmap_cache: if size fits
+	 * into that hole, we want to scan from vstart to reuse
+	 * the hole instead of allocating above free_vmap_cache.
+	 * Note that __free_vmap_area may update free_vmap_cache
+	 * without updating cached_hole_size or cached_align.
+	 */
 	if (!free_vmap_cache ||
-			size <= cached_hole_size ||
-			vstart < cached_start ||
+			size < cached_hole_size ||
+			vstart < cached_vstart ||
 			align < cached_align) {
 nocache:
 		cached_hole_size = 0;
 		free_vmap_cache = NULL;
 	}
 	/* record if we encounter less permissive parameters */
-	cached_start = vstart;
+	cached_vstart = vstart;
 	cached_align = align;
 
 	/* find starting point for our search */
@@ -379,43 +387,26 @@ nocache:
 			goto overflow;
 
 		n = vmap_area_root.rb_node;
-		if (!n)
-			goto found;
-
 		first = NULL;
-		do {
+
+		while (n) {
 			struct vmap_area *tmp;
 			tmp = rb_entry(n, struct vmap_area, rb_node);
 			if (tmp->va_end >= addr) {
-				if (!first && tmp->va_start < addr + size)
-					first = tmp;
-				n = n->rb_left;
-			} else {
 				first = tmp;
+				if (tmp->va_start <= addr)
+					break;
+				n = n->rb_left;
+			} else
 				n = n->rb_right;
-			}
-		} while (n);
+		}
 
 		if (!first)
 			goto found;
-
-		if (first->va_start < addr) {
-			addr = ALIGN(max(first->va_end + PAGE_SIZE, addr), align);
-			if (addr + size - 1 < addr)
-				goto overflow;
-			n = rb_next(&first->rb_node);
-			if (n)
-				first = rb_entry(n, struct vmap_area, rb_node);
-			else
-				goto found;
-		}
-		BUG_ON(first->va_start < addr);
-		if (addr + cached_hole_size < first->va_start)
-			cached_hole_size = first->va_start - addr;
 	}
 
 	/* from the starting point, walk areas until a suitable hole is found */
-	while (addr + size > first->va_start && addr + size <= vend) {
+	while (addr + size >= first->va_start && addr + size <= vend) {
 		if (addr + cached_hole_size < first->va_start)
 			cached_hole_size = first->va_start - addr;
 		addr = ALIGN(first->va_end + PAGE_SIZE, align);
@@ -430,21 +421,8 @@ nocache:
 	}
 
 found:
-	if (addr + size > vend) {
-overflow:
-		spin_unlock(&vmap_area_lock);
-		if (!purged) {
-			purge_vmap_area_lazy();
-			purged = 1;
-			goto retry;
-		}
-		if (printk_ratelimit())
-			printk(KERN_WARNING
-				"vmap allocation for size %lu failed: "
-				"use vmalloc=<size> to increase size.\n", size);
-		kfree(va);
-		return ERR_PTR(-EBUSY);
-	}
+	if (addr + size > vend)
+		goto overflow;
 
 	va->va_start = addr;
 	va->va_end = addr + size;
@@ -458,6 +436,20 @@ overflow:
 	BUG_ON(va->va_end > vend);
 
 	return va;
+
+overflow:
+	spin_unlock(&vmap_area_lock);
+	if (!purged) {
+		purge_vmap_area_lazy();
+		purged = 1;
+		goto retry;
+	}
+	if (printk_ratelimit())
+		printk(KERN_WARNING
+			"vmap allocation for size %lu failed: "
+			"use vmalloc=<size> to increase size.\n", size);
+	kfree(va);
+	return ERR_PTR(-EBUSY);
 }
 
 static void rcu_free_va(struct rcu_head *head)
@@ -472,14 +464,17 @@ static void __free_vmap_area(struct vmap
 	BUG_ON(RB_EMPTY_NODE(&va->rb_node));
 
 	if (free_vmap_cache) {
-		if (va->va_end < cached_start) {
+		if (va->va_end < cached_vstart) {
 			free_vmap_cache = NULL;
 		} else {
 			struct vmap_area *cache;
 			cache = rb_entry(free_vmap_cache, struct vmap_area, rb_node);
 			if (va->va_start <= cache->va_start) {
 				free_vmap_cache = rb_prev(&va->rb_node);
-				cache = rb_entry(free_vmap_cache, struct vmap_area, rb_node);
+				/*
+				 * We don't try to update cached_hole_size or
+				 * cached_align, but it won't go very wrong.
+				 */
 			}
 		}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
