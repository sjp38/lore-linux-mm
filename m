Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E9FFC6B0272
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 05:54:41 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z67so417368706pgb.0
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 02:54:41 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id s5si6045810pgj.372.2017.01.29.02.54.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 02:54:40 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id 194so29033570pgd.0
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 02:54:40 -0800 (PST)
Date: Sun, 29 Jan 2017 19:54:36 +0900
From: Jinbum Park <jinb.park7@gmail.com>
Subject: [PATCH v4] mm: add arch-independent testcases for RODATA
Message-ID: <20170129105436.GA9303@pjb1027-Latitude-E5410>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de
Cc: mingo@redhat.com, hpa@zytor.com, x86@kernel.org, keescook@chromium.org, arjan@linux.intel.com, akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, labbott@redhat.com, kernel-hardening@lists.openwall.com, mark.rutland@arm.com, kernel-janitors@vger.kernel.org, linux@armlinux.org.uk

This patch makes arch-independent testcases for RODATA.
Both x86 and x86_64 already have testcases for RODATA,
But they are arch-specific because using inline assembly directly.

and cacheflush.h is not suitable location for rodata-test related things.
Since they were in cacheflush.h,
If someone change the state of CONFIG_DEBUG_RODATA_TEST,
It cause overhead of kernel build.

To solve above issue,
write arch-independent testcases and move it to shared location.

Signed-off-by: Jinbum Park <jinb.park7@gmail.com>
---
v4: Move the rodata_test() call out into mark_readonly()
	Delete some comment

v3: Use probe_kernel_write() instead of put_user()
	Move declaration of rodata_test_data to separate header (rodata_test.h)
	Fix a kbuild-test-robot-error related to DEBUG_NX_TEST

v2: Restore original credit of mm/rodata_test.c

 arch/x86/Kconfig.debug            | 10 +-----
 arch/x86/include/asm/cacheflush.h | 10 ------
 arch/x86/kernel/Makefile          |  1 -
 arch/x86/kernel/test_rodata.c     | 75 ---------------------------------------
 arch/x86/mm/init_32.c             |  4 ---
 arch/x86/mm/init_64.c             |  5 ---
 include/linux/rodata_test.h       | 24 +++++++++++++
 init/main.c                       |  6 ++--
 mm/Kconfig.debug                  |  7 ++++
 mm/Makefile                       |  1 +
 mm/rodata_test.c                  | 56 +++++++++++++++++++++++++++++
 11 files changed, 93 insertions(+), 106 deletions(-)
 delete mode 100644 arch/x86/kernel/test_rodata.c
 create mode 100644 include/linux/rodata_test.h
 create mode 100644 mm/rodata_test.c

diff --git a/arch/x86/Kconfig.debug b/arch/x86/Kconfig.debug
index 67eec55..3fa469c 100644
--- a/arch/x86/Kconfig.debug
+++ b/arch/x86/Kconfig.debug
@@ -74,14 +74,6 @@ config EFI_PGT_DUMP
 	  issues with the mapping of the EFI runtime regions into that
 	  table.
 
-config DEBUG_RODATA_TEST
-	bool "Testcase for the marking rodata read-only"
-	default y
-	---help---
-	  This option enables a testcase for the setting rodata read-only
-	  as well as for the change_page_attr() infrastructure.
-	  If in doubt, say "N"
-
 config DEBUG_WX
 	bool "Warn on W+X mappings at boot"
 	select X86_PTDUMP_CORE
@@ -122,7 +114,7 @@ config DEBUG_SET_MODULE_RONX
 
 config DEBUG_NX_TEST
 	tristate "Testcase for the NX non-executable stack feature"
-	depends on DEBUG_KERNEL && m
+	depends on DEBUG_KERNEL && DEBUG_RODATA_TEST && m
 	---help---
 	  This option enables a testcase for the CPU NX capability
 	  and the software setup of this feature.
diff --git a/arch/x86/include/asm/cacheflush.h b/arch/x86/include/asm/cacheflush.h
index 872877d..e7e1942e 100644
--- a/arch/x86/include/asm/cacheflush.h
+++ b/arch/x86/include/asm/cacheflush.h
@@ -90,18 +90,8 @@
 
 #define mmio_flush_range(addr, size) clflush_cache_range(addr, size)
 
-extern const int rodata_test_data;
 extern int kernel_set_to_readonly;
 void set_kernel_text_rw(void);
 void set_kernel_text_ro(void);
 
-#ifdef CONFIG_DEBUG_RODATA_TEST
-int rodata_test(void);
-#else
-static inline int rodata_test(void)
-{
-	return 0;
-}
-#endif
-
 #endif /* _ASM_X86_CACHEFLUSH_H */
diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index 581386c..f6caf82 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -100,7 +100,6 @@ obj-$(CONFIG_HPET_TIMER) 	+= hpet.o
 obj-$(CONFIG_APB_TIMER)		+= apb_timer.o
 
 obj-$(CONFIG_AMD_NB)		+= amd_nb.o
-obj-$(CONFIG_DEBUG_RODATA_TEST)	+= test_rodata.o
 obj-$(CONFIG_DEBUG_NX_TEST)	+= test_nx.o
 obj-$(CONFIG_DEBUG_NMI_SELFTEST) += nmi_selftest.o
 
diff --git a/arch/x86/kernel/test_rodata.c b/arch/x86/kernel/test_rodata.c
deleted file mode 100644
index 222e84e..0000000
--- a/arch/x86/kernel/test_rodata.c
+++ /dev/null
@@ -1,75 +0,0 @@
-/*
- * test_rodata.c: functional test for mark_rodata_ro function
- *
- * (C) Copyright 2008 Intel Corporation
- * Author: Arjan van de Ven <arjan@linux.intel.com>
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; version 2
- * of the License.
- */
-#include <asm/cacheflush.h>
-#include <asm/sections.h>
-#include <asm/asm.h>
-
-int rodata_test(void)
-{
-	unsigned long result;
-	unsigned long start, end;
-
-	/* test 1: read the value */
-	/* If this test fails, some previous testrun has clobbered the state */
-	if (!rodata_test_data) {
-		printk(KERN_ERR "rodata_test: test 1 fails (start data)\n");
-		return -ENODEV;
-	}
-
-	/* test 2: write to the variable; this should fault */
-	/*
-	 * If this test fails, we managed to overwrite the data
-	 *
-	 * This is written in assembly to be able to catch the
-	 * exception that is supposed to happen in the correct
-	 * case
-	 */
-
-	result = 1;
-	asm volatile(
-		"0:	mov %[zero],(%[rodata_test])\n"
-		"	mov %[zero], %[rslt]\n"
-		"1:\n"
-		".section .fixup,\"ax\"\n"
-		"2:	jmp 1b\n"
-		".previous\n"
-		_ASM_EXTABLE(0b,2b)
-		: [rslt] "=r" (result)
-		: [rodata_test] "r" (&rodata_test_data), [zero] "r" (0UL)
-	);
-
-
-	if (!result) {
-		printk(KERN_ERR "rodata_test: test data was not read only\n");
-		return -ENODEV;
-	}
-
-	/* test 3: check the value hasn't changed */
-	/* If this test fails, we managed to overwrite the data */
-	if (!rodata_test_data) {
-		printk(KERN_ERR "rodata_test: Test 3 fails (end data)\n");
-		return -ENODEV;
-	}
-	/* test 4: check if the rodata section is 4Kb aligned */
-	start = (unsigned long)__start_rodata;
-	end = (unsigned long)__end_rodata;
-	if (start & (PAGE_SIZE - 1)) {
-		printk(KERN_ERR "rodata_test: .rodata is not 4k aligned\n");
-		return -ENODEV;
-	}
-	if (end & (PAGE_SIZE - 1)) {
-		printk(KERN_ERR "rodata_test: .rodata end is not 4k aligned\n");
-		return -ENODEV;
-	}
-
-	return 0;
-}
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 928d657..2b4b53e 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -864,9 +864,6 @@ static noinline int do_test_wp_bit(void)
 	return flag;
 }
 
-const int rodata_test_data = 0xC3;
-EXPORT_SYMBOL_GPL(rodata_test_data);
-
 int kernel_set_to_readonly __read_mostly;
 
 void set_kernel_text_rw(void)
@@ -939,7 +936,6 @@ void mark_rodata_ro(void)
 	set_pages_ro(virt_to_page(start), size >> PAGE_SHIFT);
 	printk(KERN_INFO "Write protecting the kernel read-only data: %luk\n",
 		size >> 10);
-	rodata_test();
 
 #ifdef CONFIG_CPA_DEBUG
 	printk(KERN_INFO "Testing CPA: undo %lx-%lx\n", start, start + size);
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 5fff913..a4880d8 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1011,9 +1011,6 @@ void __init mem_init(void)
 	mem_init_print_info(NULL);
 }
 
-const int rodata_test_data = 0xC3;
-EXPORT_SYMBOL_GPL(rodata_test_data);
-
 int kernel_set_to_readonly;
 
 void set_kernel_text_rw(void)
@@ -1082,8 +1079,6 @@ void mark_rodata_ro(void)
 	all_end = roundup((unsigned long)_brk_end, PMD_SIZE);
 	set_memory_nx(text_end, (all_end - text_end) >> PAGE_SHIFT);
 
-	rodata_test();
-
 #ifdef CONFIG_CPA_DEBUG
 	printk(KERN_INFO "Testing CPA: undo %lx-%lx\n", start, end);
 	set_memory_rw(start, (end-start) >> PAGE_SHIFT);
diff --git a/include/linux/rodata_test.h b/include/linux/rodata_test.h
new file mode 100644
index 0000000..562537f
--- /dev/null
+++ b/include/linux/rodata_test.h
@@ -0,0 +1,24 @@
+/*
+ * rodata_test.h: functional test for mark_rodata_ro function
+ *
+ * (C) Copyright 2008 Intel Corporation
+ * Author: Arjan van de Ven <arjan@linux.intel.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; version 2
+ * of the License.
+ */
+
+#ifndef _RODATA_TEST_H
+#define _RODATA_TEST_H
+
+#ifdef CONFIG_DEBUG_RODATA_TEST
+extern const int rodata_test_data;
+void rodata_test(void);
+#else
+static inline void rodata_test(void) {}
+#endif
+
+#endif /* _RODATA_TEST_H */
+
diff --git a/init/main.c b/init/main.c
index e47373d..1e417bb 100644
--- a/init/main.c
+++ b/init/main.c
@@ -82,6 +82,7 @@
 #include <linux/proc_ns.h>
 #include <linux/io.h>
 #include <linux/cache.h>
+#include <linux/rodata_test.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -935,9 +936,10 @@ static int __init set_debug_rodata(char *str)
 #ifdef CONFIG_DEBUG_RODATA
 static void mark_readonly(void)
 {
-	if (rodata_enabled)
+	if (rodata_enabled) {
 		mark_rodata_ro();
-	else
+		rodata_test();
+	} else
 		pr_info("Kernel memory protection disabled.\n");
 }
 #else
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index afcc550..3e5eada 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -90,3 +90,10 @@ config DEBUG_PAGE_REF
 	  careful when enabling this feature because it adds about 30 KB to the
 	  kernel code.  However the runtime performance overhead is virtually
 	  nil until the tracepoints are actually enabled.
+
+config DEBUG_RODATA_TEST
+    bool "Testcase for the marking rodata read-only"
+    depends on DEBUG_RODATA
+    ---help---
+      This option enables a testcase for the setting rodata read-only.
+
diff --git a/mm/Makefile b/mm/Makefile
index 433eaf9..d6199d4 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -83,6 +83,7 @@ obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
 obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
+obj-$(CONFIG_DEBUG_RODATA_TEST) += rodata_test.o
 obj-$(CONFIG_PAGE_OWNER) += page_owner.o
 obj-$(CONFIG_CLEANCACHE) += cleancache.o
 obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
diff --git a/mm/rodata_test.c b/mm/rodata_test.c
new file mode 100644
index 0000000..0fd2167
--- /dev/null
+++ b/mm/rodata_test.c
@@ -0,0 +1,56 @@
+/*
+ * rodata_test.c: functional test for mark_rodata_ro function
+ *
+ * (C) Copyright 2008 Intel Corporation
+ * Author: Arjan van de Ven <arjan@linux.intel.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; version 2
+ * of the License.
+ */
+#include <linux/uaccess.h>
+#include <asm/sections.h>
+
+const int rodata_test_data = 0xC3;
+EXPORT_SYMBOL_GPL(rodata_test_data);
+
+void rodata_test(void)
+{
+	unsigned long start, end;
+	int zero = 0;
+
+	/* test 1: read the value */
+	/* If this test fails, some previous testrun has clobbered the state */
+	if (!rodata_test_data) {
+		pr_err("rodata_test: test 1 fails (start data)\n");
+		return;
+	}
+
+	/* test 2: write to the variable; this should fault */
+	if (!probe_kernel_write((void *)&rodata_test_data,
+						(void *)&zero, sizeof(zero))) {
+		pr_err("rodata_test: test data was not read only\n");
+		return;
+	}
+
+	/* test 3: check the value hasn't changed */
+	if (rodata_test_data == zero) {
+		pr_err("rodata_test: test data was changed\n");
+		return;
+	}
+
+	/* test 4: check if the rodata section is PAGE_SIZE aligned */
+	start = (unsigned long)__start_rodata;
+	end = (unsigned long)__end_rodata;
+	if (start & (PAGE_SIZE - 1)) {
+		pr_err("rodata_test: start of .rodata is not page size aligned\n");
+		return;
+	}
+	if (end & (PAGE_SIZE - 1)) {
+		pr_err("rodata_test: end of .rodata is not page size aligned\n");
+		return;
+	}
+
+	pr_info("rodata_test: all tests were successful\n");
+}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
