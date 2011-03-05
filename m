Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5ABDE8D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 23:11:02 -0500 (EST)
Subject: [RFC] memblock; Properly handle overlaps
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 05 Mar 2011 15:05:46 +1100
Message-ID: <1299297946.8833.931.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Russell King <linux@arm.linux.org.uk>

Hi folks !

This is not fully tested yet (I'm toying with a little userspace
test bench, it seems to work well so far but I haven't yet tested
the cases with no-coalesce boundaries which at least ARM needs).

But it's good enough to get comments...

So currently, things like memblock_reserve() or memblock_free()
don't deal well -at-all- with overlaps of all kinds. Some specific
cases are handled but the code is clumsy and things will fall over
in many cases.

This is annoying because typically memblock_reserve() is used to
mark regions passed by the firmware as reserved and we all know
how much we can trust our firmwares right ?

I have also a case I need to deal with on powerpc where the flat
device-tree is fully enclosed within some other FW blob that has
its own reserve map entry, so when I end up trying to reserve
both, the current memblock code pukes.

In the end, I got tired, rewrote the low level functions to
add and remove a region in an array, and figured that my new
code looked simper and easier to understand than what was
there in the first place anyways :-) But feel free to object
or point out whether I've missed some obvious horrible case
etc...

Not-signed-off-yet-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

diff --git a/mm/memblock.c b/mm/memblock.c
index 4618fda..481b64b 100644
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
@@ -296,58 +273,94 @@ extern int __init_memblock __weak memblock_memory_can_coalesce(phys_addr_t addr1
 	return 1;
 }
 
-static long __init_memblock memblock_add_region(struct memblock_type *type, phys_addr_t base, phys_addr_t size)
+static long __init_memblock memblock_add_region(struct memblock_type *type,
+						phys_addr_t base, phys_addr_t size)
 {
-	unsigned long coalesced = 0;
-	long adjacent, i;
+	phys_addr_t end = base + size;
+	long i;
 
+	/* If the array is empty, special case, replace the fake
+	 * filler region and return
+	 */
 	if ((type->cnt == 1) && (type->regions[0].size == 0)) {
 		type->regions[0].base = base;
 		type->regions[0].size = size;
 		return 0;
 	}
 
-	/* First try and coalesce this MEMBLOCK with another. */
+	/* First try and coalesce this MEMBLOCK with others */
 	for (i = 0; i < type->cnt; i++) {
-		phys_addr_t rgnbase = type->regions[i].base;
-		phys_addr_t rgnsize = type->regions[i].size;
+		struct memblock_region *rgn = &type->regions[i];
+		phys_addr_t rend = rgn->base + rgn->size;
+
+		/* Exit if there's no possible hits */
+		if (rgn->base > end)
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
+		if (base <= rgn->base && end >= rgn->base) {
+			/* Check if we are allowed to coalesce the two
+			 * blocks. If not, we create a new block.
+			 */
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
+			rgn->size += rgn->base - base;
+			rgn->base = base;
+
+			/* We continue processing from the end of the
+			 * coalesced block.
+			 */
+			base = rgn->base + rgn->size;
 		}
-	}
 
-	/* If we plugged a hole, we may want to also coalesce with the
-	 * next region
-	 */
-	if ((i < type->cnt - 1) && memblock_regions_adjacent(type, i, i+1) &&
-	    ((type != &memblock.memory || memblock_memory_can_coalesce(type->regions[i].base,
-							     type->regions[i].size,
-							     type->regions[i+1].base,
-							     type->regions[i+1].size)))) {
-		memblock_coalesce_regions(type, i, i+1);
-		coalesced++;
-	}
+		/* Check if e have nothing else to allocate (fully coalesced) */
+		if (base >= end)
+			return 0;
 
-	if (coalesced)
-		return coalesced;
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
+			/* We  adjust our base down to enclose it
+			 * and destroy the original block
+			 */
+			size += (base - rgn->base);
+			base = rgn->base;			
+			memblock_remove_region(type, i--);
+		}
+	}
 
+ new_block:
 	/* If we are out of space, we fail. It's too late to resize the array
 	 * but then this shouldn't have happened in the first place.
 	 */
@@ -365,7 +378,6 @@ static long __init_memblock memblock_add_region(struct memblock_type *type, phys
 			break;
 		}
 	}
-
 	if (base < type->regions[0].base) {
 		type->regions[0].base = base;
 		type->regions[0].size = size;
@@ -389,52 +401,55 @@ long __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
 
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
+		if (rgn->base > end)
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
+			if (!memblock_add_region(type, end, rend - end)	)
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
@@ -467,7 +482,7 @@ phys_addr_t __init __memblock_alloc_base(phys_addr_t size, phys_addr_t align, ph
 
 	found = memblock_find_base(size, align, 0, max_addr);
 	if (found != MEMBLOCK_ERROR &&
-	    memblock_add_region(&memblock.reserved, found, size) >= 0)
+	    !memblock_add_region(&memblock.reserved, found, size))
 		return found;
 
 	return 0;
@@ -548,7 +563,7 @@ static phys_addr_t __init memblock_alloc_nid_region(struct memblock_region *mp,
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
