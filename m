Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 444576B0035
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 19:32:05 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id y13so14990084pdi.3
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 16:32:04 -0700 (PDT)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id wh3si38352503pac.189.2014.08.21.16.32.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 Aug 2014 16:32:04 -0700 (PDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so14288062pdj.26
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 16:32:04 -0700 (PDT)
Date: Thu, 21 Aug 2014 23:36:58 +0000
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 3/4] zram: zram memory size limitation
Message-ID: <20140821233658.GH10703@gmail.com>
References: <1408580838-29236-1-git-send-email-minchan@kernel.org>
 <1408580838-29236-4-git-send-email-minchan@kernel.org>
 <CALZtONAPtGRrkyjhcR75KDGp_8Rr_zy6Zov74AB4E1LZ6exPLA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONAPtGRrkyjhcR75KDGp_8Rr_zy6Zov74AB4E1LZ6exPLA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, David Horner <ds2horner@gmail.com>

On Thu, Aug 21, 2014 at 03:08:12PM -0400, Dan Streetman wrote:
> On Wed, Aug 20, 2014 at 8:27 PM, Minchan Kim <minchan@kernel.org> wrote:
> > Since zram has no control feature to limit memory usage,
> > it makes hard to manage system memrory.
> >
> > This patch adds new knob "mem_limit" via sysfs to set up the
> > a limit so that zram could fail allocation once it reaches
> > the limit.
> >
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  Documentation/ABI/testing/sysfs-block-zram |  9 +++++++
> >  Documentation/blockdev/zram.txt            | 20 ++++++++++++---
> >  drivers/block/zram/zram_drv.c              | 41 ++++++++++++++++++++++++++++++
> >  drivers/block/zram/zram_drv.h              |  5 ++++
> >  4 files changed, 71 insertions(+), 4 deletions(-)
> >
> > diff --git a/Documentation/ABI/testing/sysfs-block-zram b/Documentation/ABI/testing/sysfs-block-zram
> > index 70ec992514d0..025331c19045 100644
> > --- a/Documentation/ABI/testing/sysfs-block-zram
> > +++ b/Documentation/ABI/testing/sysfs-block-zram
> > @@ -119,3 +119,12 @@ Description:
> >                 efficiency can be calculated using compr_data_size and this
> >                 statistic.
> >                 Unit: bytes
> > +
> > +What:          /sys/block/zram<id>/mem_limit
> > +Date:          August 2014
> > +Contact:       Minchan Kim <minchan@kernel.org>
> > +Description:
> > +               The mem_limit file is read/write and specifies the amount
> > +               of memory to be able to consume memory to store store
> > +               compressed data.
> 
> might want to clarify here that the value "0", which is the default,
> disables the limit.

Okay.

> 
> > +               Unit: bytes
> > diff --git a/Documentation/blockdev/zram.txt b/Documentation/blockdev/zram.txt
> > index 0595c3f56ccf..9f239ff8c444 100644
> > --- a/Documentation/blockdev/zram.txt
> > +++ b/Documentation/blockdev/zram.txt
> > @@ -74,14 +74,26 @@ There is little point creating a zram of greater than twice the size of memory
> >  since we expect a 2:1 compression ratio. Note that zram uses about 0.1% of the
> >  size of the disk when not in use so a huge zram is wasteful.
> >
> > -5) Activate:
> > +5) Set memory limit: Optional
> > +       Set memory limit by writing the value to sysfs node 'mem_limit'.
> > +       The value can be either in bytes or you can use mem suffixes.
> > +       Examples:
> > +           # limit /dev/zram0 with 50MB memory
> > +           echo $((50*1024*1024)) > /sys/block/zram0/mem_limit
> > +
> > +           # Using mem suffixes
> > +           echo 256K > /sys/block/zram0/mem_limit
> > +           echo 512M > /sys/block/zram0/mem_limit
> > +           echo 1G > /sys/block/zram0/mem_limit
> 
> # To disable memory limit
> echo 0 > /sys/block/zram0/mem_limit

Yeb.

> 
> > +
> > +6) Activate:
> >         mkswap /dev/zram0
> >         swapon /dev/zram0
> >
> >         mkfs.ext4 /dev/zram1
> >         mount /dev/zram1 /tmp
> >
> > -6) Stats:
> > +7) Stats:
> >         Per-device statistics are exported as various nodes under
> >         /sys/block/zram<id>/
> >                 disksize
> > @@ -96,11 +108,11 @@ size of the disk when not in use so a huge zram is wasteful.
> >                 compr_data_size
> >                 mem_used_total
> >
> > -7) Deactivate:
> > +8) Deactivate:
> >         swapoff /dev/zram0
> >         umount /dev/zram1
> >
> > -8) Reset:
> > +9) Reset:
> >         Write any positive value to 'reset' sysfs node
> >         echo 1 > /sys/block/zram0/reset
> >         echo 1 > /sys/block/zram1/reset
> > diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> > index 302dd37bcea3..adc91c7ecaef 100644
> > --- a/drivers/block/zram/zram_drv.c
> > +++ b/drivers/block/zram/zram_drv.c
> > @@ -122,6 +122,33 @@ static ssize_t max_comp_streams_show(struct device *dev,
> >         return scnprintf(buf, PAGE_SIZE, "%d\n", val);
> >  }
> >
> > +static ssize_t mem_limit_show(struct device *dev,
> > +               struct device_attribute *attr, char *buf)
> > +{
> > +       u64 val;
> > +       struct zram *zram = dev_to_zram(dev);
> > +
> > +       down_read(&zram->init_lock);
> > +       val = zram->limit_pages;
> > +       up_read(&zram->init_lock);
> > +
> > +       return scnprintf(buf, PAGE_SIZE, "%llu\n", val << PAGE_SHIFT);
> > +}
> > +
> > +static ssize_t mem_limit_store(struct device *dev,
> > +               struct device_attribute *attr, const char *buf, size_t len)
> > +{
> > +       u64 limit;
> > +       struct zram *zram = dev_to_zram(dev);
> > +
> > +       limit = memparse(buf, NULL);
> > +       down_write(&zram->init_lock);
> > +       zram->limit_pages = PAGE_ALIGN(limit) >> PAGE_SHIFT;
> > +       up_write(&zram->init_lock);
> > +
> > +       return len;
> > +}
> > +
> >  static ssize_t max_comp_streams_store(struct device *dev,
> >                 struct device_attribute *attr, const char *buf, size_t len)
> >  {
> > @@ -513,6 +540,14 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> >                 ret = -ENOMEM;
> >                 goto out;
> >         }
> > +
> > +       if (zram->limit_pages &&
> > +               zs_get_total_size(meta->mem_pool) > zram->limit_pages) {
> > +               zs_free(meta->mem_pool, handle);
> > +               ret = -ENOMEM;
> > +               goto out;
> > +       }
> > +
> >         cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
> >
> >         if ((clen == PAGE_SIZE) && !is_partial_io(bvec)) {
> > @@ -617,6 +652,9 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
> >         struct zram_meta *meta;
> >
> >         down_write(&zram->init_lock);
> > +
> > +       zram->limit_pages = 0;
> > +
> >         if (!init_done(zram)) {
> >                 up_write(&zram->init_lock);
> >                 return;
> > @@ -857,6 +895,8 @@ static DEVICE_ATTR(initstate, S_IRUGO, initstate_show, NULL);
> >  static DEVICE_ATTR(reset, S_IWUSR, NULL, reset_store);
> >  static DEVICE_ATTR(orig_data_size, S_IRUGO, orig_data_size_show, NULL);
> >  static DEVICE_ATTR(mem_used_total, S_IRUGO, mem_used_total_show, NULL);
> > +static DEVICE_ATTR(mem_limit, S_IRUGO | S_IWUSR, mem_limit_show,
> > +               mem_limit_store);
> >  static DEVICE_ATTR(max_comp_streams, S_IRUGO | S_IWUSR,
> >                 max_comp_streams_show, max_comp_streams_store);
> >  static DEVICE_ATTR(comp_algorithm, S_IRUGO | S_IWUSR,
> > @@ -885,6 +925,7 @@ static struct attribute *zram_disk_attrs[] = {
> >         &dev_attr_orig_data_size.attr,
> >         &dev_attr_compr_data_size.attr,
> >         &dev_attr_mem_used_total.attr,
> > +       &dev_attr_mem_limit.attr,
> >         &dev_attr_max_comp_streams.attr,
> >         &dev_attr_comp_algorithm.attr,
> >         NULL,
> > diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
> > index e0f725c87cc6..b7aa9c21553f 100644
> > --- a/drivers/block/zram/zram_drv.h
> > +++ b/drivers/block/zram/zram_drv.h
> > @@ -112,6 +112,11 @@ struct zram {
> >         u64 disksize;   /* bytes */
> >         int max_comp_streams;
> >         struct zram_stats stats;
> > +       /*
> > +        * the number of pages zram can consume for storing compressed data
> > +        */
> > +       unsigned long limit_pages;
> > +
> >         char compressor[10];
> >  };
> >  #endif
> > --
> > 2.0.0
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
