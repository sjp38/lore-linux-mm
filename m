Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 6EA136B0070
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 04:35:22 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so1880654pad.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 01:35:22 -0700 (PDT)
From: Ming Lei <ming.lei@canonical.com>
Subject: [RFC PATCH v2 2/6] PM / Runtime: introduce pm_runtime_set_memalloc_noio()
Date: Mon, 22 Oct 2012 16:33:10 +0800
Message-Id: <1350894794-1494-3-git-send-email-ming.lei@canonical.com>
In-Reply-To: <1350894794-1494-1-git-send-email-ming.lei@canonical.com>
References: <1350894794-1494-1-git-send-email-ming.lei@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@canonical.com>

The patch introduces the flag of memalloc_noio_resume in
'struct dev_pm_info' to help PM core to teach mm not allocating
memory with GFP_KERNEL flag for avoiding probable deadlock
problem.

As explained in the comment, any GFP_KERNEL allocation inside
runtime_resume on any one of device in the path from one block
or network device to the root device in the device tree may cause
deadlock, the introduced pm_runtime_set_memalloc_noio() sets or
clears the flag on device of the path recursively.

Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/base/power/runtime.c |   53 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/pm.h           |    1 +
 include/linux/pm_runtime.h   |    3 +++
 3 files changed, 57 insertions(+)

diff --git a/drivers/base/power/runtime.c b/drivers/base/power/runtime.c
index 3148b10..a75eeca 100644
--- a/drivers/base/power/runtime.c
+++ b/drivers/base/power/runtime.c
@@ -124,6 +124,59 @@ unsigned long pm_runtime_autosuspend_expiration(struct device *dev)
 }
 EXPORT_SYMBOL_GPL(pm_runtime_autosuspend_expiration);
 
+static int dev_memalloc_noio(struct device *dev, void *data)
+{
+	if (dev->power.memalloc_noio_resume)
+		return 1;
+	return 0;
+}
+
+/*
+ * pm_runtime_set_memalloc_noio - Set a device's memalloc_noio flag.
+ * @dev: Device to handle.
+ * @enable: True for setting the flag and False for clearing the flag.
+ *
+ * Set the flag for all devices in the path from the device to the
+ * root device in the device tree if @enable is true, otherwise clear
+ * the flag for devices in the path which sibliings don't set the flag.
+ *
+ * The function should only be called by block device, or network
+ * device driver for solving the deadlock problem during runtime
+ * resume:
+ * 	if memory allocation with GFP_KERNEL is called inside runtime
+ * 	resume callback of any one of its ancestors(or the block device
+ * 	itself), the deadlock may be triggered inside the memory
+ * 	allocation since it might not complete until the block device
+ * 	becomes active and the involed page I/O finishes. The situation
+ * 	is pointed out first by Alan Stern. Network device are involved
+ * 	in iSCSI kind of situation.
+ *
+ * No lock is provovided in the function for handling hotplog race
+ * because pm_runtime_set_memalloc_noio(false) is called in parent's
+ * remove path.
+ */
+void pm_runtime_set_memalloc_noio(struct device *dev, bool enable)
+{
+	dev->power.memalloc_noio_resume = enable;
+
+	if (!dev->parent)
+		return;
+
+	if (enable) {
+		pm_runtime_set_memalloc_noio(dev->parent, 1);
+	} else {
+		/* only clear the flag for one device if all
+		 * children of the device don't set the flag.
+		 */
+		if (device_for_each_child(dev->parent, NULL,
+					  dev_memalloc_noio))
+			return;
+
+		pm_runtime_set_memalloc_noio(dev->parent, 0);
+	}
+}
+EXPORT_SYMBOL_GPL(pm_runtime_set_memalloc_noio);
+
 /**
  * rpm_check_suspend_allowed - Test whether a device may be suspended.
  * @dev: Device to test.
diff --git a/include/linux/pm.h b/include/linux/pm.h
index 007e687..5b0ee4d 100644
--- a/include/linux/pm.h
+++ b/include/linux/pm.h
@@ -538,6 +538,7 @@ struct dev_pm_info {
 	unsigned int		irq_safe:1;
 	unsigned int		use_autosuspend:1;
 	unsigned int		timer_autosuspends:1;
+	unsigned int		memalloc_noio_resume:1;
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
