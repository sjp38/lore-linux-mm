Return-Path: <owner-linux-mm@kvack.org>
Date: Tue, 5 Feb 2013 11:57:22 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] mm: hotplug: implement non-movable version of
 get_user_pages() called get_user_pages_non_movable()
Message-ID: <20130205115722.GF21389@suse.de>
References: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com>
 <1359972248-8722-2-git-send-email-linfeng@cn.fujitsu.com>
 <20130204160624.5c20a8a0.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130204160624.5c20a8a0.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lin Feng <linfeng@cn.fujitsu.com>, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Feb 04, 2013 at 04:06:24PM -0800, Andrew Morton wrote:
> On Mon, 4 Feb 2013 18:04:07 +0800
> Lin Feng <linfeng@cn.fujitsu.com> wrote:
> 
> > get_user_pages() always tries to allocate pages from movable zone, which is not
> >  reliable to memory hotremove framework in some case.
> > 
> > This patch introduces a new library function called get_user_pages_non_movable()
> >  to pin pages only from zone non-movable in memory.
> > It's a wrapper of get_user_pages() but it makes sure that all pages come from
> > non-movable zone via additional page migration.
> > 
> > ...
> >
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -1049,6 +1049,11 @@ int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> >  			struct page **pages, struct vm_area_struct **vmas);
> >  int get_user_pages_fast(unsigned long start, int nr_pages, int write,
> >  			struct page **pages);
> > +#ifdef CONFIG_MEMORY_HOTREMOVE
> > +int get_user_pages_non_movable(struct task_struct *tsk, struct mm_struct *mm,
> > +		unsigned long start, int nr_pages, int write, int force,
> > +		struct page **pages, struct vm_area_struct **vmas);
> > +#endif
> 
> The ifdefs aren't really needed here and I encourage people to omit
> them.  This keeps the header files looking neater and reduces the
> chances of things later breaking because we forgot to update some
> CONFIG_foo logic in a header file.  The downside is that errors will be
> revealed at link time rather than at compile time, but that's a pretty
> small cost.
> 

As an aside, if ifdefs *have* to be used then it often better to have a
pattern like

#ifdef CONFIG_MEMORY_HOTREMOVE
int get_user_pages_non_movable(struct task_struct *tsk, struct mm_struct *mm,
		unsigned long start, int nr_pages, int write, int force,
		struct page **pages, struct vm_area_struct **vmas);
#else
static inline get_user_pages_non_movable(...)
{
	get_user_pages(...)
}
#endif

It eliminates the need for #ifdefs in the C file that calls
get_user_pages_non_movable().

> >  struct kvec;
> >  int get_kernel_pages(const struct kvec *iov, int nr_pages, int write,
> >  			struct page **pages);
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 73b64a3..5db811e 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -838,6 +838,10 @@ static inline int is_normal_idx(enum zone_type idx)
> >  	return (idx == ZONE_NORMAL);
> >  }
> >  
> > +static inline int is_movable(struct zone *zone)
> > +{
> > +	return zone == zone->zone_pgdat->node_zones + ZONE_MOVABLE;
> > +}
> 
> A better name would be zone_is_movable(). 

He is matching the names of the is_normal(), is_dma32() and is_dma() helpers.
Unfortunately I would expect a name like is_movable() to return true if the
page had either been allocated with __GFP_MOVABLE or if it was checking
migrate can currently handle the page. is_movable() is indeed a terrible
name. They should be renamed or deleted in preparation -- see below.

> We haven't been very
> consistent about this in mmzone.h, but zone_is_foo() is pretty common.
> 
> And a neater implementation would be
> 
> 	return zone_idx(zone) == ZONE_MOVABLE;
> 

Yes.

> All of which made me look at mmzone.h, and what I saw wasn't very nice :(
> 
> Please review...
> 
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: include/linux/mmzone.h: cleanups
> 
> - implement zone_idx() in C to fix its references-args-twice macro bug
> 
> - use zone_idx() in is_highmem() to remove large amounts of silly fluff.
> 
> Cc: Lin Feng <linfeng@cn.fujitsu.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  include/linux/mmzone.h |   13 ++++++++-----
>  1 file changed, 8 insertions(+), 5 deletions(-)
> 
> diff -puN include/linux/mmzone.h~include-linux-mmzoneh-cleanups include/linux/mmzone.h
> --- a/include/linux/mmzone.h~include-linux-mmzoneh-cleanups
> +++ a/include/linux/mmzone.h
> @@ -815,7 +815,10 @@ unsigned long __init node_memmap_size_by
>  /*
>   * zone_idx() returns 0 for the ZONE_DMA zone, 1 for the ZONE_NORMAL zone, etc.
>   */
> -#define zone_idx(zone)		((zone) - (zone)->zone_pgdat->node_zones)
> +static inline enum zone_type zone_idx(struct zone *zone)
> +{
> +	return zone - zone->zone_pgdat->node_zones;
> +}
>  
>  static inline int populated_zone(struct zone *zone)
>  {
> @@ -857,10 +860,10 @@ static inline int is_normal_idx(enum zon
>  static inline int is_highmem(struct zone *zone)
>  {
>  #ifdef CONFIG_HIGHMEM
> -	int zone_off = (char *)zone - (char *)zone->zone_pgdat->node_zones;
> -	return zone_off == ZONE_HIGHMEM * sizeof(*zone) ||
> -	       (zone_off == ZONE_MOVABLE * sizeof(*zone) &&
> -		zone_movable_is_highmem());
> +	enum zone_type idx = zone_idx(zone);
> +
> +	return idx == ZONE_HIGHMEM ||
> +	       (idx == ZONE_MOVABLE && zone_movable_is_highmem());
>  #else
>  	return 0;
>  #endif

*blinks*. Ok, while I think your version looks nicer, it is reverting
ddc81ed2 (remove sparse warning for mmzone.h). According to my version of
gcc at least, your patch reintroduces the sar and sparse complains if run as

make ARCH=i386 C=2 CF=-Wsparse-all 

.... this?

From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] include/linux/mmzone.h: cleanups

- implement zone_idx() in C to fix its references-args-twice macro bug

- implement zone_is_idx in an attempt to explain what the fluff in
  is_highmem is for

- rename is_highmem to zone_is_highmem as preparation for
  zone_is_movable()

- implement zone_is_movable as a helper for places that care about
  ZONE_MOVABLE

- Remove is_normal, is_dma32 and is_dma because apparently no one cares

- convert users of zone_idx(zone) == ZONE_FOO to appropriate
  zone_is_foo() helper

- Use is_highmem_idx() instead of is_highmem for the PageHighMem
  implementation. Should be functionally equivalent because we
  only care about the zones index, not exactly what zone it is

[akpm@linux-foundation.org: zone_idx() reimplementation]
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/s390/mm/init.c        |    2 +-
 arch/tile/mm/init.c        |    5 +----
 arch/x86/mm/highmem_32.c   |    2 +-
 include/linux/mmzone.h     |   49 +++++++++++++++-----------------------------
 include/linux/page-flags.h |    2 +-
 kernel/power/snapshot.c    |   12 +++++------
 mm/page_alloc.c            |    6 +++---
 7 files changed, 30 insertions(+), 48 deletions(-)

diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 81e596c..c26c321 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -231,7 +231,7 @@ int arch_add_memory(int nid, u64 start, u64 size)
 	if (rc)
 		return rc;
 	for_each_zone(zone) {
-		if (zone_idx(zone) != ZONE_MOVABLE) {
+		if (!zone_is_movable(zone)) {
 			/* Add range within existing zone limits */
 			zone_start_pfn = zone->zone_start_pfn;
 			zone_end_pfn = zone->zone_start_pfn +
diff --git a/arch/tile/mm/init.c b/arch/tile/mm/init.c
index ef29d6c..8287749 100644
--- a/arch/tile/mm/init.c
+++ b/arch/tile/mm/init.c
@@ -733,9 +733,6 @@ static void __init set_non_bootmem_pages_init(void)
 	for_each_zone(z) {
 		unsigned long start, end;
 		int nid = z->zone_pgdat->node_id;
-#ifdef CONFIG_HIGHMEM
-		int idx = zone_idx(z);
-#endif
 
 		start = z->zone_start_pfn;
 		end = start + z->spanned_pages;
@@ -743,7 +740,7 @@ static void __init set_non_bootmem_pages_init(void)
 		start = max(start, max_low_pfn);
 
 #ifdef CONFIG_HIGHMEM
-		if (idx == ZONE_HIGHMEM)
+		if (zone_is_highmem(z))
 			totalhigh_pages += z->spanned_pages;
 #endif
 		if (kdata_huge) {
diff --git a/arch/x86/mm/highmem_32.c b/arch/x86/mm/highmem_32.c
index 6f31ee5..63020e7 100644
--- a/arch/x86/mm/highmem_32.c
+++ b/arch/x86/mm/highmem_32.c
@@ -124,7 +124,7 @@ void __init set_highmem_pages_init(void)
 	for_each_zone(zone) {
 		unsigned long zone_start_pfn, zone_end_pfn;
 
-		if (!is_highmem(zone))
+		if (!zone_is_highmem(zone))
 			continue;
 
 		zone_start_pfn = zone->zone_start_pfn;
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index a23923b..5ecef75 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -779,10 +779,20 @@ static inline int local_memory_node(int node_id) { return node_id; };
 unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
 #endif
 
+static inline bool zone_is_idx(struct zone *zone, enum zone_type idx)
+{
+	/* This mess avoids a potentially expensive pointer subtraction. */
+	int zone_off = (char *)zone - (char *)zone->zone_pgdat->node_zones;
+	return zone_off == idx * sizeof(*zone);
+}
+
 /*
  * zone_idx() returns 0 for the ZONE_DMA zone, 1 for the ZONE_NORMAL zone, etc.
  */
-#define zone_idx(zone)		((zone) - (zone)->zone_pgdat->node_zones)
+static inline enum zone_type zone_idx(struct zone *zone)
+{
+	return zone - zone->zone_pgdat->node_zones;
+}
 
 static inline int populated_zone(struct zone *zone)
 {
@@ -810,50 +820,25 @@ static inline int is_highmem_idx(enum zone_type idx)
 #endif
 }
 
-static inline int is_normal_idx(enum zone_type idx)
-{
-	return (idx == ZONE_NORMAL);
-}
-
 /**
- * is_highmem - helper function to quickly check if a struct zone is a 
+ * zone_is_highmem - helper function to quickly check if a struct zone is a 
  *              highmem zone or not.  This is an attempt to keep references
  *              to ZONE_{DMA/NORMAL/HIGHMEM/etc} in general code to a minimum.
  * @zone - pointer to struct zone variable
  */
-static inline int is_highmem(struct zone *zone)
+static inline bool zone_is_highmem(struct zone *zone)
 {
 #ifdef CONFIG_HIGHMEM
-	int zone_off = (char *)zone - (char *)zone->zone_pgdat->node_zones;
-	return zone_off == ZONE_HIGHMEM * sizeof(*zone) ||
-	       (zone_off == ZONE_MOVABLE * sizeof(*zone) &&
-		zone_movable_is_highmem());
-#else
-	return 0;
-#endif
-}
-
-static inline int is_normal(struct zone *zone)
-{
-	return zone == zone->zone_pgdat->node_zones + ZONE_NORMAL;
-}
-
-static inline int is_dma32(struct zone *zone)
-{
-#ifdef CONFIG_ZONE_DMA32
-	return zone == zone->zone_pgdat->node_zones + ZONE_DMA32;
+	return zone_is_idx(zone, ZONE_HIGHMEM) ||
+	       (zone_is_idx(zone, ZONE_MOVABLE) && zone_movable_is_highmem());
 #else
 	return 0;
 #endif
 }
 
-static inline int is_dma(struct zone *zone)
+static inline bool zone_is_movable(struct zone *zone)
 {
-#ifdef CONFIG_ZONE_DMA
-	return zone == zone->zone_pgdat->node_zones + ZONE_DMA;
-#else
-	return 0;
-#endif
+	return zone_is_idx(zone, ZONE_MOVABLE);
 }
 
 /* These two functions are used to setup the per zone pages min values */
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index b5d1384..2f541f1 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -237,7 +237,7 @@ PAGEFLAG(Readahead, reclaim)		/* Reminder to do async read-ahead */
  * Must use a macro here due to header dependency issues. page_zone() is not
  * available at this point.
  */
-#define PageHighMem(__p) is_highmem(page_zone(__p))
+#define PageHighMem(__p) is_highmem_idx(page_zonenum(__p))
 #else
 PAGEFLAG_FALSE(HighMem)
 #endif
diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index 0de2857..cbf0da9 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -830,7 +830,7 @@ static unsigned int count_free_highmem_pages(void)
 	unsigned int cnt = 0;
 
 	for_each_populated_zone(zone)
-		if (is_highmem(zone))
+		if (zone_is_highmem(zone))
 			cnt += zone_page_state(zone, NR_FREE_PAGES);
 
 	return cnt;
@@ -879,7 +879,7 @@ static unsigned int count_highmem_pages(void)
 	for_each_populated_zone(zone) {
 		unsigned long pfn, max_zone_pfn;
 
-		if (!is_highmem(zone))
+		if (!zone_is_highmem(zone))
 			continue;
 
 		mark_free_pages(zone);
@@ -943,7 +943,7 @@ static unsigned int count_data_pages(void)
 	unsigned int n = 0;
 
 	for_each_populated_zone(zone) {
-		if (is_highmem(zone))
+		if (zone_is_highmem(zone))
 			continue;
 
 		mark_free_pages(zone);
@@ -989,7 +989,7 @@ static void safe_copy_page(void *dst, struct page *s_page)
 static inline struct page *
 page_is_saveable(struct zone *zone, unsigned long pfn)
 {
-	return is_highmem(zone) ?
+	return zone_is_highmem(zone) ?
 		saveable_highmem_page(zone, pfn) : saveable_page(zone, pfn);
 }
 
@@ -1338,7 +1338,7 @@ int hibernate_preallocate_memory(void)
 	size = 0;
 	for_each_populated_zone(zone) {
 		size += snapshot_additional_pages(zone);
-		if (is_highmem(zone))
+		if (zone_is_highmem(zone))
 			highmem += zone_page_state(zone, NR_FREE_PAGES);
 		else
 			count += zone_page_state(zone, NR_FREE_PAGES);
@@ -1481,7 +1481,7 @@ static int enough_free_mem(unsigned int nr_pages, unsigned int nr_highmem)
 	unsigned int free = alloc_normal;
 
 	for_each_populated_zone(zone)
-		if (!is_highmem(zone))
+		if (!zone_is_highmem(zone))
 			free += zone_page_state(zone, NR_FREE_PAGES);
 
 	nr_pages += count_pages_for_highmem(nr_highmem);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7e208f0..9558341 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5136,7 +5136,7 @@ static void __setup_per_zone_wmarks(void)
 
 	/* Calculate total number of !ZONE_HIGHMEM pages */
 	for_each_zone(zone) {
-		if (!is_highmem(zone))
+		if (!zone_is_highmem(zone))
 			lowmem_pages += zone->present_pages;
 	}
 
@@ -5146,7 +5146,7 @@ static void __setup_per_zone_wmarks(void)
 		spin_lock_irqsave(&zone->lock, flags);
 		tmp = (u64)pages_min * zone->present_pages;
 		do_div(tmp, lowmem_pages);
-		if (is_highmem(zone)) {
+		if (zone_is_highmem(zone)) {
 			/*
 			 * __GFP_HIGH and PF_MEMALLOC allocations usually don't
 			 * need highmem pages, so cap pages_min to a small
@@ -5585,7 +5585,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count)
 	 * For avoiding noise data, lru_add_drain_all() should be called
 	 * If ZONE_MOVABLE, the zone never contains unmovable pages
 	 */
-	if (zone_idx(zone) == ZONE_MOVABLE)
+	if (zone_is_movable(zone))
 		return false;
 	mt = get_pageblock_migratetype(page);
 	if (mt == MIGRATE_MOVABLE || is_migrate_cma(mt))

> _
> 
> 
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -58,6 +58,8 @@
> >  #include <linux/elf.h>
> >  #include <linux/gfp.h>
> >  #include <linux/migrate.h>
> > +#include <linux/page-isolation.h>
> > +#include <linux/mm_inline.h>
> >  #include <linux/string.h>
> >  
> >  #include <asm/io.h>
> > @@ -1995,6 +1997,67 @@ int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> >  }
> >  EXPORT_SYMBOL(get_user_pages);
> >  
> > +#ifdef CONFIG_MEMORY_HOTREMOVE
> > +/**
> > + * It's a wrapper of get_user_pages() but it makes sure that all pages come from
> > + * non-movable zone via additional page migration.
> > + */
> 
> This needs a description of why the function exists - say something
> about the requirements of memory hotplug.
> 
> Also a few words describing how the function works would be good.
> 
> > +int get_user_pages_non_movable(struct task_struct *tsk, struct mm_struct *mm,
> > +		unsigned long start, int nr_pages, int write, int force,
> > +		struct page **pages, struct vm_area_struct **vmas)
> > +{
> > +	int ret, i, isolate_err, migrate_pre_flag;

migrate_pre_flag should be bool and the name is a bit
unusual. migrate_prepped?

> > +	LIST_HEAD(pagelist);
> > +
> > +retry:
> > +	ret = get_user_pages(tsk, mm, start, nr_pages, write, force, pages,
> > +				vmas);
> 
> We should handle (ret < 0) here.  At present the function will silently
> convert an error return into "return 0", which is bad.  The function
> does appear to otherwise do the right thing if get_user_pages() failed,
> but only due to good luck.
> 

A BUG_ON check if we retry more than once wouldn't hurt either. It requires
a broken implementation of alloc_migrate_target() but someone might "fix"
it and miss this.

A minor aside, it would be nice if we exited at this point if there was
no populated ZONE_MOVABLE in the system. There is a movable_zone global
variable already. If it was forced to be MAX_NR_ZONES before the call to
find_usable_zone_for_movable() in memory initialisation we should be able
to make a cheap check for it here.

> > +	isolate_err = 0;
> > +	migrate_pre_flag = 0;
> > +
> > +	for (i = 0; i < ret; i++) {
> > +		if (is_movable(page_zone(pages[i]))) {

This is a relatively expensive lookup. If my patch above is used then
you can add a is_movable_idx helper and then this becomes

if (is_movable_idx(page_zonenum(pages[i])))

which is cheaper.

> > +			if (!migrate_pre_flag) {
> > +				if (migrate_prep())
> > +					goto put_page;

CONFIG_MEMORY_HOTREMOVE depends on CONFIG_MIGRATION so this will never
return failure. You could make this BUG_ON(migrate_prep()), remove this
goto and the migrate_pre_flag check below becomes redundant.

> > +				migrate_pre_flag = 1;
> > +			}
> > +
> > +			if (!isolate_lru_page(pages[i])) {
> > +				inc_zone_page_state(pages[i], NR_ISOLATED_ANON +
> > +						 page_is_file_cache(pages[i]));
> > +				list_add_tail(&pages[i]->lru, &pagelist);
> > +			} else {
> > +				isolate_err = 1;
> > +				goto put_page;
> > +			}

isolate_lru_page() takes the LRU lock every time. If
get_user_pages_non_movable is used heavily then you may encounter lock
contention problems. Batching this lock would be a separate patch and should
not be necessary yet but you should at least comment on it as a reminder.

I think that a goto could also have been avoided here if you used break. The
i == ret check below would be false and it would just fall through.
Overall the flow would be a bit easier to follow.

Why list_add_tail()? I don't think it's wrong but it's unusual to see
list_add_tail() when list_add() is enough.

> > +		}
> > +	}
> > +
> > +	/* All pages are non movable, we are done :) */
> > +	if (i == ret && list_empty(&pagelist))
> > +		return ret;
> > +
> > +put_page:
> > +	/* Undo the effects of former get_user_pages(), we won't pin anything */
> > +	for (i = 0; i < ret; i++)
> > +		put_page(pages[i]);
> > +

release_pages.

That comment is insufficient. There are non-obvious consequences to this
logic. We are dropping pins on all pages regardless of what zone they
are in. If the subsequent migration fails then we end up returning 0
with no pages pinned. The user-visible effect is that io_setup() fails
for non-obvious reasons. It will return EAGAIN to userspace which will be
interpreted as "The specified nr_events exceeds the user's limit of available
events.". The application will either fail or potentially infinite loop
if the developer interpreted EAGAIN as "try again" as opposed to "this is
a permanent failure".

Is that deliberate? Is it really preferable that AIO can fail to setup
and the application exit just in case we want to hot-remove memory later?
Should a failed migration generate a WARN_ON at least?

I would think that it's better to WARN_ON_ONCE if migration fails but pin
the pages as requested. If a future memory hot-remove operation fails
then the warning will indicate why but applications will not fail as a
result. It's a little clumsy but the memory hot-remove failure message
could list what applications have pinned the pages that cannot be removed
so the administrator has the option of force-killing the application. It
is possible to discover what application is pinning a page from userspace
but it would involve an expensive search with /proc/kpagemap

> > +	if (migrate_pre_flag && !isolate_err) {
> > +		ret = migrate_pages(&pagelist, alloc_migrate_target, 1,
> > +					false, MIGRATE_SYNC, MR_SYSCALL);

The conversion of alloc_migrate_target is a bit problematic. It strips
the __GFP_MOVABLE flag and the consequence of this is that it converts
those allocation requests to MIGRATE_UNMOVABLE. This potentially is a large
number of pages, particularly if the number of get_user_pages_non_movable()
increases for short-lived pins like direct IO.

One way around this is to add a high_zoneidx parameter to
__alloc_pages_nodemask and rename it ____alloc_pages_nodemask, create a new
inline function __alloc_pages_nodemask that passes in gfp_zone(gfp_mask)
as the high_zoneidx and create a new migration allocation function that
passes on ZONE_HIGHMEM as high_zoneidx. That would force the allocation to
happen in a lower zone while still treating the allocation as MIGRATE_MOVABLE

> > +		/* Steal pages from non-movable zone successfully? */
> > +		if (!ret)
> > +			goto retry;
> 
> This is buggy.  migrate_pages() doesn't empty its `from' argument, so
> page_list must be reinitialised here (or, better, at the start of the loop).
> 

page_list should be empty if ret == 0.

> Mel, what's up with migrate_pages()?  Shouldn't it be removing the
> pages from the list when MIGRATEPAGE_SUCCESS?  The use of
> list_for_each_entry_safe() suggests we used to do that...
> 

On successful migration, the pages are put back on the LRU at the end of
unmap_and_move(). On migration failure the caller is responsible for putting
the pages back on the LRU with putback_lru_pages() which happens below.

> > +	}
> > +
> > +	putback_lru_pages(&pagelist);
> > +	return 0;
> > +}
> > +EXPORT_SYMBOL(get_user_pages_non_movable);
> > +#endif
> > +
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
