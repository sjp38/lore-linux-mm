Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 61B2F6B000C
	for <linux-mm@kvack.org>; Sun, 27 Jan 2013 19:38:36 -0500 (EST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RESEND PATCH v5 3/4] zram: give up lazy initialization of zram metadata
Date: Mon, 28 Jan 2013 09:38:25 +0900
Message-Id: <1359333506-13599-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1359333506-13599-1-git-send-email-minchan@kernel.org>
References: <1359333506-13599-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan@kernel.org>, Jerome Marchand <jmarchan@redhat.com>

1) User of zram normally do mkfs.xxx or mkswap before using
   the zram block device(ex, normally, do it at booting time)
   It ends up allocating such metadata of zram before real usage so
   benefit of lazy initialzation would be mitigated.

2) Some user want to use zram when memory pressure is high.(ie, load zram
   dynamically, NOT booting time). It does make sense because people don't
   want to waste memory until memory pressure is high(ie, where zram is really
   helpful time). In this case, lazy initialzation could be failed easily
   because we will use GFP_NOIO instead of GFP_KERNEL for avoiding deadlock.
   So the benefit of lazy initialzation would be mitigated, too.

3) Metadata overhead is not critical and Nitin has a plan to diet it.
   4K : 12 byte(64bit machine) -> 64G : 192M so 0.3% isn't big overhead
   If insane user use such big zram device up to 20, it could consume 6% of ram
   but efficieny of zram will cover the waste.

So this patch gives up lazy initialization and instead we initialize metadata
at disksize setting time.

Cc: Jerome Marchand <jmarchan@redhat.com>
Acked-by: Nitin Gupta <ngupta@vflare.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zram/zram_drv.c   |   20 ++++----------------
 drivers/staging/zram/zram_sysfs.c |    1 +
 2 files changed, 5 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
index f8ae1bf..4264121 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -440,16 +440,13 @@ static void zram_make_request(struct request_queue *queue, struct bio *bio)
 {
 	struct zram *zram = queue->queuedata;
 
-	if (unlikely(!zram->init_done) && zram_init_device(zram))
-		goto error;
-
 	down_read(&zram->init_lock);
 	if (unlikely(!zram->init_done))
-		goto error_unlock;
+		goto error;
 
 	if (!valid_io_request(zram, bio)) {
 		zram_stat64_inc(zram, &zram->stats.invalid_io);
-		goto error_unlock;
+		goto error;
 	}
 
 	__zram_make_request(zram, bio, bio_data_dir(bio));
@@ -457,9 +454,8 @@ static void zram_make_request(struct request_queue *queue, struct bio *bio)
 
 	return;
 
-error_unlock:
-	up_read(&zram->init_lock);
 error:
+	up_read(&zram->init_lock);
 	bio_io_error(bio);
 }
 
@@ -508,18 +504,12 @@ void zram_reset_device(struct zram *zram)
 	up_write(&zram->init_lock);
 }
 
+/* zram->init_lock should be held */
 int zram_init_device(struct zram *zram)
 {
 	int ret;
 	size_t num_pages;
 
-	down_write(&zram->init_lock);
-
-	if (zram->init_done) {
-		up_write(&zram->init_lock);
-		return 0;
-	}
-
 	if (zram->disksize > 2 * (totalram_pages << PAGE_SHIFT)) {
 		pr_info(
 		"There is little point creating a zram of greater than "
@@ -568,7 +558,6 @@ int zram_init_device(struct zram *zram)
 	}
 
 	zram->init_done = 1;
-	up_write(&zram->init_lock);
 
 	pr_debug("Initialization done!\n");
 	return 0;
@@ -578,7 +567,6 @@ fail_no_table:
 	zram->disksize = 0;
 fail:
 	__zram_reset_device(zram);
-	up_write(&zram->init_lock);
 	pr_err("Initialization failed: err=%d\n", ret);
 	return ret;
 }
diff --git a/drivers/staging/zram/zram_sysfs.c b/drivers/staging/zram/zram_sysfs.c
index 4143af9..369db12 100644
--- a/drivers/staging/zram/zram_sysfs.c
+++ b/drivers/staging/zram/zram_sysfs.c
@@ -71,6 +71,7 @@ static ssize_t disksize_store(struct device *dev,
 
 	zram->disksize = PAGE_ALIGN(disksize);
 	set_capacity(zram->disk, zram->disksize >> SECTOR_SHIFT);
+	zram_init_device(zram);
 	up_write(&zram->init_lock);
 
 	return len;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
