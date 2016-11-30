Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D0B7E6B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 03:08:46 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id o2so23812128wje.5
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 00:08:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m70si5862917wmg.143.2016.11.30.00.08.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Nov 2016 00:08:45 -0800 (PST)
Date: Wed, 30 Nov 2016 09:08:41 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/6] mm: Invalidate DAX radix tree entries only if
 appropriate
Message-ID: <20161130080841.GD16667@quack2.suse.cz>
References: <1479980796-26161-1-git-send-email-jack@suse.cz>
 <1479980796-26161-3-git-send-email-jack@suse.cz>
 <20161129193403.GA12396@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161129193403.GA12396@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

Hi Johannes,

On Tue 29-11-16 14:34:03, Johannes Weiner wrote:
> On Thu, Nov 24, 2016 at 10:46:32AM +0100, Jan Kara wrote:
> > @@ -452,16 +452,37 @@ void dax_wake_mapping_entry_waiter(struct address_space *mapping,
> >  		__wake_up(wq, TASK_NORMAL, wake_all ? 0 : 1, &key);
> >  }
> >  
> > +static int __dax_invalidate_mapping_entry(struct address_space *mapping,
> > +					  pgoff_t index, bool trunc)
> > +{
> > +	int ret = 0;
> > +	void *entry;
> > +	struct radix_tree_root *page_tree = &mapping->page_tree;
> > +
> > +	spin_lock_irq(&mapping->tree_lock);
> > +	entry = get_unlocked_mapping_entry(mapping, index, NULL);
> > +	if (!entry || !radix_tree_exceptional_entry(entry))
> > +		goto out;
> > +	if (!trunc &&
> > +	    (radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_DIRTY) ||
> > +	     radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_TOWRITE)))
> > +		goto out;
> > +	radix_tree_delete(page_tree, index);
> 
> You could use the new __radix_tree_replace() here and save a second
> tree lookup.

Hum, I'd need to return 'node' from get_unlocked_mapping_entry(). So
probably I'll do it in a patch separate from this fix. But thanks for
suggestion.

> > +/*
> > + * Invalidate exceptional DAX entry if easily possible. This handles DAX
> > + * entries for invalidate_inode_pages() so we evict the entry only if we can
> > + * do so without blocking.
> > + */
> > +int dax_invalidate_mapping_entry(struct address_space *mapping, pgoff_t index)
> > +{
> > +	int ret = 0;
> > +	void *entry, **slot;
> > +	struct radix_tree_root *page_tree = &mapping->page_tree;
> > +
> > +	spin_lock_irq(&mapping->tree_lock);
> > +	entry = __radix_tree_lookup(page_tree, index, NULL, &slot);
> > +	if (!entry || !radix_tree_exceptional_entry(entry) ||
> > +	    slot_locked(mapping, slot))
> > +		goto out;
> > +	if (radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_DIRTY) ||
> > +	    radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_TOWRITE))
> > +		goto out;
> > +	radix_tree_delete(page_tree, index);
> 
> Ditto for __radix_tree_replace().

Yes, here I can do it easily rightaway.

> > @@ -30,14 +30,6 @@ static void clear_exceptional_entry(struct address_space *mapping,
> >  	struct radix_tree_node *node;
> >  	void **slot;
> >  
> > -	/* Handled by shmem itself */
> > -	if (shmem_mapping(mapping))
> > -		return;
> > -
> > -	if (dax_mapping(mapping)) {
> > -		dax_delete_mapping_entry(mapping, index);
> > -		return;
> > -	}
> >  	spin_lock_irq(&mapping->tree_lock);
> >  	/*
> >  	 * Regular page slots are stabilized by the page lock even
> > @@ -70,6 +62,56 @@ static void clear_exceptional_entry(struct address_space *mapping,
> >  	spin_unlock_irq(&mapping->tree_lock);
> >  }
> >  
> > +/*
> > + * Unconditionally remove exceptional entry. Usually called from truncate path.
> > + */
> > +static void truncate_exceptional_entry(struct address_space *mapping,
> > +				       pgoff_t index, void *entry)
> > +{
> > +	/* Handled by shmem itself */
> > +	if (shmem_mapping(mapping))
> > +		return;
> > +
> > +	if (dax_mapping(mapping)) {
> > +		dax_delete_mapping_entry(mapping, index);
> > +		return;
> > +	}
> > +	clear_exceptional_entry(mapping, index, entry);
> > +}
> > +
> > +/*
> > + * Invalidate exceptional entry if easily possible. This handles exceptional
> > + * entries for invalidate_inode_pages() so for DAX it evicts only unlocked and
> > + * clean entries.
> > + */
> > +static int invalidate_exceptional_entry(struct address_space *mapping,
> > +					pgoff_t index, void *entry)
> > +{
> > +	/* Handled by shmem itself */
> > +	if (shmem_mapping(mapping))
> > +		return 1;
> > +	if (dax_mapping(mapping))
> > +		return dax_invalidate_mapping_entry(mapping, index);
> > +	clear_exceptional_entry(mapping, index, entry);
> > +	return 1;
> > +}
> > +
> > +/*
> > + * Invalidate exceptional entry if clean. This handles exceptional entries for
> > + * invalidate_inode_pages2() so for DAX it evicts only clean entries.
> > + */
> > +static int invalidate_exceptional_entry2(struct address_space *mapping,
> > +					 pgoff_t index, void *entry)
> > +{
> > +	/* Handled by shmem itself */
> > +	if (shmem_mapping(mapping))
> > +		return 1;
> > +	if (dax_mapping(mapping))
> > +		return dax_invalidate_clean_mapping_entry(mapping, index);
> > +	clear_exceptional_entry(mapping, index, entry);
> > +	return 1;
> > +}
> 
> The way these functions are split out looks fine to me.
> 
> Now that clear_exceptional_entry() doesn't handle shmem and DAX
> anymore, only shadows, could you rename it to clear_shadow_entry()?

Sure. Done.

> The naming situation with truncate, invalidate, invalidate2 worries me
> a bit. They aren't great names to begin with, but now DAX uses yet
> another terminology for what state prevents a page from being dropped.
> Can we switch to truncate, invalidate, and invalidate_sync throughout
> truncate.c and then have DAX follow that naming too? Or maybe you can
> think of better names. But neither invalidate2 and invalidate_clean
> don't seem to capture it quite right ;)

Yeah, the naming is confusing. I like the invalidate_sync proposal however
renaming invalidate_inode_pages2() to invalidate_inode_pages_sync() is a
larger undertaking - grep shows 51 places need to be changed. So I don't
want to do it in this patch set. I can call the function
dax_invalidate_mapping_entry_sync() if it makes you happier and do the rest
later... OK?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
