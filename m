Message-Id: <20060912144904.869344000@chello.nl>
References: <20060912143049.278065000@chello.nl>
Subject: [PATCH 17/20] scsi: propagate the swapdev hook into the scsi stack
Content-Disposition: inline; filename=scsi_swapdev.patch
Date: Tue, 12 Sep 2006 17:25:49 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, David Miller <davem@davemloft.net>, Rik van Riel <riel@redhat.com>, Daniel Phillips <phillips@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "James E.J. Bottomley" <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>
List-ID: <linux-mm.kvack.org>

Allow scsi devices to receive the swapdev notification.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: James E.J. Bottomley <James.Bottomley@SteelEye.com>
CC: Mike Christie <michaelc@cs.wisc.edu>
---
 drivers/scsi/sd.c        |   13 +++++++++++++
 include/scsi/scsi_host.h |    7 +++++++
 2 files changed, 20 insertions(+)

Index: linux-2.6/drivers/scsi/sd.c
===================================================================
--- linux-2.6.orig/drivers/scsi/sd.c
+++ linux-2.6/drivers/scsi/sd.c
@@ -892,6 +892,18 @@ static long sd_compat_ioctl(struct file 
 }
 #endif
 
+static int sd_swapdev(struct gendisk *disk, int enable)
+{
+	int error = 0;
+	struct scsi_disk *sdkp = scsi_disk(disk);
+	struct scsi_device *sdp = sdkp->device;
+
+	if (sdp->host->hostt->swapdev)
+		error = sdp->host->hostt->swapdev(sdp, enable);
+
+	return error;
+}
+
 static struct block_device_operations sd_fops = {
 	.owner			= THIS_MODULE,
 	.open			= sd_open,
@@ -903,6 +915,7 @@ static struct block_device_operations sd
 #endif
 	.media_changed		= sd_media_changed,
 	.revalidate_disk	= sd_revalidate_disk,
+	.swapdev		= sd_swapdev,
 };
 
 /**
Index: linux-2.6/include/scsi/scsi_host.h
===================================================================
--- linux-2.6.orig/include/scsi/scsi_host.h
+++ linux-2.6/include/scsi/scsi_host.h
@@ -288,6 +288,13 @@ struct scsi_host_template {
 	int (*suspend)(struct scsi_device *, pm_message_t state);
 
 	/*
+	 * Notify that this device is used for swapping.
+	 *
+	 * Status: OPTIONAL
+	 */
+	int (*swapdev)(struct scsi_device *, int enable);
+
+	/*
 	 * Name of proc directory
 	 */
 	char *proc_name;

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
