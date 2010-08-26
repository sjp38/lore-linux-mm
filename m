Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA416B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 16:23:41 -0400 (EDT)
Date: Thu, 26 Aug 2010 21:23:24 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] writeback: Do not congestion sleep when there are
	no congested BDIs
Message-ID: <20100826202324.GK20944@csn.ul.ie>
References: <1282835656-5638-1-git-send-email-mel@csn.ul.ie> <1282835656-5638-4-git-send-email-mel@csn.ul.ie> <20100826173843.GD6873@barrios-desktop> <20100826174245.GJ20944@csn.ul.ie> <20100826181735.GB6805@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100826181735.GB6805@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 26, 2010 at 08:17:35PM +0200, Johannes Weiner wrote:
> On Thu, Aug 26, 2010 at 06:42:45PM +0100, Mel Gorman wrote:
> > On Fri, Aug 27, 2010 at 02:38:43AM +0900, Minchan Kim wrote:
> > > On Thu, Aug 26, 2010 at 04:14:16PM +0100, Mel Gorman wrote:
> > > > If congestion_wait() is called with no BDIs congested, the caller will
> > > > sleep for the full timeout and this is an unnecessary sleep. This patch
> > > > checks if there are BDIs congested. If so, it goes to sleep as normal.
> > > > If not, it calls cond_resched() to ensure the caller is not hogging the
> > > > CPU longer than its quota but otherwise will not sleep.
> > > > 
> > > > This is aimed at reducing some of the major desktop stalls reported during
> > > > IO. For example, while kswapd is operating, it calls congestion_wait()
> > > > but it could just have been reclaiming clean page cache pages with no
> > > > congestion. Without this patch, it would sleep for a full timeout but after
> > > > this patch, it'll just call schedule() if it has been on the CPU too long.
> > > > Similar logic applies to direct reclaimers that are not making enough
> > > > progress.
> > > > 
> > > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > > ---
> > > >  mm/backing-dev.c |   20 ++++++++++++++------
> > > >  1 files changed, 14 insertions(+), 6 deletions(-)
> > > > 
> > > > diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> > > > index a49167f..6abe860 100644
> > > > --- a/mm/backing-dev.c
> > > > +++ b/mm/backing-dev.c
> > > 
> > > Function's decripton should be changed since we don't wait next write any more. 
> > > 
> > 
> > My bad. I need to check that "next write" thing. It doesn't appear to be
> > happening but maybe that side of things just broke somewhere in the
> > distant past. I lack context of how this is meant to work so maybe
> > someone will educate me.
> 
> On every retired io request the congestion state on the bdi is checked
> and the congestion waitqueue woken up.
> 
> So without congestion, we still only wait until the next write
> retires, but without any IO, we sleep the full timeout.
> 
> Check __freed_requests() in block/blk-core.c.
> 

Seems reasonable. Still, if there is no write IO going on and no
congestion there seems to be no point going to sleep for the full
timeout. It still feels wrong.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
