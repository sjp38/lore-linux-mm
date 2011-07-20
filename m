Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DAC3C6B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 17:17:45 -0400 (EDT)
Date: Wed, 20 Jul 2011 16:17:41 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] mm: page allocator: Initialise ZLC for first zone
 eligible for zone_reclaim
In-Reply-To: <alpine.DEB.2.00.1107201443400.1472@router.home>
Message-ID: <alpine.DEB.2.00.1107201617050.1472@router.home>
References: <1310742540-22780-1-git-send-email-mgorman@suse.de> <1310742540-22780-2-git-send-email-mgorman@suse.de> <alpine.DEB.2.00.1107180951390.30392@router.home> <20110718160552.GB5349@suse.de> <alpine.DEB.2.00.1107181208050.31576@router.home>
 <20110718211325.GC5349@suse.de> <alpine.DEB.2.00.1107181651000.31576@router.home> <alpine.DEB.2.00.1107190901120.1199@router.home> <alpine.DEB.2.00.1107201307530.1472@router.home> <20110720191858.GO5349@suse.de> <alpine.DEB.2.00.1107201425200.1472@router.home>
 <alpine.DEB.2.00.1107201443400.1472@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hmmm... Maybe we can bypass the checks?

Subject: [page allocator] Do not check watermarks if there is a page available on the per cpu freelists

One should be able to grab a page from the per cpu freelists if available.
The pages on the per cpu freelists are not accounted for in VM statistics
so getting a page from there has no impact on reclaim.

Check for this condition in get_page_from_freelist and short circuit
to the call to buffered_rmqueue if so.

Note that there is a race here. We may deplete the reserve pools by
one page if either the process is rescheduled on a different processor
or if another process grabs the last page from the per cpu freelist.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/page_alloc.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2011-07-20 15:27:20.544825852 -0500
+++ linux-2.6/mm/page_alloc.c	2011-07-20 15:30:05.314824797 -0500
@@ -1666,6 +1666,16 @@ zonelist_scan:
 			!cpuset_zone_allowed_softwall(zone, gfp_mask))
 				goto try_next_zone;

+		/*
+		 * Short circuit allocation if we have a usable object on
+		 * the percpu freelist. Note that this can only be an
+		 * optimization since there is no guarantee that we will
+		 * be executing on the same cpu. Another process could also
+		 * be scheduled and take the available page from us.
+		 */
+		if (order == 0 && this_cpu_read(zone->pageset->pcp.count))
+			goto try_this_zone;
+
 		BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
 		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
 			unsigned long mark;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
