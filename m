Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C102F6B005C
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 18:04:10 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id 16so1260759fgg.8
        for <linux-mm@kvack.org>; Wed, 09 Sep 2009 15:04:10 -0700 (PDT)
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
Subject: [PATCH 0/4] compcache: in-memory compressed swapping v2
Date: Thu, 10 Sep 2009 03:32:55 +0530
References: <200909100215.36350.ngupta@vflare.org>
In-Reply-To: <200909100215.36350.ngupta@vflare.org>
MIME-Version: 1.0
Message-Id: <200909100332.55910.ngupta@vflare.org>
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Pekka Enberg <penberg@cs.helsinki.fi>, Ed Tomlinson <edt@aei.ca>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

Hi,

Project home: http://compcache.googlecode.com/

* Changelog: v2 vs initial revision
 - Use 'struct page' instead of 32-bit PFNs in ramzswap driver and xvmalloc.
   This is to make these 64-bit safe.
 - xvmalloc is no longer a separate module and does not export any symbols.
   Its compiled directly with ramzswap block driver. This is to avoid any
   last bit of confusion with any other allocator.
 - set_swap_free_notify() now accepts block_device as parameter instead of
   swp_entry_t (interface cleanup).
 - Fix: Make sure ramzswap disksize matches usable pages in backing swap file.
   This caused initialization error in case backing swap file had intra-page
   fragmentation.

It creates RAM based block devices which can be used (only) as swap disks.
Pages swapped to these disks are compressed and stored in memory itself. This
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
exposes bottlenecks in ramzswap code (global mutex) due to which this gain
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
 Documentation/blockdev/ramzswap.txt   |   50 ++
 drivers/block/Kconfig                 |   22 +
 drivers/block/Makefile                |    1 +
 drivers/block/ramzswap/Makefile       |    3 +
 drivers/block/ramzswap/ramzswap_drv.c | 1529 +++++++++++++++++++++++++++++++++
 drivers/block/ramzswap/ramzswap_drv.h |  183 ++++
 drivers/block/ramzswap/xvmalloc.c     |  533 ++++++++++++
 drivers/block/ramzswap/xvmalloc.h     |   30 +
 drivers/block/ramzswap/xvmalloc_int.h |   86 ++
 include/linux/ramzswap_ioctl.h        |   51 ++
 include/linux/swap.h                  |    5 +
 mm/swapfile.c                         |   34 +
 13 files changed, 2529 insertions(+), 0 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
