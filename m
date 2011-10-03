Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0461F9000C7
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 07:22:14 -0400 (EDT)
Date: Mon, 3 Oct 2011 12:22:05 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 1/5] mm: exclude reserved pages from dirtyable memory
Message-ID: <20111003112205.GA5011@suse.de>
References: <1317367044-475-1-git-send-email-jweiner@redhat.com>
 <1317367044-475-2-git-send-email-jweiner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1317367044-475-2-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Chris Mason <chris.mason@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Shaohua Li <shaohua.li@intel.com>, xfs@oss.sgi.com, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Sep 30, 2011 at 09:17:20AM +0200, Johannes Weiner wrote:
> The amount of dirtyable pages should not include the full number of
> free pages: there is a number of reserved pages that the page
> allocator and kswapd always try to keep free.
> 
> The closer (reclaimable pages - dirty pages) is to the number of
> reserved pages, the more likely it becomes for reclaim to run into
> dirty pages:
> 
>        +----------+ ---
>        |   anon   |  |
>        +----------+  |
>        |          |  |
>        |          |  -- dirty limit new    -- flusher new
>        |   file   |  |                     |
>        |          |  |                     |
>        |          |  -- dirty limit old    -- flusher old
>        |          |                        |
>        +----------+                       --- reclaim
>        | reserved |
>        +----------+
>        |  kernel  |
>        +----------+
> 
> This patch introduces a per-zone dirty reserve that takes both the
> lowmem reserve as well as the high watermark of the zone into account,
> and a global sum of those per-zone values that is subtracted from the
> global amount of dirtyable pages.  The lowmem reserve is unavailable
> to page cache allocations and kswapd tries to keep the high watermark
> free.  We don't want to end up in a situation where reclaim has to
> clean pages in order to balance zones.
> 
> Not treating reserved pages as dirtyable on a global level is only a
> conceptual fix.  In reality, dirty pages are not distributed equally
> across zones and reclaim runs into dirty pages on a regular basis.
> 
> But it is important to get this right before tackling the problem on a
> per-zone level, where the distance between reclaim and the dirty pages
> is mostly much smaller in absolute numbers.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>

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
