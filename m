Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0BCB56B0396
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 11:00:24 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id u48so66630132wrc.0
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 08:00:23 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m203sor34804wma.15.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Mar 2017 08:00:22 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v3 3/9] kasan: change allocation and freeing stack traces headers
Date: Mon,  6 Mar 2017 17:00:03 +0100
Message-Id: <3d146fe40a08bbfad9b44306163bede9bc8531b9.1488815789.git.andreyknvl@google.com>
In-Reply-To: <cover.1488815789.git.andreyknvl@google.com>
References: <cover.1488815789.git.andreyknvl@google.com>
In-Reply-To: <cover.1488815789.git.andreyknvl@google.com>
References: <cover.1488815789.git.andreyknvl@google.com>
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
2.12.0.rc1.440.g5b76565f74-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
