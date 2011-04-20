Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3E9B88D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 19:41:20 -0400 (EDT)
Date: Wed, 20 Apr 2011 16:40:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/6] writeback: sync expired inodes first in background
 writeback
Message-Id: <20110420164005.e3925965.akpm@linux-foundation.org>
In-Reply-To: <20110420080918.383880412@intel.com>
References: <20110420080336.441157866@intel.com>
	<20110420080918.383880412@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 20 Apr 2011 16:03:41 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> A background flush work may run for ever. So it's reasonable for it to
> mimic the kupdate behavior of syncing old/expired inodes first.
> 
> At each queue_io() time, first try enqueuing only newly expired inodes.
> If there are zero expired inodes to work with, then relax the rule and
> enqueue all dirty inodes.
> 
> This will help reduce the number of dirty pages encountered by page
> reclaim, eg. the pageout() calls. Normally older inodes contain older
> dirty pages, which are more close to the end of the LRU lists. So
> syncing older inodes first helps reducing the dirty pages reached by
> the page reclaim code.
> 
> More background: as Mel put it, "it makes sense to write old pages first
> to reduce the chances page reclaim is initiating IO."
> 
> Rik also presented the situation with a graph:
> 
> LRU head                                 [*] dirty page
> [                          *              *      * *  *  * * * * * *]
> 
> Ideally, most dirty pages should lie close to the LRU tail instead of
> LRU head. That requires the flusher thread to sync old/expired inodes
> first (as there are obvious correlations between inode age and page
> age), and to give fair opportunities to newly expired inodes rather
> than sticking with some large eldest inodes (as larger inodes have
> weaker correlations in the inode<=>page ages).
> 
> This patch helps the flusher to meet both the above requirements.
> 
> Side effects: it might reduce the batch size and hence reduce
> inode_wb_list_lock hold time, but in turn make the cluster-by-partition
> logic in the same function less effective on reducing disk seeks.

One of the many requirements for writeback is that if userspace is
continually dirtying pages in a particular file, that shouldn't cause
the kupdate function to concentrate on that file's newly-dirtied pages,
neglecting pages from other files which were less-recently dirtied. 
(and dirty nodes, etc).

And the background writeback function and fsync() and msync() and
everything else shouldn't cause starvation of expired pages, either.  I
guess you could say that the expired dirty pages become the
highest-priority writeback item.


Are you testing for this failure scenario?  If so, can you briefly
describe the testing?

It would be hlpeful if you could explain how the current code
implements this requirement?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
