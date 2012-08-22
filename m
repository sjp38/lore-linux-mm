Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id CD29C6B0099
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:00:18 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 35/36] autonuma: add knuma_migrated/allow_first_fault in sysfs
Date: Wed, 22 Aug 2012 16:59:19 +0200
Message-Id: <1345647560-30387-36-git-send-email-aarcange@redhat.com>
In-Reply-To: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

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
 mm/autonuma.c                  |    7 +++++--
 2 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/include/linux/autonuma_flags.h b/include/linux/autonuma_flags.h
index f53203a..28756ca 100644
--- a/include/linux/autonuma_flags.h
+++ b/include/linux/autonuma_flags.h
@@ -85,6 +85,20 @@ enum autonuma_flag {
 	 * Default not set.
 	 */
 	AUTONUMA_MIGRATE_DEFER_FLAG,
+	/*
+	 * If set, a page must successfully pass a last_nid check
+	 * before it can be migrated even if it's the very first NUMA
+	 * hinting page fault occurring on the page. If not set, the
+	 * first NUMA hinting page fault of a newly allocated page
+	 * will always pass the last_nid check.
+	 *
+	 * If not set a newly started workload can converge quicker,
+	 * but it may incur in more false positive migrations before
+	 * reaching convergence.
+	 *
+	 * Default not set.
+	 */
+	AUTONUMA_MIGRATE_ALLOW_FIRST_FAULT_FLAG,
 };
 
 extern unsigned long autonuma_flags;
@@ -126,4 +140,10 @@ static inline bool autonuma_migrate_defer(void)
 	return test_bit(AUTONUMA_MIGRATE_DEFER_FLAG, &autonuma_flags);
 }
 
+static inline bool autonuma_migrate_allow_first_fault(void)
+{
+	return test_bit(AUTONUMA_MIGRATE_ALLOW_FIRST_FAULT_FLAG,
+			&autonuma_flags);
+}
+
 #endif /* _LINUX_AUTONUMA_FLAGS_H */
diff --git a/mm/autonuma.c b/mm/autonuma.c
index 4b7c744..e7570df 100644
--- a/mm/autonuma.c
+++ b/mm/autonuma.c
@@ -28,7 +28,7 @@ unsigned long autonuma_flags __read_mostly =
 #ifdef CONFIG_HAVE_ARCH_AUTONUMA_SCAN_PMD
 	|(1<<AUTONUMA_SCAN_PMD_FLAG)
 #endif
-	;
+	|(1<<AUTONUMA_MIGRATE_ALLOW_FIRST_FAULT_FLAG);
 
 static DEFINE_MUTEX(knumad_mm_mutex);
 
@@ -345,7 +345,8 @@ static inline bool last_nid_set(struct page *page, int this_nid)
 	int autonuma_last_nid = ACCESS_ONCE(page_autonuma->autonuma_last_nid);
 	VM_BUG_ON(this_nid < 0);
 	VM_BUG_ON(this_nid >= MAX_NUMNODES);
-	if (autonuma_last_nid >= 0 && autonuma_last_nid != this_nid) {
+	if ((!autonuma_migrate_allow_first_fault() ||
+	     autonuma_last_nid >= 0) && autonuma_last_nid != this_nid) {
 		int migrate_nid;
 		migrate_nid = ACCESS_ONCE(page_autonuma->autonuma_migrate_nid);
 		if (migrate_nid >= 0)
@@ -1311,6 +1312,7 @@ SYSFS_ENTRY(debug, AUTONUMA_DEBUG_FLAG);
 SYSFS_ENTRY(load_balance_strict, AUTONUMA_SCHED_LOAD_BALANCE_STRICT_FLAG);
 SYSFS_ENTRY(defer, AUTONUMA_MIGRATE_DEFER_FLAG);
 SYSFS_ENTRY(reset, AUTONUMA_SCHED_RESET_FLAG);
+SYSFS_ENTRY(allow_first_fault, AUTONUMA_MIGRATE_ALLOW_FIRST_FAULT_FLAG);
 #endif /* CONFIG_DEBUG_VM */
 
 #undef SYSFS_ENTRY
@@ -1419,6 +1421,7 @@ static struct attribute *knuma_migrated_attr[] = {
 	&pages_migrated_attr.attr,
 #ifdef CONFIG_DEBUG_VM
 	&defer_attr.attr,
+	&allow_first_fault_attr.attr,
 #endif
 	NULL,
 };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
