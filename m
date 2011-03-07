Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 190748D0039
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 22:04:03 -0500 (EST)
Subject: [PATCH/v2] mm/memblock: Properly handle overlaps and fix error path
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 07 Mar 2011 14:03:00 +1100
Message-ID: <1299466980.8833.973.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Russell King <linux@arm.linux.org.uk>, David Miller <davem@davemloft.net>

Currently memblock_reserve() or memblock_free() don't handle overlaps
of any kind. There is some special casing for coalescing exactly
adjacent regions but that's about it.

This is annoying because typically memblock_reserve() is used to
mark regions passed by the firmware as reserved and we all know
how much we can trust our firmwares...

Also, with the current code, if we do something it doesn't handle
right such as trying to memblock_reserve() a large range spanning
multiple existing smaller reserved regions for example, or doing
overlapping reservations, it can silently corrupt the internal
region array, causing odd errors much later on, such as allocations
returning reserved regions etc...

This patch rewrites the underlying functions that add or remove a
region to the arrays. The new code is a lot more robust as it fully
handles overlapping regions. It's also, imho, simpler than the previous
implementation.

In addition, while doing so, I found a bug where if we fail to double
the array while adding a region, we would remove the last region of
the array rather than the region we just allocated. This fixes it too.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

Hopefully not damaged with a spurious bit of email header this
time around... sorry about that.

diff --git a/mm/memblock.c b/mm/memblock.c
index 4618fda..de8f470 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -58,28 +58,6 @@ static unsigned long __init_memblock memblock_addrs_overlap(phys_addr_t base1, p
 	return ((base1 < (base2 + size2)) && (base2 < (base1 + size1)));
 }
 
-static long __init_memblock memblock_addrs_adjacent(phys_addr_t base1, phys_addr_t size1,
-			       phys_addr_t base2, phys_addr_t size2)
-{
-	if (base2 == base1 + size1)
-		return 1;
-	else if (base1 == base2 + size2)
-		return -1;
-
-	return 0;
-}
-
-static long __init_memblock memblock_regions_adjacent(struct memblock_type *type,
-				 unsigned long r1, unsigned long r2)
-{
-	phys_addr_t base1 = type->regions[r1].base;
-	phys_addr_t size1 = type->regions[r1].size;
-	phys_addr_t base2 = type->regions[r2].base;
-	phys_addr_t size2 = type->regions[r2].size;
-
-	return memblock_addrs_adjacent(base1, size1, base2, size2);
-}
-
 long __init_memblock memblock_overlaps_region(struct memblock_type *type, phys_addr_t base, phys_addr_t size)
 {
 	unsigned long i;
@@ -206,14 +184,13 @@ static void __init_memblock memblock_remove_region(struct memblock_type *type, u
 		type->regions[i].size = type->regions[i + 1].size;
 	}
 	type->cnt--;
-}
 
-/* Assumption: base addr of region 1 < base addr of region 2 */
-static void __init_memblock memblock_coalesce_regions(struct memblock_type *type,
-		unsigned long r1, unsigned long r2)
-{
-	type->regions[r1].size += type->regions[r2].size;
-	memblock_remove_region(type, r2);
+	/* Special case for empty arrays */
+	if (type->cnt == 0) {
+		type->cnt = 1;
+		type->regions[0].base = 0;
+		type->regions[0].size = 0;
+	}
 }
 
 /* Defined below but needed now */
@@ -276,7 +253,7 @@ static int __init_memblock memblock_double_array(struct memblock_type *type)
 		return 0;
 
 	/* Add the new reserved region now. Should not fail ! */
-	BUG_ON(memblock_add_region(&memblock.reserved, addr, new_size) < 0);
+	BUG_ON(memblock_add_region(&memblock.reserved, addr, new_size));
 
 	/* If the array wasn't our static init one, then free it. We only do
 	 * that before SLAB is available as later on, we don't know whether
@@ -296,58 +273,99 @@ extern int __init_memblock __weak memblock_memory_can_coalesce(phys_addr_t addr1
 	return 1;
 }
 
-static long __init_memblock memblock_add_region(struct memblock_type *type, phys_addr_t base, phys_addr_t size)
+static long __init_memblock memblock_add_region(struct memblock_type *type,
+						phys_addr_t base, phys_addr_t size)
 {
-	unsigned long coalesced = 0;
-	long adjacent, i;
-
-	if ((type->cnt == 1) && (type->regions[0].size == 0)) {
-		type->regions[0].base = base;
-		type->regions[0].size = size;
-		return 0;
-	}
+	phys_addr_t end = base + size;
+	int i, slot = -1;
 
-	/* First try and coalesce this MEMBLOCK with another. */
+	/* First try and coalesce this MEMBLOCK with others */
 	for (i = 0; i < type->cnt; i++) {
-		phys_addr_t rgnbase = type->regions[i].base;
-		phys_addr_t rgnsize = type->regions[i].size;
+		struct memblock_region *rgn = &type->regions[i];
+		phys_addr_t rend = rgn->base + rgn->size;
+
+		/* Exit if there's no possible hits */
+		if (rgn->base > end || rgn->size == 0)
+			break;
 
-		if ((rgnbase == base) && (rgnsize == size))
-			/* Already have this region, so we're done */
+		/* Check if we are fully enclosed within an existing
+		 * block
+		 */
+		if (rgn->base <= base && rend >= end)
 			return 0;
 
-		adjacent = memblock_addrs_adjacent(base, size, rgnbase, rgnsize);
-		/* Check if arch allows coalescing */
-		if (adjacent != 0 && type == &memblock.memory &&
-		    !memblock_memory_can_coalesce(base, size, rgnbase, rgnsize))
-			break;
-		if (adjacent > 0) {
-			type->regions[i].base -= size;
-			type->regions[i].size += size;
-			coalesced++;
-			break;
-		} else if (adjacent < 0) {
-			type->regions[i].size += size;
-			coalesced++;
-			break;
+		/* Check if we overlap or are adjacent with the bottom
+		 * of a block.
+		 */
+		if (base < rgn->base && end >= rgn->base) {
+			/* If we can't coalesce, create a new block */
+			if (!memblock_memory_can_coalesce(base, size,
+							  rgn->base,
+							  rgn->size)) {
+				/* Overlap & can't coalesce are mutually
+				 * exclusive, if you do that, be prepared
+				 * for trouble
+				 */
+				WARN_ON(end != rgn->base);
+				goto new_block;
+			}
+			/* We extend the bottom of the block down to our
+			 * base
+			 */
+			rgn->base = base;
+			rgn->size = rend - base;
+
+			/* Return if we have nothing else to allocate
+			 * (fully coalesced)
+			 */
+			if (rend >= end)
+				return 0;
+
+			/* We continue processing from the end of the
+			 * coalesced block.
+			 */
+			base = rend;
+			size = end - base;
+		}
+
+		/* Now check if we overlap or are adjacent with the
+		 * top of a block
+		 */
+		if (base <= rend && end >= rend) {
+			/* If we can't coalesce, create a new block */
+			if (!memblock_memory_can_coalesce(rgn->base,
+							  rgn->size,
+							  base, size)) {
+				/* Overlap & can't coalesce are mutually
+				 * exclusive, if you do that, be prepared
+				 * for trouble
+				 */
+				WARN_ON(rend != base);
+				goto new_block;
+			}
+			/* We adjust our base down to enclose the
+			 * original block and destroy it. It will be
+			 * part of our new allocation. Since we've
+			 * freed an entry, we know we won't fail
+			 * to allocate one later, so we won't risk
+			 * losing the original block allocation.
+			 */
+			size += (base - rgn->base);
+			base = rgn->base;			
+			memblock_remove_region(type, i--);
 		}
 	}
 
-	/* If we plugged a hole, we may want to also coalesce with the
-	 * next region
+	/* If the array is empty, special case, replace the fake
+	 * filler region and return
 	 */
-	if ((i < type->cnt - 1) && memblock_regions_adjacent(type, i, i+1) &&
-	    ((type != &memblock.memory || memblock_memory_can_coalesce(type->regions[i].base,
-							     type->regions[i].size,
-							     type->regions[i+1].base,
-							     type->regions[i+1].size)))) {
-		memblock_coalesce_regions(type, i, i+1);
-		coalesced++;
+	if ((type->cnt == 1) && (type->regions[0].size == 0)) {
+		type->regions[0].base = base;
+		type->regions[0].size = size;
+		return 0;
 	}
 
-	if (coalesced)
-		return coalesced;
-
+ new_block:
 	/* If we are out of space, we fail. It's too late to resize the array
 	 * but then this shouldn't have happened in the first place.
 	 */
@@ -362,13 +380,14 @@ static long __init_memblock memblock_add_region(struct memblock_type *type, phys
 		} else {
 			type->regions[i+1].base = base;
 			type->regions[i+1].size = size;
+			slot = i + 1;
 			break;
 		}
 	}
-
 	if (base < type->regions[0].base) {
 		type->regions[0].base = base;
 		type->regions[0].size = size;
+		slot = 0;
 	}
 	type->cnt++;
 
@@ -376,7 +395,8 @@ static long __init_memblock memblock_add_region(struct memblock_type *type, phys
 	 * our allocation and return an error
 	 */
 	if (type->cnt == type->max && memblock_double_array(type)) {
-		type->cnt--;
+		BUG_ON(slot < 0);
+		memblock_remove_region(type, slot);
 		return -1;
 	}
 
@@ -389,52 +409,55 @@ long __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
 
 }
 
-static long __init_memblock __memblock_remove(struct memblock_type *type, phys_addr_t base, phys_addr_t size)
+static long __init_memblock __memblock_remove(struct memblock_type *type,
+					      phys_addr_t base, phys_addr_t size)
 {
-	phys_addr_t rgnbegin, rgnend;
 	phys_addr_t end = base + size;
 	int i;
 
-	rgnbegin = rgnend = 0; /* supress gcc warnings */
-
-	/* Find the region where (base, size) belongs to */
-	for (i=0; i < type->cnt; i++) {
-		rgnbegin = type->regions[i].base;
-		rgnend = rgnbegin + type->regions[i].size;
+	/* Walk through the array for collisions */
+	for (i = 0; i < type->cnt; i++) {
+		struct memblock_region *rgn = &type->regions[i];
+		phys_addr_t rend = rgn->base + rgn->size;
 
-		if ((rgnbegin <= base) && (end <= rgnend))
+		/* Nothing more to do, exit */
+		if (rgn->base > end || rgn->size == 0)
 			break;
-	}
 
-	/* Didn't find the region */
-	if (i == type->cnt)
-		return -1;
+		/* If we fully enclose the block, drop it */
+		if (base <= rgn->base && end >= rend) {
+			memblock_remove_region(type, i--);
+			continue;
+		}
 
-	/* Check to see if we are removing entire region */
-	if ((rgnbegin == base) && (rgnend == end)) {
-		memblock_remove_region(type, i);
-		return 0;
-	}
+		/* If we are fully enclosed within a block
+		 * then we need to split it and we are done
+		 */
+		if (base > rgn->base && end < rend) {
+			rgn->size = base - rgn->base;
+			if (!memblock_add_region(type, end, rend - end))
+				return 0;
+			/* Failure to split is bad, we at least
+			 * restore the block before erroring
+			 */
+			rgn->size = rend - rgn->base;
+			WARN_ON(1);
+			return -1;
+		}
 
-	/* Check to see if region is matching at the front */
-	if (rgnbegin == base) {
-		type->regions[i].base = end;
-		type->regions[i].size -= size;
-		return 0;
-	}
+		/* Check if we need to trim the bottom of a block */
+		if (rgn->base < end && rend > end) {
+			rgn->size -= end - rgn->base;
+			rgn->base = end;
+			break;
+		}
 
-	/* Check to see if the region is matching at the end */
-	if (rgnend == end) {
-		type->regions[i].size -= size;
-		return 0;
-	}
+		/* And check if we need to trim the top of a block */
+		if (base < rend)
+			rgn->size -= rend - base;
 
-	/*
-	 * We need to split the entry -  adjust the current one to the
-	 * beginging of the hole and add the region after hole.
-	 */
-	type->regions[i].size = base - type->regions[i].base;
-	return memblock_add_region(type, end, rgnend - end);
+	}
+	return 0;
 }
 
 long __init_memblock memblock_remove(phys_addr_t base, phys_addr_t size)
@@ -467,7 +490,7 @@ phys_addr_t __init __memblock_alloc_base(phys_addr_t size, phys_addr_t align, ph
 
 	found = memblock_find_base(size, align, 0, max_addr);
 	if (found != MEMBLOCK_ERROR &&
-	    memblock_add_region(&memblock.reserved, found, size) >= 0)
+	    !memblock_add_region(&memblock.reserved, found, size))
 		return found;
 
 	return 0;
@@ -548,7 +571,7 @@ static phys_addr_t __init memblock_alloc_nid_region(struct memblock_region *mp,
 		if (this_nid == nid) {
 			phys_addr_t ret = memblock_find_region(start, this_end, size, align);
 			if (ret != MEMBLOCK_ERROR &&
-			    memblock_add_region(&memblock.reserved, ret, size) >= 0)
+			    !memblock_add_region(&memblock.reserved, ret, size))
 				return ret;
 		}
 		start = this_end;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
