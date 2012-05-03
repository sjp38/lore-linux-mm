Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 872DB6B00F1
	for <linux-mm@kvack.org>; Thu,  3 May 2012 10:57:14 -0400 (EDT)
Received: by wibhn6 with SMTP id hn6so398604wib.8
        for <linux-mm@kvack.org>; Thu, 03 May 2012 07:57:12 -0700 (PDT)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v1 2/6] workqueue: introduce schedule_on_each_cpu_mask
Date: Thu,  3 May 2012 17:55:58 +0300
Message-Id: <1336056962-10465-3-git-send-email-gilad@benyossef.com>
In-Reply-To: <1336056962-10465-1-git-send-email-gilad@benyossef.com>
References: <1336056962-10465-1-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Mike Frysinger <vapier@gentoo.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org

Introduce schedule_on_each_cpu_mask function to schedule a work
item on each online CPU which is included in the mask provided.

Then re-implement schedule_on_each_cpu on top of the new function.

This function should be prefered to schedule_on_each_cpu in
any case where some of the CPUs, especially on a big multi-core
system, might not have actual work to perform in order to save
needless wakeups and schedules.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: Tejun Heo <tj@kernel.org>
CC: John Stultz <johnstul@us.ibm.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Mel Gorman <mel@csn.ul.ie>
CC: Mike Frysinger <vapier@gentoo.org>
CC: David Rientjes <rientjes@google.com>
CC: Hugh Dickins <hughd@google.com>
CC: Minchan Kim <minchan.kim@gmail.com>
CC: Konstantin Khlebnikov <khlebnikov@openvz.org>
CC: Christoph Lameter <cl@linux.com>
CC: Chris Metcalf <cmetcalf@tilera.com>
CC: Hakan Akkan <hakanakkan@gmail.com>
CC: Max Krasnyansky <maxk@qualcomm.com>
CC: Frederic Weisbecker <fweisbec@gmail.com>
CC: linux-kernel@vger.kernel.org
CC: linux-mm@kvack.org
---
 include/linux/workqueue.h |    2 ++
 kernel/workqueue.c        |   36 ++++++++++++++++++++++++++++--------
 2 files changed, 30 insertions(+), 8 deletions(-)

diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
index af15545..20da95a 100644
--- a/include/linux/workqueue.h
+++ b/include/linux/workqueue.h
@@ -383,6 +383,8 @@ extern int schedule_delayed_work(struct delayed_work *work, unsigned long delay)
 extern int schedule_delayed_work_on(int cpu, struct delayed_work *work,
 					unsigned long delay);
 extern int schedule_on_each_cpu(work_func_t func);
+extern int schedule_on_each_cpu_mask(work_func_t func,
+					const struct cpumask *mask);
 extern int keventd_up(void);
 
 int execute_in_process_context(work_func_t fn, struct execute_work *);
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 5abf42f..1c9782b 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -2787,43 +2787,63 @@ int schedule_delayed_work_on(int cpu,
 EXPORT_SYMBOL(schedule_delayed_work_on);
 
 /**
- * schedule_on_each_cpu - execute a function synchronously on each online CPU
+ * schedule_on_each_cpu_mask - execute a function synchronously on each
+ * online CPU which is specified in the supplied cpumask
  * @func: the function to call
+ * @mask: the cpu mask
  *
- * schedule_on_each_cpu() executes @func on each online CPU using the
- * system workqueue and blocks until all CPUs have completed.
- * schedule_on_each_cpu() is very slow.
+ * schedule_on_each_cpu_mask() executes @func on each online CPU which
+ * is part of the @mask using the * system workqueue and blocks until
+ * all CPUs have completed
+ * schedule_on_each_cpu_mask() is very slow.
  *
  * RETURNS:
  * 0 on success, -errno on failure.
  */
-int schedule_on_each_cpu(work_func_t func)
+int schedule_on_each_cpu_mask(work_func_t func, const struct cpumask *mask)
 {
 	int cpu;
 	struct work_struct __percpu *works;
 
 	works = alloc_percpu(struct work_struct);
-	if (!works)
+	if (unlikely(!works))
 		return -ENOMEM;
 
 	get_online_cpus();
 
-	for_each_online_cpu(cpu) {
+	for_each_cpu_and(cpu, mask, cpu_online_mask) {
 		struct work_struct *work = per_cpu_ptr(works, cpu);
 
 		INIT_WORK(work, func);
 		schedule_work_on(cpu, work);
 	}
 
-	for_each_online_cpu(cpu)
+	for_each_cpu_and(cpu, mask, cpu_online_mask)
 		flush_work(per_cpu_ptr(works, cpu));
 
 	put_online_cpus();
 	free_percpu(works);
+
 	return 0;
 }
 
 /**
+ * schedule_on_each_cpu - execute a function synchronously on each online CPU
+ * @func: the function to call
+ *
+ * schedule_on_each_cpu() executes @func on each online CPU using the
+ * system workqueue and blocks until all CPUs have completed.
+ * schedule_on_each_cpu() is very slow.
+ *
+ * RETURNS:
+ * 0 on success, -errno on failure.
+ */
+int schedule_on_each_cpu(work_func_t func)
+{
+	return schedule_on_each_cpu_mask(func, cpu_online_mask);
+}
+
+/**
  * flush_scheduled_work - ensure that any scheduled work has run to completion.
  *
  * Forces execution of the kernel-global workqueue and blocks until its
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
