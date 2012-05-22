Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id D3F166B004D
	for <linux-mm@kvack.org>; Tue, 22 May 2012 04:31:50 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Tue, 22 May 2012 02:31:49 -0600
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 7D8C4C90052
	for <linux-mm@kvack.org>; Tue, 22 May 2012 04:31:42 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4M8Vjek14483672
	for <linux-mm@kvack.org>; Tue, 22 May 2012 04:31:45 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4M8VhmP009352
	for <linux-mm@kvack.org>; Tue, 22 May 2012 05:31:44 -0300
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH 2/2] mm/memblock: Fix memory leak on extending regions
Date: Tue, 22 May 2012 16:31:37 +0800
Message-Id: <1337675497-15570-2-git-send-email-shangw@linux.vnet.ibm.com>
In-Reply-To: <1337675497-15570-1-git-send-email-shangw@linux.vnet.ibm.com>
References: <1337675497-15570-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

The overall memblock has been organized into the memory regions
and reserved regions. Initially, the memory regions and reserved
regions are stored in the predetermined arrays of "struct memblock
_region". It's possible for the arrays to be enlarged when we have
newly added regions, but no free space left there. The policy here
is to create double-sized array either by slab allocator or memblock
allocator. Unfortunately, we didn't free the old array, which might
be allocated through slab allocator before. That would cause memory
leak.

The patch introduces 2 variables to trace where (slab or memblock)
the memory and reserved regions come from. The memory for the memory
or reserved regions will be deallocated by kfree() if that was allocated
by slab allocator. Thus to fix the memory leak issue.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 mm/memblock.c |   37 ++++++++++++++++++++++++-------------
 1 file changed, 24 insertions(+), 13 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index eae06ea..952123e 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -37,6 +37,8 @@ struct memblock memblock __initdata_memblock = {
 
 int memblock_debug __initdata_memblock;
 static int memblock_can_resize __initdata_memblock;
+static int memblock_memory_in_slab __initdata_memblock = 0;
+static int memblock_reserved_in_slab __initdata_memblock = 0;
 
 /* inline so we don't get a warning when pr_debug is compiled out */
 static inline const char *memblock_type_name(struct memblock_type *type)
@@ -187,6 +189,7 @@ static int __init_memblock memblock_double_array(struct memblock_type *type)
 	struct memblock_region *new_array, *old_array;
 	phys_addr_t old_size, new_size, addr;
 	int use_slab = slab_is_available();
+	int *in_slab;
 
 	/* We don't allow resizing until we know about the reserved regions
 	 * of memory that aren't suitable for allocation
@@ -198,6 +201,12 @@ static int __init_memblock memblock_double_array(struct memblock_type *type)
 	old_size = type->max * sizeof(struct memblock_region);
 	new_size = old_size << 1;
 
+	/* Retrieve the slab flag */
+	if (type == &memblock.memory)
+		in_slab = &memblock_memory_in_slab;
+	else
+		in_slab = &memblock_reserved_in_slab;
+
 	/* Try to find some space for it.
 	 *
 	 * WARNING: We assume that either slab_is_available() and we use it or
@@ -235,22 +244,24 @@ static int __init_memblock memblock_double_array(struct memblock_type *type)
 	type->regions = new_array;
 	type->max <<= 1;
 
-	/* If we use SLAB that's it, we are done */
-	if (use_slab)
-		return 0;
-
-	/* Add the new reserved region now. Should not fail ! */
-	BUG_ON(memblock_reserve(addr, new_size));
-
-	/* If the array wasn't our static init one, then free it. We only do
-	 * that before SLAB is available as later on, we don't know whether
-	 * to use kfree or free_bootmem_pages(). Shouldn't be a big deal
-	 * anyways
+	/* Free old array. We needn't free it if the array is the
+	 * static one
 	 */
-	if (old_array != memblock_memory_init_regions &&
-	    old_array != memblock_reserved_init_regions)
+	if (*in_slab)
+		kfree(old_array);
+	else if (old_array != memblock_memory_init_regions &&
+		 old_array != memblock_reserved_init_regions)
 		memblock_free(__pa(old_array), old_size);
 
+	/* Reserve the new array if that comes from the memblock.
+	 * Otherwise, we needn't do it
+	 */
+	if (!use_slab)
+		BUG_ON(memblock_reserve(addr, new_size));
+
+	/* Update slab flag */
+	*in_slab = use_slab;
+
 	return 0;
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
