From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 3/5] gpu/drm/ttm: Use mutex_trylock() to avoid deadlock inside shrinker functions.
Date: Sat, 31 May 2014 12:00:45 +0900
Message-ID: <201405311200.III57894.MLFOOFStQVHJFO@I-love.SAKURA.ne.jp>
References: <201405290647.DHI69200.HSFVFMFOJOLOQt@I-love.SAKURA.ne.jp>
	<201405292334.EAG00503.FLOOJFStHVQMFO@I-love.SAKURA.ne.jp>
	<20140530160824.GD3621@localhost.localdomain>
	<201405311158.DGE64002.QLOOHJSFFMVFOt@I-love.SAKURA.ne.jp>
	<201405311159.CHG64048.SOFLQHVtFOMFJO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201405311159.CHG64048.SOFLQHVtFOMFJO@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
To: konrad.wilk@oracle.com
Cc: dchinner@redhat.com, airlied@linux.ie, glommer@openvz.org, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org
List-Id: linux-mm.kvack.org

>From 4e8d1a83629c5966bfd401c5f2187355624194f2 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 31 May 2014 09:59:44 +0900
Subject: [PATCH 3/5] gpu/drm/ttm: Use mutex_trylock() to avoid deadlock inside shrinker functions.

I can observe that RHEL7 environment stalls with 100% CPU usage when a
certain type of memory pressure is given. While the shrinker functions
are called by shrink_slab() before the OOM killer is triggered, the stall
lasts for many minutes.

One of reasons of this stall is that
ttm_dma_pool_shrink_count()/ttm_dma_pool_shrink_scan() are called and
are blocked at mutex_lock(&_manager->lock). GFP_KERNEL allocation with
_manager->lock held causes someone (including kswapd) to deadlock when
these functions are called due to memory pressure. This patch changes
"mutex_lock();" to "if (!mutex_trylock()) return ...;" in order to
avoid deadlock.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: stable <stable@kernel.org> [3.3+]
---
 drivers/gpu/drm/ttm/ttm_page_alloc_dma.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c b/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
index d8e59f7..620da39 100644
--- a/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
+++ b/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
@@ -1014,7 +1014,8 @@ ttm_dma_pool_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
 	if (list_empty(&_manager->pools))
 		return SHRINK_STOP;
 
-	mutex_lock(&_manager->lock);
+	if (!mutex_lock(&_manager->lock))
+		return SHRINK_STOP;
 	if (!_manager->npools)
 		goto out;
 	pool_offset = ++start_pool % _manager->npools;
@@ -1047,7 +1048,8 @@ ttm_dma_pool_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
 	struct device_pools *p;
 	unsigned long count = 0;
 
-	mutex_lock(&_manager->lock);
+	if (!mutex_trylock(&_manager->lock))
+		return 0;
 	list_for_each_entry(p, &_manager->pools, pools)
 		count += p->pool->npages_free;
 	mutex_unlock(&_manager->lock);
-- 
1.7.1
