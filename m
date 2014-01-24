Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f43.google.com (mail-bk0-f43.google.com [209.85.214.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8EAF96B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 09:20:39 -0500 (EST)
Received: by mail-bk0-f43.google.com with SMTP id mx11so1169651bkb.2
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 06:20:39 -0800 (PST)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id t6si3232051bkp.120.2014.01.24.06.20.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 06:20:38 -0800 (PST)
Received: by mail-ie0-f181.google.com with SMTP id tq11so2870868ieb.12
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 06:20:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAFLCcBqJ6UT3BptgZcF6UQufHhsgPCRKEmTXF3D4tZeJTbF15Q@mail.gmail.com>
References: <CAFLCcBqyhL=wfC4uJmpp9MkGExBuPJC4EqY2RHRngnEn_1ytSA@mail.gmail.com>
	<20140121050439.GA16664@bbox>
	<CAFLCcBr1_=i3Pdh8_MToS0Dc1UGruviMiydF5c-vX2Bv8AfeAw@mail.gmail.com>
	<20140121081820.GA31230@bbox>
	<CAFLCcBo90jDa562OxwACFVBmSAwVM06oGnx7ooq7YKAvNdqU=w@mail.gmail.com>
	<20140122080238.GD31230@bbox>
	<CAFLCcBqPeeJEqyO978VQmiP3coAHBhoC86jQ0rwFwD-dkGyjkw@mail.gmail.com>
	<CALZtONDZ-jPTOLfnoXsZ8mNPFXU_j8v+QQq6+DCAvRP3+3x_=w@mail.gmail.com>
	<CAFLCcBpgfeGO4t1kxxd3-a7AgoR_bho_8v=SXTvEzBf-opYvVQ@mail.gmail.com>
	<20140123030242.GA28732@bbox>
	<CAFLCcBqJ6UT3BptgZcF6UQufHhsgPCRKEmTXF3D4tZeJTbF15Q@mail.gmail.com>
Date: Fri, 24 Jan 2014 22:20:36 +0800
Message-ID: <CAL1ERfPapN67+7Voi3U2uFiJcC_P=LuBF6rR4LD3i6RtrALdew@mail.gmail.com>
Subject: Re: [PATCH v2] mm/zswap: Check all pool pages instead of one pool pages
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cai Liu <liucai.lfn@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Bob Liu <bob.liu@oracle.com>, Cai Liu <cai.liu@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Thu, Jan 23, 2014 at 2:30 PM, Cai Liu <liucai.lfn@gmail.com> wrote:
> Hello Minchan
>
> 2014/1/23 Minchan Kim <minchan@kernel.org>:
>> Hello Cai,
>>
>> On Thu, Jan 23, 2014 at 09:38:41AM +0800, Cai Liu wrote:
>>> Hello Dan
>>>
>>> 2014/1/22 Dan Streetman <ddstreet@ieee.org>:
>>> > On Wed, Jan 22, 2014 at 7:16 AM, Cai Liu <liucai.lfn@gmail.com> wrote:
>>> >> Hello Minchan
>>> >>
>>> >>
>>> >> 2014/1/22 Minchan Kim <minchan@kernel.org>
>>> >>>
>>> >>> Hello Cai,
>>> >>>
>>> >>> On Tue, Jan 21, 2014 at 09:52:25PM +0800, Cai Liu wrote:
>>> >>> > Hello Minchan
>>> >>> >
>>> >>> > 2014/1/21 Minchan Kim <minchan@kernel.org>:
>>> >>> > > Hello,
>>> >>> > >
>>> >>> > > On Tue, Jan 21, 2014 at 02:35:07PM +0800, Cai Liu wrote:
>>> >>> > >> 2014/1/21 Minchan Kim <minchan@kernel.org>:
>>> >>> > >> > Please check your MUA and don't break thread.
>>> >>> > >> >
>>> >>> > >> > On Tue, Jan 21, 2014 at 11:07:42AM +0800, Cai Liu wrote:
>>> >>> > >> >> Thanks for your review.
>>> >>> > >> >>
>>> >>> > >> >> 2014/1/21 Minchan Kim <minchan@kernel.org>:
>>> >>> > >> >> > Hello Cai,
>>> >>> > >> >> >
>>> >>> > >> >> > On Mon, Jan 20, 2014 at 03:50:18PM +0800, Cai Liu wrote:
>>> >>> > >> >> >> zswap can support multiple swapfiles. So we need to check
>>> >>> > >> >> >> all zbud pool pages in zswap.
>>> >>> > >> >> >>
>>> >>> > >> >> >> Version 2:
>>> >>> > >> >> >>   * add *total_zbud_pages* in zbud to record all the pages in pools
>>> >>> > >> >> >>   * move the updating of pool pages statistics to
>>> >>> > >> >> >>     alloc_zbud_page/free_zbud_page to hide the details
>>> >>> > >> >> >>
>>> >>> > >> >> >> Signed-off-by: Cai Liu <cai.liu@samsung.com>
>>> >>> > >> >> >> ---
>>> >>> > >> >> >>  include/linux/zbud.h |    2 +-
>>> >>> > >> >> >>  mm/zbud.c            |   44 ++++++++++++++++++++++++++++++++------------
>>> >>> > >> >> >>  mm/zswap.c           |    4 ++--
>>> >>> > >> >> >>  3 files changed, 35 insertions(+), 15 deletions(-)
>>> >>> > >> >> >>
>>> >>> > >> >> >> diff --git a/include/linux/zbud.h b/include/linux/zbud.h
>>> >>> > >> >> >> index 2571a5c..1dbc13e 100644
>>> >>> > >> >> >> --- a/include/linux/zbud.h
>>> >>> > >> >> >> +++ b/include/linux/zbud.h
>>> >>> > >> >> >> @@ -17,6 +17,6 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle);
>>> >>> > >> >> >>  int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries);
>>> >>> > >> >> >>  void *zbud_map(struct zbud_pool *pool, unsigned long handle);
>>> >>> > >> >> >>  void zbud_unmap(struct zbud_pool *pool, unsigned long handle);
>>> >>> > >> >> >> -u64 zbud_get_pool_size(struct zbud_pool *pool);
>>> >>> > >> >> >> +u64 zbud_get_pool_size(void);
>>> >>> > >> >> >>
>>> >>> > >> >> >>  #endif /* _ZBUD_H_ */
>>> >>> > >> >> >> diff --git a/mm/zbud.c b/mm/zbud.c
>>> >>> > >> >> >> index 9451361..711aaf4 100644
>>> >>> > >> >> >> --- a/mm/zbud.c
>>> >>> > >> >> >> +++ b/mm/zbud.c
>>> >>> > >> >> >> @@ -52,6 +52,13 @@
>>> >>> > >> >> >>  #include <linux/spinlock.h>
>>> >>> > >> >> >>  #include <linux/zbud.h>
>>> >>> > >> >> >>
>>> >>> > >> >> >> +/*********************************
>>> >>> > >> >> >> +* statistics
>>> >>> > >> >> >> +**********************************/
>>> >>> > >> >> >> +
>>> >>> > >> >> >> +/* zbud pages in all pools */
>>> >>> > >> >> >> +static u64 total_zbud_pages;
>>> >>> > >> >> >> +
>>> >>> > >> >> >>  /*****************
>>> >>> > >> >> >>   * Structures
>>> >>> > >> >> >>  *****************/
>>> >>> > >> >> >> @@ -142,10 +149,28 @@ static struct zbud_header *init_zbud_page(struct page *page)
>>> >>> > >> >> >>       return zhdr;
>>> >>> > >> >> >>  }
>>> >>> > >> >> >>
>>> >>> > >> >> >> +static struct page *alloc_zbud_page(struct zbud_pool *pool, gfp_t gfp)
>>> >>> > >> >> >> +{
>>> >>> > >> >> >> +     struct page *page;
>>> >>> > >> >> >> +
>>> >>> > >> >> >> +     page = alloc_page(gfp);
>>> >>> > >> >> >> +
>>> >>> > >> >> >> +     if (page) {
>>> >>> > >> >> >> +             pool->pages_nr++;
>>> >>> > >> >> >> +             total_zbud_pages++;
>>> >>> > >> >> >
>>> >>> > >> >> > Who protect race?
>>> >>> > >> >>
>>> >>> > >> >> Yes, here the pool->pages_nr and also the total_zbud_pages are not protected.
>>> >>> > >> >> I will re-do it.
>>> >>> > >> >>
>>> >>> > >> >> I will change *total_zbud_pages* to atomic type.
>>> >>> > >> >
>>> >>> > >> > Wait, it doesn't make sense. Now, you assume zbud allocator would be used
>>> >>> > >> > for only zswap. It's true until now but we couldn't make sure it in future.
>>> >>> > >> > If other user start to use zbud allocator, total_zbud_pages would be pointless.
>>> >>> > >>
>>> >>> > >> Yes, you are right.  ZBUD is a common module. So in this patch calculate the
>>> >>> > >> zswap pool size in zbud is not suitable.
>>> >>> > >>
>>> >>> > >> >
>>> >>> > >> > Another concern is that what's your scenario for above two swap?
>>> >>> > >> > How often we need to call zbud_get_pool_size?
>>> >>> > >> > In previous your patch, you reduced the number of call so IIRC,
>>> >>> > >> > we only called it in zswap_is_full and for debugfs.
>>> >>> > >>
>>> >>> > >> zbud_get_pool_size() is called frequently when adding/freeing zswap
>>> >>> > >> entry happen in zswap . This is why in this patch I added a counter in zbud,
>>> >>> > >> and then in zswap the iteration of zswap_list to calculate the pool size will
>>> >>> > >> not be needed.
>>> >>> > >
>>> >>> > > We can remove updating zswap_pool_pages in zswap_frontswap_store and
>>> >>> > > zswap_free_entry as I said. So zswap_is_full is only hot spot.
>>> >>> > > Do you think it's still big overhead? Why? Maybe locking to prevent
>>> >>> > > destroying? Then, we can use RCU to minimize the overhead as I mentioned.
>>> >>> >
>>> >>> > I get your point. Yes, In my previous patch, zswap_is_full() was the
>>> >>> > only path to call
>>> >>> > zbud_get_pool_size(). And your suggestion on patch v1 to remove the unnecessary
>>> >>> > iteration will reduce the overhead further.
>>> >>> >
>>> >>> > So adding the calculating of all the pool size in zswap.c is better.
>>> >>> >
>>> >>> > >>
>>> >>> > >> > Of course, it would need some lock or refcount to prevent destroy
>>> >>> > >> > of zswap_tree in parallel with zswap_frontswap_invalidate_area but
>>> >>> > >> > zswap_is_full doesn't need to be exact so RCU would be good fit.
>>> >>> > >> >
>>> >>> > >> > Most important point is that now zswap doesn't consider multiple swap.
>>> >>> > >> > For example, Let's assume you uses two swap A and B with different priority
>>> >>> > >> > and A already has charged 19% long time ago and let's assume that A swap is
>>> >>> > >> > full now so VM start to use B so that B has charged 1% recently.
>>> >>> > >> > It menas zswap charged (19% + 1%)i is full by default.
>>> >>> > >> >
>>> >>> > >> > Then, if VM want to swap out more pages into B, zbud_reclaim_page
>>> >>> > >> > would be evict one of pages in B's pool and it would be repeated
>>> >>> > >> > continuously. It's totally LRU reverse problem and swap thrashing in B
>>> >>> > >> > would happen.
>>> >>> > >> >
>>> >>> > >>
>>> >>> > >> The scenario is below:
>>> >>> > >> There are 2 swap A, B in system. If pool size of A reach 19% of ram
>>> >>> > >> size and swap A
>>> >>> > >> is also full. Then swap B will be used. Pool size of B will be
>>> >>> > >> increased until it hit
>>> >>> > >> the 20% of the ram size. By now zswap pool size is about 39% of ram size.
>>> >>> > >> If there are more than 2 swap file/device,  zswap pool will expand out
>>> >>> > >> of control
>>> >>> > >> and there may be no swapout happened.
>>> >>> > >
>>> >>> > > I know.
>>> >>> > >
>>> >>> > >>
>>> >>> > >> I think the original intention of zswap designer is to keep the total
>>> >>> > >> zswap pools size below
>>> >>> > >> 20% of RAM size.
>>> >>> > >
>>> >>> > > My point is your patch still doesn't solve the example I mentioned.
>>> >>> >
>>> >>> > Hmm. My patch only make sure all the zswap pools use maximum 20% of
>>> >>> > RAM size. It is a new problem in your example. The zbud_reclaim_page would
>>> >>> > not swap out the oldest zbud page when multiple swaps are used.
>>> >>> >
>>> >>> > Maybe the new problem can be resolved in another patch.
>>> >>>
>>> >>> It means current zswap has a problem in multiple swap but you want
>>> >>> to fix a problem which happens only when it is used for multiple swap.
>>> >>> So, I'm not sure we want a fix in this phase before discussing more
>>> >>> fundamental thing.
>>> >>>
>>> >>
>>> >> Yes, The bug which I want to fix only happens when multiple swap are used.
>>> >>
>>> >>> That's why I want to know why you want to use multiple swap with zswap
>>> >>> but you are never saying it to us. :(
>>> >>>
>>> >>
>>> >> If user uses more than one swap device/file, then this is an issue.
>>> >> Zswap pool is created when a swap device/file is swapped on happens.
>>> >> So there will be more than one zswap pool when user uses 2 or even
>>> >> more swap devices/files.
>>> >>
>>> >> I am not sure whether multiple swap are popular. But if multiple swap
>>> >> are swapped
>>> >> on, then multiple zswap pool will be created. And the size of these pools may
>>> >> out of control.
>>> >
>>> > Personally I don't think using multiple swap partitions/files has to
>>> > be popular to need to solve this, it only needs to be possible, which
>>> > it is.
>>> >
>>> > Why not just leave zbud unchanged, and sum up the total size using a
>>> > list of active zswap_trees as Minchan suggested for the v1 patch?  The
>>>
>>> Yes. This is what I want to do in the v3 patch after this bug is considered need
>>> to be fixed.
>>
>> In my position, I'd like to fix zswap and multiple swap problem firstly
>> and like the Weijie's suggestion.
>>
>> So, how about this?
>> I didn't look at code in detail and want to show the concept.
>
> I read the RFC patch. I think it's perfect.
>
>> That's why I added RFC tag.
>>
>> From 67c64746e977a091ee30ca37bbc034990adf5ca5 Mon Sep 17 00:00:00 2001
>> From: Minchan Kim <minchan@kernel.org>
>> Date: Thu, 23 Jan 2014 11:41:44 +0900
>> Subject: [RFC] zswap: support multiple swap
>>
>> Cai Liu reporeted that now zbud pool pages counting has a problem
>> when multiple swap is used because it just counts one of swap
>> among mutliple swap intead of all of swap so zswap cannot control
>> writeback properly. The result is unnecessary writeback or
>> no writeback when we should really writeback. IOW, it made zswap
>> crazy.
>>
>> Another problem in zswap is following as.
>> For example, let's assume we use two swap A and B with different
>> priority and A already has charged 19% long time ago and let's assume
>> that A swap is full now so VM start to use B so that B has charged 1%
>> recently. It menas zswap charged (19% + 1%) is full by default.
>> Then, if VM want to swap out more pages into B, zbud_reclaim_page
>> would be evict one of pages in B's pool and it would be repeated
>> continuously. It's totally LRU reverse problem and swap thrashing
>> in B would happen.
>>
>> This patch makes zswap consider mutliple swap by creating *a* zbud
>> pool which will be shared by multiple swap so all of zswap pages
>> in multiple swap keep order by LRU so it can prevent above two
>> problems.
>>
>> Reported-by: Cai Liu <cai.liu@samsung.com>
>> Suggested-by: Weijie Yang <weijie.yang.kh@gmail.com>
>> Signed-off-by: Minchan Kim <minchan@kernel.org>
>> ---
>>  mm/zswap.c | 56 +++++++++++++++++++++++++++++---------------------------
>>  1 file changed, 29 insertions(+), 27 deletions(-)

Hi, Minchan

I reviewed this patch, it is good to me. Just have a little nitpick, see below.

Regards

>> diff --git a/mm/zswap.c b/mm/zswap.c
>> index 5a63f78a5601..96039e86db79 100644
>> --- a/mm/zswap.c
>> +++ b/mm/zswap.c
>> @@ -89,6 +89,8 @@ static unsigned int zswap_max_pool_percent = 20;
>>  module_param_named(max_pool_percent,
>>                         zswap_max_pool_percent, uint, 0644);
>>
>> +static struct zbud_pool *mem_pool;
>> +

nitpick1: I'd like to put the same logical code together.
   such as put this mem_pool definition with zswap_trees and zswap_entry_cache
   Just my oddity, of course you can ignore it.

>>  /*********************************
>>  * compression functions
>>  **********************************/
>> @@ -189,7 +191,6 @@ struct zswap_header {
>>  struct zswap_tree {
>>         struct rb_root rbroot;
>>         spinlock_t lock;
>> -       struct zbud_pool *pool;
>>  };
>>
>>  static struct zswap_tree *zswap_trees[MAX_SWAPFILES];
>> @@ -288,10 +289,10 @@ static void zswap_rb_erase(struct rb_root *root, struct zswap_entry *entry)
>>  static void zswap_free_entry(struct zswap_tree *tree,
>>                         struct zswap_entry *entry)

nitpick2: How about remove the tree parameter in zswap_free_entry?

>>  {
>> -       zbud_free(tree->pool, entry->handle);
>> +       zbud_free(mem_pool, entry->handle);
>>         zswap_entry_cache_free(entry);
>>         atomic_dec(&zswap_stored_pages);
>> -       zswap_pool_pages = zbud_get_pool_size(tree->pool);
>> +       zswap_pool_pages = zbud_get_pool_size(mem_pool);
>>  }
>>
>>  /* caller must hold the tree lock */
>> @@ -545,7 +546,7 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
>>         zbud_unmap(pool, handle);
>>         tree = zswap_trees[swp_type(swpentry)];
>>         offset = swp_offset(swpentry);
>> -       BUG_ON(pool != tree->pool);
>> +       BUG_ON(pool != mem_pool);
>>
>>         /* find and ref zswap entry */
>>         spin_lock(&tree->lock);
>> @@ -573,13 +574,13 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
>>         case ZSWAP_SWAPCACHE_NEW: /* page is locked */
>>                 /* decompress */
>>                 dlen = PAGE_SIZE;
>> -               src = (u8 *)zbud_map(tree->pool, entry->handle) +
>> +               src = (u8 *)zbud_map(mem_pool, entry->handle) +
>>                         sizeof(struct zswap_header);
>>                 dst = kmap_atomic(page);
>>                 ret = zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src,
>>                                 entry->length, dst, &dlen);
>>                 kunmap_atomic(dst);
>> -               zbud_unmap(tree->pool, entry->handle);
>> +               zbud_unmap(mem_pool, entry->handle);
>>                 BUG_ON(ret);
>>                 BUG_ON(dlen != PAGE_SIZE);
>>
>> @@ -652,7 +653,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>>         /* reclaim space if needed */
>>         if (zswap_is_full()) {
>>                 zswap_pool_limit_hit++;
>> -               if (zbud_reclaim_page(tree->pool, 8)) {
>> +               if (zbud_reclaim_page(mem_pool, 8)) {
>>                         zswap_reject_reclaim_fail++;
>>                         ret = -ENOMEM;
>>                         goto reject;
>> @@ -679,7 +680,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>>
>>         /* store */
>>         len = dlen + sizeof(struct zswap_header);
>> -       ret = zbud_alloc(tree->pool, len, __GFP_NORETRY | __GFP_NOWARN,
>> +       ret = zbud_alloc(mem_pool, len, __GFP_NORETRY | __GFP_NOWARN,
>>                 &handle);
>>         if (ret == -ENOSPC) {
>>                 zswap_reject_compress_poor++;
>> @@ -689,11 +690,11 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>>                 zswap_reject_alloc_fail++;
>>                 goto freepage;
>>         }
>> -       zhdr = zbud_map(tree->pool, handle);
>> +       zhdr = zbud_map(mem_pool, handle);
>>         zhdr->swpentry = swp_entry(type, offset);
>>         buf = (u8 *)(zhdr + 1);
>>         memcpy(buf, dst, dlen);
>> -       zbud_unmap(tree->pool, handle);
>> +       zbud_unmap(mem_pool, handle);
>>         put_cpu_var(zswap_dstmem);
>>
>>         /* populate entry */
>> @@ -716,7 +717,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>>
>>         /* update stats */
>>         atomic_inc(&zswap_stored_pages);
>> -       zswap_pool_pages = zbud_get_pool_size(tree->pool);
>> +       zswap_pool_pages = zbud_get_pool_size(mem_pool);
>>
>>         return 0;
>>
>> @@ -752,13 +753,13 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
>>
>>         /* decompress */
>>         dlen = PAGE_SIZE;
>> -       src = (u8 *)zbud_map(tree->pool, entry->handle) +
>> +       src = (u8 *)zbud_map(mem_pool, entry->handle) +
>>                         sizeof(struct zswap_header);
>>         dst = kmap_atomic(page);
>>         ret = zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src, entry->length,
>>                 dst, &dlen);
>>         kunmap_atomic(dst);
>> -       zbud_unmap(tree->pool, entry->handle);
>> +       zbud_unmap(mem_pool, entry->handle);
>>         BUG_ON(ret);
>>
>>         spin_lock(&tree->lock);
>> @@ -807,8 +808,6 @@ static void zswap_frontswap_invalidate_area(unsigned type)
>>                 zswap_free_entry(tree, entry);
>>         tree->rbroot = RB_ROOT;
>>         spin_unlock(&tree->lock);
>> -
>> -       zbud_destroy_pool(tree->pool);
>>         kfree(tree);
>>         zswap_trees[type] = NULL;
>>  }
>> @@ -822,20 +821,14 @@ static void zswap_frontswap_init(unsigned type)
>>         struct zswap_tree *tree;
>>
>>         tree = kzalloc(sizeof(struct zswap_tree), GFP_KERNEL);
>> -       if (!tree)
>> -               goto err;
>> -       tree->pool = zbud_create_pool(GFP_KERNEL, &zswap_zbud_ops);
>> -       if (!tree->pool)
>> -               goto freetree;
>> +       if (!tree) {
>> +               pr_err("alloc failed, zswap disabled for swap type %d\n", type);
>> +               return;
>> +       }
>> +
>>         tree->rbroot = RB_ROOT;
>>         spin_lock_init(&tree->lock);
>>         zswap_trees[type] = tree;
>> -       return;
>> -
>> -freetree:
>> -       kfree(tree);
>> -err:
>> -       pr_err("alloc failed, zswap disabled for swap type %d\n", type);
>>  }
>>
>>  static struct frontswap_ops zswap_frontswap_ops = {
>> @@ -907,9 +900,14 @@ static int __init init_zswap(void)
>>                 return 0;
>>
>>         pr_info("loading zswap\n");
>> +
>> +       mem_pool = zbud_create_pool(GFP_KERNEL, &zswap_zbud_ops);
>> +       if (!mem_pool)
>> +               goto error;
>> +
>>         if (zswap_entry_cache_create()) {
>>                 pr_err("entry cache creation failed\n");
>> -               goto error;
>> +               goto cachefail;
>>         }
>>         if (zswap_comp_init()) {
>>                 pr_err("compressor initialization failed\n");
>> @@ -919,6 +917,8 @@ static int __init init_zswap(void)
>>                 pr_err("per-cpu initialization failed\n");
>>                 goto pcpufail;
>>         }
>> +
>> +
>>         frontswap_register_ops(&zswap_frontswap_ops);
>>         if (zswap_debugfs_init())
>>                 pr_warn("debugfs initialization failed\n");
>> @@ -927,6 +927,8 @@ pcpufail:
>>         zswap_comp_exit();
>>  compfail:
>>         zswap_entry_cache_destory();
>> +cachefail:
>> +       zbud_destroy_pool(mem_pool);
>>  error:
>>         return -ENOMEM;
>>  }
>> --
>> 1.8.5.2
>>
>>
>> --
>> Kind regards,
>> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
