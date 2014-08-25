Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 714A36B006C
	for <linux-mm@kvack.org>; Mon, 25 Aug 2014 00:05:30 -0400 (EDT)
Received: by mail-qg0-f48.google.com with SMTP id i50so12606431qgf.21
        for <linux-mm@kvack.org>; Sun, 24 Aug 2014 21:05:30 -0700 (PDT)
Received: from mail-qg0-x22c.google.com (mail-qg0-x22c.google.com [2607:f8b0:400d:c04::22c])
        by mx.google.com with ESMTPS id cc7si51073665qcb.14.2014.08.24.21.05.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 24 Aug 2014 21:05:29 -0700 (PDT)
Received: by mail-qg0-f44.google.com with SMTP id e89so12805925qgf.3
        for <linux-mm@kvack.org>; Sun, 24 Aug 2014 21:05:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1408925156-11733-5-git-send-email-minchan@kernel.org>
References: <1408925156-11733-1-git-send-email-minchan@kernel.org>
	<1408925156-11733-5-git-send-email-minchan@kernel.org>
Date: Mon, 25 Aug 2014 00:05:29 -0400
Message-ID: <CAFdhcLRELK1kvU0L8YBPqR5Qe0i3Andb7QOJ5CZNiFdNn3AM=Q@mail.gmail.com>
Subject: Re: [PATCH v5 4/4] zram: report maximum used memory
From: David Horner <ds2horner@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>

On Sun, Aug 24, 2014 at 8:05 PM, Minchan Kim <minchan@kernel.org> wrote:
> Normally, zram user could get maximum memory usage zram consumed
> via polling mem_used_total with sysfs in userspace.
>
> But it has a critical problem because user can miss peak memory
> usage during update inverval of polling. For avoiding that,
> user should poll it with shorter interval(ie, 0.0000000001s)
> with mlocking to avoid page fault delay when memory pressure
> is heavy. It would be troublesome.
>
> This patch adds new knob "mem_used_max" so user could see
> the maximum memory usage easily via reading the knob and reset
> it via "echo 0 > /sys/block/zram0/mem_used_max".
>
> Reviewed-by: Dan Streetman <ddstreet@ieee.org>
Reviewed-by: David Horner <ds2horner@gmail.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  Documentation/ABI/testing/sysfs-block-zram | 10 +++++
>  Documentation/blockdev/zram.txt            |  1 +
>  drivers/block/zram/zram_drv.c              | 60 +++++++++++++++++++++++++++++-
>  drivers/block/zram/zram_drv.h              |  1 +
>  4 files changed, 70 insertions(+), 2 deletions(-)
>
> diff --git a/Documentation/ABI/testing/sysfs-block-zram b/Documentation/ABI/testing/sysfs-block-zram
> index dbe643775ec1..01a38eaf1552 100644
> --- a/Documentation/ABI/testing/sysfs-block-zram
> +++ b/Documentation/ABI/testing/sysfs-block-zram
> @@ -120,6 +120,16 @@ Description:
>                 statistic.
>                 Unit: bytes
>
> +What:          /sys/block/zram<id>/mem_used_max
> +Date:          August 2014
> +Contact:       Minchan Kim <minchan@kernel.org>
> +Description:
> +               The mem_used_max file is read/write and specifies the amount
> +               of maximum memory zram have consumed to store compressed data.
> +               For resetting the value, you should write "0". Otherwise,
> +               you could see -EINVAL.
> +               Unit: bytes
> +
>  What:          /sys/block/zram<id>/mem_limit
>  Date:          August 2014
>  Contact:       Minchan Kim <minchan@kernel.org>
> diff --git a/Documentation/blockdev/zram.txt b/Documentation/blockdev/zram.txt
> index 82c6a41116db..7fcf9c6592ec 100644
> --- a/Documentation/blockdev/zram.txt
> +++ b/Documentation/blockdev/zram.txt
> @@ -111,6 +111,7 @@ size of the disk when not in use so a huge zram is wasteful.
>                 orig_data_size
>                 compr_data_size
>                 mem_used_total
> +               mem_used_max
>
>  8) Deactivate:
>         swapoff /dev/zram0
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index 370c355eb127..1a2b3e320ea5 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -149,6 +149,41 @@ static ssize_t mem_limit_store(struct device *dev,
>         return len;
>  }
>
> +static ssize_t mem_used_max_show(struct device *dev,
> +               struct device_attribute *attr, char *buf)
> +{
> +       u64 val = 0;
> +       struct zram *zram = dev_to_zram(dev);
> +
> +       down_read(&zram->init_lock);
> +       if (init_done(zram))
> +               val = atomic_long_read(&zram->stats.max_used_pages);
> +       up_read(&zram->init_lock);
> +
> +       return scnprintf(buf, PAGE_SIZE, "%llu\n", val << PAGE_SHIFT);
> +}
> +
> +static ssize_t mem_used_max_store(struct device *dev,
> +               struct device_attribute *attr, const char *buf, size_t len)
> +{
> +       int err;
> +       unsigned long val;
> +       struct zram *zram = dev_to_zram(dev);
> +       struct zram_meta *meta = zram->meta;
> +
> +       err = kstrtoul(buf, 10, &val);
> +       if (err || val != 0)
> +               return -EINVAL;
> +
> +       down_read(&zram->init_lock);
> +       if (init_done(zram))
> +               atomic_long_set(&zram->stats.max_used_pages,
> +                               zs_get_total_pages(meta->mem_pool));
> +       up_read(&zram->init_lock);
> +
> +       return len;
> +}
> +
>  static ssize_t max_comp_streams_store(struct device *dev,
>                 struct device_attribute *attr, const char *buf, size_t len)
>  {
> @@ -461,6 +496,21 @@ out_cleanup:
>         return ret;
>  }
>
> +static inline void update_used_max(struct zram *zram,
> +                                       const unsigned long pages)
> +{
> +       int old_max, cur_max;
> +
> +       old_max = atomic_long_read(&zram->stats.max_used_pages);
> +
> +       do {
> +               cur_max = old_max;
> +               if (pages > cur_max)
> +                       old_max = atomic_long_cmpxchg(
> +                               &zram->stats.max_used_pages, cur_max, pages);
> +       } while (old_max != cur_max);
> +}
> +
>  static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>                            int offset)
>  {
> @@ -472,6 +522,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>         struct zram_meta *meta = zram->meta;
>         struct zcomp_strm *zstrm;
>         bool locked = false;
> +       unsigned long alloced_pages;
>
>         page = bvec->bv_page;
>         if (is_partial_io(bvec)) {
> @@ -541,13 +592,15 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>                 goto out;
>         }
>
> -       if (zram->limit_pages &&
> -               zs_get_total_pages(meta->mem_pool) > zram->limit_pages) {
> +       alloced_pages = zs_get_total_pages(meta->mem_pool);
> +       if (zram->limit_pages && alloced_pages > zram->limit_pages) {
>                 zs_free(meta->mem_pool, handle);
>                 ret = -ENOMEM;
>                 goto out;
>         }
>
> +       update_used_max(zram, alloced_pages);
> +
>         cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
>
>         if ((clen == PAGE_SIZE) && !is_partial_io(bvec)) {
> @@ -897,6 +950,8 @@ static DEVICE_ATTR(orig_data_size, S_IRUGO, orig_data_size_show, NULL);
>  static DEVICE_ATTR(mem_used_total, S_IRUGO, mem_used_total_show, NULL);
>  static DEVICE_ATTR(mem_limit, S_IRUGO | S_IWUSR, mem_limit_show,
>                 mem_limit_store);
> +static DEVICE_ATTR(mem_used_max, S_IRUGO | S_IWUSR, mem_used_max_show,
> +               mem_used_max_store);
>  static DEVICE_ATTR(max_comp_streams, S_IRUGO | S_IWUSR,
>                 max_comp_streams_show, max_comp_streams_store);
>  static DEVICE_ATTR(comp_algorithm, S_IRUGO | S_IWUSR,
> @@ -926,6 +981,7 @@ static struct attribute *zram_disk_attrs[] = {
>         &dev_attr_compr_data_size.attr,
>         &dev_attr_mem_used_total.attr,
>         &dev_attr_mem_limit.attr,
> +       &dev_attr_mem_used_max.attr,
>         &dev_attr_max_comp_streams.attr,
>         &dev_attr_comp_algorithm.attr,
>         NULL,
> diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
> index b7aa9c21553f..c6ee271317f5 100644
> --- a/drivers/block/zram/zram_drv.h
> +++ b/drivers/block/zram/zram_drv.h
> @@ -90,6 +90,7 @@ struct zram_stats {
>         atomic64_t notify_free; /* no. of swap slot free notifications */
>         atomic64_t zero_pages;          /* no. of zero filled pages */
>         atomic64_t pages_stored;        /* no. of pages currently stored */
> +       atomic_long_t max_used_pages;   /* no. of maximum pages stored */
>  };
>
>  struct zram_meta {
> --
> 2.0.0
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
