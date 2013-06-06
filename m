Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 657B56B0073
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 16:35:28 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v11 21/25] i915: bail out earlier when shrinker cannot acquire mutex
Date: Fri,  7 Jun 2013 00:34:54 +0400
Message-Id: <1370550898-26711-22-git-send-email-glommer@openvz.org>
In-Reply-To: <1370550898-26711-1-git-send-email-glommer@openvz.org>
References: <1370550898-26711-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <koverstreet@google.com>

The main shrinker driver will keep trying for a while to free objects if
the returned value from the shrink scan procedure is 0.  That means "no
objects now", but a retry could very well succeed.

But what we should say here is a different thing: that it is impossible to
shrink, and we would better bail out soon. We find this behavior more
appropriate for the case where the lock cannot be taken. Specially given the
hammer behavior of the i915: if another thread is already shrinking, we are
likely not to be able to shrink anything anyway when we finally acquire the
mutex.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Acked-by: Daniel Vetter <daniel.vetter@ffwll.ch>
CC: Dave Chinner <dchinner@redhat.com>
CC: Mel Gorman <mgorman@suse.de>
CC: Kent Overstreet <koverstreet@google.com>
---
 drivers/gpu/drm/i915/i915_gem.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 22a0556..101504f 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -4497,10 +4497,10 @@ i915_gem_inactive_count(struct shrinker *shrinker, struct shrink_control *sc)
 
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
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
