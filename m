Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id D00AB6B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 09:38:15 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id fl12so8872026pdb.6
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 06:38:15 -0800 (PST)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id su9si2083630pab.162.2015.01.23.06.38.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jan 2015 06:38:14 -0800 (PST)
Received: by mail-pd0-f170.google.com with SMTP id p10so8913153pdj.1
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 06:38:14 -0800 (PST)
Date: Fri, 23 Jan 2015 23:38:49 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH 2/2] zram: protect zram->stat race with init_lock
Message-ID: <20150123143849.GB2320@swordfish>
References: <1421992707-32658-1-git-send-email-minchan@kernel.org>
 <1421992707-32658-2-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421992707-32658-2-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (01/23/15 14:58), Minchan Kim wrote:
> The zram->stat handling should be procted by init_lock.
> Otherwise, user could see stale value from the stat.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
> 
> I don't think it's stable material. The race is rare in real practice
> and this stale stat value read is not a critical.
> 
>  drivers/block/zram/zram_drv.c | 37 ++++++++++++++++++++++++++++---------
>  1 file changed, 28 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index 0299d82275e7..53f176f590b0 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -48,8 +48,13 @@ static ssize_t name##_show(struct device *d,		\
>  				struct device_attribute *attr, char *b)	\
>  {									\

a side note: I wasn't Cc'd in that patchset and found out it only when it's
been merged. I'm not sure I understand, why it has been renamed from specific
zram_X_show to X_show. what gives?


can't help, catches my eye every time, that rename has broken the original
formatting:


diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 9250b3f..c567af5 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -44,7 +44,7 @@ static const char *default_compressor = "lzo";
 static unsigned int num_devices = 1;
 
 #define ZRAM_ATTR_RO(name)						\
-static ssize_t name##_show(struct device *d,		\
+static ssize_t name##_show(struct device *d,				\
 				struct device_attribute *attr, char *b)	\
 {									\
 	struct zram *zram = dev_to_zram(d);				\



I don't have any objections. but do we really want to wrap atomic ops in
semaphore? it is really such serious race?


	-ss

>  	struct zram *zram = dev_to_zram(d);				\
> -	return scnprintf(b, PAGE_SIZE, "%llu\n",			\
> -		(u64)atomic64_read(&zram->stats.name));			\
> +	u64 val = 0;							\
> +									\
> +	down_read(&zram->init_lock);					\
> +	if (init_done(zram))						\
> +		val = atomic64_read(&zram->stats.name);			\
> +	up_read(&zram->init_lock);					\
> +	return scnprintf(b, PAGE_SIZE, "%llu\n", val);			\
>  }									\
>  static DEVICE_ATTR_RO(name);
>  
> @@ -67,8 +72,14 @@ static ssize_t disksize_show(struct device *dev,
>  		struct device_attribute *attr, char *buf)
>  {
>  	struct zram *zram = dev_to_zram(dev);
> +	u64 val = 0;
> +
> +	down_read(&zram->init_lock);
> +	if (init_done(zram))
> +		val = zram->disksize;
> +	up_read(&zram->init_lock);
>  
> -	return scnprintf(buf, PAGE_SIZE, "%llu\n", zram->disksize);
> +	return scnprintf(buf, PAGE_SIZE, "%llu\n", val);
>  }
>  
>  static ssize_t initstate_show(struct device *dev,
> @@ -88,9 +99,14 @@ static ssize_t orig_data_size_show(struct device *dev,
>  		struct device_attribute *attr, char *buf)
>  {
>  	struct zram *zram = dev_to_zram(dev);
> +	u64 val = 0;
> +
> +	down_read(&zram->init_lock);
> +	if (init_done(zram))
> +		val = atomic64_read(&zram->stats.pages_stored) << PAGE_SHIFT;
> +	up_read(&zram->init_lock);
>  
> -	return scnprintf(buf, PAGE_SIZE, "%llu\n",
> -		(u64)(atomic64_read(&zram->stats.pages_stored)) << PAGE_SHIFT);
> +	return scnprintf(buf, PAGE_SIZE, "%llu\n", val);
>  }
>  
>  static ssize_t mem_used_total_show(struct device *dev,
> @@ -957,10 +973,6 @@ static int zram_rw_page(struct block_device *bdev, sector_t sector,
>  	struct bio_vec bv;
>  
>  	zram = bdev->bd_disk->private_data;
> -	if (!valid_io_request(zram, sector, PAGE_SIZE)) {
> -		atomic64_inc(&zram->stats.invalid_io);
> -		return -EINVAL;
> -	}
>  
>  	down_read(&zram->init_lock);
>  	if (unlikely(!init_done(zram))) {
> @@ -968,6 +980,13 @@ static int zram_rw_page(struct block_device *bdev, sector_t sector,
>  		goto out_unlock;
>  	}
>  
> +	if (!valid_io_request(zram, sector, PAGE_SIZE)) {
> +		atomic64_inc(&zram->stats.invalid_io);
> +		err = -EINVAL;
> +		goto out_unlock;
> +	}
> +
> +
>  	index = sector >> SECTORS_PER_PAGE_SHIFT;
>  	offset = sector & (SECTORS_PER_PAGE - 1) << SECTOR_SHIFT;
>  
> -- 
> 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
