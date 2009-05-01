Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AE5CF6B0047
	for <linux-mm@kvack.org>; Fri,  1 May 2009 10:00:22 -0400 (EDT)
Date: Fri, 1 May 2009 15:00:15 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH mmotm] mm: alloc_large_system_hash check order
Message-ID: <20090501140015.GA27831@csn.ul.ie>
References: <Pine.LNX.4.64.0904292151350.30874@blonde.anvils> <20090430132544.GB21997@csn.ul.ie> <Pine.LNX.4.64.0905011202530.8513@blonde.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0905011202530.8513@blonde.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 01, 2009 at 12:30:03PM +0100, Hugh Dickins wrote:
> On Thu, 30 Apr 2009, Mel Gorman wrote:
> > On Wed, Apr 29, 2009 at 10:09:48PM +0100, Hugh Dickins wrote:
> > > On an x86_64 with 4GB ram, tcp_init()'s call to alloc_large_system_hash(),
> > > to allocate tcp_hashinfo.ehash, is now triggering an mmotm WARN_ON_ONCE on
> > > order >= MAX_ORDER - it's hoping for order 11.  alloc_large_system_hash()
> > > had better make its own check on the order.
> > > 
> > > Signed-off-by: Hugh Dickins <hugh@veritas.com>
> > 
> > Looks good
> > 
> > Reviewed-by: Mel Gorman <mel@csn.ul.ie>
> 
> Thanks.
> 
> > 
> > As I was looking there, it seemed that alloc_large_system_hash() should be
> > using alloc_pages_exact() instead of having its own "give back the spare
> > pages at the end of the buffer" logic. If alloc_pages_exact() was used, then
> > the check for an order >= MAX_ORDER can be pushed down to alloc_pages_exact()
> > where it may catch other unwary callers.
> > 
> > How about adding the following patch on top of yours?
> 
> Well observed, yes indeed.  In fact, it even looks as if, shock horror,
> alloc_pages_exact() was _plagiarized_ from alloc_large_system_hash().
> Blessed be the GPL, I'm sure we can skip the lengthy lawsuits!
> 

*phew*.  We dodged a bullet there. I can put away my pitchfork and
flaming torch kit for another day.

> > 
> > ==== CUT HERE ====
> > Use alloc_pages_exact() in alloc_large_system_hash() to avoid duplicated logic
> > 
> > alloc_large_system_hash() has logic for freeing unused pages at the end
> > of an power-of-two-pages-aligned buffer that is a duplicate of what is in
> > alloc_pages_exact(). This patch converts alloc_large_system_hash() to use
> > alloc_pages_exact().
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > --- 
> >  mm/page_alloc.c |   27 +++++----------------------
> >  1 file changed, 5 insertions(+), 22 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 1b3da0f..c94b140 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1942,6 +1942,9 @@ void *alloc_pages_exact(size_t size, gfp_t gfp_mask)
> >  	unsigned int order = get_order(size);
> >  	unsigned long addr;
> >  
> > +	if (order >= MAX_ORDER)
> > +		return NULL;
> > +
> 
> I suppose there could be an argument about whether we do or do not
> want to skip the WARN_ON when it's in alloc_pages_exact().
> 
> I have no opinion on that; but DaveM's reply on large_system_hash
> does make it clear that we're not interested in the warning there.
> 

That's a fair point. I've included a slightly modified patch below that
preserves the warning for alloc_pages_exact() being called with a
too-large-an-order.

It means we call get_order() twice but in this path, so what. It's not
even text bloat as it's freed up.

> >  	addr = __get_free_pages(gfp_mask, order);
> >  	if (addr) {
> >  		unsigned long alloc_end = addr + (PAGE_SIZE << order);
> > @@ -4755,28 +4758,8 @@ void *__init alloc_large_system_hash(const char *tablename,
> >  			table = alloc_bootmem_nopanic(size);
> >  		else if (hashdist)
> >  			table = __vmalloc(size, GFP_ATOMIC, PAGE_KERNEL);
> > -		else {
> > -			unsigned long order = get_order(size);
> > -
> > -			if (order < MAX_ORDER)
> > -				table = (void *)__get_free_pages(GFP_ATOMIC,
> > -								order);
> > -			/*
> > -			 * If bucketsize is not a power-of-two, we may free
> > -			 * some pages at the end of hash table.
> > -			 */
> 
> That's actually a helpful comment, it's easy to think we're dealing
> in powers of two here when we may not be.  Maybe retain it with your
> alloc_pages_exact call?
> 

Sure, it explains why alloc_pages_exact() is being used instead of
__get_free_pages() for those that are unfamiliar with the call.

> > -			if (table) {
> > -				unsigned long alloc_end = (unsigned long)table +
> > -						(PAGE_SIZE << order);
> > -				unsigned long used = (unsigned long)table +
> > -						PAGE_ALIGN(size);
> > -				split_page(virt_to_page(table), order);
> > -				while (used < alloc_end) {
> > -					free_page(used);
> > -					used += PAGE_SIZE;
> > -				}
> > -			}
> > -		}
> > +		else
> > +			table = alloc_pages_exact(PAGE_ALIGN(size), GFP_ATOMIC);
> 
> Do you actually need that PAGE_ALIGN on the size?
> 

Actually no. When I added it, it was because alloc_pages_exact() did not
obviously deal with unaligned sizes but it does. Sorry about that.

> >  	} while (!table && size > PAGE_SIZE && --log2qty);
> >  
> >  	if (!table)
> 
> Andrew noticed another oddity: that if it goes the hashdist __vmalloc()
> way, it won't be limited by MAX_ORDER.  Makes one wonder whether it
> ought to fall back to __vmalloc() if the alloc_pages_exact() fails.

I don't believe so. __vmalloc() is only used when hashdist= is used or on IA-64
(according to the documentation). It is used in the case that the caller is
willing to deal with the vmalloc() overhead (e.g. using base page PTEs) in
exchange for the pages being interleaved on different nodes so that access
to the hash table has average performance[*]

If we automatically fell back to vmalloc(), I bet 2c we'd eventually get
a mysterious performance regression report for a workload that depended on
the hash tables performance but that there was enough memory for the hash
table to be allocated with vmalloc() instead of alloc_pages_exact().

[*] I speculate that on non-IA64 NUMA machines that we see different
    performance for large filesystem benchmarks depending on whether we are
    running on the boot-CPU node or not depending on whether hashdist=
    is used or not.

> I think that's a change we could make _if_ the large_system_hash
> users ever ask for it, but _not_ one we should make surreptitiously.
> 

If they want it, they'll have to ask with hashdist=. Somehow I doubt it's
specified very often :/ .

Here is Take 2

==== CUT HERE ====

Use alloc_pages_exact() in alloc_large_system_hash() to avoid duplicated logic V2

alloc_large_system_hash() has logic for freeing pages at the end
of an excessively large power-of-two buffer that is a duplicate of what
is in alloc_pages_exact(). This patch converts alloc_large_system_hash()
to use alloc_pages_exact().

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 mm/page_alloc.c |   21 ++++-----------------
 1 file changed, 4 insertions(+), 17 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1b3da0f..8360d59 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4756,26 +4756,13 @@ void *__init alloc_large_system_hash(const char *tablename,
 		else if (hashdist)
 			table = __vmalloc(size, GFP_ATOMIC, PAGE_KERNEL);
 		else {
-			unsigned long order = get_order(size);
-
-			if (order < MAX_ORDER)
-				table = (void *)__get_free_pages(GFP_ATOMIC,
-								order);
 			/*
 			 * If bucketsize is not a power-of-two, we may free
-			 * some pages at the end of hash table.
+			 * some pages at the end of hash table which
+			 * alloc_pages_exact() automatically does
 			 */
-			if (table) {
-				unsigned long alloc_end = (unsigned long)table +
-						(PAGE_SIZE << order);
-				unsigned long used = (unsigned long)table +
-						PAGE_ALIGN(size);
-				split_page(virt_to_page(table), order);
-				while (used < alloc_end) {
-					free_page(used);
-					used += PAGE_SIZE;
-				}
-			}
+			if (get_order(size) < MAX_ORDER)
+				table = alloc_pages_exact(size, GFP_ATOMIC);
 		}
 	} while (!table && size > PAGE_SIZE && --log2qty);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
