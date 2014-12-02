Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6BD096B006E
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 04:12:15 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id k14so16464785wgh.9
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 01:12:15 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z5si34071837wjx.127.2014.12.02.01.12.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Dec 2014 01:12:14 -0800 (PST)
Date: Tue, 2 Dec 2014 10:12:12 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [patch 1/3] mm: protect set_page_dirty() from ongoing truncation
Message-ID: <20141202091212.GB9092@quack.suse.cz>
References: <1417474682-29326-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417474682-29326-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 01-12-14 17:58:00, Johannes Weiner wrote:
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
> +			unlock_page(dirty_page);
> +
> +			if (dirtied && mapping) {
> +				/*
> +				 * Some device drivers do not set page.mapping
> +				 * but still dirty their pages
> +				 */
  The comment doesn't make sense to me here. Is it meant to explain why we
check 'mapping' in the above condition? I always thought truncate is the
main reason.

								Honza

-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
