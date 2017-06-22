Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 401176B02F3
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 10:14:29 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 64so4978031wrp.4
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 07:14:29 -0700 (PDT)
Received: from mail-wr0-x230.google.com (mail-wr0-x230.google.com. [2a00:1450:400c:c0c::230])
        by mx.google.com with ESMTPS id g26si1636855wrg.365.2017.06.22.07.14.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 07:14:27 -0700 (PDT)
Received: by mail-wr0-x230.google.com with SMTP id 77so25379760wrb.1
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 07:14:27 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH v5 2/4] kasan: allow kasan_check_read/write() to accept pointers to volatiles
Date: Thu, 22 Jun 2017 16:14:17 +0200
Message-Id: <33e5ec275c1ee89299245b2ebbccd63709c6021f.1498140838.git.dvyukov@google.com>
In-Reply-To: <cover.1498140468.git.dvyukov@google.com>
References: <cover.1498140468.git.dvyukov@google.com>
In-Reply-To: <cover.1498140838.git.dvyukov@google.com>
References: <cover.1498140838.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com, will.deacon@arm.com, hpa@zytor.com, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Currently kasan_check_read/write() accept 'const void*', make them
accept 'const volatile void*'. This is required for instrumentation
of atomic operations and there is just no reason to not allow that.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Acked-by: Mark Rutland <mark.rutland@arm.com>
Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org
Cc: x86@kernel.org
Cc: linux-mm@kvack.org
Cc: kasan-dev@googlegroups.com
---
 include/linux/kasan-checks.h | 10 ++++++----
 mm/kasan/kasan.c             |  4 ++--
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/linux/kasan-checks.h b/include/linux/kasan-checks.h
index b7f8aced7870..41960fecf783 100644
--- a/include/linux/kasan-checks.h
+++ b/include/linux/kasan-checks.h
@@ -2,11 +2,13 @@
 #define _LINUX_KASAN_CHECKS_H
 
 #ifdef CONFIG_KASAN
-void kasan_check_read(const void *p, unsigned int size);
-void kasan_check_write(const void *p, unsigned int size);
+void kasan_check_read(const volatile void *p, unsigned int size);
+void kasan_check_write(const volatile void *p, unsigned int size);
 #else
-static inline void kasan_check_read(const void *p, unsigned int size) { }
-static inline void kasan_check_write(const void *p, unsigned int size) { }
+static inline void kasan_check_read(const volatile void *p, unsigned int size)
+{ }
+static inline void kasan_check_write(const volatile void *p, unsigned int size)
+{ }
 #endif
 
 #endif
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index c81549d5c833..edacd161c0e5 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -333,13 +333,13 @@ static void check_memory_region(unsigned long addr,
 	check_memory_region_inline(addr, size, write, ret_ip);
 }
 
-void kasan_check_read(const void *p, unsigned int size)
+void kasan_check_read(const volatile void *p, unsigned int size)
 {
 	check_memory_region((unsigned long)p, size, false, _RET_IP_);
 }
 EXPORT_SYMBOL(kasan_check_read);
 
-void kasan_check_write(const void *p, unsigned int size)
+void kasan_check_write(const volatile void *p, unsigned int size)
 {
 	check_memory_region((unsigned long)p, size, true, _RET_IP_);
 }
-- 
2.13.1.611.g7e3b11ae1-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
