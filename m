Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id DAE326B004D
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 07:26:07 -0500 (EST)
Date: Fri, 16 Dec 2011 12:26:02 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 11/11] mm: Isolate pages for immediate reclaim on their
 own LRU
Message-ID: <20111216122602.GH3487@suse.de>
References: <1323877293-15401-1-git-send-email-mgorman@suse.de>
 <1323877293-15401-12-git-send-email-mgorman@suse.de>
 <4EEACD69.6010509@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4EEACD69.6010509@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Dec 15, 2011 at 11:47:37PM -0500, Rik van Riel wrote:
> On 12/14/2011 10:41 AM, Mel Gorman wrote:
> >It was observed that scan rates from direct reclaim during tests
> >writing to both fast and slow storage were extraordinarily high. The
> >problem was that while pages were being marked for immediate reclaim
> >when writeback completed, the same pages were being encountered over
> >and over again during LRU scanning.
> >
> >This patch isolates file-backed pages that are to be reclaimed when
> >clean on their own LRU list.
> 
> The idea makes total sense to me.  This is very similar
> to the inactive_laundry list in the early 2.4 kernel.
> 

Just to clarify, do you mean the inactive_dirty_list? It was before
my time so out of curiousity do you recall why it was removed? I
would guess that based on how the LRUs were aged at the time that
adding pages to the inactive_dirty list would lose too much aging
information. If this was the case, it would not apply today as pages
moving to the "immediate reclaim" list have already been selected for
reclaim so we expect them to be old.

> One potential issue is that the page cannot be moved
> back to the active list by mark_page_accessed(), which
> would have to be taught about the immediate LRU.
> 

Do you mean it *shouldn't* be moved back to the active list
by mark_page_accessed as opposed to "cannot"? As it is, if
mark_page_accessed() is called on a page on the immediate reclaim list,
it should get moved to the active list if it was previously inactive.
I'll admit this is odd but as it is we cannot tell for sure if the
page is on the inactive or immediate LRU list. Using PageReclaim is
not really an option because PG_reclaim is also used for readahead and
it seems overkill to try using a pageflag for this.

> >@@ -255,24 +256,80 @@ static void pagevec_move_tail(struct pagevec *pvec)
> >  }
> >
> >  /*
> >+ * Similar pair of functions to pagevec_move_tail except it is called when
> >+ * moving a page from the LRU_IMMEDIATE to one of the [in]active_[file|anon]
> >+ * lists
> >+ */
> >+static void pagevec_putback_immediate_fn(struct page *page, void *arg)
> >+{
> >+	struct zone *zone = page_zone(page);
> >+
> >+	if (PageLRU(page)) {
> >+		enum lru_list lru = page_lru(page);
> >+		list_move(&page->lru,&zone->lru[lru].list);
> >+	}
> >+}
> 
> Should this not put the page at the reclaim end of the
> inactive list, since we want to try evicting it?
> 

I don't think so. pagevec_putback_immediate() is used by
rotate_reclaimable_page when the page is *not* immediately reclaimable
because it is locked, still dirty, activated or unevictable. I expected
that most likely case it was not reclaimable was because it was
redirtied in which case it should do another lap through the LRU list to
give the flushers a chance. Putting it at the tail of the list could
mean that reclaim keeps finding these pages that are being moved from
the immediate list and raising the priority unnecessarily to skip them.
 
> >+	/*
> >+	 * There is a potential race that if a page is set PageReclaim
> >+	 * and moved to the LRU_IMMEDIATE list after writeback completed,
> >+	 * it can be left on the LRU_IMMEDATE list with no way for
> >+	 * reclaim to find it.
> >+	 *
> >+	 * This race should be very rare but count how often it happens.
> >+	 * If it is a continual race, then it's very unsatisfactory as there
> >+	 * is no guarantee that rotate_reclaimable_page() will be called
> >+	 * to rescue these pages but finding them in page reclaim is also
> >+	 * problematic due to the problem of deciding when the right time
> >+	 * to scan this list is.
> >+	 */
> 
> Would it be an idea for the pageout code to check whether the
> page at the head of the LRU_IMMEDIATE list is freeable, and
> then take that page?
> 

That is one possibility.

> Of course, that does mean adding a check to rotate_reclaimable_page
> to make sure the page is still on the LRU_IMMEDIATE list, and did
> not get moved by somebody else...
> 

This goes back to the problem of not being sure if the page is on the
inactive list or the immediate list and I don't want to introduce a
flag for this. While I think this could work, is it over complicating
things for what should be a rare occurance (see more on this later).
Ironically, the biggest complexity with solutions in this generation
direction is getting the accounting right!

> Also, it looks like your debugging check can trigger even when the
> bug does not happen (on the last LRU_IMMEDIATE page), because you
> decrement NR_IMMEDIATE before you get to this check.
> 

When NR_IMMEDIATE goes to 0, one more page is taken from the list and
moved back to an appropriate LRU list so the counts should match up.
When that counter is 0, the LRU lock is only taken if there are pages on
the list. It's racy because we are calling list_empty() outside the LRU
lock but that should not matter. Did I misunderstand you?

Also, this is not a debugging check per-se.  This "rescue" logic
is currently needed because it does happen. In the tests I ran 0.05
to 0.1% of the pages moved to the immediate reclaim list had to be
rescued from it using this logic. That was so low that I did not think a
more complex solution was justified.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
