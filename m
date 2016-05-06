Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 895316B007E
	for <linux-mm@kvack.org>; Fri,  6 May 2016 07:50:59 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id d62so246110428iof.1
        for <linux-mm@kvack.org>; Fri, 06 May 2016 04:50:59 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id 9si7188581oic.114.2016.05.06.04.50.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 May 2016 04:50:58 -0700 (PDT)
Date: Fri, 6 May 2016 17:20:48 +0530
From: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
Subject: [PATCH v2 2/2] kasan: add kasan_double_free() test
Message-ID: <20160506115048.GA2611@cherokee.in.rdlabs.hpecorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, glider@google.com, dvyukov@google.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kuthonuzo.luruo@hpe.com

This patch adds a new 'test_kasan' test for KASAN double-free error
detection when the same slab object is concurrently deallocated.

Signed-off-by: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
---
Changes in v2:
- This patch is new for v2.
---
 lib/test_kasan.c |   79 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 79 insertions(+), 0 deletions(-)

diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index bd75a03..dec5f74 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -16,6 +16,7 @@
 #include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/module.h>
+#include <linux/kthread.h>
 
 static noinline void __init kmalloc_oob_right(void)
 {
@@ -389,6 +390,83 @@ static noinline void __init ksize_unpoisons_memory(void)
 	kfree(ptr);
 }
 
+#ifdef CONFIG_SLAB
+#ifdef CONFIG_SMP
+static DECLARE_COMPLETION(starting_gun);
+static DECLARE_COMPLETION(finish_line);
+
+static int try_free(void *p)
+{
+	wait_for_completion(&starting_gun);
+	kfree(p);
+	complete(&finish_line);
+	return 0;
+}
+
+/*
+ * allocs an object; then all cpus concurrently attempt to free the
+ * same object.
+ */
+static noinline void __init kasan_double_free(void)
+{
+	char *p;
+	int cpu;
+	struct task_struct **tasks;
+	size_t size = (KMALLOC_MAX_CACHE_SIZE/4 + 1);
+
+	/*
+	 * max slab size instrumented by KASAN is KMALLOC_MAX_CACHE_SIZE/2.
+	 * Do not increase size beyond this: slab corruption from double-free
+	 * may ensue.
+	 */
+	pr_info("concurrent double-free test\n");
+	init_completion(&starting_gun);
+	init_completion(&finish_line);
+	tasks = kzalloc((sizeof(tasks) * nr_cpu_ids), GFP_KERNEL);
+	if (!tasks) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+	p = kmalloc(size, GFP_KERNEL);
+	if (!p) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+
+	for_each_online_cpu(cpu) {
+		tasks[cpu] = kthread_create(try_free, (void *)p, "try_free%d",
+				cpu);
+		if (IS_ERR(tasks[cpu])) {
+			WARN(1, "kthread_create failed.\n");
+			return;
+		}
+		kthread_bind(tasks[cpu], cpu);
+		wake_up_process(tasks[cpu]);
+	}
+
+	complete_all(&starting_gun);
+	for_each_online_cpu(cpu)
+		wait_for_completion(&finish_line);
+	kfree(tasks);
+}
+#else
+static noinline void __init kasan_double_free(void)
+{
+	char *p;
+	size_t size = 2049;
+
+	pr_info("double-free test\n");
+	p = kmalloc(size, GFP_KERNEL);
+	if (!p) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+	kfree(p);
+	kfree(p);
+}
+#endif
+#endif
+
 static int __init kmalloc_tests_init(void)
 {
 	kmalloc_oob_right();
@@ -414,6 +492,7 @@ static int __init kmalloc_tests_init(void)
 	kasan_global_oob();
 #ifdef CONFIG_SLAB
 	kasan_quarantine_cache();
+	kasan_double_free();
 #endif
 	ksize_unpoisons_memory();
 	return -EAGAIN;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
