Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DA75F6B0078
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 10:49:56 -0500 (EST)
Date: Wed, 3 Feb 2010 16:49:00 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 28 of 32] pmd_trans_huge migrate bugcheck
Message-ID: <20100203154900.GA29308@random.random>
References: <patchbomb.1264969631@v2.random>
 <ffe6ba65ebf40dde3c92.1264969659@v2.random>
 <alpine.DEB.2.00.1002011542170.2384@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002011542170.2384@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 01, 2010 at 03:46:47PM -0600, Christoph Lameter wrote:
> On Sun, 31 Jan 2010, Andrea Arcangeli wrote:
> 
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -819,6 +820,10 @@ static int do_move_page_to_node_array(st
> >  		if (PageReserved(page) || PageKsm(page))
> >  			goto put_and_set;
> >
> > +		if (unlikely(PageTransCompound(page)))
> > +			if (unlikely(split_huge_page(page)))
> > +				goto put_and_set;
> > +
> >  		pp->page = page;
> >  		err = page_to_nid(page);
> 
> How does this work? do_move_page_to_node_array takes an array of page
> pointers in pp (struct page_to_node).  Lets say one is a compound page.

yes, all it matters is that it's not an array of "struct page"
pointers in input to that function.

> 
> Now we split this into 512 4k pages? and pp only points to the first of
> them?

page_to_node is only set in the "addr" field before split_huge_page
runs, see pp[j].addr = ... That is the input of the syscall.

> The rest of the move_pages() logic will only see one 4k page and move it.

Before follow_page is called, nobody could ever see any "struct
page". And after we call it, we immediately call split_huge_page if it
returned a tail/head page. (collapse_huge_page can't be collapsing it
again under us because of the pin taken by follow_page(FOLL_GET)).

split_huge_page runs before isolate_lru_page is called, so the lru
mangling isn't involved in the split (besides it would work anyway).

> The remaining 511 pages are left dangling? With an increased refcount?

The reamining 511 pages will be taken over by the next follow_page if
userland asks for it, userland will have no way to know if ram is
backed by hugepage or regular page so it has to submit one address per
page as syscall api has to be backwards compatible or everything
breaks. All other 511 pages have no increased refcount from the first
follow_page (or more precisely nothing related to the follow_page on
the 1st page, their page_count simply goes to match the head page
mapcount plus any additional pin on tail pages previously taken by
gup).

Only after the first follow_page for an address backed by an hugepage
we will call split_huge_page, all other follow_page on that 2m
naturally aligned virtual chunk will return regular pages like if no
hugepage existed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
