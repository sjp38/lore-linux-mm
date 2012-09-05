Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 22B836B002B
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 06:53:47 -0400 (EDT)
Date: Wed, 5 Sep 2012 11:53:40 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC] mm: support MIGRATE_DISCARD
Message-ID: <20120905105340.GH11266@suse.de>
References: <1345782330-23234-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1345782330-23234-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Rik van Riel <riel@redhat.com>

On Fri, Aug 24, 2012 at 01:25:30PM +0900, Minchan Kim wrote:
> This patch introudes MIGRATE_DISCARD mode in migration.

s/introudes/introduces/

It's also not a "mode" like the other MIGRATE_ modes but is instead
a modifier.

> It drops *unmapped clean cache pages* instead of migration so that
> migration latency could be reduced by avoiding (memcpy + page remapping).
> It's useful for CMA because latency of migration is very important rather
> than eviction of background processes's workingset.

It does assume that there is clean unmapped page cache available. This will
be the case if the workload was a streaming read for example. I don't know
enough about embedded workloads to categorise them unfortunately.

> In addition, it needs
> less free pages for migration targets so it could avoid memory reclaiming
> to get free pages, which is another factor increase latency.
> 
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  include/linux/migrate_mode.h |   11 ++++++---
>  mm/migrate.c                 |   56 ++++++++++++++++++++++++++++++++++--------
>  mm/page_alloc.c              |    2 +-
>  3 files changed, 55 insertions(+), 14 deletions(-)
> 
> diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
> index ebf3d89..8e44e30 100644
> --- a/include/linux/migrate_mode.h
> +++ b/include/linux/migrate_mode.h
> @@ -6,11 +6,16 @@
>   *	on most operations but not ->writepage as the potential stall time
>   *	is too significant
>   * MIGRATE_SYNC will block when migrating pages
> + * MIGRTATE_DISCARD will discard clean cache page instead of migration
> + *

s/MIGRTATE_DISCARD/MIGRATE_DISCARD/

Your changelog says that it discards unmapped clean page cache pages.
This says it unmaps clean page cache pages. Which is it?

> + * MIGRATE_ASYNC, MIGRATE_SYNC_LIGHT, MIGRATE_SYNC shouldn't be used
> + * together with OR flag.
>   */
>  enum migrate_mode {
> -	MIGRATE_ASYNC,
> -	MIGRATE_SYNC_LIGHT,
> -	MIGRATE_SYNC,
> +	MIGRATE_ASYNC = 1 << 0,
> +	MIGRATE_SYNC_LIGHT = 1 << 1,
> +	MIGRATE_SYNC = 1 << 2,
> +	MIGRATE_DISCARD = 1 << 3,
>  };
>  

This change means that migrate_mode is no longer an enum and it would be
more suitable to make it a bitwise type similar to what reclaim_mode_t
used to be.

>  #endif		/* MIGRATE_MODE_H_INCLUDED */
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 77ed2d7..90be7a9 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -225,7 +225,7 @@ static bool buffer_migrate_lock_buffers(struct buffer_head *head,
>  	struct buffer_head *bh = head;
>  
>  	/* Simple case, sync compaction */
> -	if (mode != MIGRATE_ASYNC) {
> +	if (!(mode & MIGRATE_ASYNC)) {
>  		do {
>  			get_bh(bh);
>  			lock_buffer(bh);
> @@ -313,7 +313,7 @@ static int migrate_page_move_mapping(struct address_space *mapping,
>  	 * the mapping back due to an elevated page count, we would have to
>  	 * block waiting on other references to be dropped.
>  	 */
> -	if (mode == MIGRATE_ASYNC && head &&
> +	if (mode & MIGRATE_ASYNC && head &&
>  			!buffer_migrate_lock_buffers(head, mode)) {

Expect this generated a compiler warning

if ((mode & MIGRATE_ASYNC) && head &&

>  		page_unfreeze_refs(page, expected_count);
>  		spin_unlock_irq(&mapping->tree_lock);
> @@ -521,7 +521,7 @@ int buffer_migrate_page(struct address_space *mapping,
>  	 * with an IRQ-safe spinlock held. In the sync case, the buffers
>  	 * need to be locked now
>  	 */
> -	if (mode != MIGRATE_ASYNC)
> +	if (!(mode & MIGRATE_ASYNC))
>  		BUG_ON(!buffer_migrate_lock_buffers(head, mode));
>  
>  	ClearPagePrivate(page);
> @@ -603,7 +603,7 @@ static int fallback_migrate_page(struct address_space *mapping,
>  {
>  	if (PageDirty(page)) {
>  		/* Only writeback pages in full synchronous migration */
> -		if (mode != MIGRATE_SYNC)
> +		if (!(mode & MIGRATE_SYNC))
>  			return -EBUSY;
>  		return writeout(mapping, page);
>  	}
> @@ -678,6 +678,19 @@ static int move_to_new_page(struct page *newpage, struct page *page,
>  	return rc;
>  }
>  
> +static int discard_page(struct page *page)
> +{
> +	int ret = -EAGAIN;
> +

WARN_ON(PageDirty(page));

> +	struct address_space *mapping = page_mapping(page);
> +	if (page_has_private(page))
> +		if (!try_to_release_page(page, GFP_KERNEL))
> +			return ret;
> +	if (remove_mapping(mapping, page))
> +		ret = 0;
> +	return ret;
> +}
> +
>  static int __unmap_and_move(struct page *page, struct page *newpage,
>  			int force, bool offlining, enum migrate_mode mode)
>  {
> @@ -685,9 +698,12 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>  	int remap_swapcache = 1;
>  	struct mem_cgroup *mem;
>  	struct anon_vma *anon_vma = NULL;
> +	enum ttu_flags ttu_flags;
> +	bool discard_mode = false;
> +	bool file = false;
>  
>  	if (!trylock_page(page)) {
> -		if (!force || mode == MIGRATE_ASYNC)
> +		if (!force || mode & MIGRATE_ASYNC)

may also need parens around mode & MIGRATE_ASYNC here.

>  			goto out;
>  
>  		/*
> @@ -733,7 +749,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>  		 * the retry loop is too short and in the sync-light case,
>  		 * the overhead of stalling is too much
>  		 */
> -		if (mode != MIGRATE_SYNC) {
> +		if (!(mode & MIGRATE_SYNC)) {
>  			rc = -EBUSY;
>  			goto uncharge;
>  		}
> @@ -799,12 +815,32 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>  		goto skip_unmap;
>  	}
>  
> +	file = page_is_file_cache(page);
> +	ttu_flags = TTU_IGNORE_ACCESS;
> +retry:
> +	if (!(mode & MIGRATE_DISCARD) || !file || PageDirty(page))
> +		ttu_flags |= (TTU_MIGRATION | TTU_IGNORE_MLOCK);
> +	else
> +		discard_mode = true;
> +

This should be broken out into another function migratemode_to_ttuflags()
similar to allocflags_to_migratetype.

>  	/* Establish migration ptes or remove ptes */
> -	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
> +	rc = try_to_unmap(page, ttu_flags);
>  

If discard_mode == true then ttu_flags does not have TTU_MIGRATION set.
That means a migration PTE is not put in place. Now, I expect this is
deliberate because you are about to discard the page but it should be
commented on.

>  skip_unmap:
> -	if (!page_mapped(page))
> -		rc = move_to_new_page(newpage, page, remap_swapcache, mode);
> +	if (rc == SWAP_SUCCESS) {
> +		if (!discard_mode)
> +			rc = move_to_new_page(newpage, page,
> +					remap_swapcache, mode);
> +		else {
> +
> +			rc = discard_page(page);
> +			goto uncharge;
> +		}
> +	} else if (rc == SWAP_MLOCK && discard_mode) {
> +		mode &= ~MIGRATE_DISCARD;
> +		discard_mode = false;
> +		goto retry;
> +	}
>  

I like the idea of what you're doing but not how you are doing
it. I do not like that this patch changes migrate_pages() into
migrate_but_sometimes_reclaim_pages_depending_on_flags().

I would *much* prefer if CMA created a new helper that took a page list.
In the first pass it would create a second list and add all clean page
cache pages and send that to shrink_page_list() in mm/vmscan.c. The second
pass would send the remaining pages to migrate_pages(). That would be
functionally similar but share common core code, churn migrate.c less,
avoid the need for changing an enum to a bitwise and generally be easier
to follow. The cost will be *marginally* higher as two scans of the list
are necessary but tiny in comparison to the cost of migration.

>  	if (rc && remap_swapcache)
>  		remove_migration_ptes(page, page);
> @@ -907,7 +943,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
>  	rc = -EAGAIN;
>  
>  	if (!trylock_page(hpage)) {
> -		if (!force || mode != MIGRATE_SYNC)
> +		if (!force || !(mode & MIGRATE_SYNC))
>  			goto out;
>  		lock_page(hpage);
>  	}
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ba3100a..e14b960 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5670,7 +5670,7 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
>  
>  		ret = migrate_pages(&cc.migratepages,
>  				    __alloc_contig_migrate_alloc,
> -				    0, false, MIGRATE_SYNC);
> +				    0, false, MIGRATE_SYNC|MIGRATE_DISCARD);
>  	}
>  
>  	putback_lru_pages(&cc.migratepages);
> -- 
> 1.7.9.5
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
