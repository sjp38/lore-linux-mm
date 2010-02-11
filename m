Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A01E86B0071
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 04:30:11 -0500 (EST)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o1B9U6l5022426
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 09:30:07 GMT
Received: from pzk29 (pzk29.prod.google.com [10.243.19.157])
	by kpbe14.cbf.corp.google.com with ESMTP id o1B9TQSu018276
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 01:30:05 -0800
Received: by pzk29 with SMTP id 29so1298525pzk.17
        for <linux-mm@kvack.org>; Thu, 11 Feb 2010 01:30:04 -0800 (PST)
Date: Thu, 11 Feb 2010 01:29:58 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm: suppress pfn range output for zones without pages
Message-ID: <alpine.DEB.2.00.1002110129280.3069@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

free_area_init_nodes() emits pfn ranges for all zones on the system.
There may be no pages on a higher zone, however, due to memory
limitations or the use of the mem= kernel parameter.  For example:

Zone PFN ranges:
  DMA      0x00000001 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x00100000

The implementation copies the previous zone's highest pfn, if any, as the
next zone's lowest pfn.  If its highest pfn is then greater than the
amount of addressable memory, the upper memory limit is used instead.
Thus, both the lowest and highest possible pfn for higher zones without
memory may be the same.

The output is now suppressed for zones that do not have a valid pfn
range.

Cc: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c       |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4377,6 +4377,9 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 	for (i = 0; i < MAX_NR_ZONES; i++) {
 		if (i == ZONE_MOVABLE)
 			continue;
+		if (arch_zone_lowest_possible_pfn[i] ==
+		    arch_zone_highest_possible_pfn[i])
+			continue;
 		printk("  %-8s %0#10lx -> %0#10lx\n",
 				zone_names[i],
 				arch_zone_lowest_possible_pfn[i],

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
