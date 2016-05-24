Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id B2C726B0263
	for <linux-mm@kvack.org>; Tue, 24 May 2016 14:32:05 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 85so45439302ioq.3
        for <linux-mm@kvack.org>; Tue, 24 May 2016 11:32:05 -0700 (PDT)
Received: from g9t5008.houston.hpe.com (g9t5008.houston.hpe.com. [15.241.48.72])
        by mx.google.com with ESMTPS id k8si2805759otd.60.2016.05.24.11.32.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 11:32:04 -0700 (PDT)
Date: Wed, 25 May 2016 00:01:55 +0530
From: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
Subject: [PATCH v3 2/2] kasan: add double-free tests
Message-ID: <20160524183155.GA4773@cherokee.in.rdlabs.hpecorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dvyukov@google.com, aryabinin@virtuozzo.com, glider@google.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ynorov@caviumnetworks.com, kuthonuzo.luruo@hpe.com

This patch adds new tests for KASAN double-free error detection when the
same slab object is concurrently deallocated.

Signed-off-by: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
---

Changes in v3:
- concurrent double-free test simplified to use on_each_cpu_mask() instead
  of custom threads.
- reduced #threads and removed CONFIG_SMP guards per suggestion from Dmitry
  Vyukov.

---
 lib/test_kasan.c |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index 5e51872..0f589e7 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -411,6 +411,49 @@ static noinline void __init copy_user_test(void)
 	kfree(kmem);
 }
 
+#ifdef CONFIG_SLAB
+static void try_free(void *p)
+{
+	kfree(p);
+}
+
+static void __init kasan_double_free_concurrent(void)
+{
+#define MAX_THREADS 3
+	char *p;
+	int cpu, cnt = num_online_cpus();
+	cpumask_t mask = { CPU_BITS_NONE };
+	size_t size = 4097;     /* must be <= KMALLOC_MAX_CACHE_SIZE/2 */
+
+	if (cnt == 1)
+		return;
+	cnt = cnt < MAX_THREADS ? cnt : MAX_THREADS;
+	pr_info("concurrent double-free (%d threads)\n", cnt);
+	p = kmalloc(size, GFP_KERNEL);
+	if (!p)
+		return;
+	for_each_online_cpu(cpu) {
+		cpumask_set_cpu(cpu, &mask);
+		if (!--cnt)
+			break;
+	}
+	on_each_cpu_mask(&mask, try_free, p, 0);
+}
+
+static noinline void __init kasan_double_free(void)
+{
+	char *p;
+	size_t size = 2049;
+
+	pr_info("double-free\n");
+	p = kmalloc(size, GFP_KERNEL);
+	if (!p)
+		return;
+	kfree(p);
+	kfree(p);
+}
+#endif
+
 static int __init kmalloc_tests_init(void)
 {
 	kmalloc_oob_right();
@@ -436,6 +479,10 @@ static int __init kmalloc_tests_init(void)
 	kasan_global_oob();
 	ksize_unpoisons_memory();
 	copy_user_test();
+#ifdef CONFIG_SLAB
+	kasan_double_free();
+	kasan_double_free_concurrent();
+#endif
 	return -EAGAIN;
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
