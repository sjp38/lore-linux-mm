Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6EB436B0003
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 04:33:28 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id l126so57547119wml.1
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 01:33:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dl6si24318221wjb.82.2015.12.18.01.33.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 18 Dec 2015 01:33:27 -0800 (PST)
Date: Fri, 18 Dec 2015 10:33:23 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 3/7] mm: add find_get_entries_tag()
Message-ID: <20151218093323.GC4297@quack.suse.cz>
References: <1449602325-20572-1-git-send-email-ross.zwisler@linux.intel.com>
 <1449602325-20572-4-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1449602325-20572-4-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Tue 08-12-15 12:18:41, Ross Zwisler wrote:
> Add find_get_entries_tag() to the family of functions that include
> find_get_entries(), find_get_pages() and find_get_pages_tag().  This is
> needed for DAX dirty page handling because we need a list of both page
> offsets and radix tree entries ('indices' and 'entries' in this function)
> that are marked with the PAGECACHE_TAG_TOWRITE tag.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>

The patch looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

But I agree with Daniel that some refactoring to remove common code would
be good.

								Honza

> ---
>  include/linux/pagemap.h |  3 +++
>  mm/filemap.c            | 68 +++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 71 insertions(+)
> 
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 26eabf5..4db0425 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -361,6 +361,9 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t start,
>  			       unsigned int nr_pages, struct page **pages);
>  unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
>  			int tag, unsigned int nr_pages, struct page **pages);
> +unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
> +			int tag, unsigned int nr_entries,
> +			struct page **entries, pgoff_t *indices);
>  
>  struct page *grab_cache_page_write_begin(struct address_space *mapping,
>  			pgoff_t index, unsigned flags);
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 167a4d9..99dfbc9 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1498,6 +1498,74 @@ repeat:
>  }
>  EXPORT_SYMBOL(find_get_pages_tag);
>  
> +/**
> + * find_get_entries_tag - find and return entries that match @tag
> + * @mapping:	the address_space to search
> + * @start:	the starting page cache index
> + * @tag:	the tag index
> + * @nr_entries:	the maximum number of entries
> + * @entries:	where the resulting entries are placed
> + * @indices:	the cache indices corresponding to the entries in @entries
> + *
> + * Like find_get_entries, except we only return entries which are tagged with
> + * @tag.
> + */
> +unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
> +			int tag, unsigned int nr_entries,
> +			struct page **entries, pgoff_t *indices)
> +{
> +	void **slot;
> +	unsigned int ret = 0;
> +	struct radix_tree_iter iter;
> +
> +	if (!nr_entries)
> +		return 0;
> +
> +	rcu_read_lock();
> +restart:
> +	radix_tree_for_each_tagged(slot, &mapping->page_tree,
> +				   &iter, start, tag) {
> +		struct page *page;
> +repeat:
> +		page = radix_tree_deref_slot(slot);
> +		if (unlikely(!page))
> +			continue;
> +		if (radix_tree_exception(page)) {
> +			if (radix_tree_deref_retry(page)) {
> +				/*
> +				 * Transient condition which can only trigger
> +				 * when entry at index 0 moves out of or back
> +				 * to root: none yet gotten, safe to restart.
> +				 */
> +				goto restart;
> +			}
> +
> +			/*
> +			 * A shadow entry of a recently evicted page, a swap
> +			 * entry from shmem/tmpfs or a DAX entry.  Return it
> +			 * without attempting to raise page count.
> +			 */
> +			goto export;
> +		}
> +		if (!page_cache_get_speculative(page))
> +			goto repeat;
> +
> +		/* Has the page moved? */
> +		if (unlikely(page != *slot)) {
> +			page_cache_release(page);
> +			goto repeat;
> +		}
> +export:
> +		indices[ret] = iter.index;
> +		entries[ret] = page;
> +		if (++ret == nr_entries)
> +			break;
> +	}
> +	rcu_read_unlock();
> +	return ret;
> +}
> +EXPORT_SYMBOL(find_get_entries_tag);
> +
>  /*
>   * CD/DVDs are error prone. When a medium error occurs, the driver may fail
>   * a _large_ part of the i/o request. Imagine the worst scenario:
> -- 
> 2.5.0
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
