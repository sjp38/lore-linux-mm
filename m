Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id E13606B002C
	for <linux-mm@kvack.org>; Sat,  3 Mar 2012 08:31:06 -0500 (EST)
Date: Sat, 3 Mar 2012 21:25:55 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/9] writeback: introduce the pageout work
Message-ID: <20120303132555.GA6312@localhost>
References: <20120228140022.614718843@intel.com>
 <20120228144747.198713792@intel.com>
 <20120228160403.9c9fa4dc.akpm@linux-foundation.org>
 <20120301110404.GC4385@quack.suse.cz>
 <20120301114151.GA19049@localhost>
 <20120301114634.957da8d2.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120301114634.957da8d2.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Mar 01, 2012 at 11:46:34AM -0800, Andrew Morton wrote:
> On Thu, 1 Mar 2012 19:41:51 +0800
> Fengguang Wu <fengguang.wu@intel.com> wrote:
> 
> > >   I think using get_page() might be a good way to go. Naive implementation:
> > > If we need to write a page from kswapd, we do get_page(), attach page to
> > > wb_writeback_work and push it to flusher thread to deal with it.
> > > Flusher thread sees the work, takes a page lock, verifies the page is still
> > > attached to some inode & dirty (it could have been truncated / cleaned by
> > > someone else) and if yes, it submits page for IO (possibly with some
> > > writearound). This scheme won't have problems with iput() and won't have
> > > problems with umount. Also we guarantee some progress - either flusher
> > > thread does it, or some else must have done the work before flusher thread
> > > got to it.
> > 
> > I like this idea.
> > 
> > get_page() looks the perfect solution to verify if the struct inode
> > pointer (w/o igrab) is still live and valid.
> > 
> > [...upon rethinking...] Oh but still we need to lock some page to pin
> > the inode during the writeout. Then there is the dilemma: if the page
> > is locked, we effectively keep it from being written out...
> 
> No, all you need to do is to structure the code so that after the page
> gets unlocked, the kernel thread does not touch the address_space.  So
> the processing within the kthread is along the lines of
> 
> writearound(locked_page)
> {
> 	write some pages preceding locked_page;	/* touches address_space */

It seems the above line will lead to ABBA deadlock.

At least btrfs will lock a number of pages in lock_delalloc_pages().
This demands that all page locks be taken in ascending order of the
file offset. Otherwise it's possible some task doing
__filemap_fdatawrite_range() which in turn call into
lock_delalloc_pages() deadlock with the writearound() here, which is
taking some page in the middle first. The fix is to only do
"write ahead" which will obviously lead to more smaller I/Os.

> 	write locked_page;
> 	write pages following locked_page;	/* touches address_space */
> 	unlock_page(locked_page);
> }

As it is in general a lock, which implies danger of deadlocks. If some
filesystem do smart things like piggy backing more pages than we
asked, it may try to lock the locked_page in writearound() and block
the flusher for ever.

Grabbing the page lock at work enqueue time is particular problematic.
It's susceptible to the above ABBA deadlock scheme because we will be
taking one page lock per pageout work and the pages are likely in
_random_ order. Another scheme is, when the flusher is running sync
work (or running some final iput() and therefore truncate),  and the
vmscan is queuing a pageout work with one page locked. The flusher
will then go deadlock on that page: the current sync/truncate is
trying to lock a page that can only be unlocked when the flusher goes
forward to execute the pageout work. The fix is to do get_page() at
work enqueue time and only take the page lock at work execution time.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
