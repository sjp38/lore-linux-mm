Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D5DB6B0038
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 05:14:52 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id g124so165433123qkd.1
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 02:14:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id tj3si24379906wjb.290.2016.08.16.02.14.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Aug 2016 02:14:51 -0700 (PDT)
Date: Tue, 16 Aug 2016 11:14:50 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 4/7] dax: rename 'ret' to 'entry' in grab_mapping_entry
Message-ID: <20160816091450.GD27284@quack2.suse.cz>
References: <20160815190918.20672-1-ross.zwisler@linux.intel.com>
 <20160815190918.20672-5-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160815190918.20672-5-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Mon 15-08-16 13:09:15, Ross Zwisler wrote:
> No functional change.
> 
> Everywhere else that we get entries via get_unlocked_mapping_entry(), we
> save it in 'entry' variables.  Just change this to be more descriptive.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/dax.c | 20 ++++++++++----------
>  1 file changed, 10 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index 8030f93..fed6a52 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -394,13 +394,13 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
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
> @@ -408,10 +408,10 @@ restart:
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
> @@ -423,11 +423,11 @@ restart:
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
> @@ -440,9 +440,9 @@ restart:
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
> -- 
> 2.9.0
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
