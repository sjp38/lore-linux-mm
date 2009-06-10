Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 45BD86B005D
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 05:58:52 -0400 (EDT)
Date: Wed, 10 Jun 2009 11:00:40 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/3] Reintroduce zone_reclaim_interval for when
	zone_reclaim() scans and fails to avoid CPU spinning at 100% on NUMA
Message-ID: <20090610100040.GE25943@csn.ul.ie>
References: <1244466090-10711-1-git-send-email-mel@csn.ul.ie> <1244466090-10711-2-git-send-email-mel@csn.ul.ie> <4A2D129D.3020309@redhat.com> <20090608135433.GD15070@csn.ul.ie> <alpine.DEB.1.10.0906081033060.21954@gentwo.org> <20090608143857.GG15070@csn.ul.ie> <alpine.DEB.1.10.0906081055170.21954@gentwo.org> <20090608151151.GI15070@csn.ul.ie> <20090609222301.8da002ae.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090609222301.8da002ae.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 09, 2009 at 10:23:01PM -0700, Andrew Morton wrote:
> On Mon, 8 Jun 2009 16:11:51 +0100 Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > On Mon, Jun 08, 2009 at 10:55:55AM -0400, Christoph Lameter wrote:
> > > On Mon, 8 Jun 2009, Mel Gorman wrote:
> > > 
> > > > > The tmpfs pages are unreclaimable and therefore should not be on the anon
> > > > > lru.
> > > > >
> > > >
> > > > tmpfs pages can be swap-backed so can be reclaimable. Regardless of what
> > > > list they are on, we still need to know how many of them there are if
> > > > this patch is to be avoided.
> > > 
> > > If they are reclaimable then why does it matter? They can be pushed out if
> > > you configure zone reclaim to be that aggressive.
> > > 
> > 
> > Because they are reclaimable by kswapd or normal direct reclaim but *not*
> > reclaimable by zone_reclaim() if the zone_reclaim_mode is not configured
> > appropriately.
> 
> Ah.  (zone_reclaim_mode & RECLAIM_SWAP) == 0.  That was important info.
> 

Yes, zone_reclaim() is a different beast to kswapd or traditional direct
reclaim.

> Couldn't the lack of RECLAIM_WRITE cause a similar problem?
> 

Potentially, yes.

> > I briefly considered setting zone_reclaim_mode to 7 instead of
> > 1 by default for large NUMA distances but that has other serious consequences
> > such as paging in preference to going off-node as a default out-of-box
> > behaviour.
> 
> Maybe we should consider that a bit harder.  At what stage does
> zone_reclaim decide to give up and try a different node?  Perhaps it's
> presently too reluctant to do that?
> 

It decides to give up if it can't reclaim a number of pages
(SWAP_CLUSTER_MAX usually) with the current reclaim_mode. In practice,
that means it will go off-node if there are not enough clean unmapped
pages on the LRU list for that node.

That is a relatively short delay. If the request had to clean filesystem-backed
pages or unmap+swap pages, the cost would likely exceed the sum of all
remote-node accesses for that page.

I think in principal, the zone_reclaim_mode default of 1 is sensible and
the biggest thing this patchset needs to get right is the scan-avoidance
heuristic.

> > The point of the patch is that the heuristics that avoid the scan are not
> > perfect. In the event they are wrong and a useless scan occurs, the response
> > of the kernel after a useless scan should not be to uselessly scan a load
> > more times around the LRU lists making no progress.
> 
> It would be sad to bring back a jiffies-based thing into page reclaim. 
> Wall time has little correlation with the rate of page allocation and
> reclaim activity.
> 

Agreed. If it turns out a patch like this is needed, I'm going to build
on Wu's suggestion to auto-selecting the zone_reclaim_interval based on
scan frequency and how long it takes to do the scan. I'm still hoping that
neither is necessary because we'll be able to guess the number of tmpfs
pages in advance.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
