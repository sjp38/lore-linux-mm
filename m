Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1CC516B0006
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 13:29:37 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id i66so1581889wmc.1
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 10:29:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 7sor1873236wrp.21.2018.04.12.10.29.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Apr 2018 10:29:35 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH] kasan: add no_sanitize attribute for clang builds
Date: Thu, 12 Apr 2018 19:29:31 +0200
Message-Id: <4ad725cc903f8534f8c8a60f0daade5e3d674f8d.1523554166.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, David Woodhouse <dwmw@amazon.co.uk>, Andrey Konovalov <andreyknvl@google.com>, Will Deacon <will.deacon@arm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paul Lawrence <paullawrence@google.com>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Cc: Kostya Serebryany <kcc@google.com>

KASAN uses the __no_sanitize_address macro to disable instrumentation
of particular functions. Right now it's defined only for GCC build,
which causes false positives when clang is used.

This patch adds a definition for clang.

Note, that clang's revision 329612 or higher is required.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 include/linux/compiler-clang.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/compiler-clang.h b/include/linux/compiler-clang.h
index ceb96ecab96e..5a1d8580febe 100644
--- a/include/linux/compiler-clang.h
+++ b/include/linux/compiler-clang.h
@@ -25,6 +25,11 @@
 #define __SANITIZE_ADDRESS__
 #endif
 
+#ifdef CONFIG_KASAN
+#undef __no_sanitize_address
+#define __no_sanitize_address __attribute__((no_sanitize("address")))
+#endif
+
 /* Clang doesn't have a way to turn it off per-function, yet. */
 #ifdef __noretpoline
 #undef __noretpoline
-- 
2.17.0.484.g0c8726318c-goog
