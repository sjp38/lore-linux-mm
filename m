Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 194866B007D
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:00:13 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 08/36] autonuma: define the autonuma flags
Date: Wed, 22 Aug 2012 16:58:52 +0200
Message-Id: <1345647560-30387-9-git-send-email-aarcange@redhat.com>
In-Reply-To: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

These flags are the ones tweaked through sysfs, they control the
behavior of autonuma, from enabling disabling it, to selecting various
runtime options.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/autonuma_flags.h |  129 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 129 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/autonuma_flags.h

diff --git a/include/linux/autonuma_flags.h b/include/linux/autonuma_flags.h
new file mode 100644
index 0000000..f53203a
--- /dev/null
+++ b/include/linux/autonuma_flags.h
@@ -0,0 +1,129 @@
+#ifndef _LINUX_AUTONUMA_FLAGS_H
+#define _LINUX_AUTONUMA_FLAGS_H
+
+/*
+ * If CONFIG_AUTONUMA=n this file isn't included and only
+ * autonuma_possible() is defined (as false) in autonuma.h to allow
+ * optimizing away at compile time blocks of common code without using
+ * #ifdefs.
+ */
+#ifndef CONFIG_AUTONUMA
+#error "autonuma flags included by mistake"
+#endif
+
+enum autonuma_flag {
+	/*
+	 * Set if the kernel wasn't passed the "noautonuma" boot
+	 * parameter and the hardware is NUMA. If AutoNUMA is not
+	 * possible the value of all other flags becomes irrelevant
+	 * (they will never be checked) and AutoNUMA can't be enabled.
+	 *
+	 * No defaults: depends on hardware discovery and "noautonuma"
+	 * early param.
+	 */
+	AUTONUMA_POSSIBLE_FLAG,
+	/*
+	 * If AutoNUMA is possible, this defines if AutoNUMA is
+	 * currently enabled or disabled. It can be toggled at runtime
+	 * through sysfs.
+	 *
+	 * The default depends on CONFIG_AUTONUMA_DEFAULT_ENABLED.
+	 */
+	AUTONUMA_ENABLED_FLAG,
+	/*
+	 * If set through sysfs this will print lots of debug info
+	 * about the AutoNUMA activities in the kernel logs.
+	 *
+	 * Default not set.
+	 */
+	AUTONUMA_DEBUG_FLAG,
+	/*
+	 * This defines if CFS should prioritize between load
+	 * balancing fairness or NUMA affinity, if there are no idle
+	 * CPUs available. If this flag is set AutoNUMA will
+	 * prioritize on NUMA affinity and it will disregard
+	 * inter-node fairness.
+	 *
+	 * Default not set.
+	 */
+	AUTONUMA_SCHED_LOAD_BALANCE_STRICT_FLAG,
+	/*
+	 * This flag defines if the task/mm_autonuma statistics should
+	 * be inherithed from the parent task/process or instead if
+	 * they should be cleared at every fork/clone. The
+	 * task/mm_autonuma statistics are always cleared across
+	 * execve and there's no way to disable that.
+	 *
+	 * Default set.
+	 */
+	AUTONUMA_SCHED_RESET_FLAG,
+	/*
+	 * If set, this tells knuma_scand to trigger NUMA hinting page
+	 * faults at the pmd level instead of the pte level. This
+	 * reduces the number of NUMA hinting faults potentially
+	 * saving CPU time. It reduces the accuracy of the
+	 * task_autonuma statistics (but does not change the accuracy
+	 * of the mm_autonuma statistics). This flag can be toggled
+	 * through sysfs as runtime.
+	 *
+	 * This flag does not affect AutoNUMA with transparent
+	 * hugepages (THP). With THP the NUMA hinting page faults
+	 * always happen at the pmd level, regardless of the setting
+	 * of this flag. Note: there is no reduction in accuracy of
+	 * task_autonuma statistics with THP.
+	 *
+	 * Default set.
+	 */
+	AUTONUMA_SCAN_PMD_FLAG,
+	/*
+	 * If set, knuma_migrated will wake up in the middle of each
+	 * knuma_scand pass, regardless of how many pages have been
+	 * already queued. If not set knuma_migrated will wake up as
+	 * soon as the number of pages in the migration LRU reached a
+	 * certain threshold.
+	 *
+	 * Default not set.
+	 */
+	AUTONUMA_MIGRATE_DEFER_FLAG,
+};
+
+extern unsigned long autonuma_flags;
+
+static inline bool autonuma_possible(void)
+{
+	return test_bit(AUTONUMA_POSSIBLE_FLAG, &autonuma_flags);
+}
+
+static inline bool autonuma_enabled(void)
+{
+	return test_bit(AUTONUMA_ENABLED_FLAG, &autonuma_flags);
+}
+
+static inline bool autonuma_debug(void)
+{
+	return test_bit(AUTONUMA_DEBUG_FLAG, &autonuma_flags);
+}
+
+static inline bool autonuma_sched_load_balance_strict(void)
+{
+	return test_bit(AUTONUMA_SCHED_LOAD_BALANCE_STRICT_FLAG,
+			&autonuma_flags);
+}
+
+static inline bool autonuma_sched_reset(void)
+{
+	return test_bit(AUTONUMA_SCHED_RESET_FLAG,
+			&autonuma_flags);
+}
+
+static inline bool autonuma_scan_pmd(void)
+{
+	return test_bit(AUTONUMA_SCAN_PMD_FLAG, &autonuma_flags);
+}
+
+static inline bool autonuma_migrate_defer(void)
+{
+	return test_bit(AUTONUMA_MIGRATE_DEFER_FLAG, &autonuma_flags);
+}
+
+#endif /* _LINUX_AUTONUMA_FLAGS_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
