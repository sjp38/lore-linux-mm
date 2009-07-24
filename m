Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 70ABF6B004D
	for <linux-mm@kvack.org>; Fri, 24 Jul 2009 06:36:59 -0400 (EDT)
Date: Fri, 24 Jul 2009 11:36:56 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: Warn once when a page is freed with PG_mlocked set
	V2
Message-ID: <20090724103656.GA18074@csn.ul.ie>
References: <20090715125822.GB29749@csn.ul.ie> <alpine.DEB.1.10.0907151027410.23643@gentwo.org> <20090722160649.61176c61.akpm@linux-foundation.org> <20090723102938.GA27731@csn.ul.ie> <20090723102316.b94a2e4f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090723102316.b94a2e4f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, kosaki.motohiro@jp.fujitsu.com, maximlevitsky@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee.Schermerhorn@hp.com, penberg@cs.helsinki.fi, hannes@cmpxchg.org, jirislaby@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, Jul 23, 2009 at 10:23:16AM -0700, Andrew Morton wrote:
> On Thu, 23 Jul 2009 11:29:39 +0100 Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > On Wed, Jul 22, 2009 at 04:06:49PM -0700, Andrew Morton wrote:
> > > On Wed, 15 Jul 2009 10:31:54 -0400 (EDT)
> > > Christoph Lameter <cl@linux-foundation.org> wrote:
> > > 
> > > > On Wed, 15 Jul 2009, Mel Gorman wrote:
> > > > 
> > > > > -static inline int free_pages_check(struct page *page)
> > > > > +static inline int free_pages_check(struct page *page, int wasMlocked)
> > > > >  {
> > > > > +	WARN_ONCE(wasMlocked, KERN_WARNING
> > > > > +		"Page flag mlocked set for process %s at pfn:%05lx\n"
> > > > > +		"page:%p flags:0x%lX\n",
> > > > > +		current->comm, page_to_pfn(page),
> > > > > +		page, page->flags|__PG_MLOCKED);
> > > > > +
> > > > >  	if (unlikely(page_mapcount(page) |
> > > > 
> > > > There is already a free_page_mlocked() that is only called if the mlock
> > > > bit is set. Move it into there to avoid having to run two checks in the
> > > > hot codee path?
> > > 
> > > Agreed.
> > > 
> > > This patch gratuitously adds hotpath overhead.  Moving the change to be
> > > inside those preexisting wasMlocked tests will reduce its overhead a lot.
> > > 
> > 
> > It adds code duplication then, one of which is in a fast path.
> > 
> > > As it stands, I'm really doubting that the patch's utility is worth its
> > > cost.
> > > 
> > 
> > I'm happy to let this one drop. It seemed like it would be nice for debugging
> > while there are still corner cases where mlocked pages are getting freed
> > instead of torn down but we already account for that situation occuring. While
> > I think it'll be tricky to spot, it's probably preferable to having warnings
> > spew out onto dmesg.
> 
> If we do in it the way which Christoph recommends, the additional
> overhead is miniscule?
> 

Yep, it should be. I misinterpreted what you said with doubting the patch's
utility. The cost as it was was too high rather than the warning itself was
useless. When moved to free_page_mlock(), patch looks like;

==== CUT HERE ====
mm: Warn once when a page is freed with PG_mlocked set V3

Changelog since V2
  o Move warning to free_page_mlock()
  o Use %#lx instead of 0x%lX in printf format string

Changelog since V1
  o Remove unnecessary branch

When a page is freed with the PG_mlocked set, it is considered an unexpected
but recoverable situation. A counter records how often this event happens
but it is easy to miss that this event has occured at all. This patch warns
once when PG_mlocked is set to prompt debuggers to check the counter to
see how often it is happening.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 mm/page_alloc.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b8283e8..d3d0707 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -488,6 +488,11 @@ static inline void __free_one_page(struct page *page,
  */
 static inline void free_page_mlock(struct page *page)
 {
+	WARN_ONCE(1, KERN_WARNING
+		"Page flag mlocked set for process %s at pfn:%05lx\n"
+		"page:%p flags:%#lx\n",
+		current->comm, page_to_pfn(page),
+		page, page->flags|__PG_MLOCKED);
 	__dec_zone_page_state(page, NR_MLOCK);
 	__count_vm_event(UNEVICTABLE_MLOCKFREED);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
