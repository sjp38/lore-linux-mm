Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0447A8E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 08:40:22 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id p16so683005wmc.5
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 05:40:21 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.130])
        by mx.google.com with ESMTPS id a16si21214wmd.137.2018.12.11.05.40.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 05:40:20 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] kasan: fix kasan_check_read/write definitions
Date: Tue, 11 Dec 2018 14:34:35 +0100
Message-Id: <20181211133453.2835077-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Anders Roxell <anders.roxell@linaro.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Arnd Bergmann <arnd@arndb.de>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrey Konovalov <andreyknvl@google.com>, Stephen Rothwell <sfr@canb.auug.org.au>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Building little-endian allmodconfig kernels on arm64 started failing
with the generated atomic.h implementation, since we now try to call
kasan helpers from the EFI stub:

aarch64-linux-gnu-ld: drivers/firmware/efi/libstub/arm-stub.stub.o: in function `atomic_set':
include/generated/atomic-instrumented.h:44: undefined reference to `__efistub_kasan_check_write'

I suspect that we get similar problems in other files that explicitly
disable KASAN for some reason but call atomic_t based helper functions.

We can fix this by checking the predefined __SANITIZE_ADDRESS__ macro
that the compiler sets instead of checking CONFIG_KASAN, but this in turn
requires a small hack in mm/kasan/common.c so we do see the extern
declaration there instead of the inline function.

Fixes: b1864b828644 ("locking/atomics: build atomic headers as required")
Reported-by: Anders Roxell <anders.roxell@linaro.org>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/kasan-checks.h | 2 +-
 mm/kasan/common.c            | 2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/kasan-checks.h b/include/linux/kasan-checks.h
index d314150658a4..a61dc075e2ce 100644
--- a/include/linux/kasan-checks.h
+++ b/include/linux/kasan-checks.h
@@ -2,7 +2,7 @@
 #ifndef _LINUX_KASAN_CHECKS_H
 #define _LINUX_KASAN_CHECKS_H
 
-#ifdef CONFIG_KASAN
+#if defined(__SANITIZE_ADDRESS__) || defined(__KASAN_INTERNAL)
 void kasan_check_read(const volatile void *p, unsigned int size);
 void kasan_check_write(const volatile void *p, unsigned int size);
 #else
diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index 03d5d1374ca7..51a7932c33a3 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -14,6 +14,8 @@
  *
  */
 
+#define __KASAN_INTERNAL
+
 #include <linux/export.h>
 #include <linux/interrupt.h>
 #include <linux/init.h>
-- 
2.20.0
