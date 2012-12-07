Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id B3A896B00CE
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:25:08 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 41/49] mm: sched: numa: Control enabling and disabling of NUMA balancing
Date: Fri,  7 Dec 2012 10:23:44 +0000
Message-Id: <1354875832-9700-42-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This patch adds Kconfig options and kernel parameters to allow the
enabling and disabling of automatic NUMA balancing. The existance
of such a switch was and is very important when debugging problems
related to transparent hugepages and we should have the same for
automatic NUMA placement.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 Documentation/kernel-parameters.txt |    3 +++
 include/linux/sched.h               |    4 +++
 init/Kconfig                        |    8 ++++++
 kernel/sched/core.c                 |   48 ++++++++++++++++++++++++-----------
 kernel/sched/fair.c                 |    3 +++
 kernel/sched/features.h             |    6 +++--
 mm/mempolicy.c                      |   46 +++++++++++++++++++++++++++++++++
 7 files changed, 101 insertions(+), 17 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 9776f06..d984acb 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -403,6 +403,9 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 	atkbd.softrepeat= [HW]
 			Use software keyboard repeat
 
+	balancenuma=	[KNL,X86] Enable or disable automatic NUMA balancing.
+			Allowed values are enable and disable
+
 	baycom_epp=	[HW,AX25]
 			Format: <io>,<mode>
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 1068afd..2669bdd 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1563,10 +1563,14 @@ struct task_struct {
 
 #ifdef CONFIG_BALANCE_NUMA
 extern void task_numa_fault(int node, int pages, bool migrated);
+extern void set_balancenuma_state(bool enabled);
 #else
 static inline void task_numa_fault(int node, int pages, bool migrated)
 {
 }
+static inline void set_balancenuma_state(bool enabled)
+{
+}
 #endif
 
 /*
diff --git a/init/Kconfig b/init/Kconfig
index 6897a05..4cccc00f 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -720,6 +720,14 @@ config ARCH_USES_NUMA_PROT_NONE
 	depends on ARCH_WANTS_PROT_NUMA_PROT_NONE
 	depends on BALANCE_NUMA
 
+config BALANCE_NUMA_DEFAULT_ENABLED
+	bool "Automatically enable NUMA aware memory/task placement"
+	default y
+	depends on BALANCE_NUMA
+	help
+	  If set, autonumic NUMA balancing will be enabled if running on a NUMA
+	  machine.
+
 config BALANCE_NUMA
 	bool "Memory placement aware NUMA scheduler"
 	default n
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index a59d869..4841f4f 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -192,23 +192,10 @@ static void sched_feat_disable(int i) { };
 static void sched_feat_enable(int i) { };
 #endif /* HAVE_JUMP_LABEL */
 
-static ssize_t
-sched_feat_write(struct file *filp, const char __user *ubuf,
-		size_t cnt, loff_t *ppos)
+static int sched_feat_set(char *cmp)
 {
-	char buf[64];
-	char *cmp;
-	int neg = 0;
 	int i;
-
-	if (cnt > 63)
-		cnt = 63;
-
-	if (copy_from_user(&buf, ubuf, cnt))
-		return -EFAULT;
-
-	buf[cnt] = 0;
-	cmp = strstrip(buf);
+	int neg = 0;
 
 	if (strncmp(cmp, "NO_", 3) == 0) {
 		neg = 1;
@@ -228,6 +215,27 @@ sched_feat_write(struct file *filp, const char __user *ubuf,
 		}
 	}
 
+	return i;
+}
+
+static ssize_t
+sched_feat_write(struct file *filp, const char __user *ubuf,
+		size_t cnt, loff_t *ppos)
+{
+	char buf[64];
+	char *cmp;
+	int i;
+
+	if (cnt > 63)
+		cnt = 63;
+
+	if (copy_from_user(&buf, ubuf, cnt))
+		return -EFAULT;
+
+	buf[cnt] = 0;
+	cmp = strstrip(buf);
+
+	i = sched_feat_set(cmp);
 	if (i == __SCHED_FEAT_NR)
 		return -EINVAL;
 
@@ -1549,6 +1557,16 @@ static void __sched_fork(struct task_struct *p)
 #endif /* CONFIG_BALANCE_NUMA */
 }
 
+#ifdef CONFIG_BALANCE_NUMA
+void set_balancenuma_state(bool enabled)
+{
+	if (enabled)
+		sched_feat_set("NUMA");
+	else
+		sched_feat_set("NO_NUMA");
+}
+#endif /* CONFIG_BALANCE_NUMA */
+
 /*
  * fork()/clone()-time setup:
  */
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index c1be907..b4bc459 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -811,6 +811,9 @@ void task_numa_fault(int node, int pages, bool migrated)
 {
 	struct task_struct *p = current;
 
+	if (!sched_feat_numa(NUMA))
+		return;
+
 	/* FIXME: Allocate task-specific structure for placement policy here */
 
 	/*
diff --git a/kernel/sched/features.h b/kernel/sched/features.h
index 7cfd289..d402368 100644
--- a/kernel/sched/features.h
+++ b/kernel/sched/features.h
@@ -63,8 +63,10 @@ SCHED_FEAT(RT_RUNTIME_SHARE, true)
 SCHED_FEAT(LB_MIN, false)
 
 /*
- * Apply the automatic NUMA scheduling policy
+ * Apply the automatic NUMA scheduling policy. Enabled automatically
+ * at runtime if running on a NUMA machine. Can be controlled via
+ * balancenuma=
  */
 #ifdef CONFIG_BALANCE_NUMA
-SCHED_FEAT(NUMA,	true)
+SCHED_FEAT(NUMA,	false)
 #endif
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index fd20e28..56ad9bf 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2521,6 +2521,50 @@ void mpol_free_shared_policy(struct shared_policy *p)
 	mutex_unlock(&p->mutex);
 }
 
+#ifdef CONFIG_BALANCE_NUMA
+static bool __initdata balancenuma_override;
+
+static void __init check_balancenuma_enable(void)
+{
+	bool balancenuma_default = false;
+
+	if (IS_ENABLED(CONFIG_BALANCE_NUMA_DEFAULT_ENABLED))
+		balancenuma_default = true;
+
+	if (nr_node_ids > 1 && !balancenuma_override) {
+		printk(KERN_INFO "Enabling automatic NUMA balancing. "
+			"Configure with balancenuma= or sysctl");
+		set_balancenuma_state(balancenuma_default);
+	}
+}
+
+static int __init setup_balancenuma(char *str)
+{
+	int ret = 0;
+	if (!str)
+		goto out;
+	balancenuma_override = true;
+
+	if (!strcmp(str, "enable")) {
+		set_balancenuma_state(true);
+		ret = 1;
+	} else if (!strcmp(str, "disable")) {
+		set_balancenuma_state(false);
+		ret = 1;
+	}
+out:
+	if (!ret)
+		printk(KERN_WARNING "Unable to parse balancenuma=\n");
+
+	return ret;
+}
+__setup("balancenuma=", setup_balancenuma);
+#else
+static inline void __init check_balancenuma_enable(void)
+{
+}
+#endif /* CONFIG_BALANCE_NUMA */
+
 /* assumes fs == KERNEL_DS */
 void __init numa_policy_init(void)
 {
@@ -2571,6 +2615,8 @@ void __init numa_policy_init(void)
 
 	if (do_set_mempolicy(MPOL_INTERLEAVE, 0, &interleave_nodes))
 		printk("numa_policy_init: interleaving failed\n");
+
+	check_balancenuma_enable();
 }
 
 /* Reset policy of current process to default */
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
