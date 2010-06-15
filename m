Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5660F6B0211
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 07:08:47 -0400 (EDT)
Date: Tue, 15 Jun 2010 07:08:19 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 11/12] vmscan: Write out dirty pages in batch
Message-ID: <20100615110819.GE31051@infradead.org>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
 <1276514273-27693-12-git-send-email-mel@csn.ul.ie>
 <20100614231144.GG6590@dastard>
 <20100614162143.04783749.akpm@linux-foundation.org>
 <20100615003943.GK6590@dastard>
 <20100614183957.ad0cdb58.akpm@linux-foundation.org>
 <20100615032034.GR6590@dastard>
 <20100614211515.dd9880dc.akpm@linux-foundation.org>
 <20100615063643.GS6590@dastard>
 <20100615102822.GA4010@ioremap.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100615102822.GA4010@ioremap.net>
Sender: owner-linux-mm@kvack.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2010 at 02:28:22PM +0400, Evgeniy Polyakov wrote:
> That doesn't coverup large-number-of-small-files pattern, since
> untarring subsequently means creating something new, which FS can
> optimize. Much more interesting case is when we have dirtied large
> number of small files in kind-of random order and submitted them
> down to disk.

That's why we still have block layer sorting.  But for the problem
of larger files doing the sorting above the filesystem is a lot
more efficient, not just primarily due to the I/O patters but because
it makes life for the filesystem writeback code and allocator a lot
simpler.

> Per-mapping sorting will not do anything good in this case, even if
> files were previously created in a good facion being placed closely and
> so on, and only block layer will find a correlation between adjacent
> blocks in different files. But with existing queue management it has
> quite a small opportunity, and that's what I think Andrew is arguing
> about.

Which is actually more or less true - if we do larger amounts of
writeback from kswapd we're toast anyway and performance and allocation
patters go down the toilet.  Then again throwing a list_sort in is
a rather trivial addition.  Note that in addition to page->index we
can also sort by the inode number in the sort function.  At least for
XFS and the traditional ufs derived allocators that will give you
additional locality for small files.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
