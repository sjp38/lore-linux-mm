Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4333F6B00DF
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 03:37:47 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id et14so1304424pad.14
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 00:37:46 -0800 (PST)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id ca3si22254319pad.126.2014.11.12.00.37.43
        for <linux-mm@kvack.org>;
        Wed, 12 Nov 2014 00:37:45 -0800 (PST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 0/2] Fix node meminfo corruption.
Date: Wed, 12 Nov 2014 16:36:48 +0800
Message-ID: <1415781410-19825-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, grygorii.strashko@ti.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, fabf@skynet.be, nzimmer@sgi.com, wangnan0@huawei.com, vdavydov@parallels.com, toshi.kani@hp.com, phacht@linux.vnet.ibm.com, tj@kernel.org, kirill.shutemov@linux.intel.com, riel@redhat.com, luto@amacapital.net, hpa@linux.intel.com, aarcange@redhat.com, qiuxishi@huawei.com, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tangchen@cn.fujitsu.com

There are two problems when calculating node meminfo:

1. When hot-adding a node without onlining any page, MemTotal corrupted.

# hot-add node2 (memory not onlined)
# cat /sys/device/system/node/node2/meminfo
Node 2 MemTotal:       33554432 kB			/* corrupted */
Node 2 MemFree:               0 kB
Node 2 MemUsed:        33554432 kB
Node 2 Active:                0 kB
......


2. When onlining memory on node2, MemFree of node3 corrupted.

# for ((i = 2048; i < 2064; i++)); do echo online_movable > /sys/devices/system/node/node2/memory$i/state; done
# cat /sys/devices/system/node/node2/meminfo
Node 2 MemTotal:       33554432 kB
Node 2 MemFree:        33549092 kB
Node 2 MemUsed:            5340 kB
......
# cat /sys/devices/system/node/node3/meminfo
Node 3 MemTotal:              0 kB
Node 3 MemFree:               248 kB                    /* corrupted */
Node 3 MemUsed:               0 kB
......

This patch-set fixes them.

Tang Chen (2):
  mem-hotplug: Reset node managed pages when hot-adding a new pgdat.
  mem-hotplug: Fix wrong check for zone->pageset initialization in
    online_pages().

 include/linux/bootmem.h |  1 +
 include/linux/mm.h      |  1 +
 mm/bootmem.c            |  9 +++++----
 mm/memory_hotplug.c     | 15 ++++++++++++++-
 mm/nobootmem.c          |  8 +++++---
 mm/page_alloc.c         |  5 +++++
 6 files changed, 31 insertions(+), 8 deletions(-)

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
