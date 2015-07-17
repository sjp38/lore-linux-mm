Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id A764C280314
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 21:22:51 -0400 (EDT)
Received: by padck2 with SMTP id ck2so51433478pad.0
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 18:22:51 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id g6si15715874pdn.197.2015.07.16.18.22.49
        for <linux-mm@kvack.org>;
        Thu, 16 Jul 2015 18:22:50 -0700 (PDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 0/2] mem-hotplug: Handle node hole when initializing numa_meminfo.
Date: Fri, 17 Jul 2015 09:23:29 +0800
Message-ID: <1437096211-28605-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, dyoung@redhat.com, isimatu.yasuaki@jp.fujitsu.com, yasu.isimatu@gmail.com, lcapitulino@redhat.com, qiuxishi@huawei.com, will.deacon@arm.com, tony.luck@intel.com, vladimir.murzin@arm.com, fabf@skynet.be, kuleshovmail@gmail.com, bhe@redhat.com
Cc: x86@kernel.org, tangchen@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

When parsing SRAT, all memory ranges are added into numa_meminfo.
In numa_init(), before entering numa_cleanup_meminfo(), all possible
memory ranges are in numa_meminfo. And numa_cleanup_meminfo() removes
all ranges over max_pfn or empty.

But, this only works if the nodes are continuous. Let's have a look
at the following example:

We have an SRAT like this:
SRAT: Node 0 PXM 0 [mem 0x00000000-0x5fffffff]
SRAT: Node 0 PXM 0 [mem 0x100000000-0x1ffffffffff]
SRAT: Node 1 PXM 1 [mem 0x20000000000-0x3ffffffffff]
SRAT: Node 4 PXM 2 [mem 0x40000000000-0x5ffffffffff] hotplug
SRAT: Node 5 PXM 3 [mem 0x60000000000-0x7ffffffffff] hotplug
SRAT: Node 2 PXM 4 [mem 0x80000000000-0x9ffffffffff] hotplug
SRAT: Node 3 PXM 5 [mem 0xa0000000000-0xbffffffffff] hotplug
SRAT: Node 6 PXM 6 [mem 0xc0000000000-0xdffffffffff] hotplug
SRAT: Node 7 PXM 7 [mem 0xe0000000000-0xfffffffffff] hotplug

On boot, only node 0,1,2,3 exist.

And the numa_meminfo will look like this:
numa_meminfo.nr_blks = 9
1. on node 0: [0, 60000000]
2. on node 0: [100000000, 20000000000]
3. on node 1: [20000000000, 40000000000]
4. on node 4: [40000000000, 60000000000]
5. on node 5: [60000000000, 80000000000]
6. on node 2: [80000000000, a0000000000]
7. on node 3: [a0000000000, a0800000000]
8. on node 6: [c0000000000, a0800000000]
9. on node 7: [e0000000000, a0800000000]

And numa_cleanup_meminfo() will merge 1 and 2, and remove 8,9 because
the end address is over max_pfn, which is a0800000000. But 4 and 5
are not removed because their end addresses are less then max_pfn.
But in fact, node 4 and 5 don't exist.

In a word, numa_cleanup_meminfo() is not able to handle holes between nodes.

Since memory ranges in node 4 and 5 are in numa_meminfo, in numa_register_memblks(),
node 4 and 5 will be mistakenly set to online.

If you run lscpu, it will show:
NUMA node0 CPU(s):     0-14,128-142
NUMA node1 CPU(s):     15-29,143-157
NUMA node2 CPU(s):
NUMA node3 CPU(s):
NUMA node4 CPU(s):     62-76,190-204
NUMA node5 CPU(s):     78-92,206-220

In this patch, we use memblock_overlaps_region() to check if ranges in
numa_meminfo overlap with ranges in memory_block. Since memory_block contains
all available memory at boot time, if they overlap, it means the ranges
exist. If not, then remove them from numa_meminfo.

After this patch, lscpu will show:
NUMA node0 CPU(s):     0-14,128-142
NUMA node1 CPU(s):     15-29,143-157
NUMA node2 CPU(s):     31-45,159-173
NUMA node3 CPU(s):     46-60,174-188
NUMA node4 CPU(s):     62-76,190-204
NUMA node5 CPU(s):     78-92,206-220



Tang Chen (2):
  memblock: Make memblock_overlaps_region() return bool.
  mem-hotplug: Handle node hole when initializing numa_meminfo.

 arch/x86/mm/numa.c       |  6 ++++--
 include/linux/memblock.h |  4 +++-
 mm/memblock.c            | 10 +++++-----
 3 files changed, 12 insertions(+), 8 deletions(-)

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
