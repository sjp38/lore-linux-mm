Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 2FD246B005D
	for <linux-mm@kvack.org>; Mon,  2 Jan 2012 05:25:23 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id c41so17353876eek.14
        for <linux-mm@kvack.org>; Mon, 02 Jan 2012 02:25:22 -0800 (PST)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v5 4/8] smp: Add func to IPI cpus based on parameter func
Date: Mon,  2 Jan 2012 12:24:15 +0200
Message-Id: <1325499859-2262-5-git-send-email-gilad@benyossef.com>
In-Reply-To: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Chris Metcalf <cmetcalf@tilera.com>, Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

Add the on_each_cpu_required() function that wraps on_each_cpu_mask()
and calculates the cpumask of cpus to IPI by calling a function supplied
as a parameter in order to determine whether to IPI each specific cpu.

The function deals with allocation failure of cpumask variable in
CONFIG_CPUMASK_OFFSTACK=y by sending IPI to all cpus via on_each_cpu()
instead.

The function is useful since it allows to seperate the specific
code that decided in each case whether to IPI a specific cpu for
a specific request from the common boilerplate code of handling
creating the mask, handling failures etc.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
CC: Chris Metcalf <cmetcalf@tilera.com>
CC: Christoph Lameter <cl@linux-foundation.org>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
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
---
 include/linux/smp.h |   16 ++++++++++++++++
 kernel/smp.c        |   27 +++++++++++++++++++++++++++
 2 files changed, 43 insertions(+), 0 deletions(-)

diff --git a/include/linux/smp.h b/include/linux/smp.h
index 60628d7..ef85a3d 100644
--- a/include/linux/smp.h
+++ b/include/linux/smp.h
@@ -109,6 +109,14 @@ void on_each_cpu_mask(const struct cpumask *mask, void (*func)(void *),
 		void *info, bool wait);
 
 /*
+ * Call a function on each processor for which the supplied function
+ * cond_func returns a positive value. This may include the local
+ * processor.
+ */
+void on_each_cpu_cond(int (*cond_func) (int cpu, void *info),
+		void (*func)(void *), void *info, bool wait);
+
+/*
  * Mark the boot cpu "online" so that it can call console drivers in
  * printk() and can access its per-cpu storage.
  */
@@ -147,6 +155,14 @@ static inline int up_smp_call_function(smp_call_func_t func, void *info)
 			local_irq_enable();		\
 		}					\
 	} while (0)
+#define on_each_cpu_cond(cond_func, func, info, wait) \
+	do {						\
+		if (cond_func(0, info)) {		\
+			local_irq_disable();		\
+			(func)(info);			\
+			local_irq_enable();		\
+		}					\
+	} while (0)
 
 static inline void smp_send_reschedule(int cpu) { }
 #define num_booting_cpus()			1
diff --git a/kernel/smp.c b/kernel/smp.c
index 7c0cbd7..5f7b24e 100644
--- a/kernel/smp.c
+++ b/kernel/smp.c
@@ -721,3 +721,30 @@ void on_each_cpu_mask(const struct cpumask *mask, void (*func)(void *),
 	put_cpu();
 }
 EXPORT_SYMBOL(on_each_cpu_mask);
+
+/*
+ * Call a function on each processor for which the supplied function
+ * cond_func returns a positive value. This may include the local
+ * processor, optionally waiting for all the required CPUs to finish.
+ * The function may be called on all online CPUs without running the
+ * cond_func function in extreme circumstance (memory allocation
+ * failure condition when CONFIG_CPUMASK_OFFSTACK=y)
+ * All the limitations specified in smp_call_function_many apply.
+ */
+void on_each_cpu_cond(int (*cond_func) (int cpu, void *info),
+			void (*func)(void *), void *info, bool wait)
+{
+	cpumask_var_t cpus;
+	int cpu;
+
+	if (likely(zalloc_cpumask_var(&cpus, GFP_ATOMIC))) {
+		for_each_online_cpu(cpu)
+			if (cond_func(cpu, info))
+				cpumask_set_cpu(cpu, cpus);
+		on_each_cpu_mask(cpus, func, info, wait);
+		free_cpumask_var(cpus);
+	} else
+		on_each_cpu(func, info, wait);
+}
+EXPORT_SYMBOL(on_each_cpu_cond);
+
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
