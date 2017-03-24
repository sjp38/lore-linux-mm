Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2539A6B0351
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 15:32:42 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id h188so6342763wma.4
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 12:32:42 -0700 (PDT)
Received: from mail-wr0-x236.google.com (mail-wr0-x236.google.com. [2a00:1450:400c:c0c::236])
        by mx.google.com with ESMTPS id v8si4361033wmb.31.2017.03.24.12.32.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 12:32:40 -0700 (PDT)
Received: by mail-wr0-x236.google.com with SMTP id u1so7987785wra.2
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 12:32:40 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v4 3/9] kasan: change allocation and freeing stack traces headers
Date: Fri, 24 Mar 2017 20:32:29 +0100
Message-Id: <7191548e9fda9658cea0d6a2313bc8ba0424e5c4.1490383597.git.andreyknvl@google.com>
In-Reply-To: <cover.1490383597.git.andreyknvl@google.com>
References: <cover.1490383597.git.andreyknvl@google.com>
In-Reply-To: <cover.1490383597.git.andreyknvl@google.com>
References: <cover.1490383597.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrey Konovalov <andreyknvl@google.com>

Change stack traces headers from:

Allocated:
PID = 42

to:

Allocated by task 42:

Makes the report one line shorter and look better.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/report.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index fc0577d15671..382d4d2b9052 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -175,9 +175,9 @@ static void kasan_end_report(unsigned long *flags)
 	kasan_enable_current();
 }
 
-static void print_track(struct kasan_track *track)
+static void print_track(struct kasan_track *track, const char *prefix)
 {
-	pr_err("PID = %u\n", track->pid);
+	pr_err("%s by task %u:\n", prefix, track->pid);
 	if (track->stack) {
 		struct stack_trace trace;
 
@@ -199,10 +199,8 @@ static void kasan_object_err(struct kmem_cache *cache, void *object)
 	if (!(cache->flags & SLAB_KASAN))
 		return;
 
-	pr_err("Allocated:\n");
-	print_track(&alloc_info->alloc_track);
-	pr_err("Freed:\n");
-	print_track(&alloc_info->free_track);
+	print_track(&alloc_info->alloc_track, "Allocated");
+	print_track(&alloc_info->free_track, "Freed");
 }
 
 void kasan_report_double_free(struct kmem_cache *cache, void *object,
-- 
2.12.1.578.ge9c3154ca4-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
