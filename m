Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 33B6F900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 17:47:03 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p3ELl06B014568
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 14:47:01 -0700
Received: from iyb26 (iyb26.prod.google.com [10.241.49.90])
	by hpaq2.eem.corp.google.com with ESMTP id p3ELkQ8U027694
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 14:46:59 -0700
Received: by iyb26 with SMTP id 26so2155392iyb.12
        for <linux-mm@kvack.org>; Thu, 14 Apr 2011 14:46:59 -0700 (PDT)
Date: Thu, 14 Apr 2011 14:46:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm: fail GFP_DMA allocations when ZONE_DMA is not
 configured
Message-ID: <alpine.DEB.2.00.1104141443260.13286@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

The page allocator will improperly return a page from ZONE_NORMAL even 
when __GFP_DMA is passed if CONFIG_ZONE_DMA is disabled.  The caller 
expects DMA memory, perhaps for ISA devices with 16-bit address 
registers, and may get higher memory resulting in undefined behavior.

This patch causes the page allocator to return NULL in such circumstances 
with a warning emitted to the kernel log on the first occurrence.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2225,6 +2225,10 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 
 	if (should_fail_alloc_page(gfp_mask, order))
 		return NULL;
+#ifndef CONFIG_ZONE_DMA
+	if (WARN_ON_ONCE(gfp_mask & __GFP_DMA))
+		return NULL;
+#endif
 
 	/*
 	 * Check the zones suitable for the gfp_mask contain at least one

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
