Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AD96E9000BD
	for <linux-mm@kvack.org>; Sun, 25 Sep 2011 04:55:57 -0400 (EDT)
Received: by gxk28 with SMTP id 28so700331gxk.14
        for <linux-mm@kvack.org>; Sun, 25 Sep 2011 01:55:55 -0700 (PDT)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH 1/5] smp: Introduce a generic on_each_cpu_mask function
Date: Sun, 25 Sep 2011 11:54:46 +0300
Message-Id: <1316940890-24138-2-git-send-email-gilad@benyossef.com>
In-Reply-To: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

on_each_cpu_mask calls a function on processors specified my cpumask,
which may include the local processor.

All the limitation specified in smp_call_function_many apply.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Frederic Weisbecker <fweisbec@gmail.com>
CC: Russell King <linux@arm.linux.org.uk>
CC: Chris Metcalf <cmetcalf@tilera.com>
CC: linux-mm@kvack.org
CC: Christoph Lameter <cl@linux-foundation.org>
CC: Pekka Enberg <penberg@kernel.org>
CC: Matt Mackall <mpm@selenic.com>
---
 include/linux/smp.h |   14 ++++++++++++++
 kernel/smp.c        |   20 ++++++++++++++++++++
 2 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/include/linux/smp.h b/include/linux/smp.h
index 8cc38d3..02a8377 100644
--- a/include/linux/smp.h
+++ b/include/linux/smp.h
@@ -102,6 +102,13 @@ static inline void call_function_init(void) { }
 int on_each_cpu(smp_call_func_t func, void *info, int wait);
 
 /*
+ * Call a function on processors specified by mask, which might include
+ * the local one.
+ */
+void on_each_cpu_mask(const struct cpumask *mask, void (*func)(void *),
+		void *info, bool wait);
+
+/*
  * Mark the boot cpu "online" so that it can call console drivers in
  * printk() and can access its per-cpu storage.
  */
@@ -132,6 +139,13 @@ static inline int up_smp_call_function(smp_call_func_t func, void *info)
 		local_irq_enable();		\
 		0;				\
 	})
+#define on_each_cpu_mask(mask, func, info, wait) \
+	if (cpumask_test_cpu(0, (mask))) {	\
+		local_irq_disable();		\
+		func(info);			\
+		local_irq_enable();		\
+	}
+
 static inline void smp_send_reschedule(int cpu) { }
 #define num_booting_cpus()			1
 #define smp_prepare_boot_cpu()			do {} while (0)
diff --git a/kernel/smp.c b/kernel/smp.c
index fb67dfa..df37c08 100644
--- a/kernel/smp.c
+++ b/kernel/smp.c
@@ -701,3 +701,23 @@ int on_each_cpu(void (*func) (void *info), void *info, int wait)
 	return ret;
 }
 EXPORT_SYMBOL(on_each_cpu);
+
+/*
+ * Call a function on processors specified by cpumask, which may include
+ * the local processor. All the limitation specified in smp_call_function_many
+ * apply.
+ */
+void on_each_cpu_mask(const struct cpumask *mask, void (*func)(void *),
+			void *info, bool wait)
+{
+	int cpu = get_cpu();
+
+	smp_call_function_many(mask, func, info, wait);
+	if (cpumask_test_cpu(cpu, mask)) {
+		local_irq_disable();
+		func(info);
+		local_irq_enable();
+	}
+	put_cpu();
+}
+EXPORT_SYMBOL(on_each_cpu_mask);
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
