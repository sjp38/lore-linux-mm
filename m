Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2EB576B00AE
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 12:15:16 -0400 (EDT)
Date: Mon, 13 Sep 2010 00:15:07 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 13/17] writeback: reduce per-bdi dirty threshold ramp
 up time
Message-ID: <20100912161507.GA5247@localhost>
References: <20100912154945.758129106@intel.com>
 <20100912155204.602761236@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100912155204.602761236@intel.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Richard Kennedy <richard@rsk.demon.co.uk>, "Martin J. Bligh" <mbligh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Sun, Sep 12, 2010 at 11:49:58PM +0800, Wu, Fengguang wrote:
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
> 16GB mem, which looks good.
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

One related observation is, the task fraction may suddenly drop:

dd-4323  [004] 21608.535781: balance_dirty_pages: bdi=8:0 weight=97% thresh=124863 gap=7071 dirtied=513 pause=44 bw=44677838
dd-4323  [004] 21608.579568: balance_dirty_pages: bdi=8:0 weight=97% thresh=124851 gap=7315 dirtied=513 pause=44 bw=46321077
dd-4323  [004] 21608.623586: balance_dirty_pages: bdi=8:0 weight=97% thresh=124852 gap=7156 dirtied=513 pause=44 bw=45199674
dd-4323  [000] 21608.667526: balance_dirty_pages: bdi=8:0 weight=97% thresh=124853 gap=7029 dirtied=513 pause=44 bw=44337926
dd-4323  [000] 21608.711259: balance_dirty_pages: bdi=8:0 weight=97% thresh=124842 gap=7146 dirtied=513 pause=44 bw=45074728
dd-4323  [000] 21608.755051: balance_dirty_pages: bdi=8:0 weight=97% thresh=124843 gap=6891 dirtied=513 pause=48 bw=43356794
dd-4323  [000] 21608.802953: balance_dirty_pages: bdi=8:0 weight=97% thresh=124834 gap=6722 dirtied=513 pause=48 bw=42211067
dd-4323  [000] 21608.850745: balance_dirty_pages: bdi=8:0 weight=97% thresh=124834 gap=6594 dirtied=513 pause=48 bw=41326916
dd-4323  [004] 21608.900524: balance_dirty_pages: bdi=8:0 weight=62% thresh=127735 gap=7575 dirtied=513 pause=40 bw=47863047
dd-4323  [004] 21608.990461: balance_dirty_pages: bdi=8:0 weight=22% thresh=131040 gap=8064 dirtied=513 pause=40 bw=49548668
dd-4323  [004] 21609.030239: balance_dirty_pages: bdi=8:0 weight=23% thresh=130971 gap=7739 dirtied=513 pause=44 bw=47469455
dd-4323  [004] 21609.074075: balance_dirty_pages: bdi=8:0 weight=23% thresh=130915 gap=7427 dirtied=513 pause=44 bw=45455503
dd-4323  [004] 21609.117927: balance_dirty_pages: bdi=8:0 weight=24% thresh=130849 gap=7105 dirtied=513 pause=48 bw=43394683
dd-4323  [004] 21609.165843: balance_dirty_pages: bdi=8:0 weight=25% thresh=130770 gap=6898 dirtied=513 pause=48 bw=42071194
dd-4323  [004] 21609.213769: balance_dirty_pages: bdi=8:0 weight=26% thresh=130719 gap=7103 dirtied=513 pause=48 bw=43366955
dd-4323  [004] 21609.261483: balance_dirty_pages: bdi=8:0 weight=26% thresh=130655 gap=6911 dirtied=513 pause=48 bw=42130514
...
dd-4323  [001] 21619.473748: balance_dirty_pages: bdi=8:0 weight=96% thresh=124200 gap=7656 dirtied=513 pause=36 bw=55354531
dd-4323  [000] 21619.762110: balance_dirty_pages: bdi=8:0 weight=96% thresh=124148 gap=7540 dirtied=513 pause=36 bw=54586428
dd-4323  [000] 21619.804259: balance_dirty_pages: bdi=8:0 weight=96% thresh=124145 gap=7281 dirtied=513 pause=36 bw=52772359
dd-4323  [004] 21619.840740: balance_dirty_pages: bdi=8:0 weight=96% thresh=124133 gap=7397 dirtied=513 pause=36 bw=53627516
dd-4323  [004] 21619.876600: balance_dirty_pages: bdi=8:0 weight=96% thresh=124133 gap=7493 dirtied=513 pause=36 bw=54331060
dd-4323  [004] 21619.912482: balance_dirty_pages: bdi=8:0 weight=97% thresh=124133 gap=7621 dirtied=513 pause=36 bw=55266828
dd-4323  [007] 21619.955231: balance_dirty_pages: bdi=8:0 weight=95% thresh=124242 gap=7410 dirtied=513 pause=36 bw=53695642
dd-4323  [007] 21619.992100: balance_dirty_pages: bdi=8:0 weight=95% thresh=124246 gap=7542 dirtied=513 pause=36 bw=54714918
dd-4323  [007] 21620.028048: balance_dirty_pages: bdi=8:0 weight=95% thresh=124232 gap=7656 dirtied=513 pause=36 bw=55612568
dd-4323  [007] 21620.067278: balance_dirty_pages: bdi=8:0 weight=95% thresh=124217 gap=7257 dirtied=513 pause=36 bw=52780982
dd-4323  [007] 21620.103783: balance_dirty_pages: bdi=8:0 weight=95% thresh=124219 gap=7387 dirtied=513 pause=36 bw=53787250
dd-4323  [003] 21620.143069: balance_dirty_pages: bdi=8:0 weight=84% thresh=125141 gap=7253 dirtied=513 pause=36 bw=53982296
dd-4323  [000] 21620.259771: balance_dirty_pages: bdi=8:0 weight=21% thresh=130291 gap=7955 dirtied=513 pause=36 bw=56894085
dd-4323  [004] 21620.295309: balance_dirty_pages: bdi=8:0 weight=22% thresh=130210 gap=7746 dirtied=513 pause=36 bw=55325100
dd-4323  [004] 21620.331046: balance_dirty_pages: bdi=8:0 weight=22% thresh=130145 gap=7425 dirtied=513 pause=36 bw=52955050
dd-4323  [004] 21620.367022: balance_dirty_pages: bdi=8:0 weight=23% thresh=130070 gap=7222 dirtied=513 pause=40 bw=51489214
dd-4323  [004] 21620.406877: balance_dirty_pages: bdi=8:0 weight=24% thresh=130004 gap=6900 dirtied=513 pause=40 bw=49086099
dd-4323  [004] 21620.446702: balance_dirty_pages: bdi=8:0 weight=25% thresh=129935 gap=6831 dirtied=513 pause=40 bw=48603064
dd-4323  [007] 21620.486673: balance_dirty_pages: bdi=8:0 weight=26% thresh=129873 gap=6641 dirtied=513 pause=44 bw=47142569
dd-4323  [007] 21620.530438: balance_dirty_pages: bdi=8:0 weight=26% thresh=129802 gap=6442 dirtied=513 pause=44 bw=45673274
dd-4323  [007] 21620.574312: balance_dirty_pages: bdi=8:0 weight=27% thresh=129743 gap=6415 dirtied=513 pause=44 bw=45466202
dd-4323  [007] 21620.618182: balance_dirty_pages: bdi=8:0 weight=28% thresh=129685 gap=6197 dirtied=513 pause=44 bw=43856286

I've not looked into this yet.. need to go to bed now :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
