Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8E4716B0087
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 03:23:07 -0500 (EST)
Date: Wed, 3 Feb 2010 09:23:00 +0100
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH 01/11] readahead: limit readahead size for small devices
Message-ID: <20100203082259.GO5733@kernel.dk>
References: <20100202152835.683907822@intel.com> <20100202153316.375570078@intel.com> <20100202193826.GC5733@kernel.dk> <20100203061350.GA22890@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100203061350.GA22890@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 03 2010, Wu Fengguang wrote:
> On Wed, Feb 03, 2010 at 03:38:26AM +0800, Jens Axboe wrote:
> > On Tue, Feb 02 2010, Wu Fengguang wrote:
> > > Linus reports a _really_ small & slow (505kB, 15kB/s) USB device,
> > > on which blkid runs unpleasantly slow. He manages to optimize the blkid
> > > reads down to 1kB+16kB, but still kernel read-ahead turns it into 48kB.
> > > 
> > >      lseek 0,    read 1024   => readahead 4 pages (start of file)
> > >      lseek 1536, read 16384  => readahead 8 pages (page contiguous)
> > > 
> > > The readahead heuristics involved here are reasonable ones in general.
> > > So it's good to fix blkid with fadvise(RANDOM), as Linus already did.
> > > 
> > > For the kernel part, Linus suggests:
> > >   So maybe we could be less aggressive about read-ahead when the size of
> > >   the device is small? Turning a 16kB read into a 64kB one is a big deal,
> > >   when it's about 15% of the whole device!
> > > 
> > > This looks reasonable: smaller device tend to be slower (USB sticks as
> > > well as micro/mobile/old hard disks).
> > > 
> > > Given that the non-rotational attribute is not always reported, we can
> > > take disk size as a max readahead size hint. We use a formula that
> > > generates the following concrete limits:
> > > 
> > >         disk size    readahead size
> > >      (scale by 4)      (scale by 2)
> > >                2M            	 4k
> > >                8M                8k
> > >               32M               16k
> > >              128M               32k
> > >              512M               64k
> > >                2G              128k
> > >                8G              256k
> > >               32G              512k
> > >              128G             1024k
> > 
> > I'm not sure the size part makes a ton of sense. You can have really
> > fast small devices, and large slow devices. One real world example are
> > the Sun FMod SSD devices, which are only 22GB in size but are faster
> > than the Intel X25-E SLC disks.
> > 
> > What makes it even worse for these devices is that they are often
> > attached to fatter controllers than ahci, where command overhead is
> > larger.
> 
> Ah, good to know about this fast 22GB SSD.
> 
> > Running your script on such a device yields (I enlarged the read-count
> > by 2, makes it more reproducible):
> > 
> > MARVELL SD88SA02 MP1F
> > 
> > rasize	1st             2nd
> > ------------------------------------------------------------------
> >   4k	 41 MB/s	 41 MB/s
> >  16k	 85 MB/s	 81 MB/s
> >  32k	102 MB/s	109 MB/s
> >  64k	125 MB/s	144 MB/s
> > 128k	183 MB/s	185 MB/s
> > 256k	216 MB/s	216 MB/s
> > 512k	216 MB/s	236 MB/s
> > 1024k	251 MB/s	252 MB/s
> >   2M	258 MB/s	258 MB/s
> >   4M	266 MB/s	266 MB/s
> >   8M	266 MB/s	266 MB/s
> > 
> > So for that device, 1M-2M looks like the sweet spot, with even needing
> > 4-8M to fully reach full throughput.
> 
> Thanks for the data! I updated the formula to (16GB device => 1MB
> readahead). However the limit in this patch is only true for <4GB
> devices, since the default readahead size is merely 512KB.

Thanks Wu, you can add my acked-by.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
