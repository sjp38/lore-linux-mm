Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id F3E3B6B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 09:41:09 -0400 (EDT)
Date: Thu, 16 May 2013 14:41:04 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/4] mm: Activate !PageLRU pages on mark_page_accessed if
 page is on local pagevec
Message-ID: <20130516134104.GH11497@suse.de>
References: <1368440482-27909-1-git-send-email-mgorman@suse.de>
 <1368440482-27909-4-git-send-email-mgorman@suse.de>
 <20130515155500.ffe53764d9018c80572544cc@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130515155500.ffe53764d9018c80572544cc@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexey Lyahkov <alexey.lyashkov@gmail.com>, Andrew Perepechko <anserper@ya.ru>, Robin Dong <sanbai@taobao.com>, Theodore Tso <tytso@mit.edu>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Bernd Schubert <bernd.schubert@fastmail.fm>, David Howells <dhowells@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-ext4 <linux-ext4@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>

On Wed, May 15, 2013 at 03:55:00PM -0700, Andrew Morton wrote:
> > @@ -441,8 +462,17 @@ void activate_page(struct page *page)
> >  void mark_page_accessed(struct page *page)
> >  {
> >  	if (!PageActive(page) && !PageUnevictable(page) &&
> > -			PageReferenced(page) && PageLRU(page)) {
> > -		activate_page(page);
> > +			PageReferenced(page)) {
> > +
> > +		/*
> > +		 * If the page is on the LRU, promote immediately. Otherwise,
> > +		 * assume the page is on a pagevec, mark it active and it'll
> > +		 * be moved to the active LRU on the next drain
> > +		 */
> > +		if (PageLRU(page))
> > +			activate_page(page);
> > +		else
> > +			__lru_cache_activate_page(page);
> >  		ClearPageReferenced(page);
> >  	} else if (!PageReferenced(page)) {
> >  		SetPageReferenced(page);
> 
> For starters, activate_page() doesn't "promote immediately".  It sticks
> the page into yet another pagevec for deferred activation.
> 

True, comment updated.

> Also, I really worry about the fact that
> activate_page()->drain->__activate_page() will simply skip over the
> page if it has PageActive set!  So PageActive does something useful if
> the page is in the add-to-lru pagevec but nothing useful if the page is
> in the activate-it-soon pagevec.  This is a confusing, unobvious bug
> attractant.
> 

>From mark_page_accessed, we only call activate_page() for !PageActive
and PageLRU. The PageLRU is key, if it's set, the pages *must* be on the
inactive list or they'd trigger BUG_ON(PageActive) checks within
vmscan.c. Am I missing your point?

If I remove the PageActive check in mark_page_accessed then pages that
are already on the active list will always get moved to the top of the
active list. If that page is frequently passed to mark_page_accessed(),
it will both potentially increase the lifetime of the page and the
amount of LRU churn. This would be very unexpected.

> Secondly, I really don't see how this code avoids the races.  Suppose
> the page gets spilled from the to-add-to-lru pagevec and onto the real
> LRU while mark_page_accessed() is concurrently executing. 

Good question. The key here is that __lru_cache_activate_page only
searches the pagevec for the local CPU. If the current CPU is draining the
to_add_to_lru pagevec, it cannot also be simultaneously setting PageActive
in mark_page_accessed. It was discussed in the changelog here.

"Note that only pages on the local pagevec are considered on purpose. A
!PageLRU page could be in the process of being released, reclaimed,
migrated or on a remote pagevec that is currently being drained. Marking
it PageActive is vunerable to races where PageLRU and Active bits are
checked at the wrong time."

Subtle comments on the code belong in the changelog, right?

> We end up
> setting PageActive on a page which is on the inactive LRU?  Maybe this
> is a can't-happen, in which case it's nowhere near clear enough *why*
> this can't happen.
> 

I don't think it can happen. If I'm wrong, PageActive checks in vmscan.c
will trigger.

How about putting this fix on top?

---8<---
mm: Activate !PageLRU pages on mark_page_accessed if page is on local pagevec -fix

Give the comments a beefier arm.

Signed-off-by: Mel Gorman <mgorman@suse.de>

diff --git a/mm/swap.c b/mm/swap.c
index 5646e31..49eb93f 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -439,7 +439,13 @@ static void __lru_cache_activate_page(struct page *page)
 
 	/*
 	 * Search backwards on the optimistic assumption that the page being
-	 * activated has just been added to this pagevec
+	 * activated has just been added to this pagevec. Note that only
+	 * the local pagevec is examined as a !PageLRU page could be in the
+	 * process of being released, reclaimed, migrated or on a remote
+	 * pagevec that is currently being drained. Furthermore, marking
+	 * a remote pagevec's page PageActive potentially hits a race where
+	 * a page is marked PageActive just after it is added to the inactive
+	 * list causing accounting errors and BUG_ON checks to trigger.
 	 */
 	for (i = pagevec_count(pvec) - 1; i >= 0; i--) {
 		struct page *pagevec_page = pvec->pages[i];
@@ -466,9 +472,10 @@ void mark_page_accessed(struct page *page)
 			PageReferenced(page)) {
 
 		/*
-		 * If the page is on the LRU, promote immediately. Otherwise,
-		 * assume the page is on a pagevec, mark it active and it'll
-		 * be moved to the active LRU on the next drain
+		 * If the page is on the LRU, queue it for activation via
+		 * activate_page_pvecs. Otherwise, assume the page is on a
+		 * pagevec, mark it active and it'll be moved to the active
+		 * LRU on the next drain.
 		 */
 		if (PageLRU(page))
 			activate_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
