Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 49B1E6B02F3
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 12:23:41 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w62so9490893wrc.9
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 09:23:41 -0700 (PDT)
Received: from mail-wr0-x233.google.com (mail-wr0-x233.google.com. [2a00:1450:400c:c0c::233])
        by mx.google.com with ESMTPS id o3si5134660edl.533.2017.08.30.09.23.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 09:23:40 -0700 (PDT)
Received: by mail-wr0-x233.google.com with SMTP id 40so19375768wrv.5
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 09:23:39 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH 2/3] Makefile: support flag -fsanitizer-coverage=trace-cmp
Date: Wed, 30 Aug 2017 18:23:30 +0200
Message-Id: <81a8c78be80eb29f339959b0076f7cb7114e0bcb.1504109849.git.dvyukov@google.com>
In-Reply-To: <cover.1504109849.git.dvyukov@google.com>
References: <cover.1504109849.git.dvyukov@google.com>
In-Reply-To: <cover.1504109849.git.dvyukov@google.com>
References: <cover.1504109849.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: tchibo@google.com, Mark Rutland <mark.rutland@arm.com>, Alexander Popov <alex.popov@linux.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Kees Cook <keescook@chromium.org>, Vegard Nossum <vegard.nossum@oracle.com>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, syzkaller@googlegroups.com, linux-kernel@vger.kernel.org

From: Victor Chibotaru <tchibo@google.com>

The flag enables Clang instrumentation of comparison operations
(currently not supported by GCC). This instrumentation is needed by the
new KCOV device to collect comparison operands.

Signed-off-by: Victor Chibotaru <tchibo@google.com>
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
---
 Makefile              | 5 +++--
 lib/Kconfig.debug     | 8 ++++++++
 scripts/Makefile.kcov | 6 ++++++
 scripts/Makefile.lib  | 6 ++++++
 4 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/Makefile b/Makefile
index f9703f3223eb..bb117c42a785 100644
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
index d7e3f0bfe91e..85fc0db2e8af 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -777,6 +777,14 @@ config KCOV
 
 	  For more details, see Documentation/dev-tools/kcov.rst.
 
+config KCOV_ENABLE_COMPARISONS
+	bool "Enable comparison operands collection by KCOV"
+	depends on KCOV
+	default n
+	help
+	  KCOV also exposes operands of every comparison in instrumented code.
+	  Note: currently only available if compiled with Clang.
+
 config KCOV_INSTRUMENT_ALL
 	bool "Instrument all code by default"
 	depends on KCOV
diff --git a/scripts/Makefile.kcov b/scripts/Makefile.kcov
new file mode 100644
index 000000000000..5d6e644cefed
--- /dev/null
+++ b/scripts/Makefile.kcov
@@ -0,0 +1,6 @@
+ifeq ($(CONFIG_KCOV_ENABLE_COMPARISONS),y)
+ifneq ($(cc-name),clang)
+  $(warning Cannot use CONFIG_KCOV_ENABLE_COMPARISONS: \
+            -fsanitize=trace-cmp is not supported by compiler)
+endif
+endif
diff --git a/scripts/Makefile.lib b/scripts/Makefile.lib
index 58c05e5d9870..bb38cd33e15c 100644
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
2.14.1.581.gf28d330327-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
