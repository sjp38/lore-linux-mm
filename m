Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9DB106B039F
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 12:15:54 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e68so399989wme.10
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 09:15:54 -0700 (PDT)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id l11si5187054wrl.237.2017.03.28.09.15.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 09:15:53 -0700 (PDT)
Received: by mail-wm0-x234.google.com with SMTP id u132so43905702wmg.0
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 09:15:53 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH 6/8] kasan: allow kasan_check_read/write() to accept pointers to volatiles
Date: Tue, 28 Mar 2017 18:15:43 +0200
Message-Id: <4bb09c693aee101e6101f84fb5635e54fc360a28.1490717337.git.dvyukov@google.com>
In-Reply-To: <cover.1490717337.git.dvyukov@google.com>
References: <cover.1490717337.git.dvyukov@google.com>
In-Reply-To: <cover.1490717337.git.dvyukov@google.com>
References: <cover.1490717337.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com
Cc: akpm@linux-foundation.org, will.deacon@arm.com, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, x86@kernel.org, Dmitry Vyukov <dvyukov@google.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org

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
index 98b27195e38b..db46e66eb1d4 100644
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
2.12.2.564.g063fe858b8-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
