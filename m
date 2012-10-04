Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id A72546B0100
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 07:08:16 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so469275pad.14
        for <linux-mm@kvack.org>; Thu, 04 Oct 2012 04:08:16 -0700 (PDT)
Date: Thu, 4 Oct 2012 04:05:24 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [RFC] vmevent: Implement pressure attribute
Message-ID: <20121004110524.GA1821@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>
Cc: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, Colin Cross <ccross@android.com>, Arve =?utf-8?B?SGrDuG5uZXbDpWc=?= <arve@android.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

Hi all,

This is just an RFC so far. It's an attempt to implement Mel Gorman's idea
of detecting and measuring memory pressure by calculating the ratio of
scanned vs. reclaimed pages in a given time frame.

The implemented approach can notify userland about two things:

- Constantly rising number of scanned pages shows that Linux is busy w/
  rehashing pages in general. The more we scan, the more it's obvious that
  we're out of unused pages, and we're draining caches. By itself it's not
  critical, but for apps that want to maintain caches level (like Android)
  it's quite useful. The notifications are ratelimited by a specified
  amount of scanned pages.

- Next, we calculate pressure using '100 - reclaimed/scanned * 100'
  formula. The value shows (in percents) how efficiently the kernel
  reclaims pages. If we take number of scanned pages and think of them as
  a time scale, then these percents basically would show us how much of
  the time Linux is spending to find reclaimable pages. 0% means that
  every page is a candidate for reclaim, 100% means that MM is not
  recliaming at all, it spends all the time scanning and desperately
  trying to find something to reclaim. The more time we're at the high
  percentage level, the more chances that we'll OOM soon.

So, if we fail to find a page in a reasonable time frame, we're obviously
in trouble, no matter how much reclaimable memory we actually have --
we're too slow, and so we'd better free something.

Although it must be noted that the pressure factor might be affected by
reclaimable vs. non-reclaimable pages "fragmentation" in an LRU. If
there's a "hole" of reclaimable memory in an almost-OOMed system, the
factor will drop temporary. On the other hand, it just shows how
efficiently Linux is keeping the lists, it might be pretty inefficient,
and the factor will show it.

Some more notes:

- Although the scheme sounds good, I noticed that reclaimer 'priority'
  level (i.e. scanning depth) better responds to pressure (it's more
  smooth), and so far I'm not sure how to make the original idea to work
  on a par w/ sc->priority level.

- I have an idea, which I might want to try some day. Currently, the
  pressure callback is hooked into the inactive list reclaim path, it's
  the last step in the 'to be reclaimed' page's life time. But we could
  measure 'active -> inactive' migration speed, i.e. pages deactivation
  rate. Or we could measure inactive/active LRU size ratio, ideally
  behaving system would try to keep the ratio near 1, and it'll be close
  to 0 when inactive list is getting short (for anon LRU it'd be not 1,
  but zone->inactive_ratio actually).

Thanks,
Anton.

---
 include/linux/vmevent.h |  36 ++++++++++
 mm/vmevent.c            | 179 +++++++++++++++++++++++++++++++++++++++++++++++-
 mm/vmscan.c             |   4 ++
 3 files changed, 218 insertions(+), 1 deletion(-)

diff --git a/include/linux/vmevent.h b/include/linux/vmevent.h
index b1c4016..1397ade 100644
--- a/include/linux/vmevent.h
+++ b/include/linux/vmevent.h
@@ -10,6 +10,7 @@ enum {
 	VMEVENT_ATTR_NR_AVAIL_PAGES	= 1UL,
 	VMEVENT_ATTR_NR_FREE_PAGES	= 2UL,
 	VMEVENT_ATTR_NR_SWAP_PAGES	= 3UL,
+	VMEVENT_ATTR_PRESSURE		= 4UL,
 
 	VMEVENT_ATTR_MAX		/* non-ABI */
 };
@@ -46,6 +47,11 @@ struct vmevent_attr {
 	__u64			value;
 
 	/*
+	 * Some attributes accept two configuration values.
+	 */
+	__u64			value2;
+
+	/*
 	 * Type of profiled attribute from VMEVENT_ATTR_XXX
 	 */
 	__u32			type;
@@ -97,4 +103,34 @@ struct vmevent_event {
 	struct vmevent_attr	attrs[];
 };
 
+#ifdef __KERNEL__
+
+struct mem_cgroup;
+
+extern void __vmevent_pressure(struct mem_cgroup *memcg,
+			       ulong scanned,
+			       ulong reclaimed);
+
+static inline void vmevent_pressure(struct mem_cgroup *memcg,
+				    ulong scanned,
+				    ulong reclaimed)
+{
+	if (!scanned)
+		return;
+
+	if (IS_BUILTIN(CONFIG_MEMCG) && memcg) {
+		/*
+		 * The vmevent API reports system pressure, for per-cgroup
+		 * pressure, we'll chain cgroups notifications, this is to
+		 * be implemented.
+		 *
+		 * memcg_vm_pressure(target_mem_cgroup, scanned, reclaimed);
+		 */
+		return;
+	}
+	__vmevent_pressure(memcg, scanned, reclaimed);
+}
+
+#endif
+
 #endif /* _LINUX_VMEVENT_H */
diff --git a/mm/vmevent.c b/mm/vmevent.c
index d643615..12d0131 100644
--- a/mm/vmevent.c
+++ b/mm/vmevent.c
@@ -4,6 +4,7 @@
 #include <linux/vmevent.h>
 #include <linux/syscalls.h>
 #include <linux/workqueue.h>
+#include <linux/interrupt.h>
 #include <linux/file.h>
 #include <linux/list.h>
 #include <linux/poll.h>
@@ -30,6 +31,25 @@ struct vmevent_watch {
 	wait_queue_head_t		waitq;
 };
 
+struct vmevent_pwatcher {
+	struct vmevent_watch *watch;
+	struct vmevent_attr *attr;
+	struct vmevent_attr *samp;
+	struct list_head node;
+
+	uint scanned;
+	uint reclaimed;
+	uint window;
+};
+
+static LIST_HEAD(vmevent_pwatchers);
+static DEFINE_SPINLOCK(vmevent_pwatchers_lock);
+
+static uint vmevent_scanned;
+static uint vmevent_reclaimed;
+static uint vmevent_minwin = UINT_MAX; /* Smallest window in the list. */
+static DEFINE_SPINLOCK(vmevent_pressure_lock);
+
 typedef u64 (*vmevent_attr_sample_fn)(struct vmevent_watch *watch,
 				      struct vmevent_attr *attr);
 
@@ -141,6 +161,10 @@ static bool vmevent_match(struct vmevent_watch *watch)
 		struct vmevent_attr *samp = &watch->sample_attrs[i];
 		u64 val;
 
+		/* Pressure is event-driven, not polled */
+		if (attr->type == VMEVENT_ATTR_PRESSURE)
+			continue;
+
 		val = vmevent_sample_attr(watch, attr);
 		if (!ret && vmevent_match_attr(attr, val))
 			ret = 1;
@@ -204,6 +228,94 @@ static void vmevent_start_timer(struct vmevent_watch *watch)
 	vmevent_schedule_watch(watch);
 }
 
+static ulong vmevent_calc_pressure(struct vmevent_pwatcher *pw)
+{
+	uint win = pw->window;
+	uint s = pw->scanned;
+	uint r = pw->reclaimed;
+	ulong p;
+
+	/*
+	 * We calculate the ratio (in percents) of how many pages were
+	 * scanned vs. reclaimed in a given time frame (window). Note that
+	 * time is in VM reclaimer's "ticks", i.e. number of pages
+	 * scanned. This makes it possible set desired reaction time and
+	 * serves as a ratelimit.
+	 */
+	p = win - (r * win / s);
+	p = p * 100 / win;
+
+	pr_debug("%s: %3lu  (s: %6u  r: %6u)\n", __func__, p, s, r);
+
+	return p;
+}
+
+static void vmevent_match_pressure(struct vmevent_pwatcher *pw)
+{
+	struct vmevent_watch *watch = pw->watch;
+	struct vmevent_attr *attr = pw->attr;
+	ulong val;
+
+	val = vmevent_calc_pressure(pw);
+
+	/* Next round. */
+	pw->scanned = 0;
+	pw->reclaimed = 0;
+
+	if (!vmevent_match_attr(attr, val))
+		return;
+
+	pw->samp->value = val;
+
+	atomic_set(&watch->pending, 1);
+	wake_up(&watch->waitq);
+}
+
+static void vmevent_pressure_tlet_fn(ulong data)
+{
+	struct vmevent_pwatcher *pw;
+	uint s;
+	uint r;
+
+	if (!vmevent_scanned)
+		return;
+
+	spin_lock(&vmevent_pressure_lock);
+	s = vmevent_scanned;
+	r = vmevent_reclaimed;
+	vmevent_scanned = 0;
+	vmevent_reclaimed = 0;
+	spin_unlock(&vmevent_pressure_lock);
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(pw, &vmevent_pwatchers, node) {
+		pw->scanned += s;
+		pw->reclaimed += r;
+		if (pw->scanned >= pw->window)
+			vmevent_match_pressure(pw);
+	}
+	rcu_read_unlock();
+}
+static DECLARE_TASKLET(vmevent_pressure_tlet, vmevent_pressure_tlet_fn, 0);
+
+void __vmevent_pressure(struct mem_cgroup *memcg,
+			ulong scanned,
+			ulong reclaimed)
+{
+	if (vmevent_minwin == UINT_MAX)
+		return;
+
+	spin_lock_bh(&vmevent_pressure_lock);
+
+	vmevent_scanned += scanned;
+	vmevent_reclaimed += reclaimed;
+
+	if (vmevent_scanned >= vmevent_minwin)
+		tasklet_schedule(&vmevent_pressure_tlet);
+
+	spin_unlock_bh(&vmevent_pressure_lock);
+}
+
 static unsigned int vmevent_poll(struct file *file, poll_table *wait)
 {
 	struct vmevent_watch *watch = file->private_data;
@@ -259,12 +371,40 @@ out:
 	return ret;
 }
 
+static void vmevent_release_pwatcher(struct vmevent_watch *watch)
+{
+	struct vmevent_pwatcher *pw;
+	struct vmevent_pwatcher *tmp;
+	struct vmevent_pwatcher *del = NULL;
+	int last = 1;
+
+	spin_lock(&vmevent_pwatchers_lock);
+
+	list_for_each_entry_safe(pw, tmp, &vmevent_pwatchers, node) {
+		if (pw->watch != watch) {
+			vmevent_minwin = min(pw->window, vmevent_minwin);
+			last = 0;
+			continue;
+		}
+		WARN_ON(del);
+		list_del_rcu(&pw->node);
+		del = pw;
+	}
+
+	if (last)
+		vmevent_minwin = UINT_MAX;
+
+	spin_unlock(&vmevent_pwatchers_lock);
+	synchronize_rcu();
+	kfree(del);
+}
+
 static int vmevent_release(struct inode *inode, struct file *file)
 {
 	struct vmevent_watch *watch = file->private_data;
 
 	cancel_delayed_work_sync(&watch->work);
-
+	vmevent_release_pwatcher(watch);
 	kfree(watch);
 
 	return 0;
@@ -289,6 +429,36 @@ static struct vmevent_watch *vmevent_watch_alloc(void)
 	return watch;
 }
 
+static int vmevent_setup_pwatcher(struct vmevent_watch *watch,
+				  struct vmevent_attr *attr,
+				  struct vmevent_attr *samp)
+{
+	struct vmevent_pwatcher *pw;
+
+	if (attr->type != VMEVENT_ATTR_PRESSURE)
+		return 0;
+
+	if (!attr->value2)
+		return -EINVAL;
+
+	pw = kzalloc(sizeof(*pw), GFP_KERNEL);
+	if (!pw)
+		return -ENOMEM;
+
+	pw->watch = watch;
+	pw->attr = attr;
+	pw->samp = samp;
+	pw->window = (attr->value2 + PAGE_SIZE - 1) / PAGE_SIZE;
+
+	vmevent_minwin = min(pw->window, vmevent_minwin);
+
+	spin_lock(&vmevent_pwatchers_lock);
+	list_add_rcu(&pw->node, &vmevent_pwatchers);
+	spin_unlock(&vmevent_pwatchers_lock);
+
+	return 0;
+}
+
 static int vmevent_setup_watch(struct vmevent_watch *watch)
 {
 	struct vmevent_config *config = &watch->config;
@@ -302,6 +472,7 @@ static int vmevent_setup_watch(struct vmevent_watch *watch)
 		struct vmevent_attr *attr = &config->attrs[i];
 		size_t size;
 		void *new;
+		int ret;
 
 		if (attr->type >= VMEVENT_ATTR_MAX)
 			continue;
@@ -322,6 +493,12 @@ static int vmevent_setup_watch(struct vmevent_watch *watch)
 
 		watch->config_attrs[nr] = attr;
 
+		ret = vmevent_setup_pwatcher(watch, attr, &attrs[nr]);
+		if (ret) {
+			kfree(attrs);
+			return ret;
+		}
+
 		nr++;
 	}
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 99b434b..f4dd1e0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -20,6 +20,7 @@
 #include <linux/init.h>
 #include <linux/highmem.h>
 #include <linux/vmstat.h>
+#include <linux/vmevent.h>
 #include <linux/file.h>
 #include <linux/writeback.h>
 #include <linux/blkdev.h>
@@ -1334,6 +1335,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		nr_scanned, nr_reclaimed,
 		sc->priority,
 		trace_shrink_flags(file));
+
+	vmevent_pressure(sc->target_mem_cgroup, nr_scanned, nr_reclaimed);
+
 	return nr_reclaimed;
 }
 
-- 
1.7.12.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
