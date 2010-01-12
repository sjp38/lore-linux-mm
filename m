Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8E7776B007B
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 23:59:05 -0500 (EST)
Received: by yxe10 with SMTP id 10so17321232yxe.12
        for <linux-mm@kvack.org>; Mon, 11 Jan 2010 20:59:03 -0800 (PST)
Subject: [PATCH] Fix reset of ramzswap
From: "minchan.kim" <minchan.kim@gmail.com>
Content-Type: text/plain
Date: Tue, 12 Jan 2010 13:36:58 +0900
Message-Id: <1263271018.23507.8.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>, Nitin Gupta <ngupta@vflare.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

ioctl(cmd=reset)
	-> bd_holder check (if whoever hold bdev, return -EBUSY)
	-> ramzswap_ioctl_reset_device
		-> reset_device
			-> bd_release

bd_release is called by reset_device.
but ramzswap_ioctl always checks bd_holder before
reset_device. it means reset ioctl always fails.

This patch fixes it.

This patch is based on mmotm-2010-01-06-14-34 + 
[PATCH] Free memory when create_device is failed.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Cc: Nitin Gupta <ngupta@vflare.org>
---
 drivers/staging/ramzswap/ramzswap_drv.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/ramzswap/ramzswap_drv.c b/drivers/staging/ramzswap/ramzswap_drv.c
index 18196f3..42531bd 100644
--- a/drivers/staging/ramzswap/ramzswap_drv.c
+++ b/drivers/staging/ramzswap/ramzswap_drv.c
@@ -1270,11 +1270,6 @@ static int ramzswap_ioctl(struct block_device *bdev, fmode_t mode,
 		break;
 
 	case RZSIO_RESET:
-		/* Do not reset an active device! */
-		if (bdev->bd_holders) {
-			ret = -EBUSY;
-			goto out;
-		}
 		ret = ramzswap_ioctl_reset_device(rzs);
 		break;
 
-- 
1.5.6.3


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
