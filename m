Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 6B5196B0069
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 21:39:18 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Tue, 19 Jun 2012 21:39:17 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id CEBC038C801C
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 21:39:13 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5K1dDEU230680
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 21:39:13 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5K1dDlY031070
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 22:39:13 -0300
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH RESEND 2/2] mm/buddy: get the allownodes for dump at once
Date: Wed, 20 Jun 2012 09:39:08 +0800
Message-Id: <1340156348-18875-2-git-send-email-shangw@linux.vnet.ibm.com>
In-Reply-To: <1340156348-18875-1-git-send-email-shangw@linux.vnet.ibm.com>
References: <1340156348-18875-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: rientjes@google.com, hannes@cmpxchg.org, minchan@kernel.org, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

When dumping the statistics for zones in the allowed nodes in the
function show_free_areas(), skip_free_areas_node() got called for
multiple times to figure out the same information: the allowed nodes
for dump. It's reasonable to get the allowed nodes at once. That will
also help to get consistent dump information.

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
