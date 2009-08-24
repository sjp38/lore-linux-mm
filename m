Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BE8176B0122
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 00:10:54 -0400 (EDT)
Received: by pzk36 with SMTP id 36so2064132pzk.12
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 21:10:57 -0700 (PDT)
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
Subject: [PATCH 0/4] compcache: compressed in-memory swapping
Date: Mon, 24 Aug 2009 10:07:33 +0530
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <200908241007.33844.ngupta@vflare.org>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

Hi,

Project home: http://compcache.googlecode.com/

It creates RAM based block devices which can be used (only) as swap disks.
Pages swapped to this device are compressed and stored in memory itself. This
is a big win over swapping to slow hard-disk which are typically used as swap
disk. For flash, these suffer from wear-leveling issues when used as swap disk
- so again its helpful. For swapless systems, it allows more apps to run for a
given amount of memory.

It can create multiple ramzswap devices (/dev/ramzswapX, X = 0, 1, 2, ...).
Each of these devices can have separate backing swap (file or disk partition)
which is used when incompressible page is found or memory limit for device is
reached.

A separate userspace utility called rzscontrol is used to manage individual
ramzswap devices.

* Testing notes

Tested on x86, x64, ARM
ARM:
 - Cortex-A8 (Beagleboard)
 - ARM11 (Android G1)
 - OMAP2420 (Nokia N810)

* Performance

All performance numbers/plots can be found at:
http://code.google.com/p/compcache/wiki/Performance

Below is a summary of this data:

General:
 - Swap R/W times are reduced from milliseconds (in case of hard disks)
down to microseconds.

Positive cases:
 - Shows 33% improvement in 'scan' benchmark which allocates given amount
of memory and linearly reads/writes to this region. This benchmark also
exposes *bottlenecks* in ramzswap code (global mutex) due to which this gain
is so small.
 - On Linux thin clients, it gives the effect of nearly doubling the amount of
memory.

Negative cases:
Any workload that has active working set w.r.t. filesystem cache that is
nearly equal to amount of RAM while has minimal anonymous memory requirement,
is expected to suffer maximum loss in performance with ramzswap enabled.

Iozone filesystem benchmark can simulate exactly this kind of workload.
As expected, this test shows performance loss of ~25% with ramzswap.


(Sorry for long patch[2/4] but its now very hard to split it up).

 Documentation/blockdev/00-INDEX       |    2 +
 Documentation/blockdev/ramzswap.txt   |   52 ++
 drivers/block/Kconfig                 |   22 +
 drivers/block/Makefile                |    1 +
 drivers/block/ramzswap/Makefile       |    2 +
 drivers/block/ramzswap/ramzswap.c     | 1511 +++++++++++++++++++++++++++++++++
 drivers/block/ramzswap/ramzswap.h     |  182 ++++
 drivers/block/ramzswap/xvmalloc.c     |  556 ++++++++++++
 drivers/block/ramzswap/xvmalloc.h     |   30 +
 drivers/block/ramzswap/xvmalloc_int.h |   86 ++
 include/linux/ramzswap_ioctl.h        |   51 ++
 include/linux/swap.h                  |    5 +
 mm/swapfile.c                         |   33 +
 13 files changed, 2533 insertions(+), 0 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
