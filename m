Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D42786B025E
	for <linux-mm@kvack.org>; Fri, 14 Oct 2016 11:20:24 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c78so1051101wme.5
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 08:20:24 -0700 (PDT)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id 137si267436wmj.74.2016.10.14.08.20.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Oct 2016 08:20:23 -0700 (PDT)
Received: by mail-wm0-x22e.google.com with SMTP id c78so3843134wme.0
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 08:20:23 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH] lib: bump stackdepot capacity from 16MB to 128MB
Date: Fri, 14 Oct 2016 17:20:16 +0200
Message-Id: <1476458416-122131-1-git-send-email-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, akpm@linux-foundation.org, glider@google.com, iamjoonsoo.kim@lge.com
Cc: Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, sploving1@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

KASAN uses stackdepot to memorize stacks for all kmalloc/kfree calls.
Current stackdepot capacity is 16MB (1024 top level entries x
4 pages on second level). Size of each stack is (num_frames + 3) *
sizeof(long). Which gives us ~84K stacks. This capacity was chosen
empirically and it is enough to run kernel normally. However,
when lots of configs are enabled and a fuzzer tries to maximize
code coverage, it easily hits the limit within tens of minutes.
I've tested for long a time with number of top level entries bumped 4x
(4096). And I think I've seen overflow only once. But I don't have
all configs enabled and code coverage has not reached maximum yet.
So bump it 8x to 8192. Since we have two-level table, memory cost
of this is very moderate -- currently the top-level table is 8KB,
with this patch it is 64KB, which is negligible under KASAN.

Here is some approx math.
128MB allows us to memorize ~670K stacks (assuming stack is ~200b).
I've grepped kernel for kmalloc|kfree|kmem_cache_alloc|kmem_cache_free|
kzalloc|kstrdup|kstrndup|kmemdup and it gives ~60K matches.
Most of alloc/free call sites are reachable with only one stack.
But some utility functions can have large fanout. Assuming average
fanout is 5x, total number of alloc/free stacks is ~300K.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: kasan-dev@googlegroups.com
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: sploving1@gmail.com
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 lib/stackdepot.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/stackdepot.c b/lib/stackdepot.c
index 60f77f1..4d830e2 100644
--- a/lib/stackdepot.c
+++ b/lib/stackdepot.c
@@ -50,7 +50,7 @@
 					STACK_ALLOC_ALIGN)
 #define STACK_ALLOC_INDEX_BITS (DEPOT_STACK_BITS - \
 		STACK_ALLOC_NULL_PROTECTION_BITS - STACK_ALLOC_OFFSET_BITS)
-#define STACK_ALLOC_SLABS_CAP 1024
+#define STACK_ALLOC_SLABS_CAP 8192
 #define STACK_ALLOC_MAX_SLABS \
 	(((1LL << (STACK_ALLOC_INDEX_BITS)) < STACK_ALLOC_SLABS_CAP) ? \
 	 (1LL << (STACK_ALLOC_INDEX_BITS)) : STACK_ALLOC_SLABS_CAP)
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
