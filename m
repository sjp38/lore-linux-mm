Subject: Re: 2.5.65-mm3
From: Robert Love <rml@tech9.net>
In-Reply-To: <20030320235821.1e4ff308.akpm@digeo.com>
References: <20030320235821.1e4ff308.akpm@digeo.com>
Content-Type: text/plain
Message-Id: <1048277871.4908.36.camel@phantasy.awol.org>
Mime-Version: 1.0
Date: 21 Mar 2003 15:17:52 -0500
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2003-03-21 at 02:58, Andrew Morton wrote:

> dev_t-3-major_h-cleanup.patch
>   dev_t [3/3]: major.h cleanups
> 
> dev_t-32-bit.patch
>   [for playing only] change type of dev_t

Now that dev_t is an unsigned long, MKDEV() correspondingly returns an
unsigned long.  This causes a compiler warning and potential bug on
64-bit architectures in drivers/scsi/sg.c :: sg_device_kdev_read().

This patch needs to be applied on top of the dev_t patches.

	Robert Love


 drivers/scsi/sg.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)


diff -urN linux-2.5.65-mm3/drivers/scsi/sg.c linux/drivers/scsi/sg.c
--- linux-2.5.65-mm3/drivers/scsi/sg.c	2003-03-17 16:44:05.000000000 -0500
+++ linux/drivers/scsi/sg.c	2003-03-19 11:35:50.706607408 -0500
@@ -1331,9 +1331,11 @@
 sg_device_kdev_read(struct device *driverfs_dev, char *page)
 {
 	Sg_device *sdp = list_entry(driverfs_dev, Sg_device, sg_driverfs_dev);
-	return sprintf(page, "%x\n", MKDEV(sdp->disk->major,
-					   sdp->disk->first_minor));
+
+	return sprintf(page, "%lx\n", MKDEV(sdp->disk->major,
+					sdp->disk->first_minor));
 }
+
 static DEVICE_ATTR(kdev,S_IRUGO,sg_device_kdev_read,NULL);
 
 static ssize_t



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
