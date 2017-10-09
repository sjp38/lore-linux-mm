Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9E17C6B025F
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 11:05:35 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p130so1972521lfe.20
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 08:05:35 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 35sor2813287wrt.66.2017.10.09.08.05.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Oct 2017 08:05:34 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v2 2/3] Makefile: support flag -fsanitizer-coverage=trace-cmp
Date: Mon,  9 Oct 2017 17:05:20 +0200
Message-Id: <20171009150521.82775-2-glider@google.com>
In-Reply-To: <20171009150521.82775-1-glider@google.com>
References: <20171009150521.82775-1-glider@google.com>
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

v2: - updated KCOV_ENABLE_COMPARISONS description
---
 Makefile             |  5 +++--
 lib/Kconfig.debug    | 10 ++++++++++
 scripts/Makefile.lib |  6 ++++++
 3 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/Makefile b/Makefile
index 2835863bdd5a..c2a8e56df748 100644
--- a/Makefile
+++ b/Makefile
@@ -374,7 +374,7 @@ AFLAGS_KERNEL	=
 LDFLAGS_vmlinux =
 CFLAGS_GCOV	:= -fprofile-arcs -ftest-coverage -fno-tree-loop-im $(call cc-disable-warning,maybe-uninitialized,)
 CFLAGS_KCOV	:= $(call cc-option,-fsanitize-coverage=trace-pc,)
-
+CFLAGS_KCOV_COMPS := $(call cc-option,-fsanitize-coverage=trace-cmp,)
 
 # Use USERINCLUDE when you must reference the UAPI directories only.
 USERINCLUDE    := \
@@ -420,7 +420,7 @@ export MAKE AWK GENKSYMS INSTALLKERNEL PERL PYTHON UTS_MACHINE
 export HOSTCXX HOSTCXXFLAGS LDFLAGS_MODULE CHECK CHECKFLAGS
 
 export KBUILD_CPPFLAGS NOSTDINC_FLAGS LINUXINCLUDE OBJCOPYFLAGS LDFLAGS
-export KBUILD_CFLAGS CFLAGS_KERNEL CFLAGS_MODULE CFLAGS_GCOV CFLAGS_KCOV CFLAGS_KASAN CFLAGS_UBSAN
+export KBUILD_CFLAGS CFLAGS_KERNEL CFLAGS_MODULE CFLAGS_GCOV CFLAGS_KCOV CFLAGS_KCOV_COMPS CFLAGS_KASAN CFLAGS_UBSAN
 export KBUILD_AFLAGS AFLAGS_KERNEL AFLAGS_MODULE
 export KBUILD_AFLAGS_MODULE KBUILD_CFLAGS_MODULE KBUILD_LDFLAGS_MODULE
 export KBUILD_AFLAGS_KERNEL KBUILD_CFLAGS_KERNEL
@@ -822,6 +822,7 @@ KBUILD_CFLAGS   += $(call cc-option,-Werror=designated-init)
 KBUILD_ARFLAGS := $(call ar-option,D)
 
 include scripts/Makefile.kasan
+include scripts/Makefile.kcov
 include scripts/Makefile.extrawarn
 include scripts/Makefile.ubsan
 
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
diff --git a/scripts/Makefile.lib b/scripts/Makefile.lib
index 5e975fee0f5b..7ddd5932c832 100644
--- a/scripts/Makefile.lib
+++ b/scripts/Makefile.lib
@@ -142,6 +142,12 @@ _c_flags += $(if $(patsubst n%,, \
 	$(CFLAGS_KCOV))
 endif
 
+ifeq ($(CONFIG_KCOV_ENABLE_COMPARISONS),y)
+_c_flags += $(if $(patsubst n%,, \
+	$(KCOV_INSTRUMENT_$(basetarget).o)$(KCOV_INSTRUMENT)$(CONFIG_KCOV_INSTRUMENT_ALL)), \
+	$(CFLAGS_KCOV_COMPS))
+endif
+
 # If building the kernel in a separate objtree expand all occurrences
 # of -Idir to -I$(srctree)/dir except for absolute paths (starting with '/').
 
-- 
2.14.2.920.gcf0c67979c-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
