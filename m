Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id AEA4F6B00B6
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 19:51:55 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 32/33] autonuma: add migrate_allow_first_fault knob in sysfs
Date: Thu,  4 Oct 2012 01:51:14 +0200
Message-Id: <1349308275-2174-33-git-send-email-aarcange@redhat.com>
In-Reply-To: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

This sysfs control, if enabled, allows memory migrations on the first
numa hinting page fault.

If disabled it forbids it and requires a confirmation through the
last_nid logic.

By default, the first fault is allowed to migrate memory. Disabling it
may increase the time it takes to converge, but it reduces some
initial thrashing in case of NUMA false sharing.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/autonuma_flags.h |   20 ++++++++++++++++++++
 mm/autonuma.c                  |   11 +++++++++--
 2 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/include/linux/autonuma_flags.h b/include/linux/autonuma_flags.h
index 630ecc5..988a8b5 100644
--- a/include/linux/autonuma_flags.h
+++ b/include/linux/autonuma_flags.h
@@ -73,6 +73,20 @@ enum autonuma_flag {
 	 * Default set.
 	 */
 	AUTONUMA_SCAN_PMD_FLAG,
+	/*
+	 * If not set, a page must successfully pass a last_nid check
+	 * before it can be migrated if it's the very first NUMA
+	 * hinting page fault occurring on the page. If set, the first
+	 * NUMA hinting page fault of a newly allocated page will
+	 * always pass the last_nid check.
+	 *
+	 * If set a newly started workload can converge quicker, but
+	 * it may incur in more false positive migrations before
+	 * reaching convergence.
+	 *
+	 * Default set.
+	 */
+	AUTONUMA_MIGRATE_ALLOW_FIRST_FAULT_FLAG,
 };
 
 extern unsigned long autonuma_flags;
@@ -108,6 +122,12 @@ static inline bool autonuma_scan_pmd(void)
 	return test_bit(AUTONUMA_SCAN_PMD_FLAG, &autonuma_flags);
 }
 
+static inline bool autonuma_migrate_allow_first_fault(void)
+{
+	return test_bit(AUTONUMA_MIGRATE_ALLOW_FIRST_FAULT_FLAG,
+			&autonuma_flags);
+}
+
 #else /* CONFIG_AUTONUMA */
 
 static inline bool autonuma_possible(void)
diff --git a/mm/autonuma.c b/mm/autonuma.c
index b5c5ff6..ec5b1d4 100644
--- a/mm/autonuma.c
+++ b/mm/autonuma.c
@@ -24,7 +24,8 @@ unsigned long autonuma_flags __read_mostly =
 #ifdef CONFIG_AUTONUMA_DEFAULT_ENABLED
 	|(1<<AUTONUMA_ENABLED_FLAG)
 #endif
-	|(1<<AUTONUMA_SCAN_PMD_FLAG);
+	|(1<<AUTONUMA_SCAN_PMD_FLAG)
+	|(1<<AUTONUMA_MIGRATE_ALLOW_FIRST_FAULT_FLAG);
 
 static DEFINE_MUTEX(knumad_mm_mutex);
 
@@ -310,7 +311,8 @@ static inline bool last_nid_set(struct page *page, int this_nid)
 	VM_BUG_ON(this_nid < 0);
 	VM_BUG_ON(this_nid >= MAX_NUMNODES);
 	if (autonuma_last_nid != this_nid) {
-		if (autonuma_last_nid >= 0)
+		if (!autonuma_migrate_allow_first_fault() ||
+		    autonuma_last_nid >= 0)
 			ret = false;
 		ACCESS_ONCE(page_autonuma->autonuma_last_nid) = this_nid;
 	}
@@ -1048,6 +1050,8 @@ SYSFS_ENTRY(debug, AUTONUMA_DEBUG_FLAG);
 #ifdef CONFIG_DEBUG_VM
 SYSFS_ENTRY(sched_load_balance_strict, AUTONUMA_SCHED_LOAD_BALANCE_STRICT_FLAG);
 SYSFS_ENTRY(child_inheritance, AUTONUMA_CHILD_INHERITANCE_FLAG);
+SYSFS_ENTRY(migrate_allow_first_fault,
+	    AUTONUMA_MIGRATE_ALLOW_FIRST_FAULT_FLAG);
 #endif /* CONFIG_DEBUG_VM */
 
 #undef SYSFS_ENTRY
@@ -1130,6 +1134,9 @@ static struct attribute *autonuma_attr[] = {
 	&migrate_sleep_millisecs_attr.attr,
 	&pages_to_migrate_attr.attr,
 	&pages_migrated_attr.attr,
+#ifdef CONFIG_DEBUG_VM
+	&migrate_allow_first_fault_attr.attr,
+#endif
 	/* migrate end */
 
 	/* scan start */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
