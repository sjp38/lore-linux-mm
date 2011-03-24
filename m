Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 755878D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 16:24:42 -0400 (EDT)
Date: Thu, 24 Mar 2011 13:24:35 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] mm: fix setup_zone_pageset section mismatch
Message-Id: <20110324132435.4ee9694e.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm <akpm@linux-foundation.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix section mismatch warning:
setup_zone_pageset() is called from build_all_zonelists(),
which can be called at any time by NUMA sysctl handler
numa_zonelist_order_handler(),
so it should not be marked as __meminit.

WARNING: mm/built-in.o(.text+0xab17): Section mismatch in reference from the function build_all_zonelists() to the function .meminit.text:setup_zone_pageset()
The function build_all_zonelists() references
the function __meminit setup_zone_pageset().
This is often because build_all_zonelists lacks a __meminit 
annotation or the annotation of setup_zone_pageset is wrong.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.38-git13.orig/mm/page_alloc.c
+++ linux-2.6.38-git13/mm/page_alloc.c
@@ -3511,7 +3511,7 @@ static void setup_pagelist_highmark(stru
 		pcp->batch = PAGE_SHIFT * 8;
 }
 
-static __meminit void setup_zone_pageset(struct zone *zone)
+static void setup_zone_pageset(struct zone *zone)
 {
 	int cpu;
 
---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
