Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 745456B0071
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 04:39:15 -0500 (EST)
Date: Tue, 23 Nov 2010 09:38:59 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC 1/2] deactive invalidated pages
Message-ID: <20101123093859.GE19571@csn.ul.ie>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com> <20101122141449.9de58a2c.akpm@linux-foundation.org> <AANLkTimk4JL7hDvLWuHjiXGNYxz8GJ_TypWFC=74Xt1Q@mail.gmail.com> <20101122210132.be9962c7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101122210132.be9962c7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 22, 2010 at 09:01:32PM -0800, Andrew Morton wrote:
> On Tue, 23 Nov 2010 13:52:05 +0900 Minchan Kim <minchan.kim@gmail.com> wrote:
> 
> > >> +/*
> > >> + * Function used to forecefully demote a page to the head of the inactive
> > >> + * list.
> > >> + */
> > >
> > > This comment is wrong? __The page gets moved to the _tail_ of the
> > > inactive list?
> > 
> > No. I add it in _head_ of the inactive list intentionally.
> > Why I don't add it to _tail_ is that I don't want to be aggressive.
> > The page might be real working set. So I want to give a chance to
> > activate it again.
> 
> Well..  why?  The user just tried to toss the page away altogether.  If
> the kernel wasn't able to do that immediately, the best it can do is to
> toss the page away asap?
> 

I'm just guessing here on the motivation but maybe it is in case FADV_DONENEED
was called on a page in use by another process (via read/write more do than
being mapped). Process A says "I don't need this" but by moving it to the
head of the list we give Process B a chance to reference it and reactivate
without incurring a major fault?

> > If it's not working set, it can be reclaimed easily and it can prevent
> > active page demotion since inactive list size would be big enough for
> > not calling shrink_active_list.
> 
> What is "working set"?  Mapped and unmapped pagecache, or are you
> referring solely to mapped pagecache?
> 
> If it's mapped pagecache then the user was being a bit silly (or didn't
> know that some other process had mapped the file).  In which case we
> need to decide what to do - leave the page alone, deactivate it, or
> half-deactivate it as this patch does.
> 

What are the odds of an fadvise() user having used mincore() in advance
to determine if the page was in use by another process? I would guess
"low" so this half-deactivate gives a chance for the page to be promoted
again as well as a chance for the flusher threads to clean the page if
it really is to be reclaimed.

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
