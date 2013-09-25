Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id B0F3F6B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 07:59:55 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so5963819pbc.15
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 04:59:55 -0700 (PDT)
Received: by mail-ee0-f44.google.com with SMTP id b47so3167605eek.3
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 04:59:50 -0700 (PDT)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Subject: [PATCH] drm/i915: Fix up usage of SHRINK_STOP
Date: Wed, 25 Sep 2013 14:00:02 +0200
Message-Id: <1380110402-24749-1-git-send-email-daniel.vetter@ffwll.ch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Intel Graphics Development <intel-gfx@lists.freedesktop.org>
Cc: DRI Development <dri-devel@lists.freedesktop.org>, Linux MM <linux-mm@kvack.org>, Daniel Vetter <daniel.vetter@ffwll.ch>, Knut Petersen <Knut_Petersen@t-online.de>, Dave Chinner <david@fromorbit.com>, Glauber Costa <glommer@openvz.org>, Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

In

commit 81e49f811404f428a9d9a63295a0c267e802fa12
Author: Glauber Costa <glommer@openvz.org>
Date:   Wed Aug 28 10:18:13 2013 +1000

    i915: bail out earlier when shrinker cannot acquire mutex

SHRINK_STOP was added to tell the core shrinker code to bail out and
go to the next shrinker since the i915 shrinker couldn't acquire
required locks. But the SHRINK_STOP return code was added to the
->count_objects callback and not the ->scan_objects callback as it
should have been, resulting in tons of dmesg noise like

shrink_slab: i915_gem_inactive_scan+0x0/0x9c negative objects to delete nr=-xxxxxxxxx

Fix discusssed with Dave Chinner.

References: http://www.spinics.net/lists/intel-gfx/msg33597.html
Reported-by: Knut Petersen <Knut_Petersen@t-online.de>
Cc: Knut Petersen <Knut_Petersen@t-online.de>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Glauber Costa <glommer@openvz.org>
Cc: Glauber Costa <glommer@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Daniel Vetter <daniel.vetter@ffwll.ch>
---
 drivers/gpu/drm/i915/i915_gem.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index df9253d..cdfb9da 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -4800,10 +4800,10 @@ i915_gem_inactive_count(struct shrinker *shrinker, struct shrink_control *sc)
 
 	if (!mutex_trylock(&dev->struct_mutex)) {
 		if (!mutex_is_locked_by(&dev->struct_mutex, current))
-			return SHRINK_STOP;
+			return 0;
 
 		if (dev_priv->mm.shrinker_no_lock_stealing)
-			return SHRINK_STOP;
+			return 0;
 
 		unlock = false;
 	}
@@ -4901,10 +4901,10 @@ i915_gem_inactive_scan(struct shrinker *shrinker, struct shrink_control *sc)
 
 	if (!mutex_trylock(&dev->struct_mutex)) {
 		if (!mutex_is_locked_by(&dev->struct_mutex, current))
-			return 0;
+			return SHRINK_STOP;
 
 		if (dev_priv->mm.shrinker_no_lock_stealing)
-			return 0;
+			return SHRINK_STOP;
 
 		unlock = false;
 	}
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
