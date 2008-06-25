Subject: Re: [-mm][PATCH 10/10] putback_lru_page()/unevictable page
	handling rework v4
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080625191014.D86A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080625185717.D84C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080625191014.D86A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain
Date: Wed, 25 Jun 2008 12:29:55 -0400
Message-Id: <1214411395.7010.34.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroy@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

I'm updating the unevictable-lru doc in Documentation/vm.
I have a question, below, on the removal of page_lock() from
__mlock_vma_pages_range().  The document discusses how we hold the page
lock when calling mlock_vma_page() to prevent races with migration
[addressed by putback_lru_page() rework] and truncation.  I'm wondering
if we're properly protected from truncation now...

On Wed, 2008-06-25 at 19:11 +0900, KOSAKI Motohiro wrote:
> 
> Changelog
> ================
> V3 -> V4
>    o fix broken recheck logic in putback_lru_page().
>    o fix shmem_lock() prototype.
> 
> V2 -> V3
>    o remove lock_page() from scan_mapping_unevictable_pages() and
>      scan_zone_unevictable_pages().
>    o revert ipc/shm.c mm/shmem.c change of SHMEM unevictable patch.
>      it become unnecessary by this patch.
> 
> V1 -> V2
>    o undo unintented comment killing.
>    o move putback_lru_page() from move_to_new_page() to unmap_and_move().
>    o folded depend patch
>        http://marc.info/?l=linux-mm&m=121337119621958&w=2
>        http://marc.info/?l=linux-kernel&m=121362782406478&w=2
>        http://marc.info/?l=linux-mm&m=121377572909776&w=2
> 
> 
> Now, putback_lru_page() requires that the page is locked.
> And in some special case, implicitly unlock it.
> 
> This patch tries to make putback_lru_pages() to be lock_page() free.
> (Of course, some callers must take the lock.)
> 
> The main reason that putback_lru_page() assumes that page is locked
> is to avoid the change in page's status among Mlocked/Not-Mlocked.
> 
> Once it is added to unevictable list, the page is removed from
> unevictable list only when page is munlocked. (there are other special
> case. but we ignore the special case.)
> So, status change during putback_lru_page() is fatal and page should 
> be locked.
> 
> putback_lru_page() in this patch has a new concepts.
> When it adds page to unevictable list, it checks the status is 
> changed or not again. if changed, retry to putback.
> 
> This patche changes also caller side and cleaning up lock/unlock_page().
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroy@jp.fujitsu.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> ---
>  include/linux/mm.h |    9 +---
>  ipc/shm.c          |   16 -------
>  mm/internal.h      |    2 
>  mm/migrate.c       |   60 +++++++++------------------
>  mm/mlock.c         |   51 +++++++++++++----------
>  mm/shmem.c         |    9 +---
>  mm/vmscan.c        |  114 +++++++++++++++++++++++------------------------------
>  7 files changed, 110 insertions(+), 151 deletions(-)
> 
> Index: b/mm/vmscan.c
> ===================================================================

<snip>

> Index: b/mm/mlock.c
> ===================================================================
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -55,21 +55,22 @@ EXPORT_SYMBOL(can_do_mlock);
>   */
>  void __clear_page_mlock(struct page *page)
>  {
> -	VM_BUG_ON(!PageLocked(page));	/* for LRU isolate/putback */
>  
>  	dec_zone_page_state(page, NR_MLOCK);
>  	count_vm_event(NORECL_PGCLEARED);
> -	if (!isolate_lru_page(page)) {
> -		putback_lru_page(page);
> -	} else {
> -		/*
> -		 * Page not on the LRU yet.  Flush all pagevecs and retry.
> -		 */
> -		lru_add_drain_all();
> -		if (!isolate_lru_page(page))
> +	if (page->mapping) {	/* truncated ? */
> +		if (!isolate_lru_page(page)) {
>  			putback_lru_page(page);
> -		else if (PageUnevictable(page))
> -			count_vm_event(NORECL_PGSTRANDED);
> +		} else {
> +			/*
> +			 *Page not on the LRU yet. Flush all pagevecs and retry.
> +			 */
> +			lru_add_drain_all();
> +			if (!isolate_lru_page(page))
> +				putback_lru_page(page);
> +			else if (PageUnevictable(page))
> +				count_vm_event(NORECL_PGSTRANDED);
> +		}
>  	}
>  }
>  
> @@ -79,7 +80,7 @@ void __clear_page_mlock(struct page *pag
>   */
>  void mlock_vma_page(struct page *page)
>  {
> -	BUG_ON(!PageLocked(page));
> +	VM_BUG_ON(!page->mapping);

If we're not holding the page locked here, can the page be truncated out
from under us?  If so, I think we could hit this BUG or, if we just miss
it, we could end up setting PageMlocked on a truncated page, and end up
freeing an mlocked page.

>  
>  	if (!TestSetPageMlocked(page)) {
>  		inc_zone_page_state(page, NR_MLOCK);
> @@ -109,7 +110,7 @@ void mlock_vma_page(struct page *page)
>   */
>  static void munlock_vma_page(struct page *page)
>  {
> -	BUG_ON(!PageLocked(page));
> +	VM_BUG_ON(!page->mapping);
>  
>  	if (TestClearPageMlocked(page)) {
>  		dec_zone_page_state(page, NR_MLOCK);
> @@ -169,7 +170,8 @@ static int __mlock_vma_pages_range(struc
>  
>  		/*
>  		 * get_user_pages makes pages present if we are
> -		 * setting mlock.
> +		 * setting mlock. and this extra reference count will
> +		 * disable migration of this page.
>  		 */
>  		ret = get_user_pages(current, mm, addr,
>  				min_t(int, nr_pages, ARRAY_SIZE(pages)),
> @@ -197,14 +199,8 @@ static int __mlock_vma_pages_range(struc
>  		for (i = 0; i < ret; i++) {
>  			struct page *page = pages[i];
>  
> -			/*
> -			 * page might be truncated or migrated out from under
> -			 * us.  Check after acquiring page lock.
> -			 */
> -			lock_page(page);
Safe to remove the locking?  I.e., page can't be truncated here?

> -			if (page->mapping)
> +			if (page_mapcount(page))
>  				mlock_vma_page(page);
> -			unlock_page(page);
>  			put_page(page);		/* ref from get_user_pages() */
>  
>  			/*
> @@ -240,6 +236,9 @@ static int __munlock_pte_handler(pte_t *
>  	struct page *page;
>  	pte_t pte;
>  
> +	/*
> +	 * page is never be unmapped by page-reclaim. we lock this page now.
> +	 */
>  retry:
>  	pte = *ptep;
>  	/*
> @@ -261,7 +260,15 @@ retry:
>  		goto out;
>  
>  	lock_page(page);
> -	if (!page->mapping) {
> +	/*
> +	 * Because we lock page here, we have to check 2 cases.
> +	 * - the page is migrated.
> +	 * - the page is truncated (file-cache only)
> +	 * Note: Anonymous page doesn't clear page->mapping even if it
> +	 * is removed from rmap.
> +	 */
> +	if (!page->mapping ||
> +	     (PageAnon(page) && !page_mapcount(page))) {
>  		unlock_page(page);
>  		goto retry;
>  	}
> Index: b/mm/migrate.c
> ===================================================================

<snip>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
