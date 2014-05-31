From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 2/5] gpu/drm/ttm: Choose a pool to shrink correctly in ttm_dma_pool_shrink_scan().
Date: Sat, 31 May 2014 11:59:39 +0900
Message-ID: <201405311159.CHG64048.SOFLQHVtFOMFJO@I-love.SAKURA.ne.jp>
References: <20140528185445.GA23122@phenom.dumpdata.com>
	<201405290647.DHI69200.HSFVFMFOJOLOQt@I-love.SAKURA.ne.jp>
	<201405292334.EAG00503.FLOOJFStHVQMFO@I-love.SAKURA.ne.jp>
	<20140530160824.GD3621@localhost.localdomain>
	<201405311158.DGE64002.QLOOHJSFFMVFOt@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201405311158.DGE64002.QLOOHJSFFMVFOt@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
To: konrad.wilk@oracle.com
Cc: dchinner@redhat.com, airlied@linux.ie, glommer@openvz.org, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org
List-Id: linux-mm.kvack.org

>From 19927a63c5d2dcda467373c31d810be42e40e190 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 31 May 2014 09:47:02 +0900
Subject: [PATCH 2/5] gpu/drm/ttm: Choose a pool to shrink correctly in ttm_dma_pool_shrink_scan().

We can use "unsigned int" instead of "atomic_t" by updating start_pool
variable under _manager->lock. This patch will make it possible to avoid
skipping when choosing a pool to shrink in round-robin style, after next
patch changes mutex_lock(_manager->lock) to !mutex_trylock(_manager->lork).

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: stable <stable@kernel.org> [3.3+]
---
 drivers/gpu/drm/ttm/ttm_page_alloc_dma.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c b/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
index b751fff..d8e59f7 100644
--- a/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
+++ b/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
@@ -1004,9 +1004,9 @@ EXPORT_SYMBOL_GPL(ttm_dma_unpopulate);
 static unsigned long
 ttm_dma_pool_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
 {
-	static atomic_t start_pool = ATOMIC_INIT(0);
+	static unsigned start_pool;
 	unsigned idx = 0;
-	unsigned pool_offset = atomic_add_return(1, &start_pool);
+	unsigned pool_offset;
 	unsigned shrink_pages = sc->nr_to_scan;
 	struct device_pools *p;
 	unsigned long freed = 0;
@@ -1017,7 +1017,7 @@ ttm_dma_pool_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
 	mutex_lock(&_manager->lock);
 	if (!_manager->npools)
 		goto out;
-	pool_offset = pool_offset % _manager->npools;
+	pool_offset = ++start_pool % _manager->npools;
 	list_for_each_entry(p, &_manager->pools, pools) {
 		unsigned nr_free;
 
-- 
1.7.1
