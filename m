Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id F3FBF6B0005
	for <linux-mm@kvack.org>; Tue,  3 May 2016 01:13:25 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 4so18663870pfw.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 22:13:25 -0700 (PDT)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id o6si2272197pfj.110.2016.05.02.22.13.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 22:13:25 -0700 (PDT)
Received: by mail-pf0-x232.google.com with SMTP id 206so5054844pfu.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 22:13:25 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH for v4.6] lib/stackdepot: avoid to return 0 handle
Date: Tue,  3 May 2016 14:13:23 +0900
Message-Id: <1462252403-1106-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Potapenko <glider@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Recently, we allow to save the stacktrace whose hashed value is 0.
It causes the problem that stackdepot could return 0 even if in success.
User of stackdepot cannot distinguish whether it is success or not so we
need to solve this problem. In this patch, 1 bit are added to handle
and make valid handle none 0 by setting this bit. After that, valid handle
will not be 0 and 0 handle will represent failure correctly.

Fixes: 33334e25769c ("lib/stackdepot.c: allow the stack trace hash
to be zero")
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 lib/stackdepot.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/lib/stackdepot.c b/lib/stackdepot.c
index 9e0b031..53ad6c0 100644
--- a/lib/stackdepot.c
+++ b/lib/stackdepot.c
@@ -42,12 +42,14 @@
 
 #define DEPOT_STACK_BITS (sizeof(depot_stack_handle_t) * 8)
 
+#define STACK_ALLOC_NULL_PROTECTION_BITS 1
 #define STACK_ALLOC_ORDER 2 /* 'Slab' size order for stack depot, 4 pages */
 #define STACK_ALLOC_SIZE (1LL << (PAGE_SHIFT + STACK_ALLOC_ORDER))
 #define STACK_ALLOC_ALIGN 4
 #define STACK_ALLOC_OFFSET_BITS (STACK_ALLOC_ORDER + PAGE_SHIFT - \
 					STACK_ALLOC_ALIGN)
-#define STACK_ALLOC_INDEX_BITS (DEPOT_STACK_BITS - STACK_ALLOC_OFFSET_BITS)
+#define STACK_ALLOC_INDEX_BITS (DEPOT_STACK_BITS - \
+		STACK_ALLOC_NULL_PROTECTION_BITS - STACK_ALLOC_OFFSET_BITS)
 #define STACK_ALLOC_SLABS_CAP 1024
 #define STACK_ALLOC_MAX_SLABS \
 	(((1LL << (STACK_ALLOC_INDEX_BITS)) < STACK_ALLOC_SLABS_CAP) ? \
@@ -59,6 +61,7 @@ union handle_parts {
 	struct {
 		u32 slabindex : STACK_ALLOC_INDEX_BITS;
 		u32 offset : STACK_ALLOC_OFFSET_BITS;
+		u32 valid : STACK_ALLOC_NULL_PROTECTION_BITS;
 	};
 };
 
@@ -136,6 +139,7 @@ static struct stack_record *depot_alloc_stack(unsigned long *entries, int size,
 	stack->size = size;
 	stack->handle.slabindex = depot_index;
 	stack->handle.offset = depot_offset >> STACK_ALLOC_ALIGN;
+	stack->handle.valid = 1;
 	memcpy(stack->entries, entries, size * sizeof(unsigned long));
 	depot_offset += required_size;
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
