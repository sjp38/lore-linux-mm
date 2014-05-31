From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 4/5] gpu/drm/ttm: Fix possible stack overflow by recursive shrinker calls.
Date: Sat, 31 May 2014 12:01:33 +0900
Message-ID: <201405311201.FEG92893.FQSJOFFVOLOtHM@I-love.SAKURA.ne.jp>
References: <201405292334.EAG00503.FLOOJFStHVQMFO@I-love.SAKURA.ne.jp>
	<20140530160824.GD3621@localhost.localdomain>
	<201405311158.DGE64002.QLOOHJSFFMVFOt@I-love.SAKURA.ne.jp>
	<201405311159.CHG64048.SOFLQHVtFOMFJO@I-love.SAKURA.ne.jp>
	<201405311200.III57894.MLFOOFStQVHJFO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201405311200.III57894.MLFOOFStQVHJFO@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
To: konrad.wilk@oracle.com
Cc: dchinner@redhat.com, airlied@linux.ie, glommer@openvz.org, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org
List-Id: linux-mm.kvack.org

>From d960cdf1e1c91172b86ab9517e576e5fb7e71785 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 31 May 2014 10:05:02 +0900
Subject: [PATCH 4/5] gpu/drm/ttm: Fix possible stack overflow by recursive shrinker calls.

While ttm_dma_pool_shrink_scan() tries to take mutex before doing GFP_KERNEL
allocation, ttm_pool_shrink_scan() does not do it. This can result in stack
overflow if kmalloc() in ttm_page_pool_free() triggered recursion due to
memory pressure.

  shrink_slab()
  => ttm_pool_shrink_scan()
     => ttm_page_pool_free()
        => kmalloc(GFP_KERNEL)
           => shrink_slab()
              => ttm_pool_shrink_scan()
                 => ttm_page_pool_free()
                    => kmalloc(GFP_KERNEL)

Change ttm_pool_shrink_scan() to do like ttm_dma_pool_shrink_scan() does.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: stable <stable@kernel.org> [2.6.35+]
---
 drivers/gpu/drm/ttm/ttm_page_alloc.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/gpu/drm/ttm/ttm_page_alloc.c b/drivers/gpu/drm/ttm/ttm_page_alloc.c
index 863bef9..deba59b 100644
--- a/drivers/gpu/drm/ttm/ttm_page_alloc.c
+++ b/drivers/gpu/drm/ttm/ttm_page_alloc.c
@@ -391,14 +391,17 @@ out:
 static unsigned long
 ttm_pool_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
 {
-	static atomic_t start_pool = ATOMIC_INIT(0);
+	static DEFINE_MUTEX(lock);
+	static unsigned start_pool;
 	unsigned i;
-	unsigned pool_offset = atomic_add_return(1, &start_pool);
+	unsigned pool_offset;
 	struct ttm_page_pool *pool;
 	int shrink_pages = sc->nr_to_scan;
 	unsigned long freed = 0;
 
-	pool_offset = pool_offset % NUM_POOLS;
+	if (!mutex_trylock(&lock))
+		return SHRINK_STOP;
+	pool_offset = ++start_pool % NUM_POOLS;
 	/* select start pool in round robin fashion */
 	for (i = 0; i < NUM_POOLS; ++i) {
 		unsigned nr_free = shrink_pages;
@@ -408,6 +411,7 @@ ttm_pool_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
 		shrink_pages = ttm_page_pool_free(pool, nr_free);
 		freed += nr_free - shrink_pages;
 	}
+	mutex_unlock(&lock);
 	return freed;
 }
 
-- 
1.7.1
