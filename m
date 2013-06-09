Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 2F2AA6B0031
	for <linux-mm@kvack.org>; Sun,  9 Jun 2013 13:35:05 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id r10so498142pdi.27
        for <linux-mm@kvack.org>; Sun, 09 Jun 2013 10:35:04 -0700 (PDT)
Date: Mon, 10 Jun 2013 01:34:30 +0800
From: Wang YanQing <udknight@gmail.com>
Subject: [PATCH]memblock: do double array and add merge directly path in
 memblock_insert_region
Message-ID: <20130609173430.GA2592@udknight>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, liwanp@linux.vnet.ibm.com, tangchen@cn.fujitsu.com, tj@kernel.org

We current do double array, region insertion separately, and
have to count how many regions before do the really insertion.
This is the reasion we have the strage repeat, twice execution codes
in memblock_add_region.

If we do double array in region insertion,
we can throw away this strange and inconvenient behavior,
this patch move double array code to memblock_insert_region.

At the same time, we do region insertion and region mergence separately,
and have to iterator all regions after insert a new region every time,
it is not efficient.

If we allow do merge directly when insertion, we can get better performance,
this patch add support to do merge directly in memblock_insert_region.

Signed-off-by: Wang YanQing <udknight@gmail.com>
---
 mm/memblock.c | 87 +++++++++++++++++++++++++++++------------------------------
 1 file changed, 42 insertions(+), 45 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index c5fad93..6fc94af 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -330,20 +330,36 @@ static void __init_memblock memblock_merge_regions(struct memblock_type *type)
  *
  * Insert new memblock region [@base,@base+@size) into @type at @idx.
  * @type must already have extra room to accomodate the new region.
+ *
+ * RETURNS:
+ * 0 on sucess, non-zero on failure.
  */
-static void __init_memblock memblock_insert_region(struct memblock_type *type,
+static int __init_memblock memblock_insert_region(struct memblock_type *type,
 						   int idx, phys_addr_t base,
-						   phys_addr_t size, int nid)
+						   phys_addr_t size, int nid, int merge)
 {
 	struct memblock_region *rgn = &type->regions[idx];
 
-	BUG_ON(type->cnt >= type->max);
+	if (merge && (base + size) == rgn->base &&
+	        nid == memblock_get_region_node(rgn)) {
+		rgn->base = base;
+		rgn->size += size;
+		type->total_size += size;
+		return 0;
+	}
+
+	if (type->cnt + 1 > type->max) {
+		if (memblock_double_array(type, base, size) < 0)
+			return -ENOMEM;
+	}
+
 	memmove(rgn + 1, rgn, (type->cnt - idx) * sizeof(*rgn));
 	rgn->base = base;
 	rgn->size = size;
 	memblock_set_region_node(rgn, nid);
 	type->cnt++;
 	type->total_size += size;
+	return 0;
 }
 
 /**
@@ -364,10 +380,8 @@ static void __init_memblock memblock_insert_region(struct memblock_type *type,
 static int __init_memblock memblock_add_region(struct memblock_type *type,
 				phys_addr_t base, phys_addr_t size, int nid)
 {
-	bool insert = false;
-	phys_addr_t obase = base;
 	phys_addr_t end = base + memblock_cap_size(base, &size);
-	int i, nr_new;
+	int i, ret;
 
 	if (!size)
 		return 0;
@@ -381,14 +395,6 @@ static int __init_memblock memblock_add_region(struct memblock_type *type,
 		type->total_size = size;
 		return 0;
 	}
-repeat:
-	/*
-	 * The following is executed twice.  Once with %false @insert and
-	 * then with %true.  The first counts the number of regions needed
-	 * to accomodate the new area.  The second actually inserts them.
-	 */
-	base = obase;
-	nr_new = 0;
 
 	for (i = 0; i < type->cnt; i++) {
 		struct memblock_region *rgn = &type->regions[i];
@@ -404,10 +410,11 @@ repeat:
 		 * area, insert that portion.
 		 */
 		if (rbase > base) {
-			nr_new++;
-			if (insert)
-				memblock_insert_region(type, i++, base,
-						       rbase - base, nid);
+			ret = memblock_insert_region(type, i++, base,
+					rbase - base, nid, 1);
+			if (ret) {
+				return ret;
+			}
 		}
 		/* area below @rend is dealt with, forget about it */
 		base = min(rend, end);
@@ -415,25 +422,13 @@ repeat:
 
 	/* insert the remaining portion */
 	if (base < end) {
-		nr_new++;
-		if (insert)
-			memblock_insert_region(type, i, base, end - base, nid);
+		ret = memblock_insert_region(type, i, base, end - base, nid, 1);
+		if (ret) {
+			return ret;
+		}
 	}
 
-	/*
-	 * If this was the first round, resize array and repeat for actual
-	 * insertions; otherwise, merge and return.
-	 */
-	if (!insert) {
-		while (type->cnt + nr_new > type->max)
-			if (memblock_double_array(type, obase, size) < 0)
-				return -ENOMEM;
-		insert = true;
-		goto repeat;
-	} else {
-		memblock_merge_regions(type);
-		return 0;
-	}
+	return 0;
 }
 
 int __init_memblock memblock_add_node(phys_addr_t base, phys_addr_t size,
@@ -468,18 +463,13 @@ static int __init_memblock memblock_isolate_range(struct memblock_type *type,
 					int *start_rgn, int *end_rgn)
 {
 	phys_addr_t end = base + memblock_cap_size(base, &size);
-	int i;
+	int i, ret;
 
 	*start_rgn = *end_rgn = 0;
 
 	if (!size)
 		return 0;
 
-	/* we'll create at most two more regions */
-	while (type->cnt + 2 > type->max)
-		if (memblock_double_array(type, base, size) < 0)
-			return -ENOMEM;
-
 	for (i = 0; i < type->cnt; i++) {
 		struct memblock_region *rgn = &type->regions[i];
 		phys_addr_t rbase = rgn->base;
@@ -498,8 +488,11 @@ static int __init_memblock memblock_isolate_range(struct memblock_type *type,
 			rgn->base = base;
 			rgn->size -= base - rbase;
 			type->total_size -= base - rbase;
-			memblock_insert_region(type, i, rbase, base - rbase,
-					       memblock_get_region_node(rgn));
+			ret = memblock_insert_region(type, i, rbase, base - rbase,
+					memblock_get_region_node(rgn), 0);
+			if (ret) {
+				return ret;
+			}
 		} else if (rend > end) {
 			/*
 			 * @rgn intersects from above.  Split and redo the
@@ -508,8 +501,11 @@ static int __init_memblock memblock_isolate_range(struct memblock_type *type,
 			rgn->base = end;
 			rgn->size -= end - rbase;
 			type->total_size -= end - rbase;
-			memblock_insert_region(type, i--, rbase, end - rbase,
-					       memblock_get_region_node(rgn));
+			ret = memblock_insert_region(type, i--, rbase, end - rbase,
+					memblock_get_region_node(rgn), 0);
+			if (ret) {
+				return ret;
+			}
 		} else {
 			/* @rgn is fully contained, record it */
 			if (!*end_rgn)
@@ -533,6 +529,7 @@ static int __init_memblock __memblock_remove(struct memblock_type *type,
 
 	for (i = end_rgn - 1; i >= start_rgn; i--)
 		memblock_remove_region(type, i);
+	memblock_merge_regions(type);
 	return 0;
 }
 
-- 
1.7.12.4.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
