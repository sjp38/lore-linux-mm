Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id A69196B0035
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 19:09:20 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id up15so19313918pbc.10
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 16:09:20 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id l8si56428588pao.152.2014.01.06.16.09.18
        for <linux-mm@kvack.org>;
        Mon, 06 Jan 2014 16:09:19 -0800 (PST)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] Add a sysctl for numa_balancing v2
Date: Mon,  6 Jan 2014 16:08:46 -0800
Message-Id: <1389053326-29462-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

From: Andi Kleen <ak@linux.intel.com>

[It turns out the documentation patch was already merged
earlier. So just resending without documentation.]

As discussed earlier, this adds a working sysctl to enable/disable
automatic numa memory balancing at runtime.

This allows to track down performance problems with this
feature and is generally a good idea.

This was possible earlier through debugfs, but only with special
debugging options set. Also fix the boot message.

v2: Remove documentation as the documentation for this
sysctl was already merged earlier.
Acked-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 include/linux/sched/sysctl.h |  4 ++++
 kernel/sched/core.c          | 24 +++++++++++++++++++++++-
 kernel/sysctl.c              |  9 +++++++++
 mm/mempolicy.c               |  2 +-
 4 files changed, 37 insertions(+), 2 deletions(-)

diff --git a/include/linux/sched/sysctl.h b/include/linux/sched/sysctl.h
index 41467f8..e134535 100644
--- a/include/linux/sched/sysctl.h
+++ b/include/linux/sched/sysctl.h
@@ -100,4 +100,8 @@ extern int sched_rt_handler(struct ctl_table *table, int write,
 		void __user *buffer, size_t *lenp,
 		loff_t *ppos);
 
+extern int sched_numa_balancing(struct ctl_table *table, int write,
+				 void __user *buffer, size_t *lenp,
+				 loff_t *ppos);
+
 #endif /* _SCHED_SYSCTL_H */
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index a88f4a4..4dc22da 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1763,7 +1763,29 @@ void set_numabalancing_state(bool enabled)
 	numabalancing_enabled = enabled;
 }
 #endif /* CONFIG_SCHED_DEBUG */
-#endif /* CONFIG_NUMA_BALANCING */
+
+#ifdef CONFIG_PROC_SYSCTL
+int sched_numa_balancing(struct ctl_table *table, int write,
+			 void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	struct ctl_table t;
+	int err;
+	int state = numabalancing_enabled;
+
+	if (write && !capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	t = *table;
+	t.data = &state;
+	err = proc_dointvec_minmax(&t, write, buffer, lenp, ppos);
+	if (err < 0)
+		return err;
+	if (write)
+		set_numabalancing_state(state);
+	return err;
+}
+#endif
+#endif
 
 /*
  * fork()/clone()-time setup:
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 34a6047..9e0e790 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -398,6 +398,15 @@ static struct ctl_table kern_table[] = {
 		.mode           = 0644,
 		.proc_handler   = proc_dointvec,
 	},
+	{
+		.procname	= "numa_balancing",
+		.data		= NULL, /* filled in by handler */
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= sched_numa_balancing,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
 #endif /* CONFIG_NUMA_BALANCING */
 #endif /* CONFIG_SCHED_DEBUG */
 	{
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 0cd2c4d..947293e 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2668,7 +2668,7 @@ static void __init check_numabalancing_enable(void)
 
 	if (nr_node_ids > 1 && !numabalancing_override) {
 		printk(KERN_INFO "Enabling automatic NUMA balancing. "
-			"Configure with numa_balancing= or sysctl");
+			"Configure with numa_balancing= or the kernel.numa_balancing sysctl");
 		set_numabalancing_state(numabalancing_default);
 	}
 }
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
