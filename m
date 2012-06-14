Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 5876F6B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 04:35:46 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Thu, 14 Jun 2012 02:35:44 -0600
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id AC223C90057
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 04:35:12 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5E8ZDmp148292
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 04:35:13 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5EE65JF032359
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 10:06:05 -0400
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH] mm/buddy: get the allownodes for dump at once
Date: Thu, 14 Jun 2012 16:35:10 +0800
Message-Id: <1339662910-25774-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: minchan@kernel.org, mgorman@suse.de, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

When dumping the statistics for zones in the allowed nodes in the
function show_free_areas(), skip_free_areas_node() got called for
multiple times to figure out the same information: the allowed nodes
for dump. It's reasonable to get the allowed nodes at once.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 mm/page_alloc.c |   16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7892f84..211004e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2765,11 +2765,19 @@ out:
  */
 void show_free_areas(unsigned int filter)
 {
-	int cpu;
+	int nid, cpu;
+	nodemask_t allownodes;
 	struct zone *zone;
 
+	/* Figure out the allowed nodes for dump */
+	nodes_clear(allownodes);
+	for_each_online_node(nid) {
+		if (!skip_free_areas_node(filter, nid))
+			node_set(nid, allownodes);
+	}
+
 	for_each_populated_zone(zone) {
-		if (skip_free_areas_node(filter, zone_to_nid(zone)))
+		if (!node_isset(zone_to_nid(zone), allownodes))
 			continue;
 		show_node(zone);
 		printk("%s per-cpu:\n", zone->name);
@@ -2812,7 +2820,7 @@ void show_free_areas(unsigned int filter)
 	for_each_populated_zone(zone) {
 		int i;
 
-		if (skip_free_areas_node(filter, zone_to_nid(zone)))
+		if (!node_isset(zone_to_nid(zone), allownodes))
 			continue;
 		show_node(zone);
 		printk("%s"
@@ -2881,7 +2889,7 @@ void show_free_areas(unsigned int filter)
 	for_each_populated_zone(zone) {
  		unsigned long nr[MAX_ORDER], flags, order, total = 0;
 
-		if (skip_free_areas_node(filter, zone_to_nid(zone)))
+		if (!node_isset(zone_to_nid(zone), allownodes))
 			continue;
 		show_node(zone);
 		printk("%s: ", zone->name);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
