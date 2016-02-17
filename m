Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f178.google.com (mail-yw0-f178.google.com [209.85.161.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8AE596B0009
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 09:33:24 -0500 (EST)
Received: by mail-yw0-f178.google.com with SMTP id g127so16244329ywf.2
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 06:33:24 -0800 (PST)
Received: from mail-yw0-x249.google.com (mail-yw0-x249.google.com. [2607:f8b0:4002:c05::249])
        by mx.google.com with ESMTPS id a128si917811ybb.245.2016.02.24.06.33.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 06:33:23 -0800 (PST)
Received: by mail-yw0-x249.google.com with SMTP id g127so1238767ywf.0
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 06:33:23 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 17 Feb 2016 10:48:40 +0100
Message-ID: <001a113a54a4baa464052c84f2dc@google.com>
Subject: [RFC] mm: vmpressure: dynamic window sizing.
From: Martijn Coenen <maco@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org
Cc: Anton Vorontsov <anton@enomsg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-kernel@vger.kernel.org

The window size used for calculating vm pressure events was
previously fixed at 512 pages. The window size has a big
impact on the rate of notifications sent off to userspace,
in particular when using the "low" level. On machines with
a lot of memory, the current value is likely excessive. On
the other hand, if the window size is too big, we might
delay memory pressure events for too long, especially at
critical levels of memory pressure.

This patch attempts to address that problem with two changes.

The first change is to calculate the window size
based on the machine size, quite similar to how the vm
watermarks are being calculated. This reduces the chance
of false positives at any pressure level. Using the machine
size only makes sense on the root cgroup though; for non-root
cgroups, their hard memory limit is used to calculate the
window size. If no hard memory limit is set, we fall back to
the default window size that was previously used.

The second change is based on an idea from Johannes Weiner, to
only report medium and low pressure levels for every
X windows that we scan. This reduces the frequency with
which we report low/medium pressure levels, but at the same
time will still report critical memory pressure immediately.

Some potential items for discussion are:
- Instead of having a counter for the number of windows
   that we encountered a particular pressure level, we could
   have separate windows per pressure level, each with a different
   size and its own scanned/reclaimed counters. This averages the
   windows better, but it made the code quite a bit more complex.
- What to do with non-root cgroups for which no limit is set?
   In some cases, a parent of that cgroup may have a limit set,
   but it's still hard to reason about what constitutes pressure
   in this case. Using the (low) default value seems like a safe
   option here.
- When setting a new memory limit on a memory cgroup, we only tell
   vmpressure about the new limit once we have reclaimed enough pages
   to fit the cgroup in the new limit. It could be argued that the
   limit should already be updated while we're trying to reclaim memory
   from that cgroup, since it's that exact reclaim which could be causing
   pressure on the cgroup.

Signed-off-by: Martijn Coenen <maco@google.com>
---
  include/linux/vmpressure.h |  36 +++++++++++--
  mm/memcontrol.c            |  10 ++--
  mm/vmpressure.c            | 122  
+++++++++++++++++++++++++++++++++++----------
  3 files changed, 135 insertions(+), 33 deletions(-)

diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
index 3347cc3..ca9bbf2 100644
--- a/include/linux/vmpressure.h
+++ b/include/linux/vmpressure.h
@@ -9,13 +9,41 @@
  #include <linux/cgroup.h>
  #include <linux/eventfd.h>

+enum vmpressure_levels {
+	VMPRESSURE_LOW = 0,
+	VMPRESSURE_MEDIUM,
+	VMPRESSURE_CRITICAL,
+	VMPRESSURE_NUM_LEVELS,
+};
+
  struct vmpressure {
+	/*
+	 * The window size is the number of scanned pages before
+	 * we try to analyze scanned/reclaimed ratio. Using small window
+	 * sizes can cause lot of false positives, but too big window size will
+	 * delay the notifications.
+	 *
+	 * In order to reduce the amount of false positives for low and medium
+	 * levels, those levels aren't reported until we've seen multipl
+	 * windows at those respective pressure levels. This makes sure
+	 * sure that we don't delay notifications when encountering critical
+	 * levels of memory pressure, but also don't spam userspace in case
+	 * nothing serious is going on. The number of windows seen at each
+	 * pressure level is kept in nr_windows below.
+	 *
+	 * For the root mem cgroup, the window size is computed based on the
+	 * total amount of pages available in the system. For non-root cgroups,
+	 * we compute the window size based on the hard memory limit, or if
+	 * that is not set, we fall back to the default window size.
+	 */
+	unsigned long window_size;
+	/* The number of windows we've seen each pressure level occur for */
+	unsigned int nr_windows[VMPRESSURE_NUM_LEVELS];
  	unsigned long scanned;
  	unsigned long reclaimed;
-
  	unsigned long tree_scanned;
  	unsigned long tree_reclaimed;
-	/* The lock is used to keep the scanned/reclaimed above in sync. */
+	/* The lock is used to keep the members above in sync. */
  	struct spinlock sr_lock;

  	/* The list of vmpressure_event structs. */
@@ -33,10 +61,12 @@ extern void vmpressure(gfp_t gfp, struct mem_cgroup  
*memcg, bool tree,
  		       unsigned long scanned, unsigned long reclaimed);
  extern void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio);

-extern void vmpressure_init(struct vmpressure *vmpr);
+extern void vmpressure_init(struct vmpressure *vmpr, bool is_root);
  extern void vmpressure_cleanup(struct vmpressure *vmpr);
  extern struct vmpressure *memcg_to_vmpressure(struct mem_cgroup *memcg);
  extern struct cgroup_subsys_state *vmpressure_to_css(struct vmpressure  
*vmpr);
+extern void vmpressure_update_mem_limit(struct mem_cgroup *memcg,
+					unsigned long new_limit);
  extern int vmpressure_register_event(struct mem_cgroup *memcg,
  				     struct eventfd_ctx *eventfd,
  				     const char *args);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d06cae2..ffc3ba6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2516,8 +2516,10 @@ static int mem_cgroup_resize_limit(struct mem_cgroup  
*memcg,
  		ret = page_counter_limit(&memcg->memory, limit);
  		mutex_unlock(&memcg_limit_mutex);

-		if (!ret)
+		if (!ret) {
+			vmpressure_update_mem_limit(memcg, limit);
  			break;
+		}

  		try_to_free_mem_cgroup_pages(memcg, 1, GFP_KERNEL, true);

@@ -4144,7 +4146,7 @@ static void mem_cgroup_free(struct mem_cgroup *memcg)
  	kfree(memcg);
  }

-static struct mem_cgroup *mem_cgroup_alloc(void)
+static struct mem_cgroup *mem_cgroup_alloc(bool is_root)
  {
  	struct mem_cgroup *memcg;
  	size_t size;
@@ -4173,7 +4175,7 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
  	INIT_LIST_HEAD(&memcg->oom_notify);
  	mutex_init(&memcg->thresholds_lock);
  	spin_lock_init(&memcg->move_lock);
-	vmpressure_init(&memcg->vmpressure);
+	vmpressure_init(&memcg->vmpressure, is_root);
  	INIT_LIST_HEAD(&memcg->event_list);
  	spin_lock_init(&memcg->event_list_lock);
  	memcg->socket_pressure = jiffies;
@@ -4196,7 +4198,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state  
*parent_css)
  	struct mem_cgroup *memcg;
  	long error = -ENOMEM;

-	memcg = mem_cgroup_alloc();
+	memcg = mem_cgroup_alloc(!parent);
  	if (!memcg)
  		return ERR_PTR(error);

diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 149fdf6..99dfb26 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -25,20 +25,21 @@
  #include <linux/vmpressure.h>

  /*
- * The window size (vmpressure_win) is the number of scanned pages before
- * we try to analyze scanned/reclaimed ratio. So the window is used as a
- * rate-limit tunable for the "low" level notification, and also for
- * averaging the ratio for medium/critical levels. Using small window
- * sizes can cause lot of false positives, but too big window size will
- * delay the notifications.
- *
- * As the vmscan reclaimer logic works with chunks which are multiple of
- * SWAP_CLUSTER_MAX, it makes sense to use it for the window size as well.
- *
- * TODO: Make the window size depend on machine size, as we do for vmstat
- * thresholds. Currently we set it to 512 pages (2MB for 4KB pages).
+ * The amount of windows we need to see for each pressure level before
+ * reporting an event for that pressure level.
   */
-static const unsigned long vmpressure_win = SWAP_CLUSTER_MAX * 16;
+static const int const vmpressure_windows_needed[] = {
+	[VMPRESSURE_LOW] = 4,
+	[VMPRESSURE_MEDIUM] = 2,
+	[VMPRESSURE_CRITICAL] = 1,
+};
+
+/**
+ * In case we can't compute a window size for a cgroup, because it's
+ * not the root or it doesn't have a limit set, fall back to the
+ * default window size, which is 512 pages (2MB for 4KB pages).
+ */
+static const unsigned long default_window_size = SWAP_CLUSTER_MAX * 16;

  /*
   * These thresholds are used when we account memory pressure through
@@ -86,13 +87,6 @@ static struct vmpressure *vmpressure_parent(struct  
vmpressure *vmpr)
  	return memcg_to_vmpressure(memcg);
  }

-enum vmpressure_levels {
-	VMPRESSURE_LOW = 0,
-	VMPRESSURE_MEDIUM,
-	VMPRESSURE_CRITICAL,
-	VMPRESSURE_NUM_LEVELS,
-};
-
  static const char * const vmpressure_str_levels[] = {
  	[VMPRESSURE_LOW] = "low",
  	[VMPRESSURE_MEDIUM] = "medium",
@@ -162,6 +156,7 @@ static void vmpressure_work_fn(struct work_struct *work)
  	unsigned long scanned;
  	unsigned long reclaimed;
  	enum vmpressure_levels level;
+	bool report = false;

  	spin_lock(&vmpr->sr_lock);
  	/*
@@ -181,9 +176,15 @@ static void vmpressure_work_fn(struct work_struct  
*work)
  	reclaimed = vmpr->tree_reclaimed;
  	vmpr->tree_scanned = 0;
  	vmpr->tree_reclaimed = 0;
-	spin_unlock(&vmpr->sr_lock);

  	level = vmpressure_calc_level(scanned, reclaimed);
+	if (++vmpr->nr_windows[level] == vmpressure_windows_needed[level]) {
+		vmpr->nr_windows[level] = 0;
+		report = true;
+	}
+	spin_unlock(&vmpr->sr_lock);
+	if (!report)
+		return;

  	do {
  		if (vmpressure_event(vmpr, level))
@@ -195,6 +196,34 @@ static void vmpressure_work_fn(struct work_struct  
*work)
  	} while ((vmpr = vmpressure_parent(vmpr)));
  }

+static void vmpressure_update_window_size(struct vmpressure *vmpr,
+					  unsigned long total_pages)
+{
+	spin_lock(&vmpr->sr_lock);
+	/*
+	 * This is inspired by the low watermark computation:
+	 * We want a small window size for small machines, but don't
+	 * grow linearly, since users may want to do cache management
+	 * at a finer granularity.
+	 *
+	 * Using sqrt(8 * total_pages) yields the following:
+	 *
+	 * 16MB:	724k
+	 * 32MB:	1024k
+	 * 64MB:	1448k
+	 * 128MB:	2048k
+	 * 256MB:	2896k
+	 * 512MB:	4096k
+	 * 1024MB:	5792k
+	 * 2048MB:	8192k
+	 * 4096MB:	11584k
+	 * 8192MB:	16384k
+	 * 16384MB:	23170k
+	 */
+	vmpr->window_size = int_sqrt(total_pages * 8);
+	spin_unlock(&vmpr->sr_lock);
+}
+
  /**
   * vmpressure() - Account memory pressure through scanned/reclaimed ratio
   * @gfp:	reclaimer's gfp mask
@@ -247,12 +276,14 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,  
bool tree,
  		return;

  	if (tree) {
+		unsigned long window_size;
  		spin_lock(&vmpr->sr_lock);
  		scanned = vmpr->tree_scanned += scanned;
  		vmpr->tree_reclaimed += reclaimed;
+		window_size = vmpr->window_size;
  		spin_unlock(&vmpr->sr_lock);

-		if (scanned < vmpressure_win)
+		if (scanned < window_size)
  			return;
  		schedule_work(&vmpr->work);
  	} else {
@@ -265,7 +296,7 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,  
bool tree,
  		spin_lock(&vmpr->sr_lock);
  		scanned = vmpr->scanned += scanned;
  		reclaimed = vmpr->reclaimed += reclaimed;
-		if (scanned < vmpressure_win) {
+		if (scanned < vmpr->window_size) {
  			spin_unlock(&vmpr->sr_lock);
  			return;
  		}
@@ -301,6 +332,8 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,  
bool tree,
   */
  void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio)
  {
+	struct vmpressure *vmpr;
+	unsigned long window_size;
  	/*
  	 * We only use prio for accounting critical level. For more info
  	 * see comment for vmpressure_level_critical_prio variable above.
@@ -308,14 +341,40 @@ void vmpressure_prio(gfp_t gfp, struct mem_cgroup  
*memcg, int prio)
  	if (prio > vmpressure_level_critical_prio)
  		return;

+	vmpr = memcg_to_vmpressure(memcg);
+	spin_lock(&vmpr->sr_lock);
+	window_size = vmpr->window_size;
+	spin_unlock(&vmpr->sr_lock);
  	/*
  	 * OK, the prio is below the threshold, updating vmpressure
  	 * information before shrinker dives into long shrinking of long
-	 * range vmscan. Passing scanned = vmpressure_win, reclaimed = 0
+	 * range vmscan. Passing scanned = window size, reclaimed = 0
  	 * to the vmpressure() basically means that we signal 'critical'
  	 * level.
  	 */
-	vmpressure(gfp, memcg, true, vmpressure_win, 0);
+	vmpressure(gfp, memcg, true, window_size, 0);
+}
+
+/**
+ * vmpressure_update_mem_limit() - Lets vmpressure know about a new memory  
limit
+ * @memcg:	cgroup for which the limit is being updated
+ * @limit:	new limit in pages
+ *
+ * This function lets vmpressure know the memory limit for a specific  
cgroup
+ * was changed. This allows us to compute new window sizes for this cgroup.
+ */
+void vmpressure_update_mem_limit(struct mem_cgroup *memcg,
+				 unsigned long limit)
+{
+	struct vmpressure *vmpr = memcg_to_vmpressure(memcg);
+
+	/* Clamp to number of pages above the watermark, to avoid creating
+	 * way too large windows when erroneously high limits are set.
+	 */
+	if (limit > nr_free_pagecache_pages())
+		limit = nr_free_pagecache_pages();
+
+	vmpressure_update_window_size(vmpr, limit);
  }

  /**
@@ -396,12 +455,23 @@ void vmpressure_unregister_event(struct mem_cgroup  
*memcg,
   * This function should be called on every allocated vmpressure structure
   * before any usage.
   */
-void vmpressure_init(struct vmpressure *vmpr)
+void vmpressure_init(struct vmpressure *vmpr, bool is_root)
  {
  	spin_lock_init(&vmpr->sr_lock);
  	mutex_init(&vmpr->events_lock);
  	INIT_LIST_HEAD(&vmpr->events);
  	INIT_WORK(&vmpr->work, vmpressure_work_fn);
+	if (is_root) {
+		/* For the root mem cgroup, compute the window size
+		 * based on the total amount of memory in the machine.
+		 */
+		vmpressure_update_window_size(vmpr, nr_free_pagecache_pages());
+	} else {
+		/* Use default window size, until a hard limit is set
+		 * on this cgroup.
+		 */
+		vmpr->window_size = default_window_size;
+	}
  }

  /**
-- 
2.7.0.rc3.207.g0ac5344

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
