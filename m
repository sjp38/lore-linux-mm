Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 06C4A6B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 19:39:54 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5C8AC3EE0BD
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 09:39:52 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4344745DE51
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 09:39:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 203B045DE4F
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 09:39:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 087C71DB803E
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 09:39:52 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B8D721DB8037
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 09:39:51 +0900 (JST)
Date: Wed, 19 Jan 2011 09:33:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4] mm: add replace_page_cache_page() function
Message-Id: <20110119093356.38ff02a8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110118152844.88cfdc2c.akpm@linux-foundation.org>
References: <E1Pf9Zj-0002td-Ct@pomaz-ex.szeredi.hu>
	<20110118152844.88cfdc2c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, minchan.kim@gmail.com, nishimura@mxp.nes.nec.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Jan 2011 15:28:44 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 18 Jan 2011 12:18:11 +0100
> Miklos Szeredi <miklos@szeredi.hu> wrote:
> 
> > +int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
> > +{
> > +	int error;
> > +	struct mem_cgroup *memcg = NULL;
> 
> I'm suspecting that the unneeded initialisation was added to suppress a
> warning?
> 
> I removed it, and didn't get a warning.  I expected to.
> 
> Really, uninitialized_var() is better.  It avoids adding extra code
> and, unlike "= 0" it is self-documenting.
> 
> > +	VM_BUG_ON(!PageLocked(old));
> > +	VM_BUG_ON(!PageLocked(new));
> > +	VM_BUG_ON(new->mapping);
> > +
> > +	/*
> > +	 * This is not page migration, but prepare_migration and
> > +	 * end_migration does enough work for charge replacement.
> > +	 *
> > +	 * In the longer term we probably want a specialized function
> > +	 * for moving the charge from old to new in a more efficient
> > +	 * manner.
> > +	 */
> > +	error = mem_cgroup_prepare_migration(old, new, &memcg, gfp_mask);
> > +	if (error)
> > +		return error;
> > +
> > +	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
> > +	if (!error) {
> > +		struct address_space *mapping = old->mapping;
> > +		pgoff_t offset = old->index;
> > +
> > +		page_cache_get(new);
> > +		new->mapping = mapping;
> > +		new->index = offset;
> > +
> > +		spin_lock_irq(&mapping->tree_lock);
> > +		__remove_from_page_cache(old);
> > +		error = radix_tree_insert(&mapping->page_tree, offset, new);
> > +		BUG_ON(error);
> > +		mapping->nrpages++;
> > +		__inc_zone_page_state(new, NR_FILE_PAGES);
> > +		if (PageSwapBacked(new))
> > +			__inc_zone_page_state(new, NR_SHMEM);
> > +		spin_unlock_irq(&mapping->tree_lock);
> > +		radix_tree_preload_end();
> > +		page_cache_release(old);
> > +		mem_cgroup_end_migration(memcg, old, new, true);
> 
> This is all pretty ugly and inefficient.
> 
> We call __remove_from_page_cache() which does a radix-tree lookup and
> then fiddles a bunch of accounting things.
> 
> Then we immediately do the same radix-tree lookup and then undo the
> accounting changes which we just did.  And we do it in an open-coded
> fashion, thus giving the kernel yet another code site where various
> operations need to be kept in sync.
> 
> Would it not be better to do a single radix_tree_lookup_slot(),
> overwrite the pointer therein and just leave all the ancilliary
> accounting unaltered?
> 

Yes, I think radix_tree_lookup_slot & replacement technique can be used
as used in page migration. (migrate_page -> migrate_page_move_mapping)
So, I guess reusing page migration code will be easy way.
Hmm, if pages are never mapped, move_to_new_page() can be used.
But it requires page_count(old) == 1 for replacement. I'm not sure
what page_count(old) is here.


About memcg codes:
radix_tree_lookup_slot() technique is used for page-migration and
mem_cgroup_prepare_migration/end_migration is a code used for that.

Honestly, this radix-tree replacement is special rathar than migration
because this handles only file caches. So, we may be able to add
a new function for handling 'replacement' of page for memcg.

But the only user is this FUSE and I don't use FUSE for usual tests
and will never notice level down if it happens. I guess FUSE maintainer
will not notice level-down in memcg. So, I recommended to use the same
code for migration it's now heavily tested because of compaction.

So, I think it's better to reuse memcg codes even if move_to_newpage()
is used here directly.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
