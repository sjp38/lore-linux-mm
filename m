Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id DB6908E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 06:04:16 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id f69so1483892pff.5
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 03:04:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j6sor27582318pgq.46.2019.01.23.03.04.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 03:04:15 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 3/3] lib: Introduce test_stackinit module
Date: Wed, 23 Jan 2019 03:03:49 -0800
Message-Id: <20190123110349.35882-4-keescook@chromium.org>
In-Reply-To: <20190123110349.35882-1-keescook@chromium.org>
References: <20190123110349.35882-1-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Laura Abbott <labbott@redhat.com>, Alexander Popov <alex.popov@linux.com>, xen-devel@lists.xenproject.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, dev@openvswitch.org, linux-kbuild@vger.kernel.org, linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com

Adds test for stack initialization coverage. We have several build options
that control the level of stack variable initialization. This test lets us
visualize which options cover which cases, and provide tests for options
that are currently not available (padding initialization).

All options pass the explicit initialization cases and the partial
initializers (even with padding):

test_stackinit: u8_zero ok
test_stackinit: u16_zero ok
test_stackinit: u32_zero ok
test_stackinit: u64_zero ok
test_stackinit: char_array_zero ok
test_stackinit: small_hole_zero ok
test_stackinit: big_hole_zero ok
test_stackinit: packed_zero ok
test_stackinit: small_hole_dynamic_partial ok
test_stackinit: big_hole_dynamic_partial ok
test_stackinit: packed_static_partial ok
test_stackinit: small_hole_static_partial ok
test_stackinit: big_hole_static_partial ok

The results of the other tests (which contain no explicit initialization),
change based on the build's configured compiler instrumentation.

No options:

test_stackinit: small_hole_static_all FAIL (uninit bytes: 3)
test_stackinit: big_hole_static_all FAIL (uninit bytes: 61)
test_stackinit: small_hole_dynamic_all FAIL (uninit bytes: 3)
test_stackinit: big_hole_dynamic_all FAIL (uninit bytes: 61)
test_stackinit: small_hole_runtime_partial FAIL (uninit bytes: 23)
test_stackinit: big_hole_runtime_partial FAIL (uninit bytes: 127)
test_stackinit: small_hole_runtime_all FAIL (uninit bytes: 3)
test_stackinit: big_hole_runtime_all FAIL (uninit bytes: 61)
test_stackinit: u8 FAIL (uninit bytes: 1)
test_stackinit: u16 FAIL (uninit bytes: 2)
test_stackinit: u32 FAIL (uninit bytes: 4)
test_stackinit: u64 FAIL (uninit bytes: 8)
test_stackinit: char_array FAIL (uninit bytes: 16)
test_stackinit: small_hole FAIL (uninit bytes: 24)
test_stackinit: big_hole FAIL (uninit bytes: 128)
test_stackinit: user FAIL (uninit bytes: 32)
test_stackinit: failures: 16

CONFIG_GCC_PLUGIN_STRUCTLEAK=y
This only tries to initialize structs with __user markings:

test_stackinit: small_hole_static_all FAIL (uninit bytes: 3)
test_stackinit: big_hole_static_all FAIL (uninit bytes: 61)
test_stackinit: small_hole_dynamic_all FAIL (uninit bytes: 3)
test_stackinit: big_hole_dynamic_all FAIL (uninit bytes: 61)
test_stackinit: small_hole_runtime_partial FAIL (uninit bytes: 23)
test_stackinit: big_hole_runtime_partial FAIL (uninit bytes: 127)
test_stackinit: small_hole_runtime_all FAIL (uninit bytes: 3)
test_stackinit: big_hole_runtime_all FAIL (uninit bytes: 61)
test_stackinit: u8 FAIL (uninit bytes: 1)
test_stackinit: u16 FAIL (uninit bytes: 2)
test_stackinit: u32 FAIL (uninit bytes: 4)
test_stackinit: u64 FAIL (uninit bytes: 8)
test_stackinit: char_array FAIL (uninit bytes: 16)
test_stackinit: small_hole FAIL (uninit bytes: 24)
test_stackinit: big_hole FAIL (uninit bytes: 128)
test_stackinit: user ok
test_stackinit: failures: 15

CONFIG_GCC_PLUGIN_STRUCTLEAK=y
CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL=y
This initializes all structures passed by reference (scalars and strings
remain uninitialized, but padding is wiped):

test_stackinit: small_hole_static_all ok
test_stackinit: big_hole_static_all ok
test_stackinit: small_hole_dynamic_all ok
test_stackinit: big_hole_dynamic_all ok
test_stackinit: small_hole_runtime_partial ok
test_stackinit: big_hole_runtime_partial ok
test_stackinit: small_hole_runtime_all ok
test_stackinit: big_hole_runtime_all ok
test_stackinit: u8 FAIL (uninit bytes: 1)
test_stackinit: u16 FAIL (uninit bytes: 2)
test_stackinit: u32 FAIL (uninit bytes: 4)
test_stackinit: u64 FAIL (uninit bytes: 8)
test_stackinit: char_array FAIL (uninit bytes: 16)
test_stackinit: small_hole ok
test_stackinit: big_hole ok
test_stackinit: user ok
test_stackinit: failures: 5

CONFIG_GCC_PLUGIN_STACKINIT=y
This initializes all variables, but has no special padding handling:

test_stackinit: small_hole_static_all FAIL (uninit bytes: 3)
test_stackinit: big_hole_static_all FAIL (uninit bytes: 61)
test_stackinit: small_hole_dynamic_all FAIL (uninit bytes: 3)
test_stackinit: big_hole_dynamic_all FAIL (uninit bytes: 61)
test_stackinit: small_hole_runtime_partial ok
test_stackinit: big_hole_runtime_partial ok
test_stackinit: small_hole_runtime_all ok
test_stackinit: big_hole_runtime_all ok
test_stackinit: u8 ok
test_stackinit: u16 ok
test_stackinit: u32 ok
test_stackinit: u64 ok
test_stackinit: char_array ok
test_stackinit: small_hole ok
test_stackinit: big_hole ok
test_stackinit: user ok
test_stackinit: failures: 4

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 lib/Kconfig.debug    |   9 ++
 lib/Makefile         |   1 +
 lib/test_stackinit.c | 327 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 337 insertions(+)
 create mode 100644 lib/test_stackinit.c

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index d4df5b24d75e..09788afcccc9 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -2001,6 +2001,15 @@ config TEST_OBJAGG
 
 	  If unsure, say N.
 
+config TEST_STACKINIT
+	tristate "Test level of stack variable initialization"
+	help
+	  Test if the kernel is zero-initializing stack variables
+	  from CONFIG_GCC_PLUGIN_STACKINIT, CONFIG_GCC_PLUGIN_STRUCTLEAK,
+	  and/or GCC_PLUGIN_STRUCTLEAK_BYREF_ALL.
+
+	  If unsure, say N.
+
 endif # RUNTIME_TESTING_MENU
 
 config MEMTEST
diff --git a/lib/Makefile b/lib/Makefile
index e1b59da71418..c81a66d4d00d 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -76,6 +76,7 @@ obj-$(CONFIG_TEST_KMOD) += test_kmod.o
 obj-$(CONFIG_TEST_DEBUG_VIRTUAL) += test_debug_virtual.o
 obj-$(CONFIG_TEST_MEMCAT_P) += test_memcat_p.o
 obj-$(CONFIG_TEST_OBJAGG) += test_objagg.o
+obj-$(CONFIG_TEST_STACKINIT) += test_stackinit.o
 
 ifeq ($(CONFIG_DEBUG_KOBJECT),y)
 CFLAGS_kobject.o += -DDEBUG
diff --git a/lib/test_stackinit.c b/lib/test_stackinit.c
new file mode 100644
index 000000000000..e2ff56a1002a
--- /dev/null
+++ b/lib/test_stackinit.c
@@ -0,0 +1,327 @@
+// SPDX-Licenses: GPLv2
+/*
+ * Test cases for -finit-local-vars and CONFIG_GCC_PLUGIN_STACKINIT.
+ */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/string.h>
+
+/* Exfiltration buffer. */
+#define MAX_VAR_SIZE	128
+static char check_buf[MAX_VAR_SIZE];
+
+/* Character array to trigger stack protector in all functions. */
+#define VAR_BUFFER	 32
+
+/* Volatile mask to convince compiler to copy memory with 0xff. */
+static volatile u8 forced_mask = 0xff;
+
+/* Location and size tracking to validate fill and test are colocated. */
+static void *fill_start, *target_start;
+static size_t fill_size, target_size;
+
+static bool range_contains(char *haystack_start, size_t haystack_size,
+			   char *needle_start, size_t needle_size)
+{
+	if (needle_start >= haystack_start &&
+	    needle_start + needle_size <= haystack_start + haystack_size)
+		return true;
+	return false;
+}
+
+#define DO_NOTHING_TYPE_SCALAR(var_type)	var_type
+#define DO_NOTHING_TYPE_STRING(var_type)	void
+#define DO_NOTHING_TYPE_STRUCT(var_type)	void
+
+#define DO_NOTHING_RETURN_SCALAR(ptr)		*(ptr)
+#define DO_NOTHING_RETURN_STRING(ptr)		/**/
+#define DO_NOTHING_RETURN_STRUCT(ptr)		/**/
+
+#define DO_NOTHING_CALL_SCALAR(var, name)			\
+		(var) = do_nothing_ ## name(&(var))
+#define DO_NOTHING_CALL_STRING(var, name)			\
+		do_nothing_ ## name(var)
+#define DO_NOTHING_CALL_STRUCT(var, name)			\
+		do_nothing_ ## name(&(var))
+
+#define FETCH_ARG_SCALAR(var)		&var
+#define FETCH_ARG_STRING(var)		var
+#define FETCH_ARG_STRUCT(var)		&var
+
+#define FILL_SIZE_SCALAR		1
+#define FILL_SIZE_STRING		16
+#define FILL_SIZE_STRUCT		1
+
+#define INIT_CLONE_SCALAR		/**/
+#define INIT_CLONE_STRING		[FILL_SIZE_STRING]
+#define INIT_CLONE_STRUCT		/**/
+
+#define INIT_SCALAR_NONE		/**/
+#define INIT_SCALAR_ZERO		= 0
+
+#define INIT_STRING_NONE		[FILL_SIZE_STRING] /**/
+#define INIT_STRING_ZERO		[FILL_SIZE_STRING] = { }
+
+#define INIT_STRUCT_NONE		/**/
+#define INIT_STRUCT_ZERO		= { }
+#define INIT_STRUCT_STATIC_PARTIAL	= { .two = 0, }
+#define INIT_STRUCT_STATIC_ALL		= { .one = arg->one,		\
+					    .two = arg->two,		\
+					    .three = arg->three,	\
+					    .four = arg->four,		\
+					}
+#define INIT_STRUCT_DYNAMIC_PARTIAL	= { .two = arg->two, }
+#define INIT_STRUCT_DYNAMIC_ALL		= { .one = arg->one,		\
+					    .two = arg->two,		\
+					    .three = arg->three,	\
+					    .four = arg->four,		\
+					}
+#define INIT_STRUCT_RUNTIME_PARTIAL	;				\
+					var.two = 0
+#define INIT_STRUCT_RUNTIME_ALL		;				\
+					var.one = 0;			\
+					var.two = 0;			\
+					var.three = 0;			\
+					memset(&var.four, 0,		\
+					       sizeof(var.four))
+
+/*
+ * @name: unique string name for the test
+ * @var_type: type to be tested for zeroing initialization
+ * @which: is this a SCALAR or a STRUCT type?
+ * @init_level: what kind of initialization is performed
+ */
+#define DEFINE_TEST(name, var_type, which, init_level)		\
+static noinline int fill_ ## name(unsigned long sp)		\
+{								\
+	char buf[VAR_BUFFER +					\
+		 sizeof(var_type) * FILL_SIZE_ ## which * 4];	\
+								\
+	fill_start = buf;					\
+	fill_size = sizeof(buf);				\
+	/* Fill variable with 0xFF. */				\
+	memset(fill_start, (char)((sp && 0xff) | forced_mask),	\
+	       fill_size);					\
+								\
+	return (int)buf[0] | (int)buf[sizeof(buf)-1];		\
+}								\
+/* no-op to force compiler into ignoring "uninitialized" vars */\
+static noinline DO_NOTHING_TYPE_ ## which(var_type)		\
+do_nothing_ ## name(var_type *ptr)				\
+{								\
+	/* Will always be true, but compiler doesn't know. */	\
+	if ((unsigned long)ptr > 0x2)				\
+		return DO_NOTHING_RETURN_ ## which(ptr);	\
+	else							\
+		return DO_NOTHING_RETURN_ ## which(ptr + 1);	\
+}								\
+static noinline int fetch_ ## name(unsigned long sp,		\
+				   var_type *arg)		\
+{								\
+	char buf[VAR_BUFFER];					\
+	var_type var INIT_ ## which ## _ ## init_level;		\
+								\
+	target_start = &var;					\
+	target_size = sizeof(var);				\
+	/*							\
+	 * Keep this buffer around to make sure we've got a	\
+	 * stack frame of SOME kind...				\
+	 */							\
+	memset(buf, (char)(sp && 0xff), sizeof(buf));		\
+								\
+	/* Silence "never initialized" warnings. */		\
+	DO_NOTHING_CALL_ ## which(var, name);			\
+								\
+	/* Exfiltrate "var" or field of "var". */		\
+	memcpy(check_buf, target_start, target_size);		\
+								\
+	return (int)buf[0] | (int)buf[sizeof(buf) - 1];		\
+}								\
+/* Returns 0 on success, 1 on failure. */			\
+static noinline int test_ ## name (void)			\
+{								\
+	var_type zero INIT_CLONE_ ## which;			\
+	int ignored;						\
+	u8 sum = 0, i;						\
+								\
+	/* Notice when a new test is larger than expected. */	\
+	BUILD_BUG_ON(sizeof(zero) > MAX_VAR_SIZE);		\
+	/* Clear entire check buffer for later bit tests. */	\
+	memset(check_buf, 0x00, sizeof(check_buf));		\
+								\
+	/* Fill clone type with zero for per-field init. */	\
+	memset(&zero, 0x00, sizeof(zero));			\
+	/* Fill stack with 0xFF. */				\
+	ignored = fill_ ##name((unsigned long)&ignored);	\
+	/* Extract stack-defined variable contents. */		\
+	ignored = fetch_ ##name((unsigned long)&ignored,	\
+				FETCH_ARG_ ## which(zero));	\
+								\
+	/* Validate that compiler lined up fill and target. */	\
+	if (!range_contains(fill_start, fill_size,		\
+			    target_start, target_size)) {	\
+		pr_err(#name ": stack fill missed target!?\n");	\
+		pr_err(#name ": fill %zu wide\n", fill_size);	\
+		pr_err(#name ": target offset by %ld\n",	\
+			(ssize_t)(uintptr_t)fill_start -	\
+			(ssize_t)(uintptr_t)target_start);	\
+		return 1;					\
+	}							\
+								\
+	/* Look for any set bits in the check region. */	\
+	for (i = 0; i < sizeof(check_buf); i++)			\
+		sum += (check_buf[i] != 0);			\
+								\
+	if (sum == 0)						\
+		pr_info(#name " ok\n");				\
+	else							\
+		pr_warn(#name " FAIL (uninit bytes: %d)\n",	\
+			sum);					\
+								\
+	return (sum != 0);					\
+}
+
+/* Structure with no padding. */
+struct test_packed {
+	unsigned long one;
+	unsigned long two;
+	unsigned long three;
+	unsigned long four;
+};
+
+/* Simple structure with padding likely to be covered by compiler. */
+struct test_small_hole {
+	size_t one;
+	char two;
+	/* 3 byte padding hole here. */
+	int three;
+	unsigned long four;
+};
+
+/* Try to trigger unhandled padding in a structure. */
+struct test_aligned {
+	u32 internal1;
+	u64 internal2;
+} __aligned(64);
+
+struct test_big_hole {
+	u8 one;
+	u8 two;
+	u8 three;
+	/* 61 byte padding hole here. */
+	struct test_aligned four;
+} __aligned(64);
+
+/* Test if STRUCTLEAK is clearing structs with __user fields. */
+struct test_user {
+	u8 one;
+	char __user *two;
+	unsigned long three;
+	unsigned long four;
+};
+
+/* These should be fully initialized all the time! */
+DEFINE_TEST(u8_zero, u8, SCALAR, ZERO);
+DEFINE_TEST(u16_zero, u16, SCALAR, ZERO);
+DEFINE_TEST(u32_zero, u32, SCALAR, ZERO);
+DEFINE_TEST(u64_zero, u64, SCALAR, ZERO);
+DEFINE_TEST(char_array_zero, unsigned char, STRING, ZERO);
+
+DEFINE_TEST(packed_zero, struct test_packed, STRUCT, ZERO);
+DEFINE_TEST(small_hole_zero, struct test_small_hole, STRUCT, ZERO);
+DEFINE_TEST(big_hole_zero, struct test_big_hole, STRUCT, ZERO);
+
+/* Static initialization: padding may be left uninitialized. */
+DEFINE_TEST(packed_static_partial, struct test_packed, STRUCT, STATIC_PARTIAL);
+DEFINE_TEST(small_hole_static_partial, struct test_small_hole, STRUCT, STATIC_PARTIAL);
+DEFINE_TEST(big_hole_static_partial, struct test_big_hole, STRUCT, STATIC_PARTIAL);
+
+DEFINE_TEST(small_hole_static_all, struct test_small_hole, STRUCT, STATIC_ALL);
+DEFINE_TEST(big_hole_static_all, struct test_big_hole, STRUCT, STATIC_ALL);
+
+/* Dynamic initialization: padding may be left uninitialized. */
+DEFINE_TEST(small_hole_dynamic_partial, struct test_small_hole, STRUCT, DYNAMIC_PARTIAL);
+DEFINE_TEST(big_hole_dynamic_partial, struct test_big_hole, STRUCT, DYNAMIC_PARTIAL);
+
+DEFINE_TEST(small_hole_dynamic_all, struct test_small_hole, STRUCT, DYNAMIC_ALL);
+DEFINE_TEST(big_hole_dynamic_all, struct test_big_hole, STRUCT, DYNAMIC_ALL);
+
+/* Runtime initialization: padding may be left uninitialized. */
+DEFINE_TEST(small_hole_runtime_partial, struct test_small_hole, STRUCT, RUNTIME_PARTIAL);
+DEFINE_TEST(big_hole_runtime_partial, struct test_big_hole, STRUCT, RUNTIME_PARTIAL);
+
+DEFINE_TEST(small_hole_runtime_all, struct test_small_hole, STRUCT, RUNTIME_ALL);
+DEFINE_TEST(big_hole_runtime_all, struct test_big_hole, STRUCT, RUNTIME_ALL);
+
+/* No initialization without compiler instrumentation. */
+DEFINE_TEST(u8, u8, SCALAR, NONE);
+DEFINE_TEST(u16, u16, SCALAR, NONE);
+DEFINE_TEST(u32, u32, SCALAR, NONE);
+DEFINE_TEST(u64, u64, SCALAR, NONE);
+DEFINE_TEST(char_array, unsigned char, STRING, NONE);
+DEFINE_TEST(small_hole, struct test_small_hole, STRUCT, NONE);
+DEFINE_TEST(big_hole, struct test_big_hole, STRUCT, NONE);
+DEFINE_TEST(user, struct test_user, STRUCT, NONE);
+
+static int __init test_stackinit_init(void)
+{
+	unsigned int failures = 0;
+
+	/* These are explicitly initialized and should always pass. */
+	failures += test_u8_zero();
+	failures += test_u16_zero();
+	failures += test_u32_zero();
+	failures += test_u64_zero();
+	failures += test_char_array_zero();
+	failures += test_small_hole_zero();
+	failures += test_big_hole_zero();
+	failures += test_packed_zero();
+
+	/* Padding here appears to be accidentally always initialized. */
+	failures += test_small_hole_dynamic_partial();
+	failures += test_big_hole_dynamic_partial();
+	failures += test_packed_static_partial();
+
+	/* Padding initialization depends on compiler behaviors. */
+	failures += test_small_hole_static_partial();
+	failures += test_big_hole_static_partial();
+	failures += test_small_hole_static_all();
+	failures += test_big_hole_static_all();
+	failures += test_small_hole_dynamic_all();
+	failures += test_big_hole_dynamic_all();
+	failures += test_small_hole_runtime_partial();
+	failures += test_big_hole_runtime_partial();
+	failures += test_small_hole_runtime_all();
+	failures += test_big_hole_runtime_all();
+
+	/* STACKINIT should cover everything from here down. */
+	failures += test_u8();
+	failures += test_u16();
+	failures += test_u32();
+	failures += test_u64();
+	failures += test_char_array();
+
+	/* STRUCTLEAK_BYREF_ALL should cover from here down. */
+	failures += test_small_hole();
+	failures += test_big_hole();
+
+	/* STRUCTLEAK should cover this. */
+	failures += test_user();
+
+	if (failures == 0)
+		pr_info("all tests passed!\n");
+	else
+		pr_err("failures: %u\n", failures);
+
+	return failures ? -EINVAL : 0;
+}
+module_init(test_stackinit_init);
+
+static void __exit test_stackinit_exit(void)
+{ }
+module_exit(test_stackinit_exit);
+
+MODULE_LICENSE("GPL");
-- 
2.17.1
