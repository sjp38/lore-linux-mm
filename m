Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0D74C6B004A
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 11:41:41 -0400 (EDT)
Date: Fri, 1 Jul 2011 23:41:36 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 03/27] xfs: use write_cache_pages for writeback
 clustering
Message-ID: <20110701154136.GA17881@localhost>
References: <20110629140109.003209430@bombadil.infradead.org>
 <20110629140336.950805096@bombadil.infradead.org>
 <20110701022248.GM561@dastard>
 <20110701041851.GN561@dastard>
 <20110701093305.GA28531@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110701093305.GA28531@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Dave Chinner <david@fromorbit.com>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Christoph,

On Fri, Jul 01, 2011 at 05:33:05PM +0800, Christoph Hellwig wrote:
> Johannes, Mel, Wu,
> 
> Dave has been stressing some XFS patches of mine that remove the XFS
> internal writeback clustering in favour of using write_cache_pages.
> 
> As part of investigating the behaviour he found out that we're still
> doing lots of I/O from the end of the LRU in kswapd.  Not only is that
> pretty bad behaviour in general, but it also means we really can't
> just remove the writeback clustering in writepage given how much
> I/O is still done through that.
> 
> Any chance we could the writeback vs kswap behaviour sorted out a bit
> better finally?

I once tried this approach:

http://www.spinics.net/lists/linux-mm/msg09202.html

It used a list structure that is not linearly scalable, however that
part should be independently improvable when necessary.

The real problem was, it seem to not very effective in my test runs.
I found many ->nr_pages works queued before the ->inode works, which
effectively makes the flusher working on more dispersed pages rather
than focusing on the dirty pages encountered in LRU reclaim.

So for the patch to work efficiently, we'll need to first merge the
->nr_pages works and make them lower priority than the ->inode works.

Thanks,
Fengguang

> Some excerpts from the previous discussion:
> 
> On Fri, Jul 01, 2011 at 02:18:51PM +1000, Dave Chinner wrote:
> > I'm now only running test 180 on 100 files rather than the 1000 the
> > test normally runs on, because it's faster and still shows the
> > problem.  That means the test is only using 1GB of disk space, and
> > I'm running on a VM with 1GB RAM. It appears to be related to the VM
> > triggering random page writeback from the LRU - 100x10MB files more
> > than fills memory, hence it being the smallest test case i could
> > reproduce the problem on.
> > 
> > My triage notes are as follows, and the patch that fixes the bug is
> > attached below.
> > 
> > --- 180.out     2010-04-28 15:00:22.000000000 +1000
> > +++ 180.out.bad 2011-07-01 12:44:12.000000000 +1000
> > @@ -1 +1,9 @@
> >  QA output created by 180
> > +file /mnt/scratch/81 has incorrect size 10473472 - sync failed
> > +file /mnt/scratch/86 has incorrect size 10371072 - sync failed
> > +file /mnt/scratch/87 has incorrect size 10104832 - sync failed
> > +file /mnt/scratch/88 has incorrect size 10125312 - sync failed
> > +file /mnt/scratch/89 has incorrect size 10469376 - sync failed
> > +file /mnt/scratch/90 has incorrect size 10240000 - sync failed
> > +file /mnt/scratch/91 has incorrect size 10362880 - sync failed
> > +file /mnt/scratch/92 has incorrect size 10366976 - sync failed
> > 
> > $ ls -li /mnt/scratch/ | awk '/rw/ { printf("0x%x %d %d\n", $1, $6, $10); }'
> > 0x244093 10473472 81
> > 0x244098 10371072 86
> > 0x244099 10104832 87
> > 0x24409a 10125312 88
> > 0x24409b 10469376 89
> > 0x24409c 10240000 90
> > 0x24409d 10362880 91
> > 0x24409e 10366976 92
> > 
> > So looking at inode 0x244099 (/mnt/scratch/87), the last setfilesize
> > call in the trace (got a separate patch for that) is:
> > 
> >            <...>-393   [000] 696245.229559: xfs_ilock_nowait:     dev 253:16 ino 0x244099 flags ILOCK_EXCL caller xfs_setfilesize
> >            <...>-393   [000] 696245.229560: xfs_setfilesize:      dev 253:16 ino 0x244099 isize 0xa00000 disize 0x94e000 new_size 0x0 offset 0x600000 count 3813376
> >            <...>-393   [000] 696245.229561: xfs_iunlock:          dev 253:16 ino 0x244099 flags ILOCK_EXCL caller xfs_setfilesize
> > 
> > For an IO that was from offset 0x600000 for just under 4MB. The end
> > of that IO is at byte 10104832, which is _exactly_ what the inode
> > size says it is.
> > 
> > It is very clear that from the IO completions that we are getting a
> > *lot* of kswapd driven writeback directly through .writepage:
> > 
> > $ grep "xfs_setfilesize:" t.t |grep "4096$" | wc -l
> > 801
> > $ grep "xfs_setfilesize:" t.t |grep -v "4096$" | wc -l
> > 78
> > 
> > So there's ~900 IO completions that change the file size, and 90% of
> > them are single page updates.
> > 
> > $ ps -ef |grep [k]swap
> > root       514     2  0 12:43 ?        00:00:00 [kswapd0]
> > $ grep "writepage:" t.t | grep "514 " |wc -l
> > 799
> > 
> > Oh, now that is too close to just be a co-incidence. We're getting
> > significant amounts of random page writeback from the the ends of
> > the LRUs done by the VM.
> > 
> > <sigh>
> 
> 
> On Fri, Jul 01, 2011 at 07:20:21PM +1000, Dave Chinner wrote:
> > > Looks good.  I still wonder why I haven't been able to hit this.
> > > Haven't seen any 180 failure for a long time, with both 4k and 512 byte
> > > filesystems and since yesterday 1k as well.
> > 
> > It requires the test to run the VM out of RAM and then force enough
> > memory pressure for kswapd to start writeback from the LRU. The
> > reproducer I have is a 1p, 1GB RAM VM with it's disk image on a
> > 100MB/s HW RAID1 w/ 512MB BBWC disk subsystem.
> > 
> > When kswapd starts doing writeback from the LRU, the iops rate goes
> > through the roof (from ~300iops @~320k/io to ~7000iops @4k/io) and
> > throughput drops from 100MB/s to ~30MB/s. BBWC is the only reason
> > the IOPS stays as high as it does - maybe that is why I saw this and
> > you haven't.
> > 
> > As it is, the kswapd writeback behaviour is utterly atrocious and,
> > ultimately, quite easy to provoke. I wish the MM folk would fix that
> > goddamn problem already - we've only been complaining about it for
> > the last 6 or 7 years. As such, I'm wondering if it's a bad idea to
> > even consider removing the .writepage clustering...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
