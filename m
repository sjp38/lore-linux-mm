Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id C7BC86B0071
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 04:13:07 -0400 (EDT)
Date: Mon, 22 Oct 2012 09:05:25 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/5] mm: compaction: Add scanned and isolated counters for
 compaction
Message-ID: <20121022080525.GB2198@suse.de>
References: <1350892791-2682-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1350892791-2682-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

Compaction already has tracepoints to count scanned and isolated pages
but it requires that ftrace be enabled and if that information has to be
written to disk then it can be disruptive. This patch adds vmstat counters
for compaction called compact_migrate_scanned, compact_free_scanned and
compact_isolated.

With these counters, it is possible to define a basic cost model for
compaction. This approximates of how much work compaction is doing and can
be compared that with an oprofile showing TLB misses and see if the cost of
compaction is being offset by THP for example. Minimally a compaction patch
can be evaluated in terms of whether it increases or decreases cost. The
basic cost model looks like this

Fundamental unit u:	a word	sizeof(void *)

Ca  = cost of struct page access = sizeof(struct page) / u

Cmc = Cost migrate page copy = (Ca + PAGE_SIZE/u) * 2
Cmf = Cost migrate failure   = Ca * 2
Ci  = Cost page isolation    = (Ca + Wi)
	where Wi is a constant that should reflect the approximate
	cost of the locking operation.

Csm = Cost migrate scanning = Ca
Csf = Cost free    scanning = Ca

Overall cost =	(Csm * compact_migrate_scanned) +
	      	(Csf * compact_free_scanned)    +
	      	(Ci  * compact_isolated)	+
		(Cmc * pgmigrate_success)	+
		(Cmf * pgmigrate_failed)

Where the values are read from /proc/vmstat.

This is very basic and ignores certain costs such as the allocation cost
to do a migrate page copy but any improvement to the model would still
use the same vmstat counters.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/vm_event_item.h |    2 ++
 mm/compaction.c               |    8 ++++++++
 mm/vmstat.c                   |    3 +++
 3 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 5ce5c5f..83ea0b6 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -42,6 +42,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		PGMIGRATE_SUCCESS, PGMIGRATE_FAIL,
 #endif
 #ifdef CONFIG_COMPACTION
+		COMPACTMIGRATE_SCANNED, COMPACTFREE_SCANNED,
+		COMPACTISOLATED,
 		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
 #endif
 #ifdef CONFIG_HUGETLB_PAGE
diff --git a/mm/compaction.c b/mm/compaction.c
index 11b455b..8422dd4 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -143,6 +143,10 @@ static unsigned long isolate_freepages_block(unsigned long blockpfn,
 	}
 
 	trace_mm_compaction_isolate_freepages(nr_scanned, total_isolated);
+	count_vm_events(COMPACTFREE_SCANNED, nr_scanned);
+	if (total_isolated)
+		count_vm_events(COMPACTISOLATED, total_isolated);
+
 	return total_isolated;
 }
 
@@ -402,6 +406,10 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 
 	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
 
+	count_vm_events(COMPACTMIGRATE_SCANNED, nr_scanned);
+	if (nr_isolated)
+		count_vm_events(COMPACTISOLATED, nr_isolated);
+
 	return low_pfn;
 }
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 4849241..ab0b1b1 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -766,6 +766,9 @@ const char * const vmstat_text[] = {
 	"pgmigrate_fail",
 #endif
 #ifdef CONFIG_COMPACTION
+	"compact_migrate_scanned",
+	"compact_free_scanned",
+	"compact_isolated",
 	"compact_stall",
 	"compact_fail",
 	"compact_success",
-- 
1.7.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
