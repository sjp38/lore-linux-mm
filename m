Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id C19C96B0044
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 05:21:41 -0500 (EST)
Date: Thu, 20 Dec 2012 11:21:34 +0100 (CET)
From: Jiri Kosina <jkosina@suse.cz>
Subject: [PATCH] mm: compaction: count compaction events only if compaction
 is enabled
Message-ID: <alpine.LNX.2.00.1212201118080.17797@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On configs which have CONFIG_CMA but no CONFIG_COMPACTION, 
isolate_migratepages_range() and isolate_freepages_block() must not 
account for COMPACTFREE_SCANNED and COMPACTISOLATED events (those 
constants are even undefined in such case, causing a build error).

Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 mm/compaction.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 5ad7f4f..ca4cd82 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -303,9 +303,11 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 	if (blockpfn == end_pfn)
 		update_pageblock_skip(cc, valid_page, total_isolated, false);
 
+#ifdef CONFIG_COMPACTION
 	count_vm_events(COMPACTFREE_SCANNED, nr_scanned);
 	if (total_isolated)
 		count_vm_events(COMPACTISOLATED, total_isolated);
+#endif
 
 	return total_isolated;
 }
@@ -613,9 +615,11 @@ next_pageblock:
 
 	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
 
+#ifdef CONFIG_COMPACTION
 	count_vm_events(COMPACTMIGRATE_SCANNED, nr_scanned);
 	if (nr_isolated)
 		count_vm_events(COMPACTISOLATED, nr_isolated);
+#endif
 
 	return low_pfn;
 }

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
