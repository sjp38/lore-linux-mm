Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CE0BC6B006C
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 06:09:40 -0500 (EST)
Received: by mail-ey0-f169.google.com with SMTP id 4so42549eye.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 03:09:39 -0800 (PST)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v4 1/5] smp: Introduce a generic on_each_cpu_mask function
Date: Tue, 22 Nov 2011 13:08:44 +0200
Message-Id: <1321960128-15191-2-git-send-email-gilad@benyossef.com>
In-Reply-To: <1321960128-15191-1-git-send-email-gilad@benyossef.com>
References: <1321960128-15191-1-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Sasha Levin <levinsasha928@gmail.com>

on_each_cpu_mask calls a function on processors specified my cpumask, which may include the local processor.

All the limitation specified in smp_call_function_many apply.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
Reviewed-by: Christoph Lameter <cl@linux.com>
CC: Chris Metcalf <cmetcalf@tilera.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Frederic Weisbecker <fweisbec@gmail.com>
CC: Russell King <linux@arm.linux.org.uk>
CC: linux-mm@kvack.org
CC: Pekka Enberg <penberg@kernel.org>
CC: Matt Mackall <mpm@selenic.com>
CC: Rik van Riel <riel@redhat.com>
CC: Andi Kleen <andi@firstfloor.org>
CC: Sasha Levin <levinsasha928@gmail.com>
---
 include/linux/smp.h |   16 ++++++++++++++++
 kernel/smp.c        |   20 ++++++++++++++++++++
 2 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/include/linux/smp.h b/include/linux/smp.h
index 8cc38d3..60628d7 100644
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
@@ -132,6 +139,15 @@ static inline int up_smp_call_function(smp_call_func_t func, void *info)
 		local_irq_enable();		\
 		0;				\
 	})
+#define on_each_cpu_mask(mask, func, info, wait) \
+	do {						\
+		if (cpumask_test_cpu(0, (mask))) {	\
+			local_irq_disable();		\
+			(func)(info);			\
+			local_irq_enable();		\
+		}					\
+	} while (0)
+
 static inline void smp_send_reschedule(int cpu) { }
 #define num_booting_cpus()			1
 #define smp_prepare_boot_cpu()			do {} while (0)
diff --git a/kernel/smp.c b/kernel/smp.c
index db197d6..7c0cbd7 100644
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
