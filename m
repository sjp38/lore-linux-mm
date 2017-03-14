Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id AF8606B038C
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 15:24:22 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l37so51243847wrc.7
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 12:24:22 -0700 (PDT)
Received: from mail-wr0-x22a.google.com (mail-wr0-x22a.google.com. [2a00:1450:400c:c0c::22a])
        by mx.google.com with ESMTPS id q4si6237113wrb.291.2017.03.14.12.24.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Mar 2017 12:24:21 -0700 (PDT)
Received: by mail-wr0-x22a.google.com with SMTP id u108so130461482wrb.3
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 12:24:21 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH 1/3] kasan: allow kasan_check_read/write() to accept pointers to volatiles
Date: Tue, 14 Mar 2017 20:24:12 +0100
Message-Id: <b47f7c2e3445cf48493a1504247e6794232cc073.1489519233.git.dvyukov@google.com>
In-Reply-To: <cover.1489519233.git.dvyukov@google.com>
References: <cover.1489519233.git.dvyukov@google.com>
In-Reply-To: <cover.1489519233.git.dvyukov@google.com>
References: <cover.1489519233.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mark.rutland@arm.com, peterz@infradead.org, aryabinin@virtuozzo.com, mingo@redhat.com
Cc: will.deacon@arm.com, akpm@linux-foundation.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>

Currently kasan_check_read/write() accept 'const void*', make them
accept 'const volatile void*'. This is required for instrumentation
of atomic operations and there is just no reason to not allow that.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>,
Cc: Andrew Morton <akpm@linux-foundation.org>,
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
Cc: Ingo Molnar <mingo@redhat.com>,
Cc: kasan-dev@googlegroups.com
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: x86@kernel.org
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
2.12.0.367.g23dc2f6d3c-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
