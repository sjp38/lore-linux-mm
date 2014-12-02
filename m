Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id B73276B0069
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 06:57:00 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id bs8so29627821wib.3
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 03:57:00 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id bk9si34670032wjc.109.2014.12.02.03.56.59
        for <linux-mm@kvack.org>;
        Tue, 02 Dec 2014 03:56:59 -0800 (PST)
Date: Tue, 2 Dec 2014 13:56:52 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [patch 1/3] mm: protect set_page_dirty() from ongoing truncation
Message-ID: <20141202115652.GB22683@node.dhcp.inet.fi>
References: <1417474682-29326-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417474682-29326-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Dec 01, 2014 at 05:58:00PM -0500, Johannes Weiner wrote:
> Tejun, while reviewing the code, spotted the following race condition
> between the dirtying and truncation of a page:
> 
> __set_page_dirty_nobuffers()       __delete_from_page_cache()
>   if (TestSetPageDirty(page))
>                                      page->mapping = NULL
> 				     if (PageDirty())
> 				       dec_zone_page_state(page, NR_FILE_DIRTY);
> 				       dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
>     if (page->mapping)
>       account_page_dirtied(page)
>         __inc_zone_page_state(page, NR_FILE_DIRTY);
> 	__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
> 
> which results in an imbalance of NR_FILE_DIRTY and BDI_RECLAIMABLE.
> 
> Dirtiers usually lock out truncation, either by holding the page lock
> directly, or in case of zap_pte_range(), by pinning the mapcount with
> the page table lock held.  The notable exception to this rule, though,
> is do_wp_page(), for which this race exists.  However, do_wp_page()
> already waits for a locked page to unlock before setting the dirty
> bit, in order to prevent a race where clear_page_dirty() misses the
> page bit in the presence of dirty ptes.  Upgrade that wait to a fully
> locked set_page_dirty() to also cover the situation explained above.
> 
> Afterwards, the code in set_page_dirty() dealing with a truncation
> race is no longer needed.  Remove it.
> 
> Reported-by: Tejun Heo <tj@kernel.org>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: <stable@vger.kernel.org>
> ---
>  include/linux/writeback.h |  1 -
>  mm/memory.c               | 26 ++++++++++++++++----------
>  mm/page-writeback.c       | 43 ++++++++++++-------------------------------
>  3 files changed, 28 insertions(+), 42 deletions(-)
> 
> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
> index a219be961c0a..00048339c23e 100644
> --- a/include/linux/writeback.h
> +++ b/include/linux/writeback.h
> @@ -177,7 +177,6 @@ int write_cache_pages(struct address_space *mapping,
>  		      struct writeback_control *wbc, writepage_t writepage,
>  		      void *data);
>  int do_writepages(struct address_space *mapping, struct writeback_control *wbc);
> -void set_page_dirty_balance(struct page *page);
>  void writeback_set_ratelimit(void);
>  void tag_pages_for_writeback(struct address_space *mapping,
>  			     pgoff_t start, pgoff_t end);
> diff --git a/mm/memory.c b/mm/memory.c
> index 3e503831e042..73220eb6e9e3 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2150,17 +2150,23 @@ reuse:
>  		if (!dirty_page)
>  			return ret;
>  
> -		/*
> -		 * Yes, Virginia, this is actually required to prevent a race
> -		 * with clear_page_dirty_for_io() from clearing the page dirty
> -		 * bit after it clear all dirty ptes, but before a racing
> -		 * do_wp_page installs a dirty pte.
> -		 *
> -		 * do_shared_fault is protected similarly.
> -		 */
>  		if (!page_mkwrite) {
> -			wait_on_page_locked(dirty_page);
> -			set_page_dirty_balance(dirty_page);
> +			struct address_space *mapping;
> +			int dirtied;
> +
> +			lock_page(dirty_page);
> +			dirtied = set_page_dirty(dirty_page);
> +			mapping = dirty_page->mapping;

At first, I wanted to ask why you don't use page_mapping() here, but after
a bit of digging I see we cannot get here with anon page.

Explicid VM_BUG_ON_PAGE(PageAnon(dirty_page), dirty_page); would be great.

Otherwise looks good to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
