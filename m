Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1FF066B006A
	for <linux-mm@kvack.org>; Wed,  7 Jul 2010 01:03:46 -0400 (EDT)
Date: Wed, 7 Jul 2010 13:03:38 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 12/14] vmscan: Do not writeback pages in direct reclaim
Message-ID: <20100707050338.GA5039@localhost>
References: <1277811288-5195-1-git-send-email-mel@csn.ul.ie>
 <1277811288-5195-13-git-send-email-mel@csn.ul.ie>
 <20100702125155.69c02f85.akpm@linux-foundation.org>
 <20100705134949.GC13780@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100705134949.GC13780@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

Hi Mel,

> Second, using systemtap, I was able to see that file-backed dirty
> pages have a tendency to be near the end of the LRU even though they
> are a small percentage of the overall pages in the LRU. I'm hoping
> to figure out why this is as it would make avoiding writeback a lot
> less controversial.

Your intuitions are correct -- the current background writeback logic
fails to write elder inodes first. Under heavy loads the background
writeback job may run for ever, totally ignoring the time order of
inode->dirtied_when. This is probably why you see lots of dirty pages
near the end of LRU.

Here is an old patch for fixing this. Sorry for being late. I'll
pick up and refresh the patch series ASAP.  (I made a mistake last
year to post too many patches at one time. I'll break them up into
more manageable pieces.)

[PATCH 31/45] writeback: sync old inodes first in background writeback
<https://kerneltrap.org/mailarchive/linux-fsdevel/2009/10/7/6476313>

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
