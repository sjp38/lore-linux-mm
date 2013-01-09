Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id C7EE86B005D
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 08:37:51 -0500 (EST)
Date: Wed, 9 Jan 2013 13:37:46 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Message-ID: <20130109133746.GD13304@suse.de>
References: <20121228014503.GA5017@dcvr.yhbt.net>
 <20130102200848.GA4500@dcvr.yhbt.net>
 <20130104160148.GB3885@suse.de>
 <20130106120700.GA24671@dcvr.yhbt.net>
 <20130107122516.GC3885@suse.de>
 <20130107223850.GA21311@dcvr.yhbt.net>
 <20130108224313.GA13304@suse.de>
 <20130108232325.GA5948@dcvr.yhbt.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130108232325.GA5948@dcvr.yhbt.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Wong <normalperson@yhbt.net>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Jan 08, 2013 at 11:23:25PM +0000, Eric Wong wrote:
> Mel Gorman <mgorman@suse.de> wrote:
> > Please try the following patch. However, even if it works the benefit of
> > capture may be so marginal that partially reverting it and simplifying
> > compaction.c is the better decision.
> 
> I already got my VM stuck on this one.  I had two twosleepy instances,
> 2774 was the one that got stuck (also confirmed by watching top).
> 

page->pfmemalloc can be left set for captured pages so try this but as
capture is rarely used I'm strongly favouring a partial revert even if
this works for you. I haven't reproduced this using your workload yet
but I have found that high-order allocation stress tests for 3.8-rc2 are
completely screwed. 71% success rates at rest in 3.7 and 6% in 3.8-rc2 so
I have to chase that down too.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9d20c13..c242d21 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2180,8 +2180,10 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	current->flags &= ~PF_MEMALLOC;
 
 	/* If compaction captured a page, prep and use it */
-	if (page && !prep_new_page(page, order, gfp_mask))
+	if (page && !prep_new_page(page, order, gfp_mask)) {
+		page->pfmemalloc = false;
 		goto got_page;
+	}
 
 	if (*did_some_progress != COMPACT_SKIPPED) {
 		/* Page migration frees to the PCP lists but we want merging */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
