Date: Wed, 16 Apr 2008 14:54:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [-mm][PATCH] Fix broken gfp_zone with __GFP_THISNODE
Message-Id: <20080416145423.858462af.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "Lee.Schermerhorn@hp.com" <Lee.Schermerhorn@hp.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This patch is for -mm.
Fix broken __GFP_THISNODE.

-Kame
==
This hack, "base = MAX_NR_ZONES", at __GFP_THISNODE was used for
old zonliests.

Now, new zonelist[] have a list for __GFP_THISNODE and this hack
is incorrect. Should be removed.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/gfp.h |   17 +++++------------
 1 file changed, 5 insertions(+), 12 deletions(-)

Index: mm-2.6.25-rc8-mm2/include/linux/gfp.h
===================================================================
--- mm-2.6.25-rc8-mm2.orig/include/linux/gfp.h
+++ mm-2.6.25-rc8-mm2/include/linux/gfp.h
@@ -119,29 +119,22 @@ static inline int allocflags_to_migratet
 
 static inline enum zone_type gfp_zone(gfp_t flags)
 {
-	int base = 0;
-
-#ifdef CONFIG_NUMA
-	if (flags & __GFP_THISNODE)
-		base = MAX_NR_ZONES;
-#endif
-
 #ifdef CONFIG_ZONE_DMA
 	if (flags & __GFP_DMA)
-		return base + ZONE_DMA;
+		return ZONE_DMA;
 #endif
 #ifdef CONFIG_ZONE_DMA32
 	if (flags & __GFP_DMA32)
-		return base + ZONE_DMA32;
+		return ZONE_DMA32;
 #endif
 	if ((flags & (__GFP_HIGHMEM | __GFP_MOVABLE)) ==
 			(__GFP_HIGHMEM | __GFP_MOVABLE))
-		return base + ZONE_MOVABLE;
+		return ZONE_MOVABLE;
 #ifdef CONFIG_HIGHMEM
 	if (flags & __GFP_HIGHMEM)
-		return base + ZONE_HIGHMEM;
+		return ZONE_HIGHMEM;
 #endif
-	return base + ZONE_NORMAL;
+	return ZONE_NORMAL;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
