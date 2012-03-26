Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 8334D6B0092
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 14:57:13 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 08/39] autonuma: mm_autonuma and sched_autonuma data structures
Date: Mon, 26 Mar 2012 19:45:55 +0200
Message-Id: <1332783986-24195-9-git-send-email-aarcange@redhat.com>
In-Reply-To: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

Define the two data structures that collect the per-process (in the
mm) and per-thread (in the task_struct) statistical information that
are the input of the CPU follow memory algorithms in the NUMA
scheduler.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/autonuma_types.h |   54 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 54 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/autonuma_types.h

diff --git a/include/linux/autonuma_types.h b/include/linux/autonuma_types.h
new file mode 100644
index 0000000..818e7c7
--- /dev/null
+++ b/include/linux/autonuma_types.h
@@ -0,0 +1,54 @@
+#ifndef _LINUX_AUTONUMA_TYPES_H
+#define _LINUX_AUTONUMA_TYPES_H
+
+#ifdef CONFIG_AUTONUMA
+
+#include <linux/numa.h>
+
+struct mm_autonuma {
+	struct list_head mm_node;
+	struct mm_struct *mm;
+	unsigned long numa_fault_tot; /* reset from here */
+	unsigned long numa_fault_pass;
+	unsigned long numa_fault[0];
+};
+
+extern int alloc_mm_autonuma(struct mm_struct *mm);
+extern void free_mm_autonuma(struct mm_struct *mm);
+extern void __init mm_autonuma_init(void);
+
+struct sched_autonuma {
+	int autonuma_node;
+	bool autonuma_stop_one_cpu; /* reset from here */
+	unsigned long numa_fault_pass;
+	unsigned long numa_fault_tot;
+	unsigned long numa_fault[0];
+};
+
+extern int alloc_sched_autonuma(struct task_struct *tsk,
+				struct task_struct *orig,
+				int node);
+extern void __init sched_autonuma_init(void);
+extern void free_sched_autonuma(struct task_struct *tsk);
+
+#else /* CONFIG_AUTONUMA */
+
+static inline int alloc_mm_autonuma(struct mm_struct *mm)
+{
+	return 0;
+}
+static inline void free_mm_autonuma(struct mm_struct *mm) {}
+static inline void mm_autonuma_init(void) {}
+
+static inline int alloc_sched_autonuma(struct task_struct *tsk,
+				       struct task_struct *orig,
+				       int node)
+{
+	return 0;
+}
+static inline void sched_autonuma_init(void) {}
+static inline void free_sched_autonuma(struct task_struct *tsk) {}
+
+#endif /* CONFIG_AUTONUMA */
+
+#endif /* _LINUX_AUTONUMA_TYPES_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
