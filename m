Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3B827828DF
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 13:36:46 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id r129so178623684wmr.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 10:36:46 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id k126si14406773wma.23.2016.02.03.10.36.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 10:36:45 -0800 (PST)
Date: Wed, 3 Feb 2016 13:35:47 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/3] mm: migrate: do not touch page->mem_cgroup of live
 pages
Message-ID: <20160203183547.GA4007@cmpxchg.org>
References: <1454109573-29235-1-git-send-email-hannes@cmpxchg.org>
 <1454109573-29235-2-git-send-email-hannes@cmpxchg.org>
 <20160203131748.GB15520@mguzik>
 <20160203140824.GJ21016@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160203140824.GJ21016@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Mateusz Guzik <mguzik@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>

CCing Hugh and Greg, they have worked on the memcg migration code most
recently. AFAIK the only reason newpage->mem_cgroup had to be set up
that early in migration was because of the way dirty accounting used
to work. But Hugh took memcg out of the equation there, so moving
mem_cgroup_migrate() to the end should be safe, as long as the pages
are still locked and off the LRU.

Full quote:

On Wed, Feb 03, 2016 at 05:08:24PM +0300, Vladimir Davydov wrote:
> On Wed, Feb 03, 2016 at 02:17:49PM +0100, Mateusz Guzik wrote:
> > On Fri, Jan 29, 2016 at 06:19:31PM -0500, Johannes Weiner wrote:
> > > Changing a page's memcg association complicates dealing with the page,
> > > so we want to limit this as much as possible. Page migration e.g. does
> > > not have to do that. Just like page cache replacement, it can forcibly
> > > charge a replacement page, and then uncharge the old page when it gets
> > > freed. Temporarily overcharging the cgroup by a single page is not an
> > > issue in practice, and charging is so cheap nowadays that this is much
> > > preferrable to the headache of messing with live pages.
> > > 
> > > The only place that still changes the page->mem_cgroup binding of live
> > > pages is when pages move along with a task to another cgroup. But that
> > > path isolates the page from the LRU, takes the page lock, and the move
> > > lock (lock_page_memcg()). That means page->mem_cgroup is always stable
> > > in callers that have the page isolated from the LRU or locked. Lighter
> > > unlocked paths, like writeback accounting, can use lock_page_memcg().
> > > 
> > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > [..]
> > > @@ -372,12 +373,13 @@ int migrate_page_move_mapping(struct address_space *mapping,
> > >  	 * Now we know that no one else is looking at the page:
> > >  	 * no turning back from here.
> > >  	 */
> > > -	set_page_memcg(newpage, page_memcg(page));
> > >  	newpage->index = page->index;
> > >  	newpage->mapping = page->mapping;
> > >  	if (PageSwapBacked(page))
> > >  		SetPageSwapBacked(newpage);
> > >  
> > > +	mem_cgroup_migrate(page, newpage);
> > > +
> > >  	get_page(newpage);	/* add cache reference */
> > >  	if (PageSwapCache(page)) {
> > >  		SetPageSwapCache(newpage);
> > > @@ -457,9 +459,11 @@ int migrate_huge_page_move_mapping(struct address_space *mapping,
> > >  		return -EAGAIN;
> > >  	}
> > >  
> > > -	set_page_memcg(newpage, page_memcg(page));
> > >  	newpage->index = page->index;
> > >  	newpage->mapping = page->mapping;
> > > +
> > > +	mem_cgroup_migrate(page, newpage);
> > > +
> > >  	get_page(newpage);
> > >  
> > >  	radix_tree_replace_slot(pslot, newpage);
> > 
> > I ran trinity on recent linux-next and got the lockdep splat below and if I
> > read it right, this is the culprit.  In particular, mem_cgroup_migrate was put
> > in an area covered by spin_lock_irq(&mapping->tree_lock), but stuff it calls
> > enables and disables interrupts on its own.
> 
> It must be safe to move these calls outside tree_lock:
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 307e95ece622..17db63b2dd36 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -379,8 +379,6 @@ int migrate_page_move_mapping(struct address_space *mapping,
>  	if (PageSwapBacked(page))
>  		SetPageSwapBacked(newpage);
>  
> -	mem_cgroup_migrate(page, newpage);
> -
>  	get_page(newpage);	/* add cache reference */
>  	if (PageSwapCache(page)) {
>  		SetPageSwapCache(newpage);
> @@ -430,6 +428,8 @@ int migrate_page_move_mapping(struct address_space *mapping,
>  	}
>  	local_irq_enable();
>  
> +	mem_cgroup_migrate(page, newpage);
> +
>  	return MIGRATEPAGE_SUCCESS;
>  }
>  
> @@ -463,8 +463,6 @@ int migrate_huge_page_move_mapping(struct address_space *mapping,
>  	newpage->index = page->index;
>  	newpage->mapping = page->mapping;
>  
> -	mem_cgroup_migrate(page, newpage);
> -
>  	get_page(newpage);
>  
>  	radix_tree_replace_slot(pslot, newpage);
> @@ -472,6 +470,9 @@ int migrate_huge_page_move_mapping(struct address_space *mapping,
>  	page_unfreeze_refs(page, expected_count - 1);
>  
>  	spin_unlock_irq(&mapping->tree_lock);
> +
> +	mem_cgroup_migrate(page, newpage);
> +
>  	return MIGRATEPAGE_SUCCESS;
>  }
>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
