Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 6B70F6B009C
	for <linux-mm@kvack.org>; Mon, 13 May 2013 19:13:34 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 13 May 2013 17:13:33 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 996A219D803E
	for <linux-mm@kvack.org>; Mon, 13 May 2013 17:13:24 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4DNDUFA319092
	for <linux-mm@kvack.org>; Mon, 13 May 2013 17:13:30 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4DNDU97018847
	for <linux-mm@kvack.org>; Mon, 13 May 2013 17:13:30 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH v3 3/4] memory_hotplug: use pgdat_resize_lock() in online_pages()
Date: Mon, 13 May 2013 16:13:06 -0700
Message-Id: <1368486787-9511-4-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1368486787-9511-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1368486787-9511-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

mmzone.h documents node_size_lock (which pgdat_resize_lock() locks) as
follows:

        * Must be held any time you expect node_start_pfn, node_present_pages
        * or node_spanned_pages stay constant.  [...]

So actually hold it when we update node_present_pages in online_pages().

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
