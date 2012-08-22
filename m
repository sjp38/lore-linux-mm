Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 1E1326B009D
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:00:19 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 36/36] autonuma: add mm_autonuma working set estimation
Date: Wed, 22 Aug 2012 16:59:20 +0200
Message-Id: <1345647560-30387-37-git-send-email-aarcange@redhat.com>
In-Reply-To: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Working set estimation will only record memory that was recently used
and in turn will be eligible for automatic migration. It will ignore
memory that is never accessed by the process and that in turn will
never attempted to be migrated. This can increase NUMA convergence if
large areas of memory are never used.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/autonuma_flags.h |   25 ++++++++++++++++++++++---
 mm/autonuma.c                  |   25 +++++++++++++++++++++++++
 2 files changed, 47 insertions(+), 3 deletions(-)

diff --git a/include/linux/autonuma_flags.h b/include/linux/autonuma_flags.h
index 28756ca..f72f2e2 100644
--- a/include/linux/autonuma_flags.h
+++ b/include/linux/autonuma_flags.h
@@ -62,9 +62,10 @@ enum autonuma_flag {
 	 * faults at the pmd level instead of the pte level. This
 	 * reduces the number of NUMA hinting faults potentially
 	 * saving CPU time. It reduces the accuracy of the
-	 * task_autonuma statistics (but does not change the accuracy
-	 * of the mm_autonuma statistics). This flag can be toggled
-	 * through sysfs as runtime.
+	 * task_autonuma statistics (it doesn't change the accuracy of
+	 * the mm_autonuma statistics if the mm_working_set mode is
+	 * not set). This flag can be toggled through sysfs as
+	 * runtime.
 	 *
 	 * This flag does not affect AutoNUMA with transparent
 	 * hugepages (THP). With THP the NUMA hinting page faults
@@ -99,6 +100,18 @@ enum autonuma_flag {
 	 * Default not set.
 	 */
 	AUTONUMA_MIGRATE_ALLOW_FIRST_FAULT_FLAG,
+	/*
+	 * If set, mm_autonuma will represent a working set estimation
+	 * of the memory used by the process over the last knuma_scand
+	 * pass.
+	 *
+	 * If not set, mm_autonuma will represent all (not shared)
+	 * memory eligible for automatic migration mapped by the
+	 * process.
+	 *
+	 * Default set.
+	 */
+	AUTONUMA_MM_WORKING_SET_FLAG,
 };
 
 extern unsigned long autonuma_flags;
@@ -146,4 +159,10 @@ static inline bool autonuma_migrate_allow_first_fault(void)
 			&autonuma_flags);
 }
 
+static inline bool autonuma_mm_working_set(void)
+{
+	return test_bit(AUTONUMA_MM_WORKING_SET_FLAG,
+			&autonuma_flags);
+}
+
 #endif /* _LINUX_AUTONUMA_FLAGS_H */
diff --git a/mm/autonuma.c b/mm/autonuma.c
index e7570df..71ce619 100644
--- a/mm/autonuma.c
+++ b/mm/autonuma.c
@@ -28,6 +28,7 @@ unsigned long autonuma_flags __read_mostly =
 #ifdef CONFIG_HAVE_ARCH_AUTONUMA_SCAN_PMD
 	|(1<<AUTONUMA_SCAN_PMD_FLAG)
 #endif
+	|(1<<AUTONUMA_MM_WORKING_SET_FLAG)
 	|(1<<AUTONUMA_MIGRATE_ALLOW_FIRST_FAULT_FLAG);
 
 static DEFINE_MUTEX(knumad_mm_mutex);
@@ -603,6 +604,12 @@ static int knuma_scand_pmd(struct mm_struct *mm,
 				unsigned long *fault_tmp;
 				ret = HPAGE_PMD_NR;
 
+				if (autonuma_mm_working_set() &&
+				    pmd_numa(*pmd)) {
+					spin_unlock(&mm->page_table_lock);
+					goto out;
+				}
+
 				page = pmd_page(*pmd);
 
 				/* only check non-shared pages */
@@ -639,6 +646,9 @@ static int knuma_scand_pmd(struct mm_struct *mm,
 		unsigned long *fault_tmp;
 		if (!pte_present(pteval))
 			continue;
+		if (autonuma_mm_working_set() &&
+		    pte_numa(pteval))
+			continue;
 		page = vm_normal_page(vma, _address, pteval);
 		if (unlikely(!page))
 			continue;
@@ -682,6 +692,17 @@ static void mm_numa_fault_tmp_flush(struct mm_struct *mm)
 	unsigned long tot;
 	unsigned long *fault_tmp = knuma_scand_data.mm_numa_fault_tmp;
 
+	if (autonuma_mm_working_set()) {
+		for_each_node(nid) {
+			tot = fault_tmp[nid];
+			if (tot)
+				break;
+		}
+		if (!tot)
+			/* process was idle, keep the old data */
+			return;
+	}
+
 	/* FIXME: would be better protected with write_seqlock_bh() */
 	local_bh_disable();
 
@@ -1313,6 +1334,7 @@ SYSFS_ENTRY(load_balance_strict, AUTONUMA_SCHED_LOAD_BALANCE_STRICT_FLAG);
 SYSFS_ENTRY(defer, AUTONUMA_MIGRATE_DEFER_FLAG);
 SYSFS_ENTRY(reset, AUTONUMA_SCHED_RESET_FLAG);
 SYSFS_ENTRY(allow_first_fault, AUTONUMA_MIGRATE_ALLOW_FIRST_FAULT_FLAG);
+SYSFS_ENTRY(mm_working_set, AUTONUMA_MM_WORKING_SET_FLAG);
 #endif /* CONFIG_DEBUG_VM */
 
 #undef SYSFS_ENTRY
@@ -1408,6 +1430,9 @@ static struct attribute *knuma_scand_attr[] = {
 #ifdef CONFIG_HAVE_ARCH_AUTONUMA_SCAN_PMD
 	&pmd_attr.attr,
 #endif
+#ifdef CONFIG_DEBUG_VM
+	&mm_working_set_attr.attr,
+#endif
 	NULL,
 };
 static struct attribute_group knuma_scand_attr_group = {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
