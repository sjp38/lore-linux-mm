Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A62099000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 00:11:29 -0400 (EDT)
Date: Thu, 29 Sep 2011 12:11:24 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/18] IO-less dirty throttling v11
Message-ID: <20110929041124.GB21722@localhost>
References: <20110904015305.367445271@intel.com>
 <20110928145857.GA15587@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110928145857.GA15587@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Christoph,

On Wed, Sep 28, 2011 at 10:58:57PM +0800, Christoph Hellwig wrote:
> On Sun, Sep 04, 2011 at 09:53:05AM +0800, Wu Fengguang wrote:
> > Hi,
> > 
> > Finally, the complete IO-less balance_dirty_pages(). NFS is observed to perform
> > better or worse depending on the memory size. Otherwise the added patches can
> > address all known regressions.
> > 
> >         git://git.kernel.org/pub/scm/linux/kernel/git/wfg/writeback.git dirty-throttling-v11
> > 	(to be updated; currently it contains a pre-release v11)
> 
> Fengguang,
> 
> is there any chance we could start doing just the IO-less
> balance_dirty_pages, but not all the subtile other changes?  I.e. are
> the any known issues that make things work than current mainline if we
> only put in patches 1 to 6?

Patches 1-6 are the bare IO-less framework, the followed patches are

1) tracing for easy debug
2) regression fixes (eg. under-utilized disk in small memory systems)
3) improvements

My recent focus is trying to measure and fix the various regressions.
Up to now the JBOD regressions have been addressed and single disk
performance also looks good.

NFS throughputs are observed to drop/rise somehow randomly in
different cases and cannot be fixed fundamentally with the trivial
approaches I've experimented.

3.1.0-rc4-vanilla+  3.1.0-rc4-bgthresh3+  3.1.0-rc4-nfs-smooth+
------------------  --------------------  ---------------------

           3459793   -33.2%      2310900     +2.4%      3543478  NFS-thresh=1G/nfs-10dd-1M-32p-32768M-1024M:10-X
           3371104   -32.8%      2265584    -13.9%      2902573  NFS-thresh=1G/nfs-1dd-1M-32p-32768M-1024M:10-X
           2798005   +13.4%      3171975    +21.4%      3395410  NFS-thresh=1G/nfs-2dd-1M-32p-32768M-1024M:10-X

           1641479   +13.9%      1869541    +52.7%      2506587  NFS-thresh=100M/nfs-10dd-1M-32p-32768M-100M:10-X
           3036860   -19.4%      2447633    -32.1%      2063006  NFS-thresh=100M/nfs-1dd-1M-32p-32768M-100M:10-X
           2050746   +19.8%      2456601    +28.4%      2634044  NFS-thresh=100M/nfs-2dd-1M-32p-32768M-100M:10-X

           1042855    +2.7%      1070893     +0.9%      1052112  NFS-thresh=10M/nfs-10dd-1M-32p-32768M-10M:10-X
           2106794   -41.6%      1231128    -54.6%       957305  NFS-thresh=10M/nfs-1dd-1M-32p-32768M-10M:10-X
           2034313   -40.4%      1212212    -51.7%       982609  NFS-thresh=10M/nfs-2dd-1M-32p-32768M-10M:10-X

            239379                     0    +10.2%       263894  NFS-thresh=1M/nfs-10dd-1M-32p-32768M-1M:10-X
            521149   -42.3%       300872    +13.9%       593485  NFS-thresh=1M/nfs-1dd-1M-32p-32768M-1M:10-X
            564565                     0    -49.6%       284397  NFS-thresh=1M/nfs-2dd-1M-32p-32768M-1M:10-X

> We're getting close to another merge window, and we're still busy
> trying to figure out all the details of the bandwith estimation.  I
> think we'd have a much more robust tree if we'd first only merge the
> infrastructure (IO-less balance_dirty_pages()) and then work on the
> algorithms separately.

Agreed.  Let me sort out the minimal set of patches that can still
maintain the vanilla kernel performance, plus the tracing patches.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
