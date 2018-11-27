Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2F9F16B4953
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 11:56:21 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id b186so16863192wmc.8
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:56:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i74sor3227954wmd.20.2018.11.27.08.56.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Nov 2018 08:56:19 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v12 16/25] kasan: split out generic_report.c from report.c
Date: Tue, 27 Nov 2018 17:55:34 +0100
Message-Id: <9030fe246a786be1348f8b08089f30e52be23ec4.1543337629.git.andreyknvl@google.com>
In-Reply-To: <cover.1543337629.git.andreyknvl@google.com>
References: <cover.1543337629.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>, Andrey Konovalov <andreyknvl@google.com>

This patch moves generic KASAN specific error reporting routines to
generic_report.c without any functional changes, leaving common error
reporting code in report.c to be later reused by tag-based KASAN.

Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Reviewed-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/Makefile         |   4 +-
 mm/kasan/generic_report.c | 158 +++++++++++++++++++++++++
 mm/kasan/kasan.h          |   7 ++
 mm/kasan/report.c         | 234 +++++++++-----------------------------
 mm/kasan/tags_report.c    |  39 +++++++
 5 files changed, 257 insertions(+), 185 deletions(-)
 create mode 100644 mm/kasan/generic_report.c
 create mode 100644 mm/kasan/tags_report.c

diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
index 68ba1822f003..0a14fcff70ed 100644
--- a/mm/kasan/Makefile
+++ b/mm/kasan/Makefile
@@ -14,5 +14,5 @@ CFLAGS_generic.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 CFLAGS_tags.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 
 obj-$(CONFIG_KASAN) := common.o init.o report.o
-obj-$(CONFIG_KASAN_GENERIC) += generic.o quarantine.o
-obj-$(CONFIG_KASAN_SW_TAGS) += tags.o
+obj-$(CONFIG_KASAN_GENERIC) += generic.o generic_report.o quarantine.o
+obj-$(CONFIG_KASAN_SW_TAGS) += tags.o tags_report.o
diff --git a/mm/kasan/generic_report.c b/mm/kasan/generic_report.c
new file mode 100644
index 000000000000..5201d1770700
--- /dev/null
+++ b/mm/kasan/generic_report.c
@@ -0,0 +1,158 @@
+/*
+ * This file contains generic KASAN specific error reporting code.
+ *
+ * Copyright (c) 2014 Samsung Electronics Co., Ltd.
+ * Author: Andrey Ryabinin <ryabinin.a.a@gmail.com>
+ *
+ * Some code borrowed from https://github.com/xairy/kasan-prototype by
+ *        Andrey Konovalov <andreyknvl@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#include <linux/bitops.h>
+#include <linux/ftrace.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/printk.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/stackdepot.h>
+#include <linux/stacktrace.h>
+#include <linux/string.h>
+#include <linux/types.h>
+#include <linux/kasan.h>
+#include <linux/module.h>
+
+#include <asm/sections.h>
+
+#include "kasan.h"
+#include "../slab.h"
+
+static const void *find_first_bad_addr(const void *addr, size_t size)
+{
+	u8 shadow_val = *(u8 *)kasan_mem_to_shadow(addr);
+	const void *first_bad_addr = addr;
+
+	while (!shadow_val && first_bad_addr < addr + size) {
+		first_bad_addr += KASAN_SHADOW_SCALE_SIZE;
+		shadow_val = *(u8 *)kasan_mem_to_shadow(first_bad_addr);
+	}
+	return first_bad_addr;
+}
+
+static const char *get_shadow_bug_type(struct kasan_access_info *info)
+{
+	const char *bug_type = "unknown-crash";
+	u8 *shadow_addr;
+
+	info->first_bad_addr = find_first_bad_addr(info->access_addr,
+						info->access_size);
+
+	shadow_addr = (u8 *)kasan_mem_to_shadow(info->first_bad_addr);
+
+	/*
+	 * If shadow byte value is in [0, KASAN_SHADOW_SCALE_SIZE) we can look
+	 * at the next shadow byte to determine the type of the bad access.
+	 */
+	if (*shadow_addr > 0 && *shadow_addr <= KASAN_SHADOW_SCALE_SIZE - 1)
+		shadow_addr++;
+
+	switch (*shadow_addr) {
+	case 0 ... KASAN_SHADOW_SCALE_SIZE - 1:
+		/*
+		 * In theory it's still possible to see these shadow values
+		 * due to a data race in the kernel code.
+		 */
+		bug_type = "out-of-bounds";
+		break;
+	case KASAN_PAGE_REDZONE:
+	case KASAN_KMALLOC_REDZONE:
+		bug_type = "slab-out-of-bounds";
+		break;
+	case KASAN_GLOBAL_REDZONE:
+		bug_type = "global-out-of-bounds";
+		break;
+	case KASAN_STACK_LEFT:
+	case KASAN_STACK_MID:
+	case KASAN_STACK_RIGHT:
+	case KASAN_STACK_PARTIAL:
+		bug_type = "stack-out-of-bounds";
+		break;
+	case KASAN_FREE_PAGE:
+	case KASAN_KMALLOC_FREE:
+		bug_type = "use-after-free";
+		break;
+	case KASAN_USE_AFTER_SCOPE:
+		bug_type = "use-after-scope";
+		break;
+	case KASAN_ALLOCA_LEFT:
+	case KASAN_ALLOCA_RIGHT:
+		bug_type = "alloca-out-of-bounds";
+		break;
+	}
+
+	return bug_type;
+}
+
+static const char *get_wild_bug_type(struct kasan_access_info *info)
+{
+	const char *bug_type = "unknown-crash";
+
+	if ((unsigned long)info->access_addr < PAGE_SIZE)
+		bug_type = "null-ptr-deref";
+	else if ((unsigned long)info->access_addr < TASK_SIZE)
+		bug_type = "user-memory-access";
+	else
+		bug_type = "wild-memory-access";
+
+	return bug_type;
+}
+
+const char *get_bug_type(struct kasan_access_info *info)
+{
+	if (addr_has_shadow(info->access_addr))
+		return get_shadow_bug_type(info);
+	return get_wild_bug_type(info);
+}
+
+#define DEFINE_ASAN_REPORT_LOAD(size)                     \
+void __asan_report_load##size##_noabort(unsigned long addr) \
+{                                                         \
+	kasan_report(addr, size, false, _RET_IP_);	  \
+}                                                         \
+EXPORT_SYMBOL(__asan_report_load##size##_noabort)
+
+#define DEFINE_ASAN_REPORT_STORE(size)                     \
+void __asan_report_store##size##_noabort(unsigned long addr) \
+{                                                          \
+	kasan_report(addr, size, true, _RET_IP_);	   \
+}                                                          \
+EXPORT_SYMBOL(__asan_report_store##size##_noabort)
+
+DEFINE_ASAN_REPORT_LOAD(1);
+DEFINE_ASAN_REPORT_LOAD(2);
+DEFINE_ASAN_REPORT_LOAD(4);
+DEFINE_ASAN_REPORT_LOAD(8);
+DEFINE_ASAN_REPORT_LOAD(16);
+DEFINE_ASAN_REPORT_STORE(1);
+DEFINE_ASAN_REPORT_STORE(2);
+DEFINE_ASAN_REPORT_STORE(4);
+DEFINE_ASAN_REPORT_STORE(8);
+DEFINE_ASAN_REPORT_STORE(16);
+
+void __asan_report_load_n_noabort(unsigned long addr, size_t size)
+{
+	kasan_report(addr, size, false, _RET_IP_);
+}
+EXPORT_SYMBOL(__asan_report_load_n_noabort);
+
+void __asan_report_store_n_noabort(unsigned long addr, size_t size)
+{
+	kasan_report(addr, size, true, _RET_IP_);
+}
+EXPORT_SYMBOL(__asan_report_store_n_noabort);
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index b080b8d92812..33cc3b0e017e 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -109,11 +109,18 @@ static inline const void *kasan_shadow_to_mem(const void *shadow_addr)
 		<< KASAN_SHADOW_SCALE_SHIFT);
 }
 
+static inline bool addr_has_shadow(const void *addr)
+{
+	return (addr >= kasan_shadow_to_mem((void *)KASAN_SHADOW_START));
+}
+
 void kasan_poison_shadow(const void *address, size_t size, u8 value);
 
 void check_memory_region(unsigned long addr, size_t size, bool write,
 				unsigned long ret_ip);
 
+const char *get_bug_type(struct kasan_access_info *info);
+
 void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip);
 void kasan_report_invalid_free(void *object, unsigned long ip);
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 5c169aa688fd..64a74f334c45 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -1,5 +1,5 @@
 /*
- * This file contains error reporting code.
+ * This file contains common generic and tag-based KASAN error reporting code.
  *
  * Copyright (c) 2014 Samsung Electronics Co., Ltd.
  * Author: Andrey Ryabinin <ryabinin.a.a@gmail.com>
@@ -39,103 +39,34 @@
 #define SHADOW_BYTES_PER_ROW (SHADOW_BLOCKS_PER_ROW * SHADOW_BYTES_PER_BLOCK)
 #define SHADOW_ROWS_AROUND_ADDR 2
 
-static const void *find_first_bad_addr(const void *addr, size_t size)
-{
-	u8 shadow_val = *(u8 *)kasan_mem_to_shadow(addr);
-	const void *first_bad_addr = addr;
-
-	while (!shadow_val && first_bad_addr < addr + size) {
-		first_bad_addr += KASAN_SHADOW_SCALE_SIZE;
-		shadow_val = *(u8 *)kasan_mem_to_shadow(first_bad_addr);
-	}
-	return first_bad_addr;
-}
+static unsigned long kasan_flags;
 
-static bool addr_has_shadow(struct kasan_access_info *info)
-{
-	return (info->access_addr >=
-		kasan_shadow_to_mem((void *)KASAN_SHADOW_START));
-}
+#define KASAN_BIT_REPORTED	0
+#define KASAN_BIT_MULTI_SHOT	1
 
-static const char *get_shadow_bug_type(struct kasan_access_info *info)
+bool kasan_save_enable_multi_shot(void)
 {
-	const char *bug_type = "unknown-crash";
-	u8 *shadow_addr;
-
-	info->first_bad_addr = find_first_bad_addr(info->access_addr,
-						info->access_size);
-
-	shadow_addr = (u8 *)kasan_mem_to_shadow(info->first_bad_addr);
-
-	/*
-	 * If shadow byte value is in [0, KASAN_SHADOW_SCALE_SIZE) we can look
-	 * at the next shadow byte to determine the type of the bad access.
-	 */
-	if (*shadow_addr > 0 && *shadow_addr <= KASAN_SHADOW_SCALE_SIZE - 1)
-		shadow_addr++;
-
-	switch (*shadow_addr) {
-	case 0 ... KASAN_SHADOW_SCALE_SIZE - 1:
-		/*
-		 * In theory it's still possible to see these shadow values
-		 * due to a data race in the kernel code.
-		 */
-		bug_type = "out-of-bounds";
-		break;
-	case KASAN_PAGE_REDZONE:
-	case KASAN_KMALLOC_REDZONE:
-		bug_type = "slab-out-of-bounds";
-		break;
-	case KASAN_GLOBAL_REDZONE:
-		bug_type = "global-out-of-bounds";
-		break;
-	case KASAN_STACK_LEFT:
-	case KASAN_STACK_MID:
-	case KASAN_STACK_RIGHT:
-	case KASAN_STACK_PARTIAL:
-		bug_type = "stack-out-of-bounds";
-		break;
-	case KASAN_FREE_PAGE:
-	case KASAN_KMALLOC_FREE:
-		bug_type = "use-after-free";
-		break;
-	case KASAN_USE_AFTER_SCOPE:
-		bug_type = "use-after-scope";
-		break;
-	case KASAN_ALLOCA_LEFT:
-	case KASAN_ALLOCA_RIGHT:
-		bug_type = "alloca-out-of-bounds";
-		break;
-	}
-
-	return bug_type;
+	return test_and_set_bit(KASAN_BIT_MULTI_SHOT, &kasan_flags);
 }
+EXPORT_SYMBOL_GPL(kasan_save_enable_multi_shot);
 
-static const char *get_wild_bug_type(struct kasan_access_info *info)
+void kasan_restore_multi_shot(bool enabled)
 {
-	const char *bug_type = "unknown-crash";
-
-	if ((unsigned long)info->access_addr < PAGE_SIZE)
-		bug_type = "null-ptr-deref";
-	else if ((unsigned long)info->access_addr < TASK_SIZE)
-		bug_type = "user-memory-access";
-	else
-		bug_type = "wild-memory-access";
-
-	return bug_type;
+	if (!enabled)
+		clear_bit(KASAN_BIT_MULTI_SHOT, &kasan_flags);
 }
+EXPORT_SYMBOL_GPL(kasan_restore_multi_shot);
 
-static const char *get_bug_type(struct kasan_access_info *info)
+static int __init kasan_set_multi_shot(char *str)
 {
-	if (addr_has_shadow(info))
-		return get_shadow_bug_type(info);
-	return get_wild_bug_type(info);
+	set_bit(KASAN_BIT_MULTI_SHOT, &kasan_flags);
+	return 1;
 }
+__setup("kasan_multi_shot", kasan_set_multi_shot);
 
-static void print_error_description(struct kasan_access_info *info)
+static void print_error_description(struct kasan_access_info *info,
+					const char *bug_type)
 {
-	const char *bug_type = get_bug_type(info);
-
 	pr_err("BUG: KASAN: %s in %pS\n",
 		bug_type, (void *)info->ip);
 	pr_err("%s of size %zu at addr %px by task %s/%d\n",
@@ -143,25 +74,9 @@ static void print_error_description(struct kasan_access_info *info)
 		info->access_addr, current->comm, task_pid_nr(current));
 }
 
-static inline bool kernel_or_module_addr(const void *addr)
-{
-	if (addr >= (void *)_stext && addr < (void *)_end)
-		return true;
-	if (is_module_address((unsigned long)addr))
-		return true;
-	return false;
-}
-
-static inline bool init_task_stack_addr(const void *addr)
-{
-	return addr >= (void *)&init_thread_union.stack &&
-		(addr <= (void *)&init_thread_union.stack +
-			sizeof(init_thread_union.stack));
-}
-
 static DEFINE_SPINLOCK(report_lock);
 
-static void kasan_start_report(unsigned long *flags)
+static void start_report(unsigned long *flags)
 {
 	/*
 	 * Make sure we don't end up in loop.
@@ -171,7 +86,7 @@ static void kasan_start_report(unsigned long *flags)
 	pr_err("==================================================================\n");
 }
 
-static void kasan_end_report(unsigned long *flags)
+static void end_report(unsigned long *flags)
 {
 	pr_err("==================================================================\n");
 	add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
@@ -249,6 +164,22 @@ static void describe_object(struct kmem_cache *cache, void *object,
 	describe_object_addr(cache, object, addr);
 }
 
+static inline bool kernel_or_module_addr(const void *addr)
+{
+	if (addr >= (void *)_stext && addr < (void *)_end)
+		return true;
+	if (is_module_address((unsigned long)addr))
+		return true;
+	return false;
+}
+
+static inline bool init_task_stack_addr(const void *addr)
+{
+	return addr >= (void *)&init_thread_union.stack &&
+		(addr <= (void *)&init_thread_union.stack +
+			sizeof(init_thread_union.stack));
+}
+
 static void print_address_description(void *addr)
 {
 	struct page *page = addr_to_page(addr);
@@ -326,29 +257,38 @@ static void print_shadow_for_address(const void *addr)
 	}
 }
 
+static bool report_enabled(void)
+{
+	if (current->kasan_depth)
+		return false;
+	if (test_bit(KASAN_BIT_MULTI_SHOT, &kasan_flags))
+		return true;
+	return !test_and_set_bit(KASAN_BIT_REPORTED, &kasan_flags);
+}
+
 void kasan_report_invalid_free(void *object, unsigned long ip)
 {
 	unsigned long flags;
 
-	kasan_start_report(&flags);
+	start_report(&flags);
 	pr_err("BUG: KASAN: double-free or invalid-free in %pS\n", (void *)ip);
 	pr_err("\n");
 	print_address_description(object);
 	pr_err("\n");
 	print_shadow_for_address(object);
-	kasan_end_report(&flags);
+	end_report(&flags);
 }
 
 static void kasan_report_error(struct kasan_access_info *info)
 {
 	unsigned long flags;
 
-	kasan_start_report(&flags);
+	start_report(&flags);
 
-	print_error_description(info);
+	print_error_description(info, get_bug_type(info));
 	pr_err("\n");
 
-	if (!addr_has_shadow(info)) {
+	if (!addr_has_shadow(info->access_addr)) {
 		dump_stack();
 	} else {
 		print_address_description((void *)info->access_addr);
@@ -356,41 +296,7 @@ static void kasan_report_error(struct kasan_access_info *info)
 		print_shadow_for_address(info->first_bad_addr);
 	}
 
-	kasan_end_report(&flags);
-}
-
-static unsigned long kasan_flags;
-
-#define KASAN_BIT_REPORTED	0
-#define KASAN_BIT_MULTI_SHOT	1
-
-bool kasan_save_enable_multi_shot(void)
-{
-	return test_and_set_bit(KASAN_BIT_MULTI_SHOT, &kasan_flags);
-}
-EXPORT_SYMBOL_GPL(kasan_save_enable_multi_shot);
-
-void kasan_restore_multi_shot(bool enabled)
-{
-	if (!enabled)
-		clear_bit(KASAN_BIT_MULTI_SHOT, &kasan_flags);
-}
-EXPORT_SYMBOL_GPL(kasan_restore_multi_shot);
-
-static int __init kasan_set_multi_shot(char *str)
-{
-	set_bit(KASAN_BIT_MULTI_SHOT, &kasan_flags);
-	return 1;
-}
-__setup("kasan_multi_shot", kasan_set_multi_shot);
-
-static inline bool kasan_report_enabled(void)
-{
-	if (current->kasan_depth)
-		return false;
-	if (test_bit(KASAN_BIT_MULTI_SHOT, &kasan_flags))
-		return true;
-	return !test_and_set_bit(KASAN_BIT_REPORTED, &kasan_flags);
+	end_report(&flags);
 }
 
 void kasan_report(unsigned long addr, size_t size,
@@ -398,7 +304,7 @@ void kasan_report(unsigned long addr, size_t size,
 {
 	struct kasan_access_info info;
 
-	if (likely(!kasan_report_enabled()))
+	if (likely(!report_enabled()))
 		return;
 
 	disable_trace_on_warning();
@@ -411,41 +317,3 @@ void kasan_report(unsigned long addr, size_t size,
 
 	kasan_report_error(&info);
 }
-
-
-#define DEFINE_ASAN_REPORT_LOAD(size)                     \
-void __asan_report_load##size##_noabort(unsigned long addr) \
-{                                                         \
-	kasan_report(addr, size, false, _RET_IP_);	  \
-}                                                         \
-EXPORT_SYMBOL(__asan_report_load##size##_noabort)
-
-#define DEFINE_ASAN_REPORT_STORE(size)                     \
-void __asan_report_store##size##_noabort(unsigned long addr) \
-{                                                          \
-	kasan_report(addr, size, true, _RET_IP_);	   \
-}                                                          \
-EXPORT_SYMBOL(__asan_report_store##size##_noabort)
-
-DEFINE_ASAN_REPORT_LOAD(1);
-DEFINE_ASAN_REPORT_LOAD(2);
-DEFINE_ASAN_REPORT_LOAD(4);
-DEFINE_ASAN_REPORT_LOAD(8);
-DEFINE_ASAN_REPORT_LOAD(16);
-DEFINE_ASAN_REPORT_STORE(1);
-DEFINE_ASAN_REPORT_STORE(2);
-DEFINE_ASAN_REPORT_STORE(4);
-DEFINE_ASAN_REPORT_STORE(8);
-DEFINE_ASAN_REPORT_STORE(16);
-
-void __asan_report_load_n_noabort(unsigned long addr, size_t size)
-{
-	kasan_report(addr, size, false, _RET_IP_);
-}
-EXPORT_SYMBOL(__asan_report_load_n_noabort);
-
-void __asan_report_store_n_noabort(unsigned long addr, size_t size)
-{
-	kasan_report(addr, size, true, _RET_IP_);
-}
-EXPORT_SYMBOL(__asan_report_store_n_noabort);
diff --git a/mm/kasan/tags_report.c b/mm/kasan/tags_report.c
new file mode 100644
index 000000000000..8af15e87d3bc
--- /dev/null
+++ b/mm/kasan/tags_report.c
@@ -0,0 +1,39 @@
+/*
+ * This file contains tag-based KASAN specific error reporting code.
+ *
+ * Copyright (c) 2014 Samsung Electronics Co., Ltd.
+ * Author: Andrey Ryabinin <ryabinin.a.a@gmail.com>
+ *
+ * Some code borrowed from https://github.com/xairy/kasan-prototype by
+ *        Andrey Konovalov <andreyknvl@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#include <linux/bitops.h>
+#include <linux/ftrace.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/printk.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/stackdepot.h>
+#include <linux/stacktrace.h>
+#include <linux/string.h>
+#include <linux/types.h>
+#include <linux/kasan.h>
+#include <linux/module.h>
+
+#include <asm/sections.h>
+
+#include "kasan.h"
+#include "../slab.h"
+
+const char *get_bug_type(struct kasan_access_info *info)
+{
+	return "invalid-access";
+}
-- 
2.20.0.rc0.387.gc7a69e6b6c-goog
