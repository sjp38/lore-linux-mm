Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 607166B0365
	for <linux-mm@kvack.org>; Sat, 17 Jun 2017 05:15:46 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id h64so6268343wmg.0
        for <linux-mm@kvack.org>; Sat, 17 Jun 2017 02:15:46 -0700 (PDT)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id x4si1276802wmb.93.2017.06.17.02.15.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Jun 2017 02:15:45 -0700 (PDT)
Received: by mail-wm0-x231.google.com with SMTP id u195so27322884wmd.1
        for <linux-mm@kvack.org>; Sat, 17 Jun 2017 02:15:44 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH v4 5/7] kasan: allow kasan_check_read/write() to accept pointers to volatiles
Date: Sat, 17 Jun 2017 11:15:31 +0200
Message-Id: <e5a4c25bda8eccce2317da6d97138bfbea730e64.1497690003.git.dvyukov@google.com>
In-Reply-To: <cover.1497690003.git.dvyukov@google.com>
References: <cover.1497690003.git.dvyukov@google.com>
In-Reply-To: <cover.1497690003.git.dvyukov@google.com>
References: <cover.1497690003.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com, will.deacon@arm.com, hpa@zytor.com, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Currently kasan_check_read/write() accept 'const void*', make them
accept 'const volatile void*'. This is required for instrumentation
of atomic operations and there is just no reason to not allow that.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
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
2.13.1.518.g3df882009-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
