Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id ABAE29000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 05:36:36 -0400 (EDT)
Date: Wed, 28 Sep 2011 10:36:29 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 2/2/4] mm: try to distribute dirty pages fairly across
 zones
Message-ID: <20110928093629.GE11313@suse.de>
References: <1316526315-16801-1-git-send-email-jweiner@redhat.com>
 <1316526315-16801-3-git-send-email-jweiner@redhat.com>
 <20110921160226.1bf74494.akpm@google.com>
 <20110922085242.GA29046@redhat.com>
 <20110923144248.GC2606@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110923144248.GC2606@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@google.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Chris Mason <chris.mason@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, xfs@oss.sgi.com, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Fri, Sep 23, 2011 at 04:42:48PM +0200, Johannes Weiner wrote:
> The maximum number of dirty pages that exist in the system at any time
> is determined by a number of pages considered dirtyable and a
> user-configured percentage of those, or an absolute number in bytes.
> 
> This number of dirtyable pages is the sum of memory provided by all
> the zones in the system minus their lowmem reserves and high
> watermarks, so that the system can retain a healthy number of free
> pages without having to reclaim dirty pages.
> 
> But there is a flaw in that we have a zoned page allocator which does
> not care about the global state but rather the state of individual
> memory zones.  And right now there is nothing that prevents one zone
> from filling up with dirty pages while other zones are spared, which
> frequently leads to situations where kswapd, in order to restore the
> watermark of free pages, does indeed have to write pages from that
> zone's LRU list.  This can interfere so badly with IO from the flusher
> threads that major filesystems (btrfs, xfs, ext4) mostly ignore write
> requests from reclaim already, taking away the VM's only possibility
> to keep such a zone balanced, aside from hoping the flushers will soon
> clean pages from that zone.
> 
> Enter per-zone dirty limits.  They are to a zone's dirtyable memory
> what the global limit is to the global amount of dirtyable memory, and
> try to make sure that no single zone receives more than its fair share
> of the globally allowed dirty pages in the first place.  As the number
> of pages considered dirtyable exclude the zones' lowmem reserves and
> high watermarks, the maximum number of dirty pages in a zone is such
> that the zone can always be balanced without requiring page cleaning.
> 
> As this is a placement decision in the page allocator and pages are
> dirtied only after the allocation, this patch allows allocators to
> pass __GFP_WRITE when they know in advance that the page will be
> written to and become dirty soon.  The page allocator will then
> attempt to allocate from the first zone of the zonelist - which on
> NUMA is determined by the task's NUMA memory policy - that has not
> exceeded its dirty limit.
> 
> At first glance, it would appear that the diversion to lower zones can
> increase pressure on them, but this is not the case.  With a full high
> zone, allocations will be diverted to lower zones eventually, so it is
> more of a shift in timing of the lower zone allocations.  Workloads
> that previously could fit their dirty pages completely in the higher
> zone may be forced to allocate from lower zones, but the amount of
> pages that 'spill over' are limited themselves by the lower zones'
> dirty constraints, and thus unlikely to become a problem.
> 
> For now, the problem of unfair dirty page distribution remains for
> NUMA configurations where the zones allowed for allocation are in sum
> not big enough to trigger the global dirty limits, wake up the flusher
> threads and remedy the situation.  Because of this, an allocation that
> could not succeed on any of the considered zones is allowed to ignore
> the dirty limits before going into direct reclaim or even failing the
> allocation, until a future patch changes the global dirty throttling
> and flusher thread activation so that they take individual zone states
> into account.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
