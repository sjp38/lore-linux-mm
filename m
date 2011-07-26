Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EF04D6B0169
	for <linux-mm@kvack.org>; Tue, 26 Jul 2011 05:35:23 -0400 (EDT)
Date: Tue, 26 Jul 2011 10:35:17 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch] mm: thp: disable defrag for page faults per default
Message-ID: <20110726093517.GA3010@suse.de>
References: <1311626321-14364-1-git-send-email-jweiner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1311626321-14364-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 25, 2011 at 10:38:41PM +0200, Johannes Weiner wrote:
> With defrag mode enabled per default, huge page allocations pass
> __GFP_WAIT and may drop compaction into sync-mode where they wait for
> pages under writeback.
> 
> I observe applications hang for several minutes(!) when they fault in
> huge pages and compaction starts to wait on in-"flight" USB stick IO.
> 
> This patch disables defrag mode for page fault allocations unless the
> VMA is madvised explicitely.  Khugepaged will continue to allocate
> with __GFP_WAIT per default, but stalls are not a problem of
> application responsiveness there.
> 

Seems drastic. You could just avoid sync migration for transparent
hugepage allocations with something like the patch below? There still
is a stall as some order-0 pages will be reclaimed before compaction
is tried again but it will nothing like a sync migration.

=== CUT HERE ===
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1fac154..40f2a9b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2174,7 +2174,14 @@ rebalance:
 					sync_migration);
 	if (page)
 		goto got_pg;
-	sync_migration = true;
+
+	/*
+	 * Do not use sync migration for transparent hugepage allocations as
+	 * it could stall writing back pages which is far worse than simply
+	 * failing to promote a page.
+	 */
+	if (!(gfp_mask & __GFP_NO_KSWAPD))
+		sync_migration = true;
 
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order,
=== CUT HERE===

As this is USB, the rate of pages getting written back may mean that
too much clean memory is reclaimed in direct reclaim while compaction
still fails due to dirty pages. If this is the case, it can be mitigated
with something like this before calling direct reclaim;

if ((gfp_mask & __GFP_NO_KSWAPD) && compaction_deferred(preferred_zone))
	goto nopage;

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
