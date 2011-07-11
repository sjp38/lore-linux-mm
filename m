Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AB5056B004A
	for <linux-mm@kvack.org>; Mon, 11 Jul 2011 07:10:47 -0400 (EDT)
Date: Mon, 11 Jul 2011 07:10:39 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 03/27] xfs: use write_cache_pages for writeback clustering
Message-ID: <20110711111039.GA3139@infradead.org>
References: <20110629140109.003209430@bombadil.infradead.org>
 <20110629140336.950805096@bombadil.infradead.org>
 <20110701022248.GM561@dastard>
 <20110701041851.GN561@dastard>
 <20110701093305.GA28531@infradead.org>
 <20110701154136.GA17881@localhost>
 <20110704032534.GD1026@dastard>
 <20110705143409.GB15285@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110705143409.GB15285@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Jul 05, 2011 at 03:34:10PM +0100, Mel Gorman wrote:
> > However, what I'm questioning is whether we should even care what
> > page memory reclaim wants to write - it seems to make fundamentally
> > bad decisions from an IO persepctive.
> > 
> 
> It sucks from an IO perspective but from the perspective of the VM that
> needs memory to be free in a particular zone or node, it's a reasonable
> request.

It might appear reasonable, but it's not.

What the VM wants underneath is generally (1):

 - free N pages in zone Z

and it then goes own to free the pages one one by one though kswapd,
which leads to freeing those N pages, but unless they already were
clean it will take very long to get there and bog down the whole
system.

So we need a better way to actually perform that underlying request.
Dave's suggestion of keeping different lists for clean vs dirty pages
in the VM and preferably reclaiming for the clean ones when having
zone pressure is one first step.  The second one will be to tell the
writeback threads to preferably reclaim from a zone.  I'm actually
not sure how do that yet, as we could have memory from different
zones on a single inode.  Taking an inode that has memory from the
right zone and the writing that out will probably work fine for
different zones in a 64-bit NUMA systems where zones more or less
equal nodes.  It probably won't work very well if we need to free
up memory in the various low memory zones, as those will be spread
over random inodes.

> It doesnt' check how many pages are under writeback. Direct reclaim
> will check if the block device is congested but that is about
> it. Otherwise the expectation was the elevator would handle the
> merging of requests into a sensible patter.

It can't.  The elevator has a relatively small window it can operate
on, and can never fix up a bad large scale writeback pattern. 

> Also, while filesystem
> pages are getting cleaned by flushs, that does not cover anonymous
> pages being written to swap.

At least for now we will have to keep kswapd writeback for swap.  It
is just as inefficient a on a filesystem, but given that people don't
rely on swap performance we can probably live with it.  Note that we
can't simply use background flushing for swap, as that would mean
we'd need backing space allocated for all main memory, which isn't
very practical with todays memory sized.  The whole concept of demand
paging anonymous memory leads to pretty bad I/O patterns.  If you're
actually making heavy use of it the old-school unix full process paging
would be a lot faster.

(1) moulo things like compaction

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
