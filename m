Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 580046B005D
	for <linux-mm@kvack.org>; Sun,  2 Dec 2012 13:44:02 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so1082361eaa.14
        for <linux-mm@kvack.org>; Sun, 02 Dec 2012 10:44:00 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 02/52] mm/compaction: Add scanned and isolated counters for compaction
Date: Sun,  2 Dec 2012 19:42:54 +0100
Message-Id: <1354473824-19229-3-git-send-email-mingo@kernel.org>
In-Reply-To: <1354473824-19229-1-git-send-email-mingo@kernel.org>
References: <1354473824-19229-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>

From: Mel Gorman <mgorman@suse.de>

Compaction already has tracepoints to count scanned and isolated
pages but it requires that ftrace be enabled and if that
information has to be written to disk then it can be disruptive.
This patch adds vmstat counters for compaction called
compact_migrate_scanned, compact_free_scanned and
compact_isolated.

With these counters, it is possible to define a basic cost model
for compaction. This approximates of how much work compaction is
doing and can be compared that with an oprofile showing TLB
misses and see if the cost of compaction is being offset by THP
for example. Minimally a compaction patch can be evaluated in
terms of whether it increases or decreases cost. The basic cost
model looks like this

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

This is very basic and ignores certain costs such as the
allocation cost to do a migrate page copy but any improvement to
the model would still use the same vmstat counters.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Paul Turner <pjt@google.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Alex Shi <lkml.alex@gmail.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
[ Build fix. ]
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/vm_event_item.h | 2 ++
 mm/compaction.c               | 8 ++++++++
 mm/vmstat.c                   | 3 +++
 3 files changed, 13 insertions(+)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 8aa7cb9..b94bafd 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -41,6 +41,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #ifdef CONFIG_MIGRATION
 		PGMIGRATE_SUCCESS, PGMIGRATE_FAIL,
 #endif
+		COMPACTMIGRATE_SCANNED, COMPACTFREE_SCANNED,
+		COMPACTISOLATED,
 #ifdef CONFIG_COMPACTION
 		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
 #endif
diff --git a/mm/compaction.c b/mm/compaction.c
index 00ad883..2add930 100644
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
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
