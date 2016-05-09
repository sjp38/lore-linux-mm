Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id A35226B0264
	for <linux-mm@kvack.org>; Mon,  9 May 2016 06:26:15 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id u185so342399475oie.3
        for <linux-mm@kvack.org>; Mon, 09 May 2016 03:26:15 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0139.outbound.protection.outlook.com. [104.47.0.139])
        by mx.google.com with ESMTPS id r9si11878924otd.249.2016.05.09.03.26.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 09 May 2016 03:26:14 -0700 (PDT)
Subject: Re: [PATCH v2 1/2] mm, kasan: improve double-free detection
References: <20160506114727.GA2571@cherokee.in.rdlabs.hpecorp.net>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <573065BD.2020708@virtuozzo.com>
Date: Mon, 9 May 2016 13:26:05 +0300
MIME-Version: 1.0
In-Reply-To: <20160506114727.GA2571@cherokee.in.rdlabs.hpecorp.net>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, glider@google.com, dvyukov@google.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 05/06/2016 02:47 PM, Kuthonuzo Luruo wrote:
> Currently, KASAN may fail to detect concurrent deallocations of the same
> object due to a race in kasan_slab_free(). This patch makes double-free
> detection more reliable by serializing access to KASAN object metadata.
> New functions kasan_meta_lock() and kasan_meta_unlock() are provided to
> lock/unlock per-object metadata. Double-free errors are now reported via
> kasan_report().
> 
> Testing:
> - Tested with a modified version of the 'slab_test' microbenchmark where
>   allocs occur on CPU 0; then all other CPUs concurrently attempt to free
>   the same object.
> - Tested with new 'test_kasan' kasan_double_free() test in accompanying
>   patch.
> 
> Signed-off-by: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
> ---
> 
> Changes in v2:
> - Incorporated suggestions from Dmitry Vyukov. New per-object metadata
>   lock/unlock functions; kasan_alloc_meta modified to add new state while
>   using fewer bits overall.
> - Double-free pr_err promoted to kasan_report().
> - kasan_init_object() introduced to initialize KASAN object metadata
>   during slab creation. KASAN_STATE_INIT initialization removed from
>   kasan_poison_object_data().
>  
> ---
>  include/linux/kasan.h |    8 +++
>  mm/kasan/kasan.c      |  118 ++++++++++++++++++++++++++++++++++++-------------
>  mm/kasan/kasan.h      |   15 +++++-
>  mm/kasan/quarantine.c |    7 +++-
>  mm/kasan/report.c     |   31 +++++++++++--
>  mm/slab.c             |    1 +
>  6 files changed, 142 insertions(+), 38 deletions(-)
> 

Sorry, but this patch is crap.

Something like this, will fix the race:

---
 mm/kasan/kasan.c      | 20 ++++----------------
 mm/kasan/kasan.h      | 10 +++-------
 mm/kasan/quarantine.c |  1 -
 mm/kasan/report.c     | 11 ++---------
 4 files changed, 9 insertions(+), 33 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index ef2e87b..8d078dc 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -419,13 +419,6 @@ void kasan_poison_object_data(struct kmem_cache *cache, void *object)
 	kasan_poison_shadow(object,
 			round_up(cache->object_size, KASAN_SHADOW_SCALE_SIZE),
 			KASAN_KMALLOC_REDZONE);
-#ifdef CONFIG_SLAB
-	if (cache->flags & SLAB_KASAN) {
-		struct kasan_alloc_meta *alloc_info =
-			get_alloc_info(cache, object);
-		alloc_info->state = KASAN_STATE_INIT;
-	}
-#endif
 }
 
 #ifdef CONFIG_SLAB
@@ -521,20 +514,15 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object)
 		struct kasan_free_meta *free_info =
 			get_free_info(cache, object);
 
-		switch (alloc_info->state) {
-		case KASAN_STATE_ALLOC:
-			alloc_info->state = KASAN_STATE_QUARANTINE;
+		if (test_and_clear_bit(KASAN_STATE_ALLOCATED,
+					&alloc_info->state)) {
 			quarantine_put(free_info, cache);
 			set_track(&free_info->track, GFP_NOWAIT);
 			kasan_poison_slab_free(cache, object);
 			return true;
-		case KASAN_STATE_QUARANTINE:
-		case KASAN_STATE_FREE:
+		} else {
 			pr_err("Double free");
 			dump_stack();
-			break;
-		default:
-			break;
 		}
 	}
 	return false;
@@ -571,7 +559,7 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 		struct kasan_alloc_meta *alloc_info =
 			get_alloc_info(cache, object);
 
-		alloc_info->state = KASAN_STATE_ALLOC;
+		set_bit(KASAN_STATE_ALLOCATED, &alloc_info->state);
 		alloc_info->alloc_size = size;
 		set_track(&alloc_info->track, flags);
 	}
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 7da78a6..2dcdc8f 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -60,10 +60,7 @@ struct kasan_global {
  */
 
 enum kasan_state {
-	KASAN_STATE_INIT,
-	KASAN_STATE_ALLOC,
-	KASAN_STATE_QUARANTINE,
-	KASAN_STATE_FREE
+	KASAN_STATE_ALLOCATED,
 };
 
 #define KASAN_STACK_DEPTH 64
@@ -75,9 +72,8 @@ struct kasan_track {
 
 struct kasan_alloc_meta {
 	struct kasan_track track;
-	u32 state : 2;	/* enum kasan_state */
-	u32 alloc_size : 30;
-	u32 reserved;
+	unsigned long state;
+	u32 alloc_size;
 };
 
 struct kasan_free_meta {
diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
index 40159a6..ca33fd3 100644
--- a/mm/kasan/quarantine.c
+++ b/mm/kasan/quarantine.c
@@ -147,7 +147,6 @@ static void qlink_free(void **qlink, struct kmem_cache *cache)
 	unsigned long flags;
 
 	local_irq_save(flags);
-	alloc_info->state = KASAN_STATE_FREE;
 	___cache_free(cache, object, _THIS_IP_);
 	local_irq_restore(flags);
 }
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index b3c122d..c2b0e51 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -140,18 +140,12 @@ static void object_err(struct kmem_cache *cache, struct page *page,
 	pr_err("Object at %p, in cache %s\n", object, cache->name);
 	if (!(cache->flags & SLAB_KASAN))
 		return;
-	switch (alloc_info->state) {
-	case KASAN_STATE_INIT:
-		pr_err("Object not allocated yet\n");
-		break;
-	case KASAN_STATE_ALLOC:
+	if (test_bit(KASAN_STATE_ALLOCATED, &alloc_info->state)) {
 		pr_err("Object allocated with size %u bytes.\n",
 		       alloc_info->alloc_size);
 		pr_err("Allocation:\n");
 		print_track(&alloc_info->track);
-		break;
-	case KASAN_STATE_FREE:
-	case KASAN_STATE_QUARANTINE:
+	} else {
 		pr_err("Object freed, allocated with size %u bytes\n",
 		       alloc_info->alloc_size);
 		free_info = get_free_info(cache, object);
@@ -159,7 +153,6 @@ static void object_err(struct kmem_cache *cache, struct page *page,
 		print_track(&alloc_info->track);
 		pr_err("Deallocation:\n");
 		print_track(&free_info->track);
-		break;
 	}
 }
 #endif
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
