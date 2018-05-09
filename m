Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 321996B0581
	for <linux-mm@kvack.org>; Wed,  9 May 2018 16:02:41 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t74-v6so12590351pgc.14
        for <linux-mm@kvack.org>; Wed, 09 May 2018 13:02:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k1sor8232770pfh.35.2018.05.09.13.02.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 May 2018 13:02:39 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 2/6] lib: add runtime test of check_*_overflow functions
Date: Wed,  9 May 2018 13:02:19 -0700
Message-Id: <20180509200223.22451-3-keescook@chromium.org>
In-Reply-To: <20180509200223.22451-1-keescook@chromium.org>
References: <20180509200223.22451-1-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Kees Cook <keescook@chromium.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Matthew Wilcox <willy@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

From: Rasmus Villemoes <linux@rasmusvillemoes.dk>

This adds a small module for testing that the check_*_overflow
functions work as expected, whether implemented in C or using gcc
builtins.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 lib/Kconfig.debug   |   3 +
 lib/Makefile        |   1 +
 lib/test_overflow.c | 285 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 289 insertions(+)
 create mode 100644 lib/test_overflow.c

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index c40c7b734cd1..d9fe912afed5 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1785,6 +1785,9 @@ config TEST_BITMAP
 config TEST_UUID
 	tristate "Test functions located in the uuid module at runtime"
 
+config TEST_OVERFLOW
+	tristate "Test check_*_overflow() functions at runtime"
+
 config TEST_RHASHTABLE
 	tristate "Perform selftest on resizable hash table"
 	default n
diff --git a/lib/Makefile b/lib/Makefile
index ce20696d5a92..eb762ad52ccf 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -59,6 +59,7 @@ UBSAN_SANITIZE_test_ubsan.o := y
 obj-$(CONFIG_TEST_KSTRTOX) += test-kstrtox.o
 obj-$(CONFIG_TEST_LIST_SORT) += test_list_sort.o
 obj-$(CONFIG_TEST_LKM) += test_module.o
+obj-$(CONFIG_TEST_OVERFLOW) += test_overflow.o
 obj-$(CONFIG_TEST_RHASHTABLE) += test_rhashtable.o
 obj-$(CONFIG_TEST_SORT) += test_sort.o
 obj-$(CONFIG_TEST_USER_COPY) += test_user_copy.o
diff --git a/lib/test_overflow.c b/lib/test_overflow.c
new file mode 100644
index 000000000000..e1e45ba17ff0
--- /dev/null
+++ b/lib/test_overflow.c
@@ -0,0 +1,285 @@
+/* SPDX-License-Identifier: GPL-2.0 OR MIT */
+/*
+ * Test cases for arithmetic overflow checks.
+ */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/overflow.h>
+#include <linux/types.h>
+
+#define DEFINE_TEST_ARRAY(t)			\
+	static const struct test_ ## t {	\
+		t a, b;				\
+		t sum, diff, prod;		\
+		bool s_of, d_of, p_of;		\
+	} t ## _tests[] __initconst
+
+DEFINE_TEST_ARRAY(u8) = {
+	{0, 0, 0, 0, 0, false, false, false},
+	{1, 1, 2, 0, 1, false, false, false},
+	{0, 1, 1, U8_MAX, 0, false, true, false},
+	{1, 0, 1, 1, 0, false, false, false},
+	{0, U8_MAX, U8_MAX, 1, 0, false, true, false},
+	{U8_MAX, 0, U8_MAX, U8_MAX, 0, false, false, false},
+	{1, U8_MAX, 0, 2, U8_MAX, true, true, false},
+	{U8_MAX, 1, 0, U8_MAX-1, U8_MAX, true, false, false},
+	{U8_MAX, U8_MAX, U8_MAX-1, 0, 1, true, false, true},
+
+	{U8_MAX, U8_MAX-1, U8_MAX-2, 1, 2, true, false, true},
+	{U8_MAX-1, U8_MAX, U8_MAX-2, U8_MAX, 2, true, true, true},
+
+	{1U << 3, 1U << 3, 1U << 4, 0, 1U << 6, false, false, false},
+	{1U << 4, 1U << 4, 1U << 5, 0, 0, false, false, true},
+	{1U << 4, 1U << 3, 3*(1U << 3), 1U << 3, 1U << 7, false, false, false},
+	{1U << 7, 1U << 7, 0, 0, 0, true, false, true},
+
+	{48, 32, 80, 16, 0, false, false, true},
+	{128, 128, 0, 0, 0, true, false, true},
+	{123, 234, 101, 145, 110, true, true, true},
+};
+DEFINE_TEST_ARRAY(u16) = {
+	{0, 0, 0, 0, 0, false, false, false},
+	{1, 1, 2, 0, 1, false, false, false},
+	{0, 1, 1, U16_MAX, 0, false, true, false},
+	{1, 0, 1, 1, 0, false, false, false},
+	{0, U16_MAX, U16_MAX, 1, 0, false, true, false},
+	{U16_MAX, 0, U16_MAX, U16_MAX, 0, false, false, false},
+	{1, U16_MAX, 0, 2, U16_MAX, true, true, false},
+	{U16_MAX, 1, 0, U16_MAX-1, U16_MAX, true, false, false},
+	{U16_MAX, U16_MAX, U16_MAX-1, 0, 1, true, false, true},
+
+	{U16_MAX, U16_MAX-1, U16_MAX-2, 1, 2, true, false, true},
+	{U16_MAX-1, U16_MAX, U16_MAX-2, U16_MAX, 2, true, true, true},
+
+	{1U << 7, 1U << 7, 1U << 8, 0, 1U << 14, false, false, false},
+	{1U << 8, 1U << 8, 1U << 9, 0, 0, false, false, true},
+	{1U << 8, 1U << 7, 3*(1U << 7), 1U << 7, 1U << 15, false, false, false},
+	{1U << 15, 1U << 15, 0, 0, 0, true, false, true},
+
+	{123, 234, 357, 65425, 28782, false, true, false},
+	{1234, 2345, 3579, 64425, 10146, false, true, true},
+};
+DEFINE_TEST_ARRAY(u32) = {
+	{0, 0, 0, 0, 0, false, false, false},
+	{1, 1, 2, 0, 1, false, false, false},
+	{0, 1, 1, U32_MAX, 0, false, true, false},
+	{1, 0, 1, 1, 0, false, false, false},
+	{0, U32_MAX, U32_MAX, 1, 0, false, true, false},
+	{U32_MAX, 0, U32_MAX, U32_MAX, 0, false, false, false},
+	{1, U32_MAX, 0, 2, U32_MAX, true, true, false},
+	{U32_MAX, 1, 0, U32_MAX-1, U32_MAX, true, false, false},
+	{U32_MAX, U32_MAX, U32_MAX-1, 0, 1, true, false, true},
+
+	{U32_MAX, U32_MAX-1, U32_MAX-2, 1, 2, true, false, true},
+	{U32_MAX-1, U32_MAX, U32_MAX-2, U32_MAX, 2, true, true, true},
+
+	{1U << 15, 1U << 15, 1U << 16, 0, 1U << 30, false, false, false},
+	{1U << 16, 1U << 16, 1U << 17, 0, 0, false, false, true},
+	{1U << 16, 1U << 15, 3*(1U << 15), 1U << 15, 1U << 31, false, false, false},
+	{1U << 31, 1U << 31, 0, 0, 0, true, false, true},
+
+	{-2U, 1U, -1U, -3U, -2U, false, false, false},
+	{-4U, 5U, 1U, -9U, -20U, true, false, true},
+};
+
+DEFINE_TEST_ARRAY(u64) = {
+	{0, 0, 0, 0, 0, false, false, false},
+	{1, 1, 2, 0, 1, false, false, false},
+	{0, 1, 1, U64_MAX, 0, false, true, false},
+	{1, 0, 1, 1, 0, false, false, false},
+	{0, U64_MAX, U64_MAX, 1, 0, false, true, false},
+	{U64_MAX, 0, U64_MAX, U64_MAX, 0, false, false, false},
+	{1, U64_MAX, 0, 2, U64_MAX, true, true, false},
+	{U64_MAX, 1, 0, U64_MAX-1, U64_MAX, true, false, false},
+	{U64_MAX, U64_MAX, U64_MAX-1, 0, 1, true, false, true},
+
+	{U64_MAX, U64_MAX-1, U64_MAX-2, 1, 2, true, false, true},
+	{U64_MAX-1, U64_MAX, U64_MAX-2, U64_MAX, 2, true, true, true},
+
+	{1ULL << 31, 1ULL << 31, 1ULL << 32, 0, 1ULL << 62, false, false, false},
+	{1ULL << 32, 1ULL << 32, 1ULL << 33, 0, 0, false, false, true},
+	{1ULL << 32, 1ULL << 31, 3*(1ULL << 31), 1ULL << 31, 1ULL << 63, false, false, false},
+	{1ULL << 63, 1ULL << 63, 0, 0, 0, true, false, true},
+	{1000000000ULL /* 10^9 */, 10000000000ULL /* 10^10 */,
+	 11000000000ULL, 18446744064709551616ULL, 10000000000000000000ULL,
+	 false, true, false},
+	{-15ULL, 10ULL, -5ULL, -25ULL, -150ULL, false, false, true},
+};
+
+DEFINE_TEST_ARRAY(s8) = {
+	{0, 0, 0, 0, 0, false, false, false},
+
+	{0, S8_MAX, S8_MAX, -S8_MAX, 0, false, false, false},
+	{S8_MAX, 0, S8_MAX, S8_MAX, 0, false, false, false},
+	{0, S8_MIN, S8_MIN, S8_MIN, 0, false, true, false},
+	{S8_MIN, 0, S8_MIN, S8_MIN, 0, false, false, false},
+
+	{-1, S8_MIN, S8_MAX, S8_MAX, S8_MIN, true, false, true},
+	{S8_MIN, -1, S8_MAX, -S8_MAX, S8_MIN, true, false, true},
+	{-1, S8_MAX, S8_MAX-1, S8_MIN, -S8_MAX, false, false, false},
+	{S8_MAX, -1, S8_MAX-1, S8_MIN, -S8_MAX, false, true, false},
+	{-1, -S8_MAX, S8_MIN, S8_MAX-1, S8_MAX, false, false, false},
+	{-S8_MAX, -1, S8_MIN, S8_MIN+2, S8_MAX, false, false, false},
+
+	{1, S8_MIN, -S8_MAX, -S8_MAX, S8_MIN, false, true, false},
+	{S8_MIN, 1, -S8_MAX, S8_MAX, S8_MIN, false, true, false},
+	{1, S8_MAX, S8_MIN, S8_MIN+2, S8_MAX, true, false, false},
+	{S8_MAX, 1, S8_MIN, S8_MAX-1, S8_MAX, true, false, false},
+
+	{S8_MIN, S8_MIN, 0, 0, 0, true, false, true},
+	{S8_MAX, S8_MAX, -2, 0, 1, true, false, true},
+
+	{-4, -32, -36, 28, -128, false, false, true},
+	{-4, 32, 28, -36, -128, false, false, false},
+};
+
+DEFINE_TEST_ARRAY(s16) = {
+	{0, 0, 0, 0, 0, false, false, false},
+
+	{0, S16_MAX, S16_MAX, -S16_MAX, 0, false, false, false},
+	{S16_MAX, 0, S16_MAX, S16_MAX, 0, false, false, false},
+	{0, S16_MIN, S16_MIN, S16_MIN, 0, false, true, false},
+	{S16_MIN, 0, S16_MIN, S16_MIN, 0, false, false, false},
+
+	{-1, S16_MIN, S16_MAX, S16_MAX, S16_MIN, true, false, true},
+	{S16_MIN, -1, S16_MAX, -S16_MAX, S16_MIN, true, false, true},
+	{-1, S16_MAX, S16_MAX-1, S16_MIN, -S16_MAX, false, false, false},
+	{S16_MAX, -1, S16_MAX-1, S16_MIN, -S16_MAX, false, true, false},
+	{-1, -S16_MAX, S16_MIN, S16_MAX-1, S16_MAX, false, false, false},
+	{-S16_MAX, -1, S16_MIN, S16_MIN+2, S16_MAX, false, false, false},
+
+	{1, S16_MIN, -S16_MAX, -S16_MAX, S16_MIN, false, true, false},
+	{S16_MIN, 1, -S16_MAX, S16_MAX, S16_MIN, false, true, false},
+	{1, S16_MAX, S16_MIN, S16_MIN+2, S16_MAX, true, false, false},
+	{S16_MAX, 1, S16_MIN, S16_MAX-1, S16_MAX, true, false, false},
+
+	{S16_MIN, S16_MIN, 0, 0, 0, true, false, true},
+	{S16_MAX, S16_MAX, -2, 0, 1, true, false, true},
+};
+DEFINE_TEST_ARRAY(s32) = {
+	{0, 0, 0, 0, 0, false, false, false},
+
+	{0, S32_MAX, S32_MAX, -S32_MAX, 0, false, false, false},
+	{S32_MAX, 0, S32_MAX, S32_MAX, 0, false, false, false},
+	{0, S32_MIN, S32_MIN, S32_MIN, 0, false, true, false},
+	{S32_MIN, 0, S32_MIN, S32_MIN, 0, false, false, false},
+
+	{-1, S32_MIN, S32_MAX, S32_MAX, S32_MIN, true, false, true},
+	{S32_MIN, -1, S32_MAX, -S32_MAX, S32_MIN, true, false, true},
+	{-1, S32_MAX, S32_MAX-1, S32_MIN, -S32_MAX, false, false, false},
+	{S32_MAX, -1, S32_MAX-1, S32_MIN, -S32_MAX, false, true, false},
+	{-1, -S32_MAX, S32_MIN, S32_MAX-1, S32_MAX, false, false, false},
+	{-S32_MAX, -1, S32_MIN, S32_MIN+2, S32_MAX, false, false, false},
+
+	{1, S32_MIN, -S32_MAX, -S32_MAX, S32_MIN, false, true, false},
+	{S32_MIN, 1, -S32_MAX, S32_MAX, S32_MIN, false, true, false},
+	{1, S32_MAX, S32_MIN, S32_MIN+2, S32_MAX, true, false, false},
+	{S32_MAX, 1, S32_MIN, S32_MAX-1, S32_MAX, true, false, false},
+
+	{S32_MIN, S32_MIN, 0, 0, 0, true, false, true},
+	{S32_MAX, S32_MAX, -2, 0, 1, true, false, true},
+};
+DEFINE_TEST_ARRAY(s64) = {
+	{0, 0, 0, 0, 0, false, false, false},
+
+	{0, S64_MAX, S64_MAX, -S64_MAX, 0, false, false, false},
+	{S64_MAX, 0, S64_MAX, S64_MAX, 0, false, false, false},
+	{0, S64_MIN, S64_MIN, S64_MIN, 0, false, true, false},
+	{S64_MIN, 0, S64_MIN, S64_MIN, 0, false, false, false},
+
+	{-1, S64_MIN, S64_MAX, S64_MAX, S64_MIN, true, false, true},
+	{S64_MIN, -1, S64_MAX, -S64_MAX, S64_MIN, true, false, true},
+	{-1, S64_MAX, S64_MAX-1, S64_MIN, -S64_MAX, false, false, false},
+	{S64_MAX, -1, S64_MAX-1, S64_MIN, -S64_MAX, false, true, false},
+	{-1, -S64_MAX, S64_MIN, S64_MAX-1, S64_MAX, false, false, false},
+	{-S64_MAX, -1, S64_MIN, S64_MIN+2, S64_MAX, false, false, false},
+
+	{1, S64_MIN, -S64_MAX, -S64_MAX, S64_MIN, false, true, false},
+	{S64_MIN, 1, -S64_MAX, S64_MAX, S64_MIN, false, true, false},
+	{1, S64_MAX, S64_MIN, S64_MIN+2, S64_MAX, true, false, false},
+	{S64_MAX, 1, S64_MIN, S64_MAX-1, S64_MAX, true, false, false},
+
+	{S64_MIN, S64_MIN, 0, 0, 0, true, false, true},
+	{S64_MAX, S64_MAX, -2, 0, 1, true, false, true},
+
+	{-1, -1, -2, 0, 1, false, false, false},
+	{-1, -128, -129, 127, 128, false, false, false},
+	{-128, -1, -129, -127, 128, false, false, false},
+	{0, -S64_MAX, -S64_MAX, S64_MAX, 0, false, false, false},
+};
+
+#define DEFINE_TEST_FUNC(t, fmt)					\
+static void __init do_test_ ## t(const struct test_ ## t *p)		\
+{							   		\
+	t r;								\
+	bool of;							\
+									\
+	of = check_add_overflow(p->a, p->b, &r);			\
+	if (of != p->s_of)						\
+		pr_warn("expected "fmt" + "fmt" to%s overflow (type %s)\n", \
+			p->a, p->b, p->s_of ? "" : " not", #t);		\
+	if (r != p->sum)						\
+		pr_warn("expected "fmt" + "fmt" == "fmt", got "fmt" (type %s)\n", \
+			p->a, p->b, p->sum, r, #t);			\
+									\
+	of = check_sub_overflow(p->a, p->b, &r);			\
+	if (of != p->d_of)						\
+		pr_warn("expected "fmt" - "fmt" to%s overflow (type %s)\n", \
+			p->a, p->b, p->s_of ? "" : " not", #t);		\
+	if (r != p->diff)						\
+		pr_warn("expected "fmt" - "fmt" == "fmt", got "fmt" (type %s)\n", \
+			p->a, p->b, p->diff, r, #t);			\
+									\
+	of = check_mul_overflow(p->a, p->b, &r);			\
+	if (of != p->p_of)						\
+		pr_warn("expected "fmt" * "fmt" to%s overflow (type %s)\n", \
+			p->a, p->b, p->p_of ? "" : " not", #t);		\
+	if (r != p->prod)						\
+		pr_warn("expected "fmt" * "fmt" == "fmt", got "fmt" (type %s)\n", \
+			p->a, p->b, p->prod, r, #t);			\
+}									\
+									\
+static void __init test_ ## t ## _overflow(void) {			\
+	unsigned i;							\
+									\
+	pr_info("%-3s: %zu tests\n", #t, ARRAY_SIZE(t ## _tests));	\
+	for (i = 0; i < ARRAY_SIZE(t ## _tests); ++i)			\
+		do_test_ ## t(&t ## _tests[i]);				\
+}
+
+DEFINE_TEST_FUNC(u8, "%d");
+DEFINE_TEST_FUNC(u16, "%d");
+DEFINE_TEST_FUNC(u32, "%u");
+DEFINE_TEST_FUNC(u64, "%llu");
+
+DEFINE_TEST_FUNC(s8, "%d");
+DEFINE_TEST_FUNC(s16, "%d");
+DEFINE_TEST_FUNC(s32, "%d");
+DEFINE_TEST_FUNC(s64, "%lld");
+
+static int __init test_overflow(void)
+{
+	test_u8_overflow();
+	test_u16_overflow();
+	test_u32_overflow();
+	test_u64_overflow();
+
+	test_s8_overflow();
+	test_s16_overflow();
+	test_s32_overflow();
+	test_s64_overflow();
+
+	pr_info("done\n");
+
+	return 0;
+}
+
+static void __exit test_module_exit(void)
+{ }
+
+module_init(test_overflow);
+module_exit(test_module_exit);
+MODULE_LICENSE("Dual MIT/GPL");
-- 
2.17.0
