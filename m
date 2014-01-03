Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id DC3D36B0035
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 21:23:20 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id lf10so15308655pab.28
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 18:23:20 -0800 (PST)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id ob10si44148661pbb.307.2014.01.02.18.23.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 02 Jan 2014 18:23:19 -0800 (PST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MYS00DHZZYRL0B0@mailout4.samsung.com> for
 linux-mm@kvack.org; Fri, 03 Jan 2014 11:23:16 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
References: <1387459407-29342-1-git-send-email-ddstreet@ieee.org>
 <CALZtONDyq_r5=KBYBChWPG0WXDXOyFXBQ7ZZd7+6BXRZzDrNwA@mail.gmail.com>
In-reply-to: 
 <CALZtONDyq_r5=KBYBChWPG0WXDXOyFXBQ7ZZd7+6BXRZzDrNwA@mail.gmail.com>
Subject: RE: [PATCH] mm/zswap: add writethrough option
Date: Fri, 03 Jan 2014 10:21:34 +0800
Message-id: <000001cf082a$bfc28a40$3f479ec0$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Dan Streetman' <ddstreet@ieee.org>, 'Seth Jennings' <sjennings@variantweb.net>
Cc: 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Bob Liu' <bob.liu@oracle.com>, 'Minchan Kim' <minchan@kernel.org>, 'Shirish Pargaonkar' <spargaonkar@suse.com>, 'Mel Gorman' <mgorman@suse.de>, 'Andrew Morton' <akpm@linux-foundation.org>

On Thu, Jan 2, 2014 at 11:38 PM, Dan Streetman <ddstreet@ieee.org> wrote:
> Happy new year!
>
> Seth, just checking if you have had a chance yet to think about this one.
>
>
> On Thu, Dec 19, 2013 at 8:23 AM, Dan Streetman <ddstreet@ieee.org> wrote:
> > Currently, zswap is writeback cache; stored pages are not sent
> > to swap disk, and when zswap wants to evict old pages it must
> > first write them back to swap cache/disk manually.  This avoids
> > swap out disk I/O up front, but only moves that disk I/O to
> > the writeback case (for pages that are evicted), and adds the
> > overhead of having to uncompress the evicted pages and the
> > need for an additional free page (to store the uncompressed page).
> >
> > This optionally changes zswap to writethrough cache by enabling
> > frontswap_writethrough() before registering, so that any
> > successful page store will also be written to swap disk.  The
> > default remains writeback.  To enable writethrough, the param
> > zswap.writethrough=1 must be used at boot.
> >
> > Whether writeback or writethrough will provide better performance
> > depends on many factors including disk I/O speed/throughput,
> > CPU speed(s), system load, etc.  In most cases it is likely
> > that writeback has better performance than writethrough before
> > zswap is full, but after zswap fills up writethrough has
> > better performance than writeback.
> >
> > Signed-off-by: Dan Streetman <ddstreet@ieee.org>

Thanks for your work.
Although I won't try writethrough mode in embedded device, I hope it may be
helpful to others.
I reviewed this patch, and it is good to me.

Reviewed-by: Weijie Yang <weijie.yang@samsung.com>

> > ---
> >
> > Based on specjbb testing on my laptop, the results for both writeback
> > and writethrough are better than not using zswap at all, but writeback
> > does seem to be better than writethrough while zswap isn't full.  Once
> > it fills up, performance for writethrough is essentially close to not
> > using zswap, while writeback seems to be worse than not using zswap.
> > However, I think more testing on a wider span of systems and conditions
> > is needed.  Additionally, I'm not sure that specjbb is measuring true
> > performance under fully loaded cpu conditions, so additional cpu load
> > might need to be added or specjbb parameters modified (I took the
> > values from the 4 "warehouses" test run).
> >
> > In any case though, I think having writethrough as an option is still
> > useful.  More changes could be made, such as changing from writeback
> > to writethrough based on the zswap % full.  And the patch doesn't
> > change default behavior - writethrough must be specifically enabled.
> >
> > The %-ized numbers I got from specjbb on average, using the default
> > 20% max_pool_percent and varying the amount of heap used as shown:
> >
> > ram | no zswap | writeback | writethrough
> > 75     93.08     100         96.90
> > 87     96.58     95.58       96.72
> > 100    92.29     89.73       86.75
> > 112    63.80     38.66       19.66
> > 125    4.79      29.90       15.75
> > 137    4.99      4.50        4.75
> > 150    4.28      4.62        5.01
> > 162    5.20      2.94        4.66
> > 175    5.71      2.11        4.84
> >
> >
> >
> >  mm/zswap.c | 68 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++----
> >  1 file changed, 64 insertions(+), 4 deletions(-)
> >
> > diff --git a/mm/zswap.c b/mm/zswap.c
> > index e55bab9..2f919db 100644
> > --- a/mm/zswap.c
> > +++ b/mm/zswap.c
> > @@ -61,6 +61,8 @@ static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
> >  static u64 zswap_pool_limit_hit;
> >  /* Pages written back when pool limit was reached */
> >  static u64 zswap_written_back_pages;
> > +/* Pages evicted when pool limit was reached */
> > +static u64 zswap_evicted_pages;
> >  /* Store failed due to a reclaim failure after pool limit was reached */
> >  static u64 zswap_reject_reclaim_fail;
> >  /* Compressed page was too big for the allocator to (optimally) store */
> > @@ -89,6 +91,10 @@ static unsigned int zswap_max_pool_percent = 20;
> >  module_param_named(max_pool_percent,
> >                         zswap_max_pool_percent, uint, 0644);
> >
> > +/* Writeback/writethrough mode (fixed at boot for now) */
> > +static bool zswap_writethrough;
> > +module_param_named(writethrough, zswap_writethrough, bool, 0444);
> > +
> >  /*********************************
> >  * compression functions
> >  **********************************/
> > @@ -629,6 +635,48 @@ end:
> >  }
> >
> >  /*********************************
> > +* evict code
> > +**********************************/
> > +
> > +/*
> > + * This evicts pages that have already been written through to swap.
> > + */
> > +static int zswap_evict_entry(struct zbud_pool *pool, unsigned long handle)
> > +{
> > +       struct zswap_header *zhdr;
> > +       swp_entry_t swpentry;
> > +       struct zswap_tree *tree;
> > +       pgoff_t offset;
> > +       struct zswap_entry *entry;
> > +
> > +       /* extract swpentry from data */
> > +       zhdr = zbud_map(pool, handle);
> > +       swpentry = zhdr->swpentry; /* here */
> > +       zbud_unmap(pool, handle);
> > +       tree = zswap_trees[swp_type(swpentry)];
> > +       offset = swp_offset(swpentry);
> > +       BUG_ON(pool != tree->pool);
> > +
> > +       /* find and ref zswap entry */
> > +       spin_lock(&tree->lock);
> > +       entry = zswap_rb_search(&tree->rbroot, offset);
> > +       if (!entry) {
> > +               /* entry was invalidated */
> > +               spin_unlock(&tree->lock);
> > +               return 0;
> > +       }
> > +
> > +       zswap_evicted_pages++;
> > +
> > +       zswap_rb_erase(&tree->rbroot, entry);
> > +       zswap_entry_put(tree, entry);
> > +
> > +       spin_unlock(&tree->lock);
> > +
> > +       return 0;
> > +}
> > +
> > +/*********************************
> >  * frontswap hooks
> >  **********************************/
> >  /* attempts to compress and store an single page */
> > @@ -744,7 +792,7 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
> >         spin_lock(&tree->lock);
> >         entry = zswap_entry_find_get(&tree->rbroot, offset);
> >         if (!entry) {
> > -               /* entry was written back */
> > +               /* entry was written back or evicted */
> >                 spin_unlock(&tree->lock);
> >                 return -1;
> >         }
> > @@ -778,7 +826,7 @@ static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t offset)
> >         spin_lock(&tree->lock);
> >         entry = zswap_rb_search(&tree->rbroot, offset);
> >         if (!entry) {
> > -               /* entry was written back */
> > +               /* entry was written back or evicted */
> >                 spin_unlock(&tree->lock);
> >                 return;
> >         }
> > @@ -813,18 +861,26 @@ static void zswap_frontswap_invalidate_area(unsigned type)
> >         zswap_trees[type] = NULL;
> >  }
> >
> > -static struct zbud_ops zswap_zbud_ops = {
> > +static struct zbud_ops zswap_zbud_writeback_ops = {
> >         .evict = zswap_writeback_entry
> >  };
> > +static struct zbud_ops zswap_zbud_writethrough_ops = {
> > +       .evict = zswap_evict_entry
> > +};
> >
> >  static void zswap_frontswap_init(unsigned type)
> >  {
> >         struct zswap_tree *tree;
> > +       struct zbud_ops *ops;
> >
> >         tree = kzalloc(sizeof(struct zswap_tree), GFP_KERNEL);
> >         if (!tree)
> >                 goto err;
> > -       tree->pool = zbud_create_pool(GFP_KERNEL, &zswap_zbud_ops);
> > +       if (zswap_writethrough)
> > +               ops = &zswap_zbud_writethrough_ops;
> > +       else
> > +               ops = &zswap_zbud_writeback_ops;
> > +       tree->pool = zbud_create_pool(GFP_KERNEL, ops);
> >         if (!tree->pool)
> >                 goto freetree;
> >         tree->rbroot = RB_ROOT;
> > @@ -875,6 +931,8 @@ static int __init zswap_debugfs_init(void)
> >                         zswap_debugfs_root, &zswap_reject_compress_poor);
> >         debugfs_create_u64("written_back_pages", S_IRUGO,
> >                         zswap_debugfs_root, &zswap_written_back_pages);
> > +       debugfs_create_u64("evicted_pages", S_IRUGO,
> > +                       zswap_debugfs_root, &zswap_evicted_pages);
> >         debugfs_create_u64("duplicate_entry", S_IRUGO,
> >                         zswap_debugfs_root, &zswap_duplicate_entry);
> >         debugfs_create_u64("pool_pages", S_IRUGO,
> > @@ -919,6 +977,8 @@ static int __init init_zswap(void)
> >                 pr_err("per-cpu initialization failed\n");
> >                 goto pcpufail;
> >         }
> > +       if (zswap_writethrough)
> > +               frontswap_writethrough(true);
> >         frontswap_register_ops(&zswap_frontswap_ops);
> >         if (zswap_debugfs_init())
> >                 pr_warn("debugfs initialization failed\n");
> > --
> > 1.8.3.1
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
