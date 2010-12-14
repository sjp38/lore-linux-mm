Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4400B6B0093
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 08:37:47 -0500 (EST)
Subject: Re: [PATCH 04/35] writeback: reduce per-bdi dirty threshold ramp
 up time
From: Richard Kennedy <richard@rsk.demon.co.uk>
In-Reply-To: <20101213150326.856922289@intel.com>
References: <20101213144646.341970461@intel.com>
	 <20101213150326.856922289@intel.com>
Content-Type: multipart/mixed; boundary="=-kuCK84pMs8//cNx5PF32"
Date: Tue, 14 Dec 2010 13:37:34 +0000
Message-ID: <1292333854.2019.16.camel@castor.rsk>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


--=-kuCK84pMs8//cNx5PF32
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Mon, 2010-12-13 at 22:46 +0800, Wu Fengguang wrote:
> plain text document attachment
> (writeback-speedup-per-bdi-threshold-ramp-up.patch)
> Reduce the dampening for the control system, yielding faster
> convergence.
> 
> Currently it converges at a snail's pace for slow devices (in order of
> minutes).  For really fast storage, the convergence speed should be fine.
> 
> It makes sense to make it reasonably fast for typical desktops.
> 
> After patch, it converges in ~10 seconds for 60MB/s writes and 4GB mem.
> So expect ~1s for a fast 600MB/s storage under 4GB mem, or ~4s under
> 16GB mem, which seems reasonable.
> 
> $ while true; do grep BdiDirtyThresh /debug/bdi/8:0/stats; sleep 1; done
> BdiDirtyThresh:            0 kB
> BdiDirtyThresh:       118748 kB
> BdiDirtyThresh:       214280 kB
> BdiDirtyThresh:       303868 kB
> BdiDirtyThresh:       376528 kB
> BdiDirtyThresh:       411180 kB
> BdiDirtyThresh:       448636 kB
> BdiDirtyThresh:       472260 kB
> BdiDirtyThresh:       490924 kB
> BdiDirtyThresh:       499596 kB
> BdiDirtyThresh:       507068 kB
> ...
> DirtyThresh:          530392 kB
> 
> CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> CC: Richard Kennedy <richard@rsk.demon.co.uk>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  mm/page-writeback.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux-next.orig/mm/page-writeback.c	2010-12-13 21:46:11.000000000 +0800
> +++ linux-next/mm/page-writeback.c	2010-12-13 21:46:11.000000000 +0800
> @@ -145,7 +145,7 @@ static int calc_period_shift(void)
>  	else
>  		dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
>  				100;
> -	return 2 + ilog2(dirty_total - 1);
> +	return ilog2(dirty_total - 1) - 1;
>  }
>  
>  /*
> 
> 
Hi Fengguang,

I've been running my test set on your v3 series and generally it's
giving good results in line with the mainline kernel, with much less
variability and lower standard deviation of the results so it is much
more repeatable.

However, it doesn't seem to be honouring the background_dirty_threshold.

The attached graph is from a simple fio write test of 400Mb on ext4.
All dirty pages are completely written in 15 seconds, but I expect to
see up to background_dirty_threshold pages staying dirty until the 30
second background task writes them out. So it is much too eager to write
back dirty pages.

As to the ramp up time, when writing to 2 disks at the same time I see
the per_bdi_threshold taking up to 20 seconds to converge on a steady
value after one of the write stops. So I think this could be speeded up
even more, at least on my setup.

I am just about to start testing v4 & will report anything interesting.

regards
Richard
  

 


--=-kuCK84pMs8//cNx5PF32
Content-Type: image/png; name="dirty.png"
Content-Disposition: attachment; filename="dirty.png"
Content-Transfer-Encoding: base64

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


--=-kuCK84pMs8//cNx5PF32--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
