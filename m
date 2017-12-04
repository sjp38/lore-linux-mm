Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id C67C06B0268
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 14:17:46 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id g69so13372444ita.9
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 11:17:46 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m12sor1219579iob.317.2017.12.04.11.17.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Dec 2017 11:17:45 -0800 (PST)
From: Paul Lawrence <paullawrence@google.com>
Subject: [PATCH v4 2/5] kasan/Makefile: Support LLVM style asan parameters.
Date: Mon,  4 Dec 2017 11:17:32 -0800
Message-Id: <20171204191735.132544-3-paullawrence@google.com>
In-Reply-To: <20171204191735.132544-1-paullawrence@google.com>
References: <20171204191735.132544-1-paullawrence@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>, Paul Lawrence <paullawrence@google.com>

From: Andrey Ryabinin <aryabinin@virtuozzo.com>

LLVM doesn't understand GCC-style paramters ("--param asan-foo=bar"),
thus we currently we don't use inline/globals/stack instrumentation
when building the kernel with clang.

Add support for LLVM-style parameters ("-mllvm -asan-foo=bar") to
enable all KASAN features.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Signed-off-by: Paul Lawrence <paullawrence@google.com>
---
 scripts/Makefile.kasan | 29 ++++++++++++++++++-----------
 1 file changed, 18 insertions(+), 11 deletions(-)

diff --git a/scripts/Makefile.kasan b/scripts/Makefile.kasan
index 1ce7115aa499..d5a1a4b6d079 100644
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
+   ifeq ($(strip $(CFLAGS_KASAN_SHADOW)),)
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
