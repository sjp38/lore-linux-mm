Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2CA8F6B026C
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 16:51:22 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id s2so4021447ioa.17
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 13:51:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a195sor1782150itd.29.2017.11.29.13.51.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Nov 2017 13:51:21 -0800 (PST)
From: Paul Lawrence <paullawrence@google.com>
Subject: [PATCH v2 4/5] kasan: support LLVM-style asan parameters
Date: Wed, 29 Nov 2017 13:50:49 -0800
Message-Id: <20171129215050.158653-5-paullawrence@google.com>
In-Reply-To: <20171129215050.158653-1-paullawrence@google.com>
References: <20171129215050.158653-1-paullawrence@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <mmarek@suse.com>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>, Paul Lawrence <paullawrence@google.com>

Use cc-option to figure out whether the compiler's sanitizer uses
LLVM-style parameters ("-mllvm -asan-foo=bar") or GCC-style parameters
("--param asan-foo=bar").

Signed-off-by: Greg Hackmann <ghackmann@google.com>
Signed-off-by: Paul Lawrence <paullawrence@google.com>

---
 scripts/Makefile.kasan | 39 +++++++++++++++++++++++++++------------
 1 file changed, 27 insertions(+), 12 deletions(-)

diff --git a/scripts/Makefile.kasan b/scripts/Makefile.kasan
index 1ce7115aa499..89c5b166adec 100644
--- a/scripts/Makefile.kasan
+++ b/scripts/Makefile.kasan
@@ -10,24 +10,39 @@ KASAN_SHADOW_OFFSET ?= $(CONFIG_KASAN_SHADOW_OFFSET)
 
 CFLAGS_KASAN_MINIMAL := -fsanitize=kernel-address
 
-CFLAGS_KASAN := $(call cc-option, -fsanitize=kernel-address \
-		-fasan-shadow-offset=$(KASAN_SHADOW_OFFSET) \
-		--param asan-stack=1 --param asan-globals=1 \
-		--param asan-instrumentation-with-call-threshold=$(call_threshold))
-
 ifeq ($(call cc-option, $(CFLAGS_KASAN_MINIMAL) -Werror),)
    ifneq ($(CONFIG_COMPILE_TEST),y)
         $(warning Cannot use CONFIG_KASAN: \
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
+   CFLAGS_KASAN_SHADOW := \
+		$(call cc-option, -fsanitize=kernel-address \
+			-fasan-shadow-offset=$(KASAN_SHADOW_OFFSET))
+   ifeq ($(CFLAGS_KASAN_SHADOW),)
+      CFLAGS_KASAN := $(CFLAGS_KASAN_MINIMAL)
+   else
+      CFLAGS_KASAN := $(CFLAGS_KASAN_SHADOW)
+   endif
+
+   # Now add all the compiler specific options that are valid standalone
+   CFLAGS_KASAN := $(CFLAGS_KASAN) \
+	$(call cc-option, --param asan-globals=1) \
+	$(call cc-option, --param asan-instrument-allocas=1) \
+	$(call cc-option, --param asan-instrumentation-with-call-threshold=$(call_threshold)) \
+	$(call cc-option, -mllvm -asan-mapping-offset=$(KASAN_SHADOW_OFFSET)) \
+	$(call cc-option, -mllvm -asan-stack=1) \
+	$(call cc-option, -mllvm -asan-globals=1) \
+	$(call cc-option, -mllvm -asan-use-after-scope=1) \
+	$(call cc-option, -mllvm -asan-instrumentation-with-call-threshold=$(call_threshold))
+
+
+   # This option crashes on gcc 4.9, and is not available on clang
+   ifeq ($(call cc-ifversion, -ge, 0500, y), y)
+        CFLAGS_KASAN := $(CFLAGS_KASAN) $(call cc-option, --param asan-stack=1)
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
