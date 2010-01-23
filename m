Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A29296B0047
	for <linux-mm@kvack.org>; Sat, 23 Jan 2010 12:57:06 -0500 (EST)
Date: Sat, 23 Jan 2010 18:55:23 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 04 of 30] clear compound mapping
Message-ID: <20100123175523.GB6494@random.random>
References: <patchbomb.1264054824@v2.random>
 <bf7a027f8ee11d7230b5.1264054828@v2.random>
 <1264095810.32717.34483.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1264095810.32717.34483.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 21, 2010 at 09:43:30AM -0800, Dave Hansen wrote:
> On Thu, 2010-01-21 at 07:20 +0100, Andrea Arcangeli wrote:
> > Clear compound mapping for anonymous compound pages like it already happens for
> > regular anonymous pages.
> 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -584,6 +584,8 @@ static void __free_pages_ok(struct page 
> > 
> >  	kmemcheck_free_shadow(page, order);
> > 
> > +	if (PageAnon(page))
> > +		page->mapping = NULL;
> >  	for (i = 0 ; i < (1 << order) ; ++i)
> >  		bad += free_pages_check(page + i);
> >  	if (bad)
> 
> This one may at least need a bit of an enhanced patch description.  I
> didn't immediately remember that __free_pages_ok() is only actually
> called for compound pages.

In short the problem is that the mapping is only cleared if page is
freed through free_hot_cold_page. So we've to clear it also if we
don't pass through free_hot_cold_page.

> Would it make more sense to pull the page->mapping=NULL out of
> free_hot_cold_page(), and just put a single one in __free_pages()?
>
> I guess we'd also need one in free_compound_page() since it calls
> __free_pages_ok() directly.  But, if this patch were putting modifying
> free_compound_page() it would at least be super obvious what was going
> on.

I could as well set_compound_page_dtor and have my own callback that
calls free_compound_page. Or I can move it to __free_one_page and
remove the one from free_hot_cold_page. What do you prefer?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
