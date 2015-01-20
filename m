Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 6627F6B0032
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 06:33:52 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id y10so2916473pdj.9
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 03:33:52 -0800 (PST)
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com. [209.85.192.170])
        by mx.google.com with ESMTPS id n3si4486699pap.106.2015.01.20.03.33.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 03:33:50 -0800 (PST)
Received: by mail-pd0-f170.google.com with SMTP id p10so30932868pdj.1
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 03:33:50 -0800 (PST)
Message-ID: <1421753625.7353.0.camel@phoenix>
Subject: [PATCH] mm: vmstat: Fix build error when !CONFIG_PROC_FS
From: Axel Lin <axel.lin@ingics.com>
Date: Tue, 20 Jan 2015 19:33:45 +0800
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org

Fix build error when CONFIG_DEBUG_FS && CONFIG_COMPACTION && !CONFIG_PROC_FS:

  CC      mm/vmstat.o
mm/vmstat.c:1607:11: error: 'frag_start' undeclared here (not in a function)
mm/vmstat.c:1608:10: error: 'frag_next' undeclared here (not in a function)
mm/vmstat.c:1609:10: error: 'frag_stop' undeclared here (not in a function)
make[1]: *** [mm/vmstat.o] Error 1
make: *** [mm] Error 2

Signed-off-by: Axel Lin <axel.lin@ingics.com>
---
 mm/vmstat.c | 48 ++++++++++++++++++++++++------------------------
 1 file changed, 24 insertions(+), 24 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 5a47fb1..c95d6b3 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -853,6 +853,30 @@ const char * const vmstat_text[] = {
 
 #if (defined(CONFIG_DEBUG_FS) && defined(CONFIG_COMPACTION)) || \
      defined(CONFIG_PROC_FS)
+static void *frag_start(struct seq_file *m, loff_t *pos)
+{
+	pg_data_t *pgdat;
+	loff_t node = *pos;
+
+	for (pgdat = first_online_pgdat();
+	     pgdat && node;
+	     pgdat = next_online_pgdat(pgdat))
+		--node;
+
+	return pgdat;
+}
+
+static void *frag_next(struct seq_file *m, void *arg, loff_t *pos)
+{
+	pg_data_t *pgdat = (pg_data_t *)arg;
+
+	(*pos)++;
+	return next_online_pgdat(pgdat);
+}
+
+static void frag_stop(struct seq_file *m, void *arg)
+{
+}
 
 /* Walk all the zones in a node and print using a callback */
 static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
@@ -887,30 +911,6 @@ static char * const migratetype_names[MIGRATE_TYPES] = {
 #endif
 };
 
-static void *frag_start(struct seq_file *m, loff_t *pos)
-{
-	pg_data_t *pgdat;
-	loff_t node = *pos;
-	for (pgdat = first_online_pgdat();
-	     pgdat && node;
-	     pgdat = next_online_pgdat(pgdat))
-		--node;
-
-	return pgdat;
-}
-
-static void *frag_next(struct seq_file *m, void *arg, loff_t *pos)
-{
-	pg_data_t *pgdat = (pg_data_t *)arg;
-
-	(*pos)++;
-	return next_online_pgdat(pgdat);
-}
-
-static void frag_stop(struct seq_file *m, void *arg)
-{
-}
-
 static void frag_show_print(struct seq_file *m, pg_data_t *pgdat,
 						struct zone *zone)
 {
-- 
1.9.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
