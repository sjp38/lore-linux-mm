Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2C0BA6001DA
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 10:23:32 -0500 (EST)
Date: Thu, 28 Jan 2010 15:23:15 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 03 of 31] alter compound get_page/put_page
Message-ID: <20100128152315.GB7139@csn.ul.ie>
References: <patchbomb.1264513915@v2.random> <936cd613e4ae2d20c62b.1264513918@v2.random> <20100126180234.GH16468@csn.ul.ie> <20100127185837.GH12736@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100127185837.GH12736@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 27, 2010 at 07:58:37PM +0100, Andrea Arcangeli wrote:
> On Tue, Jan 26, 2010 at 06:02:35PM +0000, Mel Gorman wrote:
> > > diff --git a/arch/powerpc/mm/gup.c b/arch/powerpc/mm/gup.c
> > > --- a/arch/powerpc/mm/gup.c
> > > +++ b/arch/powerpc/mm/gup.c
> > > @@ -47,6 +47,14 @@ static noinline int gup_pte_range(pmd_t 
> > >  			put_page(page);
> > >  			return 0;
> > >  		}
> > > +		if (PageTail(page)) {
> > > +			/*
> > > +			 * __split_huge_page_refcount() cannot run
> > > +			 * from under us.
> > > +			 */
> > > +			VM_BUG_ON(atomic_read(&page->_count) < 0);
> > > +			atomic_inc(&page->_count);
> > > +		}
> > 
> > Is it worth considering making some of these VM_BUG_ON's BUG_ON's? None
> > of them will trigger in production setups. While you have tested heavily
> > on your own machines, there might be some wacky corner case.  I know the
> > downside is two atomics in there instead of one in there but it might be
> > worth it for a year anyway.
> 
> atomic_read isn't atomic. But it's also a fast path so I wouldn't like
> to have that... if things go under split_huge_page or free_pages_ok
> will cry I think, later, so it shouldn't go unnoticed.
> 

Ok, if it's eventually caught anyway, then it's fine. At worst, the root
cause of the error will be a little tricky to spot.

> > Also, Dave had suggested making this a helper in a previous revision to
> > avoid duplicating the comment if nothing else. It wouldn't hurt.
> 
> Ok! It must have been obfuscated by more urgent issues... thanks for
> the reminder!
> 

Yes, it was not exactly of earth-shattering importance :)

> > #define __PG_COMPOUND_LOCK           (1 << PG_compound_lock)
> > 
> > and 1 << __PG_COMPOUND_LOCK
> > 
> > so __PG_COMPOUND_LOCK is already shifted. Is that intentional? Unless I am
> > missing something obvious, it looks like it should be
> > 
> >  +      1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON | \
> >  +      __PG_COMPOUND_LOCK)
> > 
> > If it is not intentional, it should be harmless at runtime because the impact
> > is not checking a flag is properly clear.
> 
> Correct.
> 
> > >  static void put_compound_page(struct page *page)
> > >  {
> > > -	page = compound_head(page);
> > > -	if (put_page_testzero(page)) {
> > > -		compound_page_dtor *dtor;
> > > -
> > > -		dtor = get_compound_page_dtor(page);
> > > -		(*dtor)(page);
> > > +	if (unlikely(PageTail(page))) {
> > > +		/* __split_huge_page_refcount can run under us */
> > > +		struct page *page_head = page->first_page;
> > > +		smp_rmb();
> > 
> > Can you explain why the barrier is needed and why this is sufficient? It
> 
> smp_rmb is needed to be sure we read a first_page from a tail page. If
> it wasn't a tail page no more, while we read first_page, it wouldn't
> be safe.
> 
> > looks like you are checking for races before compound_lock() is called but
> > I'm not seeing how the window is fully closed if that is the case.
> 
> I need to be sure I'm getting a real valid head_page before I can run
> compound_lock, so the above smp_rmb with the smb_wmb before
> overwriting first_page in split_huge_page is meant to guarantee it.
> 

Ah, now it's clearer when I can see the rmb/wmb pairing.

> In futex it's the same, except there I disabled irqs as it's simpler
> and gup-fast accesses are all already in l1.
> 

Thanks for the explanation.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
