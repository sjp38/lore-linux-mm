Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 389556B0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 23:13:41 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id d1so117121qca.30
        for <linux-mm@kvack.org>; Thu, 21 Feb 2013 20:13:39 -0800 (PST)
Message-ID: <5126F06A.8010106@gmail.com>
Date: Fri, 22 Feb 2013 12:13:30 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] staging/zcache: Fix/improve zcache writeback code, tie
 to a config option
References: <1360175261-13287-1-git-send-email-dan.magenheimer@oracle.com>
In-Reply-To: <1360175261-13287-1-git-send-email-dan.magenheimer@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org

On 02/07/2013 02:27 AM, Dan Magenheimer wrote:
> It was observed by Andrea Arcangeli in 2011 that zcache can get "full"
> and there must be some way for compressed swap pages to be (uncompressed
> and then) sent through to the backing swap disk.  A prototype of this
> functionality, called "unuse", was added in 2012 as part of a major update
> to zcache (aka "zcache2"), but was left unfinished due to the unfortunate
> temporary fork of zcache.
>
> This earlier version of the code had an unresolved memory leak
> and was anyway dependent on not-yet-upstream frontswap and mm changes.
> The code was meanwhile adapted by Seth Jennings for similar
> functionality in zswap (which he calls "flush").  Seth also made some
> clever simplifications which are herein ported back to zcache.  As a
> result of those simplifications, the frontswap changes are no longer
> necessary, but a slightly different (and simpler) set of mm changes are
> still required [1].  The memory leak is also fixed.
>
> Due to feedback from akpm in a zswap thread, this functionality in zcache
> has now been renamed from "unuse" to "writeback".
>
> Although this zcache writeback code now works, there are open questions
> as how best to handle the policy that drives it.  As a result, this
> patch also ties writeback to a new config option.  And, since the
> code still depends on not-yet-upstreamed mm patches, to avoid build
> problems, the config option added by this patch temporarily depends
> on "BROKEN"; this config dependency can be removed in trees that
> contain the necessary mm patches.
>
> [1] https://lkml.org/lkml/2013/1/29/540/ https://lkml.org/lkml/2013/1/29/539/

shrink_zcache_memory:

while(nr_evict-- > 0) {
     page = zcache_evict_eph_pageframe();
     if (page == NULL)
         break;
     zcache_free_page(page);
}

zcache_evict_eph_pageframe
->zbud_evict_pageframe_lru
     ->zbud_evict_tmem
         ->tmem_flush_page
             ->zcache_pampd_free
                 ->zcache_free_page  <- zbudpage has already been free here

If the zcache_free_page called in shrink_zcache_memory can be treated as 
a double free?

>
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> ---
>   drivers/staging/zcache/Kconfig       |   17 ++
>   drivers/staging/zcache/zcache-main.c |  332 +++++++++++++++++++++++++++-------
>   2 files changed, 284 insertions(+), 65 deletions(-)
>
> diff --git a/drivers/staging/zcache/Kconfig b/drivers/staging/zcache/Kconfig
> index c1dbd04..7358270 100644
> --- a/drivers/staging/zcache/Kconfig
> +++ b/drivers/staging/zcache/Kconfig
> @@ -24,3 +24,20 @@ config RAMSTER
>   	  while minimizing total RAM across the cluster.  RAMster, like
>   	  zcache2, compresses swap pages into local RAM, but then remotifies
>   	  the compressed pages to another node in the RAMster cluster.
> +
> +# Depends on not-yet-upstreamed mm patches to export end_swap_bio_write and
> +# __add_to_swap_cache, and implement __swap_writepage (which is swap_writepage
> +# without the frontswap call. When these are in-tree, the dependency on
> +# BROKEN can be removed
> +config ZCACHE_WRITEBACK
> +	bool "Allow compressed swap pages to be writtenback to swap disk"
> +	depends on ZCACHE=y && BROKEN
> +	default n
> +	help
> +	  Zcache caches compressed swap pages (and other data) in RAM which
> +	  often improves performance by avoiding I/O's due to swapping.
> +	  In some workloads with very long-lived large processes, it can
> +	  instead reduce performance.  Writeback decompresses zcache-compressed
> +	  pages (in LRU order) when under memory pressure and writes them to
> +	  the backing swap disk to ameliorate this problem.  Policy driving
> +	  writeback is still under development.
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
> index c1ac905..5bf14c3 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -22,6 +22,10 @@
>   #include <linux/atomic.h>
>   #include <linux/math64.h>
>   #include <linux/crypto.h>
> +#include <linux/swap.h>
> +#include <linux/swapops.h>
> +#include <linux/pagemap.h>
> +#include <linux/writeback.h>
>   
>   #include <linux/cleancache.h>
>   #include <linux/frontswap.h>
> @@ -55,6 +59,9 @@ static inline void frontswap_tmem_exclusive_gets(bool b)
>   }
>   #endif
>   
> +/* enable (or fix code) when Seth's patches are accepted upstream */
> +#define zcache_writeback_enabled 0
> +
>   static int zcache_enabled __read_mostly;
>   static int disable_cleancache __read_mostly;
>   static int disable_frontswap __read_mostly;
> @@ -181,6 +188,8 @@ static unsigned long zcache_last_active_anon_pageframes;
>   static unsigned long zcache_last_inactive_anon_pageframes;
>   static unsigned long zcache_eph_nonactive_puts_ignored;
>   static unsigned long zcache_pers_nonactive_puts_ignored;
> +static unsigned long zcache_writtenback_pages;
> +static long zcache_outstanding_writeback_pages;
>   
>   #ifdef CONFIG_DEBUG_FS
>   #include <linux/debugfs.h>
> @@ -239,6 +248,9 @@ static int zcache_debugfs_init(void)
>   	zdfs64("eph_zbytes_max", S_IRUGO, root, &zcache_eph_zbytes_max);
>   	zdfs64("pers_zbytes", S_IRUGO, root, &zcache_pers_zbytes);
>   	zdfs64("pers_zbytes_max", S_IRUGO, root, &zcache_pers_zbytes_max);
> +	zdfs("outstanding_writeback_pages", S_IRUGO, root,
> +				&zcache_outstanding_writeback_pages);
> +	zdfs("writtenback_pages", S_IRUGO, root, &zcache_writtenback_pages);
>   	return 0;
>   }
>   #undef	zdebugfs
> @@ -285,6 +297,18 @@ void zcache_dump(void)
>   	pr_info("zcache: eph_zpages_max=%lu\n", zcache_eph_zpages_max);
>   	pr_info("zcache: pers_zpages=%lu\n", zcache_pers_zpages);
>   	pr_info("zcache: pers_zpages_max=%lu\n", zcache_pers_zpages_max);
> +	pr_info("zcache: last_active_file_pageframes=%lu\n",
> +				zcache_last_active_file_pageframes);
> +	pr_info("zcache: last_inactive_file_pageframes=%lu\n",
> +				zcache_last_inactive_file_pageframes);
> +	pr_info("zcache: last_active_anon_pageframes=%lu\n",
> +				zcache_last_active_anon_pageframes);
> +	pr_info("zcache: last_inactive_anon_pageframes=%lu\n",
> +				zcache_last_inactive_anon_pageframes);
> +	pr_info("zcache: eph_nonactive_puts_ignored=%lu\n",
> +				zcache_eph_nonactive_puts_ignored);
> +	pr_info("zcache: pers_nonactive_puts_ignored=%lu\n",
> +				zcache_pers_nonactive_puts_ignored);
>   	pr_info("zcache: eph_zbytes=%llu\n",
>   				(unsigned long long)zcache_eph_zbytes);
>   	pr_info("zcache: eph_zbytes_max=%llu\n",
> @@ -292,7 +316,10 @@ void zcache_dump(void)
>   	pr_info("zcache: pers_zbytes=%llu\n",
>   				(unsigned long long)zcache_pers_zbytes);
>   	pr_info("zcache: pers_zbytes_max=%llu\n",
> -			(unsigned long long)zcache_pers_zbytes_max);
> +				(unsigned long long)zcache_pers_zbytes_max);
> +	pr_info("zcache: outstanding_writeback_pages=%lu\n",
> +				zcache_outstanding_writeback_pages);
> +	pr_info("zcache: writtenback_pages=%lu\n", zcache_writtenback_pages);
>   }
>   #endif
>   
> @@ -449,14 +476,6 @@ static struct page *zcache_alloc_page(void)
>   	return page;
>   }
>   
> -#ifdef FRONTSWAP_HAS_UNUSE
> -static void zcache_unacct_page(void)
> -{
> -	zcache_pageframes_freed =
> -		atomic_inc_return(&zcache_pageframes_freed_atomic);
> -}
> -#endif
> -
>   static void zcache_free_page(struct page *page)
>   {
>   	long curr_pageframes;
> @@ -959,7 +978,7 @@ static struct page *zcache_evict_eph_pageframe(void)
>   					&zcache_eph_zbytes_atomic);
>   	zcache_eph_zpages = atomic_sub_return(zpages,
>   					&zcache_eph_zpages_atomic);
> -	zcache_evicted_eph_zpages++;
> +	zcache_evicted_eph_zpages += zpages;
>   	zcache_eph_pageframes =
>   		atomic_dec_return(&zcache_eph_pageframes_atomic);
>   	zcache_evicted_eph_pageframes++;
> @@ -967,77 +986,253 @@ out:
>   	return page;
>   }
>   
> -#ifdef FRONTSWAP_HAS_UNUSE
> +#ifdef CONFIG_ZCACHE_WRITEBACK
> +
> +static atomic_t zcache_outstanding_writeback_pages_atomic = ATOMIC_INIT(0);
> +
>   static void unswiz(struct tmem_oid oid, u32 index,
>   				unsigned *type, pgoff_t *offset);
>   
>   /*
> - *  Choose an LRU persistent pageframe and attempt to "unuse" it by
> - *  calling frontswap_unuse on both zpages.
> + *  Choose an LRU persistent pageframe and attempt to write it back to
> + *  the backing swap disk by calling frontswap_writeback on both zpages.
>    *
>    *  This is work-in-progress.
>    */
>   
> -static int zcache_frontswap_unuse(void)
> +static void zcache_end_swap_write(struct bio *bio, int err)
> +{
> +	end_swap_bio_write(bio, err);
> +	zcache_outstanding_writeback_pages =
> +	  atomic_dec_return(&zcache_outstanding_writeback_pages_atomic);
> +	zcache_writtenback_pages++;
> +}
> +
> +/*
> + * zcache_get_swap_cache_page
> + *
> + * This is an adaption of read_swap_cache_async()
> + *
> + * If success, page is returned in retpage
> + * Returns 0 if page was already in the swap cache, page is not locked
> + * Returns 1 if the new page needs to be populated, page is locked
> + */
> +static int zcache_get_swap_cache_page(int type, pgoff_t offset,
> +				struct page *new_page)
> +{
> +	struct page *found_page;
> +	swp_entry_t entry = swp_entry(type, offset);
> +	int err;
> +
> +	BUG_ON(new_page == NULL);
> +	do {
> +		/*
> +		 * First check the swap cache.  Since this is normally
> +		 * called after lookup_swap_cache() failed, re-calling
> +		 * that would confuse statistics.
> +		 */
> +		found_page = find_get_page(&swapper_space, entry.val);
> +		if (found_page)
> +			return 0;
> +
> +		/*
> +		 * call radix_tree_preload() while we can wait.
> +		 */
> +		err = radix_tree_preload(GFP_KERNEL);
> +		if (err)
> +			break;
> +
> +		/*
> +		 * Swap entry may have been freed since our caller observed it.
> +		 */
> +		err = swapcache_prepare(entry);
> +		if (err == -EEXIST) { /* seems racy */
> +			radix_tree_preload_end();
> +			continue;
> +		}
> +		if (err) { /* swp entry is obsolete ? */
> +			radix_tree_preload_end();
> +			break;
> +		}
> +
> +		/* May fail (-ENOMEM) if radix-tree node allocation failed. */
> +		__set_page_locked(new_page);
> +		SetPageSwapBacked(new_page);
> +		err = __add_to_swap_cache(new_page, entry);
> +		if (likely(!err)) {
> +			radix_tree_preload_end();
> +			lru_cache_add_anon(new_page);
> +			return 1;
> +		}
> +		radix_tree_preload_end();
> +		ClearPageSwapBacked(new_page);
> +		__clear_page_locked(new_page);
> +		/*
> +		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
> +		 * clear SWAP_HAS_CACHE flag.
> +		 */
> +		swapcache_free(entry, NULL);
> +		/* FIXME: is it possible to get here without err==-ENOMEM?
> +		 * If not, we can dispense with the do loop, use goto retry */
> +	} while (err != -ENOMEM);
> +
> +	return -ENOMEM;
> +}
> +
> +/*
> + * Given a frontswap zpage in zcache (identified by type/offset) and
> + * an empty page, put the page into the swap cache, use frontswap
> + * to get the page from zcache into the empty page, then give it
> + * to the swap subsystem to send to disk (carefully avoiding the
> + * possibility that frontswap might snatch it back).
> + * Returns < 0 if error, 0 if successful, and 1 if successful but
> + * the newpage passed in not needed and should be freed.
> + */
> +static int zcache_frontswap_writeback_zpage(int type, pgoff_t offset,
> +					struct page *newpage)
> +{
> +	struct page *page = newpage;
> +	int ret;
> +	struct writeback_control wbc = {
> +		.sync_mode = WB_SYNC_NONE,
> +	};
> +
> +	ret = zcache_get_swap_cache_page(type, offset, page);
> +	if (ret < 0)
> +		return ret;
> +	else if (ret == 0) {
> +		/* more uptodate page is already in swapcache */
> +		__frontswap_invalidate_page(type, offset);
> +		return 1;
> +	}
> +
> +	BUG_ON(!frontswap_has_exclusive_gets); /* load must also invalidate */
> +	/* FIXME: how is it possible to get here when page is unlocked? */
> +	__frontswap_load(page);
> +	SetPageUptodate(page);  /* above does SetPageDirty, is that enough? */
> +
> +	/* start writeback */
> +	SetPageReclaim(page);
> +	/*
> +	 * Return value is ignored here because it doesn't change anything
> +	 * for us.  Page is returned unlocked.
> +	 */
> +	(void)__swap_writepage(page, &wbc, zcache_end_swap_write);
> +	page_cache_release(page);
> +	zcache_outstanding_writeback_pages =
> +	    atomic_inc_return(&zcache_outstanding_writeback_pages_atomic);
> +
> +	return 0;
> +}
> +
> +/*
> + * The following is still a magic number... we want to allow forward progress
> + * for writeback because it clears out needed RAM when under pressure, but
> + * we don't want to allow writeback to absorb and queue too many GFP_KERNEL
> + * pages if the swap device is very slow.
> + */
> +#define ZCACHE_MAX_OUTSTANDING_WRITEBACK_PAGES 6400
> +
> +/*
> + * Try to allocate two free pages, first using a non-aggressive alloc,
> + * then by evicting zcache ephemeral (clean pagecache) pages, and last
> + * by aggressive GFP_KERNEL alloc.  We allow zbud to choose a pageframe
> + * consisting of 1-2 zbuds/zpages, then call the writeback_zpage helper
> + * function above for each.
> + */
> +static int zcache_frontswap_writeback(void)
>   {
>   	struct tmem_handle th[2];
> -	int ret = -ENOMEM;
> -	int nzbuds, unuse_ret;
> +	int ret = 0;
> +	int nzbuds, writeback_ret;
>   	unsigned type;
> -	struct page *newpage1 = NULL, *newpage2 = NULL;
> +	struct page *znewpage1 = NULL, *znewpage2 = NULL;
>   	struct page *evictpage1 = NULL, *evictpage2 = NULL;
> +	struct page *newpage1 = NULL, *newpage2 = NULL;
> +	struct page *page1 = NULL, *page2 = NULL;
>   	pgoff_t offset;
>   
> -	newpage1 = alloc_page(ZCACHE_GFP_MASK);
> -	newpage2 = alloc_page(ZCACHE_GFP_MASK);
> -	if (newpage1 == NULL)
> +	znewpage1 = alloc_page(ZCACHE_GFP_MASK);
> +	znewpage2 = alloc_page(ZCACHE_GFP_MASK);
> +	if (znewpage1 == NULL)
>   		evictpage1 = zcache_evict_eph_pageframe();
> -	if (newpage2 == NULL)
> +	if (znewpage2 == NULL)
>   		evictpage2 = zcache_evict_eph_pageframe();
> -	if (evictpage1 == NULL || evictpage2 == NULL)
> +
> +	if ((evictpage1 == NULL || evictpage2 == NULL) &&
> +	    atomic_read(&zcache_outstanding_writeback_pages_atomic) >
> +				ZCACHE_MAX_OUTSTANDING_WRITEBACK_PAGES) {
>   		goto free_and_out;
> -	/* ok, we have two pages pre-allocated */
> +	}
> +	if (znewpage1 == NULL && evictpage1 == NULL)
> +		newpage1 = alloc_page(GFP_KERNEL);
> +	if (znewpage2 == NULL && evictpage2 == NULL)
> +		newpage2 = alloc_page(GFP_KERNEL);
> +	if (newpage1 == NULL || newpage2 == NULL)
> +			goto free_and_out;
> +
> +	/* ok, we have two pageframes pre-allocated, get a pair of zbuds */
>   	nzbuds = zbud_make_zombie_lru(&th[0], NULL, NULL, false);
>   	if (nzbuds == 0) {
>   		ret = -ENOENT;
>   		goto free_and_out;
>   	}
> +
> +	/* process the first zbud */
>   	unswiz(th[0].oid, th[0].index, &type, &offset);
> -	unuse_ret = frontswap_unuse(type, offset,
> -				newpage1 != NULL ? newpage1 : evictpage1,
> -				ZCACHE_GFP_MASK);
> -	if (unuse_ret != 0)
> +	page1 = (znewpage1 != NULL) ? znewpage1 :
> +			((newpage1 != NULL) ? newpage1 : evictpage1);
> +	writeback_ret = zcache_frontswap_writeback_zpage(type, offset, page1);
> +	if (writeback_ret < 0) {
> +		ret = -ENOMEM;
>   		goto free_and_out;
> -	else if (evictpage1 != NULL)
> -		zcache_unacct_page();
> -	newpage1 = NULL;
> -	evictpage1 = NULL;
> -	if (nzbuds == 2) {
> -		unswiz(th[1].oid, th[1].index, &type, &offset);
> -		unuse_ret = frontswap_unuse(type, offset,
> -				newpage2 != NULL ? newpage2 : evictpage2,
> -				ZCACHE_GFP_MASK);
> -		if (unuse_ret != 0)
> -			goto free_and_out;
> -		else if (evictpage2 != NULL)
> -			zcache_unacct_page();
>   	}
> -	ret = 0;
> -	goto out;
> +	if (evictpage1 != NULL)
> +		zcache_pageframes_freed =
> +			atomic_inc_return(&zcache_pageframes_freed_atomic);
> +	if (writeback_ret == 0) {
> +		/* zcache_get_swap_cache_page will free, don't double free */
> +		znewpage1 = NULL;
> +		newpage1 = NULL;
> +		evictpage1 = NULL;
> +	}
> +	if (nzbuds < 2)
> +		goto free_and_out;
> +
> +	/* if there is a second zbud, process it */
> +	unswiz(th[1].oid, th[1].index, &type, &offset);
> +	page2 = (znewpage2 != NULL) ? znewpage2 :
> +			((newpage2 != NULL) ? newpage2 : evictpage2);
> +	writeback_ret = zcache_frontswap_writeback_zpage(type, offset, page2);
> +	if (writeback_ret < 0) {
> +		ret = -ENOMEM;
> +		goto free_and_out;
> +	}
> +	if (evictpage2 != NULL)
> +		zcache_pageframes_freed =
> +			atomic_inc_return(&zcache_pageframes_freed_atomic);
> +	if (writeback_ret == 0) {
> +		znewpage2 = NULL;
> +		newpage2 = NULL;
> +		evictpage2 = NULL;
> +	}
>   
>   free_and_out:
> +	if (znewpage1 != NULL)
> +		page_cache_release(znewpage1);
> +	if (znewpage2 != NULL)
> +		page_cache_release(znewpage2);
>   	if (newpage1 != NULL)
> -		__free_page(newpage1);
> +		page_cache_release(newpage1);
>   	if (newpage2 != NULL)
> -		__free_page(newpage2);
> +		page_cache_release(newpage2);
>   	if (evictpage1 != NULL)
>   		zcache_free_page(evictpage1);
>   	if (evictpage2 != NULL)
>   		zcache_free_page(evictpage2);
> -out:
>   	return ret;
>   }
> -#endif
> +#endif /* CONFIG_ZCACHE_WRITEBACK */
>   
>   /*
>    * When zcache is disabled ("frozen"), pools can be created and destroyed,
> @@ -1051,7 +1246,10 @@ static bool zcache_freeze;
>   /*
>    * This zcache shrinker interface reduces the number of ephemeral pageframes
>    * used by zcache to approximately the same as the total number of LRU_FILE
> - * pageframes in use.
> + * pageframes in use, and now also reduces the number of persistent pageframes
> + * used by zcache to approximately the same as the total number of LRU_ANON
> + * pageframes in use.  FIXME POLICY: Probably the writeback should only occur
> + * if the eviction doesn't free enough pages.
>    */
>   static int shrink_zcache_memory(struct shrinker *shrink,
>   				struct shrink_control *sc)
> @@ -1060,11 +1258,9 @@ static int shrink_zcache_memory(struct shrinker *shrink,
>   	int ret = -1;
>   	int nr = sc->nr_to_scan;
>   	int nr_evict = 0;
> -	int nr_unuse = 0;
> +	int nr_writeback = 0;
>   	struct page *page;
> -#ifdef FRONTSWAP_HAS_UNUSE
> -	int unuse_ret;
> -#endif
> +	int  file_pageframes_inuse, anon_pageframes_inuse;
>   
>   	if (nr <= 0)
>   		goto skip_evict;
> @@ -1080,8 +1276,12 @@ static int shrink_zcache_memory(struct shrinker *shrink,
>   		global_page_state(NR_LRU_BASE + LRU_ACTIVE_FILE);
>   	zcache_last_inactive_file_pageframes =
>   		global_page_state(NR_LRU_BASE + LRU_INACTIVE_FILE);
> -	nr_evict = zcache_eph_pageframes - zcache_last_active_file_pageframes +
> -		zcache_last_inactive_file_pageframes;
> +	file_pageframes_inuse = zcache_last_active_file_pageframes +
> +				zcache_last_inactive_file_pageframes;
> +	if (zcache_eph_pageframes > file_pageframes_inuse)
> +		nr_evict = zcache_eph_pageframes - file_pageframes_inuse;
> +	else
> +		nr_evict = 0;
>   	while (nr_evict-- > 0) {
>   		page = zcache_evict_eph_pageframe();
>   		if (page == NULL)
> @@ -1093,18 +1293,20 @@ static int shrink_zcache_memory(struct shrinker *shrink,
>   		global_page_state(NR_LRU_BASE + LRU_ACTIVE_ANON);
>   	zcache_last_inactive_anon_pageframes =
>   		global_page_state(NR_LRU_BASE + LRU_INACTIVE_ANON);
> -	nr_unuse = zcache_pers_pageframes - zcache_last_active_anon_pageframes +
> -		zcache_last_inactive_anon_pageframes;
> -#ifdef FRONTSWAP_HAS_UNUSE
> -	/* rate limit for testing */
> -	if (nr_unuse > 32)
> -		nr_unuse = 32;
> -	while (nr_unuse-- > 0) {
> -		unuse_ret = zcache_frontswap_unuse();
> -		if (unuse_ret == -ENOMEM)
> +	anon_pageframes_inuse = zcache_last_active_anon_pageframes +
> +				zcache_last_inactive_anon_pageframes;
> +	if (zcache_pers_pageframes > anon_pageframes_inuse)
> +		nr_writeback = zcache_pers_pageframes - anon_pageframes_inuse;
> +	else
> +		nr_writeback = 0;
> +	while (nr_writeback-- > 0) {
> +#ifdef CONFIG_ZCACHE_WRITEBACK
> +		int writeback_ret;
> +		writeback_ret = zcache_frontswap_writeback();
> +		if (writeback_ret == -ENOMEM)
> +#endif
>   			break;
>   	}
> -#endif
>   	in_progress = false;
>   
>   skip_evict:
> @@ -1345,7 +1547,7 @@ static int zcache_local_new_pool(uint32_t flags)
>   int zcache_autocreate_pool(unsigned int cli_id, unsigned int pool_id, bool eph)
>   {
>   	struct tmem_pool *pool;
> -	struct zcache_client *cli = NULL;
> +	struct zcache_client *cli;
>   	uint32_t flags = eph ? 0 : TMEM_POOL_PERSIST;
>   	int ret = -1;
>   
> @@ -1523,7 +1725,7 @@ static inline struct tmem_oid oswiz(unsigned type, u32 ind)
>   	return oid;
>   }
>   
> -#ifdef FRONTSWAP_HAS_UNUSE
> +#ifdef CONFIG_ZCACHE_WRITEBACK
>   static void unswiz(struct tmem_oid oid, u32 index,
>   				unsigned *type, pgoff_t *offset)
>   {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
