Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 911946B0036
	for <linux-mm@kvack.org>; Sun, 17 Aug 2014 19:37:12 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so6385300pdj.30
        for <linux-mm@kvack.org>; Sun, 17 Aug 2014 16:37:12 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id hs10si18975196pdb.233.2014.08.17.16.37.09
        for <linux-mm@kvack.org>;
        Sun, 17 Aug 2014 16:37:11 -0700 (PDT)
Date: Mon, 18 Aug 2014 08:37:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/3] zram: add mem_used_max via sysfs
Message-ID: <20140817233732.GC11367@bbox>
References: <1407978746-20587-1-git-send-email-minchan@kernel.org>
 <1407978746-20587-3-git-send-email-minchan@kernel.org>
 <CAFdhcLTHv9Jhc6Z40dYG7YQFgLURrh5CUyD+ZNkMSb+FXdZocw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAFdhcLTHv9Jhc6Z40dYG7YQFgLURrh5CUyD+ZNkMSb+FXdZocw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Horner <ds2horner@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>

Hi David,

On Thu, Aug 14, 2014 at 06:29:17AM -0400, David Horner wrote:
> The introduction of a reset can cause the stale zero value to be
> retained in the show.
> Instead reset to current value.

It's better. I will do.
Thanks!

> 
> On Wed, Aug 13, 2014 at 9:12 PM, Minchan Kim <minchan@kernel.org> wrote:
> > Normally, zram user can get maximum memory zsmalloc consumed via
> > polling mem_used_total with sysfs in userspace.
> >
> > But it has a critical problem because user can miss peak memory
> > usage during update interval of polling. For avoiding that,
> > user should poll it frequently with mlocking to avoid delay
> > when memory pressure is heavy so it would be handy if the
> > kernel supports the function.
> >
> > This patch adds mem_used_max via sysfs.
> >
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  Documentation/blockdev/zram.txt |  1 +
> >  drivers/block/zram/zram_drv.c   | 35 +++++++++++++++++++++++++++++++++--
> >  drivers/block/zram/zram_drv.h   |  2 ++
> >  3 files changed, 36 insertions(+), 2 deletions(-)
> >
> > diff --git a/Documentation/blockdev/zram.txt b/Documentation/blockdev/zram.txt
> > index 9f239ff8c444..3b2247c2d4cf 100644
> > --- a/Documentation/blockdev/zram.txt
> > +++ b/Documentation/blockdev/zram.txt
> > @@ -107,6 +107,7 @@ size of the disk when not in use so a huge zram is wasteful.
> >                 orig_data_size
> >                 compr_data_size
> >                 mem_used_total
> > +               mem_used_max
> >
> >  8) Deactivate:
> >         swapoff /dev/zram0
> > diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> > index b48a3d0e9031..311699f18bd5 100644
> > --- a/drivers/block/zram/zram_drv.c
> > +++ b/drivers/block/zram/zram_drv.c
> > @@ -109,6 +109,30 @@ static ssize_t mem_used_total_show(struct device *dev,
> >         return scnprintf(buf, PAGE_SIZE, "%llu\n", val);
> >  }
> >
> > +static ssize_t mem_used_max_reset(struct device *dev,
> > +               struct device_attribute *attr, const char *buf, size_t len)
> 
> perhaps these are local functions, but wouldn't the zs_ prefix still
> be appropriate?
> > +{
> > +       struct zram *zram = dev_to_zram(dev);
> > +
> > +       down_write(&zram->init_lock);
> > +       zram->max_used_bytes = 0;
> 
>            zram->max_used_bytes = zs_get_total_size_bytes(meta->mem_pool);
> 
>            (where meta is set up as below  (beyond my skill level at
> the moment)).
> 
> > +       up_write(&zram->init_lock);
> > +       return len;
> > +}
> > +
> > +static ssize_t mem_used_max_show(struct device *dev,
> > +               struct device_attribute *attr, char *buf)
> > +{
> > +       u64 max_used_bytes;
> > +       struct zram *zram = dev_to_zram(dev);
> > +
> > +       down_read(&zram->init_lock);
> 
> if these are atomic operations, why the (read and write) locks?
> 
> > +       max_used_bytes = zram->max_used_bytes;
> > +       up_read(&zram->init_lock);
> > +
> > +       return scnprintf(buf, PAGE_SIZE, "%llu\n", max_used_bytes);
> > +}
> > +
> >  static ssize_t max_comp_streams_show(struct device *dev,
> >                 struct device_attribute *attr, char *buf)
> >  {
> > @@ -474,6 +498,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> >         struct zram_meta *meta = zram->meta;
> >         struct zcomp_strm *zstrm;
> >         bool locked = false;
> > +       u64 total_bytes;
> >
> >         page = bvec->bv_page;
> >         if (is_partial_io(bvec)) {
> > @@ -543,8 +568,8 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> >                 goto out;
> >         }
> >
> > -       if (zram->limit_bytes &&
> > -               zs_get_total_size_bytes(meta->mem_pool) > zram->limit_bytes) {
> > +       total_bytes = zs_get_total_size_bytes(meta->mem_pool);
> > +       if (zram->limit_bytes && total_bytes > zram->limit_bytes) {
> >                 zs_free(meta->mem_pool, handle);
> >                 ret = -ENOMEM;
> >                 goto out;
> > @@ -578,6 +603,8 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> >         /* Update stats */
> >         atomic64_add(clen, &zram->stats.compr_data_size);
> >         atomic64_inc(&zram->stats.pages_stored);
> > +
> > +       zram->max_used_bytes = max(zram->max_used_bytes, total_bytes);
> >  out:
> >         if (locked)
> >                 zcomp_strm_release(zram->comp, zstrm);
> > @@ -656,6 +683,7 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
> >         down_write(&zram->init_lock);
> >
> >         zram->limit_bytes = 0;
> > +       zram->max_used_bytes = 0;
> >
> >         if (!init_done(zram)) {
> >                 up_write(&zram->init_lock);
> > @@ -897,6 +925,8 @@ static DEVICE_ATTR(initstate, S_IRUGO, initstate_show, NULL);
> >  static DEVICE_ATTR(reset, S_IWUSR, NULL, reset_store);
> >  static DEVICE_ATTR(orig_data_size, S_IRUGO, orig_data_size_show, NULL);
> >  static DEVICE_ATTR(mem_used_total, S_IRUGO, mem_used_total_show, NULL);
> > +static DEVICE_ATTR(mem_used_max, S_IRUGO | S_IWUSR, mem_used_max_show,
> > +               mem_used_max_reset);
> >  static DEVICE_ATTR(mem_limit, S_IRUGO | S_IWUSR, mem_limit_show,
> >                 mem_limit_store);
> >  static DEVICE_ATTR(max_comp_streams, S_IRUGO | S_IWUSR,
> > @@ -927,6 +957,7 @@ static struct attribute *zram_disk_attrs[] = {
> >         &dev_attr_orig_data_size.attr,
> >         &dev_attr_compr_data_size.attr,
> >         &dev_attr_mem_used_total.attr,
> > +       &dev_attr_mem_used_max.attr,
> >         &dev_attr_mem_limit.attr,
> >         &dev_attr_max_comp_streams.attr,
> >         &dev_attr_comp_algorithm.attr,
> > diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
> > index 086c51782e75..aca09b18fcbd 100644
> > --- a/drivers/block/zram/zram_drv.h
> > +++ b/drivers/block/zram/zram_drv.h
> > @@ -111,6 +111,8 @@ struct zram {
> >          */
> >         u64 disksize;   /* bytes */
> >         u64 limit_bytes;
> > +       u64 max_used_bytes;
> > +
> >         int max_comp_streams;
> >         struct zram_stats stats;
> >         char compressor[10];
> > --
> > 2.0.0
> >
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
