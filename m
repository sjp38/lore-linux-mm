Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AF86E9000C7
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 09:46:14 -0400 (EDT)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch 0/4] 50% faster writing to your USB drive!*
Date: Tue, 20 Sep 2011 15:45:11 +0200
Message-Id: <1316526315-16801-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Chris Mason <chris.mason@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, xfs@oss.sgi.com, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

*if you use ntfs-3g copy files larger than main memory

or: per-zone dirty limits

There have been several discussions and patches around the issue of
dirty pages being written from page reclaim, that is, they reach the
end of the LRU list before they are cleaned.

Proposed reasons for this are the divergence of dirtying age from page
cache age, on one hand, and unequal distribution of the globally
limited dirty memory across the LRU lists of different zones.

Mel's recent patches to reduce writes from reclaim, by simply skipping
over dirty pages until a certain amount of memory pressure builds up,
do help quite a bit.  But they can only deal with a limited length of
runs of dirty pages before kswapd goes to lower priority levels to
balance the zone and begins writing.

The unequal distribution of dirty memory between zones is easily
observable through the statistics in /proc/zoneinfo, but the test
results varied between filesystems.  To get an overview of where and
how often different page cache pages are created and dirtied, I hacked
together an object tracker that remembers the instantiator of a page
cache page and associates with it the paths that dirty or activate the
page, together with counters that indicate how often those operations
occur.

Btrfs, for example, appears to be activating a significant amount of
regularly written tree data with mark_page_accessed(), even with a
purely linear, page-aligned write load.  So in addition to the already
unbounded dirty memory on smaller zones, this is a divergence between
page age and dirtying age and leads to a situation where the pages
reclaimed next are not the ones that are also flushed next:

		pgactivate
			     min|  median|     max
	      xfs:	   5.000|   6.500|  20.000
	fuse-ntfs:	   5.000|  19.000| 275.000
	     ext4:	   2.000|  67.000| 810.000 
	    btrfs:	2915.000|3316.500|5786.000

ext4's delalloc, on the other hand, refuses regular write attemps from
kjournald, but the write index of the inode is still advanced for
cyclic write ranges and so the pages are not even immediately written
when the inode is selected again.

I cc'd the filesystem people because it is at least conceivable that
things could be improved on their side, but I do think the problem is
mainly with the VM and needs fixing there.

This patch series implements per-zone dirty limits, derived from the
configured global dirty limits and the individual zone size, that the
page allocator uses to distribute pages allocated for writing across
the allowable zones.  Even with pages dirtied out of the inactive LRU
order this gives page reclaim a minimum number of clean pages on each
LRU so that balancing a zone should no longer require writeback in the
common case.

The previous version included code to wake the flushers and stall the
allocation on NUMA setups where the load is bound to a node that is in
itself not large enough to reach the global dirty limits, but I am
still trying to get it to work reliably and dropped it for now, the
series has merits even without it.

			Test results

15M DMA + 3246M DMA32 + 504 Normal = 3765M memory
40% dirty ratio
16G USB thumb drive
10 runs of dd if=/dev/zero of=disk/zeroes bs=32k count=$((10 << 15))

		seconds			nr_vmscan_write
		        (stddev)	       min|     median|        max
xfs
vanilla:	 549.747( 3.492)	     0.000|      0.000|      0.000
patched:	 550.996( 3.802)	     0.000|      0.000|      0.000

fuse-ntfs
vanilla:	1183.094(53.178)	 54349.000|  59341.000|  65163.000
patched:	 558.049(17.914)	     0.000|      0.000|     43.000

btrfs
vanilla:	 573.679(14.015)	156657.000| 460178.000| 606926.000
patched:	 563.365(11.368)	     0.000|      0.000|   1362.000

ext4
vanilla:	 561.197(15.782)	     0.000|2725438.000|4143837.000
patched:	 568.806(17.496)	     0.000|      0.000|      0.000

Even though most filesystems already ignore the write request from
reclaim, we were reluctant in the past to remove it, as it was still
theoretically our only means to stay on top of the dirty pages on a
per-zone basis.  This patchset should get us closer to removing the
dreaded writepage call from page reclaim altogether.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
