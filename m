Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 00E4D6B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 14:34:14 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id xy5so28441021wjc.0
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 11:34:13 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m7si3884228wme.134.2016.11.29.11.34.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 11:34:12 -0800 (PST)
Date: Tue, 29 Nov 2016 14:34:03 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/6] mm: Invalidate DAX radix tree entries only if
 appropriate
Message-ID: <20161129193403.GA12396@cmpxchg.org>
References: <1479980796-26161-1-git-send-email-jack@suse.cz>
 <1479980796-26161-3-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1479980796-26161-3-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

Hi Jan,

On Thu, Nov 24, 2016 at 10:46:32AM +0100, Jan Kara wrote:
> @@ -452,16 +452,37 @@ void dax_wake_mapping_entry_waiter(struct address_space *mapping,
>  		__wake_up(wq, TASK_NORMAL, wake_all ? 0 : 1, &key);
>  }
>  
> +static int __dax_invalidate_mapping_entry(struct address_space *mapping,
> +					  pgoff_t index, bool trunc)
> +{
> +	int ret = 0;
> +	void *entry;
> +	struct radix_tree_root *page_tree = &mapping->page_tree;
> +
> +	spin_lock_irq(&mapping->tree_lock);
> +	entry = get_unlocked_mapping_entry(mapping, index, NULL);
> +	if (!entry || !radix_tree_exceptional_entry(entry))
> +		goto out;
> +	if (!trunc &&
> +	    (radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_DIRTY) ||
> +	     radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_TOWRITE)))
> +		goto out;
> +	radix_tree_delete(page_tree, index);

You could use the new __radix_tree_replace() here and save a second
tree lookup.

> +/*
> + * Invalidate exceptional DAX entry if easily possible. This handles DAX
> + * entries for invalidate_inode_pages() so we evict the entry only if we can
> + * do so without blocking.
> + */
> +int dax_invalidate_mapping_entry(struct address_space *mapping, pgoff_t index)
> +{
> +	int ret = 0;
> +	void *entry, **slot;
> +	struct radix_tree_root *page_tree = &mapping->page_tree;
> +
> +	spin_lock_irq(&mapping->tree_lock);
> +	entry = __radix_tree_lookup(page_tree, index, NULL, &slot);
> +	if (!entry || !radix_tree_exceptional_entry(entry) ||
> +	    slot_locked(mapping, slot))
> +		goto out;
> +	if (radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_DIRTY) ||
> +	    radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_TOWRITE))
> +		goto out;
> +	radix_tree_delete(page_tree, index);

Ditto for __radix_tree_replace().

> @@ -30,14 +30,6 @@ static void clear_exceptional_entry(struct address_space *mapping,
>  	struct radix_tree_node *node;
>  	void **slot;
>  
> -	/* Handled by shmem itself */
> -	if (shmem_mapping(mapping))
> -		return;
> -
> -	if (dax_mapping(mapping)) {
> -		dax_delete_mapping_entry(mapping, index);
> -		return;
> -	}
>  	spin_lock_irq(&mapping->tree_lock);
>  	/*
>  	 * Regular page slots are stabilized by the page lock even
> @@ -70,6 +62,56 @@ static void clear_exceptional_entry(struct address_space *mapping,
>  	spin_unlock_irq(&mapping->tree_lock);
>  }
>  
> +/*
> + * Unconditionally remove exceptional entry. Usually called from truncate path.
> + */
> +static void truncate_exceptional_entry(struct address_space *mapping,
> +				       pgoff_t index, void *entry)
> +{
> +	/* Handled by shmem itself */
> +	if (shmem_mapping(mapping))
> +		return;
> +
> +	if (dax_mapping(mapping)) {
> +		dax_delete_mapping_entry(mapping, index);
> +		return;
> +	}
> +	clear_exceptional_entry(mapping, index, entry);
> +}
> +
> +/*
> + * Invalidate exceptional entry if easily possible. This handles exceptional
> + * entries for invalidate_inode_pages() so for DAX it evicts only unlocked and
> + * clean entries.
> + */
> +static int invalidate_exceptional_entry(struct address_space *mapping,
> +					pgoff_t index, void *entry)
> +{
> +	/* Handled by shmem itself */
> +	if (shmem_mapping(mapping))
> +		return 1;
> +	if (dax_mapping(mapping))
> +		return dax_invalidate_mapping_entry(mapping, index);
> +	clear_exceptional_entry(mapping, index, entry);
> +	return 1;
> +}
> +
> +/*
> + * Invalidate exceptional entry if clean. This handles exceptional entries for
> + * invalidate_inode_pages2() so for DAX it evicts only clean entries.
> + */
> +static int invalidate_exceptional_entry2(struct address_space *mapping,
> +					 pgoff_t index, void *entry)
> +{
> +	/* Handled by shmem itself */
> +	if (shmem_mapping(mapping))
> +		return 1;
> +	if (dax_mapping(mapping))
> +		return dax_invalidate_clean_mapping_entry(mapping, index);
> +	clear_exceptional_entry(mapping, index, entry);
> +	return 1;
> +}

The way these functions are split out looks fine to me.

Now that clear_exceptional_entry() doesn't handle shmem and DAX
anymore, only shadows, could you rename it to clear_shadow_entry()?

The naming situation with truncate, invalidate, invalidate2 worries me
a bit. They aren't great names to begin with, but now DAX uses yet
another terminology for what state prevents a page from being dropped.
Can we switch to truncate, invalidate, and invalidate_sync throughout
truncate.c and then have DAX follow that naming too? Or maybe you can
think of better names. But neither invalidate2 and invalidate_clean
don't seem to capture it quite right ;)

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
