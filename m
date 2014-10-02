Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id C1C106B0038
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 10:48:12 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id a1so3392710wgh.11
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 07:48:12 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id o1si1397456wix.50.2014.10.02.07.48.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Oct 2014 07:48:11 -0700 (PDT)
Received: by mail-wi0-f178.google.com with SMTP id cc10so4335605wib.5
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 07:48:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20141002054426.GA4515@bbox>
References: <1411976727-29421-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20140929231022.GC18318@bbox> <20141002053949.GC7433@js1304-P5Q-DELUXE> <20141002054426.GA4515@bbox>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 2 Oct 2014 10:47:51 -0400
Message-ID: <CALZtONAX0sXvynpWvg+MNayhNnoh=F2vc=MCQLEovfiU6x-HuA@mail.gmail.com>
Subject: Re: [PATCH v4] zsmalloc: merge size_class to reduce fragmentation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@lge.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, juno.choi@lge.com, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Luigi Semenzato <semenzato@google.com>, "seungho1.park" <seungho1.park@lge.com>, Nitin Gupta <ngupta@vflare.org>

On Thu, Oct 2, 2014 at 1:44 AM, Minchan Kim <minchan.kim@lge.com> wrote:
> On Thu, Oct 02, 2014 at 02:39:49PM +0900, Joonsoo Kim wrote:
>> On Tue, Sep 30, 2014 at 08:10:22AM +0900, Minchan Kim wrote:
>> > Hey Joonsoo,
>> >
>> > On Mon, Sep 29, 2014 at 04:45:27PM +0900, Joonsoo Kim wrote:
>> > > zsmalloc has many size_classes to reduce fragmentation and they are
>> > > in 16 bytes unit, for example, 16, 32, 48, etc., if PAGE_SIZE is 4096.
>> > > And, zsmalloc has constraint that each zspage has 4 pages at maximum.
>> > >
>> > > In this situation, we can see interesting aspect.
>> > > Let's think about size_class for 1488, 1472, ..., 1376.
>> > > To prevent external fragmentation, they uses 4 pages per zspage and
>> > > so all they can contain 11 objects at maximum.
>> > >
>> > > 16384 (4096 * 4) = 1488 * 11 + remains
>> > > 16384 (4096 * 4) = 1472 * 11 + remains
>> > > 16384 (4096 * 4) = ...
>> > > 16384 (4096 * 4) = 1376 * 11 + remains
>> > >
>> > > It means that they have same characteristics and classification between
>> > > them isn't needed. If we use one size_class for them, we can reduce
>> > > fragementation and save some memory since both the 1488 and 1472 sized
>> > > classes can only fit 11 objects into 4 pages, and an object that's
>> > > 1472 bytes can fit into an object that's 1488 bytes, merging these
>> > > classes to always use objects that are 1488 bytes will reduce the total
>> > > number of size classes. And reducing the total number of size classes
>> > > reduces overall fragmentation, because a wider range of compressed pages
>> > > can fit into a single size class, leaving less unused objects in each
>> > > size class.
>> > >
>> > > For this purpose, this patch implement size_class merging. If there is
>> > > size_class that have same pages_per_zspage and same number of objects
>> > > per zspage with previous size_class, we don't create new size_class.
>> > > Instead, we use previous, same characteristic size_class. With this way,
>> > > above example sizes (1488, 1472, ..., 1376) use just one size_class
>> > > so we can get much more memory utilization.
>> > >
>> > > Below is result of my simple test.
>> > >
>> > > TEST ENV: EXT4 on zram, mount with discard option
>> > > WORKLOAD: untar kernel source code, remove directory in descending order
>> > > in size. (drivers arch fs sound include net Documentation firmware
>> > > kernel tools)
>> > >
>> > > Each line represents orig_data_size, compr_data_size, mem_used_total,
>> > > fragmentation overhead (mem_used - compr_data_size) and overhead ratio
>> > > (overhead to compr_data_size), respectively, after untar and remove
>> > > operation is executed.
>> > >
>> > > * untar-nomerge.out
>> > >
>> > > orig_size compr_size used_size overhead overhead_ratio
>> > > 525.88MB 199.16MB 210.23MB  11.08MB 5.56%
>> > > 288.32MB  97.43MB 105.63MB   8.20MB 8.41%
>> > > 177.32MB  61.12MB  69.40MB   8.28MB 13.55%
>> > > 146.47MB  47.32MB  56.10MB   8.78MB 18.55%
>> > > 124.16MB  38.85MB  48.41MB   9.55MB 24.58%
>> > > 103.93MB  31.68MB  40.93MB   9.25MB 29.21%
>> > >  84.34MB  22.86MB  32.72MB   9.86MB 43.13%
>> > >  66.87MB  14.83MB  23.83MB   9.00MB 60.70%
>> > >  60.67MB  11.11MB  18.60MB   7.49MB 67.48%
>> > >  55.86MB   8.83MB  16.61MB   7.77MB 88.03%
>> > >  53.32MB   8.01MB  15.32MB   7.31MB 91.24%
>> > >
>> > > * untar-merge.out
>> > >
>> > > orig_size compr_size used_size overhead overhead_ratio
>> > > 526.23MB 199.18MB 209.81MB  10.64MB 5.34%
>> > > 288.68MB  97.45MB 104.08MB   6.63MB 6.80%
>> > > 177.68MB  61.14MB  66.93MB   5.79MB 9.47%
>> > > 146.83MB  47.34MB  52.79MB   5.45MB 11.51%
>> > > 124.52MB  38.87MB  44.30MB   5.43MB 13.96%
>> > > 104.29MB  31.70MB  36.83MB   5.13MB 16.19%
>> > >  84.70MB  22.88MB  27.92MB   5.04MB 22.04%
>> > >  67.11MB  14.83MB  19.26MB   4.43MB 29.86%
>> > >  60.82MB  11.10MB  14.90MB   3.79MB 34.17%
>> > >  55.90MB   8.82MB  12.61MB   3.79MB 42.97%
>> > >  53.32MB   8.01MB  11.73MB   3.73MB 46.53%
>> > >
>> > > As you can see above result, merged one has better utilization (overhead
>> > > ratio, 5th column) and uses less memory (mem_used_total, 3rd column).
>> > >
>> > > Changes from v1:
>> > > - More commit description about what to do in this patch.
>> > > - Remove nr_obj in size_class, because it isn't need after initialization.
>> > > - Rename __size_class to size_class, size_class to merged_size_class.
>> > > - Add code comment for merged_size_class of struct zs_pool.
>> > > - Add code comment how merging works in zs_create_pool().
>> > >
>> > > Changes from v2:
>> > > - Add more commit description (Dan)
>> > > - dynamically allocate size_class structure (Dan)
>> > > - rename objs_per_zspage to get_maxobj_per_zspage (Minchan)
>> > >
>> > > Changes from v3:
>> > > - Add error handling logic in zs_create_pool (Dan)
>> > >
>> > > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> > > ---
>> > >  mm/zsmalloc.c |   84 +++++++++++++++++++++++++++++++++++++++++++++++----------
>> > >  1 file changed, 70 insertions(+), 14 deletions(-)
>> > >
>> > > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
>> > > index c4a9157..11556ae 100644
>> > > --- a/mm/zsmalloc.c
>> > > +++ b/mm/zsmalloc.c
>> > > @@ -187,6 +187,7 @@ enum fullness_group {
>> > >  static const int fullness_threshold_frac = 4;
>> > >
>> > >  struct size_class {
>> > > + int ref;
>> >
>> > Couldn't we remove the ref from size_class by making zs_destroy_pool
>> > aware of merged size class like zs_create_pool?
>> >
>>
>> Hello,
>>
>> I think that using ref would makes intuitive code. Although there is
>> some memory overhead, it is really small. So I prefer to this way.
>>
>> But, if you think that removing ref is better, I will do it.
>> Please let me know your final decision.
>
> Yeb, please remove the ref. I want to keep size_class small for
> cache footprint.

i think a foreach_size_class() would be useful for zs_destroy_pool(),
and in case any other size class iterations are added in the future,
and it wouldn't require the extra ref field.  You can use the fact
that all merged size classes contain a class->index of the
highest/largest size_class (because they all point to the same size
class).  So something like:

#define foreach_size_class(pool, class) for(class=pool->size_class[0];
class; class = class->index+1 < ZS_SIZE_CLASSES ?
pool->size_class[class->index+1] : NULL)

you would not be able to use that for a failed zs_create_pool() though
since the lower size classes would still be NULL; but you don't need
to do everything zs_destroy_pool() does (e.g. no need to check
fullness groups), so you could just manually iterate in
zs_create_pool() err case through the previously created classes to
free them.  You could define foreach_size_class_from(pool, class) to
help, starting at the previously-created class.

>
> --
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
