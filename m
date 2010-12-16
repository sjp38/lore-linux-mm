Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 373F16B0095
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 07:00:21 -0500 (EST)
In-reply-to: <AANLkTikXQmsgZ8Ea-GoQ4k2St6yCJj8Z3XthuBQ9u+EV@mail.gmail.com>
	(message from Minchan Kim on Thu, 16 Dec 2010 08:22:55 +0900)
Subject: Re: [PATCH] mm: add replace_page_cache_page() function
References: <E1PStc6-0006Cd-0Z@pomaz-ex.szeredi.hu> <AANLkTikXQmsgZ8Ea-GoQ4k2St6yCJj8Z3XthuBQ9u+EV@mail.gmail.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Message-Id: <E1PTCV4-0007sR-SO@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 16 Dec 2010 12:59:58 +0100
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 16 Dec 2010, Minchan Kim wrote:
> On Thu, Dec 16, 2010 at 12:49 AM, Miklos Szeredi <miklos@szeredi.hu> wrote:
> > From: Miklos Szeredi <mszeredi@suse.cz>
> >
> > This function basically does:
> >
> > A  A  remove_from_page_cache(old);
> > A  A  page_cache_release(old);
> > A  A  add_to_page_cache_locked(new);
> >
> > Except it does this atomically, so there's no possibility for the
> > "add" to fail because of a race.
> >
> > This is used by fuse to move pages into the page cache.
> 
> Please write down why fuse need this new atomic function in description.

Okay.

> >
> > Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
> > ---
> > A fs/fuse/dev.c A  A  A  A  A  | A  10 ++++------
> > A include/linux/pagemap.h | A  A 1 +
> > A mm/filemap.c A  A  A  A  A  A | A  41 +++++++++++++++++++++++++++++++++++++++++
> > A 3 files changed, 46 insertions(+), 6 deletions(-)
> >
> > Index: linux-2.6/mm/filemap.c
> > ===================================================================
> > --- linux-2.6.orig/mm/filemap.c 2010-12-15 16:39:55.000000000 +0100
> > +++ linux-2.6/mm/filemap.c A  A  A 2010-12-15 16:41:24.000000000 +0100
> > @@ -389,6 +389,47 @@ int filemap_write_and_wait_range(struct
> > A }
> > A EXPORT_SYMBOL(filemap_write_and_wait_range);
> >
> 
> This function is exported.
> Please, add function description

Right, will do.

> > +int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
> > +{
> > + A  A  A  int error;
> > +
> > + A  A  A  VM_BUG_ON(!PageLocked(old));
> > + A  A  A  VM_BUG_ON(!PageLocked(new));
> > + A  A  A  VM_BUG_ON(new->mapping);
> > +
> > + A  A  A  error = mem_cgroup_cache_charge(new, current->mm,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  gfp_mask & GFP_RECLAIM_MASK);
> > + A  A  A  if (error)
> > + A  A  A  A  A  A  A  goto out;
> > +
> > + A  A  A  error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
> > + A  A  A  if (error == 0) {
> > + A  A  A  A  A  A  A  struct address_space *mapping = old->mapping;
> > + A  A  A  A  A  A  A  pgoff_t offset = old->index;
> > +
> > + A  A  A  A  A  A  A  page_cache_get(new);
> > + A  A  A  A  A  A  A  new->mapping = mapping;
> > + A  A  A  A  A  A  A  new->index = offset;
> > +
> > + A  A  A  A  A  A  A  spin_lock_irq(&mapping->tree_lock);
> > + A  A  A  A  A  A  A  __remove_from_page_cache(old);
> > + A  A  A  A  A  A  A  error = radix_tree_insert(&mapping->page_tree, offset, new);
> > + A  A  A  A  A  A  A  BUG_ON(error);
> > + A  A  A  A  A  A  A  mapping->nrpages++;
> > + A  A  A  A  A  A  A  __inc_zone_page_state(new, NR_FILE_PAGES);
> > + A  A  A  A  A  A  A  if (PageSwapBacked(new))
> > + A  A  A  A  A  A  A  A  A  A  A  __inc_zone_page_state(new, NR_SHMEM);
> > + A  A  A  A  A  A  A  spin_unlock_irq(&mapping->tree_lock);
> > + A  A  A  A  A  A  A  radix_tree_preload_end();
> > + A  A  A  A  A  A  A  mem_cgroup_uncharge_cache_page(old);
> > + A  A  A  A  A  A  A  page_cache_release(old);
> 
> Why do you release reference of old?

That's the page cache reference we release.  Just like we acquire the
page cache reference for "new" above.

I suspect it's historic that page_cache_release() doesn't drop the
page cache ref.

Thanks for the review.

Miklos

> > + A  A  A  } else
> > + A  A  A  A  A  A  A  mem_cgroup_uncharge_cache_page(new);
> > +out:
> > + A  A  A  return error;
> > +}
> > +EXPORT_SYMBOL_GPL(replace_page_cache_page);
> > +
> > A /**
> > A * add_to_page_cache_locked - add a locked page to the pagecache
> > A * @page: A  A  A page to add
> > Index: linux-2.6/include/linux/pagemap.h
> > ===================================================================
> > --- linux-2.6.orig/include/linux/pagemap.h A  A  A 2010-12-15 16:39:39.000000000 +0100
> > +++ linux-2.6/include/linux/pagemap.h A  2010-12-15 16:41:24.000000000 +0100
> > @@ -457,6 +457,7 @@ int add_to_page_cache_lru(struct page *p
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A pgoff_t index, gfp_t gfp_mask);
> > A extern void remove_from_page_cache(struct page *page);
> > A extern void __remove_from_page_cache(struct page *page);
> > +int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask);
> >
> > A /*
> > A * Like add_to_page_cache_locked, but used to add newly allocated pages:
> > Index: linux-2.6/fs/fuse/dev.c
> > ===================================================================
> > --- linux-2.6.orig/fs/fuse/dev.c A  A  A  A 2010-12-15 16:39:39.000000000 +0100
> > +++ linux-2.6/fs/fuse/dev.c A  A  2010-12-15 16:41:24.000000000 +0100
> > @@ -729,14 +729,12 @@ static int fuse_try_move_page(struct fus
> > A  A  A  A if (WARN_ON(PageMlocked(oldpage)))
> > A  A  A  A  A  A  A  A goto out_fallback_unlock;
> >
> > - A  A  A  remove_from_page_cache(oldpage);
> > - A  A  A  page_cache_release(oldpage);
> > -
> > - A  A  A  err = add_to_page_cache_locked(newpage, mapping, index, GFP_KERNEL);
> > + A  A  A  err = replace_page_cache_page(oldpage, newpage, GFP_KERNEL);
> > A  A  A  A if (err) {
> > - A  A  A  A  A  A  A  printk(KERN_WARNING "fuse_try_move_page: failed to add page");
> > - A  A  A  A  A  A  A  goto out_fallback_unlock;
> > + A  A  A  A  A  A  A  unlock_page(newpage);
> > + A  A  A  A  A  A  A  return err;
> > A  A  A  A }
> > +
> > A  A  A  A page_cache_get(newpage);
> >
> > A  A  A  A if (!(buf->flags & PIPE_BUF_FLAG_LRU))
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org. A For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> 
> 
> 
> -- 
> Kind regards,
> Minchan Kim
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
