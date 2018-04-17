Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E3D466B0007
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 08:26:52 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z7so5524390wrg.11
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 05:26:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t91sor5722469wrc.27.2018.04.17.05.26.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Apr 2018 05:26:51 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v2] kasan: add no_sanitize attribute for clang builds
Date: Tue, 17 Apr 2018 14:26:47 +0200
Message-Id: <c79aa31a2a2790f6131ed607c58b0dd45dd62a6c.1523967959.git.andreyknvl@google.com>
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

Changes since v1:
- Removed redundant #ifdef CONFIG_KASAN check.

 include/linux/compiler-clang.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/compiler-clang.h b/include/linux/compiler-clang.h
index ceb96ecab96e..7d98e263e048 100644
--- a/include/linux/compiler-clang.h
+++ b/include/linux/compiler-clang.h
@@ -25,6 +25,9 @@
 #define __SANITIZE_ADDRESS__
 #endif
 
+#undef __no_sanitize_address
+#define __no_sanitize_address __attribute__((no_sanitize("address")))
+
 /* Clang doesn't have a way to turn it off per-function, yet. */
 #ifdef __noretpoline
 #undef __noretpoline
-- 
2.17.0.484.g0c8726318c-goog
