Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id WAA15583
	for <linux-mm@kvack.org>; Sat, 14 Sep 2002 22:21:24 -0700 (PDT)
Message-ID: <3D841C8A.682E6A5C@digeo.com>
Date: Sat, 14 Sep 2002 22:37:14 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.34-mm2
References: <3D803434.F2A58357@digeo.com> <E17qQMq-0001JV-00@starship> <3D8408A9.7B34483D@digeo.com> <E17qQwq-0001qT-00@starship>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Daniel Phillips wrote:
> 
> On Sunday 15 September 2002 06:12, Andrew Morton wrote:
> > Daniel Phillips wrote:
> > >  I heard you
> > > mention, on the one hand, huge speedups on some load (dbench I think)
> > > but your in-patch comments mention slowdown by 1.7X on kernel
> > > compile.
> >
> > You misread.  Relative times for running `make -j6 bzImage' with mem=512m:
> >
> > Unloaded system:                                   1.0
> > 2.5.34-mm4, while running 4 x `dbench 100'           1.7
> > Any other kernel while running 4 x `dbench 100'      basically infinity
> 
> Oh good :-)
> 
> We can make the rescanning go away in time, with more lru lists,

We don't actually need more lists, I expect.  Dirty and under writeback
pages just don't go on a list at all - cut them off the LRU and
bring them back at IO completion.  We can't do anything useful with
a list of dirty/writeback pages anyway, so why have the list?

It kind of depends whether we want to put swapcache on that list.  I
may just give swapper_inode a superblock and let pdflush write swap.

The interrupt-time page motion is of course essential if we are to
avoid long scans of that list.

That, and replacing the blk_congestion_wait() throttling with a per-classzone
wait_for_some_pages_to_come_clean() throttling pretty much eliminates the
remaining pointless scan activity from the VM, and fixes a current false OOM
scenario in -mm4.

> but that sure looks like the low hanging fruit.

It's low alright.  AFAIK Linux has always had this problem of
seizing up when there's a lot of dirty data around.

Let me quantify infinity:


With mem=512m, on the quad:

`make -j6 bzImage' takes two minutes and two seconds.

On 2.5.34, a concurrent 4 x `dbench 100' slows that same kernel
build down to 35 minutes and 16 seconds.

On 2.5.34-mm4, while running 4 x `dbench 100' that kernel build
takes three minutes and 45 seconds.



That's with seven disks: four for the dbenches, one for the kernel
build, one for swap and one for the executables.  Things would be
worse with less disks because of seek contention.  But that's
to be expected.  The intent of this work is to eliminate this
crosstalk between different activities.  And to avoid blocking things
which aren't touching disk at all.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
