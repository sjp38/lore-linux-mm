Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 680656B00FF
	for <linux-mm@kvack.org>; Fri, 25 May 2012 13:03:38 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 14/35] autonuma: knuma_migrated per NUMA node queues
Date: Fri, 25 May 2012 19:02:18 +0200
Message-Id: <1337965359-29725-15-git-send-email-aarcange@redhat.com>
In-Reply-To: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

This implements the knuma_migrated queues. The pages are added to
these queues through the NUMA hinting page faults (memory follow CPU
algorithm with false sharing evaluation) and knuma_migrated then is
waken with a certain hysteresis to migrate the memory in round robin
from all remote nodes to its local node.

The head that belongs to the local node that knuma_migrated runs on,
for now must be empty and it's not being used.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/mmzone.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 41aa49b..8e578e6 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -666,6 +666,12 @@ typedef struct pglist_data {
 	struct task_struct *kswapd;
 	int kswapd_max_order;
 	enum zone_type classzone_idx;
+#ifdef CONFIG_AUTONUMA
+	spinlock_t autonuma_lock;
+	struct list_head autonuma_migrate_head[MAX_NUMNODES];
+	unsigned long autonuma_nr_migrate_pages;
+	wait_queue_head_t autonuma_knuma_migrated_wait;
+#endif
 } pg_data_t;
 
 #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
