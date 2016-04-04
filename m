Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f54.google.com (mail-lf0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id 13B40828DF
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 09:46:58 -0400 (EDT)
Received: by mail-lf0-f54.google.com with SMTP id c62so171487065lfc.1
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 06:46:57 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id ue7si16027801lbc.83.2016.04.04.06.46.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Apr 2016 06:46:56 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id c62so23812539lfc.2
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 06:46:56 -0700 (PDT)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH v2 3/3] drm/i915/shrinker: Hook up vmap allocation failure notifier
Date: Mon,  4 Apr 2016 14:46:43 +0100
Message-Id: <1459777603-23618-4-git-send-email-chris@chris-wilson.co.uk>
In-Reply-To: <1459777603-23618-1-git-send-email-chris@chris-wilson.co.uk>
References: <1459777603-23618-1-git-send-email-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: Chris Wilson <chris@chris-wilson.co.uk>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Roman Pen <r.peniaev@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Tvrtko Ursulin <tvrtko.ursulin@intel.com>, Mika Kahola <mika.kahola@intel.com>

If the core runs out of vmap address space, it will call a notifier in
case any driver can reap some of its vmaps. As i915.ko is possibily
holding onto vmap address space that could be recovered, hook into the
notifier chain and try and reap objects holding onto vmaps.

Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Roman Pen <r.peniaev@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Tvrtko Ursulin <tvrtko.ursulin@intel.com>
Cc: Mika Kahola <mika.kahola@intel.com>
---
 drivers/gpu/drm/i915/i915_drv.h          |  1 +
 drivers/gpu/drm/i915/i915_gem_shrinker.c | 39 ++++++++++++++++++++++++++++++++
 2 files changed, 40 insertions(+)

diff --git a/drivers/gpu/drm/i915/i915_drv.h b/drivers/gpu/drm/i915/i915_drv.h
index dd187727c813..6443745d4182 100644
--- a/drivers/gpu/drm/i915/i915_drv.h
+++ b/drivers/gpu/drm/i915/i915_drv.h
@@ -1257,6 +1257,7 @@ struct i915_gem_mm {
 	struct i915_hw_ppgtt *aliasing_ppgtt;
 
 	struct notifier_block oom_notifier;
+	struct notifier_block vmap_notifier;
 	struct shrinker shrinker;
 	bool shrinker_no_lock_stealing;
 
diff --git a/drivers/gpu/drm/i915/i915_gem_shrinker.c b/drivers/gpu/drm/i915/i915_gem_shrinker.c
index e391ee3ec486..be7501afb59e 100644
--- a/drivers/gpu/drm/i915/i915_gem_shrinker.c
+++ b/drivers/gpu/drm/i915/i915_gem_shrinker.c
@@ -28,6 +28,7 @@
 #include <linux/swap.h>
 #include <linux/pci.h>
 #include <linux/dma-buf.h>
+#include <linux/vmalloc.h>
 #include <drm/drmP.h>
 #include <drm/i915_drm.h>
 
@@ -356,6 +357,40 @@ i915_gem_shrinker_oom(struct notifier_block *nb, unsigned long event, void *ptr)
 	return NOTIFY_DONE;
 }
 
+static int
+i915_gem_shrinker_vmap(struct notifier_block *nb, unsigned long event, void *ptr)
+{
+	struct drm_i915_private *dev_priv =
+		container_of(nb, struct drm_i915_private, mm.vmap_notifier);
+	struct drm_device *dev = dev_priv->dev;
+	unsigned long timeout = msecs_to_jiffies(5000) + 1;
+	unsigned long freed_pages;
+	bool was_interruptible;
+	bool unlock;
+
+	while (!i915_gem_shrinker_lock(dev, &unlock) && --timeout) {
+		schedule_timeout_killable(1);
+		if (fatal_signal_pending(current))
+			return NOTIFY_DONE;
+	}
+	if (timeout == 0) {
+		pr_err("Unable to purge GPU vmaps due to lock contention.\n");
+		return NOTIFY_DONE;
+	}
+
+	was_interruptible = dev_priv->mm.interruptible;
+	dev_priv->mm.interruptible = false;
+
+	freed_pages = i915_gem_shrink_all(dev_priv);
+
+	dev_priv->mm.interruptible = was_interruptible;
+	if (unlock)
+		mutex_unlock(&dev->struct_mutex);
+
+	*(unsigned long *)ptr += freed_pages;
+	return NOTIFY_DONE;
+}
+
 /**
  * i915_gem_shrinker_init - Initialize i915 shrinker
  * @dev_priv: i915 device
@@ -371,6 +406,9 @@ void i915_gem_shrinker_init(struct drm_i915_private *dev_priv)
 
 	dev_priv->mm.oom_notifier.notifier_call = i915_gem_shrinker_oom;
 	WARN_ON(register_oom_notifier(&dev_priv->mm.oom_notifier));
+
+	dev_priv->mm.vmap_notifier.notifier_call = i915_gem_shrinker_vmap;
+	WARN_ON(register_vmap_purge_notifier(&dev_priv->mm.vmap_notifier));
 }
 
 /**
@@ -381,6 +419,7 @@ void i915_gem_shrinker_init(struct drm_i915_private *dev_priv)
  */
 void i915_gem_shrinker_cleanup(struct drm_i915_private *dev_priv)
 {
+	WARN_ON(unregister_vmap_purge_notifier(&dev_priv->mm.vmap_notifier));
 	WARN_ON(unregister_oom_notifier(&dev_priv->mm.oom_notifier));
 	unregister_shrinker(&dev_priv->mm.shrinker);
 }
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
