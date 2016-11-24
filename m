Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7AADA6B0038
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 09:38:17 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id a20so15313475wme.5
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 06:38:17 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id xt6si35567016wjc.78.2016.11.24.06.38.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Nov 2016 06:38:16 -0800 (PST)
Received: by mail-wm0-x231.google.com with SMTP id g23so116699227wme.1
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 06:38:16 -0800 (PST)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH v3] kasan: support use-after-scope detection
Date: Thu, 24 Nov 2016 15:38:12 +0100
Message-Id: <1479998292-144502-1-git-send-email-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, glider@google.com, akpm@linux-foundation.org
Cc: stable@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, #@google.com, 4.0+@google.com

Gcc revision 241896 implements use-after-scope detection.
Will be available in gcc 7. Support it in KASAN.

Gcc emits 2 new callbacks to poison/unpoison large stack
objects when they go in/out of scope.
Implement the callbacks and add a test.

Without this patch KASAN is broken with gcc 7.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: aryabinin@virtuozzo.com
Cc: glider@google.com
Cc: akpm@linux-foundation.org
Cc: kasan-dev@googlegroups.com
Cc: arnd@arndb.de
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: stable@vger.kernel.org # 4.0+

---
Changes since v1:
 - added comment to test_kasan.c re noinline
 - fixed a typo in comment: s/go into of scope/go into scope/

Changes since v2:
 - added cc stable

FTR here are reports from the test with gcc 7:

kasan test: use_after_scope_test use-after-scope on int
==================================================================
BUG: KASAN: use-after-scope in use_after_scope_test+0xe0/0x25b [test_kasan] at addr ffff8800359b72b0
Write of size 1 by task insmod/6644
page:ffffea0000d66dc0 count:0 mapcount:0 mapping:          (null) index:0x0
flags: 0x1fffc0000000000()
page dumped because: kasan: bad access detected
CPU: 2 PID: 6644 Comm: insmod Tainted: G    B           4.9.0-rc5+ #39
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffff8800359b71f0 ffffffff834c2999 ffffffff00000002 1ffff10006b36dd1
 ffffed0006b36dc9 0000000041b58ab3 ffffffff89575430 ffffffff834c26ab
 0000000000000000 0000000000000000 0000000000000001 0000000000000000
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff834c2999>] dump_stack+0x2ee/0x3f5 lib/dump_stack.c:51
 [<     inline     >] print_address_description mm/kasan/report.c:207
 [<     inline     >] kasan_report_error mm/kasan/report.c:286
 [<ffffffff819f0ec0>] kasan_report+0x490/0x4c0 mm/kasan/report.c:306
 [<ffffffff819f0fac>] __asan_report_store1_noabort+0x1c/0x20 mm/kasan/report.c:334
 [<ffffffffa00102ba>] use_after_scope_test+0xe0/0x25b [test_kasan] lib/test_kasan.c:424
 [<ffffffffa00114b8>] kmalloc_tests_init+0x72/0x79 [test_kasan]
 [<ffffffff8100244b>] do_one_initcall+0xfb/0x3f0 init/main.c:778
 [<ffffffff8184a813>] do_init_module+0x219/0x59c kernel/module.c:3386
 [<ffffffff81658218>] load_module+0x5918/0x8c40 kernel/module.c:3706
 [<ffffffff8165b939>] SYSC_init_module+0x3f9/0x470 kernel/module.c:3776
 [<ffffffff8165bd2e>] SyS_init_module+0xe/0x10 kernel/module.c:3759
 [<ffffffff88143885>] entry_SYSCALL_64_fastpath+0x23/0xc6 arch/x86/entry/entry_64.S:209
Memory state around the buggy address:
 ffff8800359b7180: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffff8800359b7200: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>ffff8800359b7280: 00 00 f1 f1 f1 f1 f8 f2 f2 f2 f2 f2 f2 f2 00 f2
                                     ^
 ffff8800359b7300: f2 f2 f2 f2 f2 f2 00 00 00 00 00 00 00 00 00 00
 ffff8800359b7380: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
==================================================================
==================================================================
BUG: KASAN: use-after-scope in use_after_scope_test+0x118/0x25b [test_kasan] at addr ffff8800359b72b3
Write of size 1 by task insmod/6644
page:ffffea0000d66dc0 count:0 mapcount:0 mapping:          (null) index:0x0
flags: 0x1fffc0000000000()
page dumped because: kasan: bad access detected
CPU: 2 PID: 6644 Comm: insmod Tainted: G    B           4.9.0-rc5+ #39
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffff8800359b71f0 ffffffff834c2999 ffffffff00000002 1ffff10006b36dd1
 ffffed0006b36dc9 0000000041b58ab3 ffffffff89575430 ffffffff834c26ab
 0000000000000000 0000000000000000 0000000000000001 0000000000000000
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff834c2999>] dump_stack+0x2ee/0x3f5 lib/dump_stack.c:51
 [<     inline     >] print_address_description mm/kasan/report.c:207
 [<     inline     >] kasan_report_error mm/kasan/report.c:286
 [<ffffffff819f0ec0>] kasan_report+0x490/0x4c0 mm/kasan/report.c:306
 [<ffffffff819f0fac>] __asan_report_store1_noabort+0x1c/0x20 mm/kasan/report.c:334
 [<ffffffffa00102f2>] use_after_scope_test+0x118/0x25b [test_kasan] lib/test_kasan.c:425
 [<ffffffffa00114b8>] kmalloc_tests_init+0x72/0x79 [test_kasan]
 [<ffffffff8100244b>] do_one_initcall+0xfb/0x3f0 init/main.c:778
 [<ffffffff8184a813>] do_init_module+0x219/0x59c kernel/module.c:3386
 [<ffffffff81658218>] load_module+0x5918/0x8c40 kernel/module.c:3706
 [<ffffffff8165b939>] SYSC_init_module+0x3f9/0x470 kernel/module.c:3776
 [<ffffffff8165bd2e>] SyS_init_module+0xe/0x10 kernel/module.c:3759
 [<ffffffff88143885>] entry_SYSCALL_64_fastpath+0x23/0xc6 arch/x86/entry/entry_64.S:209
Memory state around the buggy address:
 ffff8800359b7180: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffff8800359b7200: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>ffff8800359b7280: 00 00 f1 f1 f1 f1 f8 f2 f2 f2 f2 f2 f2 f2 00 f2
                                     ^
 ffff8800359b7300: f2 f2 f2 f2 f2 f2 00 00 00 00 00 00 00 00 00 00
 ffff8800359b7380: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
==================================================================
kasan test: use_after_scope_test use-after-scope on array
==================================================================
BUG: KASAN: use-after-scope in use_after_scope_test+0x1ee/0x25b [test_kasan] at addr ffff8800359b7330
Write of size 1 by task insmod/6644
page:ffffea0000d66dc0 count:0 mapcount:0 mapping:          (null) index:0x0
flags: 0x1fffc0000000000()
page dumped because: kasan: bad access detected
CPU: 2 PID: 6644 Comm: insmod Tainted: G    B           4.9.0-rc5+ #39
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffff8800359b71f0 ffffffff834c2999 ffffffff00000002 1ffff10006b36dd1
 ffffed0006b36dc9 0000000041b58ab3 ffffffff89575430 ffffffff834c26ab
 0000000000000000 0000000000000000 0000000000000001 0000000000000000
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff834c2999>] dump_stack+0x2ee/0x3f5 lib/dump_stack.c:51
 [<     inline     >] print_address_description mm/kasan/report.c:207
 [<     inline     >] kasan_report_error mm/kasan/report.c:286
 [<ffffffff819f0ec0>] kasan_report+0x490/0x4c0 mm/kasan/report.c:306
 [<ffffffff819f0fac>] __asan_report_store1_noabort+0x1c/0x20 mm/kasan/report.c:334
 [<ffffffffa00103c8>] use_after_scope_test+0x1ee/0x25b [test_kasan] lib/test_kasan.c:433
 [<ffffffffa00114b8>] kmalloc_tests_init+0x72/0x79 [test_kasan]
 [<ffffffff8100244b>] do_one_initcall+0xfb/0x3f0 init/main.c:778
 [<ffffffff8184a813>] do_init_module+0x219/0x59c kernel/module.c:3386
 [<ffffffff81658218>] load_module+0x5918/0x8c40 kernel/module.c:3706
 [<ffffffff8165b939>] SYSC_init_module+0x3f9/0x470 kernel/module.c:3776
 [<ffffffff8165bd2e>] SyS_init_module+0xe/0x10 kernel/module.c:3759
 [<ffffffff88143885>] entry_SYSCALL_64_fastpath+0x23/0xc6 arch/x86/entry/entry_64.S:209
Memory state around the buggy address:
 ffff8800359b7200: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffff8800359b7280: 00 00 f1 f1 f1 f1 f8 f2 f2 f2 f2 f2 f2 f2 00 f2
>ffff8800359b7300: f2 f2 f2 f2 f2 f2 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8
                                     ^
 ffff8800359b7380: f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8
 ffff8800359b7400: f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8
==================================================================
==================================================================
BUG: KASAN: use-after-scope in use_after_scope_test+0x229/0x25b [test_kasan] at addr ffff8800359b772f
Write of size 1 by task insmod/6644
page:ffffea0000d66dc0 count:0 mapcount:0 mapping:          (null) index:0x0
flags: 0x1fffc0000000000()
page dumped because: kasan: bad access detected
CPU: 2 PID: 6644 Comm: insmod Tainted: G    B           4.9.0-rc5+ #39
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffff8800359b71f0 ffffffff834c2999 ffffffff00000002 1ffff10006b36dd1
 ffffed0006b36dc9 0000000041b58ab3 ffffffff89575430 ffffffff834c26ab
 0000000000000000 0000000000000000 0000000000000001 0000000000000000
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff834c2999>] dump_stack+0x2ee/0x3f5 lib/dump_stack.c:51
 [<     inline     >] print_address_description mm/kasan/report.c:207
 [<     inline     >] kasan_report_error mm/kasan/report.c:286
 [<ffffffff819f0ec0>] kasan_report+0x490/0x4c0 mm/kasan/report.c:306
 [<ffffffff819f0fac>] __asan_report_store1_noabort+0x1c/0x20 mm/kasan/report.c:334
 [<ffffffffa0010403>] use_after_scope_test+0x229/0x25b [test_kasan] lib/test_kasan.c:434
 [<ffffffffa00114b8>] kmalloc_tests_init+0x72/0x79 [test_kasan]
 [<ffffffff8100244b>] do_one_initcall+0xfb/0x3f0 init/main.c:778
 [<ffffffff8184a813>] do_init_module+0x219/0x59c kernel/module.c:3386
 [<ffffffff81658218>] load_module+0x5918/0x8c40 kernel/module.c:3706
 [<ffffffff8165b939>] SYSC_init_module+0x3f9/0x470 kernel/module.c:3776
 [<ffffffff8165bd2e>] SyS_init_module+0xe/0x10 kernel/module.c:3759
 [<ffffffff88143885>] entry_SYSCALL_64_fastpath+0x23/0xc6 arch/x86/entry/entry_64.S:209
Memory state around the buggy address:
 ffff8800359b7600: f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8
 ffff8800359b7680: f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8
>ffff8800359b7700: f8 f8 f8 f8 f8 f8 f3 f3 f3 f3 00 00 00 00 00 00
                                  ^
 ffff8800359b7780: 00 00 00 f1 f1 f1 f1 00 f2 f2 f2 f2 f2 f2 f2 00
 ffff8800359b7800: f2 f2 f2 f2 f2 f2 f2 00 f2 f2 f2 f2 f2 f2 f2 00
==================================================================
---
 lib/test_kasan.c  | 29 +++++++++++++++++++++++++++++
 mm/kasan/kasan.c  | 19 +++++++++++++++++++
 mm/kasan/kasan.h  |  1 +
 mm/kasan/report.c |  3 +++
 4 files changed, 52 insertions(+)

diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index 5e51872b..fbdf879 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -20,6 +20,11 @@
 #include <linux/uaccess.h>
 #include <linux/module.h>
 
+/*
+ * Note: test functions are marked noinline so that their names appear in
+ * reports.
+ */
+
 static noinline void __init kmalloc_oob_right(void)
 {
 	char *ptr;
@@ -411,6 +416,29 @@ static noinline void __init copy_user_test(void)
 	kfree(kmem);
 }
 
+static noinline void __init use_after_scope_test(void)
+{
+	volatile char *volatile p;
+
+	pr_info("use-after-scope on int\n");
+	{
+		int local = 0;
+
+		p = (char *)&local;
+	}
+	p[0] = 1;
+	p[3] = 1;
+
+	pr_info("use-after-scope on array\n");
+	{
+		char local[1024] = {0};
+
+		p = local;
+	}
+	p[0] = 1;
+	p[1023] = 1;
+}
+
 static int __init kmalloc_tests_init(void)
 {
 	kmalloc_oob_right();
@@ -436,6 +464,7 @@ static int __init kmalloc_tests_init(void)
 	kasan_global_oob();
 	ksize_unpoisons_memory();
 	copy_user_test();
+	use_after_scope_test();
 	return -EAGAIN;
 }
 
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 70c0097..0e9505f 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -764,6 +764,25 @@ EXPORT_SYMBOL(__asan_storeN_noabort);
 void __asan_handle_no_return(void) {}
 EXPORT_SYMBOL(__asan_handle_no_return);
 
+/* Emitted by compiler to poison large objects when they go out of scope. */
+void __asan_poison_stack_memory(const void *addr, size_t size)
+{
+	/*
+	 * Addr is KASAN_SHADOW_SCALE_SIZE-aligned and the object is surrounded
+	 * by redzones, so we simply round up size to simplify logic.
+	 */
+	kasan_poison_shadow(addr, round_up(size, KASAN_SHADOW_SCALE_SIZE),
+			    KASAN_USE_AFTER_SCOPE);
+}
+EXPORT_SYMBOL(__asan_poison_stack_memory);
+
+/* Emitted by compiler to unpoison large objects when they go into scope. */
+void __asan_unpoison_stack_memory(const void *addr, size_t size)
+{
+	kasan_unpoison_shadow(addr, size);
+}
+EXPORT_SYMBOL(__asan_unpoison_stack_memory);
+
 #ifdef CONFIG_MEMORY_HOTPLUG
 static int kasan_mem_notifier(struct notifier_block *nb,
 			unsigned long action, void *data)
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index e5c2181..46fb5ca 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -21,6 +21,7 @@
 #define KASAN_STACK_MID         0xF2
 #define KASAN_STACK_RIGHT       0xF3
 #define KASAN_STACK_PARTIAL     0xF4
+#define KASAN_USE_AFTER_SCOPE   0xF8
 
 /* Don't break randconfig/all*config builds */
 #ifndef KASAN_ABI_VERSION
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 24c1211..073325a 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -90,6 +90,9 @@ static void print_error_description(struct kasan_access_info *info)
 	case KASAN_KMALLOC_FREE:
 		bug_type = "use-after-free";
 		break;
+	case KASAN_USE_AFTER_SCOPE:
+		bug_type = "use-after-scope";
+		break;
 	}
 
 	pr_err("BUG: KASAN: %s in %pS at addr %p\n",
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
