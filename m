Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1DC186B0261
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 11:33:29 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id r88so5196952pfi.23
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 08:33:29 -0800 (PST)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40112.outbound.protection.outlook.com. [40.107.4.112])
        by mx.google.com with ESMTPS id s78si3507991pfj.225.2017.11.30.08.33.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Nov 2017 08:33:27 -0800 (PST)
Subject: Re: [PATCH v2 4/5] kasan: support LLVM-style asan parameters
References: <20171129215050.158653-1-paullawrence@google.com>
 <20171129215050.158653-5-paullawrence@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <7e9f3194-17c1-9dc5-9392-748801c831bd@virtuozzo.com>
Date: Thu, 30 Nov 2017 19:36:54 +0300
MIME-Version: 1.0
In-Reply-To: <20171129215050.158653-5-paullawrence@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Lawrence <paullawrence@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <mmarek@suse.com>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>

On 11/30/2017 12:50 AM, Paul Lawrence wrote:
> Use cc-option to figure out whether the compiler's sanitizer uses
> LLVM-style parameters ("-mllvm -asan-foo=bar") or GCC-style parameters
> ("--param asan-foo=bar").
> 
> Signed-off-by: Greg Hackmann <ghackmann@google.com>
> Signed-off-by: Paul Lawrence <paullawrence@google.com>
> 
> ---
>  scripts/Makefile.kasan | 39 +++++++++++++++++++++++++++------------
>  1 file changed, 27 insertions(+), 12 deletions(-)
> 

It looks rather messy. Try the following patch.
Note, that I didn't add asan-instrument-allocas=1 because it has nothing to do
with LLVM-style params support.
asan-instrument-allocas should probably be in the patch that adds alloca() support.


From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH] kasan/Makefile: Support LLVM style asan parameters.

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
index 1ce7115aa499..2af5977c394d 100644
--- a/scripts/Makefile.kasan
+++ b/scripts/Makefile.kasan
@@ -10,10 +10,7 @@ KASAN_SHADOW_OFFSET ?= $(CONFIG_KASAN_SHADOW_OFFSET)
 
 CFLAGS_KASAN_MINIMAL := -fsanitize=kernel-address
 
-CFLAGS_KASAN := $(call cc-option, -fsanitize=kernel-address \
-		-fasan-shadow-offset=$(KASAN_SHADOW_OFFSET) \
-		--param asan-stack=1 --param asan-globals=1 \
-		--param asan-instrumentation-with-call-threshold=$(call_threshold))
+cc-param = $(call cc-option, --param $(1)) $(call cc-option, -mllvm -$(1))
 
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
+   ifeq ($(CFLAGS_KASAN_SHADOW),)
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
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
