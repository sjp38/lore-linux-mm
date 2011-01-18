Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 87CF06B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 18:28:54 -0500 (EST)
Date: Tue, 18 Jan 2011 15:28:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4] mm: add replace_page_cache_page() function
Message-Id: <20110118152844.88cfdc2c.akpm@linux-foundation.org>
In-Reply-To: <E1Pf9Zj-0002td-Ct@pomaz-ex.szeredi.hu>
References: <E1Pf9Zj-0002td-Ct@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: minchan.kim@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Jan 2011 12:18:11 +0100
Miklos Szeredi <miklos@szeredi.hu> wrote:

> +int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
> +{
> +	int error;
> +	struct mem_cgroup *memcg = NULL;

I'm suspecting that the unneeded initialisation was added to suppress a
warning?

I removed it, and didn't get a warning.  I expected to.

Really, uninitialized_var() is better.  It avoids adding extra code
and, unlike "= 0" it is self-documenting.

> +	VM_BUG_ON(!PageLocked(old));
> +	VM_BUG_ON(!PageLocked(new));
> +	VM_BUG_ON(new->mapping);
> +
> +	/*
> +	 * This is not page migration, but prepare_migration and
> +	 * end_migration does enough work for charge replacement.
> +	 *
> +	 * In the longer term we probably want a specialized function
> +	 * for moving the charge from old to new in a more efficient
> +	 * manner.
> +	 */
> +	error = mem_cgroup_prepare_migration(old, new, &memcg, gfp_mask);
> +	if (error)
> +		return error;
> +
> +	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
> +	if (!error) {
> +		struct address_space *mapping = old->mapping;
> +		pgoff_t offset = old->index;
> +
> +		page_cache_get(new);
> +		new->mapping = mapping;
> +		new->index = offset;
> +
> +		spin_lock_irq(&mapping->tree_lock);
> +		__remove_from_page_cache(old);
> +		error = radix_tree_insert(&mapping->page_tree, offset, new);
> +		BUG_ON(error);
> +		mapping->nrpages++;
> +		__inc_zone_page_state(new, NR_FILE_PAGES);
> +		if (PageSwapBacked(new))
> +			__inc_zone_page_state(new, NR_SHMEM);
> +		spin_unlock_irq(&mapping->tree_lock);
> +		radix_tree_preload_end();
> +		page_cache_release(old);
> +		mem_cgroup_end_migration(memcg, old, new, true);

This is all pretty ugly and inefficient.

We call __remove_from_page_cache() which does a radix-tree lookup and
then fiddles a bunch of accounting things.

Then we immediately do the same radix-tree lookup and then undo the
accounting changes which we just did.  And we do it in an open-coded
fashion, thus giving the kernel yet another code site where various
operations need to be kept in sync.

Would it not be better to do a single radix_tree_lookup_slot(),
overwrite the pointer therein and just leave all the ancilliary
accounting unaltered?


> +	} else {
> +		mem_cgroup_end_migration(memcg, old, new, false);
> +	}
> +
> +	return error;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
