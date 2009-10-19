Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 96B1A6B004F
	for <linux-mm@kvack.org>; Sun, 18 Oct 2009 20:36:19 -0400 (EDT)
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <200910190133.33183.elendil@planet.nl>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera>
	 <20091014103002.GA5027@csn.ul.ie> <200910141510.11059.elendil@planet.nl>
	 <200910190133.33183.elendil@planet.nl>
Date: Mon, 19 Oct 2009 03:36:02 +0300
Message-Id: <1255912562.6824.9.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: Mel Gorman <mel@csn.ul.ie>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

(Adding Jens to CC.)

On Wednesday 14 October 2009, Frans Pop wrote:
> > > There still has not been a mm-change identified that makes
> > > fragmentation significantly worse.

On Mon, 2009-10-19 at 01:33 +0200, Frans Pop wrote:
> > My bisection shows a very clear point, even if not an individual commit,
> > in the 'akpm' merge where SKB errors suddenly become *much* more
> > frequent and easy to trigger.
> > I'm sorry to say this, but the fact that nothing has been identified yet
> > is IMO the result of a lack of effort, not because there is no such
> > change.
> 
> I was wrong. It turns out that I was creating the variations in the test 
> results around the akpm merge myself by tiny changes in the way I ran the 
> tests. It took another round of about 30 compilations and tests purely in 
> this range to show that, but those same tests also made me aware of other 
> patterns I should look at.
> 
> Until a few days ago I was concentrating on "do I see SKB allocation errors 
> or not". Since then I've also been looking more consciously at when they 
> happen, at disk access patterns and at desktop freeze patterns.
> 
> I think I did mention before that this whole issue is rather subtle :-/
> So, my apologies for finguering the wrong area for so long, but it looked 
> solid given the info available at the time.
> 
> On Thursday 15 October 2009, Mel Gorman wrote:
> > Outside the range of commits suspected of causing problems was the
> > following. It's extremely low probability
> >
> > Commit 8aa7e84 Fix congestion_wait() sync/async vs read/write confusion
> >         This patch alters the call to congestion_wait() in the page
> >         allocator. Frankly, I don't get the change but it might worth
> >         checking if replacing BLK_RW_ASYNC with WRITE on top of 2.6.31
> >         makes any difference
> 
> This is the real culprit. Mel: thanks very much for looking beyond the 
> area I identified. Your overview of mm changes was exactly what I needed 
> and really helped a lot during my later tests.
> 
> This commit definitely causes most of the problems; confirmed by reverting 
> it on top of 2.6.31 (also requires reverting 373c0a7e, which is a later 
> build fix).

Mel/Jens, any ideas why commit 8aa7e84 makes us run out of high order
pages? Should we be using BLK_RW_SYNC in mm/page_alloc.c instead of
BLK_RW_ASYNC?

			Pekka

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bf72055..fa8380a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1727,7 +1727,7 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 			preferred_zone, migratetype);
 
 		if (!page && gfp_mask & __GFP_NOFAIL)
-			congestion_wait(BLK_RW_ASYNC, HZ/50);
+			congestion_wait(BLK_RW_SYNC, HZ/50);
 	} while (!page && (gfp_mask & __GFP_NOFAIL));
 
 	return page;
@@ -1898,7 +1898,7 @@ rebalance:
 	pages_reclaimed += did_some_progress;
 	if (should_alloc_retry(gfp_mask, order, pages_reclaimed)) {
 		/* Wait for some write requests to complete then retry */
-		congestion_wait(BLK_RW_ASYNC, HZ/50);
+		congestion_wait(BLK_RW_SYNC, HZ/50);
 		goto rebalance;
 	}
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
