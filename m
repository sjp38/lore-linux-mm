Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id A24936B0036
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 02:19:30 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id r10so10093625pdi.39
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 23:19:30 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id o10si1699799pdr.229.2014.09.24.23.19.28
        for <linux-mm@kvack.org>;
        Wed, 24 Sep 2014 23:19:29 -0700 (PDT)
Date: Thu, 25 Sep 2014 15:20:05 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2] zsmalloc: merge size_class to reduce fragmentation
Message-ID: <20140925062004.GC23558@js1304-P5Q-DELUXE>
References: <1411538626-19285-1-git-send-email-iamjoonsoo.kim@lge.com>
 <CALZtONDFdn_NXj85GbOD263T8n9cwtJsWQELwdCBNHBKsddVtQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONDFdn_NXj85GbOD263T8n9cwtJsWQELwdCBNHBKsddVtQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Luigi Semenzato <semenzato@google.com>, juno.choi@lge.com, "seungho1.park" <seungho1.park@lge.com>

On Wed, Sep 24, 2014 at 12:24:14PM -0400, Dan Streetman wrote:
> On Wed, Sep 24, 2014 at 2:03 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > zsmalloc has many size_classes to reduce fragmentation and they are
> > in 16 bytes unit, for example, 16, 32, 48, etc., if PAGE_SIZE is 4096.
> > And, zsmalloc has constraint that each zspage has 4 pages at maximum.
> >
> > In this situation, we can see interesting aspect.
> > Let's think about size_class for 1488, 1472, ..., 1376.
> > To prevent external fragmentation, they uses 4 pages per zspage and
> > so all they can contain 11 objects at maximum.
> >
> > 16384 (4096 * 4) = 1488 * 11 + remains
> > 16384 (4096 * 4) = 1472 * 11 + remains
> > 16384 (4096 * 4) = ...
> > 16384 (4096 * 4) = 1376 * 11 + remains
> >
> > It means that they have same characteristics and classification between
> > them isn't needed. If we use one size_class for them, we can reduce
> > fragementation and save some memory.
> 
> Just a suggestion, but you might want to further clarify the example
> by saying something like:
> 
> since both the 1488 and 1472 sized classes can only fit 11 objects
> into 4 pages, and an object that's 1472 bytes can fit into an object
> that's 1488 bytes, merging these classes to always use objects that
> are 1488 bytes will reduce the total number of size classes.  And
> reducing the total number of size classes reduces overall
> fragmentation, because a wider range of compressed pages can fit into
> a single size class, leaving less unused objects in each size class.

Hello, Dan.

Yes, your suggestion is really good. I will add it on v3.

> 
> 
> > For this purpose, this patch
> > implement size_class merging. If there is size_class that have
> > same pages_per_zspage and same number of objects per zspage with previous
> > size_class, we don't create and use new size_class. Instead, we use
> > previous, same characteristic size_class. With this way, above example
> > sizes (1488, 1472, ..., 1376) use just one size_class so we can get much
> > more memory utilization.
> >
> > Below is result of my simple test.
> >
> > TEST ENV: EXT4 on zram, mount with discard option
> > WORKLOAD: untar kernel source code, remove directory in descending order
> > in size. (drivers arch fs sound include net Documentation firmware
> > kernel tools)
> >
> > Each line represents orig_data_size, compr_data_size, mem_used_total,
> > fragmentation overhead (mem_used - compr_data_size) and overhead ratio
> > (overhead to compr_data_size), respectively, after untar and remove
> > operation is executed.
> >
> > * untar-nomerge.out
> >
> > orig_size compr_size used_size overhead overhead_ratio
> > 525.88MB 199.16MB 210.23MB  11.08MB 5.56%
> > 288.32MB  97.43MB 105.63MB   8.20MB 8.41%
> > 177.32MB  61.12MB  69.40MB   8.28MB 13.55%
> > 146.47MB  47.32MB  56.10MB   8.78MB 18.55%
> > 124.16MB  38.85MB  48.41MB   9.55MB 24.58%
> > 103.93MB  31.68MB  40.93MB   9.25MB 29.21%
> >  84.34MB  22.86MB  32.72MB   9.86MB 43.13%
> >  66.87MB  14.83MB  23.83MB   9.00MB 60.70%
> >  60.67MB  11.11MB  18.60MB   7.49MB 67.48%
> >  55.86MB   8.83MB  16.61MB   7.77MB 88.03%
> >  53.32MB   8.01MB  15.32MB   7.31MB 91.24%
> >
> > * untar-merge.out
> >
> > orig_size compr_size used_size overhead overhead_ratio
> > 526.23MB 199.18MB 209.81MB  10.64MB 5.34%
> > 288.68MB  97.45MB 104.08MB   6.63MB 6.80%
> > 177.68MB  61.14MB  66.93MB   5.79MB 9.47%
> > 146.83MB  47.34MB  52.79MB   5.45MB 11.51%
> > 124.52MB  38.87MB  44.30MB   5.43MB 13.96%
> > 104.29MB  31.70MB  36.83MB   5.13MB 16.19%
> >  84.70MB  22.88MB  27.92MB   5.04MB 22.04%
> >  67.11MB  14.83MB  19.26MB   4.43MB 29.86%
> >  60.82MB  11.10MB  14.90MB   3.79MB 34.17%
> >  55.90MB   8.82MB  12.61MB   3.79MB 42.97%
> >  53.32MB   8.01MB  11.73MB   3.73MB 46.53%
> >
> > As you can see above result, merged one has better utilization (overhead
> > ratio, 5th column) and uses less memory (mem_used_total, 3rd column).
> 
> This patch is definitely a good idea!

Thank you. :)

> >
> > Changed from v1:
> > - More commit description about what to do in this patch.
> > - Remove nr_obj in size_class, because it isn't need after initialization.
> > - Rename __size_class to size_class, size_class to merged_size_class.
> > - Add code comment for merged_size_class of struct zs_pool.
> > - Add code comment how merging works in zs_create_pool().
> >
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > ---
> >  mm/zsmalloc.c |   57 ++++++++++++++++++++++++++++++++++++++++++++++++---------
> >  1 file changed, 48 insertions(+), 9 deletions(-)
> >
> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > index c4a9157..586c19d 100644
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -214,6 +214,11 @@ struct link_free {
> >  };
> >
> >  struct zs_pool {
> > +       /*
> > +        * Each merge_size_class is pointing to one of size_class that have
> > +        * same characteristics. See zs_create_pool() for more information.
> > +        */
> > +       struct size_class *merged_size_class[ZS_SIZE_CLASSES];
> >         struct size_class size_class[ZS_SIZE_CLASSES];
> 
> Isn't this confusing and wasteful?  merged_size_class is what
> everything should use, and each of those just point to one of the
> size_class entries, and not all size_class entries will be used.
> 
> Instead can we just keep only size_class[], but change it to pointers,
> and use kmalloc in zs_create_pool?  That wastes no memory and doesn't
> have duplicate arrays with confusingly similar names :-)

I will do it.

> 
> >
> >         gfp_t flags;    /* allocation flags used when growing pool */
> > @@ -468,7 +473,7 @@ static enum fullness_group fix_fullness_group(struct zs_pool *pool,
> >         if (newfg == currfg)
> >                 goto out;
> >
> > -       class = &pool->size_class[class_idx];
> > +       class = pool->merged_size_class[class_idx];
> >         remove_zspage(page, class, currfg);
> >         insert_zspage(page, class, newfg);
> >         set_zspage_mapping(page, class_idx, newfg);
> > @@ -929,6 +934,22 @@ fail:
> >         return notifier_to_errno(ret);
> >  }
> >
> > +static unsigned int objs_per_zspage(struct size_class *class)
> > +{
> > +       return class->pages_per_zspage * PAGE_SIZE / class->size;
> > +}
> > +
> > +static bool can_merge(struct size_class *prev, struct size_class *curr)
> > +{
> > +       if (prev->pages_per_zspage != curr->pages_per_zspage)
> > +               return false;
> > +
> > +       if (objs_per_zspage(prev) != objs_per_zspage(curr))
> > +               return false;
> > +
> > +       return true;
> > +}
> > +
> >  /**
> >   * zs_create_pool - Creates an allocation pool to work from.
> >   * @flags: allocation flags used to allocate pool metadata
> > @@ -949,9 +970,14 @@ struct zs_pool *zs_create_pool(gfp_t flags)
> >         if (!pool)
> >                 return NULL;
> >
> > -       for (i = 0; i < ZS_SIZE_CLASSES; i++) {
> > +       /*
> > +        * Loop reversly, because, size of size_class that we want to use for
> > +        * merging should be larger or equal to current size.
> > +        */
> > +       for (i = ZS_SIZE_CLASSES - 1; i >= 0; i--) {
> >                 int size;
> >                 struct size_class *class;
> > +               struct size_class *prev_class;
> >
> >                 size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA;
> >                 if (size > ZS_MAX_ALLOC_SIZE)
> > @@ -963,6 +989,22 @@ struct zs_pool *zs_create_pool(gfp_t flags)
> >                 spin_lock_init(&class->lock);
> >                 class->pages_per_zspage = get_pages_per_zspage(size);
> >
> > +               pool->merged_size_class[i] = class;
> > +               if (i == ZS_SIZE_CLASSES - 1)
> > +                       continue;
> > +
> > +               /*
> > +                * merged_size_class is used for normal zsmalloc operation such
> > +                * as alloc/free for that size. Although it is natural that we
> > +                * have one size_class for each size, there is a chance that we
> > +                * can get more memory utilization if we use one size_class for
> > +                * many different sizes whose size_class have same
> > +                * characteristics. So, we makes merged_size_class point to
> > +                * previous size_class if possible.
> > +                */
> > +               prev_class = pool->merged_size_class[i + 1];
> > +               if (can_merge(prev_class, class))
> > +                       pool->merged_size_class[i] = prev_class;
> >         }
> >
> >         pool->flags = flags;
> > @@ -1003,7 +1045,6 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
> >  {
> >         unsigned long obj;
> >         struct link_free *link;
> > -       int class_idx;
> >         struct size_class *class;
> >
> >         struct page *first_page, *m_page;
> > @@ -1012,9 +1053,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
> >         if (unlikely(!size || size > ZS_MAX_ALLOC_SIZE))
> >                 return 0;
> >
> > -       class_idx = get_size_class_index(size);
> > -       class = &pool->size_class[class_idx];
> > -       BUG_ON(class_idx != class->index);
> > +       class = pool->merged_size_class[get_size_class_index(size)];
> 
> As this change implies, class->index will no longer always be equal to
> the index used in pool->class[index], since with merged size classes
> the class->index will be the highest index of the merged classes.
> 
> Most places in the code won't care about this, but the two places that
> definitely do need fixing are where classes are iterated by index
> number.  I believe those places are zs_destroy_pool() and
> zs_get_total_size_bytes().  Probably, the for() iteration currently in
> use should be replaced by a for_each_size_class() function, that
> automatically skips size classes that are duplicates in a merged size
> class.  Of course, the for() iteration in zs_create_pool() has to
> stay, since that's where the merged classes are setup.

Now, there is no zs_get_total_size_bytes(), isn't it?
I will change zs_destroy_pool() according to change you suggested.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
