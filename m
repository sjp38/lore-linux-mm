Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BE3FD6B01B4
	for <linux-mm@kvack.org>; Sat, 22 May 2010 06:21:46 -0400 (EDT)
Received: by pwi7 with SMTP id 7so844726pwi.14
        for <linux-mm@kvack.org>; Sat, 22 May 2010 03:21:44 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 1/2] Clean up alloc_vmap_area
Date: Sat, 22 May 2010 19:21:34 +0900
Message-Id: <52219510083a624ff3d60d5671f826c33f8ef23c.1274522869.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steven Whitehouse <swhiteho@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

This patch cleans up procedure of finding empty address range.

Now alloc_vmap_area would be rather complicated due to finding
empty range wihtin [vstart,vend]

This divides vmap_area procedure following as.

alloc_vmap_area
        __get_first_vmap_area <-- get first vmap_area in range
        __get_vmap_area_addr <-- get address from first vmap_area
        __insert_vmap_area <-- add vmap_area into rbtree

This patch should not change behavior.

Cc: Nick Piggin <npiggin@suse.de>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/vmalloc.c |   98 +++++++++++++++++++++++++++++++++++++--------------------
 1 files changed, 63 insertions(+), 35 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index ae00746..651d1c1 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -320,6 +320,63 @@ static void __insert_vmap_area(struct vmap_area *va)
 static void purge_vmap_area_lazy(void);
 
 /*
+ * find first vmap_area in [addr, addr + size]
+ */
+static struct vmap_area *__get_first_vmap_area(struct rb_node *n, unsigned long addr, 
+					unsigned size)
+{
+	struct vmap_area *first = NULL;
+
+	do {
+		struct vmap_area *tmp;
+		tmp = rb_entry(n, struct vmap_area, rb_node);
+		if (tmp->va_end >= addr) {
+			if (!first && tmp->va_start < addr + size)
+				first = tmp;
+			n = n->rb_left;
+		} else {
+			first = tmp;
+			n = n->rb_right;
+		}
+	} while (n);
+
+	if (!first)
+		goto found;
+
+	if (first->va_end < addr) {
+		n = rb_next(&first->rb_node);
+		if (n)
+			first = rb_entry(n, struct vmap_area, rb_node);
+		else
+			first = NULL;						
+	}
+found:
+	return first;
+}
+
+/*
+ * Find empty range addr from first vmap_area.
+ * Return 0 if it find empty range. Otherwise, return 1.
+ */
+static int __get_vmap_area_addr(struct vmap_area *first, 
+				unsigned long *addr, unsigned long size, 
+				unsigned long vend, unsigned long align)
+{
+	struct rb_node *n;
+
+	while (*addr + size > first->va_start && *addr + size <= vend) {
+		*addr = ALIGN(first->va_end + PAGE_SIZE, align);
+		if (*addr + size - 1 < *addr)
+			return 1;
+
+		n = rb_next(&first->rb_node);
+		if (!n)
+			break;
+		first = rb_entry(n, struct vmap_area, rb_node);
+	}
+	return 0;
+}
+/*
  * Allocate a region of KVA of the specified size and alignment, within the
  * vstart and vend.
  */
@@ -351,43 +408,14 @@ retry:
 	/* XXX: could have a last_hole cache */
 	n = vmap_area_root.rb_node;
 	if (n) {
-		struct vmap_area *first = NULL;
-
-		do {
-			struct vmap_area *tmp;
-			tmp = rb_entry(n, struct vmap_area, rb_node);
-			if (tmp->va_end >= addr) {
-				if (!first && tmp->va_start < addr + size)
-					first = tmp;
-				n = n->rb_left;
-			} else {
-				first = tmp;
-				n = n->rb_right;
-			}
-		} while (n);
-
+		int ret;
+		struct vmap_area *first = __get_first_vmap_area(n, addr, size);
 		if (!first)
 			goto found;
-
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
-			if (addr + size - 1 < addr)
-				goto overflow;
-
-			n = rb_next(&first->rb_node);
-			if (n)
-				first = rb_entry(n, struct vmap_area, rb_node);
-			else
-				goto found;
-		}
+		
+		ret = __get_vmap_area_addr(first, &addr, size, vend, align);
+		if (ret == VMAP_AREA_OVERFLOW)
+			goto overflow;
 	}
 found:
 	if (addr + size > vend) {
-- 
1.7.0.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
