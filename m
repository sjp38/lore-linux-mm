Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6C0A76B0339
	for <linux-mm@kvack.org>; Wed, 16 May 2018 11:34:39 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 44-v6so908167wrt.9
        for <linux-mm@kvack.org>; Wed, 16 May 2018 08:34:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h10-v6sor1418898wrf.61.2018.05.16.08.34.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 May 2018 08:34:38 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH] lib/stackdepot.c: use a non-instrumented version of memcpy()
Date: Wed, 16 May 2018 17:34:34 +0200
Message-Id: <20180516153434.24479-1-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, dvyukov@google.com, aryabinin@virtuozzo.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

stackdepot used to call memcpy(), which compiler tools normally
instrument, therefore every lookup used to unnecessarily call instrumented
code.  This is somewhat ok in the case of KASAN, but under KMSAN a lot of
time was spent in the instrumentation.

(A similar change has been previously committed for memcmp())

Signed-off-by: Alexander Potapenko <glider@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
---
 lib/stackdepot.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/stackdepot.c b/lib/stackdepot.c
index e513459a5601..d48c744fa750 100644
--- a/lib/stackdepot.c
+++ b/lib/stackdepot.c
@@ -140,7 +140,7 @@ static struct stack_record *depot_alloc_stack(unsigned long *entries, int size,
 	stack->handle.slabindex = depot_index;
 	stack->handle.offset = depot_offset >> STACK_ALLOC_ALIGN;
 	stack->handle.valid = 1;
-	memcpy(stack->entries, entries, size * sizeof(unsigned long));
+	__memcpy(stack->entries, entries, size * sizeof(unsigned long));
 	depot_offset += required_size;
 
 	return stack;
-- 
2.17.0.441.gb46fe60e1d-goog
