Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B813F6B025F
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 05:55:07 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 131so524875wmk.16
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 02:55:07 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h64sor3261923wmd.50.2017.10.11.02.55.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Oct 2017 02:55:06 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v4 2/3] Makefile: support flag -fsanitizer-coverage=trace-cmp
Date: Wed, 11 Oct 2017 11:54:58 +0200
Message-Id: <20171011095459.70721-2-glider@google.com>
In-Reply-To: <20171011095459.70721-1-glider@google.com>
References: <20171011095459.70721-1-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mark.rutland@arm.com, alex.popov@linux.com, aryabinin@virtuozzo.com, quentin.casasnovas@oracle.com, dvyukov@google.com, andreyknvl@google.com, keescook@chromium.org, vegard.nossum@oracle.com
Cc: syzkaller@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Victor Chibotaru <tchibo@google.com>

The flag enables Clang instrumentation of comparison operations
(currently not supported by GCC). This instrumentation is needed by the
new KCOV device to collect comparison operands.

Signed-off-by: Victor Chibotaru <tchibo@google.com>
Signed-off-by: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Alexander Popov <alex.popov@linux.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Vegard Nossum <vegard.nossum@oracle.com>
Cc: Quentin Casasnovas <quentin.casasnovas@oracle.com>
Cc: syzkaller@googlegroups.com
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
Clang instrumentation:
https://clang.llvm.org/docs/SanitizerCoverage.html#tracing-data-flow

v4: - drop CFLAGS_KCOV_COMPS for real (revert scripts/Makefile.lib)
v3: - Andrey Ryabinin's comments: reinstated scripts/Makefile.kcov
      and moved CFLAGS_KCOV there, dropped CFLAGS_KCOV_COMPS
    - allow building with GCC
v2: - updated KCOV_ENABLE_COMPARISONS description
---
 Makefile              |  3 +--
 lib/Kconfig.debug     | 10 ++++++++++
 scripts/Makefile.kcov |  7 +++++++
 3 files changed, 18 insertions(+), 2 deletions(-)
 create mode 100644 scripts/Makefile.kcov

diff --git a/Makefile b/Makefile
index 2835863bdd5a..43f642167d68 100644
--- a/Makefile
+++ b/Makefile
@@ -373,8 +373,6 @@ CFLAGS_KERNEL	=
 AFLAGS_KERNEL	=
 LDFLAGS_vmlinux =
 CFLAGS_GCOV	:= -fprofile-arcs -ftest-coverage -fno-tree-loop-im $(call cc-disable-warning,maybe-uninitialized,)
-CFLAGS_KCOV	:= $(call cc-option,-fsanitize-coverage=trace-pc,)
-
 
 # Use USERINCLUDE when you must reference the UAPI directories only.
 USERINCLUDE    := \
@@ -657,6 +655,7 @@ ifeq ($(shell $(CONFIG_SHELL) $(srctree)/scripts/gcc-goto.sh $(CC) $(KBUILD_CFLA
 	KBUILD_AFLAGS += -DCC_HAVE_ASM_GOTO
 endif
 
+include scripts/Makefile.kcov
 include scripts/Makefile.gcc-plugins
 
 ifdef CONFIG_READABLE_ASM
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 2689b7c50c52..a10eb4e34719 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -759,6 +759,16 @@ config KCOV
 
 	  For more details, see Documentation/dev-tools/kcov.rst.
 
+config KCOV_ENABLE_COMPARISONS
+	bool "Enable comparison operands collection by KCOV"
+	depends on KCOV
+	default n
+	help
+	  KCOV also exposes operands of every comparison in the instrumented
+	  code along with operand sizes and PCs of the comparison instructions.
+	  These operands can be used by fuzzing engines to improve the quality
+	  of fuzzing coverage.
+
 config KCOV_INSTRUMENT_ALL
 	bool "Instrument all code by default"
 	depends on KCOV
diff --git a/scripts/Makefile.kcov b/scripts/Makefile.kcov
new file mode 100644
index 000000000000..5cc72037e423
--- /dev/null
+++ b/scripts/Makefile.kcov
@@ -0,0 +1,7 @@
+ifdef CONFIG_KCOV
+CFLAGS_KCOV	:= $(call cc-option,-fsanitize-coverage=trace-pc,)
+ifeq ($(CONFIG_KCOV_ENABLE_COMPARISONS),y)
+CFLAGS_KCOV += $(call cc-option,-fsanitize-coverage=trace-cmp,)
+endif
+
+endif
-- 
2.15.0.rc0.271.g36b669edcc-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
