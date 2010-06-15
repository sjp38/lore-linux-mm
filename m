Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E810A6B0214
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 07:10:34 -0400 (EDT)
Date: Tue, 15 Jun 2010 07:10:26 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 11/12] vmscan: Write out dirty pages in batch
Message-ID: <20100615111026.GF31051@infradead.org>
References: <1276514273-27693-12-git-send-email-mel@csn.ul.ie>
 <20100614231144.GG6590@dastard>
 <20100614162143.04783749.akpm@linux-foundation.org>
 <20100615003943.GK6590@dastard>
 <20100614183957.ad0cdb58.akpm@linux-foundation.org>
 <20100615032034.GR6590@dastard>
 <20100614211515.dd9880dc.akpm@linux-foundation.org>
 <20100615063643.GS6590@dastard>
 <20100615102822.GA4010@ioremap.net>
 <20100615105538.GI6138@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100615105538.GI6138@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Evgeniy Polyakov <zbr@ioremap.net>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2010 at 08:55:38PM +1000, Nick Piggin wrote:
> 
> What I do in fsblock is to maintain a block-nr sorted tree of dirty
> blocks. This works nicely because fsblock dirty state is properly
> synchronized with page dirty state. So writeout can just walk this in
> order and it provides pretty optimal submission pattern of any
> interleavings of data and metadata. No need for buffer boundary or
> hacks like that. (needs some intelligence for delalloc, though).

I think worrying about indirect blocks really doesn't matter much
these days.  For one thing extent based filesystems have a lot less
of these, and second for a journaling filesystem we only need to log
modification to the indirect blocks and not actually write them back
in place during the sync.  At least for XFS the actual writeback can
happen a lot later, as part of the ordered list of delwri buffers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
