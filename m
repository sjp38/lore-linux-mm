Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 688D66B0210
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 07:01:10 -0400 (EDT)
Date: Tue, 15 Jun 2010 07:01:02 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 11/12] vmscan: Write out dirty pages in batch
Message-ID: <20100615110102.GD31051@infradead.org>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
 <1276514273-27693-12-git-send-email-mel@csn.ul.ie>
 <20100614231144.GG6590@dastard>
 <20100614162143.04783749.akpm@linux-foundation.org>
 <20100615003943.GK6590@dastard>
 <4C16D46D.3020302@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C16D46D.3020302@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 14, 2010 at 09:16:29PM -0400, Rik van Riel wrote:
> >Besides, there really isn't the right context in the block layer to
> >be able to queue and prioritise large amounts of IO without
> >significant penalties to some higher layer operation.
> 
> Can we kick flushing for the whole inode at once from
> vmscan.c?

kswapd really should be a last effort tool to clean filesystem pages.
If it does enough I/O for this to matter significantly we need to
fix the VM to move more work to the flusher threads instead of trying
to fix kswapd.  

> Would it be hard to add a "please flush this file"
> way to call the filesystem flushing threads?

We already have that API, in Jens' latest tree that's
sync_inodes_sb/writeback_inodes_sb.  We could also add a non-waiting
variant if required, but I think the big problem with kswapd is that
we want to wait on I/O completion under circumstances.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
