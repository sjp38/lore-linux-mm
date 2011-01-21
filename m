Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 062668D0039
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 13:11:44 -0500 (EST)
Date: Fri, 21 Jan 2011 18:36:18 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/3] When migrate_pages returns 0, all pages must have
 been released
Message-ID: <20110121173618.GH9506@random.random>
References: <f60d811fd1abcb68d40ac19af35881d700a97cd2.1295539829.git.minchan.kim@gmail.com>
 <alpine.DEB.2.00.1101201130100.10695@router.home>
 <20110120182444.GA9506@random.random>
 <alpine.DEB.2.00.1101201233001.20633@router.home>
 <20110120212841.GB9506@random.random>
 <alpine.DEB.2.00.1101211005150.14313@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1101211005150.14313@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 21, 2011 at 10:11:03AM -0600, Christoph Lameter wrote:
> On Thu, 20 Jan 2011, Andrea Arcangeli wrote:
> 
> > Which following putback_lru_page()?  You mean
> > putback_lru_page(newpage)? That is for the newly allocated page
> > (allocated at the very top, so always needed), it's not relevant to
> > the page_count(page) = 1. The page_count 1 is hold by the caller, so
> > it's leaking memory right now (for everything but compaction).
> 
> Ahh yes we removed the putback_lru_pages call from migrate_pages()
> and broke the existing release logic. The caller has to call
> putback_release_pages() as per commit

putback_lru_paeges

> cf608ac19c95804dc2df43b1f4f9e068aa9034ab

That is the very commit that introduced the two bugs that I've fixed
by code review.

> 
> If that is still the case then we still have the double free.

The caller only calls putback_lru_pages if ret != 0 (the two cases you
refer to happen with ret = 0).

Even if caller unconditionally calls putback_lru_pages (kind of what
compaction did), it can't double free because migrate_pages already
unlinked the pages before calling putback_lru_page(page), so there's
no way to do a double free (however if the caller unconditionally
called putback_lru_pages there would be no memleak to fix, but it
doesn't).

> Could we please document the calling conventions exactly in the source?
> Right now it says that the caller should call putback_lru_pages().

The caller should call putback_lru_pages only if ret != 0. Minchan
this is your commit we're discussing can you check the commentary?

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
