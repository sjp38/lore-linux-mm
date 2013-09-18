Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id E69DF6B0032
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 05:09:54 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so8045178pad.0
        for <linux-mm@kvack.org>; Wed, 18 Sep 2013 02:09:54 -0700 (PDT)
Received: by mail-ee0-f46.google.com with SMTP id c13so3265861eek.19
        for <linux-mm@kvack.org>; Wed, 18 Sep 2013 02:09:50 -0700 (PDT)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Subject: [PATCH] [RFC] mm/shrinker: Add a shrinker flag to always shrink a bit
Date: Wed, 18 Sep 2013 11:10:01 +0200
Message-Id: <1379495401-18279-1-git-send-email-daniel.vetter@ffwll.ch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, DRI Development <dri-devel@lists.freedesktop.org>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, Daniel Vetter <daniel.vetter@ffwll.ch>, Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

The drm/i915 gpu driver loves to hang onto as much memory as it can -
we cache pinned pages, dma mappings and obviously also gpu address
space bindings of buffer objects. On top of that userspace has its own
opportunistic cache which is managed by an madvise-like ioctl to tell
the kernel which objects are purgeable and which are actually used.
This is to cache userspace mmapings and a bit of other metadata about
buffer objects needed to be able to hit fastpaths even on fresh
objects.

We have routine encounters with the OOM killer due to all this crave
for memory. The latest one seems to be an artifact of the mm core
trying really hard to balance page lru evictions with shrinking
caches: The shrinker in drm/i915 doesn't actually free memory, but
only drops all the dma mappings and page refcounts so that the backing
storage (which is just shmemfs nodes) can actually be evicted.

Which means that if the core mm hasn't found anything to evict from
the page lru (most likely because drm/i915 has pinned down everything
available) it will also not shrink any of the caches. Which leads to a
premature OOM while still tons of pages used by gpu buffer objects
could be swapped out.

For a quick hack I've added a shrink-me-harder flag to make sure
there's at least a bit of forward progress. It seems to work. I've
called the flag evicts_to_page_lru, but that might just be uninformed
me talking ...

We should also probably have something with a bit more smarts to be more
aggressive when in a tight spot and avoid the minimal shrinking when
it's not really required, so maybe take scan_control->priority into
account somehow. But since I utterly lack clue I've figured sending
out a quick rfc first is better.

Also, this needs to be rebased to the new shrinker api in 3.12, I
simply haven't rolled my trees forward yet. In any case I just want to
get the discussion started on this.

Cc: Glauber Costa <glommer@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Bugzilla: https://bugs.freedesktop.org/show_bug.cgi?id=69247
Signed-off-by: Daniel Vetter <daniel.vetter@ffwll.ch>
---
 drivers/gpu/drm/i915/i915_gem.c |  1 +
 include/linux/shrinker.h        | 14 ++++++++++++++
 mm/vmscan.c                     |  4 ++++
 3 files changed, 19 insertions(+)

diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index d80f33d..7481d0a 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -4582,6 +4582,7 @@ i915_gem_load(struct drm_device *dev)
 
 	dev_priv->mm.inactive_shrinker.shrink = i915_gem_inactive_shrink;
 	dev_priv->mm.inactive_shrinker.seeks = DEFAULT_SEEKS;
+	dev_priv->mm.inactive_shrinker.evicts_to_page_lru = true;
 	register_shrinker(&dev_priv->mm.inactive_shrinker);
 }
 
diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index ac6b8ee..361cc2d 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -32,6 +32,20 @@ struct shrinker {
 	int seeks;	/* seeks to recreate an obj */
 	long batch;	/* reclaim batch size, 0 = default */
 
+	/*
+	 * Some shrinkers (especially gpu drivers using gem as backing storage)
+	 * hold onto gobloads of pinned pagecache memory (from shmem nodes).
+	 * When those caches get shrunk the memory only gets unpin and so is
+	 * available to be evicted with the page launderer.
+	 *
+	 * The problem is that the core mm tries to balance eviction from the
+	 * page lru with shrinking caches. So if there's nothing on the page lru
+	 * to evict we'll never shrink the gpu driver caches and so will OOM
+	 * despite tons of memory used by gpu buffer objects that could be
+	 * swapped out. Setting this flag ensures forward progress.
+	 */
+	bool evicts_to_page_lru;
+
 	/* These are for internal use */
 	struct list_head list;
 	atomic_long_t nr_in_batch; /* objs pending delete */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2cff0d4..d81f6e0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -254,6 +254,10 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 			total_scan = max_pass;
 		}
 
+		/* Always try to shrink a bit to make forward progress. */
+		if (shrinker->evicts_to_page_lru)
+			total_scan = max_t(long, total_scan, batch_size);
+
 		/*
 		 * We need to avoid excessive windup on filesystem shrinkers
 		 * due to large numbers of GFP_NOFS allocations causing the
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
