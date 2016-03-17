Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3B0EA6B0253
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 07:59:51 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id l68so223192088wml.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 04:59:51 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id w130si9402695wmb.63.2016.03.17.04.59.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Mar 2016 04:59:50 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id l68so13871821wml.3
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 04:59:50 -0700 (PDT)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH 2/2] drm/i915/shrinker: Hook up vmap allocation failure notifier
Date: Thu, 17 Mar 2016 11:59:42 +0000
Message-Id: <1458215982-13405-2-git-send-email-chris@chris-wilson.co.uk>
In-Reply-To: <1458215982-13405-1-git-send-email-chris@chris-wilson.co.uk>
References: <1458215982-13405-1-git-send-email-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: Chris Wilson <chris@chris-wilson.co.uk>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Roman Pen <r.peniaev@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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
---
 drivers/gpu/drm/i915/i915_drv.h          |  1 +
 drivers/gpu/drm/i915/i915_gem_shrinker.c | 39 ++++++++++++++++++++++++++++++++
 2 files changed, 40 insertions(+)

diff --git a/drivers/gpu/drm/i915/i915_drv.h b/drivers/gpu/drm/i915/i915_drv.h
index b9989d05f82a..4646b8504b84 100644
--- a/drivers/gpu/drm/i915/i915_drv.h
+++ b/drivers/gpu/drm/i915/i915_drv.h
@@ -1257,6 +1257,7 @@ struct i915_gem_mm {
 	struct i915_hw_ppgtt *aliasing_ppgtt;
 
 	struct notifier_block oom_notifier;
+	struct notifier_block vmap_notifier;
 	struct shrinker shrinker;
 	bool shrinker_no_lock_stealing;
 
diff --git a/drivers/gpu/drm/i915/i915_gem_shrinker.c b/drivers/gpu/drm/i915/i915_gem_shrinker.c
index d3c473ffb90a..54943f983dc4 100644
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
