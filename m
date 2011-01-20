Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E77F18D0069
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 16:29:10 -0500 (EST)
Date: Thu, 20 Jan 2011 22:28:41 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/3] When migrate_pages returns 0, all pages must have
 been released
Message-ID: <20110120212841.GB9506@random.random>
References: <f60d811fd1abcb68d40ac19af35881d700a97cd2.1295539829.git.minchan.kim@gmail.com>
 <alpine.DEB.2.00.1101201130100.10695@router.home>
 <20110120182444.GA9506@random.random>
 <alpine.DEB.2.00.1101201233001.20633@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1101201233001.20633@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 20, 2011 at 12:49:15PM -0600, Christoph Lameter wrote:
> On Thu, 20 Jan 2011, Andrea Arcangeli wrote:
> 
> > Hello,
> >
> > On Thu, Jan 20, 2011 at 11:30:35AM -0600, Christoph Lameter wrote:
> > > On Fri, 21 Jan 2011, Minchan Kim wrote:
> > >
> > > > diff --git a/mm/migrate.c b/mm/migrate.c
> > > > index 46fe8cc..7d34237 100644
> > > > --- a/mm/migrate.c
> > > > +++ b/mm/migrate.c
> > > > @@ -772,6 +772,7 @@ uncharge:
> > > >  unlock:
> > > >  	unlock_page(page);
> > > >
> > > > +move_newpage:
> > > >  	if (rc != -EAGAIN) {
> > > >   		/*
> > > >   		 * A page that has been migrated has all references
> > > > @@ -785,8 +786,6 @@ unlock:
> > > >  		putback_lru_page(page);
> > > >  	}
> > > >
> > > > -move_newpage:
> > > > -
> > > >  	/*
> > > >  	 * Move the new page to the LRU. If migration was not successful
> > > >  	 * then this will free the page.
> > > >
> > >
> > > What does this do? Not covered by the description.
> >
> > It makes a difference for the two goto move_newpage, when rc =
> > 0. Otherwise the function will return 0, despite
> > putback_lru_page(page) wasn't called (and the caller of migrate_pages
> > won't call putback_lru_pages if migrate_pages returned 0).
> 
> Think about the difference:
> 
> Moving the move_newpage will now cause another removal and freeing of the
> page if rc != -EAGAIN.

The only ones doing "goto move_newpage" after the first two memleaks
that are fixed by this patch are always run with rc = -EAGAIN. So this
makes a difference only for the first two which were leaking memory before.

> The first goto move_newpage (because page count is 1) will now mean that
> the page is freed twice. One because of the rc != EAGAIN branch and then
> another time by the following putback_lru_page().

Which following putback_lru_page()?  You mean
putback_lru_page(newpage)? That is for the newly allocated page
(allocated at the very top, so always needed), it's not relevant to
the page_count(page) = 1. The page_count 1 is hold by the caller, so
it's leaking memory right now (for everything but compaction).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
