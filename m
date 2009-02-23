Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 584486B0099
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 15:27:15 -0500 (EST)
Date: Mon, 23 Feb 2009 20:26:59 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 00/20] Cleanup and optimise the page allocator
Message-ID: <20090223202659.GT6740@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <200902240146.03456.nickpiggin@yahoo.com.au> <20090223150055.GK6740@csn.ul.ie> <200902240222.04645.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <200902240222.04645.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 24, 2009 at 02:22:03AM +1100, Nick Piggin wrote:
> On Tuesday 24 February 2009 02:00:56 Mel Gorman wrote:
> > On Tue, Feb 24, 2009 at 01:46:01AM +1100, Nick Piggin wrote:
> 
> > > free_page_mlock shouldn't really be in free_pages_check, but oh well.
> >
> > Agreed, I took it out of there.
> 
> Oh good. I didn't notice that.
> 
> > > > Patch 16 avoids using the zonelist cache on non-NUMA machines
> > > >
> > > > Patch 17 removes an expensive and excessively paranoid check in the
> > > > allocator fast path
> > >
> > > I would be careful of removing useful debug checks completely like
> > > this. What is the cost? Obviously non-zero, but it is also a check
> >
> > The cost was something like 1/10th the cost of the path. There are atomic
> > operations in there that are causing the problems.
> 
> The only atomic memory operations in there should be atomic loads of
> word or atomic_t sized and aligned locations, which should just be
> normal loads on any architecture?
> 
> The only atomic RMW you might see in that function would come from
> free_page_mlock (which you moved out of there, and anyway can be
> made non-atomic).
> 

You're right, they're normal loads. I wasn't looking at the resulting
assembly closely enough.  I saw a lock and branch in that general area of
free_pages_check(), remembered that it was an atomic read, conflated the
lock-bit-clear with the atomic read and went astray from there. Silly.

> I'd like you to just reevaluate it after your patchset, after the
> patch to make mlock non-atomic, and my patch I just sent.
> 

I re-evaluated with your patch in place of the check being dropped. With
the mlock bit clear moved out of the way, the assembly looks grand and the
amount of time being spent in that check is ok according to profiles

  o roughly 70 samples out of 398 in __free_pages_ok()
  o 2354 samples out of 31295 in free_pcp_pages()
  o 859 samples out of 35362 get_page_from_freelist 

I guess it's 7.5% of the free_pcp_pages() path but it would probably cause
more hassle with hard-to-debug problems the check was removed.

I was momentarily concerned about the compound aspect of page_count. We can
have compound pages in the __free_pages_ok() path and we'll end up checking
the count for each of the sub-pages instead of the head page. It shouldn't be
a problem as the count should be zero for each of the tail pages. A positive
count is a bug and will now trigger where in fact we would have missed it
before. I convinced myself that this change is ok but if anyone can spot a
problem with this reasoning, please shout now.

Is the page_mapcount() change in your patch really necessary? Unlikely
page_count(), it does not check for a compound page so it's not branching
like page_count() is. I don't think it is so I dropped that part of the
patch for the moment.

> 
> > > I have seen trigger on quite a lot of occasions (due to kernel bugs
> > > and hardware bugs, and in each case it is better to warn than not,
> > > even if many other situations can go undetected).
> >
> > Have you really seen it trigger for the allocation path or did it
> > trigger in teh free path? Essentially we are making the same check on
> > every allocation and free which is why I considered it excessivly
> > paranoid.
> 
> Yes I've seen it trigger in the allocation path. Kernel memory scribbles
> or RAM errors.
> 

That's the type of situation I expected it to occur but felt that the free
path would be sufficient. However, I'm convinced now to leave it in place,
particularly as its cost is not as excessive as I initially believed.

> 
> > > One problem is that some of the calls we're making in page_alloc.c
> > > do the compound_head() thing, wheras we know that we only want to
> > > look at this page. I've attached a patch which cuts out about 150
> > > bytes of text and several branches from these paths.
> >
> > Nice, I should have spotted that. I'm going to fold this into the series
> > if that is ok with you? I'll replace patch 17 with it and see does it
> > still show up on profiles.
> 
> Great! Sure fold it in (and put SOB: me on there if you like).
> 

Done, thanks. The version I'm currently using is below.

> 
> > > > So, by and large it's an improvement of some sort.
> > >
> > > Most of these benchmarks *really* need to be run quite a few times to get
> > > a reasonable confidence.
> >
> > Most are run repeatedly and an average taken but I should double check
> > what is going on. It's irritating that gains/regressions are
> > inconsistent between different machine types but that is nothing new.
> 
> Yeah. Cache behaviour maybe. One thing you might try is to size the struct
> page out to 64 bytes if it isn't already. This could bring down any skews
> if one kernel is lucky to get a nice packing of pages, or another is unlucky
> to get lots of struct pages spread over 2 cachelines. Maybe I'm just
> thinking wishfully :)
> 

It's worth an investigate :)

> I think with many of your changes, common sense will tell us that it is a
> better code sequence. Sometimes it's just impossible to really get
> "scientific proof" :)
> 

Sounds good to me but I'm hoping that it'll be possible to show a gains in
a few benchmarks on a few machines without large regressions showing up.

The replacement patch now looks like

=====
    Do not check for compound pages during the page allocator sanity checks
    
    A number of sanity checks are made on each page allocation and free
    including that the page count is zero. page_count() checks for
    compound pages and checks the count of the head page if true. However,
    in these paths, we do not care if the page is compound or not as the
    count of each tail page should also be zero.
    
    This patch makes two changes to the use of page_count() in the free path. It
    converts one check of page_count() to a VM_BUG_ON() as the count should
    have been unconditionally checked earlier in the free path. It also avoids
    checking for compound pages.
    
    [mel@csn.ul.ie: Wrote changelog]
    Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e598da8..8a8db71 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -426,7 +426,7 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
 		return 0;
 
 	if (PageBuddy(buddy) && page_order(buddy) == order) {
-		BUG_ON(page_count(buddy) != 0);
+		VM_BUG_ON(page_count(buddy) != 0);
 		return 1;
 	}
 	return 0;
@@ -503,7 +503,7 @@ static inline int free_pages_check(struct page *page)
 {
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
-		(page_count(page) != 0)  |
+		(atomic_read(&page->_count) != 0) |
 		(page->flags & PAGE_FLAGS_CHECK_AT_FREE))) {
 		bad_page(page);
 		return 1;
@@ -648,7 +648,7 @@ static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
 {
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
-		(page_count(page) != 0)  |
+		(atomic_read(&page->_count) != 0)  |
 		(page->flags & PAGE_FLAGS_CHECK_AT_PREP))) {
 		bad_page(page);
 		return 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
