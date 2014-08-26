Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 71ECA6B0036
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 00:39:04 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id rd3so22057118pab.26
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 21:39:04 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id fw9si2276944pdb.187.2014.08.25.21.39.02
        for <linux-mm@kvack.org>;
        Mon, 25 Aug 2014 21:39:03 -0700 (PDT)
Date: Tue, 26 Aug 2014 13:39:54 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v4 3/4] zram: zram memory size limitation
Message-ID: <20140826043954.GC11319@bbox>
References: <1408668134-21696-1-git-send-email-minchan@kernel.org>
 <1408668134-21696-4-git-send-email-minchan@kernel.org>
 <CAFdhcLQXHoCT2tee8f1hb-XOsh4G5SQUGfhXtobNYjDq6MS9Ug@mail.gmail.com>
 <20140824235607.GJ17372@bbox>
 <CAFdhcLRvwifCVyoW5F9gdOGwcNd0PM679HckJY6+UDYV82n+bg@mail.gmail.com>
 <20140825043755.GE32620@bbox>
 <CAFdhcLRZreD3Ps+vb3osnT3yNYQ_oK+OVq3GJ1oBhfZfyDchww@mail.gmail.com>
 <CALZtONAdrN2sknx_9USJUGEa+dUXLdg=kr_4g1u+zSQh4ZH=5w@mail.gmail.com>
 <CAFdhcLR-OxoOkYDwZMmbk4r6kdw+FDJpOvWkHqeDK=9WH9j46w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAFdhcLR-OxoOkYDwZMmbk4r6kdw+FDJpOvWkHqeDK=9WH9j46w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Horner <ds2horner@gmail.com>
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>

Hi Dan and David,

On Mon, Aug 25, 2014 at 09:54:57PM -0400, David Horner wrote:
> On Mon, Aug 25, 2014 at 2:12 PM, Dan Streetman <ddstreet@ieee.org> wrote:
> > On Mon, Aug 25, 2014 at 4:22 AM, David Horner <ds2horner@gmail.com> wrote:
> >> On Mon, Aug 25, 2014 at 12:37 AM, Minchan Kim <minchan@kernel.org> wrote:
> >>> On Sun, Aug 24, 2014 at 11:40:50PM -0400, David Horner wrote:
> >>>> On Sun, Aug 24, 2014 at 7:56 PM, Minchan Kim <minchan@kernel.org> wrote:
> >>>> > Hello David,
> >>>> >
> >>>> > On Fri, Aug 22, 2014 at 06:55:38AM -0400, David Horner wrote:
> >>>> >> On Thu, Aug 21, 2014 at 8:42 PM, Minchan Kim <minchan@kernel.org> wrote:
> >>>> >> > Since zram has no control feature to limit memory usage,
> >>>> >> > it makes hard to manage system memrory.
> >>>> >> >
> >>>> >> > This patch adds new knob "mem_limit" via sysfs to set up the
> >>>> >> > a limit so that zram could fail allocation once it reaches
> >>>> >> > the limit.
> >>>> >> >
> >>>> >> > In addition, user could change the limit in runtime so that
> >>>> >> > he could manage the memory more dynamically.
> >>>> >> >
> >>>> >> - Default is no limit so it doesn't break old behavior.
> >>>> >> + Initial state is no limit so it doesn't break old behavior.
> >>>> >>
> >>>> >> I understand your previous post now.
> >>>> >>
> >>>> >> I was saying that setting to either a null value or garbage
> >>>> >>  (which is interpreted as zero by memparse(buf, NULL);)
> >>>> >> removes the limit.
> >>>> >>
> >>>> >> I think this is "surprise" behaviour and rather the null case should
> >>>> >> return  -EINVAL
> >>>> >> The test below should be "good enough" though not catching all garbage.
> >>>> >
> >>>> > Thanks for suggesting but as I said, it should be fixed in memparse itself,
> >>>> > not caller if it is really problem so I don't want to touch it in this
> >>>> > patchset. It's not critical for adding the feature.
> >>>> >
> >>>>
> >>>> I've looked into the memparse function more since we talked.
> >>>> I do believe a wrapper function around it for the typical use by sysfs would
> >>>> be very valuable.
> >>>
> >>> Agree.
> >>>
> >>>> However, there is nothing wrong with memparse itself that needs to be fixed.
> >>>>
> >>>> It does what it is documented to do very well (In My Uninformed Opinion).
> >>>> It provides everything that a caller needs to manage the token that it
> >>>> processes.
> >>>> It thus handles strings like "7,,5,8,,9" with the implied zeros.
> >>>
> >>> Maybe strict_memparse would be better to protect such things so you
> >>> could find several places to clean it up.
> >>>
> >>>>
> >>>> The fact that other callers don't check the return pointer value to
> >>>> see if only a null
> >>>> string was processed, is not its fault.
> >>>> Nor that it may not be ideally suited to sysfs attributes; that other store
> >>>> functions use it in a given manner does not means that is correct -
> >>>> nor that it is
> >>>> incorrect for that "knob". Some attributes could be just as valid with
> >>>> null zeros.
> >>>>
> >>>> And you are correct, to disambiguate the zero is not required for the
> >>>> limit feature.
> >>>> Your original patch which disallowed zero was full feature for mem_limit.
> >>>> It is the requested non-crucial feature to allow zero to reestablish
> >>>> the initial state
> >>>>  that benefits from distinguishing an explicit zero from a "default zero'
> >>>>  when garbage is written.
> >>>>
> >>>> The final argument is that if we release this feature as is the undocumented
> >>>>  functionality could be relied upon, and when later fixed: user space breaks.
> >>>
> >>> I don't get it. Why does it break userspace?
> >>> The sysfs-block-zram says "0" means disable the limit.
> >>> If someone writes *garabge* but work as if disabling the limit,
> >>> it's not a right thing and he already broke although it worked
> >>> so it would be not a problem if we fix later.
> >>> (ie, we don't need to take care of broken userspace)
> >>> Am I missing your point?
> >>>
> >>
> >> Perhaps you are missing my point, perhaps ignoring or dismissing.
> >>
> >> Basically, if a facility works in a useful way, even if it was designed for
> >> different usage, that becomes the "accepted" interface/usage.
> >> The developer may not have intended that usage or may even considered
> >> it wrong and a broken usage, but it is what it is and people become
> >>  reliant on that behaviour.
> >>
> >> Case in point is memparse itself.
> >>
> >> The developer intentionally sets the return pointer because that is the
> >> only value that can be validated for correct performance.
> >> The return value allows -ve so the standard error message passing is not valid.
> >> Unfortunately, C allows the user to pass a NULL value in the parameter.
> >> The developer could consider that absurd and fundamentally broken.
> >> But to the user it is a valid situation, because (perhaps) it can't be
> >> bothered to handle error cases.
> >>
> >> So, who is to blame.
> >> You say memparse, that it is fundamentally broken,
> >>   because it didn't check to see that it was used correctly.
> >>  And I say  mem_limit_store is fundamentally broken,
> >>   because it didn't check to see that it was used correctly.
> >
> > I think we should look at what the rest of the kernel does as far as
> > checking memparse results.  It appears to be a mix of some code
> > checking memparse while others don't.  The most common way to check
> > appears to be to verify that memparse actually parsed at least 1
> > character, e.g.:
> >   oldp = p;
> >   mem_size = memparse(p, &p);
> >   if (p == oldp)
> >     return -EINVAL;
> >
> > although other places where 0 isn't valid can simply check for that:
> >   mem_size = memparse(p, &p);
> >   /* don't remove all of memory when handling "mem={invalid}" param */
> >   if (mem_size == 0)
> >     return -EINVAL;
> >
> > or even the other memparse use in zram_drv.c:
> >   disksize = memparse(buf, NULL);
> >   if (!disksize)
> >     return -EINVAL;
> >
> >
> > And there seem to be other places where (maybe?) there's no checking
> > at all.  However, it also seems like many cases of memparse usage are
> > looking for a non-zero value, and therefore they can either
> > immediately check for zero/invalid or (possibly) later code has checks
> > to avoid using any zero value.  In this case though, 0 is a valid
> > value.  So, while I agree that if a user passes an invalid (i.e.
> > non-numeric) value it's clearly user error, it might be closer to the
> > apparent (although unwritten AFAICT) memparse usage api to check the
> > result for validity; in our case a simple check if at least 1 char was
> > parsed is all that's needed, e.g.:
> >
> > {
> >   u64 limit;
> >   char *tmp = buf;
> >   struct zram *zram = dev_to_zram(dev);
> >
> >   limit = memparse(buf, &tmp);
> >   if (buf == tmp) /* no chars parsed, invalid input */
> >     return -EINVAL;
> >   down_write(&zram->init_lock);
> 
> 
> Thank you Dan, for this clear, unoffensive and I believe compelling analysis.

Thanks for suggestion, Dan.

David, Are you okay for this?

You pointed out several cases. One was NULL check.
Dan's patch will fix it but other example you pointed out was
"7,,5,8,,9". Slightly modifying your example, "0..1" can reset without
returning EINVAL. Actually, it was not what we want.
Couldn't we check it if you guys really want to prevent wrong use from
userspace? If we don't need it, pz, give me a reason so I will convince
and proceed this patchset and do further works.

Thanks.

> 
> I have much to learn.
> 
> > ...
> >
> >
> > Separate from this patch, it would also help if the lib/cmdline.c
> > memparse doc was at least updated to clarify when the result should be
> > checked for validity (e.g. always, or at least when the result is 0)
> > and how best to do that (e.g. if 0 is an invalid value, just check if
> > the result is 0; if 0 is a possible valid value, check if any chars
> > were parsed).
> >
> >
> 
> I'd argue that the code is not the place for this usage recommendation.
> But rather an expansion of the support doc for sysfs
> on how to use such parsing/validation routines.
> 
> I agree with Minchan that these helper functions could be improved
> for specific use by sysfs.
>  And I will pursue this. (and maybe the documentation?)
> 
> 
> >>
> >> The difference is that memparse cannot stop being abused
> >> (C allows the NULL argument and extensive tricks are required to address that)
> >> however, we can readily fix mem_limit_store and ensure
> >> 1) no regression when the interface IS fixed and
> >> 2) predictable behaviour when accidental or "fuzzy" input arrives.
> >>
> >>
> >>>> They say getting API right is a difficult exercise. I suggest, if we
> >>>> don't insisting on
> >>>>  an explicit zero we have the API wrong.
> >>>>
> >>>> I don't think you disagreed, just that the burden to get it correct
> >>>> lay elsewhere.
> >>>>
> >>>> If that is the case it doesn't really matter, we cannot release this
> >>>> interface until
> >>>>  it is corrected wherever it must be.
> >>>>
> >>>> And my zero check was a poor hack.
> >>>>
> >>>> I should have explicitly checked the returned pointer value.
> >>>>
> >>>> I will send that proposed revision, and hopefully you will consider it
> >>>> for inclusion.
> >>>>
> >>>>
> >>>>
> >>>>
> >>>> >>
> >>>> >> >
> >>>> >> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> >>>> >> > ---
> >>>> >> >  Documentation/ABI/testing/sysfs-block-zram | 10 ++++++++
> >>>> >> >  Documentation/blockdev/zram.txt            | 24 ++++++++++++++---
> >>>> >> >  drivers/block/zram/zram_drv.c              | 41 ++++++++++++++++++++++++++++++
> >>>> >> >  drivers/block/zram/zram_drv.h              |  5 ++++
> >>>> >> >  4 files changed, 76 insertions(+), 4 deletions(-)
> >>>> >> >
> >>>> >> > diff --git a/Documentation/ABI/testing/sysfs-block-zram b/Documentation/ABI/testing/sysfs-block-zram
> >>>> >> > index 70ec992514d0..b8c779d64968 100644
> >>>> >> > --- a/Documentation/ABI/testing/sysfs-block-zram
> >>>> >> > +++ b/Documentation/ABI/testing/sysfs-block-zram
> >>>> >> > @@ -119,3 +119,13 @@ Description:
> >>>> >> >                 efficiency can be calculated using compr_data_size and this
> >>>> >> >                 statistic.
> >>>> >> >                 Unit: bytes
> >>>> >> > +
> >>>> >> > +What:          /sys/block/zram<id>/mem_limit
> >>>> >> > +Date:          August 2014
> >>>> >> > +Contact:       Minchan Kim <minchan@kernel.org>
> >>>> >> > +Description:
> >>>> >> > +               The mem_limit file is read/write and specifies the amount
> >>>> >> > +               of memory to be able to consume memory to store store
> >>>> >> > +               compressed data. The limit could be changed in run time
> >>>> >> > -               and "0" is default which means disable the limit.
> >>>> >> > +               and "0" means disable the limit. No limit is the initial state.
> >>>> >>
> >>>> >> there should be no default in the API.
> >>>> >
> >>>> > Thanks.
> >>>> >
> >>>> >>
> >>>> >> > +               Unit: bytes
> >>>> >> > diff --git a/Documentation/blockdev/zram.txt b/Documentation/blockdev/zram.txt
> >>>> >> > index 0595c3f56ccf..82c6a41116db 100644
> >>>> >> > --- a/Documentation/blockdev/zram.txt
> >>>> >> > +++ b/Documentation/blockdev/zram.txt
> >>>> >> > @@ -74,14 +74,30 @@ There is little point creating a zram of greater than twice the size of memory
> >>>> >> >  since we expect a 2:1 compression ratio. Note that zram uses about 0.1% of the
> >>>> >> >  size of the disk when not in use so a huge zram is wasteful.
> >>>> >> >
> >>>> >> > -5) Activate:
> >>>> >> > +5) Set memory limit: Optional
> >>>> >> > +       Set memory limit by writing the value to sysfs node 'mem_limit'.
> >>>> >> > +       The value can be either in bytes or you can use mem suffixes.
> >>>> >> > +       In addition, you could change the value in runtime.
> >>>> >> > +       Examples:
> >>>> >> > +           # limit /dev/zram0 with 50MB memory
> >>>> >> > +           echo $((50*1024*1024)) > /sys/block/zram0/mem_limit
> >>>> >> > +
> >>>> >> > +           # Using mem suffixes
> >>>> >> > +           echo 256K > /sys/block/zram0/mem_limit
> >>>> >> > +           echo 512M > /sys/block/zram0/mem_limit
> >>>> >> > +           echo 1G > /sys/block/zram0/mem_limit
> >>>> >> > +
> >>>> >> > +           # To disable memory limit
> >>>> >> > +           echo 0 > /sys/block/zram0/mem_limit
> >>>> >> > +
> >>>> >> > +6) Activate:
> >>>> >> >         mkswap /dev/zram0
> >>>> >> >         swapon /dev/zram0
> >>>> >> >
> >>>> >> >         mkfs.ext4 /dev/zram1
> >>>> >> >         mount /dev/zram1 /tmp
> >>>> >> >
> >>>> >> > -6) Stats:
> >>>> >> > +7) Stats:
> >>>> >> >         Per-device statistics are exported as various nodes under
> >>>> >> >         /sys/block/zram<id>/
> >>>> >> >                 disksize
> >>>> >> > @@ -96,11 +112,11 @@ size of the disk when not in use so a huge zram is wasteful.
> >>>> >> >                 compr_data_size
> >>>> >> >                 mem_used_total
> >>>> >> >
> >>>> >> > -7) Deactivate:
> >>>> >> > +8) Deactivate:
> >>>> >> >         swapoff /dev/zram0
> >>>> >> >         umount /dev/zram1
> >>>> >> >
> >>>> >> > -8) Reset:
> >>>> >> > +9) Reset:
> >>>> >> >         Write any positive value to 'reset' sysfs node
> >>>> >> >         echo 1 > /sys/block/zram0/reset
> >>>> >> >         echo 1 > /sys/block/zram1/reset
> >>>> >> > diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> >>>> >> > index f0b8b30a7128..370c355eb127 100644
> >>>> >> > --- a/drivers/block/zram/zram_drv.c
> >>>> >> > +++ b/drivers/block/zram/zram_drv.c
> >>>> >> > @@ -122,6 +122,33 @@ static ssize_t max_comp_streams_show(struct device *dev,
> >>>> >> >         return scnprintf(buf, PAGE_SIZE, "%d\n", val);
> >>>> >> >  }
> >>>> >> >
> >>>> >> > +static ssize_t mem_limit_show(struct device *dev,
> >>>> >> > +               struct device_attribute *attr, char *buf)
> >>>> >> > +{
> >>>> >> > +       u64 val;
> >>>> >> > +       struct zram *zram = dev_to_zram(dev);
> >>>> >> > +
> >>>> >> > +       down_read(&zram->init_lock);
> >>>> >> > +       val = zram->limit_pages;
> >>>> >> > +       up_read(&zram->init_lock);
> >>>> >> > +
> >>>> >> > +       return scnprintf(buf, PAGE_SIZE, "%llu\n", val << PAGE_SHIFT);
> >>>> >> > +}
> >>>> >> > +
> >>>> >> > +static ssize_t mem_limit_store(struct device *dev,
> >>>> >> > +               struct device_attribute *attr, const char *buf, size_t len)
> >>>> >> > +{
> >>>> >> > +       u64 limit;
> >>>> >> > +       struct zram *zram = dev_to_zram(dev);
> >>>> >> > +
> >>>> >> > +       limit = memparse(buf, NULL);
> >>>> >>
> >>>> >>             if (limit = 0 && buf != "0")
> >>>> >>                   return  -EINVAL
> >>>> >>
> >>>> >> > +       down_write(&zram->init_lock);
> >>>> >> > +       zram->limit_pages = PAGE_ALIGN(limit) >> PAGE_SHIFT;
> >>>> >> > +       up_write(&zram->init_lock);
> >>>> >> > +
> >>>> >> > +       return len;
> >>>> >> > +}
> >>>> >> > +
> >>>> >> >  static ssize_t max_comp_streams_store(struct device *dev,
> >>>> >> >                 struct device_attribute *attr, const char *buf, size_t len)
> >>>> >> >  {
> >>>> >> > @@ -513,6 +540,14 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> >>>> >> >                 ret = -ENOMEM;
> >>>> >> >                 goto out;
> >>>> >> >         }
> >>>> >> > +
> >>>> >> > +       if (zram->limit_pages &&
> >>>> >> > +               zs_get_total_pages(meta->mem_pool) > zram->limit_pages) {
> >>>> >> > +               zs_free(meta->mem_pool, handle);
> >>>> >> > +               ret = -ENOMEM;
> >>>> >> > +               goto out;
> >>>> >> > +       }
> >>>> >> > +
> >>>> >> >         cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
> >>>> >> >
> >>>> >> >         if ((clen == PAGE_SIZE) && !is_partial_io(bvec)) {
> >>>> >> > @@ -617,6 +652,9 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
> >>>> >> >         struct zram_meta *meta;
> >>>> >> >
> >>>> >> >         down_write(&zram->init_lock);
> >>>> >> > +
> >>>> >> > +       zram->limit_pages = 0;
> >>>> >> > +
> >>>> >> >         if (!init_done(zram)) {
> >>>> >> >                 up_write(&zram->init_lock);
> >>>> >> >                 return;
> >>>> >> > @@ -857,6 +895,8 @@ static DEVICE_ATTR(initstate, S_IRUGO, initstate_show, NULL);
> >>>> >> >  static DEVICE_ATTR(reset, S_IWUSR, NULL, reset_store);
> >>>> >> >  static DEVICE_ATTR(orig_data_size, S_IRUGO, orig_data_size_show, NULL);
> >>>> >> >  static DEVICE_ATTR(mem_used_total, S_IRUGO, mem_used_total_show, NULL);
> >>>> >> > +static DEVICE_ATTR(mem_limit, S_IRUGO | S_IWUSR, mem_limit_show,
> >>>> >> > +               mem_limit_store);
> >>>> >> >  static DEVICE_ATTR(max_comp_streams, S_IRUGO | S_IWUSR,
> >>>> >> >                 max_comp_streams_show, max_comp_streams_store);
> >>>> >> >  static DEVICE_ATTR(comp_algorithm, S_IRUGO | S_IWUSR,
> >>>> >> > @@ -885,6 +925,7 @@ static struct attribute *zram_disk_attrs[] = {
> >>>> >> >         &dev_attr_orig_data_size.attr,
> >>>> >> >         &dev_attr_compr_data_size.attr,
> >>>> >> >         &dev_attr_mem_used_total.attr,
> >>>> >> > +       &dev_attr_mem_limit.attr,
> >>>> >> >         &dev_attr_max_comp_streams.attr,
> >>>> >> >         &dev_attr_comp_algorithm.attr,
> >>>> >> >         NULL,
> >>>> >> > diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
> >>>> >> > index e0f725c87cc6..b7aa9c21553f 100644
> >>>> >> > --- a/drivers/block/zram/zram_drv.h
> >>>> >> > +++ b/drivers/block/zram/zram_drv.h
> >>>> >> > @@ -112,6 +112,11 @@ struct zram {
> >>>> >> >         u64 disksize;   /* bytes */
> >>>> >> >         int max_comp_streams;
> >>>> >> >         struct zram_stats stats;
> >>>> >> > +       /*
> >>>> >> > +        * the number of pages zram can consume for storing compressed data
> >>>> >> > +        */
> >>>> >> > +       unsigned long limit_pages;
> >>>> >> > +
> >>>> >> >         char compressor[10];
> >>>> >> >  };
> >>>> >> >  #endif
> >>>> >> > --
> >>>> >> > 2.0.0
> >>>> >> >
> >>>> >>
> >>>> >> --
> >>>> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >>>> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >>>> >> see: http://www.linux-mm.org/ .
> >>>> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >>>> >
> >>>> > --
> >>>> > Kind regards,
> >>>> > Minchan Kim
> >>>>
> >>>> --
> >>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >>>> the body to majordomo@kvack.org.  For more info on Linux MM,
> >>>> see: http://www.linux-mm.org/ .
> >>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >>>
> >>> --
> >>> Kind regards,
> >>> Minchan Kim
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
