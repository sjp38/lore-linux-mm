Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3A13A82958
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 11:43:06 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r190so21620477wmr.0
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 08:43:06 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id x9si1759168wmg.67.2016.07.01.08.43.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 08:43:05 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id C68781C1E51
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 16:43:04 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 30/31] mm, vmstat: print node-based stats in zoneinfo file
Date: Fri,  1 Jul 2016 16:37:45 +0100
Message-Id: <1467387466-10022-31-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
References: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

There are a number of stats that were previously accessible via zoneinfo
that are now invisible. While it is possible to create a new file for the
node stats, this may be missed by users. Instead this patch prints the
stats under the first populated zone in /proc/zoneinfo.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmstat.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index b9a9844e3142..ce09be63e8c7 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1402,11 +1402,35 @@ static const struct file_operations pagetypeinfo_file_ops = {
 	.release	= seq_release,
 };
 
+static bool is_zone_first_populated(pg_data_t *pgdat, struct zone *zone)
+{
+	int zid;
+
+	for (zid = 0; zid < MAX_NR_ZONES; zid++) {
+		struct zone *compare = &pgdat->node_zones[zid];
+
+		if (populated_zone(compare))
+			return zone == compare;
+	}
+
+	/* The zone must be somewhere! */
+	WARN_ON_ONCE(1);
+	return false;
+}
+
 static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 							struct zone *zone)
 {
 	int i;
 	seq_printf(m, "Node %d, zone %8s", pgdat->node_id, zone->name);
+	if (is_zone_first_populated(pgdat, zone)) {
+		seq_printf(m, "\n  per-node stats");
+		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++) {
+			seq_printf(m, "\n      %-12s %lu",
+				vmstat_text[i + NR_VM_ZONE_STAT_ITEMS],
+				node_page_state(pgdat, i));
+		}
+	}
 	seq_printf(m,
 		   "\n  pages free     %lu"
 		   "\n        min      %lu"
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
