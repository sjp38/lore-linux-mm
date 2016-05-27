Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 099616B0265
	for <linux-mm@kvack.org>; Fri, 27 May 2016 10:26:28 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f75so61864124wmf.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 07:26:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f4si858886wma.120.2016.05.27.07.26.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 May 2016 07:26:26 -0700 (PDT)
Subject: Re: [PATCH v6 02/12] mm: migrate: support non-lru movable page
 migration
References: <1463754225-31311-1-git-send-email-minchan@kernel.org>
 <1463754225-31311-3-git-send-email-minchan@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ebe3244c-4821-aad2-ed32-8e730a882438@suse.cz>
Date: Fri, 27 May 2016 16:26:21 +0200
MIME-Version: 1.0
In-Reply-To: <1463754225-31311-3-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rafael Aquini <aquini@redhat.com>, virtualization@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>, John Einar Reitan <john.reitan@foss.arm.com>, dri-devel@lists.freedesktop.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Gioh Kim <gi-oh.kim@profitbricks.com>

On 05/20/2016 04:23 PM, Minchan Kim wrote:
> We have allowed migration for only LRU pages until now and it was
> enough to make high-order pages. But recently, embedded system(e.g.,
> webOS, android) uses lots of non-movable pages(e.g., zram, GPU memory)
> so we have seen several reports about troubles of small high-order
> allocation. For fixing the problem, there were several efforts
> (e,g,. enhance compaction algorithm, SLUB fallback to 0-order page,
> reserved memory, vmalloc and so on) but if there are lots of
> non-movable pages in system, their solutions are void in the long run.
>
> So, this patch is to support facility to change non-movable pages
> with movable. For the feature, this patch introduces functions related
> to migration to address_space_operations as well as some page flags.
>
> If a driver want to make own pages movable, it should define three functions
> which are function pointers of struct address_space_operations.
>
> 1. bool (*isolate_page) (struct page *page, isolate_mode_t mode);
>
> What VM expects on isolate_page function of driver is to return *true*
> if driver isolates page successfully. On returing true, VM marks the page
> as PG_isolated so concurrent isolation in several CPUs skip the page
> for isolation. If a driver cannot isolate the page, it should return *false*.
>
> Once page is successfully isolated, VM uses page.lru fields so driver
> shouldn't expect to preserve values in that fields.
>
> 2. int (*migratepage) (struct address_space *mapping,
> 		struct page *newpage, struct page *oldpage, enum migrate_mode);
>
> After isolation, VM calls migratepage of driver with isolated page.
> The function of migratepage is to move content of the old page to new page
> and set up fields of struct page newpage. Keep in mind that you should
> clear PG_movable of oldpage via __ClearPageMovable under page_lock if you
> migrated the oldpage successfully and returns 0.
> If driver cannot migrate the page at the moment, driver can return -EAGAIN.
> On -EAGAIN, VM will retry page migration in a short time because VM interprets
> -EAGAIN as "temporal migration failure". On returning any error except -EAGAIN,
> VM will give up the page migration without retrying in this time.
>
> Driver shouldn't touch page.lru field VM using in the functions.
>
> 3. void (*putback_page)(struct page *);
>
> If migration fails on isolated page, VM should return the isolated page
> to the driver so VM calls driver's putback_page with migration failed page.
> In this function, driver should put the isolated page back to the own data
> structure.
>
> 4. non-lru movable page flags
>
> There are two page flags for supporting non-lru movable page.
>
> * PG_movable
>
> Driver should use the below function to make page movable under page_lock.
>
> 	void __SetPageMovable(struct page *page, struct address_space *mapping)
>
> It needs argument of address_space for registering migration family functions
> which will be called by VM. Exactly speaking, PG_movable is not a real flag of
> struct page. Rather than, VM reuses page->mapping's lower bits to represent it.
>
> 	#define PAGE_MAPPING_MOVABLE 0x2
> 	page->mapping = page->mapping | PAGE_MAPPING_MOVABLE;

Interesting, let's see how that works out...

Overal this looks much better than the last version I checked!

[...]

> @@ -357,29 +360,37 @@ PAGEFLAG(Idle, idle, PF_ANY)
>   * with the PAGE_MAPPING_ANON bit set to distinguish it.  See rmap.h.
>   *
>   * On an anonymous page in a VM_MERGEABLE area, if CONFIG_KSM is enabled,
> - * the PAGE_MAPPING_KSM bit may be set along with the PAGE_MAPPING_ANON bit;
> - * and then page->mapping points, not to an anon_vma, but to a private
> + * the PAGE_MAPPING_MOVABLE bit may be set along with the PAGE_MAPPING_ANON
> + * bit; and then page->mapping points, not to an anon_vma, but to a private
>   * structure which KSM associates with that merged page.  See ksm.h.
>   *
> - * PAGE_MAPPING_KSM without PAGE_MAPPING_ANON is currently never used.
> + * PAGE_MAPPING_KSM without PAGE_MAPPING_ANON is used for non-lru movable
> + * page and then page->mapping points a struct address_space.
>   *
>   * Please note that, confusingly, "page_mapping" refers to the inode
>   * address_space which maps the page from disk; whereas "page_mapped"
>   * refers to user virtual address space into which the page is mapped.
>   */
> -#define PAGE_MAPPING_ANON	1
> -#define PAGE_MAPPING_KSM	2
> -#define PAGE_MAPPING_FLAGS	(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM)
> +#define PAGE_MAPPING_ANON	0x1
> +#define PAGE_MAPPING_MOVABLE	0x2
> +#define PAGE_MAPPING_KSM	(PAGE_MAPPING_ANON | PAGE_MAPPING_MOVABLE)
> +#define PAGE_MAPPING_FLAGS	(PAGE_MAPPING_ANON | PAGE_MAPPING_MOVABLE)
>
> -static __always_inline int PageAnonHead(struct page *page)
> +static __always_inline int PageMappingFlag(struct page *page)

PageMappingFlags()?

[...]

> diff --git a/mm/compaction.c b/mm/compaction.c
> index 1427366ad673..2d6862d0df60 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -81,6 +81,41 @@ static inline bool migrate_async_suitable(int migratetype)
>
>  #ifdef CONFIG_COMPACTION
>
> +int PageMovable(struct page *page)
> +{
> +	struct address_space *mapping;
> +
> +	WARN_ON(!PageLocked(page));

Why not VM_BUG_ON_PAGE as elsewhere?

> +	if (!__PageMovable(page))
> +		goto out;

Just return 0.

> +
> +	mapping = page_mapping(page);
> +	if (mapping && mapping->a_ops && mapping->a_ops->isolate_page)
> +		return 1;
> +out:
> +	return 0;
> +}
> +EXPORT_SYMBOL(PageMovable);
> +
> +void __SetPageMovable(struct page *page, struct address_space *mapping)
> +{
> +	VM_BUG_ON_PAGE(!PageLocked(page), page);
> +	VM_BUG_ON_PAGE((unsigned long)mapping & PAGE_MAPPING_MOVABLE, page);
> +	page->mapping = (void *)((unsigned long)mapping | PAGE_MAPPING_MOVABLE);
> +}
> +EXPORT_SYMBOL(__SetPageMovable);
> +
> +void __ClearPageMovable(struct page *page)
> +{
> +	VM_BUG_ON_PAGE(!PageLocked(page), page);
> +	VM_BUG_ON_PAGE(!PageMovable(page), page);
> +	VM_BUG_ON_PAGE(!((unsigned long)page->mapping & PAGE_MAPPING_MOVABLE),
> +				page);

The last line sounds redundant, PageMovable() already checked this via 
__PageMovable()


> +	page->mapping = (void *)((unsigned long)page->mapping &
> +				PAGE_MAPPING_MOVABLE);

This should be negated to clear... use ~PAGE_MAPPING_MOVABLE ?

> +}
> +EXPORT_SYMBOL(__ClearPageMovable);
> +
>  /* Do not skip compaction more than 64 times */
>  #define COMPACT_MAX_DEFER_SHIFT 6
>
> @@ -735,21 +770,6 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>  		}
>
>  		/*
> -		 * Check may be lockless but that's ok as we recheck later.
> -		 * It's possible to migrate LRU pages and balloon pages
> -		 * Skip any other type of page
> -		 */
> -		is_lru = PageLRU(page);
> -		if (!is_lru) {
> -			if (unlikely(balloon_page_movable(page))) {
> -				if (balloon_page_isolate(page)) {
> -					/* Successfully isolated */
> -					goto isolate_success;
> -				}
> -			}
> -		}

So this effectively prevents movable compound pages from being migrated. Are you 
sure no users of this functionality are going to have compound pages? I assumed 
that they could, and so made the code like this, with the is_lru variable (which 
is redundant after your change).

> -		/*
>  		 * Regardless of being on LRU, compound pages such as THP and
>  		 * hugetlbfs are not to be compacted. We can potentially save
>  		 * a lot of iterations if we skip them at once. The check is
> @@ -765,8 +785,38 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>  			goto isolate_fail;
>  		}
>
> -		if (!is_lru)
> +		/*
> +		 * Check may be lockless but that's ok as we recheck later.
> +		 * It's possible to migrate LRU and non-lru movable pages.
> +		 * Skip any other type of page
> +		 */
> +		is_lru = PageLRU(page);
> +		if (!is_lru) {
> +			if (unlikely(balloon_page_movable(page))) {
> +				if (balloon_page_isolate(page)) {
> +					/* Successfully isolated */
> +					goto isolate_success;
> +				}
> +			}

[...]

> +bool isolate_movable_page(struct page *page, isolate_mode_t mode)
> +{
> +	struct address_space *mapping;
> +
> +	/*
> +	 * Avoid burning cycles with pages that are yet under __free_pages(),
> +	 * or just got freed under us.
> +	 *
> +	 * In case we 'win' a race for a movable page being freed under us and
> +	 * raise its refcount preventing __free_pages() from doing its job
> +	 * the put_page() at the end of this block will take care of
> +	 * release this page, thus avoiding a nasty leakage.
> +	 */
> +	if (unlikely(!get_page_unless_zero(page)))
> +		goto out;
> +
> +	/*
> +	 * Check PageMovable before holding a PG_lock because page's owner
> +	 * assumes anybody doesn't touch PG_lock of newly allocated page
> +	 * so unconditionally grapping the lock ruins page's owner side.
> +	 */
> +	if (unlikely(!__PageMovable(page)))
> +		goto out_putpage;
> +	/*
> +	 * As movable pages are not isolated from LRU lists, concurrent
> +	 * compaction threads can race against page migration functions
> +	 * as well as race against the releasing a page.
> +	 *
> +	 * In order to avoid having an already isolated movable page
> +	 * being (wrongly) re-isolated while it is under migration,
> +	 * or to avoid attempting to isolate pages being released,
> +	 * lets be sure we have the page lock
> +	 * before proceeding with the movable page isolation steps.
> +	 */
> +	if (unlikely(!trylock_page(page)))
> +		goto out_putpage;
> +
> +	if (!PageMovable(page) || PageIsolated(page))
> +		goto out_no_isolated;
> +
> +	mapping = page_mapping(page);

Hmm so on first tail page of a THP compound page, page->mapping will alias with 
compound_mapcount. That can easily have a value matching PageMovable flags and 
we'll proceed and start inspecting the compound head in page_mapping()... maybe 
it's not a big deal, or we better check and skip PageTail first, must think 
about it more...

[...]

> @@ -755,33 +844,69 @@ static int move_to_new_page(struct page *newpage, struct page *page,
>  				enum migrate_mode mode)
>  {
>  	struct address_space *mapping;
> -	int rc;
> +	int rc = -EAGAIN;
> +	bool is_lru = !__PageMovable(page);
>
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>  	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
>
>  	mapping = page_mapping(page);
> -	if (!mapping)
> -		rc = migrate_page(mapping, newpage, page, mode);
> -	else if (mapping->a_ops->migratepage)
> -		/*
> -		 * Most pages have a mapping and most filesystems provide a
> -		 * migratepage callback. Anonymous pages are part of swap
> -		 * space which also has its own migratepage callback. This
> -		 * is the most common path for page migration.
> -		 */
> -		rc = mapping->a_ops->migratepage(mapping, newpage, page, mode);
> -	else
> -		rc = fallback_migrate_page(mapping, newpage, page, mode);
> +	/*
> +	 * In case of non-lru page, it could be released after
> +	 * isolation step. In that case, we shouldn't try
> +	 * fallback migration which is designed for LRU pages.
> +	 */

Hmm but is_lru was determined from !__PageMovable() above, also well after the 
isolation step. So if the driver already released it, we wouldn't detect it? And 
this function is all under same page lock, so if __PageMovable was true above, 
so will be PageMovable below?

> +	if (unlikely(!is_lru)) {
> +		VM_BUG_ON_PAGE(!PageIsolated(page), page);
> +		if (!PageMovable(page)) {
> +			rc = MIGRATEPAGE_SUCCESS;
> +			__ClearPageIsolated(page);
> +			goto out;
> +		}
> +	}
> +
> +	if (likely(is_lru)) {
> +		if (!mapping)
> +			rc = migrate_page(mapping, newpage, page, mode);
> +		else if (mapping->a_ops->migratepage)
> +			/*
> +			 * Most pages have a mapping and most filesystems
> +			 * provide a migratepage callback. Anonymous pages
> +			 * are part of swap space which also has its own
> +			 * migratepage callback. This is the most common path
> +			 * for page migration.
> +			 */
> +			rc = mapping->a_ops->migratepage(mapping, newpage,
> +							page, mode);
> +		else
> +			rc = fallback_migrate_page(mapping, newpage,
> +							page, mode);
> +	} else {
> +		rc = mapping->a_ops->migratepage(mapping, newpage,
> +						page, mode);
> +		WARN_ON_ONCE(rc == MIGRATEPAGE_SUCCESS &&
> +			!PageIsolated(page));
> +	}

Why split the !is_lru handling in two places?

>
>  	/*
>  	 * When successful, old pagecache page->mapping must be cleared before
>  	 * page is freed; but stats require that PageAnon be left as PageAnon.
>  	 */
>  	if (rc == MIGRATEPAGE_SUCCESS) {
> -		if (!PageAnon(page))
> +		if (__PageMovable(page)) {
> +			VM_BUG_ON_PAGE(!PageIsolated(page), page);
> +
> +			/*
> +			 * We clear PG_movable under page_lock so any compactor
> +			 * cannot try to migrate this page.
> +			 */
> +			__ClearPageIsolated(page);
> +		}
> +
> +		if (!((unsigned long)page->mapping & PAGE_MAPPING_FLAGS))
>  			page->mapping = NULL;

The two lines above make little sense to me without a comment. Should the 
condition be negated, even?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
