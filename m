Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1FC198D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 00:00:14 -0400 (EDT)
Date: Thu, 21 Apr 2011 11:59:54 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/6] writeback: sync expired inodes first in background
 writeback
Message-ID: <20110421035954.GA15461@localhost>
References: <20110419030003.108796967@intel.com>
 <20110419030532.515923886@intel.com>
 <20110419073523.GF23985@dastard>
 <20110419095740.GC5257@quack.suse.cz>
 <20110419125616.GA20059@localhost>
 <20110420012120.GK23985@dastard>
 <20110420025321.GA14398@localhost>
 <20110421004547.GD1814@dastard>
 <20110421020617.GB12191@localhost>
 <20110421030152.GG1814@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110421030152.GG1814@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, Apr 21, 2011 at 11:01:52AM +0800, Dave Chinner wrote:
> Content-Length: 4479
> Lines: 116
> 
> On Thu, Apr 21, 2011 at 10:06:17AM +0800, Wu Fengguang wrote:
> > On Thu, Apr 21, 2011 at 08:45:47AM +0800, Dave Chinner wrote:
> > > On Wed, Apr 20, 2011 at 10:53:21AM +0800, Wu Fengguang wrote:
> > > > On Wed, Apr 20, 2011 at 09:21:20AM +0800, Dave Chinner wrote:
> > > > > On Tue, Apr 19, 2011 at 08:56:16PM +0800, Wu Fengguang wrote:
> > > > > > I actually started with wb_writeback() as a natural choice, and then
> > > > > > found it much easier to do the expired-only=>all-inodes switching in
> > > > > > move_expired_inodes() since it needs to know the @b_dirty and @tmp
> > > > > > lists' emptiness to trigger the switch. It's not sane for
> > > > > > wb_writeback() to look into such details. And once you do the switch
> > > > > > part in move_expired_inodes(), the whole policy naturally follows.
> > > > > 
> > > > > Well, not really. You didn't need to modify move_expired_inodes() at
> > > > > all to implement these changes - all you needed to do was modify how
> > > > > older_than_this is configured.
> > > > > 
> > > > > writeback policy is defined by the struct writeback_control.
> > > > > move_expired_inodes() is pure mechanism. What you've done is remove
> > > > > policy from the struct wbc and moved it to move_expired_inodes(),
> > > > > which now defines both policy and mechanism.
> > > > 
> > > > > Furhter, this means that all the tracing that uses the struct wbc no
> > > > > no longer shows the entire writeback policy that is being worked on,
> > > > > so we lose visibility into policy decisions that writeback is
> > > > > making.
> > > > 
> > > > Good point! I'm convinced, visibility is a necessity for debugging the
> > > > complex writeback behaviors.
> > > > 
> > > > > This same change is as simple as updating wbc->older_than_this
> > > > > appropriately after the wb_writeback() call for both background and
> > > > > kupdate and leaving the lower layers untouched. It's just a policy
> > > > > change. If you thinkthe mechanism is inefficient, copy
> > > > > wbc->older_than_this to a local variable inside
> > > > > move_expired_inodes()....
> > > > 
> > > > Do you like something like this? (details will change a bit when
> > > > rearranging the patchset)
> > > 
> > > Yeah, this is close to what I had in mind.
> > > 
> > > > 
> > > > --- linux-next.orig/fs/fs-writeback.c	2011-04-20 10:30:47.000000000 +0800
> > > > +++ linux-next/fs/fs-writeback.c	2011-04-20 10:40:19.000000000 +0800
> > > > @@ -660,11 +660,6 @@ static long wb_writeback(struct bdi_writ
> > > >  	long write_chunk;
> > > >  	struct inode *inode;
> > > >  
> > > > -	if (wbc.for_kupdate) {
> > > > -		wbc.older_than_this = &oldest_jif;
> > > > -		oldest_jif = jiffies -
> > > > -				msecs_to_jiffies(dirty_expire_interval * 10);
> > > > -	}
> > > 
> > > Right here I'd do:
> > > 
> > > 	if (work->for_kupdate || work->for_background)
> > > 		wbc.older_than_this = &oldest_jif;
> > > 
> > > so that the setting of wbc.older_than_this in the loop can trigger
> > > on whether it is null or not.
> > 
> > That's the tricky part that drove me to change move_expired_inodes()
> > directly..
> > 
> > One important thing to bear in mind is, the background work can run on
> > for one hour, one day or whatever. During the time dirty inodes come
> > and go, expired and cleaned.  If we only reset wbc.older_than_this and
> > never restore it _inside_ the loop, we'll quickly lose the ability to
> > "start with expired inodes" shortly after f.g. 5 minutes.
> 
> However, there's not need to implicity switch back to expired inodes
> on the next wb_writeback loop - it only needs to switch back when
> b_io is emptied.

Right. However my intention is to make simple and safe code :)

> And I suspect that it really only needs to switch
> if there are inodes on b_more_io because if we didn't put any inodes
> onto b_more_io, then then we most likely cleaned the entire list of
> unexpired inodes in a single write chunk...
> 
> That is, something like this when updating the background state in
> the loop tail:
> 
> 	if (work->for_background && list_empty(&wb->b_io)) {
> 		if (wbc.older_than_this) {
> 			if (list_empty(&wb->b_more_io)) {
> 				wbc.older_than_this = NULL;
> 				continue;
> 			}
> 		} else if (!list_empty(&wb->b_more_io)) {
> 			wbc.older_than_this = &oldest_jif;
> 			continue;
> 		}
> 	}

Now how are you going to interpret the call trace? Going through all
the above tests in our little mind and reach the conclusion: ah got it,
older_than_this is changed here because (... && ... && ...)...

Besides, we still need to update oldest_jif inside the loop (you can
sure add more tests to the update rule..).

Took quite some time iterating possible situations through the
tests...ah got a bug: what if it's all small files? older_than_this
will never be restored to &oldest_jif then...

> Still, given wb_writeback() is the only caller of both
> __writeback_inodes_sb and writeback_inodes_wb(), I'm wondering if
> moving the queue_io calls up into wb_writeback() would clean up this
> logic somewhat. I think Jan mentioned doing something like this as
> well elsewhere in the thread...

Unfortunately they call queue_io() inside the lock..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
