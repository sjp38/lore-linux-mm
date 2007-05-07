Message-Id: <20070507212411.329013996@sgi.com>
References: <20070507212240.254911542@sgi.com>
Date: Mon, 07 May 2007 14:22:57 -0700
From: clameter@sgi.com
Subject: [patch 17/17] SLUB: Rework slab order determination
Content-Disposition: inline; filename=fixordercalc
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In some cases SLUB is creating uselessly slabs that are larger than
slub_max_order. Also the layout of some of the slabs was not satisfactory.

Go to an iterarive approach.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   66 ++++++++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 52 insertions(+), 14 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-07 13:57:42.000000000 -0700
+++ slub/mm/slub.c	2007-05-07 13:57:45.000000000 -0700
@@ -1584,37 +1584,75 @@ static int slub_nomerge;
  * requested a higher mininum order then we start with that one instead of
  * the smallest order which will fit the object.
  */
-static int calculate_order(int size)
+static inline int slab_order(int size, int min_objects,
+				int max_order, int fract_leftover)
 {
 	int order;
 	int rem;
 
-	for (order = max(slub_min_order, fls(size - 1) - PAGE_SHIFT);
-			order < MAX_ORDER; order++) {
-		unsigned long slab_size = PAGE_SIZE << order;
+	for (order = max(slub_min_order,
+				fls(min_objects * size - 1) - PAGE_SHIFT);
+			order <= max_order; order++) {
 
-		if (order < slub_max_order &&
-				slab_size < slub_min_objects * size)
-			continue;
+		unsigned long slab_size = PAGE_SIZE << order;
 
-		if (slab_size < size)
+		if (slab_size < min_objects * size)
 			continue;
 
-		if (order >= slub_max_order)
-			break;
-
 		rem = slab_size % size;
 
-		if (rem <= slab_size / 8)
+		if (rem <= slab_size / fract_leftover)
 			break;
 
 	}
-	if (order >= MAX_ORDER)
-		return -E2BIG;
 
 	return order;
 }
 
+static inline int calculate_order(int size)
+{
+	int order;
+	int min_objects;
+	int fraction;
+
+	/*
+	 * Attempt to find best configuration for a slab. This
+	 * works by first attempting to generate a layout with
+	 * the best configuration and backing off gradually.
+	 *
+	 * First we reduce the acceptable waste in a slab. Then
+	 * we reduce the minimum objects required in a slab.
+	 */
+	min_objects = slub_min_objects;
+	while (min_objects > 1) {
+		fraction = 8;
+		while (fraction >= 4) {
+			order = slab_order(size, min_objects,
+						slub_max_order, fraction);
+			if (order <= slub_max_order)
+				return order;
+			fraction /= 2;
+		}
+		min_objects /= 2;
+	}
+
+	/*
+	 * We were unable to place multiple objects in a slab. Now
+	 * lets see if we can place a single object there.
+	 */
+	order = slab_order(size, 1, slub_max_order, 1);
+	if (order <= slub_max_order)
+		return order;
+
+	/*
+	 * Doh this slab cannot be placed using slub_max_order.
+	 */
+	order = slab_order(size, 1, MAX_ORDER, 1);
+	if (order <= MAX_ORDER)
+		return order;
+	return -ENOSYS;
+}
+
 /*
  * Figure out what the alignment of the objects will be.
  */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
