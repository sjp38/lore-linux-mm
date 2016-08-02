Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A04076B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 06:27:07 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l4so100331649wml.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 03:27:07 -0700 (PDT)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id h7si1916208wjo.70.2016.08.02.03.27.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 03:27:06 -0700 (PDT)
Received: by mail-wm0-x234.google.com with SMTP id i5so282914106wmg.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 03:27:06 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v2] kasan: avoid overflowing quarantine size on low memory systems
Date: Tue,  2 Aug 2016 12:27:00 +0200
Message-Id: <1470133620-28683-1-git-send-email-glider@google.com>
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
v2: Don't print the warning if we don't have enough memory for quarantine.
---
 mm/kasan/quarantine.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
index 65793f1..8c29938 100644
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
@@ -214,7 +214,9 @@ void quarantine_reduce(void)
 	 */
 	new_quarantine_size = (READ_ONCE(totalram_pages) << PAGE_SHIFT) /
 		QUARANTINE_FRACTION;
-	new_quarantine_size -= QUARANTINE_PERCPU_SIZE * num_online_cpus();
+	percpu_quarantines = QUARANTINE_PERCPU_SIZE * num_online_cpus();
+	new_quarantine_size = (new_quarantine_size < percpu_quarantines) ?
+		0 : new_quarantine_size - percpu_quarantines;
 	WRITE_ONCE(quarantine_size, new_quarantine_size);
 
 	last = global_quarantine.head;
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
