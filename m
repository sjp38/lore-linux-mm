Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1FD436B0169
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 16:37:07 -0400 (EDT)
Date: Mon, 25 Jul 2011 13:37:05 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [patch 4/5] mm: writeback: throttle __GFP_WRITE on per-zone
 dirty limits
Message-ID: <20110725203705.GA21691@tassilo.jf.intel.com>
References: <1311625159-13771-1-git-send-email-jweiner@redhat.com>
 <1311625159-13771-5-git-send-email-jweiner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1311625159-13771-5-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org

> The global dirty limits are put in proportion to the respective zone's
> amount of dirtyable memory and the allocation denied when the limit of
> that zone is reached.
> 
> Before the allocation fails, the allocator slowpath has a stage before
> compaction and reclaim, where the flusher threads are kicked and the
> allocator ultimately has to wait for writeback if still none of the
> zones has become eligible for allocation again in the meantime.
> 

I don't really like this. It seems wrong to make memory
placement depend on dirtyness.

Just try to explain it to some system administrator or tuner: her 
head will explode and for good reasons.

On the other hand I like doing round-robin in filemap by default
(I think that is what your patch essentially does)
We should have made  this default long ago. It avoids most of the
"IO fills up local node" problems people run into all the time.

So I would rather just change the default in filemap allocation.

That's also easy to explain.

BTW the original argument why this wasn't done was that it may
be a problem on extremly large systems, but I think it's reasonable
to let these oddballs change their defaults instead of letting
everyone else handle them.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
