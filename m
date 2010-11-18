Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0E4626B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 04:21:00 -0500 (EST)
Date: Thu, 18 Nov 2010 09:20:44 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/8] Use memory compaction instead of lumpy reclaim
	during high-order allocations
Message-ID: <20101118092044.GE8135@csn.ul.ie>
References: <1290010969-26721-1-git-send-email-mel@csn.ul.ie> <20101117154641.51fd7ce5.akpm@linux-foundation.org> <20101118081254.GB8135@csn.ul.ie> <20101118172627.cf25b83a.kamezawa.hiroyu@jp.fujitsu.com> <20101118083828.GA24635@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101118083828.GA24635@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 09:38:28AM +0100, Johannes Weiner wrote:
> On Thu, Nov 18, 2010 at 05:26:27PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Thu, 18 Nov 2010 08:12:54 +0000
> > Mel Gorman <mel@csn.ul.ie> wrote:
> > 
> > > > > I'm hoping that this series also removes the
> > > > > necessity for the "delete lumpy reclaim" patch from the THP tree.
> > > > 
> > > > Now I'm sad.  I read all that and was thinking "oh goody, we get to
> > > > delete something for once".  But no :(
> > > > 
> > > > If you can get this stuff to work nicely, why can't we remove lumpy
> > > > reclaim?
> > > 
> > > Ultimately we should be able to. Lumpy reclaim is still there for the
> > > !CONFIG_COMPACTION case and to have an option if we find that compaction
> > > behaves badly for some reason.
> > > 
> > 
> > Hmm. CONFIG_COMPACTION depends on CONFIG_MMU. lumpy reclaim will be for NOMMU,
> > finally ?
> 
> It's because migration depends on MMU.  But we should be able to make
> a NOMMU version of migration that just does page cache, which is all
> that is reclaimable on NOMMU anyway.
> 

Conceivably, but I see little problem leaving them with lumpy reclaim. As
page cache and anon pages are mixed together in MIGRATE_MOVABLE but only one
set of pages can be discarded, the success rates of either lumpy reclaim or
compaction is doubtful. It'd require a specific investigation.

> At this point, the MMU dependency can go away, and so can lumpy
> reclaim.
> 

The series never calls lumpy reclaim once CONFIG_COMPACTION is set. The code
could be shrunk with the below patch but the saving to vmlinux is minimal
(288 bytes for me on x86-64). My preference is still to have lumpy reclaim
available as a comparison point with compaction for a development cycle or two.

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 52a0f0c..7488983 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1048,7 +1048,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			BUG();
 		}
 
-		if (!order)
+		if (!order || COMPACTION_BUILD)
 			continue;
 
 		/*

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
