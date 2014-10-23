Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 379B16B0069
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 12:58:49 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id n3so2539824wiv.14
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 09:58:48 -0700 (PDT)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id fg6si5695913wib.15.2014.10.23.09.58.47
        for <linux-mm@kvack.org>;
        Thu, 23 Oct 2014 09:58:47 -0700 (PDT)
From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: [RFC] mm: memblock: change default cnt for regions from 1 to 0
Date: Thu, 23 Oct 2014 17:56:53 +0100
Message-ID: <1414083413-61756-1-git-send-email-Zubair.Kakakhel@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Zubair.Kakakhel@imgtec.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

The default region counts are set to 1 with a comment saying empty
dummy entry.

If this is a dummy entry, should this be changed to 0?

We have faced this in mips/kernel/setup.c arch_mem_init.

cma uses memblock. But even with cma disabled.
The for_each_memblock(reserved, reg) goes inside the loop.
Even without any reserved regions.

Traced it to the following, when the macro
for_each_memblock(memblock_type, region) is used.

It expands to add the cnt variable.

for (region = memblock.memblock_type.regions; 		\
	region < (memblock.memblock_type.regions + memblock.memblock_type.cnt); \
	region++)

In the corner case, that there are no reserved regions.
Due to the default 1 value of cnt.
The loop under for_each_memblock still runs once.

Even when there is no reserved region.

Is this by design? or unintentional?
It might be that this loop runs an extra time every instance out there?
---
 mm/memblock.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 6d2f219..b91301c 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -33,16 +33,16 @@ static struct memblock_region memblock_physmem_init_regions[INIT_PHYSMEM_REGIONS
 
 struct memblock memblock __initdata_memblock = {
 	.memory.regions		= memblock_memory_init_regions,
-	.memory.cnt		= 1,	/* empty dummy entry */
+	.memory.cnt		= 0,	/* empty dummy entry */
 	.memory.max		= INIT_MEMBLOCK_REGIONS,
 
 	.reserved.regions	= memblock_reserved_init_regions,
-	.reserved.cnt		= 1,	/* empty dummy entry */
+	.reserved.cnt		= 0,	/* empty dummy entry */
 	.reserved.max		= INIT_MEMBLOCK_REGIONS,
 
 #ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
 	.physmem.regions	= memblock_physmem_init_regions,
-	.physmem.cnt		= 1,	/* empty dummy entry */
+	.physmem.cnt		= 0,	/* empty dummy entry */
 	.physmem.max		= INIT_PHYSMEM_REGIONS,
 #endif
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
