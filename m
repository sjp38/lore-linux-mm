Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 94E7E6B024E
	for <linux-mm@kvack.org>; Mon, 10 May 2010 06:40:22 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 15/25] lmb: Define LMB_ERROR internally instead of using ~(phys_addr_t)0
Date: Mon, 10 May 2010 19:38:49 +1000
Message-Id: <1273484339-28911-16-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1273484339-28911-15-git-send-email-benh@kernel.crashing.org>
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
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 lib/lmb.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/lib/lmb.c b/lib/lmb.c
index 4882e9a..9fd0145 100644
--- a/lib/lmb.c
+++ b/lib/lmb.c
@@ -22,6 +22,8 @@ static int lmb_debug;
 static struct lmb_region lmb_memory_init_regions[INIT_LMB_REGIONS + 1];
 static struct lmb_region lmb_reserved_init_regions[INIT_LMB_REGIONS + 1];
 
+#define LMB_ERROR	(~(phys_addr_t)0)
+
 static int __init early_lmb(char *p)
 {
 	if (p && strstr(p, "debug"))
@@ -326,7 +328,7 @@ static phys_addr_t __init lmb_find_region(phys_addr_t start, phys_addr_t end,
 		base = lmb_align_down(res_base - size, align);
 	}
 
-	return ~(phys_addr_t)0;
+	return LMB_ERROR;
 }
 
 phys_addr_t __weak __init lmb_nid_range(phys_addr_t start, phys_addr_t end, int *nid)
@@ -353,14 +355,14 @@ static phys_addr_t __init lmb_alloc_nid_region(struct lmb_region *mp,
 		this_end = lmb_nid_range(start, end, &this_nid);
 		if (this_nid == nid) {
 			phys_addr_t ret = lmb_find_region(start, this_end, size, align);
-			if (ret != ~(phys_addr_t)0 &&
+			if (ret != LMB_ERROR &&
 			    lmb_add_region(&lmb.reserved, start, size) >= 0)
 				return ret;
 		}
 		start = this_end;
 	}
 
-	return ~(phys_addr_t)0;
+	return LMB_ERROR;
 }
 
 phys_addr_t __init lmb_alloc_nid(phys_addr_t size, phys_addr_t align, int nid)
@@ -379,7 +381,7 @@ phys_addr_t __init lmb_alloc_nid(phys_addr_t size, phys_addr_t align, int nid)
 	for (i = 0; i < mem->cnt; i++) {
 		phys_addr_t ret = lmb_alloc_nid_region(&mem->regions[i],
 					       size, align, nid);
-		if (ret != ~(phys_addr_t)0)
+		if (ret != LMB_ERROR)
 			return ret;
 	}
 
@@ -430,7 +432,7 @@ phys_addr_t __init __lmb_alloc_base(phys_addr_t size, phys_addr_t align, phys_ad
 			continue;
 		base = min(lmbbase + lmbsize, max_addr);
 		res_base = lmb_find_region(lmbbase, base, size, align);		
-		if (res_base != ~(phys_addr_t)0 &&
+		if (res_base != LMB_ERROR &&
 		    lmb_add_region(&lmb.reserved, res_base, size) >= 0)
 			return res_base;
 	}
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
