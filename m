Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C2F876B00E9
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 04:22:51 -0500 (EST)
Date: Wed, 12 Jan 2011 09:22:26 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: mmotm hangs on compaction lock_page
Message-ID: <20110112092225.GF11932@csn.ul.ie>
References: <alpine.LSU.2.00.1101061632020.9601@sister.anvils> <20110107145259.GK29257@csn.ul.ie> <20110107175705.GL29257@csn.ul.ie> <20110110172609.GA11932@csn.ul.ie> <alpine.LSU.2.00.1101101458540.21100@tigran.mtv.corp.google.com> <20110111114521.GD11932@csn.ul.ie> <alpine.LSU.2.00.1101111217410.26276@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1101111217410.26276@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 11, 2011 at 12:41:41PM -0800, Hugh Dickins wrote:
> On Tue, 11 Jan 2011, Mel Gorman wrote:
> > On Mon, Jan 10, 2011 at 03:56:37PM -0800, Hugh Dickins wrote:
> > > On Mon, 10 Jan 2011, Mel Gorman wrote:
> > > > the other patch I posted was garbage.
> > > 
> > > I did give it a run, additionally setting PF_MEMALLOC before the call
> > > to __alloc_pages_direct_compact and clearing after, you appeared to
> > > be relying on that.  It didn't help, but now, only now, do I see there
> > > are two calls to __alloc_pages_direct_compact and I missed the second
> > > one - perhaps that's why it didn't help.
> > 
> > That is the most likely explanation.
> 
> Perhaps.  But FWIW let me add that before I realized I'd missed the second
> location, I set a run going with my anon_vma hang patch added in - it's had
> plenty of testing in the last week or two, but I'd taken it out because it
> seemed to make hitting this other bug harder.  Indeed: the test was still
> running happily this morning, as if the one bugfix somehow makes the other
> bug much harder to hit (despite the one being entirely about anon pages
> and the other entirely about file pages).  Odd odd odd.
> 

It is possibly explained by your bugfix changing how many anon pages are
possible to migrate. If more anon pages are being migrated due to the bugfix,
it makes it less likely that we are triggering the bug related to file
readahead pages.

> > How about this then? Andrew, if accepted, this should replace the patch
> > mm-vmscan-reclaim-order-0-and-use-compaction-instead-of-lumpy-reclaim-avoid-potential-deadlock-for-readahead-pages-and-direct-compaction.patch
> > in -mm.
> > 
> > ==== CUT HERE ====
> > mm: compaction: Avoid a potential deadlock due to lock_page() during direct compaction
> > 
> > Hugh Dickins reported that two instances of cp were locking up when
> > running on ppc64 in a memory constrained environment. It also affects
> > x86-64 but was harder to reproduce. The deadlock was related to readahead
> > pages. When reading ahead, the pages are added locked to the LRU and queued
> > for IO. The process is also inserting pages into the page cache and so is
> > calling radix_preload and entering the page allocator. When SLUB is used,
> > this can result in direct compaction finding the page that was just added
> > to the LRU but still locked by the current process leading to deadlock.
> > 
> > This patch avoids locking pages in the direct compaction patch because
> > we cannot be certain the current process is not holding the lock. To do
> > this, PF_MEMALLOC is set for compaction. Compaction should not be
> > re-entering the page allocator and so will not breach watermarks through
> > the use of ALLOC_NO_WATERMARKS.
> > 
> > Reported-by: Hugh Dickins <hughd@google.com>
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> Yes, I like this one (and the PF_MEMALLOCs are better here than at the
> outer level where I missed the one earlier).  I do wonder if you'll later
> discover some reason why you were right to hesitate from doing this before,
> but to me it looks like the right answer. 

I'm reasonably sure my original reason was to avoid re-entering the page
allocator and using ALLOC_NO_WATERMARKS but compaction is careful about
not doing any work if watermarks are too low. If the problem does happen,
the result will be a lockup in compaction with 0 free pages in a zone.

> I've not yet tested precisely
> this patch (and the issue is sufficiently elusive that successful tests
> don't give much guarantee anyway - though I may find your tuning tips
> help a lot there), but
> 
> Acked-by: Hugh Dickins <hughd@google.com>
> 

Thanks.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
