Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 841DC6B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 00:41:24 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id z10so656782pdj.1
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 21:41:24 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ez5si2635138pab.48.2014.01.14.21.41.21
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 21:41:23 -0800 (PST)
Date: Wed, 15 Jan 2014 14:42:08 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/zswap: add writethrough option
Message-ID: <20140115054208.GL1992@bbox>
References: <1387459407-29342-1-git-send-email-ddstreet@ieee.org>
 <20140114001115.GU1992@bbox>
 <CALZtONCCrckuHxgHB=GQj0tHszLAYTZZLGzFTnRkj9pvxx0dyg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONCCrckuHxgHB=GQj0tHszLAYTZZLGzFTnRkj9pvxx0dyg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Weijie Yang <weijie.yang@samsung.com>, Shirish Pargaonkar <spargaonkar@suse.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

Hello,

On Tue, Jan 14, 2014 at 10:10:44AM -0500, Dan Streetman wrote:
> On Mon, Jan 13, 2014 at 7:11 PM, Minchan Kim <minchan@kernel.org> wrote:
> > Hello Dan,
> >
> > Sorry for the late response and I didn't look at the code yet
> > because I am not convinced. :(
> >
> > On Thu, Dec 19, 2013 at 08:23:27AM -0500, Dan Streetman wrote:
> >> Currently, zswap is writeback cache; stored pages are not sent
> >> to swap disk, and when zswap wants to evict old pages it must
> >> first write them back to swap cache/disk manually.  This avoids
> >> swap out disk I/O up front, but only moves that disk I/O to
> >> the writeback case (for pages that are evicted), and adds the
> >> overhead of having to uncompress the evicted pages and the
> >> need for an additional free page (to store the uncompressed page).
> >>
> >> This optionally changes zswap to writethrough cache by enabling
> >> frontswap_writethrough() before registering, so that any
> >> successful page store will also be written to swap disk.  The
> >> default remains writeback.  To enable writethrough, the param
> >> zswap.writethrough=1 must be used at boot.
> >>
> >> Whether writeback or writethrough will provide better performance
> >> depends on many factors including disk I/O speed/throughput,
> >> CPU speed(s), system load, etc.  In most cases it is likely
> >> that writeback has better performance than writethrough before
> >> zswap is full, but after zswap fills up writethrough has
> >> better performance than writeback.
> >
> > So you claims we should use writeback default but writethrough
> > after memory limit is full?
> > But it would break LRU ordering and I think better idea is to
> > handle it more generic way rather than chaning entire policy.
> 
> This patch only adds the option of using writethrough.  That's all.

The point is that please explain that what's the your problem now
and prove that adding new option for solve the problem is best.
Just "Optionally, having is better" is not good approach to merge/maintain.

> 
> > Now, zswap evict out just *a* page rather than a bunch of pages
> > so it stucks every store if many swap write happens continuously.
> > It's not efficient so how about adding kswapd's threshold concept
> > like min/low/high? So, it could evict early before reaching zswap
> > memory pool and stop it reaches high watermark.
> > I guess it could be better than now.
> 
> Well, I don't think that's related to this patch, but certainly a good idea to
> investigate.

Why I suggested it that I feel from your description that wb is just
slower than wt since zswap memory is pool.

> 
> >
> > Other point: As I read device-mapper/cache.txt, cache operating mode
> > already supports writethrough. It means zram zRAM can support
> > writeback/writethough with dm-cache.
> > Have you tried it? Is there any problem?
> 
> zswap isn't a block device though, so that doesn't apply (unless I'm
> missing something).

zram is block device so freely you can make it to swap block device
and binding it with dm-cache will make what you want.
The whole point is we could do what you want without adding new
so I hope you prove what's the problem in existing solution so that
we could judge and try to solve the pain point with more ideal
approach.

> 
> >
> > Acutally, I really don't know how much benefit we have that in-memory
> > swap overcomming to the real storage but if you want, zRAM with dm-cache
> > is another option rather than invent new wheel by "just having is better".
> 
> I'm not sure if this patch is related to the zswap vs. zram discussions.  This
> only adds the option of using writethrough to zswap.  It's a first
> step to possibly
> making zswap work more efficiently using writeback and/or writethrough
> depending on
> the system and conditions.

The patch size is small. Okay I don't want to be a party-pooper
but at least, I should say my thought for Andrew to help judging.

> 
> >
> > Thanks.
> >
> >>
> >> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> >>
> >> ---
> >>
> >> Based on specjbb testing on my laptop, the results for both writeback
> >> and writethrough are better than not using zswap at all, but writeback
> >> does seem to be better than writethrough while zswap isn't full.  Once
> >> it fills up, performance for writethrough is essentially close to not
> >> using zswap, while writeback seems to be worse than not using zswap.
> >> However, I think more testing on a wider span of systems and conditions
> >> is needed.  Additionally, I'm not sure that specjbb is measuring true
> >> performance under fully loaded cpu conditions, so additional cpu load
> >> might need to be added or specjbb parameters modified (I took the
> >> values from the 4 "warehouses" test run).
> >>
> >> In any case though, I think having writethrough as an option is still
> >> useful.  More changes could be made, such as changing from writeback
> >> to writethrough based on the zswap % full.  And the patch doesn't
> >> change default behavior - writethrough must be specifically enabled.
> >>
> >> The %-ized numbers I got from specjbb on average, using the default
> >> 20% max_pool_percent and varying the amount of heap used as shown:
> >>
> >> ram | no zswap | writeback | writethrough
> >> 75     93.08     100         96.90
> >> 87     96.58     95.58       96.72
> >> 100    92.29     89.73       86.75
> >> 112    63.80     38.66       19.66
> >> 125    4.79      29.90       15.75
> >> 137    4.99      4.50        4.75
> >> 150    4.28      4.62        5.01
> >> 162    5.20      2.94        4.66
> >> 175    5.71      2.11        4.84
> >>
> >>
> >>
> >>  mm/zswap.c | 68 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++----
> >>  1 file changed, 64 insertions(+), 4 deletions(-)
> >>
> >> diff --git a/mm/zswap.c b/mm/zswap.c
> >> index e55bab9..2f919db 100644
> >> --- a/mm/zswap.c
> >> +++ b/mm/zswap.c
> >> @@ -61,6 +61,8 @@ static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
> >>  static u64 zswap_pool_limit_hit;
> >>  /* Pages written back when pool limit was reached */
> >>  static u64 zswap_written_back_pages;
> >> +/* Pages evicted when pool limit was reached */
> >> +static u64 zswap_evicted_pages;
> >>  /* Store failed due to a reclaim failure after pool limit was reached */
> >>  static u64 zswap_reject_reclaim_fail;
> >>  /* Compressed page was too big for the allocator to (optimally) store */
> >> @@ -89,6 +91,10 @@ static unsigned int zswap_max_pool_percent = 20;
> >>  module_param_named(max_pool_percent,
> >>                       zswap_max_pool_percent, uint, 0644);
> >>
> >> +/* Writeback/writethrough mode (fixed at boot for now) */
> >> +static bool zswap_writethrough;
> >> +module_param_named(writethrough, zswap_writethrough, bool, 0444);
> >> +
> >>  /*********************************
> >>  * compression functions
> >>  **********************************/
> >> @@ -629,6 +635,48 @@ end:
> >>  }
> >>
> >>  /*********************************
> >> +* evict code
> >> +**********************************/
> >> +
> >> +/*
> >> + * This evicts pages that have already been written through to swap.
> >> + */
> >> +static int zswap_evict_entry(struct zbud_pool *pool, unsigned long handle)
> >> +{
> >> +     struct zswap_header *zhdr;
> >> +     swp_entry_t swpentry;
> >> +     struct zswap_tree *tree;
> >> +     pgoff_t offset;
> >> +     struct zswap_entry *entry;
> >> +
> >> +     /* extract swpentry from data */
> >> +     zhdr = zbud_map(pool, handle);
> >> +     swpentry = zhdr->swpentry; /* here */
> >> +     zbud_unmap(pool, handle);
> >> +     tree = zswap_trees[swp_type(swpentry)];
> >> +     offset = swp_offset(swpentry);
> >> +     BUG_ON(pool != tree->pool);
> >> +
> >> +     /* find and ref zswap entry */
> >> +     spin_lock(&tree->lock);
> >> +     entry = zswap_rb_search(&tree->rbroot, offset);
> >> +     if (!entry) {
> >> +             /* entry was invalidated */
> >> +             spin_unlock(&tree->lock);
> >> +             return 0;
> >> +     }
> >> +
> >> +     zswap_evicted_pages++;
> >> +
> >> +     zswap_rb_erase(&tree->rbroot, entry);
> >> +     zswap_entry_put(tree, entry);
> >> +
> >> +     spin_unlock(&tree->lock);
> >> +
> >> +     return 0;
> >> +}
> >> +
> >> +/*********************************
> >>  * frontswap hooks
> >>  **********************************/
> >>  /* attempts to compress and store an single page */
> >> @@ -744,7 +792,7 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
> >>       spin_lock(&tree->lock);
> >>       entry = zswap_entry_find_get(&tree->rbroot, offset);
> >>       if (!entry) {
> >> -             /* entry was written back */
> >> +             /* entry was written back or evicted */
> >>               spin_unlock(&tree->lock);
> >>               return -1;
> >>       }
> >> @@ -778,7 +826,7 @@ static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t offset)
> >>       spin_lock(&tree->lock);
> >>       entry = zswap_rb_search(&tree->rbroot, offset);
> >>       if (!entry) {
> >> -             /* entry was written back */
> >> +             /* entry was written back or evicted */
> >>               spin_unlock(&tree->lock);
> >>               return;
> >>       }
> >> @@ -813,18 +861,26 @@ static void zswap_frontswap_invalidate_area(unsigned type)
> >>       zswap_trees[type] = NULL;
> >>  }
> >>
> >> -static struct zbud_ops zswap_zbud_ops = {
> >> +static struct zbud_ops zswap_zbud_writeback_ops = {
> >>       .evict = zswap_writeback_entry
> >>  };
> >> +static struct zbud_ops zswap_zbud_writethrough_ops = {
> >> +     .evict = zswap_evict_entry
> >> +};
> >>
> >>  static void zswap_frontswap_init(unsigned type)
> >>  {
> >>       struct zswap_tree *tree;
> >> +     struct zbud_ops *ops;
> >>
> >>       tree = kzalloc(sizeof(struct zswap_tree), GFP_KERNEL);
> >>       if (!tree)
> >>               goto err;
> >> -     tree->pool = zbud_create_pool(GFP_KERNEL, &zswap_zbud_ops);
> >> +     if (zswap_writethrough)
> >> +             ops = &zswap_zbud_writethrough_ops;
> >> +     else
> >> +             ops = &zswap_zbud_writeback_ops;
> >> +     tree->pool = zbud_create_pool(GFP_KERNEL, ops);
> >>       if (!tree->pool)
> >>               goto freetree;
> >>       tree->rbroot = RB_ROOT;
> >> @@ -875,6 +931,8 @@ static int __init zswap_debugfs_init(void)
> >>                       zswap_debugfs_root, &zswap_reject_compress_poor);
> >>       debugfs_create_u64("written_back_pages", S_IRUGO,
> >>                       zswap_debugfs_root, &zswap_written_back_pages);
> >> +     debugfs_create_u64("evicted_pages", S_IRUGO,
> >> +                     zswap_debugfs_root, &zswap_evicted_pages);
> >>       debugfs_create_u64("duplicate_entry", S_IRUGO,
> >>                       zswap_debugfs_root, &zswap_duplicate_entry);
> >>       debugfs_create_u64("pool_pages", S_IRUGO,
> >> @@ -919,6 +977,8 @@ static int __init init_zswap(void)
> >>               pr_err("per-cpu initialization failed\n");
> >>               goto pcpufail;
> >>       }
> >> +     if (zswap_writethrough)
> >> +             frontswap_writethrough(true);
> >>       frontswap_register_ops(&zswap_frontswap_ops);
> >>       if (zswap_debugfs_init())
> >>               pr_warn("debugfs initialization failed\n");
> >> --
> >> 1.8.3.1
> >>
> >> --
> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >> see: http://www.linux-mm.org/ .
> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> > --
> > Kind regards,
> > Minchan Kim
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
