Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 4 Feb 2013 16:06:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: hotplug: implement non-movable version of
 get_user_pages() called get_user_pages_non_movable()
Message-Id: <20130204160624.5c20a8a0.akpm@linux-foundation.org>
In-Reply-To: <1359972248-8722-2-git-send-email-linfeng@cn.fujitsu.com>
References: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com>
	<1359972248-8722-2-git-send-email-linfeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: mgorman@suse.de, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org


melreadthis

On Mon, 4 Feb 2013 18:04:07 +0800
Lin Feng <linfeng@cn.fujitsu.com> wrote:

> get_user_pages() always tries to allocate pages from movable zone, which is not
>  reliable to memory hotremove framework in some case.
> 
> This patch introduces a new library function called get_user_pages_non_movable()
>  to pin pages only from zone non-movable in memory.
> It's a wrapper of get_user_pages() but it makes sure that all pages come from
> non-movable zone via additional page migration.
> 
> ...
>
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1049,6 +1049,11 @@ int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  			struct page **pages, struct vm_area_struct **vmas);
>  int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>  			struct page **pages);
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +int get_user_pages_non_movable(struct task_struct *tsk, struct mm_struct *mm,
> +		unsigned long start, int nr_pages, int write, int force,
> +		struct page **pages, struct vm_area_struct **vmas);
> +#endif

The ifdefs aren't really needed here and I encourage people to omit
them.  This keeps the header files looking neater and reduces the
chances of things later breaking because we forgot to update some
CONFIG_foo logic in a header file.  The downside is that errors will be
revealed at link time rather than at compile time, but that's a pretty
small cost.

>  struct kvec;
>  int get_kernel_pages(const struct kvec *iov, int nr_pages, int write,
>  			struct page **pages);
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 73b64a3..5db811e 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -838,6 +838,10 @@ static inline int is_normal_idx(enum zone_type idx)
>  	return (idx == ZONE_NORMAL);
>  }
>  
> +static inline int is_movable(struct zone *zone)
> +{
> +	return zone == zone->zone_pgdat->node_zones + ZONE_MOVABLE;
> +}

A better name would be zone_is_movable().  We haven't been very
consistent about this in mmzone.h, but zone_is_foo() is pretty common.

And a neater implementation would be

	return zone_idx(zone) == ZONE_MOVABLE;

All of which made me look at mmzone.h, and what I saw wasn't very nice :(

Please review...


From: Andrew Morton <akpm@linux-foundation.org>
Subject: include/linux/mmzone.h: cleanups

- implement zone_idx() in C to fix its references-args-twice macro bug

- use zone_idx() in is_highmem() to remove large amounts of silly fluff.

Cc: Lin Feng <linfeng@cn.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/mmzone.h |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff -puN include/linux/mmzone.h~include-linux-mmzoneh-cleanups include/linux/mmzone.h
--- a/include/linux/mmzone.h~include-linux-mmzoneh-cleanups
+++ a/include/linux/mmzone.h
@@ -815,7 +815,10 @@ unsigned long __init node_memmap_size_by
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
@@ -857,10 +860,10 @@ static inline int is_normal_idx(enum zon
 static inline int is_highmem(struct zone *zone)
 {
 #ifdef CONFIG_HIGHMEM
-	int zone_off = (char *)zone - (char *)zone->zone_pgdat->node_zones;
-	return zone_off == ZONE_HIGHMEM * sizeof(*zone) ||
-	       (zone_off == ZONE_MOVABLE * sizeof(*zone) &&
-		zone_movable_is_highmem());
+	enum zone_type idx = zone_idx(zone);
+
+	return idx == ZONE_HIGHMEM ||
+	       (idx == ZONE_MOVABLE && zone_movable_is_highmem());
 #else
 	return 0;
 #endif
_


> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -58,6 +58,8 @@
>  #include <linux/elf.h>
>  #include <linux/gfp.h>
>  #include <linux/migrate.h>
> +#include <linux/page-isolation.h>
> +#include <linux/mm_inline.h>
>  #include <linux/string.h>
>  
>  #include <asm/io.h>
> @@ -1995,6 +1997,67 @@ int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  }
>  EXPORT_SYMBOL(get_user_pages);
>  
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +/**
> + * It's a wrapper of get_user_pages() but it makes sure that all pages come from
> + * non-movable zone via additional page migration.
> + */

This needs a description of why the function exists - say something
about the requirements of memory hotplug.

Also a few words describing how the function works would be good.

> +int get_user_pages_non_movable(struct task_struct *tsk, struct mm_struct *mm,
> +		unsigned long start, int nr_pages, int write, int force,
> +		struct page **pages, struct vm_area_struct **vmas)
> +{
> +	int ret, i, isolate_err, migrate_pre_flag;
> +	LIST_HEAD(pagelist);
> +
> +retry:
> +	ret = get_user_pages(tsk, mm, start, nr_pages, write, force, pages,
> +				vmas);

We should handle (ret < 0) here.  At present the function will silently
convert an error return into "return 0", which is bad.  The function
does appear to otherwise do the right thing if get_user_pages() failed,
but only due to good luck.

> +	isolate_err = 0;
> +	migrate_pre_flag = 0;
> +
> +	for (i = 0; i < ret; i++) {
> +		if (is_movable(page_zone(pages[i]))) {
> +			if (!migrate_pre_flag) {
> +				if (migrate_prep())
> +					goto put_page;
> +				migrate_pre_flag = 1;
> +			}
> +
> +			if (!isolate_lru_page(pages[i])) {
> +				inc_zone_page_state(pages[i], NR_ISOLATED_ANON +
> +						 page_is_file_cache(pages[i]));
> +				list_add_tail(&pages[i]->lru, &pagelist);
> +			} else {
> +				isolate_err = 1;
> +				goto put_page;
> +			}
> +		}
> +	}
> +
> +	/* All pages are non movable, we are done :) */
> +	if (i == ret && list_empty(&pagelist))
> +		return ret;
> +
> +put_page:
> +	/* Undo the effects of former get_user_pages(), we won't pin anything */
> +	for (i = 0; i < ret; i++)
> +		put_page(pages[i]);
> +
> +	if (migrate_pre_flag && !isolate_err) {
> +		ret = migrate_pages(&pagelist, alloc_migrate_target, 1,
> +					false, MIGRATE_SYNC, MR_SYSCALL);
> +		/* Steal pages from non-movable zone successfully? */
> +		if (!ret)
> +			goto retry;

This is buggy.  migrate_pages() doesn't empty its `from' argument, so
page_list must be reinitialised here (or, better, at the start of the loop).

Mel, what's up with migrate_pages()?  Shouldn't it be removing the
pages from the list when MIGRATEPAGE_SUCCESS?  The use of
list_for_each_entry_safe() suggests we used to do that...

> +	}
> +
> +	putback_lru_pages(&pagelist);
> +	return 0;
> +}
> +EXPORT_SYMBOL(get_user_pages_non_movable);
> +#endif
> +

Generally, I'd like Mel to go through (the next version of) this patch
carefully, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
