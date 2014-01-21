Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id D22066B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 00:03:34 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id q10so5667531pdj.10
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 21:03:34 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id i3si3642537pbe.349.2014.01.20.21.03.31
        for <linux-mm@kvack.org>;
        Mon, 20 Jan 2014 21:03:33 -0800 (PST)
Date: Tue, 21 Jan 2014 14:04:39 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm/zswap: Check all pool pages instead of one pool
 pages
Message-ID: <20140121050439.GA16664@bbox>
References: <CAFLCcBqyhL=wfC4uJmpp9MkGExBuPJC4EqY2RHRngnEn_1ytSA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFLCcBqyhL=wfC4uJmpp9MkGExBuPJC4EqY2RHRngnEn_1ytSA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cai Liu <liucai.lfn@gmail.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Bob Liu <bob.liu@oracle.com>, Cai Liu <cai.liu@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

Please check your MUA and don't break thread.

On Tue, Jan 21, 2014 at 11:07:42AM +0800, Cai Liu wrote:
> Thanks for your review.
> 
> 2014/1/21 Minchan Kim <minchan@kernel.org>:
> > Hello Cai,
> >
> > On Mon, Jan 20, 2014 at 03:50:18PM +0800, Cai Liu wrote:
> >> zswap can support multiple swapfiles. So we need to check
> >> all zbud pool pages in zswap.
> >>
> >> Version 2:
> >>   * add *total_zbud_pages* in zbud to record all the pages in pools
> >>   * move the updating of pool pages statistics to
> >>     alloc_zbud_page/free_zbud_page to hide the details
> >>
> >> Signed-off-by: Cai Liu <cai.liu@samsung.com>
> >> ---
> >>  include/linux/zbud.h |    2 +-
> >>  mm/zbud.c            |   44 ++++++++++++++++++++++++++++++++------------
> >>  mm/zswap.c           |    4 ++--
> >>  3 files changed, 35 insertions(+), 15 deletions(-)
> >>
> >> diff --git a/include/linux/zbud.h b/include/linux/zbud.h
> >> index 2571a5c..1dbc13e 100644
> >> --- a/include/linux/zbud.h
> >> +++ b/include/linux/zbud.h
> >> @@ -17,6 +17,6 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle);
> >>  int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries);
> >>  void *zbud_map(struct zbud_pool *pool, unsigned long handle);
> >>  void zbud_unmap(struct zbud_pool *pool, unsigned long handle);
> >> -u64 zbud_get_pool_size(struct zbud_pool *pool);
> >> +u64 zbud_get_pool_size(void);
> >>
> >>  #endif /* _ZBUD_H_ */
> >> diff --git a/mm/zbud.c b/mm/zbud.c
> >> index 9451361..711aaf4 100644
> >> --- a/mm/zbud.c
> >> +++ b/mm/zbud.c
> >> @@ -52,6 +52,13 @@
> >>  #include <linux/spinlock.h>
> >>  #include <linux/zbud.h>
> >>
> >> +/*********************************
> >> +* statistics
> >> +**********************************/
> >> +
> >> +/* zbud pages in all pools */
> >> +static u64 total_zbud_pages;
> >> +
> >>  /*****************
> >>   * Structures
> >>  *****************/
> >> @@ -142,10 +149,28 @@ static struct zbud_header *init_zbud_page(struct page *page)
> >>       return zhdr;
> >>  }
> >>
> >> +static struct page *alloc_zbud_page(struct zbud_pool *pool, gfp_t gfp)
> >> +{
> >> +     struct page *page;
> >> +
> >> +     page = alloc_page(gfp);
> >> +
> >> +     if (page) {
> >> +             pool->pages_nr++;
> >> +             total_zbud_pages++;
> >
> > Who protect race?
> 
> Yes, here the pool->pages_nr and also the total_zbud_pages are not protected.
> I will re-do it.
> 
> I will change *total_zbud_pages* to atomic type.

Wait, it doesn't make sense. Now, you assume zbud allocator would be used
for only zswap. It's true until now but we couldn't make sure it in future.
If other user start to use zbud allocator, total_zbud_pages would be pointless.

Another concern is that what's your scenario for above two swap?
How often we need to call zbud_get_pool_size?
In previous your patch, you reduced the number of call so IIRC,
we only called it in zswap_is_full and for debugfs.
Of course, it would need some lock or refcount to prevent destroy
of zswap_tree in parallel with zswap_frontswap_invalidate_area but
zswap_is_full doesn't need to be exact so RCU would be good fit.

Most important point is that now zswap doesn't consider multiple swap.
For example, Let's assume you uses two swap A and B with different priority
and A already has charged 19% long time ago and let's assume that A swap is
full now so VM start to use B so that B has charged 1% recently.
It menas zswap charged (19% + 1%)i is full by default.

Then, if VM want to swap out more pages into B, zbud_reclaim_page
would be evict one of pages in B's pool and it would be repeated
continuously. It's totally LRU reverse problem and swap thrashing in B
would happen.

Please say your usecase scenario and if it's really problem,
we need more surgery.

Thanks.

> For *pool->pages_nr*, one way is to use pool->lock to protect. But I
> think it is too heavy.
> So does it ok to change pages_nr to atomic type too?
> 
> 
> >
> >> +     }
> >> +
> >> +     return page;
> >> +}
> >> +
> >> +
> >>  /* Resets the struct page fields and frees the page */
> >> -static void free_zbud_page(struct zbud_header *zhdr)
> >> +static void free_zbud_page(struct zbud_pool *pool, struct zbud_header *zhdr)
> >>  {
> >>       __free_page(virt_to_page(zhdr));
> >> +
> >> +     pool->pages_nr--;
> >> +     total_zbud_pages--;
> >>  }
> >>
> >>  /*
> >> @@ -279,11 +304,10 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
> >>
> >>       /* Couldn't find unbuddied zbud page, create new one */
> >>       spin_unlock(&pool->lock);
> >> -     page = alloc_page(gfp);
> >> +     page = alloc_zbud_page(pool, gfp);
> >>       if (!page)
> >>               return -ENOMEM;
> >>       spin_lock(&pool->lock);
> >> -     pool->pages_nr++;
> >>       zhdr = init_zbud_page(page);
> >>       bud = FIRST;
> >>
> >> @@ -349,8 +373,7 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
> >>       if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
> >>               /* zbud page is empty, free */
> >>               list_del(&zhdr->lru);
> >> -             free_zbud_page(zhdr);
> >> -             pool->pages_nr--;
> >> +             free_zbud_page(pool, zhdr);
> >>       } else {
> >>               /* Add to unbuddied list */
> >>               freechunks = num_free_chunks(zhdr);
> >> @@ -447,8 +470,7 @@ next:
> >>                        * Both buddies are now free, free the zbud page and
> >>                        * return success.
> >>                        */
> >> -                     free_zbud_page(zhdr);
> >> -                     pool->pages_nr--;
> >> +                     free_zbud_page(pool, zhdr);
> >>                       spin_unlock(&pool->lock);
> >>                       return 0;
> >>               } else if (zhdr->first_chunks == 0 ||
> >> @@ -496,14 +518,12 @@ void zbud_unmap(struct zbud_pool *pool, unsigned long handle)
> >>
> >>  /**
> >>   * zbud_get_pool_size() - gets the zbud pool size in pages
> >> - * @pool:    pool whose size is being queried
> >>   *
> >> - * Returns: size in pages of the given pool.  The pool lock need not be
> >> - * taken to access pages_nr.
> >> + * Returns: size in pages of all the zbud pools.
> >>   */
> >> -u64 zbud_get_pool_size(struct zbud_pool *pool)
> >> +u64 zbud_get_pool_size(void)
> >>  {
> >> -     return pool->pages_nr;
> >> +     return total_zbud_pages;
> >>  }
> >>
> >>  static int __init init_zbud(void)
> >> diff --git a/mm/zswap.c b/mm/zswap.c
> >> index 5a63f78..ef44d9d 100644
> >> --- a/mm/zswap.c
> >> +++ b/mm/zswap.c
> >> @@ -291,7 +291,7 @@ static void zswap_free_entry(struct zswap_tree *tree,
> >>       zbud_free(tree->pool, entry->handle);
> >>       zswap_entry_cache_free(entry);
> >>       atomic_dec(&zswap_stored_pages);
> >> -     zswap_pool_pages = zbud_get_pool_size(tree->pool);
> >> +     zswap_pool_pages = zbud_get_pool_size();
> >>  }
> >>
> >>  /* caller must hold the tree lock */
> >> @@ -716,7 +716,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
> >>
> >>       /* update stats */
> >>       atomic_inc(&zswap_stored_pages);
> >> -     zswap_pool_pages = zbud_get_pool_size(tree->pool);
> >> +     zswap_pool_pages = zbud_get_pool_size();
> >>
> >>       return 0;
> >>
> >> --
> >> 1.7.10.4
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
