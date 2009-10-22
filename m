Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 085B26B004D
	for <linux-mm@kvack.org>; Thu, 22 Oct 2009 10:22:43 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC failures V2
Date: Thu, 22 Oct 2009 15:22:31 +0100
Message-Id: <1256221356-26049-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org\"" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Sorry for the large cc list. Variations of this bug have cropped up in a
number of different places and so there are a fair few people that should
be vaguely aware of what's going on.

Since 2.6.31-rc1, there have been an increasing number of GFP_ATOMIC
failures. A significant number of these have been high-order GFP_ATOMIC
failures and while they are generally brushed away, there has been a large
increase in them recently and there are a number of possible areas the
problem could be in - core vm, page writeback and a specific driver. The
bugs affected by this that I am aware of are;

[Bug #14141] order 2 page allocation failures in iwlagn
	Commit 4752c93c30441f98f7ed723001b1a5e3e5619829 introduced GFP_ATOMIC
	allocations within the wireless driver. This has caused large numbers
	of failure reports to occur as reported by Frans Pop. Fixing this
	requires changes to the driver if it wants to use GFP_ATOMIC which
	is in the hands of Mohamed Abbas and Reinette Chatre. However,
	it is very likely that it has being compounded by core mm changes
	that this series is aimed at.

[Bug #14141] order 2 page allocation failures (generic)
	This problem is being tracked under bug #14141 but chances are it's
	unrelated to the wireless change. Tobi Oetiker has reported that a
	virtualised machine using a bridged interface is reporting a small
	number of order-5 GFP_ATOMIC failures. He has reported that the
	errors can be suppressed with kswapd patches in this series. However,
	I would like to confirm they are necessary.

[Bug #14265] ifconfig: page allocation failure. order:5, mode:0x8020 w/ e100
	Karol Lewandows reported that e100 fails to allocate order-5
	GFP_ATOMIC when loading firmware during resume. This has started
	happening relatively recent.

[No BZ ID] Kernel crash on 2.6.31.x (kcryptd: page allocation failure..)
	This apparently is easily reproducible, particular in comparison to
	the other reports. The point of greatest interest is that this is
	order-0 GFP_ATOMIC failures. Sven, I'm hoping that you in particular
	will be able to follow the tests below as you are the most likely
	person to have an easily reproducible situation.

[No BZ ID] page allocation failure message kernel 2.6.31.4 (tty-related)
	reported at: http://lkml.org/lkml/2009/10/20/139. Looks the same
	as the order-2 failures.

There are 5 patches in this series. For people affected by this bug,
I'm afraid there is a lot of legwork involved to help pin down which of
these patches are relevant. These patches are all against 2.6.32-rc5 and
have been tested on X86 and X86-64 by running the sysbench benchmark to
completion. I'll post against 2.6.31.4 where necessary.

Test 1: Verify your problem occurs on 2.6.32-rc5 if you can

Test 2: Apply the following two patches and test again

  1/5 page allocator: Always wake kswapd when restarting an allocation attempt after direct reclaim failed
  2/5 page allocator: Do not allow interrupts to use ALLOC_HARDER


	These patches correct problems introduced by me during the 2.6.31-rc1
	merge window. The patches were not meant to introduce any functional
	changes but two were missed.

	If your problem goes away with just these two patches applied,
	please tell me.

Test 3: If you are getting allocation failures, try with the following patch

  3/5 vmscan: Force kswapd to take notice faster when high-order watermarks are being hit

	This is a functional change that causes kswapd to notice sooner
	when high-order watermarks have been hit. There have been a number
	of changes in page reclaim since 2.6.30 that might have delayed
	when kswapd kicks in for higher orders

	If your problem goes away with these three patches applied, please
	tell me

Test 4: If you are still getting failures, apply the following
  4/5 page allocator: Pre-emptively wake kswapd when high-order watermarks are hit

	This patch is very heavy handed and pre-emptively kicks kswapd when
	watermarks are hit. It should only be necessary if there has been
	significant changes in the timing and density of page allocations
	from an unknown source. Tobias, this patch is largely aimed at you.
	You reported that with patches 3+4 applied that your problems went
	away. I need to know if patch 3 on its own is enough or if both
	are required

	If your problem goes away with these four patches applied, please
	tell me

Test 5: If things are still screwed, apply the following
  5/5 Revert 373c0a7e, 8aa7e847: Fix congestion_wait() sync/async vs read/write confusion

	Frans Pop reports that the bulk of his problems go away when this
	patch is reverted on 2.6.31. There has been some confusion on why
	exactly this patch was wrong but apparently the conversion was not
	complete and further work was required. It's unknown if all the
	necessary work exists in 2.6.31-rc5 or not. If there are still
	allocation failures and applying this patch fixes the problem,
	there are still snags that need to be ironed out.

Test 6: If only testing 2.6.31.4, test with patches 1, 2 and 5 as posted for that kernel
	Even if patches 3, 4 or both are necessary against mainline, I'm
	hoping they are unnecessary against -stable.

Thanks to all that reported problems and are testing this. The major bulk of
the work was done by Frans Pop so a big thanks to him in particular. I/we owe
him beers.

 arch/x86/lib/usercopy_32.c  |    2 +-
 drivers/block/pktcdvd.c     |   10 ++++------
 drivers/md/dm-crypt.c       |    2 +-
 fs/fat/file.c               |    2 +-
 fs/fuse/dev.c               |    8 ++++----
 fs/nfs/write.c              |    8 +++-----
 fs/reiserfs/journal.c       |    2 +-
 fs/xfs/linux-2.6/kmem.c     |    4 ++--
 fs/xfs/linux-2.6/xfs_buf.c  |    2 +-
 include/linux/backing-dev.h |   11 +++--------
 include/linux/blkdev.h      |   13 +++++++++----
 mm/backing-dev.c            |    7 ++++---
 mm/memcontrol.c             |    2 +-
 mm/page-writeback.c         |    2 +-
 mm/page_alloc.c             |   41 ++++++++++++++++++++++++++---------------
 mm/vmscan.c                 |   17 +++++++++++++----
 16 files changed, 75 insertions(+), 58 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
