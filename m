Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 90F296B005C
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 06:37:34 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/2] Reduce number of GFP_ATOMIC allocation failures
Date: Fri, 16 Oct 2009 11:37:24 +0100
Message-Id: <1255689446-3858-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, stable <stable@kernel.org>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Frans Pop <elendil@planet.nl>, reinette chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org\"" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

The following two patches against 2.6.32-rc4 should reduce allocation
failure reports for GFP_ATOMIC allocations that have being cropping up
since 2.6.31-rc1.

I believe these are candidates for -stable as they address issues in the
following commit introduced in the v2.6.30..v2.6.31-rc1 window

11e33f6 page allocator: break up the allocator entry point into fast and slow paths

The patch should not have made functional changes but at least two slipped
by. The first patch wakes kswapd up each time after OOM-killing has been
considered. This can be important to high-order allocations where kswapd
needs to reclaim at a higher order. The second patch corrects a problem
whereby a process that is exiting and making a __GFP_NOFAIL allocation can
ignore watermarks.

These patches in combination should help reduce the number of GFP_ATOMIC
failures in the following bug.

[Bug #14141] order 2 page allocation failures in iwlagn

However, this bug should not yet be closed as there are still problems in
the driver itself that increase the number of GFP_ATOMIC allocations that bug.

The patches should also help the following bugs as well and testing there
would be appreciated.

[Bug #14265] ifconfig: page allocation failure. order:5, mode:0x8020 w/ e100

It might also have helped the following bug although that driver has already
been fixed by not making high-order atomic allocations.

[Bug #14016] mm/ipw2200 regression

 mm/page_alloc.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
