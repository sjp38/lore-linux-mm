Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 7FE226B0034
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 16:03:02 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id k10so1029628wiv.11
        for <linux-mm@kvack.org>; Wed, 19 Jun 2013 13:03:00 -0700 (PDT)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v2 2/2] mm: add sysctl to pick vmstat monitor cpu
Date: Wed, 19 Jun 2013 23:02:48 +0300
Message-Id: <1371672168-9869-2-git-send-email-gilad@benyossef.com>
In-Reply-To: <CAOtvUMc5w3zNe8ed6qX0OOM__3F_hOTqvFa1AkdXF0PHvzGZqg@mail.gmail.com>
References: <CAOtvUMc5w3zNe8ed6qX0OOM__3F_hOTqvFa1AkdXF0PHvzGZqg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Add a sysctl knob to enable admin to hand pick the scapegoat cpu
that will perform the extra work of preiodically checking for
new VM activity on CPUs that have switched off their vmstat_update
work item schedling.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
CC: Christoph Lameter <cl@linux.com>
CC: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
CC: linux-kernel@vger.kernel.org
CC: linux-mm@kvack.org

---
 include/linux/vmstat.h |    1 +
 kernel/sysctl.c        |    7 ++++
 mm/vmstat.c            |   72 ++++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 74 insertions(+), 6 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index a30ab79..470f1d0 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -9,6 +9,7 @@
 #include <linux/atomic.h>
 
 extern int sysctl_stat_interval;
+extern int sysctl_vmstat_monitor_cpu;
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
 /*
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 9edcf45..58c889e 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1361,6 +1361,13 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
+	{
+		.procname	= "stat_monitor_cpu",
+		.data		= &sysctl_vmstat_monitor_cpu,
+		.maxlen		= sizeof(sysctl_vmstat_monitor_cpu),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 #endif
 #ifdef CONFIG_MMU
 	{
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 6143c70..767412e 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1187,7 +1187,7 @@ static const struct file_operations proc_vmstat_file_operations = {
 static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
 int sysctl_stat_interval __read_mostly = HZ;
 static struct cpumask vmstat_cpus;
-static int vmstat_monitor_cpu __read_mostly = VMSTAT_NO_CPU;
+int sysctl_vmstat_monitor_cpu __read_mostly = VMSTAT_NO_CPU;
 
 static inline bool need_vmstat(int cpu)
 {
@@ -1232,12 +1232,13 @@ static void vmstat_update(struct work_struct *w)
 {
 	int cpu, this_cpu = smp_processor_id();
 
-	if (unlikely(this_cpu == vmstat_monitor_cpu))
+	if (unlikely(this_cpu == sysctl_vmstat_monitor_cpu))
 		for_each_cpu_not(cpu, &vmstat_cpus)
 			if (need_vmstat(cpu))
 				start_cpu_timer(cpu);
 
-	if (likely(refresh_cpu_vm_stats(this_cpu) || (this_cpu == vmstat_monitor_cpu)))
+	if (likely(refresh_cpu_vm_stats(this_cpu) ||
+		(this_cpu == sysctl_vmstat_monitor_cpu)))
 		schedule_delayed_work(&__get_cpu_var(vmstat_work),
 				round_jiffies_relative(sysctl_stat_interval));
 	else
@@ -1266,9 +1267,9 @@ static int __cpuinit vmstat_cpuup_callback(struct notifier_block *nfb,
 		if (cpumask_test_cpu(cpu, &vmstat_cpus)) {
 			cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
 			per_cpu(vmstat_work, cpu).work.func = NULL;
-			if(cpu == vmstat_monitor_cpu) {
+			if (cpu == sysctl_vmstat_monitor_cpu) {
 				int this_cpu = smp_processor_id();
-				vmstat_monitor_cpu = this_cpu;
+				sysctl_vmstat_monitor_cpu = this_cpu;
 				if (!cpumask_test_cpu(this_cpu, &vmstat_cpus))
 					start_cpu_timer(this_cpu);
 			}
@@ -1299,7 +1300,7 @@ static int __init setup_vmstat(void)
 
 	register_cpu_notifier(&vmstat_notifier);
 
-	vmstat_monitor_cpu = smp_processor_id();
+	sysctl_vmstat_monitor_cpu = smp_processor_id();
 
 	for_each_online_cpu(cpu)
 		setup_cpu_timer(cpu);
@@ -1474,5 +1475,64 @@ fail:
 	return -ENOMEM;
 }
 
+#ifdef CONFIG_SYSCTL
+/*
+ * proc handler for /proc/sys/mm/stat_monitor_cpu
+ *
+ * Note that there is a harmless race condition here:
+ * If you concurrently try to change the monitor CPU to
+ * a new valid one and an invalid (offline) one at the
+ * same time, you can get a success indication for the
+ * valid one, a failure for the invalid one, but end up
+ * with the old value. It's easily fixable but hardly
+ * worth the added complexity.
+ */
+
+int proc_monitor_cpu(struct ctl_table *table, int write,
+			void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int ret;
+	int tmp;
+
+	/*
+	 * We need to make sure the chosen and old monitor cpus don't
+	 * go offline on us during the transition.
+	 */
+	get_online_cpus();
+
+	tmp = sysctl_vmstat_monitor_cpu;
+
+	ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
+
+	if (ret || !write)
+		goto out;
+
+	/*
+	 * An offline CPU is a bad choice for monitoring duty.
+	 * Abort.
+	 */
+	if (!cpu_online(sysctl_vmstat_monitor_cpu)) {
+		sysctl_vmstat_monitor_cpu = tmp;
+		ret = -ERANGE;
+		/*
+		 * Note! we fall through here on purpose, since
+		 * the old CPU monitor might have switched off
+		 * its vmstat_update by this time.
+		 */
+	}
+
+	/*
+	 * If the new monitor cpu had the vmstat_update off,
+	 * bring it back on.
+	 */
+	if (!cpumask_test_cpu(sysctl_vmstat_monitor_cpu, &vmstat_cpus))
+		start_cpu_timer(sysctl_vmstat_monitor_cpu);
+
+out:
+	put_online_cpus();
+	return ret;
+}
+#endif /* CONFIG_SYSCTL */
+
 module_init(extfrag_debug_init);
 #endif
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
