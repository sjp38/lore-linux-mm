Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C508C6B0387
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 17:03:34 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 67so212540008pfg.0
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 14:03:34 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 27sor13146664pgy.4.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Mar 2017 14:03:33 -0800 (PST)
Date: Mon, 6 Mar 2017 14:03:32 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] mm, vmstat: suppress pcp stats for unpopulated zones in
 zoneinfo
In-Reply-To: <alpine.DEB.2.10.1703031451310.98023@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1703061400500.46428@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1703021525500.5229@chino.kir.corp.google.com> <4acf16c5-c64b-b4f8-9a41-1926eed23fe1@linux.vnet.ibm.com> <alpine.DEB.2.10.1703031445340.92298@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1703031451310.98023@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

After "mm, vmstat: print non-populated zones in zoneinfo", /proc/zoneinfo 
will show unpopulated zones.

The per-cpu pageset statistics are not relevant for unpopulated zones and 
can be potentially lengthy, so supress them when they are not interesting.

Also moves lowmem reserve protection information above pcp stats since it 
is relevant for all zones per vm.lowmem_reserve_ratio.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/vmstat.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1392,18 +1392,24 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		   zone->present_pages,
 		   zone->managed_pages);
 
-	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
-		seq_printf(m, "\n      %-12s %lu", vmstat_text[i],
-				zone_page_state(zone, i));
-
 	seq_printf(m,
 		   "\n        protection: (%ld",
 		   zone->lowmem_reserve[0]);
 	for (i = 1; i < ARRAY_SIZE(zone->lowmem_reserve); i++)
 		seq_printf(m, ", %ld", zone->lowmem_reserve[i]);
-	seq_printf(m,
-		   ")"
-		   "\n  pagesets");
+	seq_putc(m, ')');
+
+	/* If unpopulated, no other information is useful */
+	if (!populated_zone(zone)) {
+		seq_putc(m, '\n');
+		return;
+	}
+
+	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
+		seq_printf(m, "\n      %-12s %lu", vmstat_text[i],
+				zone_page_state(zone, i));
+
+	seq_printf(m, "\n  pagesets");
 	for_each_online_cpu(i) {
 		struct per_cpu_pageset *pageset;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
