Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 234AE6B0261
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 16:37:02 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id n42so9732488ioe.12
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 13:37:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m187sor700411iof.256.2017.12.01.13.37.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Dec 2017 13:37:01 -0800 (PST)
From: Paul Lawrence <paullawrence@google.com>
Subject: [PATCH v3 2/5] kasan/Makefile: Support LLVM style asan parameters.
Date: Fri,  1 Dec 2017 13:36:40 -0800
Message-Id: <20171201213643.2506-3-paullawrence@google.com>
In-Reply-To: <20171201213643.2506-1-paullawrence@google.com>
References: <20171201213643.2506-1-paullawrence@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>, Paul Lawrence <paullawrence@google.com>

LLVM doesn't understand GCC-style paramters ("--param asan-foo=bar"),
thus we currently we don't use inline/globals/stack instrumentation
when building the kernel with clang.

Add support for LLVM-style parameters ("-mllvm -asan-foo=bar") to
enable all KASAN features.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 scripts/Makefile.kasan | 29 ++++++++++++++++++-----------
 1 file changed, 18 insertions(+), 11 deletions(-)

diff --git a/scripts/Makefile.kasan b/scripts/Makefile.kasan
index 1ce7115aa499..7c00be9216f4 100644
--- a/scripts/Makefile.kasan
+++ b/scripts/Makefile.kasan
@@ -10,10 +10,7 @@ KASAN_SHADOW_OFFSET ?= $(CONFIG_KASAN_SHADOW_OFFSET)
 
 CFLAGS_KASAN_MINIMAL := -fsanitize=kernel-address
 
-CFLAGS_KASAN := $(call cc-option, -fsanitize=kernel-address \
-		-fasan-shadow-offset=$(KASAN_SHADOW_OFFSET) \
-		--param asan-stack=1 --param asan-globals=1 \
-		--param asan-instrumentation-with-call-threshold=$(call_threshold))
+cc-param = $(call cc-option, -mllvm -$(1), $(call cc-option, --param $(1)))
 
 ifeq ($(call cc-option, $(CFLAGS_KASAN_MINIMAL) -Werror),)
    ifneq ($(CONFIG_COMPILE_TEST),y)
@@ -21,13 +18,23 @@ ifeq ($(call cc-option, $(CFLAGS_KASAN_MINIMAL) -Werror),)
             -fsanitize=kernel-address is not supported by compiler)
    endif
 else
-    ifeq ($(CFLAGS_KASAN),)
-        ifneq ($(CONFIG_COMPILE_TEST),y)
-            $(warning CONFIG_KASAN: compiler does not support all options.\
-                Trying minimal configuration)
-        endif
-        CFLAGS_KASAN := $(CFLAGS_KASAN_MINIMAL)
-    endif
+   # -fasan-shadow-offset fails without -fsanitize
+   CFLAGS_KASAN_SHADOW := $(call cc-option, -fsanitize=kernel-address \
+			-fasan-shadow-offset=$(KASAN_SHADOW_OFFSET), \
+			$(call cc-option, -fsanitize=kernel-address \
+			-mllvm -asan-mapping-offset=$(KASAN_SHADOW_OFFSET)))
+
+   ifeq ("$(CFLAGS_KASAN_SHADOW)"," ")
+      CFLAGS_KASAN := $(CFLAGS_KASAN_MINIMAL)
+   else
+      # Now add all the compiler specific options that are valid standalone
+      CFLAGS_KASAN := $(CFLAGS_KASAN_SHADOW) \
+	$(call cc-param,asan-globals=1) \
+	$(call cc-param,asan-instrumentation-with-call-threshold=$(call_threshold)) \
+	$(call cc-param,asan-stack=1) \
+	$(call cc-param,asan-use-after-scope=1)
+   endif
+
 endif
 
 CFLAGS_KASAN += $(call cc-option, -fsanitize-address-use-after-scope)
-- 
2.15.0.531.g2ccb3012c9-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
