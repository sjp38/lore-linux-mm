Date: Fri, 25 May 2007 00:48:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/1] vmscan: give referenced, active and unmapped pages
 a second trip around the LRU
Message-Id: <20070525004808.84ae5cf3.akpm@linux-foundation.org>
In-Reply-To: <1180078590.7348.27.camel@twins>
References: <200705242357.l4ONvw49006681@shell0.pdx.osdl.net>
	<1180076565.7348.14.camel@twins>
	<20070525001812.9dfc972e.akpm@linux-foundation.org>
	<1180077810.7348.20.camel@twins>
	<20070525002829.19deb888.akpm@linux-foundation.org>
	<1180078590.7348.27.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, mbligh@mbligh.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, 25 May 2007 09:36:30 +0200 Peter Zijlstra <peterz@infradead.org> wrote:

> > > The trouble I had with the previous patch is that it somehow looks to
> > > PG_referenced but not the PTE state, that seems wrong to me.
> > 
> > 		if (page_mapped(page)) {
> > 			if (!reclaim_mapped ||
> > 			    (total_swap_pages == 0 && PageAnon(page)) ||
> > 			    page_referenced(page, 0)) {
> > 				list_add(&page->lru, &l_active);
> > 				continue;
> > 			}
> > 		} else if (TestClearPageReferenced(page)) {
> > 			list_add(&page->lru, &l_active);
> > 			continue;
> > 		}
> > 
> > When we run TestClearPageReferenced() we know that the page isn't
> > page_mapped(): there aren't any pte's which refer to it.
> 
> D'0h, I guess I need my morning juice...
> 
> OK, that was my biggest beef - another small nit: I think it should do
> the page_referenced() first, and then the other checks (in the
> page_mapped() branch). Otherwise we might 'leak' the referenced state
> and give it yet another cycle on the active list - even though it was
> not used since last we were here.

You're saying we whould run page_referenced() prior to testing
reclaim_mapped?

That's quite a large change in behaviour: when reclaim is having an easy
time, (say, reclaiming clean pagecache), a change like that would cause
more pte-refenced bits to be cleared and it would cause more clearing of
PG_referenced on mapped pages.  Net effect: mapped pages get deactivated
and reclaimed more easily.

It's also significantly more computationally expensive: more rmap walking,
more lock-taking, more tlb writeback when those ptes get dirtied.  Not that
reclaim is very CPU-intensive.


But hey, like any change in there it might make reclaim better.  Or worse.
Or pink with shiny spots.  We just don't know.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
