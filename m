Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 8A5B26B00E7
	for <linux-mm@kvack.org>; Fri, 25 May 2012 13:03:11 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 25/35] autonuma: default mempolicy follow AutoNUMA
Date: Fri, 25 May 2012 19:02:29 +0200
Message-Id: <1337965359-29725-26-git-send-email-aarcange@redhat.com>
In-Reply-To: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

If the task has already been moved to an autonuma_node try to allocate
memory from it even if it's temporarily not the local node. Chances
are it's where most of its memory is already located and where it will
run in the future.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/mempolicy.c |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 88f9422..b6b88f6 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1925,10 +1925,21 @@ retry_cpuset:
 	 */
 	if (pol->mode == MPOL_INTERLEAVE)
 		page = alloc_page_interleave(gfp, order, interleave_nodes(pol));
-	else
+	else {
+		int nid;
+#ifdef CONFIG_AUTONUMA
+		nid = -1;
+		if (current->sched_autonuma)
+			nid = current->sched_autonuma->autonuma_node;
+		if (nid < 0)
+			nid = numa_node_id();
+#else
+		nid = numa_node_id();
+#endif
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
