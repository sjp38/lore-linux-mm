Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id F24B96B0038
	for <linux-mm@kvack.org>; Fri,  5 May 2017 03:29:19 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y106so4515925wrb.14
        for <linux-mm@kvack.org>; Fri, 05 May 2017 00:29:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b74si1780026wmb.146.2017.05.05.00.29.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 May 2017 00:29:18 -0700 (PDT)
Date: Fri, 5 May 2017 09:29:12 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 1/2] dax: prevent invalidation of mapped DAX entries
Message-ID: <20170505072912.GA25424@quack2.suse.cz>
References: <20170504195910.11579-1-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170504195910.11579-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Alexey Kuznetsov <kuznet@virtuozzo.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Anna Schumaker <anna.schumaker@netapp.com>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Van Hensbergen <ericvh@gmail.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Latchesar Ionkov <lucho@ionkov.net>, linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-nvdimm@lists.01.org, Matthew Wilcox <mawilcox@microsoft.com>, Ron Minnich <rminnich@sandia.gov>, samba-technical@lists.samba.org, Steve French <sfrench@samba.org>, Trond Myklebust <trond.myklebust@primarydata.com>, v9fs-developer@lists.sourceforge.net

On Thu 04-05-17 13:59:09, Ross Zwisler wrote:
> dax_invalidate_mapping_entry() currently removes DAX exceptional entries
> only if they are clean and unlocked.  This is done via:
> 
> invalidate_mapping_pages()
>   invalidate_exceptional_entry()
>     dax_invalidate_mapping_entry()
> 
> However, for page cache pages removed in invalidate_mapping_pages() there
> is an additional criteria which is that the page must not be mapped.  This
> is noted in the comments above invalidate_mapping_pages() and is checked in
> invalidate_inode_page().
> 
> For DAX entries this means that we can can end up in a situation where a
> DAX exceptional entry, either a huge zero page or a regular DAX entry,
> could end up mapped but without an associated radix tree entry. This is
> inconsistent with the rest of the DAX code and with what happens in the
> page cache case.
> 
> We aren't able to unmap the DAX exceptional entry because according to its
> comments invalidate_mapping_pages() isn't allowed to block, and
> unmap_mapping_range() takes a write lock on the mapping->i_mmap_rwsem.
> 
> We could potentially do an rmap walk to see if each of the entries actually
> has any active mappings before we remove it, but this might end up being
> very expensive and doesn't currently look to be worth it.
> 
> So, just remove dax_invalidate_mapping_entry() and leave the DAX entries in
> the radix tree.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Fixes: c6dcf52c23d2 ("mm: Invalidate DAX radix tree entries only if appropriate")
> Reported-by: Jan Kara <jack@suse.cz>
> Reviewed-by: Jan Kara <jack@suse.cz>
> Cc: <stable@vger.kernel.org>    [4.10+]

Ah, I've just sent out a series which contains these two patches and
another two patches which change the entry locking to fix the last spotted
race...  So either just take my last two patches on top of these two or
take my series as a whole.

								Honza

> ---
>  fs/dax.c            | 29 -----------------------------
>  include/linux/dax.h |  1 -
>  mm/truncate.c       |  9 +++------
>  3 files changed, 3 insertions(+), 36 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index 85abd74..166504c 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -507,35 +507,6 @@ int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index)
>  }
>  
>  /*
> - * Invalidate exceptional DAX entry if easily possible. This handles DAX
> - * entries for invalidate_inode_pages() so we evict the entry only if we can
> - * do so without blocking.
> - */
> -int dax_invalidate_mapping_entry(struct address_space *mapping, pgoff_t index)
> -{
> -	int ret = 0;
> -	void *entry, **slot;
> -	struct radix_tree_root *page_tree = &mapping->page_tree;
> -
> -	spin_lock_irq(&mapping->tree_lock);
> -	entry = __radix_tree_lookup(page_tree, index, NULL, &slot);
> -	if (!entry || !radix_tree_exceptional_entry(entry) ||
> -	    slot_locked(mapping, slot))
> -		goto out;
> -	if (radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_DIRTY) ||
> -	    radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_TOWRITE))
> -		goto out;
> -	radix_tree_delete(page_tree, index);
> -	mapping->nrexceptional--;
> -	ret = 1;
> -out:
> -	spin_unlock_irq(&mapping->tree_lock);
> -	if (ret)
> -		dax_wake_mapping_entry_waiter(mapping, index, entry, true);
> -	return ret;
> -}
> -
> -/*
>   * Invalidate exceptional DAX entry if it is clean.
>   */
>  int dax_invalidate_mapping_entry_sync(struct address_space *mapping,
> diff --git a/include/linux/dax.h b/include/linux/dax.h
> index d8a3dc0..f8e1833 100644
> --- a/include/linux/dax.h
> +++ b/include/linux/dax.h
> @@ -41,7 +41,6 @@ ssize_t dax_iomap_rw(struct kiocb *iocb, struct iov_iter *iter,
>  int dax_iomap_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
>  		    const struct iomap_ops *ops);
>  int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index);
> -int dax_invalidate_mapping_entry(struct address_space *mapping, pgoff_t index);
>  int dax_invalidate_mapping_entry_sync(struct address_space *mapping,
>  				      pgoff_t index);
>  void dax_wake_mapping_entry_waiter(struct address_space *mapping,
> diff --git a/mm/truncate.c b/mm/truncate.c
> index 6263aff..c537184 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -67,17 +67,14 @@ static void truncate_exceptional_entry(struct address_space *mapping,
>  
>  /*
>   * Invalidate exceptional entry if easily possible. This handles exceptional
> - * entries for invalidate_inode_pages() so for DAX it evicts only unlocked and
> - * clean entries.
> + * entries for invalidate_inode_pages().
>   */
>  static int invalidate_exceptional_entry(struct address_space *mapping,
>  					pgoff_t index, void *entry)
>  {
> -	/* Handled by shmem itself */
> -	if (shmem_mapping(mapping))
> +	/* Handled by shmem itself, or for DAX we do nothing. */
> +	if (shmem_mapping(mapping) || dax_mapping(mapping))
>  		return 1;
> -	if (dax_mapping(mapping))
> -		return dax_invalidate_mapping_entry(mapping, index);
>  	clear_shadow_entry(mapping, index, entry);
>  	return 1;
>  }
> -- 
> 2.9.3
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
