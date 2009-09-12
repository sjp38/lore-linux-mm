Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3E3F46B004D
	for <linux-mm@kvack.org>; Fri, 11 Sep 2009 22:25:17 -0400 (EDT)
Received: by ywh28 with SMTP id 28so2434041ywh.15
        for <linux-mm@kvack.org>; Fri, 11 Sep 2009 19:25:23 -0700 (PDT)
Message-ID: <4AAB065D.3070602@vflare.org>
Date: Sat, 12 Sep 2009 07:54:29 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] compcache: in-memory compressed swapping v2
References: <200909100215.36350.ngupta@vflare.org> <200909100332.55910.ngupta@vflare.org>
In-Reply-To: <200909100332.55910.ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ed Tomlinson <edt@aei.ca>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc <linux-mm-cc@laptop.org>
List-ID: <linux-mm.kvack.org>

Hi,


On 09/10/2009 03:32 AM, Nitin Gupta wrote:
> Project home: http://compcache.googlecode.com/
>
> * Changelog: v2 vs initial revision
>   - Use 'struct page' instead of 32-bit PFNs in ramzswap driver and xvmalloc.
>     This is to make these 64-bit safe.
>   - xvmalloc is no longer a separate module and does not export any symbols.
>     Its compiled directly with ramzswap block driver. This is to avoid any
>     last bit of confusion with any other allocator.
>   - set_swap_free_notify() now accepts block_device as parameter instead of
>     swp_entry_t (interface cleanup).
>   - Fix: Make sure ramzswap disksize matches usable pages in backing swap file.
>     This caused initialization error in case backing swap file had intra-page
>     fragmentation.
>
>    


Can anyone please review these patches for possible inclusion in 2.6.32?
Sorry for the weird email threading.

Thanks,
Nitin


> It creates RAM based block devices which can be used (only) as swap disks.
> Pages swapped to these disks are compressed and stored in memory itself. This
> is a big win over swapping to slow hard-disk which are typically used as swap
> disk. For flash, these suffer from wear-leveling issues when used as swap disk
> - so again its helpful. For swapless systems, it allows more apps to run for a
> given amount of memory.
>
> It can create multiple ramzswap devices (/dev/ramzswapX, X = 0, 1, 2, ...).
> Each of these devices can have separate backing swap (file or disk partition)
> which is used when incompressible page is found or memory limit for device is
> reached.
>
> A separate userspace utility called rzscontrol is used to manage individual
> ramzswap devices.
>
> * Testing notes
>
> Tested on x86, x64, ARM
> ARM:
>   - Cortex-A8 (Beagleboard)
>   - ARM11 (Android G1)
>   - OMAP2420 (Nokia N810)
>
> * Performance
>
> All performance numbers/plots can be found at:
> http://code.google.com/p/compcache/wiki/Performance
>
> Below is a summary of this data:
>
> General:
>   - Swap R/W times are reduced from milliseconds (in case of hard disks)
> down to microseconds.
>
> Positive cases:
>   - Shows 33% improvement in 'scan' benchmark which allocates given amount
> of memory and linearly reads/writes to this region. This benchmark also
> exposes bottlenecks in ramzswap code (global mutex) due to which this gain
> is so small.
>   - On Linux thin clients, it gives the effect of nearly doubling the amount of
> memory.
>
> Negative cases:
> Any workload that has active working set w.r.t. filesystem cache that is
> nearly equal to amount of RAM while has minimal anonymous memory requirement,
> is expected to suffer maximum loss in performance with ramzswap enabled.
>
> Iozone filesystem benchmark can simulate exactly this kind of workload.
> As expected, this test shows performance loss of ~25% with ramzswap.
>
> (Sorry for long patch[2/4] but its now very hard to split it up).
>
>   Documentation/blockdev/00-INDEX       |    2 +
>   Documentation/blockdev/ramzswap.txt   |   50 ++
>   drivers/block/Kconfig                 |   22 +
>   drivers/block/Makefile                |    1 +
>   drivers/block/ramzswap/Makefile       |    3 +
>   drivers/block/ramzswap/ramzswap_drv.c | 1529 +++++++++++++++++++++++++++++++++
>   drivers/block/ramzswap/ramzswap_drv.h |  183 ++++
>   drivers/block/ramzswap/xvmalloc.c     |  533 ++++++++++++
>   drivers/block/ramzswap/xvmalloc.h     |   30 +
>   drivers/block/ramzswap/xvmalloc_int.h |   86 ++
>   include/linux/ramzswap_ioctl.h        |   51 ++
>   include/linux/swap.h                  |    5 +
>   mm/swapfile.c                         |   34 +
>   13 files changed, 2529 insertions(+), 0 deletions(-)
> _______________________________________________
>    

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
