Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 54B1A60021B
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 02:47:27 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBS7lOXI007299
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 28 Dec 2009 16:47:24 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C500245DE53
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 16:47:23 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C1CD45DE51
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 16:47:23 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DFD91DB8043
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 16:47:23 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 396111DB803F
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 16:47:23 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/4] vmstat: remove zone->lock from walk_zones_in_node
Message-Id: <20091228164451.A687.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 28 Dec 2009 16:47:22 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

The zone->lock is one of performance critical locks. Then, it shouldn't
be hold for long time. Currently, we have four walk_zones_in_node()
usage and almost use-case don't need to hold zone->lock.

Thus, this patch move locking responsibility from walk_zones_in_node
to its sub function. Also this patch kill unnecessary zone->lock taking.

Cc: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmstat.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 6051fba..a5d45bc 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -418,15 +418,12 @@ static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
 {
 	struct zone *zone;
 	struct zone *node_zones = pgdat->node_zones;
-	unsigned long flags;
 
 	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
 		if (!populated_zone(zone))
 			continue;
 
-		spin_lock_irqsave(&zone->lock, flags);
 		print(m, pgdat, zone);
-		spin_unlock_irqrestore(&zone->lock, flags);
 	}
 }
 
@@ -455,6 +452,7 @@ static void pagetypeinfo_showfree_print(struct seq_file *m,
 					pg_data_t *pgdat, struct zone *zone)
 {
 	int order, mtype;
+	unsigned long flags;
 
 	for (mtype = 0; mtype < MIGRATE_TYPES; mtype++) {
 		seq_printf(m, "Node %4d, zone %8s, type %12s ",
@@ -468,8 +466,11 @@ static void pagetypeinfo_showfree_print(struct seq_file *m,
 
 			area = &(zone->free_area[order]);
 
+			spin_lock_irqsave(&zone->lock, flags);
 			list_for_each(curr, &area->free_list[mtype])
 				freecount++;
+			spin_unlock_irqrestore(&zone->lock, flags);
+
 			seq_printf(m, "%6lu ", freecount);
 		}
 		seq_putc(m, '\n');
@@ -709,6 +710,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 							struct zone *zone)
 {
 	int i;
+
 	seq_printf(m, "Node %d, zone %8s", pgdat->node_id, zone->name);
 	seq_printf(m,
 		   "\n  pages free     %lu"
-- 
1.6.5.2




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
