Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3BBD16B0093
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 09:57:02 -0500 (EST)
Date: Tue, 14 Dec 2010 22:56:54 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 04/35] writeback: reduce per-bdi dirty threshold ramp
 up time
Message-ID: <20101214145654.GA25607@localhost>
References: <20101213144646.341970461@intel.com>
 <20101213150326.856922289@intel.com>
 <1292333854.2019.16.camel@castor.rsk>
 <20101214135910.GA21401@localhost>
 <20101214143325.GA22764@localhost>
 <20101214143902.GA24827@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101214143902.GA24827@localhost>
Sender: owner-linux-mm@kvack.org
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 14, 2010 at 10:39:02PM +0800, Wu Fengguang wrote:
> On Tue, Dec 14, 2010 at 10:33:25PM +0800, Wu Fengguang wrote:
> > On Tue, Dec 14, 2010 at 09:59:10PM +0800, Wu Fengguang wrote:
> > > On Tue, Dec 14, 2010 at 09:37:34PM +0800, Richard Kennedy wrote:
> > 
> > > > As to the ramp up time, when writing to 2 disks at the same time I see
> > > > the per_bdi_threshold taking up to 20 seconds to converge on a steady
> > > > value after one of the write stops. So I think this could be speeded up
> > > > even more, at least on my setup.
> > > 
> > > I have the roughly same ramp up time on the 1-disk 3GB mem test:
> > > 
> > > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/ext4-1dd-1M-8p-2952M-2.6.37-rc5+-2010-12-09-00-37/dirty-pages.png
> > >  
> > 
> > Interestingly, the above graph shows that after about 10s fast ramp
> > up, there is another 20s slow ramp down. It's obviously due the
> > decline of global limit:
> > 
> > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/ext4-1dd-1M-8p-2952M-2.6.37-rc5+-2010-12-09-00-37/vmstat-dirty.png
> > 
> > But why is the global limit declining?  The following log shows that
> > nr_file_pages keeps growing and goes stable after 75 seconds (so long
> > time!). In the same period nr_free_pages goes slowly down to its
> > stable value. Given that the global limit is mainly derived from
> > nr_free_pages+nr_file_pages (I disabled swap), something must be
> > slowly eating memory until 75 ms. Maybe the tracing ring buffers?
> > 
> >          free     file      reclaimable pages
> > 50s      369324 + 318760 => 688084
> > 60s      235989 + 448096 => 684085
> > 
> > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/ext4-1dd-1M-8p-2952M-2.6.37-rc5+-2010-12-09-00-37/vmstat
> 
> The log shows that ~64MB reclaimable memory is stoled. But the trace
> data only takes 1.8MB. Hmm..

ext2 has the same pattern:

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/ext2-1dd-1M-8p-2952M-2.6.37-rc5+-2010-12-09-01-36/dirty-pages.png

But it does not happen for btrfs!

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/btrfs-1dd-1M-8p-2952M-2.6.37-rc5-2010-12-10-21-23/vmstat-dirty.png

Seems that it's the nr_slab_reclaimable keep growing until 75s.

Looking at
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/ext2-1dd-1M-8p-2952M-2.6.37-rc5+-2010-12-09-01-36/slabinfo-end

It should be the buffer heads that slowly eats the memory during the time:

buffer_head       670304 670662    104   37    1 : tunables  120   60 8 : slabdata  18117  18126    480

(670304/37)*4 = 72464KB.

The consumption seems acceptable for a 3G memory system.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
