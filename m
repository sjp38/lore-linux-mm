Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 48B649000BD
	for <linux-mm@kvack.org>; Sun, 18 Sep 2011 10:37:28 -0400 (EDT)
Date: Sun, 18 Sep 2011 22:37:21 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 10/18] writeback: dirty position control - bdi reserve
 area
Message-ID: <20110918143721.GA17240@localhost>
References: <20110904015305.367445271@intel.com>
 <20110904020915.942753370@intel.com>
 <1315318179.14232.3.camel@twins>
 <20110907123108.GB6862@localhost>
 <1315822779.26517.23.camel@twins>
 <20110918141705.GB15366@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110918141705.GB15366@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, Sep 18, 2011 at 10:17:05PM +0800, Wu Fengguang wrote:
> On Mon, Sep 12, 2011 at 06:19:38PM +0800, Peter Zijlstra wrote:
> > On Wed, 2011-09-07 at 20:31 +0800, Wu Fengguang wrote:
> > > > > +   x_intercept = min(write_bw, freerun);
> > > > > +   if (bdi_dirty < x_intercept) {
> > > > 
> > > > So the point of the freerun point is that we never throttle before it,
> > > > so basically all the below shouldn't be needed at all, right? 
> > > 
> > > Yes!
> > > 
> > > > > +           if (bdi_dirty > x_intercept / 8) {
> > > > > +                   pos_ratio *= x_intercept;
> > > > > +                   do_div(pos_ratio, bdi_dirty);
> > > > > +           } else
> > > > > +                   pos_ratio *= 8;
> > > > > +   }
> > > > > +
> > > > >     return pos_ratio;
> > > > >  }
> > 
> > Does that mean we can remove this whole block?
> 
> Right, if the bdi freerun concept is proved to work fine.
> 
> Unfortunately I find it mostly yields lower performance than bdi
> reserve area. Patch is attached. If you would like me try other
> patches, I can easily kick off new tests and redo the comparison.
> 
> Here is the nr_written numbers over various JBOD test cases,
> the larger, the better:
> 
> bdi-reserve     bdi-freerun    diff    case
> ---------------------------------------------------------------------------------------
> 38375271        31553807      -17.8%	JBOD-10HDD-6G/xfs-100dd-1M-16p-5895M-20
> 30478879        28631491       -6.1%	JBOD-10HDD-6G/xfs-10dd-1M-16p-5895M-20
> 29735407        28871956       -2.9%	JBOD-10HDD-6G/xfs-1dd-1M-16p-5895M-20
> 30850350        28344165       -8.1%	JBOD-10HDD-6G/xfs-2dd-1M-16p-5895M-20
> 17706200        16174684       -8.6%	JBOD-10HDD-thresh=100M/xfs-100dd-1M-16p-5895M-100M
> 23374918        14376942      -38.5%	JBOD-10HDD-thresh=100M/xfs-10dd-1M-16p-5895M-100M
> 20659278        19640375       -4.9%	JBOD-10HDD-thresh=100M/xfs-1dd-1M-16p-5895M-100M
> 22517497        14552321      -35.4%	JBOD-10HDD-thresh=100M/xfs-2dd-1M-16p-5895M-100M
> 68287850        61078553      -10.6%	JBOD-10HDD-thresh=2G/xfs-100dd-1M-16p-5895M-2048M
> 33835247        32018425       -5.4%	JBOD-10HDD-thresh=2G/xfs-10dd-1M-16p-5895M-2048M
> 30187817        29942083       -0.8%	JBOD-10HDD-thresh=2G/xfs-1dd-1M-16p-5895M-2048M
> 30563144        30204022       -1.2%	JBOD-10HDD-thresh=2G/xfs-2dd-1M-16p-5895M-2048M
> 34476862        34645398       +0.5%	JBOD-10HDD-thresh=4G/xfs-10dd-1M-16p-5895M-4096M
> 30326479        30097263       -0.8%	JBOD-10HDD-thresh=4G/xfs-1dd-1M-16p-5895M-4096M
> 30446767        30339683       -0.4%	JBOD-10HDD-thresh=4G/xfs-2dd-1M-16p-5895M-4096M
> 40793956        45936678      +12.6%	JBOD-10HDD-thresh=800M/xfs-100dd-1M-16p-5895M-800M
> 27481305        24867282       -9.5%	JBOD-10HDD-thresh=800M/xfs-10dd-1M-16p-5895M-800M
> 25651257        22507406      -12.3%	JBOD-10HDD-thresh=800M/xfs-1dd-1M-16p-5895M-800M
> 19849350        21298787       +7.3%	JBOD-10HDD-thresh=800M/xfs-2dd-1M-16p-5895M-800M

BTW, I also compared the IO-less patchset and the vanilla kernel's
JBOD performance. Basically, the performance is lightly improved
under large memory, and reduced a lot in small memory servers.

 vanillla IO-less  
--------------------------------------------------------------------------------
 31189025 34476862      +10.5%  JBOD-10HDD-thresh=4G/xfs-10dd-1M-16p-5895M-4096M
 30441974 30326479       -0.4%  JBOD-10HDD-thresh=4G/xfs-1dd-1M-16p-5895M-4096M
 30484578 30446767       -0.1%  JBOD-10HDD-thresh=4G/xfs-2dd-1M-16p-5895M-4096M

 68532421 68287850       -0.4%  JBOD-10HDD-thresh=2G/xfs-100dd-1M-16p-5895M-2048M
 31606793 33835247       +7.1%  JBOD-10HDD-thresh=2G/xfs-10dd-1M-16p-5895M-2048M
 30404955 30187817       -0.7%  JBOD-10HDD-thresh=2G/xfs-1dd-1M-16p-5895M-2048M
 30425591 30563144       +0.5%  JBOD-10HDD-thresh=2G/xfs-2dd-1M-16p-5895M-2048M

 40451069 38375271       -5.1%  JBOD-10HDD-6G/xfs-100dd-1M-16p-5895M-20
 30903629 30478879       -1.4%  JBOD-10HDD-6G/xfs-10dd-1M-16p-5895M-20
 30113560 29735407       -1.3%  JBOD-10HDD-6G/xfs-1dd-1M-16p-5895M-20
 30181418 30850350       +2.2%  JBOD-10HDD-6G/xfs-2dd-1M-16p-5895M-20

 46067335 40793956      -11.4%  JBOD-10HDD-thresh=800M/xfs-100dd-1M-16p-5895M-800M
 30425063 27481305       -9.7%  JBOD-10HDD-thresh=800M/xfs-10dd-1M-16p-5895M-800M
 28437929 25651257       -9.8%  JBOD-10HDD-thresh=800M/xfs-1dd-1M-16p-5895M-800M
 29409406 19849350      -32.5%  JBOD-10HDD-thresh=800M/xfs-2dd-1M-16p-5895M-800M

 26508063 17706200      -33.2%  JBOD-10HDD-thresh=100M/xfs-100dd-1M-16p-5895M-100M
 23767810 23374918       -1.7%  JBOD-10HDD-thresh=100M/xfs-10dd-1M-16p-5895M-100M
 28032891 20659278      -26.3%  JBOD-10HDD-thresh=100M/xfs-1dd-1M-16p-5895M-100M
 26049973 22517497      -13.6%  JBOD-10HDD-thresh=100M/xfs-2dd-1M-16p-5895M-100M

There are still some itches in JBOD..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
