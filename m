Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id CBDA56B0036
	for <linux-mm@kvack.org>; Fri,  2 May 2014 09:16:30 -0400 (EDT)
Received: by mail-ee0-f54.google.com with SMTP id b57so1245286eek.27
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:16:30 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n46si1615734eeo.127.2014.05.02.06.16.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 06:16:28 -0700 (PDT)
Message-ID: <53639AA9.7050005@suse.cz>
Date: Fri, 02 May 2014 15:16:25 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch 1/2] mm, migration: add destination page freeing callback
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/01/2014 02:45 AM, David Rientjes wrote:
> Memory migration uses a callback defined by the caller to determine how to
> allocate destination pages.  When migration fails for a source page, however, it
> frees the destination page back to the system.
>
> This patch adds a memory migration callback defined by the caller to determine
> how to free destination pages.  If a caller, such as memory compaction, builds
> its own freelist for migration targets, this can reuse already freed memory
> instead of scanning additional memory.
>
> If the caller provides a function to handle freeing of destination pages, it is
> called when page migration fails.  Otherwise, it may pass NULL and freeing back
> to the system will be handled as usual.  This patch introduces no functional
> change.
>
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   include/linux/migrate.h | 11 ++++++----
>   mm/compaction.c         |  2 +-
>   mm/memory-failure.c     |  4 ++--
>   mm/memory_hotplug.c     |  2 +-
>   mm/mempolicy.c          |  4 ++--
>   mm/migrate.c            | 54 ++++++++++++++++++++++++++++++++-----------------
>   mm/page_alloc.c         |  2 +-
>   7 files changed, 50 insertions(+), 29 deletions(-)
>
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -5,7 +5,9 @@
>   #include <linux/mempolicy.h>
>   #include <linux/migrate_mode.h>
>
> -typedef struct page *new_page_t(struct page *, unsigned long private, int **);
> +typedef struct page *new_page_t(struct page *page, unsigned long private,
> +				int **reason);
> +typedef void free_page_t(struct page *page, unsigned long private);
>
>   /*
>    * Return values from addresss_space_operations.migratepage():
> @@ -38,7 +40,7 @@ enum migrate_reason {
>   extern void putback_movable_pages(struct list_head *l);
>   extern int migrate_page(struct address_space *,
>   			struct page *, struct page *, enum migrate_mode);
> -extern int migrate_pages(struct list_head *l, new_page_t x,
> +extern int migrate_pages(struct list_head *l, new_page_t new, free_page_t free,
>   		unsigned long private, enum migrate_mode mode, int reason);
>
>   extern int migrate_prep(void);
> @@ -56,8 +58,9 @@ extern int migrate_page_move_mapping(struct address_space *mapping,
>   #else
>
>   static inline void putback_movable_pages(struct list_head *l) {}
> -static inline int migrate_pages(struct list_head *l, new_page_t x,
> -		unsigned long private, enum migrate_mode mode, int reason)
> +static inline int migrate_pages(struct list_head *l, new_page_t new,
> +		free_page_t free, unsigned long private, enum migrate_mode mode,
> +		int reason)
>   	{ return -ENOSYS; }
>
>   static inline int migrate_prep(void) { return -ENOSYS; }
> diff --git a/mm/compaction.c b/mm/compaction.c
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1023,7 +1023,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>   		}
>
>   		nr_migrate = cc->nr_migratepages;
> -		err = migrate_pages(&cc->migratepages, compaction_alloc,
> +		err = migrate_pages(&cc->migratepages, compaction_alloc, NULL,
>   				(unsigned long)cc,
>   				cc->sync ? MIGRATE_SYNC_LIGHT : MIGRATE_ASYNC,
>   				MR_COMPACTION);
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1500,7 +1500,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
>
>   	/* Keep page count to indicate a given hugepage is isolated. */
>   	list_move(&hpage->lru, &pagelist);
> -	ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL,
> +	ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
>   				MIGRATE_SYNC, MR_MEMORY_FAILURE);
>   	if (ret) {
>   		pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
> @@ -1581,7 +1581,7 @@ static int __soft_offline_page(struct page *page, int flags)
>   		inc_zone_page_state(page, NR_ISOLATED_ANON +
>   					page_is_file_cache(page));
>   		list_add(&page->lru, &pagelist);
> -		ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL,
> +		ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
>   					MIGRATE_SYNC, MR_MEMORY_FAILURE);
>   		if (ret) {
>   			if (!list_empty(&pagelist)) {
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1332,7 +1332,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>   		 * alloc_migrate_target should be improooooved!!
>   		 * migrate_pages returns # of failed pages.
>   		 */
> -		ret = migrate_pages(&source, alloc_migrate_target, 0,
> +		ret = migrate_pages(&source, alloc_migrate_target, NULL, 0,
>   					MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
>   		if (ret)
>   			putback_movable_pages(&source);
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1028,7 +1028,7 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
>   			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
>
>   	if (!list_empty(&pagelist)) {
> -		err = migrate_pages(&pagelist, new_node_page, dest,
> +		err = migrate_pages(&pagelist, new_node_page, NULL, dest,
>   					MIGRATE_SYNC, MR_SYSCALL);
>   		if (err)
>   			putback_movable_pages(&pagelist);
> @@ -1277,7 +1277,7 @@ static long do_mbind(unsigned long start, unsigned long len,
>   		if (!list_empty(&pagelist)) {
>   			WARN_ON_ONCE(flags & MPOL_MF_LAZY);
>   			nr_failed = migrate_pages(&pagelist, new_vma_page,
> -					(unsigned long)vma,
> +					NULL, (unsigned long)vma,
>   					MIGRATE_SYNC, MR_MEMPOLICY_MBIND);
>   			if (nr_failed)
>   				putback_movable_pages(&pagelist);
> diff --git a/mm/migrate.c b/mm/migrate.c
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -938,8 +938,9 @@ out:
>    * Obtain the lock on page, remove all ptes and migrate the page
>    * to the newly allocated page in newpage.
>    */
> -static int unmap_and_move(new_page_t get_new_page, unsigned long private,
> -			struct page *page, int force, enum migrate_mode mode)
> +static int unmap_and_move(new_page_t get_new_page, free_page_t put_new_page,
> +			unsigned long private, struct page *page, int force,
> +			enum migrate_mode mode)
>   {
>   	int rc = 0;
>   	int *result = NULL;
> @@ -983,11 +984,12 @@ out:
>   				page_is_file_cache(page));
>   		putback_lru_page(page);
>   	}
> -	/*
> -	 * Move the new page to the LRU. If migration was not successful
> -	 * then this will free the page.
> -	 */
> -	putback_lru_page(newpage);
> +
> +	if (rc != MIGRATEPAGE_SUCCESS && put_new_page)
> +		put_new_page(newpage, private);
> +	else
> +		putback_lru_page(newpage);
> +
>   	if (result) {
>   		if (rc)
>   			*result = rc;
> @@ -1016,8 +1018,9 @@ out:
>    * will wait in the page fault for migration to complete.
>    */
>   static int unmap_and_move_huge_page(new_page_t get_new_page,
> -				unsigned long private, struct page *hpage,
> -				int force, enum migrate_mode mode)
> +				free_page_t put_new_page, unsigned long private,
> +				struct page *hpage, int force,
> +				enum migrate_mode mode)
>   {
>   	int rc = 0;
>   	int *result = NULL;
> @@ -1056,20 +1059,30 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
>   	if (!page_mapped(hpage))
>   		rc = move_to_new_page(new_hpage, hpage, 1, mode);
>
> -	if (rc)
> +	if (rc != MIGRATEPAGE_SUCCESS)
>   		remove_migration_ptes(hpage, hpage);
>
>   	if (anon_vma)
>   		put_anon_vma(anon_vma);
>
> -	if (!rc)
> +	if (rc == MIGRATEPAGE_SUCCESS)
>   		hugetlb_cgroup_migrate(hpage, new_hpage);
>
>   	unlock_page(hpage);
>   out:
>   	if (rc != -EAGAIN)
>   		putback_active_hugepage(hpage);
> -	put_page(new_hpage);
> +
> +	/*
> +	 * If migration was not successful and there's a freeing callback, use
> +	 * it.  Otherwise, put_page() will drop the reference grabbed during
> +	 * isolation.
> +	 */
> +	if (rc != MIGRATEPAGE_SUCCESS && put_new_page)
> +		put_new_page(new_hpage, private);
> +	else
> +		put_page(new_hpage);
> +
>   	if (result) {
>   		if (rc)
>   			*result = rc;
> @@ -1086,6 +1099,8 @@ out:
>    * @from:		The list of pages to be migrated.
>    * @get_new_page:	The function used to allocate free pages to be used
>    *			as the target of the page migration.
> + * @put_new_page:	The function used to free target pages if migration
> + *			fails, or NULL if no special handling is necessary.
>    * @private:		Private data to be passed on to get_new_page()
>    * @mode:		The migration mode that specifies the constraints for
>    *			page migration, if any.
> @@ -1099,7 +1114,8 @@ out:
>    * Returns the number of pages that were not migrated, or an error code.
>    */
>   int migrate_pages(struct list_head *from, new_page_t get_new_page,
> -		unsigned long private, enum migrate_mode mode, int reason)
> +		free_page_t put_new_page, unsigned long private,
> +		enum migrate_mode mode, int reason)
>   {
>   	int retry = 1;
>   	int nr_failed = 0;
> @@ -1121,10 +1137,11 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
>
>   			if (PageHuge(page))
>   				rc = unmap_and_move_huge_page(get_new_page,
> -						private, page, pass > 2, mode);
> +						put_new_page, private, page,
> +						pass > 2, mode);
>   			else
> -				rc = unmap_and_move(get_new_page, private,
> -						page, pass > 2, mode);
> +				rc = unmap_and_move(get_new_page, put_new_page,
> +						private, page, pass > 2, mode);
>
>   			switch(rc) {
>   			case -ENOMEM:
> @@ -1273,7 +1290,7 @@ set_status:
>
>   	err = 0;
>   	if (!list_empty(&pagelist)) {
> -		err = migrate_pages(&pagelist, new_page_node,
> +		err = migrate_pages(&pagelist, new_page_node, NULL,
>   				(unsigned long)pm, MIGRATE_SYNC, MR_SYSCALL);
>   		if (err)
>   			putback_movable_pages(&pagelist);
> @@ -1729,7 +1746,8 @@ int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
>
>   	list_add(&page->lru, &migratepages);
>   	nr_remaining = migrate_pages(&migratepages, alloc_misplaced_dst_page,
> -				     node, MIGRATE_ASYNC, MR_NUMA_MISPLACED);
> +				     NULL, node, MIGRATE_ASYNC,
> +				     MR_NUMA_MISPLACED);
>   	if (nr_remaining) {
>   		if (!list_empty(&migratepages)) {
>   			list_del(&page->lru);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6215,7 +6215,7 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
>   		cc->nr_migratepages -= nr_reclaimed;
>
>   		ret = migrate_pages(&cc->migratepages, alloc_migrate_target,
> -				    0, MIGRATE_SYNC, MR_CMA);
> +				    NULL, 0, MIGRATE_SYNC, MR_CMA);
>   	}
>   	if (ret < 0) {
>   		putback_movable_pages(&cc->migratepages);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
