Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 8DC046B0038
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 05:49:52 -0400 (EDT)
Date: Tue, 26 Mar 2013 10:49:50 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 03/10] soft-offline: use migrate_pages() instead of
 migrate_huge_page()
Message-ID: <20130326094950.GM2295@dhcp22.suse.cz>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-4-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130325123128.GU2154@dhcp22.suse.cz>
 <1364272480-bmzkqzs6-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1364272480-bmzkqzs6-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Tue 26-03-13 00:34:40, Naoya Horiguchi wrote:
> On Mon, Mar 25, 2013 at 01:31:28PM +0100, Michal Hocko wrote:
> > On Fri 22-03-13 16:23:48, Naoya Horiguchi wrote:
[...]
> > > @@ -1482,12 +1483,20 @@ static int soft_offline_huge_page(struct page *page, int flags)
> > >  	unlock_page(hpage);
> > >  
> > >  	/* Keep page count to indicate a given hugepage is isolated. */
> > > -	ret = migrate_huge_page(hpage, new_page, MPOL_MF_MOVE_ALL,
> > > -				MIGRATE_SYNC);
> > > -	put_page(hpage);
> > > +	list_move(&hpage->lru, &pagelist);
> > > +	ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL,
> > > +				MIGRATE_SYNC, MR_MEMORY_FAILURE);
> > >  	if (ret) {
> > >  		pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
> > >  			pfn, ret, page->flags);
> > > +		/*
> > > +		 * We know that soft_offline_huge_page() tries to migrate
> > > +		 * only one hugepage pointed to by hpage, so we need not
> > > +		 * run through the pagelist here.
> > > +		 */
> > > +		putback_active_hugepage(hpage);
> > 
> > Maybe I am missing something but why we didn't need to call this before
> > when using migrate_huge_page?
> 
> migrate_huge_page() does not need list handling before/after the call,
> because it's defined to migrate only one hugepage, and it has a page as
> an argument, not list_head.

I do not understand this reasoning. migrate_huge_page calls
unmap_and_move_huge_page and migrate_pages does the same + accounting.
So what is the difference here? I suspect that putback_active_hugepage
was simply missing in this code path.

> > > +		if (ret > 0)
> > > +			ret = -EIO;
> > >  	} else {
> > >  		set_page_hwpoison_huge_page(hpage);
> > >  		dequeue_hwpoisoned_huge_page(hpage);
> > > diff --git v3.9-rc3.orig/mm/migrate.c v3.9-rc3/mm/migrate.c
> > > index f69f354..66030b6 100644
> > > --- v3.9-rc3.orig/mm/migrate.c
> > > +++ v3.9-rc3/mm/migrate.c
> > > @@ -981,6 +981,8 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
> > >  
> > >  	unlock_page(hpage);
> > >  out:
> > > +	if (rc != -EAGAIN)
> > > +		putback_active_hugepage(hpage);
> > 
> > And why do you put it here? If it is called from migrate_pages then the
> > caller already does the clean-up (putback_lru_pages).
> 
> What the caller of migrate_pages() cleans up is the (huge)pages which failed
> to be migrated. And what the above code cleans up is the source hugepage
> after the migration succeeds.

Why should you want to add successfully migrated page? /me confused.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
