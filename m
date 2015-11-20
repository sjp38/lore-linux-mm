Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 81CB16B0253
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 17:13:24 -0500 (EST)
Received: by qkao63 with SMTP id o63so41242335qka.2
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 14:13:24 -0800 (PST)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0082.outbound.protection.outlook.com. [65.55.169.82])
        by mx.google.com with ESMTPS id 61si1587407qgz.37.2015.11.20.14.13.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 20 Nov 2015 14:13:23 -0800 (PST)
From: Bart Van Assche <bart.vanassche@sandisk.com>
Subject: [PATCH] Fix a bdi reregistration race, v2
Message-ID: <564F9AFF.3050605@sandisk.com>
Date: Fri, 20 Nov 2015 14:13:19 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <jbottomley@parallels.com>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>, Jens Axboe <axboe@fb.com>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Hannes
 Reinecke <hare@suse.de>, Aaro Koskinen <aaro.koskinen@iki.fi>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, linux-mm@kvack.org

Unregister and reregister BDI devices in the proper order. This patch
avoids that the following kernel warning can be triggered during
SCSI device reregistration:

WARNING: CPU: 7 PID: 203 at fs/sysfs/dir.c:31 sysfs_warn_dup+0x68/0x80()
sysfs: cannot create duplicate filename '/devices/virtual/bdi/8:32'
Workqueue: events_unbound async_run_entry_fn
Call Trace:
[<ffffffff814ff5a4>] dump_stack+0x4c/0x65
[<ffffffff810746ba>] warn_slowpath_common+0x8a/0xc0
[<ffffffff81074736>] warn_slowpath_fmt+0x46/0x50
[<ffffffff81237ca8>] sysfs_warn_dup+0x68/0x80
[<ffffffff81237d8e>] sysfs_create_dir_ns+0x7e/0x90
[<ffffffff81291f58>] kobject_add_internal+0xa8/0x320
[<ffffffff812923a0>] kobject_add+0x60/0xb0
[<ffffffff8138c937>] device_add+0x107/0x5e0
[<ffffffff8138d018>] device_create_groups_vargs+0xd8/0x100
[<ffffffff8138d05c>] device_create_vargs+0x1c/0x20
[<ffffffff8117f233>] bdi_register+0x63/0x2a0
[<ffffffff8117f497>] bdi_register_dev+0x27/0x30
[<ffffffff81281549>] add_disk+0x1a9/0x4e0
[<ffffffffa00c5739>] sd_probe_async+0x119/0x1d0 [sd_mod]
[<ffffffff8109a81a>] async_run_entry_fn+0x4a/0x140
[<ffffffff81091078>] process_one_work+0x1d8/0x7c0
[<ffffffff81091774>] worker_thread+0x114/0x460
[<ffffffff81097878>] kthread+0xf8/0x110
[<ffffffff8150801f>] ret_from_fork+0x3f/0x70

Signed-off-by: Bart Van Assche <bart.vanassche@sandisk.com>
Cc: Jens Axboe <axboe@fb.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Hannes Reinecke <hare@suse.de>
Cc: Aaro Koskinen <aaro.koskinen@iki.fi>
Cc: <stable@vger.kernel.org>
---
 drivers/scsi/scsi_sysfs.c        |  2 ++
 include/linux/backing-dev-defs.h |  1 +
 include/linux/backing-dev.h      |  1 +
 mm/backing-dev.c                 | 28 ++++++++++++++++++++++++++--
 4 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/drivers/scsi/scsi_sysfs.c b/drivers/scsi/scsi_sysfs.c
index f5ace2b..8d64518 100644
--- a/drivers/scsi/scsi_sysfs.c
+++ b/drivers/scsi/scsi_sysfs.c
@@ -12,6 +12,7 @@
 #include <linux/blkdev.h>
 #include <linux/device.h>
 #include <linux/pm_runtime.h>
+#include <linux/backing-dev.h>
 
 #include <scsi/scsi.h>
 #include <scsi/scsi_device.h>
@@ -1110,6 +1111,7 @@ void __scsi_remove_device(struct scsi_device *sdev)
 		device_unregister(&sdev->sdev_dev);
 		transport_remove_device(dev);
 		scsi_dh_remove_device(sdev);
+		bdi_sysfs_del(&sdev->request_queue->backing_dev_info);
 		device_del(dev);
 	} else
 		put_device(&sdev->sdev_dev);
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 1b4d69f..1a42ecb 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -135,6 +135,7 @@ struct bdi_writeback {
 
 struct backing_dev_info {
 	struct list_head bdi_list;
+	bool is_visible;
 	unsigned long ra_pages;	/* max readahead in PAGE_CACHE_SIZE units */
 	unsigned int capabilities; /* Device capabilities */
 	congested_fn *congested_fn; /* Function pointer if device is md/dm */
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index c82794f..9004d90 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -24,6 +24,7 @@ __printf(3, 4)
 int bdi_register(struct backing_dev_info *bdi, struct device *parent,
 		const char *fmt, ...);
 int bdi_register_dev(struct backing_dev_info *bdi, dev_t dev);
+void bdi_sysfs_del(struct backing_dev_info *bdi);
 void bdi_unregister(struct backing_dev_info *bdi);
 
 int __must_check bdi_setup_and_register(struct backing_dev_info *, char *);
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 8ed2ffd..b56971f 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -774,6 +774,7 @@ int bdi_init(struct backing_dev_info *bdi)
 	int ret;
 
 	bdi->dev = NULL;
+	bdi->is_visible = false;
 
 	bdi->min_ratio = 0;
 	bdi->max_ratio = 100;
@@ -806,6 +807,7 @@ int bdi_register(struct backing_dev_info *bdi, struct device *parent,
 		return PTR_ERR(dev);
 
 	bdi->dev = dev;
+	bdi->is_visible = true;
 
 	bdi_debug_register(bdi, dev_name(dev));
 	set_bit(WB_registered, &bdi->wb.state);
@@ -837,6 +839,28 @@ static void bdi_remove_from_list(struct backing_dev_info *bdi)
 	synchronize_rcu_expedited();
 }
 
+/**
+ * bdi_sysfs_del - remove a BDI device from sysfs
+ * @bdi: BDI device pointer.
+ *
+ * It is safe to call this function more than once.
+ */
+void bdi_sysfs_del(struct backing_dev_info *bdi)
+{
+	bool is_visible = false;
+
+	spin_lock_bh(&bdi_lock);
+	swap(bdi->is_visible, is_visible);
+	spin_unlock_bh(&bdi_lock);
+
+	if (!is_visible)
+		return;
+
+	bdi_debug_unregister(bdi);
+	device_del(bdi->dev);
+}
+EXPORT_SYMBOL(bdi_sysfs_del);
+
 void bdi_unregister(struct backing_dev_info *bdi)
 {
 	/* make sure nobody finds us on the bdi_list anymore */
@@ -845,8 +869,8 @@ void bdi_unregister(struct backing_dev_info *bdi)
 	cgwb_bdi_destroy(bdi);
 
 	if (bdi->dev) {
-		bdi_debug_unregister(bdi);
-		device_unregister(bdi->dev);
+		bdi_sysfs_del(bdi);
+		put_device(bdi->dev);
 		bdi->dev = NULL;
 	}
 }
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
