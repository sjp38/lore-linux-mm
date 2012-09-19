Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 675616B0044
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 17:53:33 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so1455910qcs.14
        for <linux-mm@kvack.org>; Wed, 19 Sep 2012 14:53:32 -0700 (PDT)
Date: Wed, 19 Sep 2012 14:52:53 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/4] mm: clear_page_mlock in page_remove_rmap
In-Reply-To: <20120919171811.GR1560@cmpxchg.org>
Message-ID: <alpine.LSU.2.00.1209191347360.28400@eggly.anvils>
References: <alpine.LSU.2.00.1209182045370.11632@eggly.anvils> <alpine.LSU.2.00.1209182053520.11632@eggly.anvils> <20120919171811.GR1560@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 19 Sep 2012, Johannes Weiner wrote:
> On Tue, Sep 18, 2012 at 08:55:21PM -0700, Hugh Dickins wrote:
> > We had thought that pages could no longer get freed while still marked
> > as mlocked; but Johannes Weiner posted this program to demonstrate that
> > truncating an mlocked private file mapping containing COWed pages is
> > still mishandled:
> > 
> > #include <sys/types.h>
> > #include <sys/mman.h>
> > #include <sys/stat.h>
> > #include <stdlib.h>
> > #include <unistd.h>
> > #include <fcntl.h>
> > #include <stdio.h>
> > 
> > int main(void)
> > {
> > 	char *map;
> > 	int fd;
> > 
> > 	system("grep mlockfreed /proc/vmstat");
> > 	fd = open("chigurh", O_CREAT|O_EXCL|O_RDWR);
> > 	unlink("chigurh");
> > 	ftruncate(fd, 4096);
> > 	map = mmap(NULL, 4096, PROT_WRITE, MAP_PRIVATE, fd, 0);
> > 	map[0] = 11;
> > 	mlock(map, sizeof(fd));
> > 	ftruncate(fd, 0);
> > 	close(fd);
> > 	munlock(map, sizeof(fd));
> > 	munmap(map, 4096);
> > 	system("grep mlockfreed /proc/vmstat");
> > 	return 0;
> > }
> > 
> > The anon COWed pages are not caught by truncation's clear_page_mlock()
> > of the pagecache pages; but unmap_mapping_range() unmaps them, so we
> > ought to look out for them there in page_remove_rmap().  Indeed, why
> > should truncation or invalidation be doing the clear_page_mlock() when
> > removing from pagecache?  mlock is a property of mapping in userspace,
> > not a propertly of pagecache: an mlocked unmapped page is nonsensical.
> 
> property?

Indeed :) thanks.  I'll not post a v2 just for this, I'll have a peep
when/if it goes into akpm's tree, in the hope that he might turn out
to have magically corrected it on the way (thank you, Andrew).

> 
> > --- 3.6-rc6.orig/mm/memory.c	2012-09-18 15:38:08.000000000 -0700
> > +++ 3.6-rc6/mm/memory.c	2012-09-18 17:51:02.871288773 -0700
> > @@ -1576,12 +1576,12 @@ split_fallthrough:
> >  		if (page->mapping && trylock_page(page)) {
> >  			lru_add_drain();  /* push cached pages to LRU */
> >  			/*
> > -			 * Because we lock page here and migration is
> > -			 * blocked by the pte's page reference, we need
> > -			 * only check for file-cache page truncation.
> > +			 * Because we lock page here, and migration is
> > +			 * blocked by the pte's page reference, and we
> > +			 * know the page is still mapped, we don't even
> > +			 * need to check for file-cache page truncation.
> >  			 */
> > -			if (page->mapping)
> > -				mlock_vma_page(page);
> > +			mlock_vma_page(page);
> >  			unlock_page(page);
> 
> So I don't see a reason for checking for truncation in current code,
> but I also had a hard time figuring out from git history and list
> archives when this was ever "needed" (flu brain does not help).

Thanks a lot for looking through all these.

But my unflued brain curses your flued brain for asking hard questions
that mine has such difficulty answering.  So, please get well soon!

I do believe you're right that it was unnecessary even before my patch.

I came to look at it (and spent a long time pondering this very block)
because I had already removed the page->mapping checks from the
munlocking cases.  Without giving any thought as to whether the NULL
case could actually occur in those, it was clearly wrong to skip
munlocking if NULL did occur (after my other changes anyway:
I didn't stop to work out if they were right before or not).

A more interesting question, I think, is whether that mlocking block
actually needs the trylock_page and unlock_page: holding the pte
lock there in follow_page gives a lot of security.  I did not decide
one way or another (just as I simply updated the comment to reflect
the change being made, without rethinking it all): it simply needed
more time and thought than I had to give it, could be done separately
later, and would have delayed getting these patches out.

> 
> My conclusion is that it started out as a fix for when an early draft
> of putback_lru_page dropped the page lock on truncated pages, but at

I don't recall the history of putback_lru_page at all, that sounds an
odd thing for it to have done.  Your question prompted me to look back
at old 2008 saved mail (though I've not looked at marc.info), but I
didn't find the crucial stage where the page->mapping check got added
(but there is a comment that Kosaki-san had fixed a truncate race).

I believe it used to be necessary (or at least advisable) because
there was a get_user_pages to pin the pages to be mlocked, quite
separate from the loop down those pages to mlock them: it was a
real possibility that the pages could be truncated between those.

> the time b291f00 "mlock: mlocked pages are unevictable" went into the
> tree it was merely an optimization anymore to avoid moving pages
> between lists when they are to be freed soon anyway.

I doubt it was ever intended as an optimization: too rare a case to
optimize for.  I think it just got carried over when the mlocking moved
inside the get_user_pages, because removing it would have required more
thought - in just the same way as I'm leaving the trylock_page.

> 
> Is this correct?
> 
> > --- 3.6-rc6.orig/mm/mlock.c	2012-09-18 15:38:08.000000000 -0700
> > +++ 3.6-rc6/mm/mlock.c	2012-09-18 17:51:02.871288773 -0700
> > @@ -51,13 +51,10 @@ EXPORT_SYMBOL(can_do_mlock);
> >  /*
> >   *  LRU accounting for clear_page_mlock()
> >   */
> > -void __clear_page_mlock(struct page *page)
> > +void clear_page_mlock(struct page *page)
> >  {
> > -	VM_BUG_ON(!PageLocked(page));
> > -
> > -	if (!page->mapping) {	/* truncated ? */
> > +	if (!TestClearPageMlocked(page))
> >  		return;
> > -	}
> >  
> >  	dec_zone_page_state(page, NR_MLOCK);
> >  	count_vm_event(UNEVICTABLE_PGCLEARED);
> > @@ -290,14 +287,7 @@ void munlock_vma_pages_range(struct vm_a
> >  		page = follow_page(vma, addr, FOLL_GET | FOLL_DUMP);
> >  		if (page && !IS_ERR(page)) {
> >  			lock_page(page);
> > -			/*
> > -			 * Like in __mlock_vma_pages_range(),
> > -			 * because we lock page here and migration is
> > -			 * blocked by the elevated reference, we need
> > -			 * only check for file-cache page truncation.
> > -			 */
> > -			if (page->mapping)
> > -				munlock_vma_page(page);
> > +			munlock_vma_page(page);
> >  			unlock_page(page);
> >  			put_page(page);
> >  		}
> > --- 3.6-rc6.orig/mm/rmap.c	2012-09-18 16:39:50.000000000 -0700
> > +++ 3.6-rc6/mm/rmap.c	2012-09-18 17:51:02.871288773 -0700
> > @@ -1203,7 +1203,10 @@ void page_remove_rmap(struct page *page)
> >  	} else {
> >  		__dec_zone_page_state(page, NR_FILE_MAPPED);
> >  		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_MAPPED);
> > +		mem_cgroup_end_update_page_stat(page, &locked, &flags);
> >  	}
> > +	if (unlikely(PageMlocked(page)))
> > +		clear_page_mlock(page);
> >  	/*
> >  	 * It would be tidy to reset the PageAnon mapping here,
> >  	 * but that might overwrite a racing page_add_anon_rmap
> > @@ -1213,6 +1216,7 @@ void page_remove_rmap(struct page *page)
> >  	 * Leaving it set also helps swapoff to reinstate ptes
> >  	 * faster for those pages still in swapcache.
> >  	 */
> > +	return;
> >  out:
> >  	if (!anon)
> >  		mem_cgroup_end_update_page_stat(page, &locked, &flags);
> 
> Would it be cleaner to fold this into the only goto site left?  One
> certain upside of that would be the fantastic comment about leaving
> page->mapping intact being the last operation in this function again :-)

Yes and no: I wanted to do that, but look again and you'll see
that there are actually two "goto out"s there.

I dislike the way page_remove_rmap() looks these days, and have
contemplated splitting it into anon and file subfunctions; but
not been satisfied with the result of that either.  And I admit
that this latest patch does not make it prettier.

I find the (very necessary) mem_cgroup_begin/end_update_page_stat()
particularly constricting, and some things depend upon how those are
implemented (what locks might get taken).  I do have a patch to make
them somewhat easier to work with (I never find time to review its
memory barriers, and it doesn't seem urgent), but page_remove_rmap()
remains just as ugly even with that change.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
