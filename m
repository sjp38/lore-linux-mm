Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9160B6B009A
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 07:05:55 -0500 (EST)
In-reply-to: <20101216100744.e3a417cf.kamezawa.hiroyu@jp.fujitsu.com> (message
	from KAMEZAWA Hiroyuki on Thu, 16 Dec 2010 10:07:44 +0900)
Subject: Re: [PATCH] mm: add replace_page_cache_page() function
References: <E1PStc6-0006Cd-0Z@pomaz-ex.szeredi.hu> <20101216100744.e3a417cf.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <E1PTCae-0007tw-Un@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 16 Dec 2010 13:05:44 +0100
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 16 Dec 2010, KAMEZAWA Hiroyuki wrote:
> On Wed, 15 Dec 2010 16:49:58 +0100
> Miklos Szeredi <miklos@szeredi.hu> wrote:
> 
> > From: Miklos Szeredi <mszeredi@suse.cz>
> > 
> > This function basically does:
> > 
> >      remove_from_page_cache(old);
> >      page_cache_release(old);
> >      add_to_page_cache_locked(new);
> > 
> > Except it does this atomically, so there's no possibility for the
> > "add" to fail because of a race.
> > 
> > This is used by fuse to move pages into the page cache.
> > 
> > Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
> > ---
> >  fs/fuse/dev.c           |   10 ++++------
> >  include/linux/pagemap.h |    1 +
> >  mm/filemap.c            |   41 +++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 46 insertions(+), 6 deletions(-)
> > 
> > Index: linux-2.6/mm/filemap.c
> > ===================================================================
> > --- linux-2.6.orig/mm/filemap.c	2010-12-15 16:39:55.000000000 +0100
> > +++ linux-2.6/mm/filemap.c	2010-12-15 16:41:24.000000000 +0100
> > @@ -389,6 +389,47 @@ int filemap_write_and_wait_range(struct
> >  }
> >  EXPORT_SYMBOL(filemap_write_and_wait_range);
> >  
> > +int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
> > +{
> > +	int error;
> > +
> > +	VM_BUG_ON(!PageLocked(old));
> > +	VM_BUG_ON(!PageLocked(new));
> > +	VM_BUG_ON(new->mapping);
> > +
> > +	error = mem_cgroup_cache_charge(new, current->mm,
> > +					gfp_mask & GFP_RECLAIM_MASK);
> 
> Hmm, then, the page will be recharged to "current" instead of the memcg
> where "old" was under control. Is this design ? If so, why ?

No, I just haven't thought about it.

Porbably charging "new" to where "old" was charged is the logical
thing to do here.

> 
> In mm/migrate.c, following is called.
> 
> 	 charge = mem_cgroup_prepare_migration(page, newpage, &mem);
> 	....do migration....
>         if (!charge)
>                 mem_cgroup_end_migration(mem, page, newpage);
> 
> BTW, off topic, in fuse/dev.c
> 
> add_to_page_cache_locked(page)

This is the call which the above patch replaces with
replace_page_cache_page().  So if I fix replace_page_cache_page() to
charge "newpage" to the correct memory cgroup, that should solve all
problems, no?

Thanks for the review.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
