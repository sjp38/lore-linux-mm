Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 514246B00BE
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:25:05 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 39/49] mm: numa: Use a two-stage filter to restrict pages being migrated for unlikely task<->node relationships
Date: Fri,  7 Dec 2012 10:23:42 +0000
Message-Id: <1354875832-9700-40-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Note: This two-stage filter was taken directly from the sched/numa patch
	"sched, numa, mm: Add the scanning page fault machinery" but is
	only a partial extraction. As the end result is not necessarily
	recognisable, the signed-offs-by had to be removed. Will be added
	back if requested.

While it is desirable that all threads in a process run on its home
node, this is not always possible or necessary. There may be more
threads than exist within the node or the node might over-subscribed
with unrelated processes.

This can cause a situation whereby a page gets migrated off its home
node because the threads clearing pte_numa were running off-node. This
patch uses page->last_nid to build a two-stage filter before pages get
migrated to avoid problems with short or unlikely task<->node
relationships.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/mempolicy.c |   30 +++++++++++++++++++++++++++++-
 1 file changed, 29 insertions(+), 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 4c1c8d8..fd20e28 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2317,9 +2317,37 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 	}
 
 	/* Migrate the page towards the node whose CPU is referencing it */
-	if (pol->flags & MPOL_F_MORON)
+	if (pol->flags & MPOL_F_MORON) {
+		int last_nid;
+
 		polnid = numa_node_id();
 
+		/*
+		 * Multi-stage node selection is used in conjunction
+		 * with a periodic migration fault to build a temporal
+		 * task<->page relation. By using a two-stage filter we
+		 * remove short/unlikely relations.
+		 *
+		 * Using P(p) ~ n_p / n_t as per frequentist
+		 * probability, we can equate a task's usage of a
+		 * particular page (n_p) per total usage of this
+		 * page (n_t) (in a given time-span) to a probability.
+		 *
+		 * Our periodic faults will sample this probability and
+		 * getting the same result twice in a row, given these
+		 * samples are fully independent, is then given by
+		 * P(n)^2, provided our sample period is sufficiently
+		 * short compared to the usage pattern.
+		 *
+		 * This quadric squishes small probabilities, making
+		 * it less likely we act on an unlikely task<->page
+		 * relation.
+		 */
+		last_nid = page_xchg_last_nid(page, polnid);
+		if (last_nid != polnid)
+			goto out;
+	}
+
 	if (curnid != polnid)
 		ret = polnid;
 out:
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
