Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 656686B0032
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 10:31:02 -0400 (EDT)
Date: Thu, 25 Apr 2013 15:30:56 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: page eviction from the buddy cache
Message-ID: <20130425143056.GF2144@suse.de>
References: <3C8EEEF8-C1EB-4E3D-8DE6-198AB1BEA8C0@gmail.com>
 <515CD665.9000300@gmail.com>
 <239AD30A-2A31-4346-A4C7-8A6EB8247990@gmail.com>
 <51730619.3030204@fastmail.fm>
 <20130420235718.GA28789@thunk.org>
 <5176785D.5030707@fastmail.fm>
 <20130423122708.GA31170@thunk.org>
 <alpine.LNX.2.00.1304231230340.12850@eggly.anvils>
 <20130423150008.046ee9351da4681128db0bf3@linux-foundation.org>
 <20130424142650.GA29097@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130424142650.GA29097@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andrew Perepechko <anserper@ya.ru>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Bernd Schubert <bernd.schubert@fastmail.fm>, Alexey Lyahkov <alexey.lyashkov@gmail.com>, Will Huck <will.huckk@gmail.com>, linux-ext4@vger.kernel.org, linux-mm@kvack.org

On Wed, Apr 24, 2013 at 10:26:50AM -0400, Theodore Ts'o wrote:
> On Tue, Apr 23, 2013 at 03:00:08PM -0700, Andrew Morton wrote:
> > That should fix things for now.  Although it might be better to just do
> > 
> >  	mark_page_accessed(page);	/* to SetPageReferenced */
> >  	lru_add_drain();		/* to SetPageLRU */
> > 
> > Because a) this was too early to decide that the page is
> > super-important and b) the second touch of this page should have a
> > mark_page_accessed() in it already.
> 
> The question is do we really want to put lru_add_drain() into the ext4
> file system code?  That seems to pushing some fairly mm-specific
> knowledge into file system code.  I'll do this if I have to do, but
> wouldn't be better if this was pushed into mark_page_accessed(), or
> some other new API was exported by the mm subsystem?
> 

I don't think we want to push lru_add_drain() into the ext4 code. It's
too specific of knowledge just to work around pagevecs. Before we rework
how pagevecs select what LRU to place a page, can we make sure that fixing
that will fix the problem?

Andrew, can you try the following patch please? Also, is there any chance
you can describe in more detail what the workload does? If it fails to boot,
remove the second that calls lru_add_drain_all() and try again.

The patch looks deceptively simple, a downside from is is that workloads that
call mark_page_accessed() frequently will contend more on the zone->lru_lock
than it did previously. Moving lru_add_drain() to the ext4 could would
suffer the same contention problem.

Thanks.

---8<---
mm: pagevec: Move inactive pages to active lists even if on a pagevec

If a page is on a pagevec aimed at the inactive list then two subsequent
calls to mark_page_acessed() will still not move it to the active list.
This can cause a page to be reclaimed sooner than is expected. This
patch detects if an inactive page is not on the LRU and drains the
pagevec before promoting it.

Not-signed-off

diff --git a/mm/swap.c b/mm/swap.c
index 8a529a0..eac64fe 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -437,7 +437,18 @@ void activate_page(struct page *page)
 void mark_page_accessed(struct page *page)
 {
 	if (!PageActive(page) && !PageUnevictable(page) &&
-			PageReferenced(page) && PageLRU(page)) {
+			PageReferenced(page)) {
+		/* Page could be in pagevec */
+		if (!PageLRU(page))
+			lru_add_drain();
+
+		/*
+		 * Weeeee, using in_atomic() like this is a hand-grenade.
+		 * Patch is for debugging purposes only, do not merge this.
+		 */
+		if (!PageLRU(page) && !in_atomic())
+			lru_add_drain_all();
+
 		activate_page(page);
 		ClearPageReferenced(page);
 	} else if (!PageReferenced(page)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
