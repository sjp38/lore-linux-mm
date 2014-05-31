From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 1/5] gpu/drm/ttm: Fix possible division by 0 in ttm_dma_pool_shrink_scan().
Date: Sat, 31 May 2014 11:58:35 +0900
Message-ID: <201405311158.DGE64002.QLOOHJSFFMVFOt@I-love.SAKURA.ne.jp>
References: <201405242322.AID86423.HOMLQJOtFFVOSF@I-love.SAKURA.ne.jp>
	<20140528185445.GA23122@phenom.dumpdata.com>
	<201405290647.DHI69200.HSFVFMFOJOLOQt@I-love.SAKURA.ne.jp>
	<201405292334.EAG00503.FLOOJFStHVQMFO@I-love.SAKURA.ne.jp>
	<20140530160824.GD3621@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140530160824.GD3621@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
To: konrad.wilk@oracle.com
Cc: dchinner@redhat.com, airlied@linux.ie, glommer@openvz.org, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org
List-Id: linux-mm.kvack.org

>From c1af6a76f8566eeeed049d3cf24635a43b4a83a6 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 31 May 2014 09:39:22 +0900
Subject: [PATCH 1/5] gpu/drm/ttm: Fix possible division by 0 in ttm_dma_pool_shrink_scan().

list_empty(&_manager->pools) being false before taking _manager->lock
does not guarantee that _manager->npools != 0 after taking _manager->lock
because _manager->npools is updated under _manager->lock.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: stable <stable@kernel.org> [3.3+]
---
 drivers/gpu/drm/ttm/ttm_page_alloc_dma.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c b/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
index fb8259f..b751fff 100644
--- a/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
+++ b/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
@@ -1015,6 +1015,8 @@ ttm_dma_pool_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
 		return SHRINK_STOP;
 
 	mutex_lock(&_manager->lock);
+	if (!_manager->npools)
+		goto out;
 	pool_offset = pool_offset % _manager->npools;
 	list_for_each_entry(p, &_manager->pools, pools) {
 		unsigned nr_free;
@@ -1034,6 +1036,7 @@ ttm_dma_pool_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
 			 p->pool->dev_name, p->pool->name, current->pid,
 			 nr_free, shrink_pages);
 	}
+out:
 	mutex_unlock(&_manager->lock);
 	return freed;
 }
-- 
1.7.1
