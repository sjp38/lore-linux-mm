Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1ED0D6B0038
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 11:44:37 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n11so227172461pfg.7
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 08:44:37 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0092.outbound.protection.outlook.com. [104.47.2.92])
        by mx.google.com with ESMTPS id p6si6028409pgd.368.2017.03.23.08.44.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 23 Mar 2017 08:44:36 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH v3] kasan: report only the first error by default
Date: Thu, 23 Mar 2017 18:44:16 +0300
Message-ID: <20170323154416.30257-1-aryabinin@virtuozzo.com>
In-Reply-To: <20170322160647.32032-1-aryabinin@virtuozzo.com>
References: <20170322160647.32032-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Konovalov <andreyknvl@google.com>, Mark Rutland <mark.rutland@arm.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

From: Mark Rutland <mark.rutland@arm.com>

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

Signed-off-by: Mark Rutland <mark.rutland@arm.com>
[ aryabinin: wrote changelog and doc, added missing include ]
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
Changes since v2:
        - Instead of using atomic report counter, use separate flags to determine
           whether we're in multi-shot mode, and whether a (oneshot) report
           has been made.
Changes since v1:
        - provide kasan_multi_shot boot parameter.

 Documentation/admin-guide/kernel-parameters.txt |  6 +++++
 include/linux/kasan.h                           |  3 +++
 lib/test_kasan.c                                | 10 +++++++
 mm/kasan/kasan.h                                |  5 ----
 mm/kasan/report.c                               | 36 +++++++++++++++++++++++++
 5 files changed, 55 insertions(+), 5 deletions(-)

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
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 5734480c9..a5c7046 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -76,6 +76,9 @@ size_t ksize(const void *);
 static inline void kasan_unpoison_slab(const void *ptr) { ksize(ptr); }
 size_t kasan_metadata_size(struct kmem_cache *cache);
 
+bool kasan_save_enable_multi_shot(void);
+void kasan_restore_multi_shot(bool enabled);
+
 #else /* CONFIG_KASAN */
 
 static inline void kasan_unpoison_shadow(const void *address, size_t size) {}
diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index 0b1d314..a25c976 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -20,6 +20,7 @@
 #include <linux/string.h>
 #include <linux/uaccess.h>
 #include <linux/module.h>
+#include <linux/kasan.h>
 
 /*
  * Note: test functions are marked noinline so that their names appear in
@@ -474,6 +475,12 @@ static noinline void __init use_after_scope_test(void)
 
 static int __init kmalloc_tests_init(void)
 {
+	/*
+	 * Temporarily enable multi-shot mode. Otherwise, we'd only get a
+	 * report for the first case.
+	 */
+	bool multishot = kasan_save_enable_multi_shot();
+
 	kmalloc_oob_right();
 	kmalloc_oob_left();
 	kmalloc_node_oob_right();
@@ -499,6 +506,9 @@ static int __init kmalloc_tests_init(void)
 	ksize_unpoisons_memory();
 	copy_user_test();
 	use_after_scope_test();
+
+	kasan_restore_multi_shot(multishot);
+
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
index 718a10a..beee0e9 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -13,7 +13,9 @@
  *
  */
 
+#include <linux/bitops.h>
 #include <linux/ftrace.h>
+#include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
 #include <linux/printk.h>
@@ -354,6 +356,40 @@ static void kasan_report_error(struct kasan_access_info *info)
 	kasan_end_report(&flags);
 }
 
+static unsigned long kasan_flags;
+
+#define KASAN_BIT_REPORTED	0
+#define KASAN_BIT_MULTI_SHOT	1
+
+bool kasan_save_enable_multi_shot(void)
+{
+	return test_and_set_bit(KASAN_BIT_MULTI_SHOT, &kasan_flags);
+}
+EXPORT_SYMBOL_GPL(kasan_save_enable_multi_shot);
+
+void kasan_restore_multi_shot(bool enabled)
+{
+	if (!enabled)
+		clear_bit(KASAN_BIT_MULTI_SHOT, &kasan_flags);
+}
+EXPORT_SYMBOL_GPL(kasan_restore_multi_shot);
+
+static int __init kasan_set_multi_shot(char *str)
+{
+	set_bit(KASAN_BIT_MULTI_SHOT, &kasan_flags);
+	return 1;
+}
+__setup("kasan_multi_shot", kasan_set_multi_shot);
+
+static inline bool kasan_report_enabled(void)
+{
+	if (current->kasan_depth)
+		return false;
+	if (test_bit(KASAN_BIT_MULTI_SHOT, &kasan_flags))
+		return true;
+	return !test_and_set_bit(KASAN_BIT_REPORTED, &kasan_flags);
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
