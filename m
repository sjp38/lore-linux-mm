Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id DCB536B00C2
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:24:56 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 34/49] mm: numa: Rate limit setting of pte_numa if node is saturated
Date: Fri,  7 Dec 2012 10:23:37 +0000
Message-Id: <1354875832-9700-35-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

If there are a large number of NUMA hinting faults and all of them
are resulting in migrations it may indicate that memory is just
bouncing uselessly around. NUMA balancing cost is likely exceeding
any benefit from locality. Rate limit the PTE updates if the node
is migration rate-limited. As noted in the comments, this distorts
the NUMA faulting statistics.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/migrate.h |    6 ++++++
 kernel/sched/fair.c     |    9 +++++++++
 mm/migrate.c            |   20 ++++++++++++++++++++
 3 files changed, 35 insertions(+)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 2923135..6229177 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -77,11 +77,17 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 
 #ifdef CONFIG_BALANCE_NUMA
 extern int migrate_misplaced_page(struct page *page, int node);
+extern int migrate_misplaced_page(struct page *page, int node);
+extern bool migrate_ratelimited(int node);
 #else
 static inline int migrate_misplaced_page(struct page *page, int node)
 {
 	return -EAGAIN; /* can't migrate now */
 }
+static inline bool migrate_ratelimited(int node)
+{
+	return false;
+}
 #endif /* CONFIG_BALANCE_NUMA */
 
 #endif /* _LINUX_MIGRATE_H */
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 2e65f44..357057c 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -27,6 +27,7 @@
 #include <linux/profile.h>
 #include <linux/interrupt.h>
 #include <linux/mempolicy.h>
+#include <linux/migrate.h>
 #include <linux/task_work.h>
 
 #include <trace/events/sched.h>
@@ -861,6 +862,14 @@ void task_numa_work(struct callback_head *work)
 	if (cmpxchg(&mm->numa_next_scan, migrate, next_scan) != migrate)
 		return;
 
+	/*
+	 * Do not set pte_numa if the current running node is rate-limited.
+	 * This loses statistics on the fault but if we are unwilling to
+	 * migrate to this node, it is less likely we can do useful work
+	 */
+	if (migrate_ratelimited(numa_node_id()))
+		return;
+
 	start = mm->numa_scan_offset;
 	pages = sysctl_balance_numa_scan_size;
 	pages <<= 20 - PAGE_SHIFT; /* MB in pages */
diff --git a/mm/migrate.c b/mm/migrate.c
index b2e6d4c..2c8310c 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1464,10 +1464,30 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
  * page migration rate limiting control.
  * Do not migrate more than @pages_to_migrate in a @migrate_interval_millisecs
  * window of time. Default here says do not migrate more than 1280M per second.
+ * If a node is rate-limited then PTE NUMA updates are also rate-limited. However
+ * as it is faults that reset the window, pte updates will happen unconditionally
+ * if there has not been a fault since @pteupdate_interval_millisecs after the
+ * throttle window closed.
  */
 static unsigned int migrate_interval_millisecs __read_mostly = 100;
+static unsigned int pteupdate_interval_millisecs __read_mostly = 1000;
 static unsigned int ratelimit_pages __read_mostly = 128 << (20 - PAGE_SHIFT);
 
+/* Returns true if NUMA migration is currently rate limited */
+bool migrate_ratelimited(int node)
+{
+	pg_data_t *pgdat = NODE_DATA(node);
+
+	if (time_after(jiffies, pgdat->balancenuma_migrate_next_window +
+				msecs_to_jiffies(pteupdate_interval_millisecs)))
+		return false;
+
+	if (pgdat->balancenuma_migrate_nr_pages < ratelimit_pages)
+		return false;
+
+	return true;
+}
+
 /*
  * Attempt to migrate a misplaced page to the specified destination
  * node. Caller is expected to have an elevated reference count on
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
