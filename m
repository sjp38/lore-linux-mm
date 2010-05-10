Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 323CE200013
	for <linux-mm@kvack.org>; Mon, 10 May 2010 06:02:11 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 14/25] lmb: Make lmb_find_region() out of lmb_alloc_region()
Date: Mon, 10 May 2010 19:38:48 +1000
Message-Id: <1273484339-28911-15-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1273484339-28911-14-git-send-email-benh@kernel.crashing.org>
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
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

This function will be used to locate a free area to put the new lmb
arrays when attempting to resize them. lmb_alloc_region() is gone,
the two callsites now call lmb_add_region().

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 lib/lmb.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/lib/lmb.c b/lib/lmb.c
index 6765a3a..4882e9a 100644
--- a/lib/lmb.c
+++ b/lib/lmb.c
@@ -309,8 +309,8 @@ static phys_addr_t lmb_align_up(phys_addr_t addr, phys_addr_t size)
 	return (addr + (size - 1)) & ~(size - 1);
 }
 
-static phys_addr_t __init lmb_alloc_region(phys_addr_t start, phys_addr_t end,
-					   phys_addr_t size, phys_addr_t align)
+static phys_addr_t __init lmb_find_region(phys_addr_t start, phys_addr_t end,
+					  phys_addr_t size, phys_addr_t align)
 {
 	phys_addr_t base, res_base;
 	long j;
@@ -318,12 +318,8 @@ static phys_addr_t __init lmb_alloc_region(phys_addr_t start, phys_addr_t end,
 	base = lmb_align_down((end - size), align);
 	while (start <= base) {
 		j = lmb_overlaps_region(&lmb.reserved, base, size);
-		if (j < 0) {
-			/* this area isn't reserved, take it */
-			if (lmb_add_region(&lmb.reserved, base, size) < 0)
-				base = ~(phys_addr_t)0;
+		if (j < 0)
 			return base;
-		}
 		res_base = lmb.reserved.regions[j].base;
 		if (res_base < size)
 			break;
@@ -356,8 +352,9 @@ static phys_addr_t __init lmb_alloc_nid_region(struct lmb_region *mp,
 
 		this_end = lmb_nid_range(start, end, &this_nid);
 		if (this_nid == nid) {
-			phys_addr_t ret = lmb_alloc_region(start, this_end, size, align);
-			if (ret != ~(phys_addr_t)0)
+			phys_addr_t ret = lmb_find_region(start, this_end, size, align);
+			if (ret != ~(phys_addr_t)0 &&
+			    lmb_add_region(&lmb.reserved, start, size) >= 0)
 				return ret;
 		}
 		start = this_end;
@@ -432,8 +429,9 @@ phys_addr_t __init __lmb_alloc_base(phys_addr_t size, phys_addr_t align, phys_ad
 		if (lmbsize < size)
 			continue;
 		base = min(lmbbase + lmbsize, max_addr);
-		res_base = lmb_alloc_region(lmbbase, base, size, align);
-		if (res_base != ~(phys_addr_t)0)
+		res_base = lmb_find_region(lmbbase, base, size, align);		
+		if (res_base != ~(phys_addr_t)0 &&
+		    lmb_add_region(&lmb.reserved, res_base, size) >= 0)
 			return res_base;
 	}
 	return 0;
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
