Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 326816B00F3
	for <linux-mm@kvack.org>; Thu,  3 May 2012 10:57:18 -0400 (EDT)
Received: by wibhr7 with SMTP id hr7so111711wib.8
        for <linux-mm@kvack.org>; Thu, 03 May 2012 07:57:16 -0700 (PDT)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v1 3/6] workqueue: introduce schedule_on_each_cpu_cond
Date: Thu,  3 May 2012 17:55:59 +0300
Message-Id: <1336056962-10465-4-git-send-email-gilad@benyossef.com>
In-Reply-To: <1336056962-10465-1-git-send-email-gilad@benyossef.com>
References: <1336056962-10465-1-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Mike Frysinger <vapier@gentoo.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org

Introduce the schedule_on_each_cpu_cond() function that schedules
a work item on each online CPU for which the supplied condition
function returns true.

This function should be used instead of schedule_on_each_cpu()
when only some of the CPUs have actual work to do and a predicate
function can tell if a certain CPU does or does not have work to do,
thus saving unneeded wakeups and schedules.

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
 kernel/workqueue.c        |   37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
index 20da95a..d7bb104 100644
--- a/include/linux/workqueue.h
+++ b/include/linux/workqueue.h
@@ -385,6 +385,8 @@ extern int schedule_delayed_work_on(int cpu, struct delayed_work *work,
 extern int schedule_on_each_cpu(work_func_t func);
 extern int schedule_on_each_cpu_mask(work_func_t func,
 					const struct cpumask *mask);
+extern int schedule_on_each_cpu_cond(work_func_t func,
+					bool (*cond_func)(int cpu));
 extern int keventd_up(void);
 
 int execute_in_process_context(work_func_t fn, struct execute_work *);
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 1c9782b..3322d30 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -2828,6 +2828,43 @@ int schedule_on_each_cpu_mask(work_func_t func, const struct cpumask *mask)
 }
 
 /**
+ * schedule_on_each_cpu_cond - execute a function synchronously on each
+ * online CPU for which the supplied condition function returns true
+ * @func: the function to run on the selected CPUs
+ * @cond_func: the function to call to select the CPUs
+ *
+ * schedule_on_each_cpu_cond() executes @func on each online CPU for
+ * @cond_func returns true using the system workqueue and blocks until
+ * all CPUs have completed.
+ * schedule_on_each_cpu_cond() is very slow.
+ *
+ * RETURNS:
+ * 0 on success, -errno on failure.
+ */
+int schedule_on_each_cpu_cond(work_func_t func, bool (*cond_func)(int cpu))
+{
+	int cpu, ret;
+	cpumask_var_t mask;
+
+	if (unlikely(!zalloc_cpumask_var(&mask, GFP_KERNEL)))
+		return -ENOMEM;
+
+	get_online_cpus();
+
+	for_each_online_cpu(cpu)
+		if (cond_func(cpu))
+			cpumask_set_cpu(cpu, mask);
+
+	ret = schedule_on_each_cpu_mask(func, mask);
+
+	put_online_cpus();
+
+	free_cpumask_var(mask);
+
+	return ret;
+}
+
+/**
  * schedule_on_each_cpu - execute a function synchronously on each online CPU
  * @func: the function to call
  *
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
