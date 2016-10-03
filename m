Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6530E6B0253
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 05:37:34 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l138so86644662wmg.3
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 02:37:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i8si7014795wmg.61.2016.10.03.02.37.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Oct 2016 02:37:33 -0700 (PDT)
Date: Mon, 3 Oct 2016 11:37:32 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 06/12] dax: consistent variable naming for DAX entries
Message-ID: <20161003093732.GL6457@quack2.suse.cz>
References: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
 <1475189370-31634-7-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475189370-31634-7-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Thu 29-09-16 16:49:24, Ross Zwisler wrote:
> No functional change.
> 
> Consistently use the variable name 'entry' instead of 'ret' for DAX radix
> tree entries.  This was already happening in most of the code, so update
> get_unlocked_mapping_entry(), grab_mapping_entry() and
> dax_unlock_mapping_entry().
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/dax.c | 34 +++++++++++++++++-----------------
>  1 file changed, 17 insertions(+), 17 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index ac28cdf..baef586 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -357,7 +357,7 @@ static inline void *unlock_slot(struct address_space *mapping, void **slot)
>  static void *get_unlocked_mapping_entry(struct address_space *mapping,
>  					pgoff_t index, void ***slotp)
>  {
> -	void *ret, **slot;
> +	void *entry, **slot;
>  	struct wait_exceptional_entry_queue ewait;
>  	wait_queue_head_t *wq = dax_entry_waitqueue(mapping, index);
>  
> @@ -367,13 +367,13 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
>  	ewait.key.index = index;
>  
>  	for (;;) {
> -		ret = __radix_tree_lookup(&mapping->page_tree, index, NULL,
> +		entry = __radix_tree_lookup(&mapping->page_tree, index, NULL,
>  					  &slot);
> -		if (!ret || !radix_tree_exceptional_entry(ret) ||
> +		if (!entry || !radix_tree_exceptional_entry(entry) ||
>  		    !slot_locked(mapping, slot)) {
>  			if (slotp)
>  				*slotp = slot;
> -			return ret;
> +			return entry;
>  		}
>  		prepare_to_wait_exclusive(wq, &ewait.wait,
>  					  TASK_UNINTERRUPTIBLE);
> @@ -396,13 +396,13 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
>   */
>  static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index)
>  {
> -	void *ret, **slot;
> +	void *entry, **slot;
>  
>  restart:
>  	spin_lock_irq(&mapping->tree_lock);
> -	ret = get_unlocked_mapping_entry(mapping, index, &slot);
> +	entry = get_unlocked_mapping_entry(mapping, index, &slot);
>  	/* No entry for given index? Make sure radix tree is big enough. */
> -	if (!ret) {
> +	if (!entry) {
>  		int err;
>  
>  		spin_unlock_irq(&mapping->tree_lock);
> @@ -410,10 +410,10 @@ restart:
>  				mapping_gfp_mask(mapping) & ~__GFP_HIGHMEM);
>  		if (err)
>  			return ERR_PTR(err);
> -		ret = (void *)(RADIX_TREE_EXCEPTIONAL_ENTRY |
> +		entry = (void *)(RADIX_TREE_EXCEPTIONAL_ENTRY |
>  			       RADIX_DAX_ENTRY_LOCK);
>  		spin_lock_irq(&mapping->tree_lock);
> -		err = radix_tree_insert(&mapping->page_tree, index, ret);
> +		err = radix_tree_insert(&mapping->page_tree, index, entry);
>  		radix_tree_preload_end();
>  		if (err) {
>  			spin_unlock_irq(&mapping->tree_lock);
> @@ -425,11 +425,11 @@ restart:
>  		/* Good, we have inserted empty locked entry into the tree. */
>  		mapping->nrexceptional++;
>  		spin_unlock_irq(&mapping->tree_lock);
> -		return ret;
> +		return entry;
>  	}
>  	/* Normal page in radix tree? */
> -	if (!radix_tree_exceptional_entry(ret)) {
> -		struct page *page = ret;
> +	if (!radix_tree_exceptional_entry(entry)) {
> +		struct page *page = entry;
>  
>  		get_page(page);
>  		spin_unlock_irq(&mapping->tree_lock);
> @@ -442,9 +442,9 @@ restart:
>  		}
>  		return page;
>  	}
> -	ret = lock_slot(mapping, slot);
> +	entry = lock_slot(mapping, slot);
>  	spin_unlock_irq(&mapping->tree_lock);
> -	return ret;
> +	return entry;
>  }
>  
>  void dax_wake_mapping_entry_waiter(struct address_space *mapping,
> @@ -469,11 +469,11 @@ void dax_wake_mapping_entry_waiter(struct address_space *mapping,
>  
>  void dax_unlock_mapping_entry(struct address_space *mapping, pgoff_t index)
>  {
> -	void *ret, **slot;
> +	void *entry, **slot;
>  
>  	spin_lock_irq(&mapping->tree_lock);
> -	ret = __radix_tree_lookup(&mapping->page_tree, index, NULL, &slot);
> -	if (WARN_ON_ONCE(!ret || !radix_tree_exceptional_entry(ret) ||
> +	entry = __radix_tree_lookup(&mapping->page_tree, index, NULL, &slot);
> +	if (WARN_ON_ONCE(!entry || !radix_tree_exceptional_entry(entry) ||
>  			 !slot_locked(mapping, slot))) {
>  		spin_unlock_irq(&mapping->tree_lock);
>  		return;
> -- 
> 2.7.4
> 
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
