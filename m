Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 550C78D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 22:53:31 -0400 (EDT)
Date: Wed, 20 Apr 2011 10:53:21 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/6] writeback: sync expired inodes first in background
 writeback
Message-ID: <20110420025321.GA14398@localhost>
References: <20110419030003.108796967@intel.com>
 <20110419030532.515923886@intel.com>
 <20110419073523.GF23985@dastard>
 <20110419095740.GC5257@quack.suse.cz>
 <20110419125616.GA20059@localhost>
 <20110420012120.GK23985@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110420012120.GK23985@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Apr 20, 2011 at 09:21:20AM +0800, Dave Chinner wrote:
> On Tue, Apr 19, 2011 at 08:56:16PM +0800, Wu Fengguang wrote:
> > On Tue, Apr 19, 2011 at 05:57:40PM +0800, Jan Kara wrote:
> > > On Tue 19-04-11 17:35:23, Dave Chinner wrote:
> > > > On Tue, Apr 19, 2011 at 11:00:06AM +0800, Wu Fengguang wrote:
> > > > > A background flush work may run for ever. So it's reasonable for it to
> > > > > mimic the kupdate behavior of syncing old/expired inodes first.
> > > > > 
> > > > > The policy is
> > > > > - enqueue all newly expired inodes at each queue_io() time
> > > > > - enqueue all dirty inodes if there are no more expired inodes to sync
> > > > > 
> > > > > This will help reduce the number of dirty pages encountered by page
> > > > > reclaim, eg. the pageout() calls. Normally older inodes contain older
> > > > > dirty pages, which are more close to the end of the LRU lists. So
> > > > > syncing older inodes first helps reducing the dirty pages reached by
> > > > > the page reclaim code.
> > > > 
> > > > Once again I think this is the wrong place to be changing writeback
> > > > policy decisions. for_background writeback only goes through
> > > > wb_writeback() and writeback_inodes_wb() (same as for_kupdate
> > > > writeback), so a decision to change from expired inodes to fresh
> > > > inodes, IMO, should be made in wb_writeback.
> > > > 
> > > > That is, for_background and for_kupdate writeback start with the
> > > > same policy (older_than_this set) to writeback expired inodes first,
> > > > then when background writeback runs out of expired inodes, it should
> > > > switch to all remaining inodes by clearing older_than_this instead
> > > > of refreshing it for the next loop.
> > >   Yes, I agree with this and my impression is that Fengguang is trying to
> > > achieve exactly this behavior.
> > > 
> > > > This keeps all the policy decisions in the one place, all using the
> > > > same (existing) mechanism, and all relatively simple to understand,
> > > > and easy to tracepoint for debugging.  Changing writeback policy
> > > > deep in the writeback stack is not a good idea as it will make
> > > > extending writeback policies in future (e.g. for cgroup awareness)
> > > > very messy.
> > >   Hmm, I see. I agree the policy decisions should be at one place if
> > > reasonably possible. Fengguang moves them from wb_writeback() to inode
> > > queueing code which looks like a logical place to me as well - there we
> > > have the largest control over what inodes do we decide to write and don't
> > > have to pass all the detailed 'instructions' down in wbc structure. So if
> > > we later want to add cgroup awareness to writeback, I imagine we just add
> > > the knowledge to inode queueing code.
> > 
> > I actually started with wb_writeback() as a natural choice, and then
> > found it much easier to do the expired-only=>all-inodes switching in
> > move_expired_inodes() since it needs to know the @b_dirty and @tmp
> > lists' emptiness to trigger the switch. It's not sane for
> > wb_writeback() to look into such details. And once you do the switch
> > part in move_expired_inodes(), the whole policy naturally follows.
> 
> Well, not really. You didn't need to modify move_expired_inodes() at
> all to implement these changes - all you needed to do was modify how
> older_than_this is configured.
> 
> writeback policy is defined by the struct writeback_control.
> move_expired_inodes() is pure mechanism. What you've done is remove
> policy from the struct wbc and moved it to move_expired_inodes(),
> which now defines both policy and mechanism.

> Furhter, this means that all the tracing that uses the struct wbc no
> no longer shows the entire writeback policy that is being worked on,
> so we lose visibility into policy decisions that writeback is
> making.

Good point! I'm convinced, visibility is a necessity for debugging the
complex writeback behaviors.

> This same change is as simple as updating wbc->older_than_this
> appropriately after the wb_writeback() call for both background and
> kupdate and leaving the lower layers untouched. It's just a policy
> change. If you thinkthe mechanism is inefficient, copy
> wbc->older_than_this to a local variable inside
> move_expired_inodes()....

Do you like something like this? (details will change a bit when
rearranging the patchset)

--- linux-next.orig/fs/fs-writeback.c	2011-04-20 10:30:47.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2011-04-20 10:40:19.000000000 +0800
@@ -660,11 +660,6 @@ static long wb_writeback(struct bdi_writ
 	long write_chunk;
 	struct inode *inode;
 
-	if (wbc.for_kupdate) {
-		wbc.older_than_this = &oldest_jif;
-		oldest_jif = jiffies -
-				msecs_to_jiffies(dirty_expire_interval * 10);
-	}
 	if (!wbc.range_cyclic) {
 		wbc.range_start = 0;
 		wbc.range_end = LLONG_MAX;
@@ -713,10 +708,17 @@ static long wb_writeback(struct bdi_writ
 		if (work->for_background && !over_bground_thresh())
 			break;
 
+		if (work->for_kupdate || work->for_background) {
+			oldest_jif = jiffies -
+				msecs_to_jiffies(dirty_expire_interval * 10);
+			wbc.older_than_this = &oldest_jif;
+		}
+
 		wbc.more_io = 0;
 		wbc.nr_to_write = write_chunk;
 		wbc.pages_skipped = 0;
 
+retry_all:
 		trace_wbc_writeback_start(&wbc, wb->bdi);
 		if (work->sb)
 			__writeback_inodes_sb(work->sb, wb, &wbc);
@@ -733,6 +735,17 @@ static long wb_writeback(struct bdi_writ
 		if (wbc.nr_to_write <= 0)
 			continue;
 		/*
+		 * No expired inode? Try all fresh ones
+		 */
+		if ((work->for_kupdate || work->for_background) &&
+		    wbc.older_than_this &&
+		    wbc.nr_to_write == write_chunk &&
+		    list_empty(&wb->b_io) &&
+		    list_empty(&wb->b_more_io)) {
+			wbc.older_than_this = NULL;
+			goto retry_all;
+		}
+		/*
 		 * Didn't write everything and we don't have more IO, bail
 		 */
 		if (!wbc.more_io)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
