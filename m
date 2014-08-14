Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 709056B0036
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 10:33:51 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id ho1so9041755wib.14
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 07:33:50 -0700 (PDT)
Received: from mail-wg0-x22d.google.com (mail-wg0-x22d.google.com [2a00:1450:400c:c00::22d])
        by mx.google.com with ESMTPS id d12si7053461wic.93.2014.08.14.07.33.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 Aug 2014 07:33:50 -0700 (PDT)
Received: by mail-wg0-f45.google.com with SMTP id x12so1156586wgg.28
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 07:33:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1407977877-18185-2-git-send-email-minchan@kernel.org>
References: <1407977877-18185-1-git-send-email-minchan@kernel.org> <1407977877-18185-2-git-send-email-minchan@kernel.org>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 14 Aug 2014 10:33:29 -0400
Message-ID: <CALZtONB=t5nivxYTTjqjYO0EQDYvLofKO6kM_xRUn3FT1Dut6A@mail.gmail.com>
Subject: Re: [PATCH 2/2] zram: limit memory size for zram
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ds2horner@gmail.com

On Wed, Aug 13, 2014 at 8:57 PM, Minchan Kim <minchan@kernel.org> wrote:
> Since zram has no control feature to limit memory usage,
> it makes hard to manage system memrory.
>
> This patch adds new knob "mem_limit" via sysfs to set up the
> limit.
>
> Note: I added the logic in zram, not zsmalloc because the limit
> is requirement of zram, not zsmalloc so I'd like to avoid
> unnecessary branch in zsmalloc.
>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  Documentation/blockdev/zram.txt | 20 +++++++++++++++----
>  drivers/block/zram/zram_drv.c   | 43 +++++++++++++++++++++++++++++++++++++++++
>  drivers/block/zram/zram_drv.h   |  1 +
>  3 files changed, 60 insertions(+), 4 deletions(-)
>
> diff --git a/Documentation/blockdev/zram.txt b/Documentation/blockdev/zram.txt
> index 0595c3f56ccf..9f239ff8c444 100644
> --- a/Documentation/blockdev/zram.txt
> +++ b/Documentation/blockdev/zram.txt
> @@ -74,14 +74,26 @@ There is little point creating a zram of greater than twice the size of memory
>  since we expect a 2:1 compression ratio. Note that zram uses about 0.1% of the
>  size of the disk when not in use so a huge zram is wasteful.
>
> -5) Activate:
> +5) Set memory limit: Optional
> +       Set memory limit by writing the value to sysfs node 'mem_limit'.
> +       The value can be either in bytes or you can use mem suffixes.
> +       Examples:
> +           # limit /dev/zram0 with 50MB memory
> +           echo $((50*1024*1024)) > /sys/block/zram0/mem_limit
> +
> +           # Using mem suffixes
> +           echo 256K > /sys/block/zram0/mem_limit
> +           echo 512M > /sys/block/zram0/mem_limit
> +           echo 1G > /sys/block/zram0/mem_limit
> +
> +6) Activate:
>         mkswap /dev/zram0
>         swapon /dev/zram0
>
>         mkfs.ext4 /dev/zram1
>         mount /dev/zram1 /tmp
>
> -6) Stats:
> +7) Stats:
>         Per-device statistics are exported as various nodes under
>         /sys/block/zram<id>/
>                 disksize
> @@ -96,11 +108,11 @@ size of the disk when not in use so a huge zram is wasteful.
>                 compr_data_size
>                 mem_used_total
>
> -7) Deactivate:
> +8) Deactivate:
>         swapoff /dev/zram0
>         umount /dev/zram1
>
> -8) Reset:
> +9) Reset:
>         Write any positive value to 'reset' sysfs node
>         echo 1 > /sys/block/zram0/reset
>         echo 1 > /sys/block/zram1/reset
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index d00831c3d731..b48a3d0e9031 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -122,6 +122,35 @@ static ssize_t max_comp_streams_show(struct device *dev,
>         return scnprintf(buf, PAGE_SIZE, "%d\n", val);
>  }
>
> +static ssize_t mem_limit_show(struct device *dev,
> +               struct device_attribute *attr, char *buf)
> +{
> +       u64 val;
> +       struct zram *zram = dev_to_zram(dev);
> +
> +       down_read(&zram->init_lock);
> +       val = zram->limit_bytes;
> +       up_read(&zram->init_lock);
> +
> +       return scnprintf(buf, PAGE_SIZE, "%llu\n", val);
> +}
> +
> +static ssize_t mem_limit_store(struct device *dev,
> +               struct device_attribute *attr, const char *buf, size_t len)
> +{
> +       u64 limit;
> +       struct zram *zram = dev_to_zram(dev);
> +
> +       limit = memparse(buf, NULL);
> +       if (!limit)
> +               return -EINVAL;

Shouldn't passing a 0 limit be allowed, to disable the limit?

> +
> +       down_write(&zram->init_lock);
> +       zram->limit_bytes = limit;
> +       up_write(&zram->init_lock);
> +       return len;
> +}
> +
>  static ssize_t max_comp_streams_store(struct device *dev,
>                 struct device_attribute *attr, const char *buf, size_t len)
>  {
> @@ -513,6 +542,14 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>                 ret = -ENOMEM;
>                 goto out;
>         }
> +
> +       if (zram->limit_bytes &&
> +               zs_get_total_size_bytes(meta->mem_pool) > zram->limit_bytes) {
> +               zs_free(meta->mem_pool, handle);
> +               ret = -ENOMEM;
> +               goto out;
> +       }
> +
>         cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
>
>         if ((clen == PAGE_SIZE) && !is_partial_io(bvec)) {
> @@ -617,6 +654,9 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
>         struct zram_meta *meta;
>
>         down_write(&zram->init_lock);
> +
> +       zram->limit_bytes = 0;
> +
>         if (!init_done(zram)) {
>                 up_write(&zram->init_lock);
>                 return;
> @@ -857,6 +897,8 @@ static DEVICE_ATTR(initstate, S_IRUGO, initstate_show, NULL);
>  static DEVICE_ATTR(reset, S_IWUSR, NULL, reset_store);
>  static DEVICE_ATTR(orig_data_size, S_IRUGO, orig_data_size_show, NULL);
>  static DEVICE_ATTR(mem_used_total, S_IRUGO, mem_used_total_show, NULL);
> +static DEVICE_ATTR(mem_limit, S_IRUGO | S_IWUSR, mem_limit_show,
> +               mem_limit_store);
>  static DEVICE_ATTR(max_comp_streams, S_IRUGO | S_IWUSR,
>                 max_comp_streams_show, max_comp_streams_store);
>  static DEVICE_ATTR(comp_algorithm, S_IRUGO | S_IWUSR,
> @@ -885,6 +927,7 @@ static struct attribute *zram_disk_attrs[] = {
>         &dev_attr_orig_data_size.attr,
>         &dev_attr_compr_data_size.attr,
>         &dev_attr_mem_used_total.attr,
> +       &dev_attr_mem_limit.attr,
>         &dev_attr_max_comp_streams.attr,
>         &dev_attr_comp_algorithm.attr,
>         NULL,
> diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
> index e0f725c87cc6..086c51782e75 100644
> --- a/drivers/block/zram/zram_drv.h
> +++ b/drivers/block/zram/zram_drv.h
> @@ -110,6 +110,7 @@ struct zram {
>          * we can store in a disk.
>          */
>         u64 disksize;   /* bytes */
> +       u64 limit_bytes;
>         int max_comp_streams;
>         struct zram_stats stats;
>         char compressor[10];
> --
> 2.0.0
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
