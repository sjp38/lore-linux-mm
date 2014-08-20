Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4EB516B0038
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 04:25:17 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so11596210pad.21
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 01:25:16 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id tx4si30653474pac.163.2014.08.20.01.25.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 20 Aug 2014 01:25:16 -0700 (PDT)
Received: by mail-pa0-f51.google.com with SMTP id ey11so12024806pad.10
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 01:25:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140820075326.GC17372@bbox>
References: <1408434887-16387-1-git-send-email-minchan@kernel.org>
	<1408434887-16387-5-git-send-email-minchan@kernel.org>
	<CAFdhcLQcgME18U2NfEc6dXfvHnJWpyqcMR=Y16MyyghWiNRo1w@mail.gmail.com>
	<20140820065318.GB17372@bbox>
	<CAFdhcLQub+VkMAQSdjLCfB2W=NHWu=Hv5K3ua1YbGWZUrCjOmw@mail.gmail.com>
	<20140820075326.GC17372@bbox>
Date: Wed, 20 Aug 2014 04:25:15 -0400
Message-ID: <CAFdhcLTdZ9DrHBC=KLiDGw6zsJPDZrkg1A3GJ5MYKPXh80r4Ng@mail.gmail.com>
Subject: Re: [PATCH v2 4/4] zram: report maximum used memory
From: David Horner <ds2horner@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>

I'm really surprised there isn't an atomic_set_max function -
 that keeps trying the exchange until the target value is equal or
greater than provided value.

(and complimentary atomic_set_min)

I would be surprised that this is the only place in the kernel with
this scenario.

On Wed, Aug 20, 2014 at 3:53 AM, Minchan Kim <minchan@kernel.org> wrote:
> On Wed, Aug 20, 2014 at 03:38:27AM -0400, David Horner wrote:
>> On Wed, Aug 20, 2014 at 2:53 AM, Minchan Kim <minchan@kernel.org> wrote:
>> > On Wed, Aug 20, 2014 at 02:26:50AM -0400, David Horner wrote:
>> >> On Tue, Aug 19, 2014 at 3:54 AM, Minchan Kim <minchan@kernel.org> wrote:
>> >> > Normally, zram user could get maximum memory usage zram consumed
>> >> > via polling mem_used_total with sysfs in userspace.
>> >> >
>> >> > But it has a critical problem because user can miss peak memory
>> >> > usage during update inverval of polling. For avoiding that,
>> >> > user should poll it with shorter interval(ie, 0.0000000001s)
>> >> > with mlocking to avoid page fault delay when memory pressure
>> >> > is heavy. It would be troublesome.
>> >> >
>> >> > This patch adds new knob "mem_used_max" so user could see
>> >> > the maximum memory usage easily via reading the knob and reset
>> >> > it via "echo 0 > /sys/block/zram0/mem_used_max".
>> >> >
>> >> > Signed-off-by: Minchan Kim <minchan@kernel.org>
>> >> > ---
>> >> >  Documentation/ABI/testing/sysfs-block-zram | 10 +++++
>> >> >  Documentation/blockdev/zram.txt            |  1 +
>> >> >  drivers/block/zram/zram_drv.c              | 60 +++++++++++++++++++++++++++++-
>> >> >  drivers/block/zram/zram_drv.h              |  1 +
>> >> >  4 files changed, 70 insertions(+), 2 deletions(-)
>> >> >
>> >> > diff --git a/Documentation/ABI/testing/sysfs-block-zram b/Documentation/ABI/testing/sysfs-block-zram
>> >> > index 025331c19045..ffd1ea7443dd 100644
>> >> > --- a/Documentation/ABI/testing/sysfs-block-zram
>> >> > +++ b/Documentation/ABI/testing/sysfs-block-zram
>> >> > @@ -120,6 +120,16 @@ Description:
>> >> >                 statistic.
>> >> >                 Unit: bytes
>> >> >
>> >> > +What:          /sys/block/zram<id>/mem_used_max
>> >> > +Date:          August 2014
>> >> > +Contact:       Minchan Kim <minchan@kernel.org>
>> >> > +Description:
>> >> > +               The mem_used_max file is read/write and specifies the amount
>> >> > +               of maximum memory zram have consumed to store compressed data.
>> >> > +               For resetting the value, you should do "echo 0". Otherwise,
>> >> > +               you could see -EINVAL.
>> >> > +               Unit: bytes
>> >> > +
>> >> >  What:          /sys/block/zram<id>/mem_limit
>> >> >  Date:          August 2014
>> >> >  Contact:       Minchan Kim <minchan@kernel.org>
>> >> > diff --git a/Documentation/blockdev/zram.txt b/Documentation/blockdev/zram.txt
>> >> > index 9f239ff8c444..3b2247c2d4cf 100644
>> >> > --- a/Documentation/blockdev/zram.txt
>> >> > +++ b/Documentation/blockdev/zram.txt
>> >> > @@ -107,6 +107,7 @@ size of the disk when not in use so a huge zram is wasteful.
>> >> >                 orig_data_size
>> >> >                 compr_data_size
>> >> >                 mem_used_total
>> >> > +               mem_used_max
>> >> >
>> >> >  8) Deactivate:
>> >> >         swapoff /dev/zram0
>> >> > diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
>> >> > index adc91c7ecaef..e4d44842a91d 100644
>> >> > --- a/drivers/block/zram/zram_drv.c
>> >> > +++ b/drivers/block/zram/zram_drv.c
>> >> > @@ -149,6 +149,40 @@ static ssize_t mem_limit_store(struct device *dev,
>> >> >         return len;
>> >> >  }
>> >> >
>> >> > +static ssize_t mem_used_max_show(struct device *dev,
>> >> > +               struct device_attribute *attr, char *buf)
>> >> > +{
>> >> > +       u64 val = 0;
>> >> > +       struct zram *zram = dev_to_zram(dev);
>> >> > +
>> >> > +       down_read(&zram->init_lock);
>> >> > +       if (init_done(zram))
>> >> > +               val = atomic64_read(&zram->stats.max_used_pages);
>> >> > +       up_read(&zram->init_lock);
>> >> > +
>> >> > +       return scnprintf(buf, PAGE_SIZE, "%llu\n", val << PAGE_SHIFT);
>> >> > +}
>> >> > +
>> >> > +static ssize_t mem_used_max_store(struct device *dev,
>> >> > +               struct device_attribute *attr, const char *buf, size_t len)
>> >> > +{
>> >> > +       u64 limit;
>> >> > +       struct zram *zram = dev_to_zram(dev);
>> >> > +       struct zram_meta *meta = zram->meta;
>> >> > +
>> >> > -       limit = memparse(buf, NULL);
>> >> > -       if (0 != limit)
>> >>
>> >> we wanted explicit "0" and nothing else for extensibility
>> >>
>> >>      if (len != 1 || *buf != "0")
>> >>
>> >
>> > I wanted to work with "0", "0K", "0M", "0G" but agree it's meaningless
>> > at the moment so your version is better.
>> >
>> >
>> >> > +               return -EINVAL;
>> >> > +
>> >> > +       down_read(&zram->init_lock);
>> >> > +       if (init_done(zram))
>> >> > +               atomic64_set(&zram->stats.max_used_pages,
>> >> > +                               zs_get_total_size(meta->mem_pool));
>> >> > +       up_read(&zram->init_lock);
>> >> > +
>> >> > +       return len;
>> >>           return 1;
>> >>
>> >> the standard convention is to return used amount of buffer
>> >
>> > If I follow your suggestion, len should be 1 right before returning
>> > so no problem for functionality POV but I agree explicit "1" is better
>> > for readability so your version is better, better.
>> >
>> >>
>> >>
>> >>
>> >> > +}
>> >> > +
>> >> >  static ssize_t max_comp_streams_store(struct device *dev,
>> >> >                 struct device_attribute *attr, const char *buf, size_t len)
>> >> >  {
>> >> > @@ -461,6 +495,26 @@ out_cleanup:
>> >> >         return ret;
>> >> >  }
>> >> >
>> >> > +static bool check_limit(struct zram *zram)
>> >> > +{
>> >> > +       unsigned long alloced_pages;
>> >> > +       u64 old_max, cur_max;
>> >> > +       struct zram_meta *meta = zram->meta;
>> >> > +
>> >> > +       do {
>> >> > +               alloced_pages = zs_get_total_size(meta->mem_pool);
>> >> > +               if (zram->limit_pages && alloced_pages > zram->limit_pages)
>> >> > +                       return false;
>> >> > +
>> >> > +               old_max = cur_max = atomic64_read(&zram->stats.max_used_pages);
>> >> > +               if (alloced_pages > cur_max)
>> >> > +                       old_max = atomic64_cmpxchg(&zram->stats.max_used_pages,
>> >> > +                                       cur_max, alloced_pages);
>> >> > +       } while (old_max != cur_max);
>> >> > +
>> >> > +       return true;
>> >> > +}
>> >> > +
>> >>
>> >> Check_limit does more than check limit - it has a substantial side
>> >> effect of updating max used.
>> >
>> > Hmm, Normally, limit check is best place to update the max although
>> > function name imply just checking the limit and I don't think
>> > code piece for max updating doesn't hurt readbilty.
>> > If you or other reviewer is strong against, I will be happy to
>> > factor out part of max updating into another function because
>> > I think it's just preference problem for small logic and don't want
>> > to waste argue for that.
>> >
>> > If you really want it, pz, ping me again.
>> >
>> >>
>> >> Basically if we already allocated the buffer and our alloced_pages is
>> >> less than the limit then we are good to go.
>> >
>> > Yeb.
>> >
>> >>
>> >> It is the race to update that we need to have the cmpxchg.
>> >> And maybe a helper function would aid readability - not sure, see next point.
>> >>
>> >> I don't believe there is need for the loop either.
>> >> Any other updater will also be including our allocated pages
>> >> (and at this point in the code eliminated from roll back)
>> >>  so if they beat us to it, then no problem, their max is better than ours.
>> >
>> > Let's assume we don't have the loop.
>> >
>> >
>> > CPU A                                   CPU B
>> >
>> > alloced_pages = 2001
>> > old_max = cur_max = 2000
>> >                                         alloced_pages = 2005
>> >                                         old_max = cur_max = 2000
>> >
>> > cmpxchg(2000, 2000, 2001) -> OK
>> >
>> >                                         cmpxchg(2001, 2000, 2005) -> FAIL
>> >
>> > So, we lose 2005 which is bigger vaule.
>> >
>>
>> Yes - you are absolutely correct - I missed that scenario.
>>
>> but there isn't the need to redo  zs_get_total_size.
>>
>> we only need to loop while our value is still the max.
>
> Yes - you are absolutely right. :)
>
>>
>> So the two parts are not closely coupled and the inline code for the
>> exceeded check is simple enough.
>> And the loop to apply max would be best in helper function.
>
> Okay, you proved helper function would be better for readabilty
> to indicate limit check and max_used_check is not coupled.
>
> Thanks for the review, David!
>
>>
>> >>
>> >>
>> >>
>> >> >  static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>> >> >                            int offset)
>> >> >  {
>> >> > @@ -541,8 +595,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>> >> >                 goto out;
>> >> >         }
>> >> >
>> >> > -       if (zram->limit_pages &&
>> >> > -               zs_get_total_size(meta->mem_pool) > zram->limit_pages) {
>> >> > +       if (!check_limit(zram)) {
>> >> >                 zs_free(meta->mem_pool, handle);
>> >> >                 ret = -ENOMEM;
>> >> >                 goto out;
>> >> > @@ -897,6 +950,8 @@ static DEVICE_ATTR(orig_data_size, S_IRUGO, orig_data_size_show, NULL);
>> >> >  static DEVICE_ATTR(mem_used_total, S_IRUGO, mem_used_total_show, NULL);
>> >> >  static DEVICE_ATTR(mem_limit, S_IRUGO | S_IWUSR, mem_limit_show,
>> >> >                 mem_limit_store);
>> >> > +static DEVICE_ATTR(mem_used_max, S_IRUGO | S_IWUSR, mem_used_max_show,
>> >> > +               mem_used_max_store);
>> >> >  static DEVICE_ATTR(max_comp_streams, S_IRUGO | S_IWUSR,
>> >> >                 max_comp_streams_show, max_comp_streams_store);
>> >> >  static DEVICE_ATTR(comp_algorithm, S_IRUGO | S_IWUSR,
>> >> > @@ -926,6 +981,7 @@ static struct attribute *zram_disk_attrs[] = {
>> >> >         &dev_attr_compr_data_size.attr,
>> >> >         &dev_attr_mem_used_total.attr,
>> >> >         &dev_attr_mem_limit.attr,
>> >> > +       &dev_attr_mem_used_max.attr,
>> >> >         &dev_attr_max_comp_streams.attr,
>> >> >         &dev_attr_comp_algorithm.attr,
>> >> >         NULL,
>> >> > diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
>> >> > index b7aa9c21553f..29383312d543 100644
>> >> > --- a/drivers/block/zram/zram_drv.h
>> >> > +++ b/drivers/block/zram/zram_drv.h
>> >> > @@ -90,6 +90,7 @@ struct zram_stats {
>> >> >         atomic64_t notify_free; /* no. of swap slot free notifications */
>> >> >         atomic64_t zero_pages;          /* no. of zero filled pages */
>> >> >         atomic64_t pages_stored;        /* no. of pages currently stored */
>> >> > +       atomic64_t max_used_pages;      /* no. of maximum pages stored */
>> >> >  };
>> >> >
>> >> >  struct zram_meta {
>> >> > --
>> >> > 2.0.0
>> >> >
>> >>
>> >> --
>> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> >> the body to majordomo@kvack.org.  For more info on Linux MM,
>> >> see: http://www.linux-mm.org/ .
>> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>> >
>> > --
>> > Kind regards,
>> > Minchan Kim
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
