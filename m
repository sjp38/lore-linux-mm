Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 6EC596B13F2
	for <linux-mm@kvack.org>; Sun,  5 Feb 2012 08:49:32 -0500 (EST)
Received: by eekc13 with SMTP id c13so2082484eek.14
        for <linux-mm@kvack.org>; Sun, 05 Feb 2012 05:49:30 -0800 (PST)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v8 4/8] smp: add func to IPI cpus based on parameter func
Date: Sun,  5 Feb 2012 15:48:38 +0200
Message-Id: <1328449722-15959-3-git-send-email-gilad@benyossef.com>
In-Reply-To: <1328448800-15794-1-git-send-email-gilad@benyossef.com>
References: <1328448800-15794-1-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Chris Metcalf <cmetcalf@tilera.com>, Christoph Lameter <cl@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Milton Miller <miltonm@bga.com>

Add the on_each_cpu_cond() function that wraps on_each_cpu_mask()
and calculates the cpumask of cpus to IPI by calling a function supplied
as a parameter in order to determine whether to IPI each specific cpu.

The function works around allocation failure of cpumask variable in
CONFIG_CPUMASK_OFFSTACK=y by itereating over cpus sending an IPI a
time via smp_call_function_single().

The function is useful since it allows to seperate the specific
code that decided in each case whether to IPI a specific cpu for
a specific request from the common boilerplate code of handling
creating the mask, handling failures etc.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Chris Metcalf <cmetcalf@tilera.com>
CC: Christoph Lameter <cl@linux-foundation.org>
CC: Frederic Weisbecker <fweisbec@gmail.com>
CC: Russell King <linux@arm.linux.org.uk>
CC: linux-mm@kvack.org
CC: Pekka Enberg <penberg@kernel.org>
CC: Matt Mackall <mpm@selenic.com>
CC: Sasha Levin <levinsasha928@gmail.com>
CC: Rik van Riel <riel@redhat.com>
CC: Andi Kleen <andi@firstfloor.org>
CC: Alexander Viro <viro@zeniv.linux.org.uk>
CC: linux-fsdevel@vger.kernel.org
CC: Avi Kivity <avi@redhat.com>
CC: Michal Nazarewicz <mina86@mina86.com>
CC: Kosaki Motohiro <kosaki.motohiro@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Milton Miller <miltonm@bga.com>
---
 include/linux/smp.h |   24 ++++++++++++++++++++
 kernel/smp.c        |   60 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 84 insertions(+), 0 deletions(-)

diff --git a/include/linux/smp.h b/include/linux/smp.h
index d0adb78..da4d034 100644
--- a/include/linux/smp.h
+++ b/include/linux/smp.h
@@ -109,6 +109,15 @@ void on_each_cpu_mask(const struct cpumask *mask, smp_call_func_t func,
 		void *info, bool wait);
 
 /*
+ * Call a function on each processor for which the supplied function
+ * cond_func returns a positive value. This may include the local
+ * processor.
+ */
+void on_each_cpu_cond(bool (*cond_func)(int cpu, void *info),
+		smp_call_func_t func, void *info, bool wait,
+		gfp_t gfp_flags);
+
+/*
  * Mark the boot cpu "online" so that it can call console drivers in
  * printk() and can access its per-cpu storage.
  */
@@ -153,6 +162,21 @@ static inline int up_smp_call_function(smp_call_func_t func, void *info)
 			local_irq_enable();		\
 		}					\
 	} while (0)
+/*
+ * Preemption is disabled here to make sure the
+ * cond_func is called under the same condtions in UP
+ * and SMP.
+ */
+#define on_each_cpu_cond(cond_func, func, info, wait, gfp_flags) \
+	do {						\
+		preempt_disable();			\
+		if (cond_func(0, info)) {		\
+			local_irq_disable();		\
+			(func)(info);			\
+			local_irq_enable();		\
+		}					\
+		preempt_enable();			\
+	} while (0)
 
 static inline void smp_send_reschedule(int cpu) { }
 #define num_booting_cpus()			1
diff --git a/kernel/smp.c b/kernel/smp.c
index a081e6c..28cbcc5 100644
--- a/kernel/smp.c
+++ b/kernel/smp.c
@@ -730,3 +730,63 @@ void on_each_cpu_mask(const struct cpumask *mask, smp_call_func_t func,
 	put_cpu();
 }
 EXPORT_SYMBOL(on_each_cpu_mask);
+
+/*
+ * on_each_cpu_cond(): Call a function on each processor for which
+ * the supplied function cond_func returns true, optionally waiting
+ * for all the required CPUs to finish. This may include the local
+ * processor.
+ * @cond_func:	A callback function that is passed a cpu id and
+ *		the the info parameter. The function is called
+ *		with preemption disabled. The function should
+ *		return a blooean value indicating whether to IPI
+ *		the specified CPU.
+ * @func:	The function to run on all applicable CPUs.
+ *		This must be fast and non-blocking.
+ * @info:	An arbitrary pointer to pass to both functions.
+ * @wait:	If true, wait (atomically) until function has
+ *		completed on other CPUs.
+ * @gfp_flags:	GFP flags to use when allocating the cpumask
+ *		used internally by the function.
+ *
+ * The function might sleep if the GFP flags indicates a non
+ * atomic allocation is allowed.
+ *
+ * Preemption is disabled to protect against a hotplug event.
+ *
+ * You must not call this function with disabled interrupts or
+ * from a hardware interrupt handler or from a bottom half handler.
+ */
+void on_each_cpu_cond(bool (*cond_func)(int cpu, void *info),
+			smp_call_func_t func, void *info, bool wait,
+			gfp_t gfp_flags)
+{
+	cpumask_var_t cpus;
+	int cpu, ret;
+
+	might_sleep_if(gfp_flags & __GFP_WAIT);
+
+	if (likely(zalloc_cpumask_var(&cpus, (gfp_flags|__GFP_NOWARN)))) {
+		preempt_disable();
+		for_each_online_cpu(cpu)
+			if (cond_func(cpu, info))
+				cpumask_set_cpu(cpu, cpus);
+		on_each_cpu_mask(cpus, func, info, wait);
+		preempt_enable();
+		free_cpumask_var(cpus);
+	} else {
+		/*
+		 * No free cpumask, bother. No matter, we'll
+		 * just have to IPI them one by one.
+		 */
+		preempt_disable();
+		for_each_online_cpu(cpu)
+			if (cond_func(cpu, info)) {
+				ret = smp_call_function_single(cpu, func,
+								info, wait);
+				WARN_ON_ONCE(!ret);
+			}
+		preempt_enable();
+	}
+}
+EXPORT_SYMBOL(on_each_cpu_cond);
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
