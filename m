Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 912506B0009
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 12:07:25 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id p13so3884238wmc.6
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 09:07:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n191sor1473267wmd.57.2018.03.01.09.07.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Mar 2018 09:07:24 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH] kasan, arm64: clean up KASAN_SHADOW_SCALE_SHIFT usage
Date: Thu,  1 Mar 2018 18:07:12 +0100
Message-Id: <44281e784702443f06edb837ec672984783a9621.1519923749.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Cc: Kostya Serebryany <kcc@google.com>, Andrey Konovalov <andreyknvl@google.com>

This is a follow up patch to the series I sent recently that cleans up
KASAN_SHADOW_SCALE_SHIFT usage (which value was hardcoded and scattered
all over the code). This fixes the one place that I forgot to fix.

The change is purely aesthetical, instead of hardcoding the value for
KASAN_SHADOW_SCALE_SHIFT in arch/arm64/Makefile, an appropriate variable
is declared and used.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 arch/arm64/Makefile | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/arch/arm64/Makefile b/arch/arm64/Makefile
index b481b4a7c011..4bb18aee4846 100644
--- a/arch/arm64/Makefile
+++ b/arch/arm64/Makefile
@@ -97,12 +97,14 @@ else
 TEXT_OFFSET := 0x00080000
 endif
 
-# KASAN_SHADOW_OFFSET = VA_START + (1 << (VA_BITS - 3)) - (1 << 61)
+# KASAN_SHADOW_OFFSET = VA_START + (1 << (VA_BITS - KASAN_SHADOW_SCALE_SHIFT))
+#				 - (1 << (64 - KASAN_SHADOW_SCALE_SHIFT))
 # in 32-bit arithmetic
+KASAN_SHADOW_SCALE_SHIFT := 3
 KASAN_SHADOW_OFFSET := $(shell printf "0x%08x00000000\n" $$(( \
-			(0xffffffff & (-1 << ($(CONFIG_ARM64_VA_BITS) - 32))) \
-			+ (1 << ($(CONFIG_ARM64_VA_BITS) - 32 - 3)) \
-			- (1 << (64 - 32 - 3)) )) )
+	(0xffffffff & (-1 << ($(CONFIG_ARM64_VA_BITS) - 32))) \
+	+ (1 << ($(CONFIG_ARM64_VA_BITS) - 32 - $(KASAN_SHADOW_SCALE_SHIFT))) \
+	- (1 << (64 - 32 - $(KASAN_SHADOW_SCALE_SHIFT))) )) )
 
 export	TEXT_OFFSET GZFLAGS
 
-- 
2.16.2.395.g2e18187dfd-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
