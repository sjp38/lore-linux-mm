Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id ADEC36B0022
	for <linux-mm@kvack.org>; Fri,  6 May 2011 10:22:08 -0400 (EDT)
Date: Fri, 6 May 2011 16:21:55 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 6/6] writeback: refill b_io iff empty
Message-ID: <20110506142155.GD18982@quack.suse.cz>
References: <20110420080336.441157866@intel.com>
 <20110420080918.560499032@intel.com>
 <20110504073931.GA22675@localhost>
 <20110505163708.GN5323@quack.suse.cz>
 <20110506052955.GA24904@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110506052955.GA24904@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Dave Chinner <david@fromorbit.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 06-05-11 13:29:55, Wu Fengguang wrote:
> On Fri, May 06, 2011 at 12:37:08AM +0800, Jan Kara wrote:
> > On Wed 04-05-11 15:39:31, Wu Fengguang wrote:
> > > To help understand the behavior change, I wrote the writeback_queue_io
> > > trace event, and found very different patterns between
> > > - vanilla kernel
> > > - this patchset plus the sync livelock fixes
> > > 
> > > Basically the vanilla kernel each time pulls a random number of inodes
> > > from b_dirty, while the patched kernel tends to pull a fixed number of
> > > inodes (enqueue=1031) from b_dirty. The new behavior is very interesting...
> >   This regularity is really strange. Did you have a chance to look more into
> > it? I find it highly unlikely that there would be exactly 1031 dirty inodes
> > in b_dirty list every time you call move_expired_inodes()...
> 
> Jan, I got some results for ext4. The total dd+tar+sync time is
> decreased from 177s to 167s. The other numbers are either raised or
> dropped.
  Nice, but what I was more curious about was to understand why you saw
enqueued=1031 all the time. BTW, I'd suppose that the better performance
numbers come from sync using page tagging, right? Because from the traces
it seems that not much IO is going on until sync is called. And I expect
that tagging can bring you some performance because now you sync a file in
one big sweep instead of 4MB chunks...

> 1902.672610: writeback_queue_io: older=4296543506 age=30000 enqueue=0
> 1905.209570: writeback_queue_io: older=4296546051 age=30000 enqueue=0
> 1907.294936: writeback_queue_io: older=4296548143 age=30000 enqueue=0
> 1909.607301: writeback_queue_io: older=4296550462 age=30000 enqueue=0
> 1912.290627: writeback_queue_io: older=4296553154 age=30000 enqueue=0
> 1914.331197: writeback_queue_io: older=4296555201 age=30000 enqueue=0
> 1927.275838: writeback_queue_io: older=4296568186 age=30000 enqueue=0
> 1927.277794: writeback_queue_io: older=4296568188 age=30000 enqueue=0
> 1927.279504: writeback_queue_io: older=4296568189 age=30000 enqueue=0
> 1927.279923: writeback_queue_io: older=4296568190 age=30000 enqueue=0
> 1929.981734: writeback_queue_io: older=4296600898 age=2 enqueue=13227
> 1932.840150: writeback_queue_io: older=4296600898 age=2869 enqueue=0
> 1932.840781: writeback_queue_io: older=4296603768 age=0 enqueue=0
> 1932.840787: writeback_queue_io: older=4296573768 age=30000 enqueue=0
> 1932.991596: writeback_queue_io: older=4296603919 age=0 enqueue=1
> 1937.975765: writeback_queue_io: older=4296578919 age=30000 enqueue=0
> 1942.960305: writeback_queue_io: older=4296583919 age=30000 enqueue=0
> 1947.944925: writeback_queue_io: older=4296588919 age=30000 enqueue=0
> 1952.929427: writeback_queue_io: older=4296593919 age=30000 enqueue=0
> 1957.914031: writeback_queue_io: older=4296598919 age=30000 enqueue=0
> 1962.898507: writeback_queue_io: older=4296603919 age=30000 enqueue=1
> 1962.898518: writeback_queue_io: older=4296603919 age=30000 enqueue=0
  OK, so now enqueue numbers look like what I'd expect. I'm relieved :)
Thanks for running the tests.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
