Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CF9EB6007FD
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:37 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp03.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765BqSw013153
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:11:52 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FYew1818740
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:34 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FYeH017095
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:34 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 38/43] memblock: Improve debug output when resizing the reserve array
Date: Fri,  6 Aug 2010 15:15:19 +1000
Message-Id: <1281071724-28740-39-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Yinghai Lu <yinghai@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

From: Yinghai Lu <yinghai@kernel.org>

Print out the location info in addition to which array is being
resized. Also use memblocK_dbg() to put that under control of
the memblock_debug flag.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 mm/memblock.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 5499ab1..c3703ab 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -192,8 +192,6 @@ static int memblock_double_array(struct memblock_type *type)
 	if (!memblock_can_resize)
 		return -1;
 
-	pr_debug("memblock: %s array full, doubling...", memblock_type_name(type));
-
 	/* Calculate new doubled size */
 	old_size = type->max * sizeof(struct memblock_region);
 	new_size = old_size << 1;
@@ -221,6 +219,9 @@ static int memblock_double_array(struct memblock_type *type)
 	}
 	new_array = __va(addr);
 
+	memblock_dbg("memblock: %s array is doubled to %ld at [%#010llx-%#010llx]",
+		 memblock_type_name(type), type->max * 2, (u64)addr, (u64)addr + new_size - 1);
+
 	/* Found space, we now need to move the array over before
 	 * we add the reserved region since it may be our reserved
 	 * array itself that is full.
@@ -672,7 +673,7 @@ static void memblock_dump(struct memblock_type *region, char *name)
 		base = region->regions[i].base;
 		size = region->regions[i].size;
 
-		pr_info(" %s[0x%x]\t0x%016llx - 0x%016llx, 0x%llx bytes\n",
+		pr_info(" %s[%#x]\t[%#016llx-%#016llx], %#llx bytes\n",
 		    name, i, base, base + size - 1, size);
 	}
 }
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
