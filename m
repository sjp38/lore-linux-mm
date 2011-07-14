Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id AC53390011A
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 02:33:37 -0400 (EDT)
Date: Thu, 14 Jul 2011 07:33:32 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/5] mm: vmscan: Throttle reclaim if encountering too
 many dirty pages under writeback
Message-ID: <20110714063332.GP7529@suse.de>
References: <1310567487-15367-1-git-send-email-mgorman@suse.de>
 <1310567487-15367-4-git-send-email-mgorman@suse.de>
 <20110713234150.GW23038@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110713234150.GW23038@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, Jul 14, 2011 at 09:41:50AM +1000, Dave Chinner wrote:
> On Wed, Jul 13, 2011 at 03:31:25PM +0100, Mel Gorman wrote:
> > Workloads that are allocating frequently and writing files place a
> > large number of dirty pages on the LRU. With use-once logic, it is
> > possible for them to reach the end of the LRU quickly requiring the
> > reclaimer to scan more to find clean pages. Ordinarily, processes that
> > are dirtying memory will get throttled by dirty balancing but this
> > is a global heuristic and does not take into account that LRUs are
> > maintained on a per-zone basis. This can lead to a situation whereby
> > reclaim is scanning heavily, skipping over a large number of pages
> > under writeback and recycling them around the LRU consuming CPU.
> > 
> > This patch checks how many of the number of pages isolated from the
> > LRU were dirty. If a percentage of them are dirty, the process will be
> > throttled if a blocking device is congested or the zone being scanned
> > is marked congested. The percentage that must be dirty depends on
> > the priority. At default priority, all of them must be dirty. At
> > DEF_PRIORITY-1, 50% of them must be dirty, DEF_PRIORITY-2, 25%
> > etc. i.e.  as pressure increases the greater the likelihood the process
> > will get throttled to allow the flusher threads to make some progress.
> 
> It still doesn't take into account how many pages under writeback
> were skipped. If there are lots of pages that are under writeback, I
> think we still want to throttle to give IO a chance to complete and
> clean those pages before scanning again....
> 

An earlier revision did take them into account but in these tests at
least, 0 pages at the end of the LRU were PageWriteback. I expect this
to change when multiple processes and CPUs were in use but am ignoring
it for the moment.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
