Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D8C8E6B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 09:52:07 -0400 (EDT)
Date: Mon, 8 Jun 2009 16:11:51 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/3] Reintroduce zone_reclaim_interval for when
	zone_reclaim() scans and fails to avoid CPU spinning at 100% on NUMA
Message-ID: <20090608151151.GI15070@csn.ul.ie>
References: <1244466090-10711-1-git-send-email-mel@csn.ul.ie> <1244466090-10711-2-git-send-email-mel@csn.ul.ie> <4A2D129D.3020309@redhat.com> <20090608135433.GD15070@csn.ul.ie> <alpine.DEB.1.10.0906081033060.21954@gentwo.org> <20090608143857.GG15070@csn.ul.ie> <alpine.DEB.1.10.0906081055170.21954@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0906081055170.21954@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 08, 2009 at 10:55:55AM -0400, Christoph Lameter wrote:
> On Mon, 8 Jun 2009, Mel Gorman wrote:
> 
> > > The tmpfs pages are unreclaimable and therefore should not be on the anon
> > > lru.
> > >
> >
> > tmpfs pages can be swap-backed so can be reclaimable. Regardless of what
> > list they are on, we still need to know how many of them there are if
> > this patch is to be avoided.
> 
> If they are reclaimable then why does it matter? They can be pushed out if
> you configure zone reclaim to be that aggressive.
> 

Because they are reclaimable by kswapd or normal direct reclaim but *not*
reclaimable by zone_reclaim() if the zone_reclaim_mode is not configured
appropriately. I briefly considered setting zone_reclaim_mode to 7 instead of
1 by default for large NUMA distances but that has other serious consequences
such as paging in preference to going off-node as a default out-of-box
behaviour.

The point of the patch is that the heuristics that avoid the scan are not
perfect. In the event they are wrong and a useless scan occurs, the response
of the kernel after a useless scan should not be to uselessly scan a load
more times around the LRU lists making no progress.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
