Date: Tue, 22 May 2007 20:01:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Patch] memory unplug v3 [1/4] page isolation
Message-Id: <20070522200139.e7ac1987.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0705221023020.16461@skynet.skynet.ie>
References: <20070522155824.563f5873.kamezawa.hiroyu@jp.fujitsu.com>
	<20070522160151.3ae5e5d7.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0705221023020.16461@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, y-goto@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, 22 May 2007 11:19:27 +0100 (IST)
Mel Gorman <mel@csn.ul.ie> wrote:
> > If isolate_pages(start,end) is called,
> > - migratetype of the range turns to be MIGRATE_ISOLATE  if
> >  its current type is MIGRATE_MOVABLE or MIGRATE_RESERVE.
> 
> Why not MIGRATE_RECLAIMABLE as well?
> 

To allow that, I have to implement page_reclaime_range(start_pfn, end_pfn);
Now, I use just migration.
I'll consider it as my future work.
Maybe Christoph's work will help me.

> > - MIGRATE_ISOLATE is not on migratetype fallback list.
> >
> > Then, pages of this migratetype will not be allocated even if it is free.
> >
> > Now, isolate_pages() only can treat the range aligned to MAX_ORDER.
> > This can be adjusted if necesasry...maybe.
> >
> 
> I have a patch ready that groups pages by an arbitrary order. Right now it 
> is related to the size of the huge page on the system but it's a single 
> variable pageblock_order that determines the range. You may find you want 
> to adjust this value.
> 
I see. I'll support it in patches for next -mm.


> > +#define MIGRATE_UNMOVABLE     0		/* not reclaimable pages */
> > +#define MIGRATE_RECLAIMABLE   1		/* shrink_xxx routine can reap this */
> > +#define MIGRATE_MOVABLE       2		/* migrate_page can migrate this */
> > +#define MIGRATE_RESERVE       3		/* no type yet */
> 
> MIGRATE_RESERVE is where the min_free_kbytes pages are kept if possible 
> and the number of RESERVE blocks depends on the value of it. It is only 
> allocated from if the alternative is to fail the allocation so this 
> comment should read
> 
> /* min_free_kbytes free pages here */
> 
ok.

> Later we may find a way of using MIGRATE_RESERVE to isolate ranges but 
> it's not necessary now because it would obscure how the patch works.
> 
> > +#define MIGRATE_ISOLATE       4		/* never allocated from */
> > +#define MIGRATE_TYPES         5
> >
> 
> The documentation changes probably belong in a separate patch but thanks, 
> it nudges me again into getting around to it.
> 
Ok, I'll just consider comments for MIGRAT_ISOLATE.


>
> > +
> > +	migrate_type = get_pageblock_migratetype(page);
> > +	if (migrate_type == MIGRATE_ISOLATE) {
> > +		__free_pages_ok(page, 0);
> > +		return;
> > +	}
> 
> This change to the PCP allocator may be unnecessary. If you let the page 
> free to the pcp lists, they will never be allocated from there because 
> allocflags_to_migratetype() will never return MIGRATE_ISOLATE. What you 
> could do is drain the PCP lists just before you try to hot-remove or call 
> test_pages_isolated() to that the pcp pages will free back to the 
> MIGRATE_ISOLATE lists.
> 
Ah.. thanks. I'll remove this.


> The extra drain is undesirable but probably better than checking for 
> isolate every time a free occurs to the pcp lists.
> 
yes.

>
> > +/*
> > + * set/clear page block's type to be ISOLATE.
> > + * page allocater never alloc memory from ISOLATE blcok.
> > + */
> > +
> > +int is_page_isolated(struct page *page)
> > +{
> > +	if ((page_count(page) == 0) &&
> > +	    (get_pageblock_migratetype(page) == MIGRATE_ISOLATE))
> 
> (PageBuddy(page) || (page_count(page) == 0 && PagePrivate(page))) &&
>  	(get_pageblock_migratetype(page) == MIGRATE_ISOLATE)
> 
> PageBuddy(page) for free pages and page_count(page) with PagePrivate 
> should indicate pages that are on the pcp lists.
> 
> As you currently prevent ISOLATE pages going to the pcp lists, only the 
> PageBuddy check is necessary right now but If you drain before you check 
> for isolated pages, you only need the PageBuddy() check. If you choose to 
> let pages on the pcp lists until a drain occurs, then you need the second 
> check.
> 
> This page_count() check instead of PageBuddy() appears to be related to 
> how test_pages_isolated() is implemented - more on that later.
> 
PG_buddy is set only if page is linked to freelist. IOW, if the page
is not the head of its buddy, PG_buddy is not set.
So, I didn't use PageBuddy().

(*) If I use PG_buddy for check "page is free or not", I have to search 
    head of buddy and its order.

> > +		return 1;
> > +	return 0;
> > +}
> > +
> > +int set_migratetype_isolate(struct page *page)
> > +{
> 
> set_pageblock_isolate() maybe to match set_pageblock_migratetype() naming?
> 

> > +	struct zone *zone;
> > +	unsigned long flags;
> > +	int migrate_type;
> > +	int ret = -EBUSY;
> > +
> > +	zone = page_zone(page);
> > +	spin_lock_irqsave(&zone->lock, flags);
> 
> It may be more appropriate to have the caller take this lock. More later 
> in isolates_pages()
> 
ok.

> > +	migrate_type = get_pageblock_migratetype(page);
> > +	if ((migrate_type != MIGRATE_MOVABLE) &&
> > +	    (migrate_type != MIGRATE_RESERVE))
> > +		goto out;
> 
> and maybe MIGRATE_RECLAIMABLE here particularly in view of Christoph's 
> work with kmem_cache_vacate().
> 
ok. I'll look into.


> > +	set_pageblock_migratetype(page, MIGRATE_ISOLATE);
> > +	move_freepages_block(zone, page, MIGRATE_ISOLATE);
> > +	ret = 0;
> > +out:
> > +	spin_unlock_irqrestore(&zone->lock, flags);
> > +	if (!ret)
> > +		drain_all_local_pages();
> 
> It's not clear why you drain the pcp lists when you encounter a block of 
> the wrong migrate_type. Draining the pcp lists is unlikely to help you.
> 
Ah, drain_all_local_pages() are called when MIGRATE_ISOLATE is successfully set.
But I'll change this because I'll remove hook in free_hot_cold_page() and call
drain_all_local_pages() in somewhere.


> > +	return ret;
> > +}
> > +
> > +void clear_migratetype_isolate(struct page *page)
> > +{
> > +	struct zone *zone;
> > +	unsigned long flags;
> > +	zone = page_zone(page);
> > +	spin_lock_irqsave(&zone->lock, flags);
> > +	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
> > +		goto out;
> > +	set_pageblock_migratetype(page, MIGRATE_RESERVE);
> > +	move_freepages_block(zone, page, MIGRATE_RESERVE);
> 
> MIGRATE_RESERVE is likely not what you want to do here. The number of 
> MIGRATE_RESERVE blocks in a zone is determined by 
> setup_zone_migrate_reserve(). If you are setting blocks like this, then 
> you need to call setup_zone_migrate_reserve() with the zone->lru_lock held 
> after you have call clear_migratetype_isolate() for all the necessary 
> blocks.
> 
> It may be easier to just set the blocks MIGRATE_MOVABLE.
> 
Ok.



> > +out:
> > +	spin_unlock_irqrestore(&zone->lock, flags);
> > +}
> > Index: devel-2.6.22-rc1-mm1/mm/page_isolation.c
> > ===================================================================
> > --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> > +++ devel-2.6.22-rc1-mm1/mm/page_isolation.c	2007-05-22 15:12:28.000000000 +0900
> > @@ -0,0 +1,67 @@
> > +/*
> > + * linux/mm/page_isolation.c
> > + */
> > +
> > +#include <stddef.h>
> > +#include <linux/mm.h>
> > +#include <linux/page-isolation.h>
> > +
> > +#define ROUND_DOWN(x,y)	((x) & ~((y) - 1))
> > +#define ROUND_UP(x,y)	(((x) + (y) -1) & ~((y) - 1))
> 
> A roundup() macro already exists in kernel.h. You may want to use that and 
> define a new rounddown() macro there instead.
Oh...I couldn't find it. thank you.


> 
> > +int
> > +isolate_pages(unsigned long start_pfn, unsigned long end_pfn)
> > +{
> > +	unsigned long pfn, start_pfn_aligned, end_pfn_aligned;
> > +	unsigned long undo_pfn;
> > +
> > +	start_pfn_aligned = ROUND_DOWN(start_pfn, NR_PAGES_ISOLATION_BLOCK);
> > +	end_pfn_aligned = ROUND_UP(end_pfn, NR_PAGES_ISOLATION_BLOCK);
> > +
> > +	for (pfn = start_pfn_aligned;
> > +	     pfn < end_pfn_aligned;
> > +	     pfn += NR_PAGES_ISOLATION_BLOCK)
> > +		if (set_migratetype_isolate(pfn_to_page(pfn))) {
> 
> You will need to call pfn_valid() in the non-SPARSEMEM case before calling 
> pfn_to_page() or this will crash in some circumstances.
ok.

> 
> You also need to check zone boundaries. Lets say start_pfn is the start of 
> a non-MAX_ORDER aligned zone. Aligning it could make you start isolating 
> in the wrong zone - prehaps this is intentional, I don't know.

Ah, ok. at least pfn_valid() is necessary.



> 
> > +			undo_pfn = pfn;
> > +			goto undo;
> > +		}
> > +	return 0;
> > +undo:
> > +	for (pfn = start_pfn_aligned;
> > +	     pfn <= undo_pfn;
> > +	     pfn += NR_PAGES_ISOLATION_BLOCK)
> > +		clear_migratetype_isolate(pfn_to_page(pfn));
> > +
> 
> We fail if we encounter any non-MIGRATE_MOVABLE block in the start_pfn to 
> end_pfn range but at that point we've done a lot of work. We also take and 
> release an interrupt safe lock for each NR_PAGES_ISOLATION_BLOCK block 
> because set_migratetype_isolate() is responsible for lock taking.
> 
> It might be better if you took the lock here, scanned first to make sure 
> all the blocks were suitable for isolation and only then, call 
> set_migratetype_isolate() for each of them before releasing the lock.

Hm. ok.

> 
> That would take the lock once and avoid the need for back-out code that 
> changes all the MIGRATE types in the range. Even for large ranges of 
> memory, it should not be too long to be holding a lock particularly in 
> this path.
> 


> > +	return -EBUSY;
> > +}
> > +
> > +
> > +int
> > +free_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
> > +{
> > +	unsigned long pfn, start_pfn_aligned, end_pfn_aligned;
> > +	start_pfn_aligned = ROUND_DOWN(start_pfn, NR_PAGES_ISOLATION_BLOCK);
> > +        end_pfn_aligned = ROUND_UP(end_pfn, NR_PAGES_ISOLATION_BLOCK);
> 
> spaces instead of tabs there before end_pfn_aligned.
> 
> > +
> > +	for (pfn = start_pfn_aligned;
> > +	     pfn < end_pfn_aligned;
> > +	     pfn += MAX_ORDER_NR_PAGES)
> 
> pfn += NR_PAGES_ISOLATION_BLOCK ?
> 
yes. it should be.

> pfn_valid() ?
> 
ok.

> > +		clear_migratetype_isolate(pfn_to_page(pfn));
> > +	return 0;
> > +}
> > +
> > +int
> > +test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
> > +{
> > +	unsigned long pfn;
> > +	int ret = 0;
> > +
> 
> You didn't align here, intentional?
> 
Ah...no. check alignment in the next version.


> > +	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
> > +		if (!pfn_valid(pfn))
> > +			continue;
> > +		if (!is_page_isolated(pfn_to_page(pfn))) {
> > +			ret = 1;
> > +			break;
> > +		}
> 
> If the page is isolated, it's free and assuming you've drained the pcp 
> lists, it will have PageBuddy() set. In that case, you should be checking 
> what order the page is free at and skipping forward that number of pages. 
> I am guessing this pfn++ walk here is why you are checking 
> page_count(page) == 0 in is_page_isolated() instead of PageBuddy()
> 
yes. In next version, I'd like to try to treat PageBuddy() and page_order() things.


> > +	}
> > +	return ret;
> 
> The return value is a little counter-intuitive. It returns 1 if they are 
> not isolated. I would expect it to return 1 if isolated like test_bit() 
> returns 1 if it's set.
> 
ok.

> > +#define PAGE_ISOLATION_ORDER	(MAX_ORDER - 1)
> > +#define NR_PAGES_ISOLATION_BLOCK	(1 << PAGE_ISOLATION_ORDER)
> > +
> 
> When grouping-pages-by-arbitary-order goes in, there will be a value 
> available called pageblock_order and nr_pages_pageblock which will be 
> identical to these two values.
> 
ok.


> All in all, I like this implementation. I found it nice and relatively 
> straight-forward to read. Thanks
> 
Thank you for review. I'll reflect your comments in the next version.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
