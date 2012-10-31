Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 2E7EA6B0072
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 01:35:20 -0400 (EDT)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [PART1 Patch 0/3] mm, memory-hotplug: allow to online movable memory
Date: Wed, 31 Oct 2012 13:40:33 +0800
Message-Id: <1351662036-7435-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org
Cc: Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Yinghai Lu <yinghai@kernel.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>

From: Lai Jiangshan <laijs@cn.fujitsu.com>

This patch is part1 of the following patchset:
    https://lkml.org/lkml/2012/10/29/319

The patchset is based on Linus's tree with these three patches already applied:
    https://lkml.org/lkml/2012/10/24/151
    https://lkml.org/lkml/2012/10/26/150

Movable memory is a very important concept of memory-management,
we need to consolidate it and make use of it on systems.

Movable memory is needed for
    anti-fragmentation(hugepage, big-order allocation...)
    logic hot-remove(virtualization, Memory capacity on Demand)
    physic hot-remove(power-saving, hardware partitioning, hardware fault management)

All these require dynamic configuring the memory and making better utilities of
memories and safer. We also need physic hot-remove, so we need movable node too.
(Although some systems support physic-memory-migration, we don't require all
memory on physic-node is movable, but movable node is still needed here
for logic-node if we want to make physic-migration is transparent)

We add dynamic configuration commands "online_movalbe" and "online_kernel" in
this patchset, and you can't make a movable node(it will be implemented in
part4).

Usage:
1. online_movable:
   echo online_movable >/sys/devices/system/memory/memoryX/state
   The memory must be offlined before doing this.
2. online_kernel:
   echo online_kernel >/sys/devices/system/memory/memoryX/state
   The memory must be offlined before doing this.
3. online:
   echo online_kernel >/sys/devices/system/memory/memoryX/state
   The memory must be offline before doing this. This operation does't change
   the memory's attribute: movable or normal/high

Note:
   You only can move the highest memory in normal/high zone to movable zone,
   and only can move the lowest memory in movable zone to normal/high zone.

Lai Jiangshan (3):
  mm, memory-hotplug: dynamic configure movable memory and portion
    memory
  memory_hotplug: handle empty zone when online_movable/online_kernel
  memory_hotplug: ensure every online node has NORMAL memory

 Documentation/memory-hotplug.txt |  14 ++-
 drivers/base/memory.c            |  27 +++---
 include/linux/memory_hotplug.h   |  13 ++-
 mm/memory_hotplug.c              | 180 ++++++++++++++++++++++++++++++++++++++-
 4 files changed, 221 insertions(+), 13 deletions(-)

-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
