Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f50.google.com (mail-oa0-f50.google.com [209.85.219.50])
	by kanga.kvack.org (Postfix) with ESMTP id EB2746B003A
	for <linux-mm@kvack.org>; Sun, 20 Jul 2014 23:57:36 -0400 (EDT)
Received: by mail-oa0-f50.google.com with SMTP id g18so6556170oah.37
        for <linux-mm@kvack.org>; Sun, 20 Jul 2014 20:57:36 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id b1si32016914oeq.25.2014.07.20.20.57.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 20 Jul 2014 20:57:36 -0700 (PDT)
From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH v2 0/7] memory-hotplug: suitable memory should go to ZONE_MOVABLE
Date: Mon, 21 Jul 2014 11:46:35 +0800
Message-ID: <1405914402-66212-1-git-send-email-wangnan0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Yinghai Lu <yinghai@kernel.org>, Mel
 Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave
 Hansen <dave.hansen@intel.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: peifeiyue@huawei.com, linux-mm@kvack.org, x86@kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org, wangnan0@huawei.com

This series of patches fix a problem when adding memory in bad manner.
For example: for a x86_64 machine booted with "mem=400M" and with 2GiB
memory installed, following commands cause problem:

  # echo 0x40000000 > /sys/devices/system/memory/probe
 [   28.613895] init_memory_mapping: [mem 0x40000000-0x47ffffff]
  # echo 0x48000000 > /sys/devices/system/memory/probe
 [   28.693675] init_memory_mapping: [mem 0x48000000-0x4fffffff]
  # echo online_movable > /sys/devices/system/memory/memory9/state
  # echo 0x50000000 > /sys/devices/system/memory/probe 
 [   29.084090] init_memory_mapping: [mem 0x50000000-0x57ffffff]
  # echo 0x58000000 > /sys/devices/system/memory/probe 
 [   29.151880] init_memory_mapping: [mem 0x58000000-0x5fffffff]
  # echo online_movable > /sys/devices/system/memory/memory11/state
  # echo online> /sys/devices/system/memory/memory8/state
  # echo online> /sys/devices/system/memory/memory10/state
  # echo offline> /sys/devices/system/memory/memory9/state
 [   30.558819] Offlined Pages 32768
  # free
              total       used       free     shared    buffers     cached
 Mem:        780588 18014398509432020     830552          0          0      51180
 -/+ buffers/cache: 18014398509380840     881732
 Swap:            0          0          0

This is because the above commands probe higher memory after online a
section with online_movable, which causes ZONE_HIGHMEM (or ZONE_NORMAL
for systems without ZONE_HIGHMEM) overlaps ZONE_MOVABLE.

After the second online_movable, the problem can be observed from
zoneinfo:

 # cat /proc/zoneinfo
...
Node 0, zone  Movable
  pages free     65491
        min      250
        low      312
        high     375
        scanned  0
        spanned  18446744073709518848
        present  65536
        managed  65536
...

This series of patches solve the problem by checking ZONE_MOVABLE when
choosing zone for new memory. If new memory is inside or higher than
ZONE_MOVABLE, makes it go there instead.

After applying this series of patches, following are free and zoneinfo
result (after offlining memory9):

bash-4.2# free
              total       used       free     shared    buffers     cached
 Mem:        780956      80112     700844          0          0      51180
 -/+ buffers/cache:      28932     752024
 Swap:            0          0          0

bash-4.2# cat /proc/zoneinfo

Node 0, zone      DMA
  pages free     3389
        min      14
        low      17
        high     21
        scanned  0
        spanned  4095
        present  3998
        managed  3977
    nr_free_pages 3389
...
  start_pfn:         1
  inactive_ratio:    1
Node 0, zone    DMA32
  pages free     73724
        min      341
        low      426
        high     511
        scanned  0
        spanned  98304
        present  98304
        managed  92958
    nr_free_pages 73724
...
  start_pfn:         4096
  inactive_ratio:    1
Node 0, zone   Normal
  pages free     32630
        min      120
        low      150
        high     180
        scanned  0
        spanned  32768
        present  32768
        managed  32768
    nr_free_pages 32630
...
  start_pfn:         262144
  inactive_ratio:    1
Node 0, zone  Movable
  pages free     65476
        min      241
        low      301
        high     361
        scanned  0
        spanned  98304
        present  65536
        managed  65536
    nr_free_pages 65476
...
  start_pfn:         294912
  inactive_ratio:    1

v1 -> v2:
 - introduce zone_for_memory() to arch independent code to make arch
   dependent code simpler, following Dave Hansen's comments.
 - Paste free and zoneinfo result in patch 0 as a response to
   Zhang Yanfei.
 - Fix a problem in tile to add memory into ZONE_HIGHMEM by default.

Wang Nan (7):
  memory-hotplug: add zone_for_memory() for selecting zone for new
    memory
  memory-hotplug: x86_64: suitable memory should go to ZONE_MOVABLE
  memory-hotplug: x86_32: suitable memory should go to ZONE_MOVABLE
  memory-hotplug: ia64: suitable memory should go to ZONE_MOVABLE
  memory-hotplug: ppc: suitable memory should go to ZONE_MOVABLE
  memory-hotplug: sh: suitable memory should go to ZONE_MOVABLE
  memory-hotplug: tile: suitable memory should go to ZONE_MOVABLE

 arch/ia64/mm/init.c            |  3 ++-
 arch/powerpc/mm/mem.c          |  3 ++-
 arch/sh/mm/init.c              |  5 +++--
 arch/tile/mm/init.c            |  3 ++-
 arch/x86/mm/init_32.c          |  3 ++-
 arch/x86/mm/init_64.c          |  3 ++-
 include/linux/memory_hotplug.h |  1 +
 mm/memory_hotplug.c            | 28 ++++++++++++++++++++++++++++
 8 files changed, 42 insertions(+), 7 deletions(-)

-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
