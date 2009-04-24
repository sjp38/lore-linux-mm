Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6BB2A6B003D
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 07:18:37 -0400 (EDT)
Date: Fri, 24 Apr 2009 12:18:50 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 15/22] Do not disable interrupts in free_page_mlock()
Message-ID: <20090424111850.GF14283@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie> <1240408407-21848-16-git-send-email-mel@csn.ul.ie> <20090423155951.6778bdd3.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090423155951.6778bdd3.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, cl@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, ming.m.lin@intel.com, yanmin_zhang@linux.intel.com, peterz@infradead.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

On Thu, Apr 23, 2009 at 03:59:51PM -0700, Andrew Morton wrote:
> On Wed, 22 Apr 2009 14:53:20 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > free_page_mlock() tests and clears PG_mlocked using locked versions of the
> > bit operations. If set, it disables interrupts to update counters and this
> > happens on every page free even though interrupts are disabled very shortly
> > afterwards a second time.  This is wasteful.
> 
> Well.  It's only wasteful if the page was mlocked, which is rare.
> 

True. mlocked pages are only going to be torn down during process exit or
munmap, both of which you'd expect to be rare when mlock is involved.

s/This is wasteful/While rare, this is unnecessary./

?

> > This patch splits what free_page_mlock() does. The bit check is still
> > made. However, the update of counters is delayed until the interrupts are
> > disabled and the non-lock version for clearing the bit is used. One potential
> > weirdness with this split is that the counters do not get updated if the
> > bad_page() check is triggered but a system showing bad pages is getting
> > screwed already.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
> > Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>
> > Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > ---
> >  mm/internal.h   |   11 +++--------
> >  mm/page_alloc.c |    8 +++++++-
> >  2 files changed, 10 insertions(+), 9 deletions(-)
> > 
> > diff --git a/mm/internal.h b/mm/internal.h
> > index 987bb03..58ec1bc 100644
> > --- a/mm/internal.h
> > +++ b/mm/internal.h
> > @@ -157,14 +157,9 @@ static inline void mlock_migrate_page(struct page *newpage, struct page *page)
> >   */
> >  static inline void free_page_mlock(struct page *page)
> >  {
> > -	if (unlikely(TestClearPageMlocked(page))) {
> > -		unsigned long flags;
> > -
> > -		local_irq_save(flags);
> > -		__dec_zone_page_state(page, NR_MLOCK);
> > -		__count_vm_event(UNEVICTABLE_MLOCKFREED);
> > -		local_irq_restore(flags);
> > -	}
> > +	__ClearPageMlocked(page);
> > +	__dec_zone_page_state(page, NR_MLOCK);
> > +	__count_vm_event(UNEVICTABLE_MLOCKFREED);
> >  }
> 
> The conscientuous reviewer runs around and checks for free_page_mlock()
> callers in other .c files which might be affected.
> 

The patch author should have done the same thing :/

> Only there are no such callers.
> 
> The reviewer's job would be reduced if free_page_mlock() wasn't
> needlessly placed in a header file!
> 
> >  #else /* CONFIG_HAVE_MLOCKED_PAGE_BIT */
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 67cafd0..7f45de1 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -499,7 +499,6 @@ static inline void __free_one_page(struct page *page,
> >  
> >  static inline int free_pages_check(struct page *page)
> >  {
> > -	free_page_mlock(page);
> >  	if (unlikely(page_mapcount(page) |
> >  		(page->mapping != NULL)  |
> >  		(page_count(page) != 0)  |
> > @@ -556,6 +555,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
> >  	unsigned long flags;
> >  	int i;
> >  	int bad = 0;
> > +	int clearMlocked = PageMlocked(page);
> >  
> >  	for (i = 0 ; i < (1 << order) ; ++i)
> >  		bad += free_pages_check(page + i);
> > @@ -571,6 +571,8 @@ static void __free_pages_ok(struct page *page, unsigned int order)
> >  	kernel_map_pages(page, 1 << order, 0);
> >  
> >  	local_irq_save(flags);
> > +	if (unlikely(clearMlocked))
> > +		free_page_mlock(page);
> 
> I wonder what the compiler does in the case
> CONFIG_HAVE_MLOCKED_PAGE_BIT=n.  If it is dumb, this patch would cause
> additional code generation.
> 

PageMlocked becomes

static inline int PageMlocked(page)
	{ return 0; }

so the compiler should be fit to spot that clearMlocked will always be 0. Even
if it didn't, it should have at least spotted that free_page_mlock(page)
is an empty inline function in this case.

Still double checked and I did not see the branch with
CONFIG_HAVE_MLOCKED_PAGE_BIT=n

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
