Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 9DF236B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 09:29:37 -0400 (EDT)
Date: Mon, 5 Aug 2013 15:29:34 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 19/23] truncate: support huge pages
Message-ID: <20130805132934.GC25691@quack.suse.cz>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1375582645-29274-20-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375582645-29274-20-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun 04-08-13 05:17:21, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> truncate_inode_pages_range() drops whole huge page at once if it's fully
> inside the range.
> 
> If a huge page is only partly in the range we zero out the part,
> exactly like we do for partial small pages.
> 
> invalidate_mapping_pages() just skips huge pages if they are not fully
> in the range.
  Umm, this is not a new problem but with THP pagecache it will become more
visible: When we punch holes within a file like <0..2MB>, <2MB-4MB>
(presuming 4 MB hugepages), then we won't free the underlying huge page for
the range 0..4MB. Maybe for initial implementation is doesn't matter but we
should at least note it in truncate_inode_pages_range() so that people are
aware of this.

Otherwise the patch looks OK to me. So you can add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/truncate.c | 108 +++++++++++++++++++++++++++++++++++++++++++++-------------
>  1 file changed, 84 insertions(+), 24 deletions(-)
> 
> diff --git a/mm/truncate.c b/mm/truncate.c
> index 353b683..fcef7cb 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -205,8 +205,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
>  {
>  	pgoff_t		start;		/* inclusive */
>  	pgoff_t		end;		/* exclusive */
> -	unsigned int	partial_start;	/* inclusive */
> -	unsigned int	partial_end;	/* exclusive */
> +	bool		partial_thp_start = false, partial_thp_end = false;
>  	struct pagevec	pvec;
>  	pgoff_t		index;
>  	int		i;
> @@ -215,15 +214,9 @@ void truncate_inode_pages_range(struct address_space *mapping,
>  	if (mapping->nrpages == 0)
>  		return;
>  
> -	/* Offsets within partial pages */
> -	partial_start = lstart & (PAGE_CACHE_SIZE - 1);
> -	partial_end = (lend + 1) & (PAGE_CACHE_SIZE - 1);
> -
>  	/*
>  	 * 'start' and 'end' always covers the range of pages to be fully
> -	 * truncated. Partial pages are covered with 'partial_start' at the
> -	 * start of the range and 'partial_end' at the end of the range.
> -	 * Note that 'end' is exclusive while 'lend' is inclusive.
> +	 * truncated. Note that 'end' is exclusive while 'lend' is inclusive.
>  	 */
>  	start = (lstart + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
>  	if (lend == -1)
> @@ -249,6 +242,23 @@ void truncate_inode_pages_range(struct address_space *mapping,
>  			if (index >= end)
>  				break;
>  
> +			if (PageTransTailCache(page)) {
> +				/* part of already handled huge page */
> +				if (!page->mapping)
> +					continue;
> +				/* the range starts in middle of huge page */
> +				partial_thp_start = true;
> +				start = index & ~HPAGE_CACHE_INDEX_MASK;
> +				continue;
> +			}
> +			/* the range ends on huge page */
> +			if (PageTransHugeCache(page) &&
> +				index == (end & ~HPAGE_CACHE_INDEX_MASK)) {
> +				partial_thp_end = true;
> +				end = index;
> +				break;
> +			}
> +
>  			if (!trylock_page(page))
>  				continue;
>  			WARN_ON(page->index != index);
> @@ -265,34 +275,74 @@ void truncate_inode_pages_range(struct address_space *mapping,
>  		index++;
>  	}
>  
> -	if (partial_start) {
> -		struct page *page = find_lock_page(mapping, start - 1);
> +	if (partial_thp_start || lstart & ~PAGE_CACHE_MASK) {
> +		pgoff_t off;
> +		struct page *page;
> +		unsigned pstart, pend;
> +		void (*zero_segment)(struct page *page,
> +				unsigned start, unsigned len);
> +retry_partial_start:
> +		if (partial_thp_start) {
> +			zero_segment = zero_huge_user_segment;
> +			off = (start - 1) & ~HPAGE_CACHE_INDEX_MASK;
> +			pstart = lstart & ~HPAGE_PMD_MASK;
> +			if ((end & ~HPAGE_CACHE_INDEX_MASK) == off)
> +				pend = (lend - 1) & ~HPAGE_PMD_MASK;
> +			else
> +				pend = HPAGE_PMD_SIZE;
> +		} else {
> +			zero_segment = zero_user_segment;
> +			off = start - 1;
> +			pstart = lstart & ~PAGE_CACHE_MASK;
> +			if (start > end)
> +				pend = (lend - 1) & ~PAGE_CACHE_MASK;
> +			else
> +				pend = PAGE_CACHE_SIZE;
> +		}
> +
> +		page = find_get_page(mapping, off);
>  		if (page) {
> -			unsigned int top = PAGE_CACHE_SIZE;
> -			if (start > end) {
> -				/* Truncation within a single page */
> -				top = partial_end;
> -				partial_end = 0;
> +			/* the last tail page*/
> +			if (PageTransTailCache(page)) {
> +				partial_thp_start = true;
> +				page_cache_release(page);
> +				goto retry_partial_start;
>  			}
> +
> +			lock_page(page);
>  			wait_on_page_writeback(page);
> -			zero_user_segment(page, partial_start, top);
> +			zero_segment(page, pstart, pend);
>  			cleancache_invalidate_page(mapping, page);
>  			if (page_has_private(page))
> -				do_invalidatepage(page, partial_start,
> -						  top - partial_start);
> +				do_invalidatepage(page, pstart,
> +						pend - pstart);
>  			unlock_page(page);
>  			page_cache_release(page);
>  		}
>  	}
> -	if (partial_end) {
> -		struct page *page = find_lock_page(mapping, end);
> +	if (partial_thp_end || (lend + 1) & ~PAGE_CACHE_MASK) {
> +		pgoff_t off;
> +		struct page *page;
> +		unsigned pend;
> +		void (*zero_segment)(struct page *page,
> +				unsigned start, unsigned len);
> +		if (partial_thp_end) {
> +			zero_segment = zero_huge_user_segment;
> +			off = end & ~HPAGE_CACHE_INDEX_MASK;
> +			pend = (lend - 1) & ~HPAGE_PMD_MASK;
> +		} else {
> +			zero_segment = zero_user_segment;
> +			off = end;
> +			pend = (lend - 1) & ~PAGE_CACHE_MASK;
> +		}
> +
> +		page = find_lock_page(mapping, end);
>  		if (page) {
>  			wait_on_page_writeback(page);
> -			zero_user_segment(page, 0, partial_end);
> +			zero_segment(page, 0, pend);
>  			cleancache_invalidate_page(mapping, page);
>  			if (page_has_private(page))
> -				do_invalidatepage(page, 0,
> -						  partial_end);
> +				do_invalidatepage(page, 0, pend);
>  			unlock_page(page);
>  			page_cache_release(page);
>  		}
> @@ -327,6 +377,9 @@ void truncate_inode_pages_range(struct address_space *mapping,
>  			if (index >= end)
>  				break;
>  
> +			if (PageTransTailCache(page))
> +				continue;
> +
>  			lock_page(page);
>  			WARN_ON(page->index != index);
>  			wait_on_page_writeback(page);
> @@ -401,6 +454,13 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
>  			if (index > end)
>  				break;
>  
> +			/* skip huge page if it's not fully in the range */
> +			if (PageTransHugeCache(page) &&
> +					index + HPAGE_CACHE_NR - 1 > end)
> +				continue;
> +			if (PageTransTailCache(page))
> +				continue;
> +
>  			if (!trylock_page(page))
>  				continue;
>  			WARN_ON(page->index != index);
> -- 
> 1.8.3.2
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
