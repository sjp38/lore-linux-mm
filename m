Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 823236B0246
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 21:14:51 -0400 (EDT)
Date: Tue, 6 Jul 2010 21:14:28 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 12/14] vmscan: Do not writeback pages in direct reclaim
Message-ID: <20100707011428.GA3630@infradead.org>
References: <20100702125155.69c02f85.akpm@linux-foundation.org>
 <20100705134949.GC13780@csn.ul.ie>
 <20100706093529.CCD1.A69D9226@jp.fujitsu.com>
 <20100706101235.GE13780@csn.ul.ie>
 <AANLkTin8FotAC1GvjuoYU9XA2eiSr6FWWh6bwypTdhq3@mail.gmail.com>
 <20100706152539.GG13780@csn.ul.ie>
 <20100706202758.GC18210@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100706202758.GC18210@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 06, 2010 at 10:27:58PM +0200, Johannes Weiner wrote:
> It bypasses the fs.  On swapon, the blocks are resolved
> (mm/swapfile.c::setup_swap_extents) and then the writeout path uses
> bios directly (mm/page_io.c::swap_writepage).
> 
> (GFP_NOFS still includes __GFP_IO, so allows swapping)

Exactly.  Note that while the stack problems for swap writeout aren't
as bad as for filesystems as the whole allocator / extent map footprint
is missing it might still be an issue.  We still splice the whole block
I/O stack footprint over a random stack that might be filled up a lot.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
