Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 7F7F26B005A
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 06:15:05 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so3078709pbb.14
        for <linux-mm@kvack.org>; Fri, 12 Oct 2012 03:15:04 -0700 (PDT)
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 2/3] mm: vmevent: Use value2 for setting vmstat thresholds
Date: Fri, 12 Oct 2012 03:11:58 -0700
Message-Id: <1350036719-29031-2-git-send-email-anton.vorontsov@linaro.org>
In-Reply-To: <20121012101115.GA11825@lizard>
References: <20121012101115.GA11825@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

Attributes that use vmstat can now use attr->value2 to specify an optional
accuracy. Based on the provided value, we will setup appropriate vmstat
thresholds.

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 include/linux/vmevent.h |  5 +++++
 mm/vmevent.c            | 56 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 61 insertions(+)

diff --git a/include/linux/vmevent.h b/include/linux/vmevent.h
index b1c4016..b8c1394 100644
--- a/include/linux/vmevent.h
+++ b/include/linux/vmevent.h
@@ -46,6 +46,11 @@ struct vmevent_attr {
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
diff --git a/mm/vmevent.c b/mm/vmevent.c
index 8c0fbe6..8113bda 100644
--- a/mm/vmevent.c
+++ b/mm/vmevent.c
@@ -28,8 +28,13 @@ struct vmevent_watch {
 
 	/* poll */
 	wait_queue_head_t		waitq;
+
+	struct list_head node;
 };
 
+static LIST_HEAD(vmevent_watchers);
+static DEFINE_SPINLOCK(vmevent_watchers_lock);
+
 typedef u64 (*vmevent_attr_sample_fn)(struct vmevent_watch *watch,
 				      struct vmevent_attr *attr);
 
@@ -259,12 +264,57 @@ out:
 	return ret;
 }
 
+#ifdef CONFIG_SMP
+
+static void vmevent_set_thresholds(void)
+{
+	struct vmevent_watch *w;
+	struct zone *zone;
+	u64 thres = ULLONG_MAX;
+
+	spin_lock(&vmevent_watchers_lock);
+
+	list_for_each_entry(w, &vmevent_watchers, node) {
+		int i;
+
+		for (i = 0; i < w->config.counter; i++) {
+			struct vmevent_attr *attr = &w->config.attrs[i];
+
+			if (attr->type != VMEVENT_ATTR_NR_FREE_PAGES)
+				continue;
+			if (!attr->value2)
+				continue;
+			thres = min(thres, attr->value2);
+		}
+	}
+
+	if (thres == ULLONG_MAX)
+		thres = 0;
+
+	thres = (thres + PAGE_SIZE - 1) / PAGE_SIZE;
+
+	for_each_populated_zone(zone)
+		set_zone_stat_thresholds(zone, NULL, thres);
+
+	spin_unlock(&vmevent_watchers_lock);
+}
+
+#else
+static inline void vmevent_set_thresholds(void) {}
+#endif /* CONFIG_SMP */
+
 static int vmevent_release(struct inode *inode, struct file *file)
 {
 	struct vmevent_watch *watch = file->private_data;
 
 	cancel_delayed_work_sync(&watch->work);
 
+	spin_lock(&vmevent_watchers_lock);
+	list_del(&watch->node);
+	spin_unlock(&vmevent_watchers_lock);
+
+	vmevent_set_thresholds();
+
 	kfree(watch);
 
 	return 0;
@@ -328,6 +378,10 @@ static int vmevent_setup_watch(struct vmevent_watch *watch)
 	watch->sample_attrs	= attrs;
 	watch->nr_attrs		= nr;
 
+	spin_lock(&vmevent_watchers_lock);
+	list_add(&watch->node, &vmevent_watchers);
+	spin_unlock(&vmevent_watchers_lock);
+
 	return 0;
 }
 
@@ -363,6 +417,8 @@ SYSCALL_DEFINE1(vmevent_fd,
 	if (err)
 		goto err_free;
 
+	vmevent_set_thresholds();
+
 	fd = get_unused_fd_flags(O_RDONLY);
 	if (fd < 0) {
 		err = fd;
-- 
1.7.12.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
