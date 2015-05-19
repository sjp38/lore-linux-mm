Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1B1C16B0073
	for <linux-mm@kvack.org>; Mon, 18 May 2015 23:04:09 -0400 (EDT)
Received: by oign205 with SMTP id n205so1609564oig.2
        for <linux-mm@kvack.org>; Mon, 18 May 2015 20:04:08 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id fy16si1067472oeb.33.2015.05.18.20.04.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 18 May 2015 20:04:08 -0700 (PDT)
Message-ID: <555AA782.2070603@huawei.com>
Date: Tue, 19 May 2015 11:01:22 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 0/3] Find mirrored memory, use for boot time allocations
References: <cover.1431103461.git.tony.luck@intel.com>
In-Reply-To: <cover.1431103461.git.tony.luck@intel.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>

On 2015/5/9 0:44, Tony Luck wrote:

> Some high end Intel Xeon systems report uncorrectable memory errors
> as a recoverable machine check. Linux has included code for some time
> to process these and just signal the affected processes (or even
> recover completely if the error was in a read only page that can be
> replaced by reading from disk).
> 
> But we have no recovery path for errors encountered during kernel
> code execution. Except for some very specific cases were are unlikely
> to ever be able to recover.
> 
> Enter memory mirroring. Actually 3rd generation of memory mirroing.
> 
> Gen1: All memory is mirrored
> 	Pro: No s/w enabling - h/w just gets good data from other side of the mirror
> 	Con: Halves effective memory capacity available to OS/applications
> Gen2: Partial memory mirror - just mirror memory begind some memory controllers
> 	Pro: Keep more of the capacity
> 	Con: Nightmare to enable. Have to choose between allocating from
> 	     mirrored memory for safety vs. NUMA local memory for performance
> Gen3: Address range partial memory mirror - some mirror on each memory controller
> 	Pro: Can tune the amount of mirror and keep NUMA performance
> 	Con: I have to write memory management code to implement
> 
> The current plan is just to use mirrored memory for kernel allocations. This
> has been broken into two phases:
> 1) This patch series - find the mirrored memory, use it for boot time allocations
> 2) Wade into mm/page_alloc.c and define a ZONE_MIRROR to pick up the unused
>    mirrored memory from mm/memblock.c and only give it out to select kernel
>    allocations (this is still being scoped because page_alloc.c is scary).
> 

Hi Tony,

In part2, does it means the memory allocated from kernel should use mirrored memory?

I have heard of this feature(address range mirroring) before, and I changed some
code to test it(implement memory allocations in specific physical areas).

In my opinion, add a new zone(ZONE_MIRROR) to fill the mirrored memory is not a good
idea. If there are XX discontiguous mirrored areas in one numa node, there should be
XX ZONE_MIRROR zones in one pgdat, it is impossible, right?

I think add a new migrate type(MIGRATE_MIRROR) will be better, the following print
is from my changed kernel. 

[root@localhost ~]# cat /proc/pagetypeinfo
Page block order: 9
Pages per block:  512

Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10
Node    0, zone      DMA, type    Unmovable      1      1      1      0      2      1      1      0      1      0      0
Node    0, zone      DMA, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone      DMA, type      Movable      0      0      0      0      0      0      0      0      0      0      3
Node    0, zone      DMA, type       Mirror      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone      DMA, type      Reserve      0      0      0      0      0      0      0      0      0      1      0
Node    0, zone      DMA, type          CMA      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone      DMA, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone    DMA32, type    Unmovable     14      7      6      1      3      0      1      0      0      0      0
Node    0, zone    DMA32, type  Reclaimable     15      2      2      1      1      2      1      1      0      0      0
Node    0, zone    DMA32, type      Movable      3     24     52     58     31      2      1      1      1      3    231
Node    0, zone    DMA32, type       Mirror      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone    DMA32, type      Reserve      0      0      0      0      0      0      0      0      0      0      1
Node    0, zone    DMA32, type          CMA      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone    DMA32, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type    Unmovable     80     12      6      7      3      1     67     58     23     11      0
Node    0, zone   Normal, type  Reclaimable      6      6      8     11      5      3      0      1      0      0      0
Node    0, zone   Normal, type      Movable      6    198    618    675    363     13      4      3      0      2   4074
Node    0, zone   Normal, type       Mirror      0      0      0      0      0      0      0      0      0      0   1024
Node    0, zone   Normal, type      Reserve      0      0      0      0      0      0      0      0      0      0      1
Node    0, zone   Normal, type          CMA      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0

Number of blocks type     Unmovable  Reclaimable      Movable       Mirror      Reserve          CMA      Isolate
Node 0, zone      DMA            1            0            6            0            1            0            0
Node 0, zone    DMA32            8           32          975            0            1            0            0
Node 0, zone   Normal          216          334        12760         2048            2            0            0
Page block order: 9
Pages per block:  512

Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10
Node    1, zone   Normal, type    Unmovable     18      2     19      3     21     28     13      0      1      1      0
Node    1, zone   Normal, type  Reclaimable      0      1      1      1      0      0      1      0      0      1      0
Node    1, zone   Normal, type      Movable      6     13      9      3      0      4      5      0      1      0   6970
Node    1, zone   Normal, type       Mirror      0      0      0      0      0      0      0      0      0      0   1024
Node    1, zone   Normal, type      Reserve      0      0      0      0      0      0      0      0      0      0      1
Node    1, zone   Normal, type          CMA      0      0      0      0      0      0      0      0      0      0      0
Node    1, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0

Number of blocks type     Unmovable  Reclaimable      Movable       Mirror      Reserve          CMA      Isolate
Node 1, zone   Normal          112            4        14218         2048            2            0            0


Also I add a new flag(GFP_MIRROR), then we can use the mirrored form both
kernel-space and user-space. If there is no mirrored memory, we will allocate
other types memory.

1) kernel-space(pcp, page buddy, slab/slub ...):
	-> use mirrored memory(e.g. /proc/sys/vm/mirrorable)
		-> __alloc_pages_nodemask()
			->gfpflags_to_migratetype()
				-> use MIGRATE_MIRROR list
2) user-space(syscall, madvise, mmap ...):
	-> add VM_MIRROR flag in the vma
		-> add GFP_MIRROR when page fault in the vma
			-> __alloc_pages_nodemask()
				-> use MIGRATE_MIRROR list

Thanks,
Xishi Qiu

> Tony Luck (3):
>   mm/memblock: Add extra "flags" to memblock to allow selection of
>     memory based on attribute
>   mm/memblock: Allocate boot time data structures from mirrored memory
>   x86, mirror: x86 enabling - find mirrored memory ranges
> 
>  arch/s390/kernel/crash_dump.c |   5 +-
>  arch/sparc/mm/init_64.c       |   6 ++-
>  arch/x86/kernel/check.c       |   3 +-
>  arch/x86/kernel/e820.c        |   3 +-
>  arch/x86/kernel/setup.c       |   3 ++
>  arch/x86/mm/init_32.c         |   2 +-
>  arch/x86/platform/efi/efi.c   |  21 ++++++++
>  include/linux/efi.h           |   3 ++
>  include/linux/memblock.h      |  49 +++++++++++------
>  mm/cma.c                      |   6 ++-
>  mm/memblock.c                 | 123 +++++++++++++++++++++++++++++++++---------
>  mm/memtest.c                  |   3 +-
>  mm/nobootmem.c                |  14 ++++-
>  13 files changed, 188 insertions(+), 53 deletions(-)
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
