Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id A9ADB6B020F
	for <linux-mm@kvack.org>; Wed,  1 May 2013 19:32:18 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 1 May 2013 17:32:17 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 67AA73E4003F
	for <linux-mm@kvack.org>; Wed,  1 May 2013 17:32:00 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r41NWEsH041186
	for <linux-mm@kvack.org>; Wed, 1 May 2013 17:32:14 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r41NWDj9017564
	for <linux-mm@kvack.org>; Wed, 1 May 2013 17:32:13 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH v2 4/4] memory_hotplug: use pgdat_resize_lock() in __offline_pages()
Date: Wed,  1 May 2013 16:32:01 -0700
Message-Id: <1367451121-22725-5-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367451121-22725-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367451121-22725-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

mmzone.h documents node_size_lock (which pgdat_resize_lock() locks) as
guarding against changes to node_present_pages, so actually lock it when
we update node_present_pages to keep that promise.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/memory_hotplug.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 0bdca10..b59a695 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1582,7 +1582,11 @@ repeat:
 	/* removal success */
 	zone->managed_pages -= offlined_pages;
 	zone->present_pages -= offlined_pages;
+
+	pgdat_resize_lock(zone->zone_pgdat, &flags);
 	zone->zone_pgdat->node_present_pages -= offlined_pages;
+	pgdat_resize_unlock(zone->zone_pgdat, &flags);
+
 	totalram_pages -= offlined_pages;
 
 	init_per_zone_wmark_min();
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
