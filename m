Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id A69336B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 08:48:53 -0500 (EST)
Received: by mail-oi0-f45.google.com with SMTP id g201so26691864oib.4
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 05:48:53 -0800 (PST)
Received: from mail-oi0-x22b.google.com (mail-oi0-x22b.google.com. [2607:f8b0:4003:c06::22b])
        by mx.google.com with ESMTPS id p127si3787805oif.127.2015.01.29.05.48.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 05:48:52 -0800 (PST)
Received: by mail-oi0-f43.google.com with SMTP id z81so26728772oif.2
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 05:48:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1422432945-6764-2-git-send-email-minchan@kernel.org>
References: <1422432945-6764-1-git-send-email-minchan@kernel.org>
	<1422432945-6764-2-git-send-email-minchan@kernel.org>
Date: Thu, 29 Jan 2015 21:48:51 +0800
Message-ID: <CADAEsF9tejvCL3gqGuYKsnv_wsfpsESsAg=Hm3r_ZfbpftE4-w@mail.gmail.com>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello, Minchan:

2015-01-28 16:15 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> Admin could reset zram during I/O operation going on so we have
> used zram->init_lock as read-side lock in I/O path to prevent
> sudden zram meta freeing.

When I/O operation is running, that means the /dev/zram0 is
mounted or swaped on. Then the device could not be reset by
below code:

    /* Do not reset an active device! */
    if (bdev->bd_holders) {
        ret = -EBUSY;
        goto out;
    }

So the zram->init_lock in I/O path is to check whether the device
has been initialized(echo xxx > /sys/block/zram/disk_size).

Is that right?

>
> However, the init_lock is really troublesome.
> We can't do call zram_meta_alloc under init_lock due to lockdep splat

I do not know much about the lockdep.

enabled the CONFIG_LOCKDEP, But from the test, there is no warning
printed. Could you please tell me how this happened?

Thanks.

> because zram_rw_page is one of the function under reclaim path and
> hold it as read_lock while other places in process context hold it
> as write_lock. So, we have used allocation out of the lock to avoid
> lockdep warn but it's not good for readability and fainally, I met
> another lockdep splat between init_lock and cpu_hotpulug from
> kmem_cache_destroy during wokring zsmalloc compaction. :(
>
> Yes, the ideal is to remove horrible init_lock of zram in rw path.
> This patch removes it in rw path and instead, put init_done bool
> variable to check initialization done with smp_[wmb|rmb] and
> srcu_[un]read_lock to prevent sudden zram meta freeing
> during I/O operation.
>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  drivers/block/zram/zram_drv.c | 85 +++++++++++++++++++++++++++++++------------
>  drivers/block/zram/zram_drv.h |  5 +++
>  2 files changed, 66 insertions(+), 24 deletions(-)
>
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index a598ada817f0..b33add453027 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -32,6 +32,7 @@
>  #include <linux/string.h>
>  #include <linux/vmalloc.h>
>  #include <linux/err.h>
> +#include <linux/srcu.h>
>
>  #include "zram_drv.h"
>
> @@ -53,9 +54,31 @@ static ssize_t name##_show(struct device *d,         \
>  }                                                                      \
>  static DEVICE_ATTR_RO(name);
>
> -static inline int init_done(struct zram *zram)
> +static inline bool init_done(struct zram *zram)
>  {
> -       return zram->meta != NULL;
> +       /*
> +        * init_done can be used without holding zram->init_lock in
> +        * read/write handler(ie, zram_make_request) but we should make sure
> +        * that zram->init_done should set up after meta initialization is
> +        * done. Look at setup_init_done.
> +        */
> +       bool ret = zram->init_done;
> +
> +       if (ret)
> +               smp_rmb(); /* pair with setup_init_done */
> +
> +       return ret;
> +}
> +
> +static inline void setup_init_done(struct zram *zram, bool flag)
> +{
> +       /*
> +        * Store operation of struct zram fields should complete
> +        * before zram->init_done set up because zram_bvec_rw
> +        * doesn't hold an zram->init_lock.
> +        */
> +       smp_wmb();
> +       zram->init_done = flag;
>  }
>
>  static inline struct zram *dev_to_zram(struct device *dev)
> @@ -326,6 +349,10 @@ static void zram_meta_free(struct zram_meta *meta)
>         kfree(meta);
>  }
>
> +static void rcu_zram_do_nothing(struct rcu_head *unused)
> +{
> +}
> +
>  static struct zram_meta *zram_meta_alloc(int device_id, u64 disksize)
>  {
>         char pool_name[8];
> @@ -726,11 +753,8 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
>                 return;
>         }
>
> -       zcomp_destroy(zram->comp);
>         zram->max_comp_streams = 1;
>
> -       zram_meta_free(zram->meta);
> -       zram->meta = NULL;
>         /* Reset stats */
>         memset(&zram->stats, 0, sizeof(zram->stats));
>
> @@ -738,8 +762,12 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
>         if (reset_capacity)
>                 set_capacity(zram->disk, 0);

Should this be after synchronize_srcu()?

>
> +       setup_init_done(zram, false);
> +       call_srcu(&zram->srcu, &zram->rcu, rcu_zram_do_nothing);
> +       synchronize_srcu(&zram->srcu);
> +       zram_meta_free(zram->meta);
> +       zcomp_destroy(zram->comp);
>         up_write(&zram->init_lock);
> -
>         /*
>          * Revalidate disk out of the init_lock to avoid lockdep splat.
>          * It's okay because disk's capacity is protected by init_lock
> @@ -762,10 +790,19 @@ static ssize_t disksize_store(struct device *dev,
>         if (!disksize)
>                 return -EINVAL;
>
> +       down_write(&zram->init_lock);
> +       if (init_done(zram)) {
> +               pr_info("Cannot change disksize for initialized device\n");
> +               up_write(&zram->init_lock);
> +               return -EBUSY;
> +       }
> +
>         disksize = PAGE_ALIGN(disksize);
>         meta = zram_meta_alloc(zram->disk->first_minor, disksize);
> -       if (!meta)
> +       if (!meta) {
> +               up_write(&zram->init_lock);
>                 return -ENOMEM;
> +       }
>
>         comp = zcomp_create(zram->compressor, zram->max_comp_streams);
>         if (IS_ERR(comp)) {
> @@ -775,17 +812,11 @@ static ssize_t disksize_store(struct device *dev,
>                 goto out_free_meta;
>         }
>
> -       down_write(&zram->init_lock);
> -       if (init_done(zram)) {
> -               pr_info("Cannot change disksize for initialized device\n");
> -               err = -EBUSY;
> -               goto out_destroy_comp;
> -       }
> -
>         zram->meta = meta;
>         zram->comp = comp;
>         zram->disksize = disksize;
>         set_capacity(zram->disk, zram->disksize >> SECTOR_SHIFT);
> +       setup_init_done(zram, true);
>         up_write(&zram->init_lock);
>
>         /*
> @@ -797,10 +828,8 @@ static ssize_t disksize_store(struct device *dev,
>
>         return len;
>
> -out_destroy_comp:
> -       up_write(&zram->init_lock);
> -       zcomp_destroy(comp);
>  out_free_meta:
> +       up_write(&zram->init_lock);
>         zram_meta_free(meta);
>         return err;
>  }
> @@ -905,9 +934,10 @@ out:
>   */
>  static void zram_make_request(struct request_queue *queue, struct bio *bio)
>  {
> +       int idx;
>         struct zram *zram = queue->queuedata;
>
> -       down_read(&zram->init_lock);
> +       idx = srcu_read_lock(&zram->srcu);
>         if (unlikely(!init_done(zram)))
>                 goto error;
>
> @@ -918,12 +948,12 @@ static void zram_make_request(struct request_queue *queue, struct bio *bio)
>         }
>
>         __zram_make_request(zram, bio);
> -       up_read(&zram->init_lock);
> +       srcu_read_unlock(&zram->srcu, idx);
>
>         return;
>
>  error:
> -       up_read(&zram->init_lock);
> +       srcu_read_unlock(&zram->srcu, idx);
>         bio_io_error(bio);
>  }
>
> @@ -945,18 +975,20 @@ static void zram_slot_free_notify(struct block_device *bdev,
>  static int zram_rw_page(struct block_device *bdev, sector_t sector,
>                        struct page *page, int rw)
>  {
> -       int offset, err;
> +       int offset, err, idx;
>         u32 index;
>         struct zram *zram;
>         struct bio_vec bv;
>
>         zram = bdev->bd_disk->private_data;
> +       idx = srcu_read_lock(&zram->srcu);
> +
>         if (!valid_io_request(zram, sector, PAGE_SIZE)) {
>                 atomic64_inc(&zram->stats.invalid_io);
> +               srcu_read_unlock(&zram->srcu, idx);
>                 return -EINVAL;
>         }
>
> -       down_read(&zram->init_lock);
>         if (unlikely(!init_done(zram))) {
>                 err = -EIO;
>                 goto out_unlock;
> @@ -971,7 +1003,7 @@ static int zram_rw_page(struct block_device *bdev, sector_t sector,
>
>         err = zram_bvec_rw(zram, &bv, index, offset, rw);
>  out_unlock:
> -       up_read(&zram->init_lock);
> +       srcu_read_unlock(&zram->srcu, idx);
>         /*
>          * If I/O fails, just return error(ie, non-zero) without
>          * calling page_endio.
> @@ -1041,6 +1073,11 @@ static int create_device(struct zram *zram, int device_id)
>
>         init_rwsem(&zram->init_lock);
>
> +       if (init_srcu_struct(&zram->srcu)) {
> +               pr_err("Error initialize srcu for device %d\n", device_id);
> +               goto out;
> +       }
> +
>         zram->queue = blk_alloc_queue(GFP_KERNEL);
>         if (!zram->queue) {
>                 pr_err("Error allocating disk queue for device %d\n",
> @@ -1125,8 +1162,8 @@ static void destroy_device(struct zram *zram)
>
>         del_gendisk(zram->disk);
>         put_disk(zram->disk);
> -
>         blk_cleanup_queue(zram->queue);
> +       cleanup_srcu_struct(&zram->srcu);
>  }
>
>  static int __init zram_init(void)
> diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
> index e492f6bf11f1..2042c310aea8 100644
> --- a/drivers/block/zram/zram_drv.h
> +++ b/drivers/block/zram/zram_drv.h
> @@ -105,8 +105,13 @@ struct zram {
>         struct gendisk *disk;
>         struct zcomp *comp;
>
> +       struct srcu_struct srcu;
> +       struct rcu_head rcu;
> +
>         /* Prevent concurrent execution of device init, reset and R/W request */
>         struct rw_semaphore init_lock;
> +       bool init_done;
> +
>         /*
>          * This is the limit on amount of *uncompressed* worth of data
>          * we can store in a disk.
> --
> 1.9.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
