Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 571CB6B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 05:49:29 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id sq19so184718618igc.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 02:49:29 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id s7si5427948oeh.73.2016.05.02.02.49.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 02:49:28 -0700 (PDT)
Date: Mon, 2 May 2016 15:19:20 +0530
From: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
Subject: [PATCH] kasan: improve double-free detection
Message-ID: <20160502094920.GA3005@cherokee.in.rdlabs.hpecorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, glider@google.com, dvyukov@google.com
Cc: akpm@linux-foundation.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kuthonuzo.luruo@hpe.com

Hi Alexander/Andrey/Dmitry,

For your consideration/review. Thanks!

Kuthonuzo Luruo 

Currently, KASAN may fail to detect concurrent deallocations of the same
object due to a race in kasan_slab_free(). This patch makes double-free
detection more reliable by atomically setting allocation state for object
to KASAN_STATE_QUARANTINE iff current state is KASAN_STATE_ALLOC.

Tested using a modified version of the 'slab_test' microbenchmark where
allocs occur on CPU 0; then all other CPUs concurrently attempt to free the
same object.

Signed-off-by: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
---
 mm/kasan/kasan.c |   32 ++++++++++++++++++--------------
 mm/kasan/kasan.h |    5 ++---
 2 files changed, 20 insertions(+), 17 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index ef2e87b..4fc4e76 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -511,23 +511,28 @@ void kasan_poison_slab_free(struct kmem_cache *cache, void *object)
 bool kasan_slab_free(struct kmem_cache *cache, void *object)
 {
 #ifdef CONFIG_SLAB
+	struct kasan_alloc_meta *alloc_info;
+	struct kasan_free_meta *free_info;
+
 	/* RCU slabs could be legally used after free within the RCU period */
 	if (unlikely(cache->flags & SLAB_DESTROY_BY_RCU))
 		return false;
 
-	if (likely(cache->flags & SLAB_KASAN)) {
-		struct kasan_alloc_meta *alloc_info =
-			get_alloc_info(cache, object);
-		struct kasan_free_meta *free_info =
-			get_free_info(cache, object);
-
-		switch (alloc_info->state) {
-		case KASAN_STATE_ALLOC:
-			alloc_info->state = KASAN_STATE_QUARANTINE;
-			quarantine_put(free_info, cache);
-			set_track(&free_info->track, GFP_NOWAIT);
-			kasan_poison_slab_free(cache, object);
-			return true;
+	if (unlikely(!(cache->flags & SLAB_KASAN)))
+		return false;
+
+	alloc_info = get_alloc_info(cache, object);
+
+	if (cmpxchg(&alloc_info->state, KASAN_STATE_ALLOC,
+				KASAN_STATE_QUARANTINE) == KASAN_STATE_ALLOC) {
+		free_info = get_free_info(cache, object);
+		quarantine_put(free_info, cache);
+		set_track(&free_info->track, GFP_NOWAIT);
+		kasan_poison_slab_free(cache, object);
+		return true;
+	}
+
+	switch (alloc_info->state) {
 		case KASAN_STATE_QUARANTINE:
 		case KASAN_STATE_FREE:
 			pr_err("Double free");
@@ -535,7 +540,6 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object)
 			break;
 		default:
 			break;
-		}
 	}
 	return false;
 #else
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 7da78a6..8c22a96 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -75,9 +75,8 @@ struct kasan_track {
 
 struct kasan_alloc_meta {
 	struct kasan_track track;
-	u32 state : 2;	/* enum kasan_state */
-	u32 alloc_size : 30;
-	u32 reserved;
+	u32 state;	/* enum kasan_state */
+	u32 alloc_size;
 };
 
 struct kasan_free_meta {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
