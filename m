Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 40F236B026F
	for <linux-mm@kvack.org>; Mon, 10 May 2010 06:57:25 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 21/25] lmb: Add "start" argument to lmb_find_base()
Date: Mon, 10 May 2010 19:38:55 +1000
Message-Id: <1273484339-28911-22-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1273484339-28911-21-git-send-email-benh@kernel.crashing.org>
References: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-2-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-3-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-4-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-5-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-6-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-7-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-8-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-9-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-10-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-11-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-12-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-13-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-14-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-15-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-16-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-17-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-18-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-19-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-20-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-21-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

To constraint the search of a region between two boundaries,
which will be used by the new NUMA aware allocator among others.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 lib/lmb.c |   27 ++++++++++++++++-----------
 1 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/lib/lmb.c b/lib/lmb.c
index 84ac3a9..848f908 100644
--- a/lib/lmb.c
+++ b/lib/lmb.c
@@ -117,19 +117,18 @@ static phys_addr_t __init lmb_find_region(phys_addr_t start, phys_addr_t end,
 	return LMB_ERROR;
 }
 
-static phys_addr_t __init lmb_find_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
+static phys_addr_t __init lmb_find_base(phys_addr_t size, phys_addr_t align,
+					phys_addr_t start, phys_addr_t end)
 {
 	long i;
-	phys_addr_t base = 0;
-	phys_addr_t res_base;
 
 	BUG_ON(0 == size);
 
 	size = lmb_align_up(size, align);
 
 	/* Pump up max_addr */
-	if (max_addr == LMB_ALLOC_ACCESSIBLE)
-		max_addr = lmb.current_limit;
+	if (end == LMB_ALLOC_ACCESSIBLE)
+		end = lmb.current_limit;
 	
 	/* We do a top-down search, this tends to limit memory
 	 * fragmentation by keeping early boot allocs near the
@@ -138,13 +137,19 @@ static phys_addr_t __init lmb_find_base(phys_addr_t size, phys_addr_t align, phy
 	for (i = lmb.memory.cnt - 1; i >= 0; i--) {
 		phys_addr_t lmbbase = lmb.memory.regions[i].base;
 		phys_addr_t lmbsize = lmb.memory.regions[i].size;
+		phys_addr_t bottom, top, found;
 
 		if (lmbsize < size)
 			continue;
-		base = min(lmbbase + lmbsize, max_addr);
-		res_base = lmb_find_region(lmbbase, base, size, align);		
-		if (res_base != LMB_ERROR)
-			return res_base;
+		if ((lmbbase + lmbsize) <= start)
+			break;
+		bottom = max(lmbbase, start);
+		top = min(lmbbase + lmbsize, end);
+		if (bottom >= top)
+			continue;
+		found = lmb_find_region(lmbbase, top, size, align);		
+		if (found != LMB_ERROR)
+			return found;
 	}
 	return 0;
 }
@@ -198,7 +203,7 @@ static int lmb_double_array(struct lmb_type *type)
 		new_array = kmalloc(new_size, GFP_KERNEL);
 		addr = new_array == NULL ? LMB_ERROR : __pa(new_array);
 	} else
-		addr = lmb_find_base(new_size, sizeof(phys_addr_t), LMB_ALLOC_ACCESSIBLE);
+		addr = lmb_find_base(new_size, sizeof(phys_addr_t), 0, LMB_ALLOC_ACCESSIBLE);
 	if (addr == LMB_ERROR) {
 		pr_err("lmb: Failed to double %s array from %ld to %ld entries !\n",
 		       lmb_type_name(type), type->max, type->max * 2);
@@ -403,7 +408,7 @@ long __init lmb_reserve(phys_addr_t base, phys_addr_t size)
 
 phys_addr_t __init __lmb_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
 {
-	phys_addr_t found = lmb_find_base(size, align, max_addr);
+	phys_addr_t found = lmb_find_base(size, align, 0, max_addr);
 
 	if (found != LMB_ERROR &&
 	    lmb_add_region(&lmb.reserved, found, size) >= 0)
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
