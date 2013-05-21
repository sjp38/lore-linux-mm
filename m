Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id CA9916B0037
	for <linux-mm@kvack.org>; Tue, 21 May 2013 16:14:15 -0400 (EDT)
Message-ID: <519BD595.5040405@sr71.net>
Date: Tue, 21 May 2013 13:14:13 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv4 14/39] thp, mm: rewrite delete_from_page_cache() to
 support huge pages
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com> <1368321816-17719-15-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-15-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> As with add_to_page_cache_locked() we handle HPAGE_CACHE_NR pages a
> time.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/filemap.c |   31 +++++++++++++++++++++++++------
>  1 file changed, 25 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index b0c7c8c..657ce82 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -115,6 +115,9 @@
>  void __delete_from_page_cache(struct page *page)
>  {
>  	struct address_space *mapping = page->mapping;
> +	bool thp = PageTransHuge(page) &&
> +		IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE);
> +	int nr;

Is that check for the config option really necessary?  How would we get
a page with PageTransHuge() set without it being enabled?

>  	trace_mm_filemap_delete_from_page_cache(page);
>  	/*
> @@ -127,13 +130,29 @@ void __delete_from_page_cache(struct page *page)
>  	else
>  		cleancache_invalidate_page(mapping, page);
>  
> -	radix_tree_delete(&mapping->page_tree, page->index);
> +	if (thp) {
> +		int i;
> +
> +		nr = HPAGE_CACHE_NR;
> +		radix_tree_delete(&mapping->page_tree, page->index);
> +		for (i = 1; i < HPAGE_CACHE_NR; i++) {
> +			radix_tree_delete(&mapping->page_tree, page->index + i);
> +			page[i].mapping = NULL;
> +			page_cache_release(page + i);
> +		}
> +		__dec_zone_page_state(page, NR_FILE_TRANSPARENT_HUGEPAGES);
> +	} else {
> +		BUG_ON(PageTransHuge(page));
> +		nr = 1;
> +		radix_tree_delete(&mapping->page_tree, page->index);
> +	}
>  	page->mapping = NULL;

I like to rewrite your code. :)

	nr = hpage_nr_pages(page);
	for (i = 0; i < nr; i++) {
		page[i].mapping = NULL;
		radix_tree_delete(&mapping->page_tree, page->index + i);
		/* tail pages: */
		if (i)
			page_cache_release(page + i);
	}
	if (thp)
	     __dec_zone_page_state(page, NR_FILE_TRANSPARENT_HUGEPAGES);

I like this because it explicitly calls out the logic that tail pages
are different from head pages.  We handle their reference counts
differently.

Which reminds me...  Why do we handle their reference counts differently? :)

It seems like we could easily put a for loop in delete_from_page_cache()
that will release their reference counts along with the head page.
Wouldn't that make the code less special-cased for tail pages?

>  	/* Leave page->index set: truncation lookup relies upon it */
> -	mapping->nrpages--;
> -	__dec_zone_page_state(page, NR_FILE_PAGES);
> +	mapping->nrpages -= nr;
> +	__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, -nr);
>  	if (PageSwapBacked(page))
> -		__dec_zone_page_state(page, NR_SHMEM);
> +		__mod_zone_page_state(page_zone(page), NR_SHMEM, -nr);
>  	BUG_ON(page_mapped(page));

Man, we suck:

	__dec_zone_page_state()
and
	__mod_zone_page_state()

take a differently-typed first argument.  <sigh>

Would there be any good to making __dec_zone_page_state() check to see
if the page we passed in _is_ a compound page, and adjusting its
behaviour accordingly?

>  	/*
> @@ -144,8 +163,8 @@ void __delete_from_page_cache(struct page *page)
>  	 * having removed the page entirely.
>  	 */
>  	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
> -		dec_zone_page_state(page, NR_FILE_DIRTY);
> -		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
> +		mod_zone_page_state(page_zone(page), NR_FILE_DIRTY, -nr);
> +		add_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE, -nr);
>  	}
>  }

Ahh, I see now why you didn't need a dec_bdi_stat().  Oh well...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
