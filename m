Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 013716B0268
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 02:15:23 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id o138so30811673ito.2
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 23:15:22 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id 15si11823103pfz.175.2017.01.12.23.15.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 23:15:22 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id y143so7117934pfb.1
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 23:15:22 -0800 (PST)
From: js1304@gmail.com
Subject: [RFC PATCH 4/5] mm/vmstat: introduce /proc/fraginfo to get fragmentation stat stably
Date: Fri, 13 Jan 2017 16:14:32 +0900
Message-Id: <1484291673-2239-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1484291673-2239-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1484291673-2239-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/vmstat.c | 42 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 42 insertions(+)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 0b218d9..9e5a862 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1448,6 +1448,47 @@ static int zoneinfo_open(struct inode *inode, struct file *file)
 	.release	= seq_release,
 };
 
+static void fraginfo_show_print(struct seq_file *m, pg_data_t *pgdat,
+						struct zone *zone)
+{
+	int order;
+	int index;
+
+	seq_printf(m, "Node %d, zone %8s ", pgdat->node_id, zone->name);
+	for (order = 0; order < MAX_ORDER; ++order) {
+		index = zone->free_area[order].unusable_free_avg /
+			(1 << UNUSABLE_INDEX_FACTOR);
+		seq_printf(m, "0.%03d ", index);
+	}
+	seq_putc(m, '\n');
+}
+
+static int fraginfo_show(struct seq_file *m, void *arg)
+{
+	pg_data_t *pgdat = (pg_data_t *)arg;
+	walk_zones_in_node(m, pgdat, fraginfo_show_print);
+	return 0;
+}
+
+static const struct seq_operations fraginfo_op = {
+	.start	= frag_start,
+	.next	= frag_next,
+	.stop	= frag_stop,
+	.show	= fraginfo_show,
+};
+
+static int fraginfo_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &fraginfo_op);
+}
+
+static const struct file_operations fraginfo_file_operations = {
+	.open		= fraginfo_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
 enum writeback_stat_item {
 	NR_DIRTY_THRESHOLD,
 	NR_DIRTY_BG_THRESHOLD,
@@ -1778,6 +1819,7 @@ static int __init setup_vmstat(void)
 	proc_create("pagetypeinfo", S_IRUGO, NULL, &pagetypeinfo_file_ops);
 	proc_create("vmstat", S_IRUGO, NULL, &proc_vmstat_file_operations);
 	proc_create("zoneinfo", S_IRUGO, NULL, &proc_zoneinfo_file_operations);
+	proc_create("fraginfo", S_IRUGO, NULL, &fraginfo_file_operations);
 #endif
 	return 0;
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
