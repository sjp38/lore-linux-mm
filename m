Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id B70B26B003B
	for <linux-mm@kvack.org>; Sun, 14 Jul 2013 19:48:29 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 15 Jul 2013 05:13:20 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id CD478394004D
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 05:18:19 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6ENn7xK12582914
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 05:19:07 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6ENmMXk007667
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 09:48:23 +1000
Date: Mon, 15 Jul 2013 07:48:21 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [v5][PATCH 2/6] mm: swap: make 'struct page' and swp_entry_t
 variants of swapcache_free().
Message-ID: <20130714234821.GB23628@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <20130603200202.7F5FDE07@viggo.jf.intel.com>
 <20130603200205.23A23517@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130603200205.23A23517@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com, minchan@kernel.org

On Mon, Jun 03, 2013 at 01:02:05PM -0700, Dave Hansen wrote:
>
>From: Dave Hansen <dave.hansen@linux.intel.com>
>
>swapcache_free() takes two arguments:
>
>	void swapcache_free(swp_entry_t entry, struct page *page)
>
>Most of its callers (5/7) are from error handling paths haven't
>even instantiated a page, so they pass page=NULL.  Both of the
>callers that call in with a 'struct page' create and pass in a
>temporary swp_entry_t.
>
>Now that we are deferring clearing page_private() until after
>swapcache_free() has been called, we can just create a variant
>that takes a 'struct page' and does the temporary variable in the
>helper.
>
>That leaves all the other callers doing
>
>	swapcache_free(entry, NULL)
>
>so create another helper for them that makes it clear that they
>need only pass in a swp_entry_t.
>
>One downside here is that delete_from_swap_cache() now calls
>swap_address_space() via page_mapping() instead of calling
>swap_address_space() directly.  In doing so, it removes one more
>case of the swap cache code being special-cased, which is a good
>thing in my book.  But it does cost us a function call.
>
>Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
>Acked-by: Mel Gorman <mgorman@suse.de>
>Reviewed-by: Minchan Kin <minchan@kernel.org>
>---

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>
> linux.git-davehans/drivers/staging/zcache/zcache-main.c |    2 +-
> linux.git-davehans/include/linux/swap.h                 |    3 ++-
> linux.git-davehans/mm/shmem.c                           |    2 +-
> linux.git-davehans/mm/swap_state.c                      |   15 +++++----------
> linux.git-davehans/mm/swapfile.c                        |   15 ++++++++++++++-
> linux.git-davehans/mm/vmscan.c                          |    5 +----
> 6 files changed, 24 insertions(+), 18 deletions(-)
>
>diff -puN drivers/staging/zcache/zcache-main.c~make-page-and-swp_entry_t-variants drivers/staging/zcache/zcache-main.c
>--- linux.git/drivers/staging/zcache/zcache-main.c~make-page-and-swp_entry_t-variants	2013-06-03 12:41:30.590715114 -0700
>+++ linux.git-davehans/drivers/staging/zcache/zcache-main.c	2013-06-03 12:41:30.602715646 -0700
>@@ -961,7 +961,7 @@ static int zcache_get_swap_cache_page(in
> 		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
> 		 * clear SWAP_HAS_CACHE flag.
> 		 */
>-		swapcache_free(entry, NULL);
>+		swapcache_free_entry(entry);
> 		/* FIXME: is it possible to get here without err==-ENOMEM?
> 		 * If not, we can dispense with the do loop, use goto retry */
> 	} while (err != -ENOMEM);
>diff -puN include/linux/swap.h~make-page-and-swp_entry_t-variants include/linux/swap.h
>--- linux.git/include/linux/swap.h~make-page-and-swp_entry_t-variants	2013-06-03 12:41:30.591715158 -0700
>+++ linux.git-davehans/include/linux/swap.h	2013-06-03 12:41:30.602715646 -0700
>@@ -385,7 +385,8 @@ extern void swap_shmem_alloc(swp_entry_t
> extern int swap_duplicate(swp_entry_t);
> extern int swapcache_prepare(swp_entry_t);
> extern void swap_free(swp_entry_t);
>-extern void swapcache_free(swp_entry_t, struct page *page);
>+extern void swapcache_free_entry(swp_entry_t entry);
>+extern void swapcache_free_page_entry(struct page *page);
> extern int free_swap_and_cache(swp_entry_t);
> extern int swap_type_of(dev_t, sector_t, struct block_device **);
> extern unsigned int count_swap_pages(int, int);
>diff -puN mm/shmem.c~make-page-and-swp_entry_t-variants mm/shmem.c
>--- linux.git/mm/shmem.c~make-page-and-swp_entry_t-variants	2013-06-03 12:41:30.593715247 -0700
>+++ linux.git-davehans/mm/shmem.c	2013-06-03 12:41:30.603715690 -0700
>@@ -872,7 +872,7 @@ static int shmem_writepage(struct page *
> 	}
>
> 	mutex_unlock(&shmem_swaplist_mutex);
>-	swapcache_free(swap, NULL);
>+	swapcache_free_entry(swap);
> redirty:
> 	set_page_dirty(page);
> 	if (wbc->for_reclaim)
>diff -puN mm/swapfile.c~make-page-and-swp_entry_t-variants mm/swapfile.c
>--- linux.git/mm/swapfile.c~make-page-and-swp_entry_t-variants	2013-06-03 12:41:30.595715336 -0700
>+++ linux.git-davehans/mm/swapfile.c	2013-06-03 12:41:30.604715734 -0700
>@@ -637,7 +637,7 @@ void swap_free(swp_entry_t entry)
> /*
>  * Called after dropping swapcache to decrease refcnt to swap entries.
>  */
>-void swapcache_free(swp_entry_t entry, struct page *page)
>+static void __swapcache_free(swp_entry_t entry, struct page *page)
> {
> 	struct swap_info_struct *p;
> 	unsigned char count;
>@@ -651,6 +651,19 @@ void swapcache_free(swp_entry_t entry, s
> 	}
> }
>
>+void swapcache_free_entry(swp_entry_t entry)
>+{
>+	__swapcache_free(entry, NULL);
>+}
>+
>+void swapcache_free_page_entry(struct page *page)
>+{
>+	swp_entry_t entry = { .val = page_private(page) };
>+	__swapcache_free(entry, page);
>+	set_page_private(page, 0);
>+	ClearPageSwapCache(page);
>+}
>+
> /*
>  * How many references to page are currently swapped out?
>  * This does not give an exact answer when swap count is continued,
>diff -puN mm/swap_state.c~make-page-and-swp_entry_t-variants mm/swap_state.c
>--- linux.git/mm/swap_state.c~make-page-and-swp_entry_t-variants	2013-06-03 12:41:30.596715380 -0700
>+++ linux.git-davehans/mm/swap_state.c	2013-06-03 12:41:30.605715778 -0700
>@@ -174,7 +174,7 @@ int add_to_swap(struct page *page, struc
>
> 	if (unlikely(PageTransHuge(page)))
> 		if (unlikely(split_huge_page_to_list(page, list))) {
>-			swapcache_free(entry, NULL);
>+			swapcache_free_entry(entry);
> 			return 0;
> 		}
>
>@@ -200,7 +200,7 @@ int add_to_swap(struct page *page, struc
> 		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
> 		 * clear SWAP_HAS_CACHE flag.
> 		 */
>-		swapcache_free(entry, NULL);
>+		swapcache_free_entry(entry);
> 		return 0;
> 	}
> }
>@@ -213,19 +213,14 @@ int add_to_swap(struct page *page, struc
>  */
> void delete_from_swap_cache(struct page *page)
> {
>-	swp_entry_t entry;
> 	struct address_space *address_space;
>
>-	entry.val = page_private(page);
>-
>-	address_space = swap_address_space(entry);
>+	address_space = page_mapping(page);
> 	spin_lock_irq(&address_space->tree_lock);
> 	__delete_from_swap_cache(page);
> 	spin_unlock_irq(&address_space->tree_lock);
>
>-	swapcache_free(entry, page);
>-	set_page_private(page, 0);
>-	ClearPageSwapCache(page);
>+	swapcache_free_page_entry(page);
> 	page_cache_release(page);
> }
>
>@@ -370,7 +365,7 @@ struct page *read_swap_cache_async(swp_e
> 		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
> 		 * clear SWAP_HAS_CACHE flag.
> 		 */
>-		swapcache_free(entry, NULL);
>+		swapcache_free_entry(entry);
> 	} while (err != -ENOMEM);
>
> 	if (new_page)
>diff -puN mm/vmscan.c~make-page-and-swp_entry_t-variants mm/vmscan.c
>--- linux.git/mm/vmscan.c~make-page-and-swp_entry_t-variants	2013-06-03 12:41:30.598715468 -0700
>+++ linux.git-davehans/mm/vmscan.c	2013-06-03 12:41:30.606715822 -0700
>@@ -490,12 +490,9 @@ static int __remove_mapping(struct addre
> 	}
>
> 	if (PageSwapCache(page)) {
>-		swp_entry_t swap = { .val = page_private(page) };
> 		__delete_from_swap_cache(page);
> 		spin_unlock_irq(&mapping->tree_lock);
>-		swapcache_free(swap, page);
>-		set_page_private(page, 0);
>-		ClearPageSwapCache(page);
>+		swapcache_free_page_entry(page);
> 	} else {
> 		void (*freepage)(struct page *);
>
>_
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
