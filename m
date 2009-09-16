Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6B59F6B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 07:41:06 -0400 (EDT)
Date: Wed, 16 Sep 2009 12:40:23 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 1/4] mm: m(un)lock avoid ZERO_PAGE
In-Reply-To: <20090916093506.GB1993@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0909161226500.12659@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
 <Pine.LNX.4.64.0909152127240.22199@sister.anvils>
 <Pine.LNX.4.64.0909152130260.22199@sister.anvils> <20090916093506.GB1993@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Sep 2009, Mel Gorman wrote:
> On Tue, Sep 15, 2009 at 09:31:49PM +0100, Hugh Dickins wrote:
> > 
> > And when munlocking, it turns out that FOLL_DUMP coincidentally does
> > what's needed to avoid all updates to ZERO_PAGE, so use that here also.
...
> >  	for (addr = start; addr < end; addr += PAGE_SIZE) {
> > -		struct page *page = follow_page(vma, addr, FOLL_GET);
> > -		if (page) {
> > +		struct page *page;
> > +		/*
> > +		 * Although FOLL_DUMP is intended for get_dump_page(),
> > +		 * it just so happens that its special treatment of the
> > +		 * ZERO_PAGE (returning an error instead of doing get_page)
> > +		 * suits munlock very well (and if somehow an abnormal page
> > +		 * has sneaked into the range, we won't oops here: great).
> > +		 */
> > +		page = follow_page(vma, addr, FOLL_GET | FOLL_DUMP);
> 
> Ouch, now I get your depraved comment :) . This will be a tricky rule to
> remember in a years time, wouldn't it?

I rely more upon git and grep than memory; I hope others do too.
(And that's partly why I put "get_dump_page" into the comment line.)

> Functionally, the patch seems fine and the avoidance of lock_page() is
> nice so.
> 
> Reviewed-by: Mel Gorman <mel@csn.ul.ie>

Thanks.

> 
> But, as FOLL_DUMP applies to more than core dumping, can it be renamed
> in another follow-on patch?  The fundamental underlying "thing" it does
> is to error instead of faulting the zero page so FOLL_NO_FAULT_ZEROPAGE,
> FOLL_ERRORZERO, FOLL_NOZERO etc? A name like that would simplify the comments
> as FOLL_DUMP would no longer just be a desirable side-effect.

At this moment, particularly after the years of FOLL_ANON confusion,
I feel pretty strongly that this flag is there for coredumping; and
it's just a happy accident that it happens also to be useful for munlock.
And if their needs diverge later, FOLL_DUMP will do whatever dumping
wants, and FOLL_MUNLOCK or something with a longer name will do
whatever munlocking wants.

I suspect that if I could think of a really snappy name for the flag,
that didn't just send us away to study the source to see what it
really does, I'd be glad to change to that.  But at the moment,
I'm happier sticking with FOLL_DUMP myself.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
