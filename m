Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id DDF9C6B0037
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 06:14:31 -0400 (EDT)
Date: Tue, 19 Mar 2013 10:14:28 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 03/10] mm: vmscan: Flatten kswapd priority loop
Message-ID: <20130319101428.GD2055@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-4-git-send-email-mgorman@suse.de>
 <5147D6A7.5060008@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5147D6A7.5060008@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Mar 19, 2013 at 11:08:23AM +0800, Simon Jeons wrote:
> Hi Mel,
> On 03/17/2013 09:04 PM, Mel Gorman wrote:
> >kswapd stops raising the scanning priority when at least SWAP_CLUSTER_MAX
> >pages have been reclaimed or the pgdat is considered balanced. It then
> >rechecks if it needs to restart at DEF_PRIORITY and whether high-order
> >reclaim needs to be reset. This is not wrong per-se but it is confusing
> 
> per-se is short for what?
> 

It means "in self" or "as such".

> >to follow and forcing kswapd to stay at DEF_PRIORITY may require several
> >restarts before it has scanned enough pages to meet the high watermark even
> >at 100% efficiency. This patch irons out the logic a bit by controlling
> >when priority is raised and removing the "goto loop_again".
> >
> >This patch has kswapd raise the scanning priority until it is scanningmm: vmscan: Flatten kswapd priority loop
> >enough pages that it could meet the high watermark in one shrink of the
> >LRU lists if it is able to reclaim at 100% efficiency. It will not raise
> 
> Which kind of reclaim can be treated as 100% efficiency?
> 

100% efficiency is where every page scanned can be reclaimed immediately.

> >  		/*
> >-		 * We do this so kswapd doesn't build up large priorities for
> >-		 * example when it is freeing in parallel with allocators. It
> >-		 * matches the direct reclaim path behaviour in terms of impact
> >-		 * on zone->*_priority.
> >+		 * Fragmentation may mean that the system cannot be rebalanced
> >+		 * for high-order allocations in all zones. If twice the
> >+		 * allocation size has been reclaimed and the zones are still
> >+		 * not balanced then recheck the watermarks at order-0 to
> >+		 * prevent kswapd reclaiming excessively. Assume that a
> >+		 * process requested a high-order can direct reclaim/compact.
> >  		 */
> >-		if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
> >-			break;
> >-	} while (--sc.priority >= 0);
> >+		if (order && sc.nr_reclaimed >= 2UL << order)
> >+			order = sc.order = 0;
> 
> If order == 0 is meet, should we do defrag for it?
> 

Compaction is unnecessary for order-0.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
