Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BA31C6B0098
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 23:16:40 -0500 (EST)
From: KyongHo Cho <pullip.cho@samsung.com>
Subject: [RFCv2,0/8] mm: vcm: The Virtual Memory Manager for multiple IOMMUs
Date: Fri, 17 Dec 2010 12:56:19 +0900
Message-Id: <1292558187-17348-1-git-send-email-pullip.cho@samsung.com>
Sender: owner-linux-mm@kvack.org
To: KyongHo Cho <pullip.cho@samsung.com>
Cc: Kyungmin Park <kyungmin.park@samsung.com>, Kukjin Kim <kgene.kim@samsung.com>, Inho Lee <ilho215.lee@samsung.com>, Inki Dae <inki.dae@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linux-samsung-soc@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello,

The VCM is a framework to deal with multiple IOMMUs in a system 
with intuitive and abstract objects
These patches are the bugfix and enhanced version of previous RFC by Michal Nazarewicz.
(https://patchwork.kernel.org/patch/157451/)

It is introduced by Zach Pfeffer and implemented by Michal Nazarewicz.
These patches include entirely new implementation of VCM than the one submitted by Zach Pfeffer.

The prerequisites of these patches are the followings by Michal Nazarewicz:
https://patchwork.kernel.org/patch/340281/
https://patchwork.kernel.org/patch/414381/
https://patchwork.kernel.org/patch/414541/

In addition to the above patches, 
the prerequisites of "[RFCv2,7/8] mm: vcm: vcm-cma: VCM CMA driver added" is
CMA RFCv8 introduced by Michal Nazarewicz:
https://patchwork.kernel.org/patch/414351/

The VCM also works correctly without "[RFC,6/7] mm: vcm: vcm-cma: VCM CMA driver added"

The last patch, "[RFC,7/7] mm: vcm: Sample driver added" is not the one to be submitted
but is an example to show how to use the VCM.

The VCM provides generic interfaces and objects to deal with IOMMUs in various architectures
especially the ones that embed multiple IOMMUs including GART.

Chagelog:
v2:  1. Added reference counting on a reservation.
	When vcm_reserve() creates a reservation, it sets the reference counter
	of the reservation to 1. The ownership of the reservation is only owned by
	the caller of vcm_reserve. If the caller passes the reservation to another
	callee functions, the callee functions must increment the reference counter
	with vcm_ref_reserve() to set the ownership of the reservation.
	To release the ownership, just call vcm_unreserve(). vcm_unreserve decrements
	the reference counter of the given reservation. vcm_unreserve() eventually
	unreserves the reservation when its reference counter becomes 0.
     2. Applied the design changes of CMA by Michal Nazarewicz.
	Since it is dramatically changed, vcm-cma also followed.

Patch list:
[RFCv2,1/8] mm: vcm: Virtual Contiguous Memory framework added
[RFCv2,2/8] mm: vcm: reference counting on a reservation added
[RFCv2,3/8] mm: vcm: physical memory allocator added
[RFCv2,4/8] mm: vcm: VCM VMM driver added
[RFCv2,5/8] mm: vcm: VCM MMU wrapper added
[RFCv2,6/8] mm: vcm: VCM One-to-One wrapper added
[RFCv2,7/8] mm: vcm: vcm-cma: VCM CMA driver added
[RFCv2,8/8] mm: vcm: Sample driver added

Summery:
Documentation/00-INDEX                      |    2 +
Documentation/virtual-contiguous-memory.txt |  940 +++++++++++++++++++++++++
include/linux/vcm-cma.h                     |   38 +
include/linux/vcm-drv.h                     |  326 +++++++++
include/linux/vcm-sample.h                  |   30 +
include/linux/vcm.h                         |  311 +++++++++
mm/Kconfig                                  |   79 +++
mm/Makefile                                 |    3 +
mm/vcm-cma.c                                |   99 +++
mm/vcm-sample.c                             |  119 ++++
mm/vcm.c                                    |  987 +++++++++++++++++++++++++++
11 files changed, 2934 insertions(+), 0 deletions(-)
create mode 100644 Documentation/virtual-contiguous-memory.txt
create mode 100644 include/linux/vcm-cma.h
create mode 100644 include/linux/vcm-drv.h
create mode 100644 include/linux/vcm-sample.h
create mode 100644 include/linux/vcm.h
create mode 100644 mm/vcm-cma.c
create mode 100644 mm/vcm-sample.c
create mode 100644 mm/vcm.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
