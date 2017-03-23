Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7FB9F6B0038
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 07:48:16 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id o126so390372879pfb.2
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 04:48:16 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00114.outbound.protection.outlook.com. [40.107.0.114])
        by mx.google.com with ESMTPS id p19si5347905pgj.167.2017.03.23.04.48.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 23 Mar 2017 04:48:15 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH v2] kasan: report only the first error by default
Date: Thu, 23 Mar 2017 14:49:16 +0300
Message-ID: <20170323114916.29871-1-aryabinin@virtuozzo.com>
In-Reply-To: <20170322160647.32032-1-aryabinin@virtuozzo.com>
References: <20170322160647.32032-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Konovalov <andreyknvl@google.com>, Mark Rutland <mark.rutland@arm.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

Disable kasan after the first report. There are several reasons for this:
 * Single bug quite often has multiple invalid memory accesses causing
    storm in the dmesg.
 * Write OOB access might corrupt metadata so the next report will print
    bogus alloc/free stacktraces.
 * Reports after the first easily could be not bugs by itself but just side
    effects of the first one.

Given that multiple reports usually only do harm, it makes sense to disable
kasan after the first one. If user wants to see all the reports, the
boot-time parameter kasan_multi_shot must be used.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
Changes since v1:
        - provide kasan_multi_shot boot parameter.

 Documentation/admin-guide/kernel-parameters.txt |  6 ++++++
 lib/test_kasan.c                                | 12 ++++++++++++
 mm/kasan/kasan.h                                |  5 -----
 mm/kasan/report.c                               | 18 ++++++++++++++++++
 4 files changed, 36 insertions(+), 5 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 2906987..f88d60e 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -1726,6 +1726,12 @@
 			kernel and module base offset ASLR (Address Space
 			Layout Randomization).
 
+	kasan_multi_shot
+			[KNL] Enforce KASAN (Kernel Address Sanitizer) to print
+			report on every invalid memory access. Without this
+			parameter KASAN will print report only for the first
+			invalid access.
+
 	keepinitrd	[HW,ARM]
 
 	kernelcore=	[KNL,X86,IA-64,PPC]
diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index 0b1d314..f3acece 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -11,6 +11,7 @@
 
 #define pr_fmt(fmt) "kasan test: %s " fmt, __func__
 
+#include <linux/atomic.h>
 #include <linux/delay.h>
 #include <linux/kernel.h>
 #include <linux/mman.h>
@@ -21,6 +22,8 @@
 #include <linux/uaccess.h>
 #include <linux/module.h>
 
+extern atomic_t kasan_report_count;
+
 /*
  * Note: test functions are marked noinline so that their names appear in
  * reports.
@@ -474,6 +477,9 @@ static noinline void __init use_after_scope_test(void)
 
 static int __init kmalloc_tests_init(void)
 {
+	/* Rise reports limit high enough to see all the following bugs */
+	atomic_add(100, &kasan_report_count);
+
 	kmalloc_oob_right();
 	kmalloc_oob_left();
 	kmalloc_node_oob_right();
@@ -499,6 +505,12 @@ static int __init kmalloc_tests_init(void)
 	ksize_unpoisons_memory();
 	copy_user_test();
 	use_after_scope_test();
+
+	/*
+	 * kasan is unreliable now, disable reports if
+	 * we are in single shot mode
+	 */
+	atomic_sub(100, &kasan_report_count);
 	return -EAGAIN;
 }
 
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 7572917..1229298 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -96,11 +96,6 @@ static inline const void *kasan_shadow_to_mem(const void *shadow_addr)
 		<< KASAN_SHADOW_SCALE_SHIFT);
 }
 
-static inline bool kasan_report_enabled(void)
-{
-	return !current->kasan_depth;
-}
-
 void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip);
 void kasan_report_double_free(struct kmem_cache *cache, void *object,
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 718a10a..5650534 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -13,7 +13,9 @@
  *
  */
 
+#include <linux/atomic.h>
 #include <linux/ftrace.h>
+#include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
 #include <linux/printk.h>
@@ -354,6 +356,22 @@ static void kasan_report_error(struct kasan_access_info *info)
 	kasan_end_report(&flags);
 }
 
+atomic_t kasan_report_count = ATOMIC_INIT(1);
+EXPORT_SYMBOL_GPL(kasan_report_count);
+
+static int __init kasan_set_multi_shot(char *str)
+{
+	atomic_set(&kasan_report_count, 1000000000);
+	return 1;
+}
+__setup("kasan_multi_shot", kasan_set_multi_shot);
+
+static inline bool kasan_report_enabled(void)
+{
+	return !current->kasan_depth &&
+		(atomic_dec_if_positive(&kasan_report_count) >= 0);
+}
+
 void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip)
 {
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
