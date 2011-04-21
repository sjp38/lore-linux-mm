Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B81C78D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 21:14:36 -0400 (EDT)
Date: Thu, 21 Apr 2011 09:14:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/6] writeback: sync expired inodes first in background
 writeback
Message-ID: <20110421011431.GA7828@localhost>
References: <20110420080336.441157866@intel.com>
 <20110420080918.383880412@intel.com>
 <20110420164005.e3925965.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110420164005.e3925965.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Apr 21, 2011 at 07:40:05AM +0800, Andrew Morton wrote:
> On Wed, 20 Apr 2011 16:03:41 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > A background flush work may run for ever. So it's reasonable for it to
> > mimic the kupdate behavior of syncing old/expired inodes first.
> > 
> > At each queue_io() time, first try enqueuing only newly expired inodes.
> > If there are zero expired inodes to work with, then relax the rule and
> > enqueue all dirty inodes.
> > 
> > This will help reduce the number of dirty pages encountered by page
> > reclaim, eg. the pageout() calls. Normally older inodes contain older
> > dirty pages, which are more close to the end of the LRU lists. So
> > syncing older inodes first helps reducing the dirty pages reached by
> > the page reclaim code.
> > 
> > More background: as Mel put it, "it makes sense to write old pages first
> > to reduce the chances page reclaim is initiating IO."
> > 
> > Rik also presented the situation with a graph:
> > 
> > LRU head                                 [*] dirty page
> > [                          *              *      * *  *  * * * * * *]
> > 
> > Ideally, most dirty pages should lie close to the LRU tail instead of
> > LRU head. That requires the flusher thread to sync old/expired inodes
> > first (as there are obvious correlations between inode age and page
> > age), and to give fair opportunities to newly expired inodes rather
> > than sticking with some large eldest inodes (as larger inodes have
> > weaker correlations in the inode<=>page ages).
> > 
> > This patch helps the flusher to meet both the above requirements.
> > 
> > Side effects: it might reduce the batch size and hence reduce
> > inode_wb_list_lock hold time, but in turn make the cluster-by-partition
> > logic in the same function less effective on reducing disk seeks.
> 
> One of the many requirements for writeback is that if userspace is
> continually dirtying pages in a particular file, that shouldn't cause
> the kupdate function to concentrate on that file's newly-dirtied pages,
> neglecting pages from other files which were less-recently dirtied. 
> (and dirty nodes, etc).

Right. This patch will exclude unexpired inodes from background work,
as long as there are expired ones to work on. Which hopefully will
provide better data safety in normal cases. After all the flusher
is based on inodes and this is the most sane order it can take.

Given that the unexpired inodes will eventually expire after 30s, it
won't exclude any inode from entering b_io for long time.

When there is a continually dirtied inode, let's check its internal
pages writeback order first, and then examine the inter-inode order.

a) it's a small file (less than the write chunk size)

No problem at all, it will be fairly redirty_tail()ed after all the
freshly dirtied inodes, waiting for the next turn

b) it's a large file, random writes

No optimal solution at all, because it will contain both old and new
pages all over the places.

c) it's a large file, sequentially written to

Old pages will be served first (if not, we'll cycle around sooner or
later to behind the write stream), we will be rightfully concentrating
on old pages

d) it's a large file, reversely written to

This is rare. We'll work through a series of segments, eg. pages
90000-100000, pages 70000-80000, pages 60000-70000. Within each
segment we'll work on youngest pages first..

Except for (d) there is no way we may wrongly keep concentrating on
the newly-dirtied pages _inside_ one file.

As for _inter_ inode fairness, the last patch describes the scheme:

: A b_io refill will setup a _fixed_ work set with all currently eligible
: inodes and start a new round of walking through b_io.  The "fixed" work
: set means no new inodes will be added to the work set during the walk.
: Only when a complete walk over b_io is done, new inodes that are eligible
: at the time will be enqueued and the walk will be started over.
: 
: This procedure provides fairness among the inodes because it guarantees
: that each inode will be synced once and only once in each round.  So all
: inodes will be free from starvation.

In long turn, each inode will be honored a chance to write write_chunk
pages _in fair turn_. However there is an implicit priority: the
larger write_chunk, the more a large file can effectively write than
small files.

> And the background writeback function and fsync() and msync() and
> everything else shouldn't cause starvation of expired pages, either.  I
> guess you could say that the expired dirty pages become the
> highest-priority writeback item.

fsync() and msync() is expected to finish in bounded time, since they
work on a fixed set of PAGECACHE_TAG_TOWRITE pages. So won't be
starved by them. If there are too many fsync()s, we have the more
serious problem of the whole system coming to a halt.

Inside the background work, inter-inode fairness is guaranteed as
described above.

> Are you testing for this failure scenario?  If so, can you briefly
> describe the testing?

Not yet.. But one possible scheme is to record the dirty time of each
page in a debug kernel and expose them to user space. Then we can run
any kind of workloads, and in the mean while run a background scanner
to collect and report the distribution of dirty page ages.

Does it sound too heavy weight? Or we may start by reporting the dirty
inode age first. To maintain a mapping->writeback_index_wrapped_when and
a mapping->pages_dirtied_when to follow it (or just reuse/reset
mapping->dirtied_when?). The former will be reset to jiffies on each
full scan of the pages. range_whole=1 scan can maintain its start time
in a local variable. Then we get an estimation "what's the max
possible dirty page age this inode has?". There will sure be redirtied
pages though..

> It would be hlpeful if you could explain how the current code
> implements this requirement?

See above descriptions.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
