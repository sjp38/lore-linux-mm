Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6A3AA6B0093
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 08:59:18 -0500 (EST)
Date: Tue, 14 Dec 2010 21:59:10 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 04/35] writeback: reduce per-bdi dirty threshold ramp
 up time
Message-ID: <20101214135910.GA21401@localhost>
References: <20101213144646.341970461@intel.com>
 <20101213150326.856922289@intel.com>
 <1292333854.2019.16.camel@castor.rsk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1292333854.2019.16.camel@castor.rsk>
Sender: owner-linux-mm@kvack.org
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Richard,

On Tue, Dec 14, 2010 at 09:37:34PM +0800, Richard Kennedy wrote:
> On Mon, 2010-12-13 at 22:46 +0800, Wu Fengguang wrote:
> > plain text document attachment
> > (writeback-speedup-per-bdi-threshold-ramp-up.patch)
> > Reduce the dampening for the control system, yielding faster
> > convergence.
> > 
> > Currently it converges at a snail's pace for slow devices (in order of
> > minutes).  For really fast storage, the convergence speed should be fine.
> > 
> > It makes sense to make it reasonably fast for typical desktops.
> > 
> > After patch, it converges in ~10 seconds for 60MB/s writes and 4GB mem.
> > So expect ~1s for a fast 600MB/s storage under 4GB mem, or ~4s under
> > 16GB mem, which seems reasonable.
> > 
> > $ while true; do grep BdiDirtyThresh /debug/bdi/8:0/stats; sleep 1; done
> > BdiDirtyThresh:            0 kB
> > BdiDirtyThresh:       118748 kB
> > BdiDirtyThresh:       214280 kB
> > BdiDirtyThresh:       303868 kB
> > BdiDirtyThresh:       376528 kB
> > BdiDirtyThresh:       411180 kB
> > BdiDirtyThresh:       448636 kB
> > BdiDirtyThresh:       472260 kB
> > BdiDirtyThresh:       490924 kB
> > BdiDirtyThresh:       499596 kB
> > BdiDirtyThresh:       507068 kB
> > ...
> > DirtyThresh:          530392 kB
> > 
> > CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > CC: Richard Kennedy <richard@rsk.demon.co.uk>
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  mm/page-writeback.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > --- linux-next.orig/mm/page-writeback.c	2010-12-13 21:46:11.000000000 +0800
> > +++ linux-next/mm/page-writeback.c	2010-12-13 21:46:11.000000000 +0800
> > @@ -145,7 +145,7 @@ static int calc_period_shift(void)
> >  	else
> >  		dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
> >  				100;
> > -	return 2 + ilog2(dirty_total - 1);
> > +	return ilog2(dirty_total - 1) - 1;
> >  }
> >  
> >  /*
> > 
> > 
> Hi Fengguang,
> 
> I've been running my test set on your v3 series and generally it's
> giving good results in line with the mainline kernel, with much less
> variability and lower standard deviation of the results so it is much
> more repeatable.

Glad to hear that, and thank you very much for trying it out!

> However, it doesn't seem to be honouring the background_dirty_threshold.

> The attached graph is from a simple fio write test of 400Mb on ext4.
> All dirty pages are completely written in 15 seconds, but I expect to
> see up to background_dirty_threshold pages staying dirty until the 30
> second background task writes them out. So it is much too eager to write
> back dirty pages.
 
This is interesting, and seems easy to root cause. When testing v4,
would you help collect the following trace events?

echo 1 > /debug/tracing/events/writeback/balance_dirty_pages/enable
echo 1 > /debug/tracing/events/writeback/balance_dirty_state/enable
echo 1 > /debug/tracing/events/writeback/writeback_single_inode/enable

They'll have good opportunity to disclose the bug.

> As to the ramp up time, when writing to 2 disks at the same time I see
> the per_bdi_threshold taking up to 20 seconds to converge on a steady
> value after one of the write stops. So I think this could be speeded up
> even more, at least on my setup.

I have the roughly same ramp up time on the 1-disk 3GB mem test:

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/ext4-1dd-1M-8p-2952M-2.6.37-rc5+-2010-12-09-00-37/dirty-pages.png
 
Given that it's the typical desktop, it does seem reasonable to speed
it up further.

> I am just about to start testing v4 & will report anything interesting.

Thanks!

Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
