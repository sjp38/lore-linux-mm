Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 243146B0037
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 04:13:28 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id bs8so396766wib.14
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 01:13:27 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id cp2si1922850wib.107.2014.07.18.01.13.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 01:13:26 -0700 (PDT)
From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 0/5] memory-hotplug: suitable memory should go to ZONE_MOVABLE
Date: Fri, 18 Jul 2014 15:55:58 +0800
Message-ID: <1405670163-53747-1-git-send-email-wangnan0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Yinghai Lu <yinghai@kernel.org>, Mel
 Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Pei Feiyue <peifeiyue@huawei.com>, linux-mm@kvack.org, x86@kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org

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


Wang Nan (5):
  memory-hotplug: x86_64: suitable memory should go to ZONE_MOVABLE
  memory-hotplug: x86_32: suitable memory should go to ZONE_MOVABLE
  memory-hotplug: ia64: suitable memory should go to ZONE_MOVABLE
  memory-hotplug: sh: suitable memory should go to ZONE_MOVABLE
  memory-hotplug: powerpc: suitable memory should go to ZONE_MOVABLE

 arch/ia64/mm/init.c   |  7 +++++++
 arch/powerpc/mm/mem.c |  6 ++++++
 arch/sh/mm/init.c     | 13 ++++++++-----
 arch/x86/mm/init_32.c |  6 ++++++
 arch/x86/mm/init_64.c | 10 ++++++++--
 5 files changed, 35 insertions(+), 7 deletions(-)

-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
