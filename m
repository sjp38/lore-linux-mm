Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 5B1876B006C
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 12:09:15 -0400 (EDT)
Date: Thu, 20 Sep 2012 12:09:07 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/4] mm: clear_page_mlock in page_remove_rmap
Message-ID: <20120920160907.GU1560@cmpxchg.org>
References: <alpine.LSU.2.00.1209182045370.11632@eggly.anvils>
 <alpine.LSU.2.00.1209182053520.11632@eggly.anvils>
 <20120919171811.GR1560@cmpxchg.org>
 <alpine.LSU.2.00.1209191347360.28400@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1209191347360.28400@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 19, 2012 at 02:52:53PM -0700, Hugh Dickins wrote:
> On Wed, 19 Sep 2012, Johannes Weiner wrote:
> > On Tue, Sep 18, 2012 at 08:55:21PM -0700, Hugh Dickins wrote:
> > > --- 3.6-rc6.orig/mm/memory.c	2012-09-18 15:38:08.000000000 -0700
> > > +++ 3.6-rc6/mm/memory.c	2012-09-18 17:51:02.871288773 -0700
> > > @@ -1576,12 +1576,12 @@ split_fallthrough:
> > >  		if (page->mapping && trylock_page(page)) {
> > >  			lru_add_drain();  /* push cached pages to LRU */
> > >  			/*
> > > -			 * Because we lock page here and migration is
> > > -			 * blocked by the pte's page reference, we need
> > > -			 * only check for file-cache page truncation.
> > > +			 * Because we lock page here, and migration is
> > > +			 * blocked by the pte's page reference, and we
> > > +			 * know the page is still mapped, we don't even
> > > +			 * need to check for file-cache page truncation.
> > >  			 */
> > > -			if (page->mapping)
> > > -				mlock_vma_page(page);
> > > +			mlock_vma_page(page);
> > >  			unlock_page(page);
> > 
> > So I don't see a reason for checking for truncation in current code,
> > but I also had a hard time figuring out from git history and list
> > archives when this was ever "needed" (flu brain does not help).
> 
> Thanks a lot for looking through all these.
> 
> But my unflued brain curses your flued brain for asking hard questions
> that mine has such difficulty answering.  So, please get well soon!
> 
> I do believe you're right that it was unnecessary even before my patch.
> 
> I came to look at it (and spent a long time pondering this very block)
> because I had already removed the page->mapping checks from the
> munlocking cases.  Without giving any thought as to whether the NULL
> case could actually occur in those, it was clearly wrong to skip
> munlocking if NULL did occur (after my other changes anyway:
> I didn't stop to work out if they were right before or not).
> 
> A more interesting question, I think, is whether that mlocking block
> actually needs the trylock_page and unlock_page: holding the pte
> lock there in follow_page gives a lot of security.  I did not decide
> one way or another (just as I simply updated the comment to reflect
> the change being made, without rethinking it all): it simply needed
> more time and thought than I had to give it, could be done separately
> later, and would have delayed getting these patches out.

Fair enough, it was just a mix of curiosity and making sure I did not
miss anything fundamental.  It looks like we agree, though :)

> > My conclusion is that it started out as a fix for when an early draft
> > of putback_lru_page dropped the page lock on truncated pages, but at
> 
> I don't recall the history of putback_lru_page at all, that sounds an
> odd thing for it to have done.  Your question prompted me to look back
> at old 2008 saved mail (though I've not looked at marc.info), but I
> didn't find the crucial stage where the page->mapping check got added
> (but there is a comment that Kosaki-san had fixed a truncate race).

This is what I was referring to: https://lkml.org/lkml/2008/6/19/72 -
but the base of this patch never appeared in Linus' tree.

> > > --- 3.6-rc6.orig/mm/rmap.c	2012-09-18 16:39:50.000000000 -0700
> > > +++ 3.6-rc6/mm/rmap.c	2012-09-18 17:51:02.871288773 -0700
> > > @@ -1203,7 +1203,10 @@ void page_remove_rmap(struct page *page)
> > >  	} else {
> > >  		__dec_zone_page_state(page, NR_FILE_MAPPED);
> > >  		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_MAPPED);
> > > +		mem_cgroup_end_update_page_stat(page, &locked, &flags);
> > >  	}
> > > +	if (unlikely(PageMlocked(page)))
> > > +		clear_page_mlock(page);
> > >  	/*
> > >  	 * It would be tidy to reset the PageAnon mapping here,
> > >  	 * but that might overwrite a racing page_add_anon_rmap
> > > @@ -1213,6 +1216,7 @@ void page_remove_rmap(struct page *page)
> > >  	 * Leaving it set also helps swapoff to reinstate ptes
> > >  	 * faster for those pages still in swapcache.
> > >  	 */
> > > +	return;
> > >  out:
> > >  	if (!anon)
> > >  		mem_cgroup_end_update_page_stat(page, &locked, &flags);
> > 
> > Would it be cleaner to fold this into the only goto site left?  One
> > certain upside of that would be the fantastic comment about leaving
> > page->mapping intact being the last operation in this function again :-)
> 
> Yes and no: I wanted to do that, but look again and you'll see
> that there are actually two "goto out"s there.

Yes, I missed that.  No worries, then!

Please include in this patch:

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
