Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5A6426B0011
	for <linux-mm@kvack.org>; Tue, 10 May 2011 00:53:51 -0400 (EDT)
Date: Tue, 10 May 2011 14:53:46 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 6/6] writeback: refill b_io iff empty
Message-ID: <20110510045346.GC19446@dastard>
References: <20110420080336.441157866@intel.com>
 <20110420080918.560499032@intel.com>
 <20110504073931.GA22675@localhost>
 <20110505163708.GN5323@quack.suse.cz>
 <20110506052955.GA24904@localhost>
 <20110506142155.GD18982@quack.suse.cz>
 <20110510043104.GA14423@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110510043104.GA14423@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, May 10, 2011 at 12:31:04PM +0800, Wu Fengguang wrote:
> On Fri, May 06, 2011 at 10:21:55PM +0800, Jan Kara wrote:
> > On Fri 06-05-11 13:29:55, Wu Fengguang wrote:
> > > On Fri, May 06, 2011 at 12:37:08AM +0800, Jan Kara wrote:
> > > > On Wed 04-05-11 15:39:31, Wu Fengguang wrote:
> > > > > To help understand the behavior change, I wrote the writeback_queue_io
> > > > > trace event, and found very different patterns between
> > > > > - vanilla kernel
> > > > > - this patchset plus the sync livelock fixes
> > > > > 
> > > > > Basically the vanilla kernel each time pulls a random number of inodes
> > > > > from b_dirty, while the patched kernel tends to pull a fixed number of
> > > > > inodes (enqueue=1031) from b_dirty. The new behavior is very interesting...
> > > >   This regularity is really strange. Did you have a chance to look more into
> > > > it? I find it highly unlikely that there would be exactly 1031 dirty inodes
> > > > in b_dirty list every time you call move_expired_inodes()...
> > > 
> > > Jan, I got some results for ext4. The total dd+tar+sync time is
> > > decreased from 177s to 167s. The other numbers are either raised or
> > > dropped.
> >   Nice, but what I was more curious about was to understand why you saw
> > enqueued=1031 all the time.
> 
> Maybe some unknown interactions with XFS? Attached is another trace
> with both writeback_single_inode and writeback_queue_io.

Perhaps because write throttling is limiting the number of files
being dirtied to match the number of files being cleaned? hence they
age at roughly the same rate as writeback is cleaning them?
Especially as most file are only a single page in size?

Or perhaps that is the rate at which IO completions are occurring
and updating the inode size and redirtying the inode? After all,
there are lots of inodes that are only state=I_DIRTY_SYNC and
wrote=0 in the traces around when it starts going to ~1000 inodes
per queue_io call....

Or maybe a combination of both?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
