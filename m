Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 05EC66B004F
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 08:49:08 -0400 (EDT)
Date: Thu, 3 Sep 2009 13:49:14 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: ipw2200: firmware DMA loading rework
Message-ID: <20090903124913.GA26110@csn.ul.ie>
References: <riPp5fx5ECC.A.2IG.qsGlKB@chimera> <1251430951.3704.181.camel@debian> <200908301437.42133.bzolnier@gmail.com> <200909021948.13262.bzolnier@gmail.com> <43e72e890909021102g7f844c79xefccf305f5f5c5b6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <43e72e890909021102g7f844c79xefccf305f5f5c5b6@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Cc: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Tso Ted <tytso@mit.edu>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Zhu Yi <yi.zhu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Pekka Enberg <penberg@cs.helsinki.fi>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Mel Gorman <mel@skynet.ie>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, James Ketrenos <jketreno@linux.intel.com>, "Chatre, Reinette" <reinette.chatre@intel.com>, "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>, "ipw2100-devel@lists.sourceforge.net" <ipw2100-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 02, 2009 at 11:02:14AM -0700, Luis R. Rodriguez wrote:
> On Wed, Sep 2, 2009 at 10:48 AM, Bartlomiej
> Zolnierkiewicz<bzolnier@gmail.com> wrote:
> > On Sunday 30 August 2009 14:37:42 Bartlomiej Zolnierkiewicz wrote:
> >> On Friday 28 August 2009 05:42:31 Zhu Yi wrote:
> >> > Bartlomiej Zolnierkiewicz reported an atomic order-6 allocation failure
> >> > for ipw2200 firmware loading in kernel 2.6.30. High order allocation is
> >>
> >> s/2.6.30/2.6.31-rc6/
> >>
> >> The issue has always been there but it was some recent change that
> >> explicitly triggered the allocation failures (after 2.6.31-rc1).
> >
> > ipw2200 fix works fine but yesterday I got the following error while mounting
> > ext4 filesystem (mb_history is optional so the mount succeeded):
> 
> OK so the mount succeeded.
> 
> > EXT4-fs (dm-2): barriers enabled
> > kjournald2 starting: pid 3137, dev dm-2:8, commit interval 5 seconds
> > EXT4-fs (dm-2): internal journal on dm-2:8
> > EXT4-fs (dm-2): delayed allocation enabled
> > EXT4-fs: file extents enabled
> > mount: page allocation failure. order:5, mode:0xc0d0
> > Pid: 3136, comm: mount Not tainted 2.6.31-rc8-00015-gadda766-dirty #78
> > Call Trace:
> >  [<c0394de3>] ? printk+0xf/0x14
> >  [<c016a693>] __alloc_pages_nodemask+0x400/0x442
> >  [<c016a71b>] __get_free_pages+0xf/0x32
> >  [<c01865cf>] __kmalloc+0x28/0xfa
> >  [<c023d96f>] ? __spin_lock_init+0x28/0x4d
> >  [<c01f529d>] ext4_mb_init+0x392/0x460
> >  [<c01e99d2>] ext4_fill_super+0x1b96/0x2012
> >  [<c0239bc8>] ? snprintf+0x15/0x17
> >  [<c01c0b26>] ? disk_name+0x24/0x69
> >  [<c018ba63>] get_sb_bdev+0xda/0x117
> >  [<c01e6711>] ext4_get_sb+0x13/0x15
> >  [<c01e7e3c>] ? ext4_fill_super+0x0/0x2012
> >  [<c018ad2d>] vfs_kern_mount+0x3b/0x76
> >  [<c018adad>] do_kern_mount+0x33/0xbd
> >  [<c019d0af>] do_mount+0x660/0x6b8
> >  [<c016a71b>] ? __get_free_pages+0xf/0x32
> >  [<c019d168>] sys_mount+0x61/0x99
> >  [<c0102908>] sysenter_do_call+0x12/0x36
> > Mem-Info:
> > DMA per-cpu:
> > CPU    0: hi:    0, btch:   1 usd:   0
> > Normal per-cpu:
> > CPU    0: hi:  186, btch:  31 usd:   0
> > Active_anon:25471 active_file:22802 inactive_anon:25812
> >  inactive_file:33619 unevictable:2 dirty:2452 writeback:135 unstable:0
> >  free:4346 slab:4308 mapped:26038 pagetables:912 bounce:0
> > DMA free:2060kB min:84kB low:104kB high:124kB active_anon:1660kB inactive_anon:1848kB active_file:144kB inactive_file:868kB unevictable:0kB present:15788kB pages_scanned:0 all_unreclaimable? no
> > lowmem_reserve[]: 0 489 489
> > Normal free:15324kB min:2788kB low:3484kB high:4180kB active_anon:100224kB inactive_anon:101400kB active_file:91064kB inactive_file:133608kB unevictable:8kB present:501392kB pages_scanned:0 all_unreclaimable? no
> > lowmem_reserve[]: 0 0 0
> > DMA: 1*4kB 1*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 2060kB
> > Normal: 1283*4kB 648*8kB 159*16kB 53*32kB 10*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 15324kB
> > 57947 total pagecache pages
> > 878 pages in swap cache
> > Swap cache stats: add 920, delete 42, find 11/11
> > Free swap  = 1016436kB
> > Total swap = 1020116kB
> > 131056 pages RAM
> > 4233 pages reserved
> > 90573 pages shared
> > 77286 pages non-shared
> > EXT4-fs: mballoc enabled
> > EXT4-fs (dm-2): mounted filesystem with ordered data mode
> >
> > Thus it seems like the original bug is still there and any ideas how to
> > debug the problem further are appreciated..
> >
> > The complete dmesg and kernel config are here:
> >
> > http://www.kernel.org/pub/linux/kernel/people/bart/ext4-paf.dmesg
> > http://www.kernel.org/pub/linux/kernel/people/bart/ext4-paf.config
> 
> This looks very similar to the kmemleak ext4 reports upon a mount. If
> it is the same issue, which from the trace it seems it is, then this
> is due to an extra kmalloc() allocation and this apparently will not
> get fixed on 2.6.31 due to the closeness of the merge window and the
> non-criticalness this issue has been deemed.
> 

I suspect the more pressing concern is why is this kmalloc() resulting in
an order-5 allocation request? What size is the buffer being requested?
Was that expected?  What is the contents of /proc/slabinfo in case a buffer
that should have required order-1 or order-2 is using a higher order for
some reason.

> A patch fix is part of the ext4-patchqueue
> http://repo.or.cz/w/ext4-patch-queue.git
> 

p.s. I'm will be offline until Tuesday so will not be initially very
responsive.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
