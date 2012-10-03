Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 95E9E6B00AB
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 19:51:46 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 33/33] autonuma: add mm_autonuma working set estimation
Date: Thu,  4 Oct 2012 01:51:15 +0200
Message-Id: <1349308275-2174-34-git-send-email-aarcange@redhat.com>
In-Reply-To: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Working set estimation will only record memory that was recently used
and in turn will be eligible for automatic migration. It will ignore
memory that is never accessed by the process and that in turn will
never attempted to be migrated. This can increase NUMA convergence if
large areas of memory are never used.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/autonuma_flags.h |   25 ++++++++++++++++++++++---
 mm/autonuma.c                  |   21 +++++++++++++++++++++
 2 files changed, 43 insertions(+), 3 deletions(-)

diff --git a/include/linux/autonuma_flags.h b/include/linux/autonuma_flags.h
index 988a8b5..1c5e625 100644
--- a/include/linux/autonuma_flags.h
+++ b/include/linux/autonuma_flags.h
@@ -60,9 +60,10 @@ enum autonuma_flag {
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
@@ -87,6 +88,18 @@ enum autonuma_flag {
 	 * Default set.
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
@@ -128,6 +141,12 @@ static inline bool autonuma_migrate_allow_first_fault(void)
 			&autonuma_flags);
 }
 
+static inline bool autonuma_mm_working_set(void)
+{
+	return test_bit(AUTONUMA_MM_WORKING_SET_FLAG,
+			&autonuma_flags);
+}
+
 #else /* CONFIG_AUTONUMA */
 
 static inline bool autonuma_possible(void)
diff --git a/mm/autonuma.c b/mm/autonuma.c
index ec5b1d4..f1e699f 100644
--- a/mm/autonuma.c
+++ b/mm/autonuma.c
@@ -25,6 +25,7 @@ unsigned long autonuma_flags __read_mostly =
 	|(1<<AUTONUMA_ENABLED_FLAG)
 #endif
 	|(1<<AUTONUMA_SCAN_PMD_FLAG)
+	|(1<<AUTONUMA_MM_WORKING_SET_FLAG)
 	|(1<<AUTONUMA_MIGRATE_ALLOW_FIRST_FAULT_FLAG);
 
 static DEFINE_MUTEX(knumad_mm_mutex);
@@ -592,6 +593,11 @@ static int knuma_scand_pmd(struct mm_struct *mm,
 
 		VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 
+		if (autonuma_mm_working_set() && pmd_numa(*pmd)) {
+			spin_unlock(&mm->page_table_lock);
+			goto out;
+		}
+
 		page = pmd_page(*pmd);
 
 		/* only check non-shared pages */
@@ -627,6 +633,8 @@ static int knuma_scand_pmd(struct mm_struct *mm,
 		unsigned long *fault_tmp;
 		if (!pte_present(pteval))
 			continue;
+		if (autonuma_mm_working_set() && pte_numa(pteval))
+			continue;
 		page = vm_normal_page(vma, _address, pteval);
 		if (unlikely(!page))
 			continue;
@@ -670,6 +678,17 @@ static void mm_numa_fault_tmp_flush(struct mm_struct *mm)
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
 
@@ -1052,6 +1071,7 @@ SYSFS_ENTRY(sched_load_balance_strict, AUTONUMA_SCHED_LOAD_BALANCE_STRICT_FLAG);
 SYSFS_ENTRY(child_inheritance, AUTONUMA_CHILD_INHERITANCE_FLAG);
 SYSFS_ENTRY(migrate_allow_first_fault,
 	    AUTONUMA_MIGRATE_ALLOW_FIRST_FAULT_FLAG);
+SYSFS_ENTRY(mm_working_set, AUTONUMA_MM_WORKING_SET_FLAG);
 #endif /* CONFIG_DEBUG_VM */
 
 #undef SYSFS_ENTRY
@@ -1151,6 +1171,7 @@ static struct attribute *autonuma_attr[] = {
 #ifdef CONFIG_DEBUG_VM
 	&sched_load_balance_strict_attr.attr,
 	&child_inheritance_attr.attr,
+	&mm_working_set_attr.attr,
 #endif
 
 	NULL,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
