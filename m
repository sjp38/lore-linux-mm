Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 1E4EE6B00B4
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 06:14:15 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 31/31] mm: numa: Use a two-stage filter to restrict pages being migrated for unlikely task<->node relationships
Date: Tue, 13 Nov 2012 11:13:00 +0000
Message-Id: <1352805180-1607-32-git-send-email-mgorman@suse.de>
In-Reply-To: <1352805180-1607-1-git-send-email-mgorman@suse.de>
References: <1352805180-1607-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

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
 mm/mempolicy.c |   27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 076f8f8..89696d7 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2425,6 +2425,8 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 
 	/* Migrate pages towards their home node or the referencing node */
 	if (pol->flags & MPOL_F_HOME) {
+		int last_nid;
+
 		/*
 		 * Make a placement decision based on the home node.
 		 * NOTE: Potentially this can result in a remote->remote
@@ -2437,6 +2439,31 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 			/* No home node, migrate to the referencing node */
 			polnid = numa_node_id();
 		}
+
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
 	}
 
 	if (curnid != polnid)
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
