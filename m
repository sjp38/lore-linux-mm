Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E15E76B006A
	for <linux-mm@kvack.org>; Wed,  7 Jul 2010 05:50:29 -0400 (EDT)
Date: Wed, 7 Jul 2010 10:50:10 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 12/14] vmscan: Do not writeback pages in direct reclaim
Message-ID: <20100707095010.GK13780@csn.ul.ie>
References: <1277811288-5195-1-git-send-email-mel@csn.ul.ie> <1277811288-5195-13-git-send-email-mel@csn.ul.ie> <20100702125155.69c02f85.akpm@linux-foundation.org> <20100705134949.GC13780@csn.ul.ie> <20100707050338.GA5039@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100707050338.GA5039@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 07, 2010 at 01:03:38PM +0800, Wu Fengguang wrote:
> Hi Mel,
> 
> > Second, using systemtap, I was able to see that file-backed dirty
> > pages have a tendency to be near the end of the LRU even though they
> > are a small percentage of the overall pages in the LRU. I'm hoping
> > to figure out why this is as it would make avoiding writeback a lot
> > less controversial.
> 
> Your intuitions are correct -- the current background writeback logic
> fails to write elder inodes first. Under heavy loads the background
> writeback job may run for ever, totally ignoring the time order of
> inode->dirtied_when. This is probably why you see lots of dirty pages
> near the end of LRU.
> 

Possible. In a mail to Christoph, I asserted that writeback of elder inodes
was happening first but I obviously could be mistaken.

> Here is an old patch for fixing this. Sorry for being late. I'll
> pick up and refresh the patch series ASAP.  (I made a mistake last
> year to post too many patches at one time. I'll break them up into
> more manageable pieces.)
> 
> [PATCH 31/45] writeback: sync old inodes first in background writeback
> <https://kerneltrap.org/mailarchive/linux-fsdevel/2009/10/7/6476313>
> 

I'll check it out as an alternative to forward-flushing based on the
amount of dirty pages encountered during scanning. Thanks.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
