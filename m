Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3A9856B0031
	for <linux-mm@kvack.org>; Sun, 26 Jan 2014 21:20:01 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rp16so5285468pbb.20
        for <linux-mm@kvack.org>; Sun, 26 Jan 2014 18:20:00 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id a6si9372294pao.157.2014.01.26.18.19.58
        for <linux-mm@kvack.org>;
        Sun, 26 Jan 2014 18:19:59 -0800 (PST)
Date: Mon, 27 Jan 2014 11:21:29 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm/zswap: Check all pool pages instead of one pool
 pages
Message-ID: <20140127022128.GD14369@bbox>
References: <CAFLCcBr1_=i3Pdh8_MToS0Dc1UGruviMiydF5c-vX2Bv8AfeAw@mail.gmail.com>
 <20140121081820.GA31230@bbox>
 <CAFLCcBo90jDa562OxwACFVBmSAwVM06oGnx7ooq7YKAvNdqU=w@mail.gmail.com>
 <20140122080238.GD31230@bbox>
 <CAFLCcBqPeeJEqyO978VQmiP3coAHBhoC86jQ0rwFwD-dkGyjkw@mail.gmail.com>
 <CALZtONDZ-jPTOLfnoXsZ8mNPFXU_j8v+QQq6+DCAvRP3+3x_=w@mail.gmail.com>
 <CAFLCcBpgfeGO4t1kxxd3-a7AgoR_bho_8v=SXTvEzBf-opYvVQ@mail.gmail.com>
 <20140123030242.GA28732@bbox>
 <CAFLCcBqJ6UT3BptgZcF6UQufHhsgPCRKEmTXF3D4tZeJTbF15Q@mail.gmail.com>
 <CAL1ERfPapN67+7Voi3U2uFiJcC_P=LuBF6rR4LD3i6RtrALdew@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAL1ERfPapN67+7Voi3U2uFiJcC_P=LuBF6rR4LD3i6RtrALdew@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang.kh@gmail.com>
Cc: Cai Liu <liucai.lfn@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Bob Liu <bob.liu@oracle.com>, Cai Liu <cai.liu@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

Hello Weigie,

On Fri, Jan 24, 2014 at 10:20:36PM +0800, Weijie Yang wrote:
> On Thu, Jan 23, 2014 at 2:30 PM, Cai Liu <liucai.lfn@gmail.com> wrote:
> > Hello Minchan
> >
> > 2014/1/23 Minchan Kim <minchan@kernel.org>:
> >> Hello Cai,
> >>
> >> On Thu, Jan 23, 2014 at 09:38:41AM +0800, Cai Liu wrote:
> >>> Hello Dan
> >>>
> >>> 2014/1/22 Dan Streetman <ddstreet@ieee.org>:
> >>> > On Wed, Jan 22, 2014 at 7:16 AM, Cai Liu <liucai.lfn@gmail.com> wrote:
> >>> >> Hello Minchan
> >>> >>
> >>> >>
> >>> >> 2014/1/22 Minchan Kim <minchan@kernel.org>
> >>> >>>
> >>> >>> Hello Cai,
> >>> >>>
> >>> >>> On Tue, Jan 21, 2014 at 09:52:25PM +0800, Cai Liu wrote:
> >>> >>> > Hello Minchan
> >>> >>> >
> >>> >>> > 2014/1/21 Minchan Kim <minchan@kernel.org>:
> >>> >>> > > Hello,
> >>> >>> > >
> >>> >>> > > On Tue, Jan 21, 2014 at 02:35:07PM +0800, Cai Liu wrote:
> >>> >>> > >> 2014/1/21 Minchan Kim <minchan@kernel.org>:
> >>> >>> > >> > Please check your MUA and don't break thread.
> >>> >>> > >> >
> >>> >>> > >> > On Tue, Jan 21, 2014 at 11:07:42AM +0800, Cai Liu wrote:
> >>> >>> > >> >> Thanks for your review.
> >>> >>> > >> >>
> >>> >>> > >> >> 2014/1/21 Minchan Kim <minchan@kernel.org>:
> >>> >>> > >> >> > Hello Cai,
> >>> >>> > >> >> >
> >>> >>> > >> >> > On Mon, Jan 20, 2014 at 03:50:18PM +0800, Cai Liu wrote:
> >>> >>> > >> >> >> zswap can support multiple swapfiles. So we need to check
> >>> >>> > >> >> >> all zbud pool pages in zswap.
> >>> >>> > >> >> >>
> >>> >>> > >> >> >> Version 2:
> >>> >>> > >> >> >>   * add *total_zbud_pages* in zbud to record all the pages in pools
> >>> >>> > >> >> >>   * move the updating of pool pages statistics to
> >>> >>> > >> >> >>     alloc_zbud_page/free_zbud_page to hide the details
> >>> >>> > >> >> >>
> >>> >>> > >> >> >> Signed-off-by: Cai Liu <cai.liu@samsung.com>
> >>> >>> > >> >> >> ---
> >>> >>> > >> >> >>  include/linux/zbud.h |    2 +-
> >>> >>> > >> >> >>  mm/zbud.c            |   44 ++++++++++++++++++++++++++++++++------------
> >>> >>> > >> >> >>  mm/zswap.c           |    4 ++--
> >>> >>> > >> >> >>  3 files changed, 35 insertions(+), 15 deletions(-)
> >>> >>> > >> >> >>
> >>> >>> > >> >> >> diff --git a/include/linux/zbud.h b/include/linux/zbud.h
> >>> >>> > >> >> >> index 2571a5c..1dbc13e 100644
> >>> >>> > >> >> >> --- a/include/linux/zbud.h
> >>> >>> > >> >> >> +++ b/include/linux/zbud.h
> >>> >>> > >> >> >> @@ -17,6 +17,6 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle);
> >>> >>> > >> >> >>  int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries);
> >>> >>> > >> >> >>  void *zbud_map(struct zbud_pool *pool, unsigned long handle);
> >>> >>> > >> >> >>  void zbud_unmap(struct zbud_pool *pool, unsigned long handle);
> >>> >>> > >> >> >> -u64 zbud_get_pool_size(struct zbud_pool *pool);
> >>> >>> > >> >> >> +u64 zbud_get_pool_size(void);
> >>> >>> > >> >> >>
> >>> >>> > >> >> >>  #endif /* _ZBUD_H_ */
> >>> >>> > >> >> >> diff --git a/mm/zbud.c b/mm/zbud.c
> >>> >>> > >> >> >> index 9451361..711aaf4 100644
> >>> >>> > >> >> >> --- a/mm/zbud.c
> >>> >>> > >> >> >> +++ b/mm/zbud.c
> >>> >>> > >> >> >> @@ -52,6 +52,13 @@
> >>> >>> > >> >> >>  #include <linux/spinlock.h>
> >>> >>> > >> >> >>  #include <linux/zbud.h>
> >>> >>> > >> >> >>
> >>> >>> > >> >> >> +/*********************************
> >>> >>> > >> >> >> +* statistics
> >>> >>> > >> >> >> +**********************************/
> >>> >>> > >> >> >> +
> >>> >>> > >> >> >> +/* zbud pages in all pools */
> >>> >>> > >> >> >> +static u64 total_zbud_pages;
> >>> >>> > >> >> >> +
> >>> >>> > >> >> >>  /*****************
> >>> >>> > >> >> >>   * Structures
> >>> >>> > >> >> >>  *****************/
> >>> >>> > >> >> >> @@ -142,10 +149,28 @@ static struct zbud_header *init_zbud_page(struct page *page)
> >>> >>> > >> >> >>       return zhdr;
> >>> >>> > >> >> >>  }
> >>> >>> > >> >> >>
> >>> >>> > >> >> >> +static struct page *alloc_zbud_page(struct zbud_pool *pool, gfp_t gfp)
> >>> >>> > >> >> >> +{
> >>> >>> > >> >> >> +     struct page *page;
> >>> >>> > >> >> >> +
> >>> >>> > >> >> >> +     page = alloc_page(gfp);
> >>> >>> > >> >> >> +
> >>> >>> > >> >> >> +     if (page) {
> >>> >>> > >> >> >> +             pool->pages_nr++;
> >>> >>> > >> >> >> +             total_zbud_pages++;
> >>> >>> > >> >> >
> >>> >>> > >> >> > Who protect race?
> >>> >>> > >> >>
> >>> >>> > >> >> Yes, here the pool->pages_nr and also the total_zbud_pages are not protected.
> >>> >>> > >> >> I will re-do it.
> >>> >>> > >> >>
> >>> >>> > >> >> I will change *total_zbud_pages* to atomic type.
> >>> >>> > >> >
> >>> >>> > >> > Wait, it doesn't make sense. Now, you assume zbud allocator would be used
> >>> >>> > >> > for only zswap. It's true until now but we couldn't make sure it in future.
> >>> >>> > >> > If other user start to use zbud allocator, total_zbud_pages would be pointless.
> >>> >>> > >>
> >>> >>> > >> Yes, you are right.  ZBUD is a common module. So in this patch calculate the
> >>> >>> > >> zswap pool size in zbud is not suitable.
> >>> >>> > >>
> >>> >>> > >> >
> >>> >>> > >> > Another concern is that what's your scenario for above two swap?
> >>> >>> > >> > How often we need to call zbud_get_pool_size?
> >>> >>> > >> > In previous your patch, you reduced the number of call so IIRC,
> >>> >>> > >> > we only called it in zswap_is_full and for debugfs.
> >>> >>> > >>
> >>> >>> > >> zbud_get_pool_size() is called frequently when adding/freeing zswap
> >>> >>> > >> entry happen in zswap . This is why in this patch I added a counter in zbud,
> >>> >>> > >> and then in zswap the iteration of zswap_list to calculate the pool size will
> >>> >>> > >> not be needed.
> >>> >>> > >
> >>> >>> > > We can remove updating zswap_pool_pages in zswap_frontswap_store and
> >>> >>> > > zswap_free_entry as I said. So zswap_is_full is only hot spot.
> >>> >>> > > Do you think it's still big overhead? Why? Maybe locking to prevent
> >>> >>> > > destroying? Then, we can use RCU to minimize the overhead as I mentioned.
> >>> >>> >
> >>> >>> > I get your point. Yes, In my previous patch, zswap_is_full() was the
> >>> >>> > only path to call
> >>> >>> > zbud_get_pool_size(). And your suggestion on patch v1 to remove the unnecessary
> >>> >>> > iteration will reduce the overhead further.
> >>> >>> >
> >>> >>> > So adding the calculating of all the pool size in zswap.c is better.
> >>> >>> >
> >>> >>> > >>
> >>> >>> > >> > Of course, it would need some lock or refcount to prevent destroy
> >>> >>> > >> > of zswap_tree in parallel with zswap_frontswap_invalidate_area but
> >>> >>> > >> > zswap_is_full doesn't need to be exact so RCU would be good fit.
> >>> >>> > >> >
> >>> >>> > >> > Most important point is that now zswap doesn't consider multiple swap.
> >>> >>> > >> > For example, Let's assume you uses two swap A and B with different priority
> >>> >>> > >> > and A already has charged 19% long time ago and let's assume that A swap is
> >>> >>> > >> > full now so VM start to use B so that B has charged 1% recently.
> >>> >>> > >> > It menas zswap charged (19% + 1%)i is full by default.
> >>> >>> > >> >
> >>> >>> > >> > Then, if VM want to swap out more pages into B, zbud_reclaim_page
> >>> >>> > >> > would be evict one of pages in B's pool and it would be repeated
> >>> >>> > >> > continuously. It's totally LRU reverse problem and swap thrashing in B
> >>> >>> > >> > would happen.
> >>> >>> > >> >
> >>> >>> > >>
> >>> >>> > >> The scenario is below:
> >>> >>> > >> There are 2 swap A, B in system. If pool size of A reach 19% of ram
> >>> >>> > >> size and swap A
> >>> >>> > >> is also full. Then swap B will be used. Pool size of B will be
> >>> >>> > >> increased until it hit
> >>> >>> > >> the 20% of the ram size. By now zswap pool size is about 39% of ram size.
> >>> >>> > >> If there are more than 2 swap file/device,  zswap pool will expand out
> >>> >>> > >> of control
> >>> >>> > >> and there may be no swapout happened.
> >>> >>> > >
> >>> >>> > > I know.
> >>> >>> > >
> >>> >>> > >>
> >>> >>> > >> I think the original intention of zswap designer is to keep the total
> >>> >>> > >> zswap pools size below
> >>> >>> > >> 20% of RAM size.
> >>> >>> > >
> >>> >>> > > My point is your patch still doesn't solve the example I mentioned.
> >>> >>> >
> >>> >>> > Hmm. My patch only make sure all the zswap pools use maximum 20% of
> >>> >>> > RAM size. It is a new problem in your example. The zbud_reclaim_page would
> >>> >>> > not swap out the oldest zbud page when multiple swaps are used.
> >>> >>> >
> >>> >>> > Maybe the new problem can be resolved in another patch.
> >>> >>>
> >>> >>> It means current zswap has a problem in multiple swap but you want
> >>> >>> to fix a problem which happens only when it is used for multiple swap.
> >>> >>> So, I'm not sure we want a fix in this phase before discussing more
> >>> >>> fundamental thing.
> >>> >>>
> >>> >>
> >>> >> Yes, The bug which I want to fix only happens when multiple swap are used.
> >>> >>
> >>> >>> That's why I want to know why you want to use multiple swap with zswap
> >>> >>> but you are never saying it to us. :(
> >>> >>>
> >>> >>
> >>> >> If user uses more than one swap device/file, then this is an issue.
> >>> >> Zswap pool is created when a swap device/file is swapped on happens.
> >>> >> So there will be more than one zswap pool when user uses 2 or even
> >>> >> more swap devices/files.
> >>> >>
> >>> >> I am not sure whether multiple swap are popular. But if multiple swap
> >>> >> are swapped
> >>> >> on, then multiple zswap pool will be created. And the size of these pools may
> >>> >> out of control.
> >>> >
> >>> > Personally I don't think using multiple swap partitions/files has to
> >>> > be popular to need to solve this, it only needs to be possible, which
> >>> > it is.
> >>> >
> >>> > Why not just leave zbud unchanged, and sum up the total size using a
> >>> > list of active zswap_trees as Minchan suggested for the v1 patch?  The
> >>>
> >>> Yes. This is what I want to do in the v3 patch after this bug is considered need
> >>> to be fixed.
> >>
> >> In my position, I'd like to fix zswap and multiple swap problem firstly
> >> and like the Weijie's suggestion.
> >>
> >> So, how about this?
> >> I didn't look at code in detail and want to show the concept.
> >
> > I read the RFC patch. I think it's perfect.
> >
> >> That's why I added RFC tag.
> >>
> >> From 67c64746e977a091ee30ca37bbc034990adf5ca5 Mon Sep 17 00:00:00 2001
> >> From: Minchan Kim <minchan@kernel.org>
> >> Date: Thu, 23 Jan 2014 11:41:44 +0900
> >> Subject: [RFC] zswap: support multiple swap
> >>
> >> Cai Liu reporeted that now zbud pool pages counting has a problem
> >> when multiple swap is used because it just counts one of swap
> >> among mutliple swap intead of all of swap so zswap cannot control
> >> writeback properly. The result is unnecessary writeback or
> >> no writeback when we should really writeback. IOW, it made zswap
> >> crazy.
> >>
> >> Another problem in zswap is following as.
> >> For example, let's assume we use two swap A and B with different
> >> priority and A already has charged 19% long time ago and let's assume
> >> that A swap is full now so VM start to use B so that B has charged 1%
> >> recently. It menas zswap charged (19% + 1%) is full by default.
> >> Then, if VM want to swap out more pages into B, zbud_reclaim_page
> >> would be evict one of pages in B's pool and it would be repeated
> >> continuously. It's totally LRU reverse problem and swap thrashing
> >> in B would happen.
> >>
> >> This patch makes zswap consider mutliple swap by creating *a* zbud
> >> pool which will be shared by multiple swap so all of zswap pages
> >> in multiple swap keep order by LRU so it can prevent above two
> >> problems.
> >>
> >> Reported-by: Cai Liu <cai.liu@samsung.com>
> >> Suggested-by: Weijie Yang <weijie.yang.kh@gmail.com>
> >> Signed-off-by: Minchan Kim <minchan@kernel.org>
> >> ---
> >>  mm/zswap.c | 56 +++++++++++++++++++++++++++++---------------------------
> >>  1 file changed, 29 insertions(+), 27 deletions(-)
> 
> Hi, Minchan
> 
> I reviewed this patch, it is good to me. Just have a little nitpick, see below.
> 
> Regards
> 
> >> diff --git a/mm/zswap.c b/mm/zswap.c
> >> index 5a63f78a5601..96039e86db79 100644
> >> --- a/mm/zswap.c
> >> +++ b/mm/zswap.c
> >> @@ -89,6 +89,8 @@ static unsigned int zswap_max_pool_percent = 20;
> >>  module_param_named(max_pool_percent,
> >>                         zswap_max_pool_percent, uint, 0644);
> >>
> >> +static struct zbud_pool *mem_pool;
> >> +
> 
> nitpick1: I'd like to put the same logical code together.
>    such as put this mem_pool definition with zswap_trees and zswap_entry_cache
>    Just my oddity, of course you can ignore it.

I'd like to stress "the mem_pool is shared by several zswap_tress" rather than
adding it in zswp_tree so

static struct zbud_pool *shared_mem_pool;


> 
> >>  /*********************************
> >>  * compression functions
> >>  **********************************/
> >> @@ -189,7 +191,6 @@ struct zswap_header {
> >>  struct zswap_tree {
> >>         struct rb_root rbroot;
> >>         spinlock_t lock;
> >> -       struct zbud_pool *pool;
> >>  };
> >>
> >>  static struct zswap_tree *zswap_trees[MAX_SWAPFILES];
> >> @@ -288,10 +289,10 @@ static void zswap_rb_erase(struct rb_root *root, struct zswap_entry *entry)
> >>  static void zswap_free_entry(struct zswap_tree *tree,
> >>                         struct zswap_entry *entry)
> 
> nitpick2: How about remove the tree parameter in zswap_free_entry?

Nice catch! I will fix it and send the patch when merge window is closed.
Thanks for the review, Weijie!

> 
> >>  {
> >> -       zbud_free(tree->pool, entry->handle);
> >> +       zbud_free(mem_pool, entry->handle);
> >>         zswap_entry_cache_free(entry);
> >>         atomic_dec(&zswap_stored_pages);
> >> -       zswap_pool_pages = zbud_get_pool_size(tree->pool);
> >> +       zswap_pool_pages = zbud_get_pool_size(mem_pool);
> >>  }
> >>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
