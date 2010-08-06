Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F06886B02AB
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:34 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp05.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765B9XI011475
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:11:09 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FVCX1851574
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:31 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FV3x026881
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:31 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 05/43] memblock/arm: pfn_valid uses memblock_is_memory()
Date: Fri,  6 Aug 2010 15:14:46 +1000
Message-Id: <1281071724-28740-6-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

The implementation is pretty much similar. There is a -small- added
overhead by having another function call and the address shift.

If that becomes a concern, I suppose we could actually have memblock
itself expose a memblock_pfn_valid() which then ARM can use directly
with an appropriate #define...

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 arch/arm/mm/init.c |   15 +--------------
 1 files changed, 1 insertions(+), 14 deletions(-)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index d1496e6..e739223 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -237,20 +237,7 @@ static void __init arm_bootmem_free(struct meminfo *mi, unsigned long min,
 #ifndef CONFIG_SPARSEMEM
 int pfn_valid(unsigned long pfn)
 {
-	struct memblock_type *mem = &memblock.memory;
-	unsigned int left = 0, right = mem->cnt;
-
-	do {
-		unsigned int mid = (right + left) / 2;
-
-		if (pfn < memblock_start_pfn(mem, mid))
-			right = mid;
-		else if (pfn >= memblock_end_pfn(mem, mid))
-			left = mid + 1;
-		else
-			return 1;
-	} while (left < right);
-	return 0;
+	return memblock_is_memory(pfn << PAGE_SHIFT);
 }
 EXPORT_SYMBOL(pfn_valid);
 
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
