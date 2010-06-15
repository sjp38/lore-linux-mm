Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7D5766B021C
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 09:08:18 -0400 (EDT)
Date: Tue, 15 Jun 2010 09:07:39 -0400
From: tytso@mit.edu
Subject: Re: [PATCH 11/12] vmscan: Write out dirty pages in batch
Message-ID: <20100615130739.GM6666@thunk.org>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
 <1276514273-27693-12-git-send-email-mel@csn.ul.ie>
 <20100614231144.GG6590@dastard>
 <20100614162143.04783749.akpm@linux-foundation.org>
 <20100615003943.GK6590@dastard>
 <20100614183957.ad0cdb58.akpm@linux-foundation.org>
 <20100615032034.GR6590@dastard>
 <20100614211515.dd9880dc.akpm@linux-foundation.org>
 <20100615114342.GD26788@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100615114342.GD26788@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2010 at 12:43:42PM +0100, Mel Gorman wrote:
> 
> I'll do this just to see what it looks like. To be frank, I lack
> taste when it comes to how the block layer and filesystem should
> behave so am having troube deciding if sorting the pages prior to
> submission is a good thing or if it would just encourage bad or lax
> behaviour in the IO submission queueing.
> 

I suspect the right answer is we need to sort both at the block layer
and either (a) before you pass things to the filesystem layer, or if
you don't do that (b) the filesystem will be forced to do its own
queuing/sorting at the very least for delayed allocation pages, so the
allocator can do something sane.  And given that there are multiple
file systems that support delayed allocation, it would be nice if this
could be recognized by the writeback code, as opposed to having btrfs,
xfs, ext4, all having to implement something very similar at the fs
layer.

							- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
