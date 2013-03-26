Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id D8D376B014B
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 16:35:49 -0400 (EDT)
Date: Tue, 26 Mar 2013 16:35:35 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1364330135-268cmm8x-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130326094950.GM2295@dhcp22.suse.cz>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-4-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130325123128.GU2154@dhcp22.suse.cz>
 <1364272480-bmzkqzs6-mutt-n-horiguchi@ah.jp.nec.com>
 <20130326094950.GM2295@dhcp22.suse.cz>
Subject: Re: [PATCH 03/10] soft-offline: use migrate_pages() instead of
 migrate_huge_page()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Tue, Mar 26, 2013 at 10:49:50AM +0100, Michal Hocko wrote:
> On Tue 26-03-13 00:34:40, Naoya Horiguchi wrote:
> > On Mon, Mar 25, 2013 at 01:31:28PM +0100, Michal Hocko wrote:
> > > On Fri 22-03-13 16:23:48, Naoya Horiguchi wrote:
> [...]
> > > > @@ -1482,12 +1483,20 @@ static int soft_offline_huge_page(struct page *page, int flags)
> > > >  	unlock_page(hpage);
> > > >  
> > > >  	/* Keep page count to indicate a given hugepage is isolated. */
> > > > -	ret = migrate_huge_page(hpage, new_page, MPOL_MF_MOVE_ALL,
> > > > -				MIGRATE_SYNC);
> > > > -	put_page(hpage);
> > > > +	list_move(&hpage->lru, &pagelist);
> > > > +	ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL,
> > > > +				MIGRATE_SYNC, MR_MEMORY_FAILURE);
> > > >  	if (ret) {
> > > >  		pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
> > > >  			pfn, ret, page->flags);
> > > > +		/*
> > > > +		 * We know that soft_offline_huge_page() tries to migrate
> > > > +		 * only one hugepage pointed to by hpage, so we need not
> > > > +		 * run through the pagelist here.
> > > > +		 */
> > > > +		putback_active_hugepage(hpage);
> > > 
> > > Maybe I am missing something but why we didn't need to call this before
> > > when using migrate_huge_page?
> > 
> > migrate_huge_page() does not need list handling before/after the call,
> > because it's defined to migrate only one hugepage, and it has a page as
> > an argument, not list_head.
> 
> I do not understand this reasoning. migrate_huge_page calls
> unmap_and_move_huge_page and migrate_pages does the same + accounting.
> So what is the difference here?

My previous comment missed the point, sorry.
Let me restate for your original question:
> > > Maybe I am missing something but why we didn't need to call this before
> > > when using migrate_huge_page?

Before 189ebff28, there was no hugepage_activelist and in-use hugepages are
not linked to any pagelist, so put_page was used instead.

And present question:
> I do not understand this reasoning. migrate_huge_page calls
> unmap_and_move_huge_page and migrate_pages does the same + accounting.
> So what is the difference here?

The differences is that migrate_huge_page() has one hugepage as an argument,
and migrate_pages() has a pagelist with multiple hugepages.
I already told this before and I'm not sure it's enough to answer the question,
so I explain another point about why this patch do like it.

I think that we must do putback_*pages() for source pages whether migration
succeeds or not. But when we call migrate_pages() with a pagelist,
the caller can't access to the successfully migrated source pages
after migrate_pages() returns, because they are no longer on the pagelist.
So putback of the successfully migrated source pages should be done *in*
unmap_and_move() and/or unmap_and_move_huge_page().

And when we used migrate_huge_page(), we passed a hugepage to be migrated
as an argument, so the caller can still access to the page even if the
migration succeeds.

> I suspect that putback_active_hugepage
> was simply missing in this code path.

Commit 189ebff28 moved put_page() out of the if-block with removing put_page()
in unmap_and_move_huge_page(). As I wrote above, this is correct only when
migrate_huge_page() handles only one hugepage.
But this patch makes us back to pagelist implementation, so we should cancel
this change.

> > > > +		if (ret > 0)
> > > > +			ret = -EIO;
> > > >  	} else {
> > > >  		set_page_hwpoison_huge_page(hpage);
> > > >  		dequeue_hwpoisoned_huge_page(hpage);
> > > > diff --git v3.9-rc3.orig/mm/migrate.c v3.9-rc3/mm/migrate.c
> > > > index f69f354..66030b6 100644
> > > > --- v3.9-rc3.orig/mm/migrate.c
> > > > +++ v3.9-rc3/mm/migrate.c
> > > > @@ -981,6 +981,8 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
> > > >  
> > > >  	unlock_page(hpage);
> > > >  out:
> > > > +	if (rc != -EAGAIN)
> > > > +		putback_active_hugepage(hpage);
> > > 
> > > And why do you put it here? If it is called from migrate_pages then the
> > > caller already does the clean-up (putback_lru_pages).
> > 
> > What the caller of migrate_pages() cleans up is the (huge)pages which failed
> > to be migrated. And what the above code cleans up is the source hugepage
> > after the migration succeeds.
> 
> Why should you want to add successfully migrated page? /me confused.

When hugepage migration succeeds, the source hugepage is freed back to
free hugepage pool (just after copy of data and mapping ended,
refcount of the source hugepage should be 1, so free_huge_page() is called
in this putback_active_hugepage().)
As I stated above, the caller cannot access to the source page, so we
need to do this here.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
