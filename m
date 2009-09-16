Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id ED9926B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 08:47:35 -0400 (EDT)
Date: Wed, 16 Sep 2009 13:47:40 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/4] mm: m(un)lock avoid ZERO_PAGE
Message-ID: <20090916124740.GD1993@csn.ul.ie>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils> <Pine.LNX.4.64.0909152127240.22199@sister.anvils> <Pine.LNX.4.64.0909152130260.22199@sister.anvils> <20090916093506.GB1993@csn.ul.ie> <Pine.LNX.4.64.0909161226500.12659@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0909161226500.12659@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 16, 2009 at 12:40:23PM +0100, Hugh Dickins wrote:
> On Wed, 16 Sep 2009, Mel Gorman wrote:
> > On Tue, Sep 15, 2009 at 09:31:49PM +0100, Hugh Dickins wrote:
> > > 
> > > And when munlocking, it turns out that FOLL_DUMP coincidentally does
> > > what's needed to avoid all updates to ZERO_PAGE, so use that here also.
> ...
> > >  	for (addr = start; addr < end; addr += PAGE_SIZE) {
> > > -		struct page *page = follow_page(vma, addr, FOLL_GET);
> > > -		if (page) {
> > > +		struct page *page;
> > > +		/*
> > > +		 * Although FOLL_DUMP is intended for get_dump_page(),
> > > +		 * it just so happens that its special treatment of the
> > > +		 * ZERO_PAGE (returning an error instead of doing get_page)
> > > +		 * suits munlock very well (and if somehow an abnormal page
> > > +		 * has sneaked into the range, we won't oops here: great).
> > > +		 */
> > > +		page = follow_page(vma, addr, FOLL_GET | FOLL_DUMP);
> > 
> > Ouch, now I get your depraved comment :) . This will be a tricky rule to
> > remember in a years time, wouldn't it?
> 
> I rely more upon git and grep than memory; I hope others do too.
> (And that's partly why I put "get_dump_page" into the comment line.)
> 

True and the comment is pretty explicit.

> > Functionally, the patch seems fine and the avoidance of lock_page() is
> > nice so.
> > 
> > Reviewed-by: Mel Gorman <mel@csn.ul.ie>
> 
> Thanks.
> 
> > 
> > But, as FOLL_DUMP applies to more than core dumping, can it be renamed
> > in another follow-on patch?  The fundamental underlying "thing" it does
> > is to error instead of faulting the zero page so FOLL_NO_FAULT_ZEROPAGE,
> > FOLL_ERRORZERO, FOLL_NOZERO etc? A name like that would simplify the comments
> > as FOLL_DUMP would no longer just be a desirable side-effect.
> 
> At this moment, particularly after the years of FOLL_ANON confusion,
> I feel pretty strongly that this flag is there for coredumping; and
> it's just a happy accident that it happens also to be useful for munlock.
> And if their needs diverge later, FOLL_DUMP will do whatever dumping
> wants, and FOLL_MUNLOCK or something with a longer name will do
> whatever munlocking wants.
> 

Ok, that's reasonable. You want to avoid any temptation of abuse of flag
and a reviewer will spot abuse of something called FOLL_DUMP easier than
something like FOLL_NOZERO.

> I suspect that if I could think of a really snappy name for the flag,
> that didn't just send us away to study the source to see what it
> really does, I'd be glad to change to that.  But at the moment,
> I'm happier sticking with FOLL_DUMP myself.
> 

Grand. Thanks for clarifying and explaining.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
