Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9932D6B025E
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 10:59:31 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id e7so76982228lfe.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 07:59:31 -0700 (PDT)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id wg3si31794235wjb.188.2016.08.01.07.59.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 07:59:30 -0700 (PDT)
Received: by mail-wm0-x232.google.com with SMTP id f65so373708745wmi.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 07:59:30 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH] kasan: avoid overflowing quarantine size on low memory systems
Date: Mon,  1 Aug 2016 16:59:23 +0200
Message-Id: <1470063563-96266-1-git-send-email-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dvyukov@google.com, kcc@google.com, aryabinin@virtuozzo.com, adech.fo@gmail.com, cl@linux.com, akpm@linux-foundation.org, rostedt@goodmis.org, js1304@gmail.com, iamjoonsoo.kim@lge.com, kuthonuzo.luruo@hpe.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

If the total amount of memory assigned to quarantine is less than the
amount of memory assigned to per-cpu quarantines, |new_quarantine_size|
may overflow. Instead, set it to zero.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Fixes: 55834c59098d ("mm: kasan: initial memory quarantine
implementation")
Signed-off-by: Alexander Potapenko <glider@google.com>
---
 mm/kasan/quarantine.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
index 65793f1..416d3b0 100644
--- a/mm/kasan/quarantine.c
+++ b/mm/kasan/quarantine.c
@@ -196,7 +196,7 @@ void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache)
 
 void quarantine_reduce(void)
 {
-	size_t new_quarantine_size;
+	size_t new_quarantine_size, percpu_quarantines;
 	unsigned long flags;
 	struct qlist_head to_free = QLIST_INIT;
 	size_t size_to_free = 0;
@@ -214,7 +214,15 @@ void quarantine_reduce(void)
 	 */
 	new_quarantine_size = (READ_ONCE(totalram_pages) << PAGE_SHIFT) /
 		QUARANTINE_FRACTION;
-	new_quarantine_size -= QUARANTINE_PERCPU_SIZE * num_online_cpus();
+	percpu_quarantines = QUARANTINE_PERCPU_SIZE * num_online_cpus();
+	if (new_quarantine_size < percpu_quarantines) {
+		WARN_ONCE(1,
+			"Too little memory, disabling global KASAN quarantine.\n",
+		);
+		new_quarantine_size = 0;
+	} else {
+		new_quarantine_size -= percpu_quarantines;
+	}
 	WRITE_ONCE(quarantine_size, new_quarantine_size);
 
 	last = global_quarantine.head;
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
