Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id AF2ED6B00C9
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 03:44:45 -0400 (EDT)
Date: Mon, 11 Jun 2012 09:44:40 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: do not use page_count without a page pin
Message-ID: <20120611074440.GI3094@redhat.com>
References: <1339373872-31969-1-git-send-email-minchan@kernel.org>
 <4FD59C31.6000606@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FD59C31.6000606@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

Hi,

On Mon, Jun 11, 2012 at 04:20:17PM +0900, Kamezawa Hiroyuki wrote:
> (2012/06/11 9:17), Minchan Kim wrote:
> > d179e84ba fixed the problem[1] in vmscan.c but same problem is here.
> > Let's fix it.
> > 
> > [1] http://comments.gmane.org/gmane.linux.kernel.mm/65844
> > 
> > I copy and paste d179e84ba's contents for description.
> > 
> > "It is unsafe to run page_count during the physical pfn scan because
> > compound_head could trip on a dangling pointer when reading
> > page->first_page if the compound page is being freed by another CPU."
> > 
> > Cc: Andrea Arcangeli<aarcange@redhat.com>
> > Cc: Mel Gorman<mgorman@suse.de>
> > Cc: Michal Hocko<mhocko@suse.cz>
> > Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> > Signed-off-by: Minchan Kim<minchan@kernel.org>
> > ---
> >   mm/page_alloc.c |    6 +++++-
> >   1 file changed, 5 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 266f267..019c4fe 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -5496,7 +5496,11 @@ __count_immobile_pages(struct zone *zone, struct page *page, int count)
> >   			continue;
> > 
> >   		page = pfn_to_page(check);
> > -		if (!page_count(page)) {
> > +		/*
> > +		 * We can't use page_count withou pin a page
> > +		 * because another CPU can free compound page.
> > +		 */
> > +		if (!atomic_read(&page->_count)) {
> >   			if (PageBuddy(page))
> >   				iter += (1<<  page_order(page)) - 1;
> >   			continue;
> Nice Catch.

Agreed!

> Other than the comment fix already pointed out..
> Hmm...BTW, it seems this __count_xxx doesn't have any code for THP/Hugepage..
> so, we need more fixes for better code, I think.
> Hmm, Don't we need !PageTail() check and 'skip thp' code ?

So the page->_count for tail pages is guaranteed zero at all times
(tail page refcounting is done on _mapcount).

We could add a comment that "this check already skips compound tails
of THP because their page->_count is zero at all times".

Instead of a comment we could consider defining an inline function
with a special name that does atomic_read(&page->_count) and use it
when we intend to the regular or compound head count and return 0 on
tails. It would make it easier to identify these places later if we
ever want to change the refcounting mechanism, but it may be overkill,
it's up to you.

Tail pages also can't be PageLRU.

The code after the patch should already skip thp tails fine (it won't
skip heads but I believe that's intentional, but one problem that
remains is that the heads should increase found by more than 1...).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
