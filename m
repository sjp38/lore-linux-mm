Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C70116200C2
	for <linux-mm@kvack.org>; Mon, 10 May 2010 05:40:05 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 05/25] lmb: Factor the lowest level alloc function
Date: Mon, 10 May 2010 19:38:39 +1000
Message-Id: <1273484339-28911-6-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1273484339-28911-5-git-send-email-benh@kernel.crashing.org>
References: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-2-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-3-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-4-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-5-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 lib/lmb.c |   59 +++++++++++++++++++++++++++--------------------------------
 1 files changed, 27 insertions(+), 32 deletions(-)

diff --git a/lib/lmb.c b/lib/lmb.c
index be3d7d9..00d5808 100644
--- a/lib/lmb.c
+++ b/lib/lmb.c
@@ -294,8 +294,8 @@ static u64 lmb_align_up(u64 addr, u64 size)
 	return (addr + (size - 1)) & ~(size - 1);
 }
 
-static u64 __init lmb_alloc_nid_unreserved(u64 start, u64 end,
-					   u64 size, u64 align)
+static u64 __init lmb_alloc_region(u64 start, u64 end,
+				   u64 size, u64 align)
 {
 	u64 base, res_base;
 	long j;
@@ -318,6 +318,13 @@ static u64 __init lmb_alloc_nid_unreserved(u64 start, u64 end,
 	return ~(u64)0;
 }
 
+u64 __weak __init lmb_nid_range(u64 start, u64 end, int *nid)
+{
+	*nid = 0;
+
+	return end;
+}
+
 static u64 __init lmb_alloc_nid_region(struct lmb_region *mp,
 				       u64 size, u64 align, int nid)
 {
@@ -333,8 +340,7 @@ static u64 __init lmb_alloc_nid_region(struct lmb_region *mp,
 
 		this_end = lmb_nid_range(start, end, &this_nid);
 		if (this_nid == nid) {
-			u64 ret = lmb_alloc_nid_unreserved(start, this_end,
-							   size, align);
+			u64 ret = lmb_alloc_region(start, this_end, size, align);
 			if (ret != ~(u64)0)
 				return ret;
 		}
@@ -351,6 +357,10 @@ u64 __init lmb_alloc_nid(u64 size, u64 align, int nid)
 
 	BUG_ON(0 == size);
 
+	/* We do a bottom-up search for a region with the right
+	 * nid since that's easier considering how lmb_nid_range()
+	 * works
+	 */
 	size = lmb_align_up(size, align);
 
 	for (i = 0; i < mem->cnt; i++) {
@@ -383,7 +393,7 @@ u64 __init lmb_alloc_base(u64 size, u64 align, u64 max_addr)
 
 u64 __init __lmb_alloc_base(u64 size, u64 align, u64 max_addr)
 {
-	long i, j;
+	long i;
 	u64 base = 0;
 	u64 res_base;
 
@@ -396,33 +406,24 @@ u64 __init __lmb_alloc_base(u64 size, u64 align, u64 max_addr)
 	if (max_addr == LMB_ALLOC_ANYWHERE)
 		max_addr = LMB_REAL_LIMIT;
 
+	/* Pump up max_addr */
+	if (max_addr == LMB_ALLOC_ANYWHERE)
+		max_addr = ~(u64)0;
+	
+	/* We do a top-down search, this tends to limit memory
+	 * fragmentation by keeping early boot allocs near the
+	 * top of memory
+	 */
 	for (i = lmb.memory.cnt - 1; i >= 0; i--) {
 		u64 lmbbase = lmb.memory.regions[i].base;
 		u64 lmbsize = lmb.memory.regions[i].size;
 
 		if (lmbsize < size)
 			continue;
-		if (max_addr == LMB_ALLOC_ANYWHERE)
-			base = lmb_align_down(lmbbase + lmbsize - size, align);
-		else if (lmbbase < max_addr) {
-			base = min(lmbbase + lmbsize, max_addr);
-			base = lmb_align_down(base - size, align);
-		} else
-			continue;
-
-		while (base && lmbbase <= base) {
-			j = lmb_overlaps_region(&lmb.reserved, base, size);
-			if (j < 0) {
-				/* this area isn't reserved, take it */
-				if (lmb_add_region(&lmb.reserved, base, size) < 0)
-					return 0;
-				return base;
-			}
-			res_base = lmb.reserved.regions[j].base;
-			if (res_base < size)
-				break;
-			base = lmb_align_down(res_base - size, align);
-		}
+		base = min(lmbbase + lmbsize, max_addr);
+		res_base = lmb_alloc_region(lmbbase, base, size, align);
+		if (res_base != ~(u64)0)
+			return res_base;
 	}
 	return 0;
 }
@@ -502,9 +503,3 @@ int lmb_is_region_reserved(u64 base, u64 size)
 	return lmb_overlaps_region(&lmb.reserved, base, size);
 }
 
-u64 __weak lmb_nid_range(u64 start, u64 end, int *nid)
-{
-	*nid = 0;
-
-	return end;
-}
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
