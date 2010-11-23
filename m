Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 73AD56B008C
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 09:59:14 -0500 (EST)
Date: Tue, 23 Nov 2010 14:58:56 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC 1/2] deactive invalidated pages
Message-ID: <20101123145856.GQ19571@csn.ul.ie>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com> <20101122141449.9de58a2c.akpm@linux-foundation.org> <AANLkTimk4JL7hDvLWuHjiXGNYxz8GJ_TypWFC=74Xt1Q@mail.gmail.com> <20101122210132.be9962c7.akpm@linux-foundation.org> <20101123093859.GE19571@csn.ul.ie> <87k4k49jii.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <87k4k49jii.fsf@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Ben Gamari <bgamari@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 23, 2010 at 09:55:49AM -0500, Ben Gamari wrote:
> On Tue, 23 Nov 2010 09:38:59 +0000, Mel Gorman <mel@csn.ul.ie> wrote:
> > > If it's mapped pagecache then the user was being a bit silly (or didn't
> > > know that some other process had mapped the file).  In which case we
> > > need to decide what to do - leave the page alone, deactivate it, or
> > > half-deactivate it as this patch does.
> > > 
> > 
> > What are the odds of an fadvise() user having used mincore() in advance
> > to determine if the page was in use by another process? I would guess
> > "low" so this half-deactivate gives a chance for the page to be promoted
> > again as well as a chance for the flusher threads to clean the page if
> > it really is to be reclaimed.
> > 
> Do we really want to make the user jump through such hoops as using
> mincore() just to get the kernel to handle use-once pages properly?

I would think "no" which is why I support half-deactivating pages so they won't
have to. The downside is that it's essentially a race window as another process
needs to reactivate the page before it gets reclaimed to avoid a major fault.

> I hope the answer is no. I know that fadvise isn't supposed to be a
> magic bullet, but it would be nice if more processes would use it to
> indicate their access patterns and the only way that will happen is if
> it is reasonably straightforward to use.
> 
> - Ben
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
