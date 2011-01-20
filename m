Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 415878D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 13:25:13 -0500 (EST)
Date: Thu, 20 Jan 2011 19:24:44 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/3] When migrate_pages returns 0, all pages must have
 been released
Message-ID: <20110120182444.GA9506@random.random>
References: <f60d811fd1abcb68d40ac19af35881d700a97cd2.1295539829.git.minchan.kim@gmail.com>
 <alpine.DEB.2.00.1101201130100.10695@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1101201130100.10695@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Hello,

On Thu, Jan 20, 2011 at 11:30:35AM -0600, Christoph Lameter wrote:
> On Fri, 21 Jan 2011, Minchan Kim wrote:
> 
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index 46fe8cc..7d34237 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -772,6 +772,7 @@ uncharge:
> >  unlock:
> >  	unlock_page(page);
> >
> > +move_newpage:
> >  	if (rc != -EAGAIN) {
> >   		/*
> >   		 * A page that has been migrated has all references
> > @@ -785,8 +786,6 @@ unlock:
> >  		putback_lru_page(page);
> >  	}
> >
> > -move_newpage:
> > -
> >  	/*
> >  	 * Move the new page to the LRU. If migration was not successful
> >  	 * then this will free the page.
> >
> 
> What does this do? Not covered by the description.

It makes a difference for the two goto move_newpage, when rc =
0. Otherwise the function will return 0, despite
putback_lru_page(page) wasn't called (and the caller of migrate_pages
won't call putback_lru_pages if migrate_pages returned 0).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
