Message-Id: <20070614075336.635263920@sgi.com>
References: <20070614075026.607300756@sgi.com>
Date: Thu, 14 Jun 2007 00:50:37 -0700
From: clameter@sgi.com
Subject: [RFC 11/13] SLUB: Ensure that the # object per slabs stays low enough.
Content-Disposition: inline; filename=slub_oversize
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently SLUB has no provision to deal with too high page orders
that may be specified on the kernel boot line. If an order higher
than 6 (on a 4k platform) is generated then we will BUG() because
slabs get more than 65535 objects.

Add some logic that decreases order for slabs that have too many
objects. This allow booting with slab sizes up to MAX_ORDER.

For example

	slub_min_order=10

will boot with a default slab size of 4M and reduce slab sizes
for small object sizes to lower orders if the number of objects
becomes too big. Large slab sizes like that allow a concentration
of objects of the same slab cache under as few as possible TLB
entries and thus reduce TLB pressure.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

Index: vps/mm/slub.c
===================================================================
--- vps.orig/mm/slub.c	2007-06-12 15:58:35.000000000 -0700
+++ vps/mm/slub.c	2007-06-12 16:04:01.000000000 -0700
@@ -212,6 +212,11 @@ static inline void ClearSlabDebug(struct
 #define ARCH_SLAB_MINALIGN __alignof__(unsigned long long)
 #endif
 
+/*
+ * The page->inuse field is 16 bit thus we have this limitation
+ */
+#define MAX_OBJECTS_PER_SLAB 65535
+
 /* Internal SLUB flags */
 #define __OBJECT_POISON 0x80000000	/* Poison object */
 
@@ -1751,8 +1756,17 @@ static inline int slab_order(int size, i
 {
 	int order;
 	int rem;
+	int min_order = slub_min_order;
 
-	for (order = max(slub_min_order,
+	/*
+	 * If we would create too many object per slab then reduce
+	 * the slab order even if it goes below slub_min_order.
+	 */
+	while (min_order > 0 &&
+		(PAGE_SIZE << min_order) >= MAX_OBJECTS_PER_SLAB * size)
+			min_order--;
+
+	for (order = max(min_order,
 				fls(min_objects * size - 1) - PAGE_SHIFT);
 			order <= max_order; order++) {
 
@@ -1766,6 +1780,9 @@ static inline int slab_order(int size, i
 		if (rem <= slab_size / fract_leftover)
 			break;
 
+		/* If the next size is too high then exit now */
+		if (slab_size * 2 >= MAX_OBJECTS_PER_SLAB * size)
+			break;
 	}
 
 	return order;
@@ -2048,7 +2065,7 @@ static int calculate_sizes(struct kmem_c
 	 * The page->inuse field is only 16 bit wide! So we cannot have
 	 * more than 64k objects per slab.
 	 */
-	if (!s->objects || s->objects > 65535)
+	if (!s->objects || s->objects > MAX_OBJECTS_PER_SLAB)
 		return 0;
 	return 1;
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
