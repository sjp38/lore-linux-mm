Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 377176B02B4
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:36 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp07.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765FY5n025893
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:34 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FXbw872514
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:33 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FXDF021120
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:33 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 25/43] memblock: Make memblock_find_region() out of memblock_alloc_region()
Date: Fri,  6 Aug 2010 15:15:06 +1000
Message-Id: <1281071724-28740-26-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

This function will be used to locate a free area to put the new memblock
arrays when attempting to resize them. memblock_alloc_region() is gone,
the two callsites now call memblock_add_region().

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
v2. Fix membase_alloc_nid_region() conversion
---
 mm/memblock.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index a925866..c1d2060 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -309,8 +309,8 @@ static phys_addr_t memblock_align_up(phys_addr_t addr, phys_addr_t size)
 	return (addr + (size - 1)) & ~(size - 1);
 }
 
-static phys_addr_t __init memblock_alloc_region(phys_addr_t start, phys_addr_t end,
-					   phys_addr_t size, phys_addr_t align)
+static phys_addr_t __init memblock_find_region(phys_addr_t start, phys_addr_t end,
+					  phys_addr_t size, phys_addr_t align)
 {
 	phys_addr_t base, res_base;
 	long j;
@@ -318,12 +318,8 @@ static phys_addr_t __init memblock_alloc_region(phys_addr_t start, phys_addr_t e
 	base = memblock_align_down((end - size), align);
 	while (start <= base) {
 		j = memblock_overlaps_region(&memblock.reserved, base, size);
-		if (j < 0) {
-			/* this area isn't reserved, take it */
-			if (memblock_add_region(&memblock.reserved, base, size) < 0)
-				base = ~(phys_addr_t)0;
+		if (j < 0)
 			return base;
-		}
 		res_base = memblock.reserved.regions[j].base;
 		if (res_base < size)
 			break;
@@ -356,8 +352,9 @@ static phys_addr_t __init memblock_alloc_nid_region(struct memblock_region *mp,
 
 		this_end = memblock_nid_range(start, end, &this_nid);
 		if (this_nid == nid) {
-			phys_addr_t ret = memblock_alloc_region(start, this_end, size, align);
-			if (ret != ~(phys_addr_t)0)
+			phys_addr_t ret = memblock_find_region(start, this_end, size, align);
+			if (ret != ~(phys_addr_t)0 &&
+			    memblock_add_region(&memblock.reserved, ret, size) >= 0)
 				return ret;
 		}
 		start = this_end;
@@ -432,8 +429,9 @@ phys_addr_t __init __memblock_alloc_base(phys_addr_t size, phys_addr_t align, ph
 		if (memblocksize < size)
 			continue;
 		base = min(memblockbase + memblocksize, max_addr);
-		res_base = memblock_alloc_region(memblockbase, base, size, align);
-		if (res_base != ~(phys_addr_t)0)
+		res_base = memblock_find_region(memblockbase, base, size, align);
+		if (res_base != ~(phys_addr_t)0 &&
+		    memblock_add_region(&memblock.reserved, res_base, size) >= 0)
 			return res_base;
 	}
 	return 0;
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
