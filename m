Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4BFA86B0098
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 17:10:52 -0500 (EST)
Received: by pzk27 with SMTP id 27so6481pzk.9
        for <linux-mm@kvack.org>; Thu, 16 Dec 2010 14:10:50 -0800 (PST)
Date: Fri, 17 Dec 2010 07:04:57 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] mm: add replace_page_cache_page() function
Message-ID: <20101216220457.GA3450@barrios-desktop>
References: <E1PStc6-0006Cd-0Z@pomaz-ex.szeredi.hu>
 <AANLkTikXQmsgZ8Ea-GoQ4k2St6yCJj8Z3XthuBQ9u+EV@mail.gmail.com>
 <E1PTCV4-0007sR-SO@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1PTCV4-0007sR-SO@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Dec 16, 2010 at 12:59:58PM +0100, Miklos Szeredi wrote:
> On Thu, 16 Dec 2010, Minchan Kim wrote:
> > > +int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
> > > +{
> > > + ?? ?? ?? int error;
> > > +
> > > + ?? ?? ?? VM_BUG_ON(!PageLocked(old));
> > > + ?? ?? ?? VM_BUG_ON(!PageLocked(new));
> > > + ?? ?? ?? VM_BUG_ON(new->mapping);
> > > +
> > > + ?? ?? ?? error = mem_cgroup_cache_charge(new, current->mm,
> > > + ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? gfp_mask & GFP_RECLAIM_MASK);
> > > + ?? ?? ?? if (error)
> > > + ?? ?? ?? ?? ?? ?? ?? goto out;
> > > +
> > > + ?? ?? ?? error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
> > > + ?? ?? ?? if (error == 0) {
> > > + ?? ?? ?? ?? ?? ?? ?? struct address_space *mapping = old->mapping;
> > > + ?? ?? ?? ?? ?? ?? ?? pgoff_t offset = old->index;
> > > +
> > > + ?? ?? ?? ?? ?? ?? ?? page_cache_get(new);
> > > + ?? ?? ?? ?? ?? ?? ?? new->mapping = mapping;
> > > + ?? ?? ?? ?? ?? ?? ?? new->index = offset;
> > > +
> > > + ?? ?? ?? ?? ?? ?? ?? spin_lock_irq(&mapping->tree_lock);
> > > + ?? ?? ?? ?? ?? ?? ?? __remove_from_page_cache(old);
> > > + ?? ?? ?? ?? ?? ?? ?? error = radix_tree_insert(&mapping->page_tree, offset, new);
> > > + ?? ?? ?? ?? ?? ?? ?? BUG_ON(error);
> > > + ?? ?? ?? ?? ?? ?? ?? mapping->nrpages++;
> > > + ?? ?? ?? ?? ?? ?? ?? __inc_zone_page_state(new, NR_FILE_PAGES);
> > > + ?? ?? ?? ?? ?? ?? ?? if (PageSwapBacked(new))
> > > + ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? __inc_zone_page_state(new, NR_SHMEM);
> > > + ?? ?? ?? ?? ?? ?? ?? spin_unlock_irq(&mapping->tree_lock);
> > > + ?? ?? ?? ?? ?? ?? ?? radix_tree_preload_end();
> > > + ?? ?? ?? ?? ?? ?? ?? mem_cgroup_uncharge_cache_page(old);
> > > + ?? ?? ?? ?? ?? ?? ?? page_cache_release(old);
> > 
> > Why do you release reference of old?
> 
> That's the page cache reference we release.  Just like we acquire the
> page cache reference for "new" above.

I mean current page cache handling semantic and page reference counting semantic
is separeated. For example, remove_from_page_cache doesn't drop the reference of page.
That's because we need more works after drop the page from page cache.
Look at shmem_writepage, truncate_complete_page.

You makes the general API and caller might need works before the old page 
is free. So how about this?

err = replace_page_cache_page(oldpage, newpage, GFP_KERNEL);
if (err) {
        ...
}

page_cache_release(oldpage); /* drop ref of page cache */


> 
> I suspect it's historic that page_cache_release() doesn't drop the
> page cache ref.

Sorry I can't understand your words.

> 
> Thanks for the review.
> 
> Miklos
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
