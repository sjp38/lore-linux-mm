Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 263446B0070
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 21:27:31 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id jt11so9473817pbb.12
        for <linux-mm@kvack.org>; Fri, 04 Jan 2013 18:27:30 -0800 (PST)
From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v7 2/6] PM / Runtime: introduce pm_runtime_set_memalloc_noio()
Date: Sat,  5 Jan 2013 10:25:40 +0800
Message-Id: <1357352744-8138-3-git-send-email-ming.lei@canonical.com>
In-Reply-To: <1357352744-8138-1-git-send-email-ming.lei@canonical.com>
References: <1357352744-8138-1-git-send-email-ming.lei@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Ming Lei <ming.lei@canonical.com>

The patch introduces the flag of memalloc_noio in 'struct dev_pm_info'
to help PM core to teach mm not allocating memory with GFP_KERNEL
flag for avoiding probable deadlock.

As explained in the comment, any GFP_KERNEL allocation inside
runtime_resume() or runtime_suspend() on any one of device in
the path from one block or network device to the root device
in the device tree may cause deadlock, the introduced
pm_runtime_set_memalloc_noio() sets or clears the flag on
device in the path recursively.

Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
--
v7:
	- optimize on pm_runtime_set_memalloc_noio(true)

v5:
	- fix code style error
	- add comment on clear the device memalloc_noio flag
v4:
	- rename memalloc_noio_resume as memalloc_noio
	- remove pm_runtime_get_memalloc_noio()
	- add comments on pm_runtime_set_memalloc_noio
v3:
	- introduce pm_runtime_get_memalloc_noio()
	- hold one global lock on pm_runtime_set_memalloc_noio
	- hold device power lock when accessing memalloc_noio_resume
	  flag suggested by Alan Stern
	- implement pm_runtime_set_memalloc_noio without recursion
	  suggested by Alan Stern
v2:
	- introduce pm_runtime_set_memalloc_noio()
---
 drivers/base/power/runtime.c |   70 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/pm.h           |    1 +
 include/linux/pm_runtime.h   |    3 ++
 3 files changed, 74 insertions(+)

diff --git a/drivers/base/power/runtime.c b/drivers/base/power/runtime.c
index 3148b10..cd92e1c 100644
--- a/drivers/base/power/runtime.c
+++ b/drivers/base/power/runtime.c
@@ -124,6 +124,76 @@ unsigned long pm_runtime_autosuspend_expiration(struct device *dev)
 }
 EXPORT_SYMBOL_GPL(pm_runtime_autosuspend_expiration);
 
+static int dev_memalloc_noio(struct device *dev, void *data)
+{
+	return dev->power.memalloc_noio;
+}
+
+/*
+ * pm_runtime_set_memalloc_noio - Set a device's memalloc_noio flag.
+ * @dev: Device to handle.
+ * @enable: True for setting the flag and False for clearing the flag.
+ *
+ * Set the flag for all devices in the path from the device to the
+ * root device in the device tree if @enable is true, otherwise clear
+ * the flag for devices in the path whose siblings don't set the flag.
+ *
+ * The function should only be called by block device, or network
+ * device driver for solving the deadlock problem during runtime
+ * resume/suspend:
+ *
+ *     If memory allocation with GFP_KERNEL is called inside runtime
+ *     resume/suspend callback of any one of its ancestors(or the
+ *     block device itself), the deadlock may be triggered inside the
+ *     memory allocation since it might not complete until the block
+ *     device becomes active and the involed page I/O finishes. The
+ *     situation is pointed out first by Alan Stern. Network device
+ *     are involved in iSCSI kind of situation.
+ *
+ * The lock of dev_hotplug_mutex is held in the function for handling
+ * hotplug race because pm_runtime_set_memalloc_noio() may be called
+ * in async probe().
+ *
+ * The function should be called between device_add() and device_del()
+ * on the affected device(block/network device).
+ */
+void pm_runtime_set_memalloc_noio(struct device *dev, bool enable)
+{
+	static DEFINE_MUTEX(dev_hotplug_mutex);
+
+	mutex_lock(&dev_hotplug_mutex);
+	for (;;) {
+		bool enabled;
+
+		/* hold power lock since bitfield is not SMP-safe. */
+		spin_lock_irq(&dev->power.lock);
+		enabled = dev->power.memalloc_noio;
+		dev->power.memalloc_noio = enable;
+		spin_unlock_irq(&dev->power.lock);
+
+		/*
+		 * not need to enable ancestors any more if the device
+		 * has been enabled.
+		 */
+		if (enabled && enable)
+			break;
+
+		dev = dev->parent;
+
+		/*
+		 * clear flag of the parent device only if all the
+		 * children don't set the flag because ancestor's
+		 * flag was set by any one of the descendants.
+		 */
+		if (!dev || (!enable &&
+			     device_for_each_child(dev, NULL,
+						   dev_memalloc_noio)))
+			break;
+	}
+	mutex_unlock(&dev_hotplug_mutex);
+}
+EXPORT_SYMBOL_GPL(pm_runtime_set_memalloc_noio);
+
 /**
  * rpm_check_suspend_allowed - Test whether a device may be suspended.
  * @dev: Device to test.
diff --git a/include/linux/pm.h b/include/linux/pm.h
index 03d7bb1..1a8a69d 100644
--- a/include/linux/pm.h
+++ b/include/linux/pm.h
@@ -538,6 +538,7 @@ struct dev_pm_info {
 	unsigned int		irq_safe:1;
 	unsigned int		use_autosuspend:1;
 	unsigned int		timer_autosuspends:1;
+	unsigned int		memalloc_noio:1;
 	enum rpm_request	request;
 	enum rpm_status		runtime_status;
 	int			runtime_error;
diff --git a/include/linux/pm_runtime.h b/include/linux/pm_runtime.h
index f271860..775e063 100644
--- a/include/linux/pm_runtime.h
+++ b/include/linux/pm_runtime.h
@@ -47,6 +47,7 @@ extern void pm_runtime_set_autosuspend_delay(struct device *dev, int delay);
 extern unsigned long pm_runtime_autosuspend_expiration(struct device *dev);
 extern void pm_runtime_update_max_time_suspended(struct device *dev,
 						 s64 delta_ns);
+extern void pm_runtime_set_memalloc_noio(struct device *dev, bool enable);
 
 static inline bool pm_children_suspended(struct device *dev)
 {
@@ -149,6 +150,8 @@ static inline void pm_runtime_set_autosuspend_delay(struct device *dev,
 						int delay) {}
 static inline unsigned long pm_runtime_autosuspend_expiration(
 				struct device *dev) { return 0; }
+static inline void pm_runtime_set_memalloc_noio(struct device *dev,
+						bool enable){}
 
 #endif /* !CONFIG_PM_RUNTIME */
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
