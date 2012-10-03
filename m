Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 0F3AB6B00AC
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 19:51:53 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 20/33] autonuma: default mempolicy follow AutoNUMA
Date: Thu,  4 Oct 2012 01:51:02 +0200
Message-Id: <1349308275-2174-21-git-send-email-aarcange@redhat.com>
In-Reply-To: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

If an task_selected_nid has already been selected for the task, try to
allocate memory from it even if it's temporarily not the local
node. Chances are it's where most of its memory is already located and
where it will run in the future.

Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/mempolicy.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 4ada3be..5cffcb6 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1951,10 +1951,18 @@ retry_cpuset:
 	 */
 	if (pol->mode == MPOL_INTERLEAVE)
 		page = alloc_page_interleave(gfp, order, interleave_nodes(pol));
-	else
+	else {
+		int nid = -1;
+#ifdef CONFIG_AUTONUMA
+		if (current->task_autonuma)
+			nid = current->task_autonuma->task_selected_nid;
+#endif
+		if (nid < 0)
+			nid = numa_node_id();
 		page = __alloc_pages_nodemask(gfp, order,
-				policy_zonelist(gfp, pol, numa_node_id()),
+				policy_zonelist(gfp, pol, nid),
 				policy_nodemask(gfp, pol));
+	}
 
 	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
 		goto retry_cpuset;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
