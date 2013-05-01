Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id D1B416B01A7
	for <linux-mm@kvack.org>; Wed,  1 May 2013 18:17:35 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 1 May 2013 18:17:34 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id D642738C8042
	for <linux-mm@kvack.org>; Wed,  1 May 2013 18:17:31 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r41MHVSj36962508
	for <linux-mm@kvack.org>; Wed, 1 May 2013 18:17:32 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r41MHV1w010851
	for <linux-mm@kvack.org>; Wed, 1 May 2013 18:17:31 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 4/4] memory_hotplug: use pgdat_resize_lock() when updating node_present_pages
Date: Wed,  1 May 2013 15:17:15 -0700
Message-Id: <1367446635-12856-5-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367446635-12856-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367446635-12856-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

mmzone.h documents node_size_lock (which pgdat_resize_lock() locks) as
guarding against changes to node_present_pages, so actually lock it when
we update node_present_pages to keep that promise.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/memory_hotplug.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index a221fac..0bdca10 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -915,6 +915,7 @@ static void node_states_set_node(int node, struct memory_notify *arg)
 
 int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_type)
 {
+	unsigned long flags;
 	unsigned long onlined_pages = 0;
 	struct zone *zone;
 	int need_zonelists_rebuild = 0;
@@ -993,7 +994,11 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 
 	zone->managed_pages += onlined_pages;
 	zone->present_pages += onlined_pages;
+
+	pgdat_resize_lock(zone->zone_pgdat, &flags);
 	zone->zone_pgdat->node_present_pages += onlined_pages;
+	pgdat_resize_unlock(zone->zone_pgdat, &flags);
+
 	if (onlined_pages) {
 		node_states_set_node(zone_to_nid(zone), &arg);
 		if (need_zonelists_rebuild)
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
