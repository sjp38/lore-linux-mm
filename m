Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id A30CA6B000A
	for <linux-mm@kvack.org>; Thu, 31 May 2018 20:43:44 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id x2-v6so14274837plv.0
        for <linux-mm@kvack.org>; Thu, 31 May 2018 17:43:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i3-v6sor16555214pld.65.2018.05.31.17.43.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 May 2018 17:43:43 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 03/16] lib: overflow: Report test failures
Date: Thu, 31 May 2018 17:42:20 -0700
Message-Id: <20180601004233.37822-4-keescook@chromium.org>
In-Reply-To: <20180601004233.37822-1-keescook@chromium.org>
References: <20180601004233.37822-1-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Matthew Wilcox <willy@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

This adjusts the overflow test to report failures, and prepares to
add allocation tests.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 lib/test_overflow.c | 75 ++++++++++++++++++++++++++++++++-------------
 1 file changed, 54 insertions(+), 21 deletions(-)

diff --git a/lib/test_overflow.c b/lib/test_overflow.c
index e1e45ba17ff0..482d71c880fa 100644
--- a/lib/test_overflow.c
+++ b/lib/test_overflow.c
@@ -212,42 +212,59 @@ DEFINE_TEST_ARRAY(s64) = {
 };
 
 #define DEFINE_TEST_FUNC(t, fmt)					\
-static void __init do_test_ ## t(const struct test_ ## t *p)		\
+static int __init do_test_ ## t(const struct test_ ## t *p)		\
 {							   		\
 	t r;								\
+	int err = 0;							\
 	bool of;							\
 									\
 	of = check_add_overflow(p->a, p->b, &r);			\
-	if (of != p->s_of)						\
+	if (of != p->s_of) {						\
 		pr_warn("expected "fmt" + "fmt" to%s overflow (type %s)\n", \
 			p->a, p->b, p->s_of ? "" : " not", #t);		\
-	if (r != p->sum)						\
+		err = 1;						\
+	}								\
+	if (r != p->sum) {						\
 		pr_warn("expected "fmt" + "fmt" == "fmt", got "fmt" (type %s)\n", \
 			p->a, p->b, p->sum, r, #t);			\
+		err = 1;						\
+	}								\
 									\
 	of = check_sub_overflow(p->a, p->b, &r);			\
-	if (of != p->d_of)						\
+	if (of != p->d_of) {						\
 		pr_warn("expected "fmt" - "fmt" to%s overflow (type %s)\n", \
 			p->a, p->b, p->s_of ? "" : " not", #t);		\
-	if (r != p->diff)						\
+		err = 1;						\
+	}								\
+	if (r != p->diff) {						\
 		pr_warn("expected "fmt" - "fmt" == "fmt", got "fmt" (type %s)\n", \
 			p->a, p->b, p->diff, r, #t);			\
+		err = 1;						\
+	}								\
 									\
 	of = check_mul_overflow(p->a, p->b, &r);			\
-	if (of != p->p_of)						\
+	if (of != p->p_of) {						\
 		pr_warn("expected "fmt" * "fmt" to%s overflow (type %s)\n", \
 			p->a, p->b, p->p_of ? "" : " not", #t);		\
-	if (r != p->prod)						\
+		err = 1;						\
+	}								\
+	if (r != p->prod) {						\
 		pr_warn("expected "fmt" * "fmt" == "fmt", got "fmt" (type %s)\n", \
 			p->a, p->b, p->prod, r, #t);			\
+		err = 1;						\
+	}								\
+									\
+	return err;							\
 }									\
 									\
-static void __init test_ ## t ## _overflow(void) {			\
+static int __init test_ ## t ## _overflow(void) {			\
 	unsigned i;							\
+	int err = 0;							\
 									\
 	pr_info("%-3s: %zu tests\n", #t, ARRAY_SIZE(t ## _tests));	\
 	for (i = 0; i < ARRAY_SIZE(t ## _tests); ++i)			\
-		do_test_ ## t(&t ## _tests[i]);				\
+		err |= do_test_ ## t(&t ## _tests[i]);			\
+	return err;							\
 }
 
 DEFINE_TEST_FUNC(u8, "%d");
@@ -260,26 +277,42 @@ DEFINE_TEST_FUNC(s16, "%d");
 DEFINE_TEST_FUNC(s32, "%d");
 DEFINE_TEST_FUNC(s64, "%lld");
 
-static int __init test_overflow(void)
+static int __init test_overflow_calculation(void)
+{
+	int err = 0;
+
+	err |= test_u8_overflow();
+	err |= test_u16_overflow();
+	err |= test_u32_overflow();
+	err |= test_u64_overflow();
+
+	err |= test_s8_overflow();
+	err |= test_s16_overflow();
+	err |= test_s32_overflow();
+	err |= test_s64_overflow();
+
+	return err;
+}
+
+static int __init test_module_init(void)
 {
-	test_u8_overflow();
-	test_u16_overflow();
-	test_u32_overflow();
-	test_u64_overflow();
+	int err = 0;
 
-	test_s8_overflow();
-	test_s16_overflow();
-	test_s32_overflow();
-	test_s64_overflow();
+	err |= test_overflow_calculation();
 
-	pr_info("done\n");
+	if (err) {
+		pr_warn("FAIL!\n");
+		err = -EINVAL;
+	} else {
+		pr_info("all tests passed\n");
+	}
 
-	return 0;
+	return err;
 }
 
 static void __exit test_module_exit(void)
 { }
 
-module_init(test_overflow);
+module_init(test_module_init);
 module_exit(test_module_exit);
 MODULE_LICENSE("Dual MIT/GPL");
-- 
2.17.0
