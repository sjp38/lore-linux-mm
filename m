Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 8116D6B012B
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 09:50:59 -0400 (EDT)
Received: by yhr47 with SMTP id 47so3286660yhr.14
        for <linux-mm@kvack.org>; Mon, 11 Jun 2012 06:50:58 -0700 (PDT)
From: kosaki.motohiro@gmail.com
Subject: [PATCH] mm: fix protection column misplacing in /proc/zoneinfo
Date: Mon, 11 Jun 2012 09:50:50 -0400
Message-Id: <1339422650-9798-1-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

commit 2244b95a7b (zoned vm counters: basic ZVC (zoned vm counter)
implementation) broke protection column. It is a part of "pages"
attribute. but not it is showed after vmstats column.

This patch restores the right position.

<before>
  pages free     3965
        min      32
        low      40
        high     48
        scanned  0
        spanned  4080
        present  3909
    (snip)
    numa_local   1
    numa_other   0
    nr_anon_transparent_hugepages 0
        protection: (0, 3512, 7867, 7867)

<after>
  pages free     3965
        min      32
        low      40
        high     48
        scanned  0
        spanned  4080
        present  3909
        protection: (0, 3504, 7851, 7851)
    nr_free_pages 3965
    nr_inactive_anon 0

Cc: Christoph Lameter <cl@linux.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmstat.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 1bbbbd9..9f5f2a9 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -987,19 +987,18 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		   zone->pages_scanned,
 		   zone->spanned_pages,
 		   zone->present_pages);
-
-	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
-		seq_printf(m, "\n    %-12s %lu", vmstat_text[i],
-				zone_page_state(zone, i));
-
 	seq_printf(m,
 		   "\n        protection: (%lu",
 		   zone->lowmem_reserve[0]);
 	for (i = 1; i < ARRAY_SIZE(zone->lowmem_reserve); i++)
 		seq_printf(m, ", %lu", zone->lowmem_reserve[i]);
-	seq_printf(m,
-		   ")"
-		   "\n  pagesets");
+	seq_printf(m, ")");
+
+	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
+		seq_printf(m, "\n    %-12s %lu", vmstat_text[i],
+				zone_page_state(zone, i));
+
+	seq_printf(m, "\n  pagesets");
 	for_each_online_cpu(i) {
 		struct per_cpu_pageset *pageset;
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
