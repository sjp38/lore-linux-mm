Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 610536B0022
	for <linux-mm@kvack.org>; Wed, 18 May 2011 20:29:01 -0400 (EDT)
Date: Thu, 19 May 2011 10:28:55 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 2/2] mm: vmscan: If kswapd has been running too long,
 allow it to sleep
Message-ID: <20110519002855.GD32466@dastard>
References: <1305558417-24354-1-git-send-email-mgorman@suse.de>
 <1305558417-24354-3-git-send-email-mgorman@suse.de>
 <20110516141654.2728f05a.akpm@linux-foundation.org>
 <1305614225.6008.19.camel@mulgrave.site>
 <20110517162226.96974d89.akpm@linux-foundation.org>
 <20110518094718.GP5279@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110518094718.GP5279@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, stable <stable@kernel.org>

On Wed, May 18, 2011 at 10:47:18AM +0100, Mel Gorman wrote:
> As we are aggressively shrinking slab, we can reach the stage where
> we scan the requested number of objects and reclaim none of them
> potentially setting zone->all_unreclaimable to 1 if a lot of scanning
> has also taken place recently without pages being freed. Once this
> happens, kswapd isn't even trying to reclaim pages and is instead stuck
> in shrink_slab until a page is freed clearing zone->all_unreclaimable
> and zone->pages-scanned.

Isn't this completely broken then? We can have slabs with lots of
objects but none are reclaimable - e.g. dirty inodes are not even on
the inode LRU and require IO to get there, so repeatedly scanning
the slab trying to free inodes is completely pointless.

If the shrinkers are not freeing anything, then it should be backing
off and giving thme some time to clean objects is a much more
efficient use of CPU time than spinning madly. Indeed, if you back
off, you can do another pass over the LRU and see if there are more
pages that can be reclaimed, too, so you're not dependent on the
shrinkers actually making progress to break the livelock....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
