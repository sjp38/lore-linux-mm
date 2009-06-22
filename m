Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D0C156B004F
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 16:51:33 -0400 (EDT)
Date: Mon, 22 Jun 2009 21:53:08 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: BUG: Bad page state [was: Strange oopses in 2.6.30]
Message-ID: <20090622205308.GG3981@csn.ul.ie>
References: <1245506908.6327.36.camel@localhost> <4A3CFFEC.1000805@gmail.com> <20090622113652.21E7.A69D9226@jp.fujitsu.com> <20090622091626.GA3981@csn.ul.ie> <1245686553.7799.102.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1245686553.7799.102.camel@lts-notebook>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Slaby <jirislaby@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 22, 2009 at 12:02:33PM -0400, Lee Schermerhorn wrote:
> On Mon, 2009-06-22 at 10:16 +0100, Mel Gorman wrote:
> > On Mon, Jun 22, 2009 at 11:39:53AM +0900, KOSAKI Motohiro wrote:
> > > (cc to Mel and some reviewer)
> 
> [added Rik so that he can get multiple copies, too. :)]
> 
> > > 
> > > > Flags are:
> > > > 0000000000400000 -- __PG_MLOCKED
> > > > 800000000050000c -- my page flags
> > > >         3650000c -- Maxim's page flags
> > > > 0000000000693ce1 -- my PAGE_FLAGS_CHECK_AT_FREE
> > > 
> > > I guess commit da456f14d (page allocator: do not disable interrupts in
> > > free_page_mlock()) is a bit wrong.
> > > 
> > > current code is:
> > > -------------------------------------------------------------
> > > static void free_hot_cold_page(struct page *page, int cold)
> > > {
> > > (snip)
> > >         int clearMlocked = PageMlocked(page);
> > > (snip)
> > >         if (free_pages_check(page))
> > >                 return;
> > > (snip)
> > >         local_irq_save(flags);
> > >         if (unlikely(clearMlocked))
> > >                 free_page_mlock(page);
> > > -------------------------------------------------------------
> > > 
> > > Oh well, we remove PG_Mlocked *after* free_pages_check().
> > > Then, it makes false-positive warning.
> > > 
> > > Sorry, my review was also wrong. I think reverting this patch is better ;)
> > > 
> > 
> > I think a revert is way overkill. The intention of the patch is sound -
> > reducing the number of times interrupts are disabled. Having pages
> > with the PG_locked bit is now somewhat of an expected situation. I'd
> > prefer to go with either
> > 
> > 1. Unconditionally clearing the bit with TestClearPageLocked as the
> >    patch already posted does
> > 2. Removing PG_locked from the free_pages_check()
> > 3. Unlocking the pages as we go when an mlocked VMA is being torn town
> 
> Mel,
> 
> #3 SHOULD be happening in all cases.  The free_page_mlocked() function
> counts when this is not happening.  We tried to fix all cases that we
> encountered before this feature was submitted, but left the vm_stat
> there to report if more PG_mlocked leaks were introduced. 

That makes sense. I was surprised at the thought that the pages were
apparently not getting freed properly and upon investigation I could not
trivially reproduce the problem. Can someone with this problem post their
.config please in case I'm missing something in there?

> We also,
> inadvertently, left PG_mlocked in the flags to check at free.  We didn't
> hit this before your patch because free_page_mlock() did a test&clear on
> the PG_mlocked before checking the flags.  Since you moved the call, and
> used PageMlocked() instead of TestClearPageMlocked(), any PG_locked page
> will cause the bug.
> 
> So, we have another PG_mlocked flag leaking to free.  I don't think this
> is terribly serious in itself, and probably not deserving of a BUG_ON.
> It probably doesn't deserve a vm_stat, either, I guess.  However, it
> could indicate a more serious logic error and should be examined. So it
> would be nice to retain some indication that it's happening.
> 
> > The patch that addresses 1 seemed ok to me. What do you think?
> > 
> 
> Your alternative #2 sounds less expensive that test&clear.
> 

How about the following? The intention is to warn once when PG_mlocked
is set but continue to count the number of times the event occured.

==== CUT HERE ====
mm: Warn once when a page is freed with PG_mlocked set

When a page is freed with the PG_mlocked set, it is considered an unexpected
but recoverable situation. A counter records how often this event happens
but due to commit da456f14d [page allocator: do not disable interrupts in
free_page_mlock()], the page state is being treated as a bad page which is
considered a severe bug.

This bug drops the severity of the report in the event a page is freed
with PG_mlocked set. A warning is printed once and the subsequent events
counted.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 include/linux/page-flags.h |   10 +++++++++-
 mm/page_alloc.c            |    9 +++++++++
 2 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index d6792f8..81731cf 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -389,7 +389,15 @@ static inline void __ClearPageTail(struct page *page)
 	 1 << PG_private | 1 << PG_private_2 | \
 	 1 << PG_buddy	 | 1 << PG_writeback | 1 << PG_reserved | \
 	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
-	 1 << PG_unevictable | __PG_MLOCKED)
+	 1 << PG_unevictable)
+
+/*
+ * Flags checked when a page is freed. Pages being freed should not have
+ * these set but the situation is easily resolved and should just be
+ * reported as a once-off warning.
+ */
+#define PAGE_FLAGS_WARN_AT_FREE \
+	(__PG_MLOCKED)
 
 /*
  * Flags checked when a page is prepped for return by the page allocator.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a5f3c27..c8c029e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -497,6 +497,15 @@ static void free_page_mlock(struct page *page) { }
 
 static inline int free_pages_check(struct page *page)
 {
+	if (unlikely(page->flags & PAGE_FLAGS_WARN_AT_FREE)) {
+		WARN_ONCE(1, KERN_WARNING
+			"Sloppy page flags set process %s at pfn:%05lx\n"
+			"page:%p flags:%p\n",
+			current->comm, page_to_pfn(page),
+			page, (void *)page->flags);
+		page->flags &= ~PAGE_FLAGS_WARN_AT_FREE;
+	}
+
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
 		(atomic_read(&page->_count) != 0) |

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
