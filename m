Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 08B3A9000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 07:05:31 -0400 (EDT)
Date: Thu, 29 Sep 2011 19:05:25 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 10/18] writeback: dirty position control - bdi reserve
 area
Message-ID: <20110929110525.GA10979@localhost>
References: <1315318179.14232.3.camel@twins>
 <20110907123108.GB6862@localhost>
 <1315822779.26517.23.camel@twins>
 <20110918141705.GB15366@localhost>
 <20110918143721.GA17240@localhost>
 <20110918144751.GA18645@localhost>
 <20110928140205.GA26617@localhost>
 <1317221435.24040.39.camel@twins>
 <20110929033201.GA21722@localhost>
 <1317286197.22581.4.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1317286197.22581.4.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Sep 29, 2011 at 04:49:57PM +0800, Peter Zijlstra wrote:
> On Thu, 2011-09-29 at 11:32 +0800, Wu Fengguang wrote:
> > > Now I guess the only problem is when nr_bdi * MIN_WRITEBACK_PAGES ~
> > > limit, at which point things go pear shaped.
> > 
> > Yes. In that case the global @dirty will always be drove up to @limit.
> > Once @dirty dropped reasonably below, whichever bdi task wakeup first
> > will take the chance to fill the gap, which is not fair for bdi's of
> > different speed.
> > 
> > Let me retry the thresh=1M,10M test cases without MIN_WRITEBACK_PAGES.
> > Hopefully the removal of it won't impact performance a lot. 
> 
> 
> Right, so alternatively we could try an argument that this is
> sufficiently rare and shouldn't happen. People with lots of disks tend
> to also have lots of memory, etc.

Right.

> If we do find it happens we can always look at it again.

Sure.  Now I got the results for single disk thresh=1M,8M,100M cases
and find no big differences if removing MIN_WRITEBACK_PAGES:

    3.1.0-rc4-bgthresh3+      3.1.0-rc4-bgthresh4+
------------------------  ------------------------
                 3988742        +1.9%      4063217  thresh=100M/ext4-10dd-4k-8p-4096M-100M:10-X
                 4758884        +1.5%      4829320  thresh=100M/ext4-1dd-4k-8p-4096M-100M:10-X
                 4621240        +1.6%      4693525  thresh=100M/ext4-2dd-4k-8p-4096M-100M:10-X
                 3420717        +0.1%      3423712  thresh=100M/xfs-10dd-4k-8p-4096M-100M:10-X
                 4361830        +1.4%      4423554  thresh=100M/xfs-1dd-4k-8p-4096M-100M:10-X
                 3964043        +0.2%      3972057  thresh=100M/xfs-2dd-4k-8p-4096M-100M:10-X
                 2937926        +0.6%      2956870  thresh=1M/ext4-10dd-4k-8p-4096M-1M:10-X
                 4472552        -1.9%      4387457  thresh=1M/ext4-1dd-4k-8p-4096M-1M:10-X
                 4085707        -3.0%      3961155  thresh=1M/ext4-2dd-4k-8p-4096M-1M:10-X
                 2206897        +2.1%      2253839  thresh=1M/xfs-10dd-4k-8p-4096M-1M:10-X
                 4207336        -2.1%      4119821  thresh=1M/xfs-1dd-4k-8p-4096M-1M:10-X
                 3739888        -3.6%      3604315  thresh=1M/xfs-2dd-4k-8p-4096M-1M:10-X
                 3279302        -0.2%      3273310  thresh=8M/ext4-10dd-4k-8p-4096M-8M:10-X
                 4834878        +1.6%      4912372  thresh=8M/ext4-1dd-4k-8p-4096M-8M:10-X
                 4511120        -1.7%      4435193  thresh=8M/ext4-2dd-4k-8p-4096M-8M:10-X
                 2443874        -0.5%      2432188  thresh=8M/xfs-10dd-4k-8p-4096M-8M:10-X
                 4308416        -0.6%      4283110  thresh=8M/xfs-1dd-4k-8p-4096M-8M:10-X
                 3739810        +0.6%      3763320  thresh=8M/xfs-2dd-4k-8p-4096M-8M:10-X

Or lowering the largest promotion ratio from 128 to 8:

    3.1.0-rc4-bgthresh4+      3.1.0-rc4-bgthresh5+
------------------------  ------------------------
                 4063217        -0.0%      4062022  thresh=100M/ext4-10dd-4k-8p-4096M-100M:10-X
                 4829320        +1.1%      4882829  thresh=100M/ext4-1dd-4k-8p-4096M-100M:10-X
                 4693525        +0.1%      4700537  thresh=100M/ext4-2dd-4k-8p-4096M-100M:10-X
                 3423712        +0.2%      3431603  thresh=100M/xfs-10dd-4k-8p-4096M-100M:10-X
                 4423554        -0.3%      4408912  thresh=100M/xfs-1dd-4k-8p-4096M-100M:10-X
                 3972057        -0.1%      3968535  thresh=100M/xfs-2dd-4k-8p-4096M-100M:10-X
                 2956870        -0.9%      2929605  thresh=1M/ext4-10dd-4k-8p-4096M-1M:10-X
                 4387457        -0.2%      4378233  thresh=1M/ext4-1dd-4k-8p-4096M-1M:10-X
                 3961155        -0.5%      3940075  thresh=1M/ext4-2dd-4k-8p-4096M-1M:10-X
                 2253839        -0.9%      2232976  thresh=1M/xfs-10dd-4k-8p-4096M-1M:10-X
                 4119821        -2.1%      4031983  thresh=1M/xfs-1dd-4k-8p-4096M-1M:10-X
                 3604315        -3.1%      3493042  thresh=1M/xfs-2dd-4k-8p-4096M-1M:10-X
                 3273310        -1.1%      3237060  thresh=8M/ext4-10dd-4k-8p-4096M-8M:10-X
                 4912372        -0.0%      4911287  thresh=8M/ext4-1dd-4k-8p-4096M-8M:10-X
                 4435193        +0.1%      4441581  thresh=8M/ext4-2dd-4k-8p-4096M-8M:10-X
                 2432188        +1.1%      2459249  thresh=8M/xfs-10dd-4k-8p-4096M-8M:10-X
                 4283110        +0.1%      4289456  thresh=8M/xfs-1dd-4k-8p-4096M-8M:10-X
                 3763320        -0.1%      3758938  thresh=8M/xfs-2dd-4k-8p-4096M-8M:10-X

As for the thresh=100M JBOD cases, I don't see much occurrences of promotion
ratio > 2. So the simplification should make no difference, too.

Thus the finalized code will be:

+       x_intercept = bdi_thresh / 2;
+       if (bdi_dirty < x_intercept) {
+               if (bdi_dirty > x_intercept / 8) {
+                       pos_ratio *= x_intercept;
+                       do_div(pos_ratio, bdi_dirty);
+               } else
+                       pos_ratio *= 8;
+       }

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
