Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id E49AC6B004D
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 13:48:32 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so1805541bkt.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 10:48:32 -0800 (PST)
Subject: [PATCH 2/2] mm: show zone lruvec state in /proc/zoneinfo
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 23 Feb 2012 22:48:29 +0400
Message-ID: <20120223184829.7184.53490.stgit@zurg>
In-Reply-To: <20120223162111.GA4713@one.firstfloor.org>
References: <20120223162111.GA4713@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/vmstat.c |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 2c813e1..2e77a19 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -20,6 +20,8 @@
 #include <linux/writeback.h>
 #include <linux/compaction.h>
 
+#include "internal.h"
+
 #ifdef CONFIG_VM_EVENT_COUNTERS
 DEFINE_PER_CPU(struct vm_event_state, vm_event_states) = {{0}};
 EXPORT_PER_CPU_SYMBOL(vm_event_states);
@@ -1020,6 +1022,27 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		   "\n  start_pfn:         %lu",
 		   zone->all_unreclaimable,
 		   zone->zone_start_pfn);
+	seq_printf(m, "\n  lruvecs");
+	for_each_lruvec_id(i) {
+		struct lruvec *lruvec = zone->lruvec + i;
+		enum lru_list lru;
+
+		seq_printf(m,
+			   "\n    lruvec: %i",
+			   i);
+		for_each_lru(lru)
+			seq_printf(m,
+			   "\n              %s: %lu",
+			   vmstat_text[NR_LRU_BASE + lru],
+			   lruvec->pages_count[lru]);
+		seq_printf(m,
+			   "\n              %s: %lu"
+			   "\n              %s: %lu",
+			   vmstat_text[NR_ISOLATED_ANON],
+			   lruvec->pages_count[LRU_ISOLATED_ANON],
+			   vmstat_text[NR_ISOLATED_FILE],
+			   lruvec->pages_count[LRU_ISOLATED_FILE]);
+	}
 	seq_putc(m, '\n');
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
