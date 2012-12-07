Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 6C4326B0092
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:24:15 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 10/49] mm: compaction: Add scanned and isolated counters for compaction
Date: Fri,  7 Dec 2012 10:23:13 +0000
Message-Id: <1354875832-9700-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

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
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 include/linux/vm_event_item.h |    2 ++
 mm/compaction.c               |    8 ++++++++
 mm/vmstat.c                   |    3 +++
 3 files changed, 13 insertions(+)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 8aa7cb9..a1f750b 100644
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
index 2c077a7..aee7443 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -356,6 +356,10 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 	if (blockpfn == end_pfn)
 		update_pageblock_skip(cc, valid_page, total_isolated, false);
 
+	count_vm_events(COMPACTFREE_SCANNED, nr_scanned);
+	if (total_isolated)
+		count_vm_events(COMPACTISOLATED, total_isolated);
+
 	return total_isolated;
 }
 
@@ -646,6 +650,10 @@ next_pageblock:
 
 	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
 
+	count_vm_events(COMPACTMIGRATE_SCANNED, nr_scanned);
+	if (nr_isolated)
+		count_vm_events(COMPACTISOLATED, nr_isolated);
+
 	return low_pfn;
 }
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 89a7fd6..3a067fa 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -779,6 +779,9 @@ const char * const vmstat_text[] = {
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
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
