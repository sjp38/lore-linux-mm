Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 218C8600802
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:39 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765FSYi029563
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:28 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FZCH1806422
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:35 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FYMv021228
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:35 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 40/43] memblock: Make MEMBLOCK_ERROR be 0
Date: Fri,  6 Aug 2010 15:15:21 +1000
Message-Id: <1281071724-28740-41-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

And ensure we don't hand out 0 as a valid allocation. We put the
low limit at PAGE_SIZE arbitrarily.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 include/linux/memblock.h |    2 +-
 mm/memblock.c            |    6 ++++++
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 1a9c29c..dfa6449 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -19,7 +19,7 @@
 #include <asm/memblock.h>
 
 #define INIT_MEMBLOCK_REGIONS	128
-#define MEMBLOCK_ERROR		(~(phys_addr_t)0)
+#define MEMBLOCK_ERROR		0
 
 struct memblock_region {
 	phys_addr_t base;
diff --git a/mm/memblock.c b/mm/memblock.c
index 85cfa1d..cb520df 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -105,6 +105,12 @@ static phys_addr_t __init memblock_find_region(phys_addr_t start, phys_addr_t en
 	phys_addr_t base, res_base;
 	long j;
 
+	/* Prevent allocations returning 0 as it's also used to
+	 * indicate an allocation failure
+	 */
+	if (start == 0)
+		start = PAGE_SIZE;
+
 	base = memblock_align_down((end - size), align);
 	while (start <= base) {
 		j = memblock_overlaps_region(&memblock.reserved, base, size);
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
