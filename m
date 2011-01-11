Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4675E6B00E7
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 04:38:35 -0500 (EST)
In-reply-to: <20110111125330.e416cff5.nishimura@mxp.nes.nec.co.jp> (message
	from Daisuke Nishimura on Tue, 11 Jan 2011 12:53:30 +0900)
Subject: Re: [PATCH] mm: add replace_page_cache_page() function
References: <E1PbGxV-0001ug-2r@pomaz-ex.szeredi.hu>
	<20110111112949.57fd6fd7.kamezawa.hiroyu@jp.fujitsu.com> <20110111125330.e416cff5.nishimura@mxp.nes.nec.co.jp>
Message-Id: <E1PcagC-0007Ge-40@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 11 Jan 2011 10:38:16 +0100
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: kamezawa.hiroyu@jp.fujitsu.com, miklos@szeredi.hu, akpm@linux-foundation.org, minchan.kim@gmail.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 11 Jan 2011, Daisuke Nishimura wrote:
> > What I recommend is below. (Please see the newest -mm because of a bug fix for
> > mem cgroup) Considering page management on radix-tree, it can be considerd as
> > a kind of page-migration, which replaces pages on radix-tree.
> > 
> > ==
> > 
> > > +int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
> > > +{
> > > +	int error;
> > > +
> > > +	VM_BUG_ON(!PageLocked(old));
> > > +	VM_BUG_ON(!PageLocked(new));
> > > +	VM_BUG_ON(new->mapping);
> > > +
> > 	struct mem_cgroup *memcg;
> > 
> I think it should be initialized to NULL.
> 
> > 	error = mem_cgroup_prepare_migration(old, new, &memcg);
> 
> I want some comments like:
> 
> 	/*
> 	 * This is not page migration, but prepare_migration and end_migration
> 	 * does enough work for charge replacement.
> 	 */
> 
> > 	#
> > 	# This function will charge against "newpage". But this expects
> > 	# the caller allows GFP_KERNEL gfp_mask. 
> > 	# After this, the newpage is in "charged" state.
> > 	if (error)
> > 		return -ENOMEM;
> > 
> > > +	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
> > > +	if (!error) {
> > > +		struct address_space *mapping = old->mapping;
> > > +		pgoff_t offset = old->index;
> > > +
> > > +		page_cache_get(new);
> > > +		new->mapping = mapping;
> > > +		new->index = offset;
> > > +
> > > +		spin_lock_irq(&mapping->tree_lock);
> > > +		__remove_from_page_cache(old);
> > > +		error = radix_tree_insert(&mapping->page_tree, offset, new);
> > > +		BUG_ON(error);
> > > +		mapping->nrpages++;
> > > +		__inc_zone_page_state(new, NR_FILE_PAGES);
> > > +		if (PageSwapBacked(new))
> > > +			__inc_zone_page_state(new, NR_SHMEM);
> > > +		spin_unlock_irq(&mapping->tree_lock);
> > > +		radix_tree_preload_end();
> > 
> > > +		mem_cgroup_replace_cache_page(old, new); <== remove this.
> > 
> > 		mem_cgroup_end_migraton(memcg, old, new, true);
> > 
> > > +		page_cache_release(old);
> > > +	} 
> > 	else 
> > 		mem_cgroup_end_migration(memcg, old, new, false);
> > 
> > 	# Here, if the 4th argument is true, old page is uncharged.
> > 	# if the 4th argument is false, the new page is uncharged.
> > 	# Then, "charge" of the old page will be migrated onto the new page
> > 	# if replacement is done.
> > 
> > 
> > 
> > > +
> > > +	return error;
> > > +}
> > > +EXPORT_SYMBOL_GPL(replace_page_cache_page);
> > > +
> > 
> > ==
> > 
> > I think this is enough simple and this covers all memory cgroup's racy
> > problems.
> > 
> I agree.

Thanks for the comments.

Yeah, using existing infrastructure is undoubtedly simpler and less
prone to bugs.  So going with this for a first implementation might
do.

However, replace_page_cache_page() is meant to be very efficient,
otherwise any performance won by not copying the page contents are
lost to the cost of page replacement.  My guess is,
mem_cgroup_prepare_migration()/end_migration() are to heavyweight for
this.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
