Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f176.google.com (mail-ea0-f176.google.com [209.85.215.176])
	by kanga.kvack.org (Postfix) with ESMTP id 633796B006E
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 02:09:28 -0500 (EST)
Received: by mail-ea0-f176.google.com with SMTP id h14so1345517eaj.7
        for <linux-mm@kvack.org>; Sun, 08 Dec 2013 23:09:27 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id s8si8231099eeh.101.2013.12.08.23.09.27
        for <linux-mm@kvack.org>;
        Sun, 08 Dec 2013 23:09:27 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 15/18] mm: numa: Trace tasks that fail migration due to rate limiting
Date: Mon,  9 Dec 2013 07:09:09 +0000
Message-Id: <1386572952-1191-16-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-1-git-send-email-mgorman@suse.de>
References: <1386572952-1191-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

A low local/remote numa hinting fault ratio is potentially explained by
failed migrations. This patch adds a tracepoint that fires when migration
fails due to migration rate limitation.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/trace/events/migrate.h | 26 ++++++++++++++++++++++++++
 mm/migrate.c                   |  5 ++++-
 2 files changed, 30 insertions(+), 1 deletion(-)

diff --git a/include/trace/events/migrate.h b/include/trace/events/migrate.h
index ec2a6cc..3075ffb 100644
--- a/include/trace/events/migrate.h
+++ b/include/trace/events/migrate.h
@@ -45,6 +45,32 @@ TRACE_EVENT(mm_migrate_pages,
 		__print_symbolic(__entry->reason, MIGRATE_REASON))
 );
 
+TRACE_EVENT(mm_numa_migrate_ratelimit,
+
+	TP_PROTO(struct task_struct *p, int dst_nid, unsigned long nr_pages),
+
+	TP_ARGS(p, dst_nid, nr_pages),
+
+	TP_STRUCT__entry(
+		__array(	char,		comm,	TASK_COMM_LEN)
+		__field(	pid_t,		pid)
+		__field(	int,		dst_nid)
+		__field(	unsigned long,	nr_pages)
+	),
+
+	TP_fast_assign(
+		memcpy(__entry->comm, p->comm, TASK_COMM_LEN);
+		__entry->pid		= p->pid;
+		__entry->dst_nid	= dst_nid;
+		__entry->nr_pages	= nr_pages;
+	),
+
+	TP_printk("comm=%s pid=%d dst_nid=%d nr_pages=%lu",
+		__entry->comm,
+		__entry->pid,
+		__entry->dst_nid,
+		__entry->nr_pages)
+);
 #endif /* _TRACE_MIGRATE_H */
 
 /* This part must be outside protection */
diff --git a/mm/migrate.c b/mm/migrate.c
index 8b560d5..9f53c00 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1608,8 +1608,11 @@ static bool numamigrate_update_ratelimit(pg_data_t *pgdat,
 			msecs_to_jiffies(migrate_interval_millisecs);
 		spin_unlock(&pgdat->numabalancing_migrate_lock);
 	}
-	if (pgdat->numabalancing_migrate_nr_pages > ratelimit_pages)
+	if (pgdat->numabalancing_migrate_nr_pages > ratelimit_pages) {
+		trace_mm_numa_migrate_ratelimit(current, pgdat->node_id,
+								nr_pages);
 		return true;
+	}
 
 	/*
 	 * This is an unlocked non-atomic update so errors are possible.
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
