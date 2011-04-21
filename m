Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E55758D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 22:06:22 -0400 (EDT)
Date: Thu, 21 Apr 2011 10:06:17 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/6] writeback: sync expired inodes first in background
 writeback
Message-ID: <20110421020617.GB12191@localhost>
References: <20110419030003.108796967@intel.com>
 <20110419030532.515923886@intel.com>
 <20110419073523.GF23985@dastard>
 <20110419095740.GC5257@quack.suse.cz>
 <20110419125616.GA20059@localhost>
 <20110420012120.GK23985@dastard>
 <20110420025321.GA14398@localhost>
 <20110421004547.GD1814@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110421004547.GD1814@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, Apr 21, 2011 at 08:45:47AM +0800, Dave Chinner wrote:
> On Wed, Apr 20, 2011 at 10:53:21AM +0800, Wu Fengguang wrote:
> > On Wed, Apr 20, 2011 at 09:21:20AM +0800, Dave Chinner wrote:
> > > On Tue, Apr 19, 2011 at 08:56:16PM +0800, Wu Fengguang wrote:
> > > > I actually started with wb_writeback() as a natural choice, and then
> > > > found it much easier to do the expired-only=>all-inodes switching in
> > > > move_expired_inodes() since it needs to know the @b_dirty and @tmp
> > > > lists' emptiness to trigger the switch. It's not sane for
> > > > wb_writeback() to look into such details. And once you do the switch
> > > > part in move_expired_inodes(), the whole policy naturally follows.
> > > 
> > > Well, not really. You didn't need to modify move_expired_inodes() at
> > > all to implement these changes - all you needed to do was modify how
> > > older_than_this is configured.
> > > 
> > > writeback policy is defined by the struct writeback_control.
> > > move_expired_inodes() is pure mechanism. What you've done is remove
> > > policy from the struct wbc and moved it to move_expired_inodes(),
> > > which now defines both policy and mechanism.
> > 
> > > Furhter, this means that all the tracing that uses the struct wbc no
> > > no longer shows the entire writeback policy that is being worked on,
> > > so we lose visibility into policy decisions that writeback is
> > > making.
> > 
> > Good point! I'm convinced, visibility is a necessity for debugging the
> > complex writeback behaviors.
> > 
> > > This same change is as simple as updating wbc->older_than_this
> > > appropriately after the wb_writeback() call for both background and
> > > kupdate and leaving the lower layers untouched. It's just a policy
> > > change. If you thinkthe mechanism is inefficient, copy
> > > wbc->older_than_this to a local variable inside
> > > move_expired_inodes()....
> > 
> > Do you like something like this? (details will change a bit when
> > rearranging the patchset)
> 
> Yeah, this is close to what I had in mind.
> 
> > 
> > --- linux-next.orig/fs/fs-writeback.c	2011-04-20 10:30:47.000000000 +0800
> > +++ linux-next/fs/fs-writeback.c	2011-04-20 10:40:19.000000000 +0800
> > @@ -660,11 +660,6 @@ static long wb_writeback(struct bdi_writ
> >  	long write_chunk;
> >  	struct inode *inode;
> >  
> > -	if (wbc.for_kupdate) {
> > -		wbc.older_than_this = &oldest_jif;
> > -		oldest_jif = jiffies -
> > -				msecs_to_jiffies(dirty_expire_interval * 10);
> > -	}
> 
> Right here I'd do:
> 
> 	if (work->for_kupdate || work->for_background)
> 		wbc.older_than_this = &oldest_jif;
> 
> so that the setting of wbc.older_than_this in the loop can trigger
> on whether it is null or not.

That's the tricky part that drove me to change move_expired_inodes()
directly..

One important thing to bear in mind is, the background work can run on
for one hour, one day or whatever. During the time dirty inodes come
and go, expired and cleaned.  If we only reset wbc.older_than_this and
never restore it _inside_ the loop, we'll quickly lose the ability to
"start with expired inodes" shortly after f.g. 5 minutes.

So we need to start with searching for expired inodes at each
queue_io() time.  wbc.older_than_this shall be properly restored to
&oldest_jif inside the loop. Since no expired inodes found in this
loop does not mean no new inodes will be expired in the next loop.

> >  	if (!wbc.range_cyclic) {
> >  		wbc.range_start = 0;
> >  		wbc.range_end = LLONG_MAX;
> > @@ -713,10 +708,17 @@ static long wb_writeback(struct bdi_writ
> >  		if (work->for_background && !over_bground_thresh())
> >  			break;
> >  
> > +		if (work->for_kupdate || work->for_background) {
> > +			oldest_jif = jiffies -
> > +				msecs_to_jiffies(dirty_expire_interval * 10);
> > +			wbc.older_than_this = &oldest_jif;
> > +		}
> > +
> 
> if you change that to:
> 
> 		if (wbc.older_than_this) {
> 			*wbc.older_than_this = jiffies -
> 				msecs_to_jiffies(dirty_expire_interval * 10);
> 		}
> 
> >  		wbc.more_io = 0;
> >  		wbc.nr_to_write = write_chunk;
> >  		wbc.pages_skipped = 0;
> >  
> > +retry_all:
> 
> You can get rid of this retry_all label and have the changeover in
> behaviour re-initialise nr_to_write, etc.
> 
> >  		trace_wbc_writeback_start(&wbc, wb->bdi);
> >  		if (work->sb)
> >  			__writeback_inodes_sb(work->sb, wb, &wbc);
> > @@ -733,6 +735,17 @@ static long wb_writeback(struct bdi_writ
> >  		if (wbc.nr_to_write <= 0)
> >  			continue;
> >  		/*
> > +		 * No expired inode? Try all fresh ones
> > +		 */
> > +		if ((work->for_kupdate || work->for_background) &&
> > +		    wbc.older_than_this &&
> > +		    wbc.nr_to_write == write_chunk &&
> > +		    list_empty(&wb->b_io) &&
> > +		    list_empty(&wb->b_more_io)) {
> > +			wbc.older_than_this = NULL;
> > +			goto retry_all;
> > +		}
> 
> And here only do this for work->for_background as kupdate writeback
> stops when we run out of expired inodes (i.e. it doesn't writeback
> non-expired inodes).

Sorry for the mistake. I've fixed it in the v2 :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
