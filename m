Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 9AAE66B00C3
	for <linux-mm@kvack.org>; Sat, 15 Nov 2014 04:19:01 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id v10so18206701pde.32
        for <linux-mm@kvack.org>; Sat, 15 Nov 2014 01:19:01 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id y15si30512686pdj.67.2014.11.15.01.19.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 15 Nov 2014 01:19:00 -0800 (PST)
Received: by mail-pa0-f50.google.com with SMTP id eu11so18909772pac.23
        for <linux-mm@kvack.org>; Sat, 15 Nov 2014 01:18:59 -0800 (PST)
Date: Sat, 15 Nov 2014 18:19:21 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] zram: rely on the bi_end_io for zram_rw_page fails
Message-ID: <20141115091921.GA1046@swordfish>
References: <1415926147-9023-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1415926147-9023-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <matthew.r.wilcox@intel.com>, Karam Lee <karam.lee@lge.com>, Dave Chinner <david@fromorbit.com>

Hi,

On (11/14/14 09:49), Minchan Kim wrote:
> When I tested zram, I found processes got segfaulted.
> The reason was zram_rw_page doesn't make the page dirty
> again when swap write failed, and even it doesn't return
> error by [1].
> 
> If error by zram internal happens, zram_rw_page should return
> non-zero without calling page_endio.
> It causes resubmit the IO with bio so that it ends up calling
> bio->bi_end_io.
> 
> The reason is zram could be used for a block device for FS and
> swap, which they uses different bio complete callback, which
> works differently. So, we should rely on the bio I/O complete
> handler rather than zram_bvec_rw itself in case of I/O fail.
> 
> This patch fixes the segfault issue as well one [1]'s
> mentioned
> 
> [1] zram: make rw_page opeartion return 0
> 
> Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
> Cc: Karam Lee <karam.lee@lge.com>
> Cc: Dave Chinner <david@fromorbit.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  drivers/block/zram/zram_drv.c | 8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index 4b4f4dbc3cfd..0e0650feab2a 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -978,12 +978,10 @@ static int zram_rw_page(struct block_device *bdev, sector_t sector,
>  out_unlock:
>  	up_read(&zram->init_lock);
>  out:
> -	page_endio(page, rw, err);
> +	if (unlikely(err))
> +		return err;

this unlikely() case can be turned into a likely() one:

	if (err == 0)
		page_endio(page, rw, 0);
	return err;

> -	/*
> -	 * Return 0 prevents I/O fallback trial caused by rw_page fail
> -	 * and upper layer can handle this IO error via page error.
> -	 */
> +	page_endio(page, rw, 0);
>  	return 0;
>  }

seems like we also can drop at least one goto (jump-to-return) for
invalid request.

(not sure about `goto out_unblock', yet another up_read(&zram->init_lock)
just will make function bigger).

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

---

 drivers/block/zram/zram_drv.c | 13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 0e0650f..decca6f 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -956,8 +956,7 @@ static int zram_rw_page(struct block_device *bdev, sector_t sector,
 	zram = bdev->bd_disk->private_data;
 	if (!valid_io_request(zram, sector, PAGE_SIZE)) {
 		atomic64_inc(&zram->stats.invalid_io);
-		err = -EINVAL;
-		goto out;
+		return -EINVAL;
 	}
 
 	down_read(&zram->init_lock);
@@ -974,15 +973,11 @@ static int zram_rw_page(struct block_device *bdev, sector_t sector,
 	bv.bv_offset = 0;
 
 	err = zram_bvec_rw(zram, &bv, index, offset, rw);
-
 out_unlock:
 	up_read(&zram->init_lock);
-out:
-	if (unlikely(err))
-		return err;
-
-	page_endio(page, rw, 0);
-	return 0;
+	if (err == 0)
+		page_endio(page, rw, 0);
+	return err;
 }
 
 static const struct block_device_operations zram_devops = {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
