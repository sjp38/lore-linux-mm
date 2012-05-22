Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 8CEBD6B0082
	for <linux-mm@kvack.org>; Tue, 22 May 2012 04:32:01 -0400 (EDT)
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Tue, 22 May 2012 04:31:59 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id CD72A38C8052
	for <linux-mm@kvack.org>; Tue, 22 May 2012 04:31:42 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4M8Vh8w123090
	for <linux-mm@kvack.org>; Tue, 22 May 2012 04:31:43 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4M8VgLE011168
	for <linux-mm@kvack.org>; Tue, 22 May 2012 05:31:43 -0300
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH 1/2] mm/memblock: cleanup on duplicate VA/PA conversion
Date: Tue, 22 May 2012 16:31:36 +0800
Message-Id: <1337675497-15570-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

The overall memblock has been organized into the memory regions
and reserved regions. Initially, the memory regions and reserved
regions are stored in the predetermined arrays of "struct memblock
_region". It's possible for the arrays to be enlarged when we have
newly added regions for them, but no enough space there. Under the
situation, We will created double-sized array to meet the requirement.
However, the original implementation converted the VA (Virtual Address)
of the newly allocated array of regions to PA (Physical Address), then
translate back when we allocates the new array from slab. That's
actually unnecessary.

The patch removes the duplicate VA/PA conversion.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 mm/memblock.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index a44eab3..eae06ea 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -212,14 +212,15 @@ static int __init_memblock memblock_double_array(struct memblock_type *type)
 	if (use_slab) {
 		new_array = kmalloc(new_size, GFP_KERNEL);
 		addr = new_array ? __pa(new_array) : 0;
-	} else
+	} else {
 		addr = memblock_find_in_range(0, MEMBLOCK_ALLOC_ACCESSIBLE, new_size, sizeof(phys_addr_t));
+		new_array = addr ? __va(addr) : 0;
+	}
 	if (!addr) {
 		pr_err("memblock: Failed to double %s array from %ld to %ld entries !\n",
 		       memblock_type_name(type), type->max, type->max * 2);
 		return -1;
 	}
-	new_array = __va(addr);
 
 	memblock_dbg("memblock: %s array is doubled to %ld at [%#010llx-%#010llx]",
 		 memblock_type_name(type), type->max * 2, (u64)addr, (u64)addr + new_size - 1);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
