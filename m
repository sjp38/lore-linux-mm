Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 795C7828DF
	for <linux-mm@kvack.org>; Wed, 13 Apr 2016 08:07:33 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id u206so73736578wme.1
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 05:07:33 -0700 (PDT)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id 21si29069627wmu.10.2016.04.13.05.07.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Apr 2016 05:07:32 -0700 (PDT)
Received: by mail-wm0-x22f.google.com with SMTP id n3so73945332wmn.0
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 05:07:31 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v2] lib/stackdepot.c: allow the stack trace hash to be zero
Date: Wed, 13 Apr 2016 14:07:25 +0200
Message-Id: <1460549245-131634-1-git-send-email-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, dvyukov@google.com, cl@linux.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, kcc@google.com, iamjoonsoo.kim@lge.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Do not bail out from depot_save_stack() if the stack trace has zero hash.
Initially depot_save_stack() silently dropped stack traces with zero
hashes, however there's actually no point in reserving this zero value.

Reported-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Alexander Potapenko <glider@google.com>
---
 lib/stackdepot.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/lib/stackdepot.c b/lib/stackdepot.c
index 654c9d8..9e0b031 100644
--- a/lib/stackdepot.c
+++ b/lib/stackdepot.c
@@ -210,10 +210,6 @@ depot_stack_handle_t depot_save_stack(struct stack_trace *trace,
 		goto fast_exit;
 
 	hash = hash_stack(trace->entries, trace->nr_entries);
-	/* Bad luck, we won't store this stack. */
-	if (hash == 0)
-		goto exit;
-
 	bucket = &stack_table[hash & STACK_HASH_MASK];
 
 	/*
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
