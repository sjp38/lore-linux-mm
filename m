Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 5DCB76B005D
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 09:57:36 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v5 0/3] make balloon pages movable by compaction
Date: Mon,  6 Aug 2012 10:56:49 -0300
Message-Id: <cover.1344259054.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Rafael Aquini <aquini@redhat.com>

Memory fragmentation introduced by ballooning might reduce significantly
the number of 2MB contiguous memory blocks that can be used within a guest,
thus imposing performance penalties associated with the reduced number of
transparent huge pages that could be used by the guest workload.

This patch-set follows the main idea discussed at 2012 LSFMMS session:
"Ballooning for transparent huge pages" -- http://lwn.net/Articles/490114/
to introduce the required changes to the virtio_balloon driver, as well as
the changes to the core compaction & migration bits, in order to make those
subsystems aware of ballooned pages and allow memory balloon pages become
movable within a guest, thus avoiding the aforementioned fragmentation issue

Rafael Aquini (3):
  mm: introduce compaction and migration for virtio ballooned pages
  virtio_balloon: introduce migration primitives to balloon pages
  mm: add vm event counters for balloon pages compaction

 drivers/virtio/virtio_balloon.c | 139 +++++++++++++++++++++++++++++++++++++---
 include/linux/mm.h              |  26 ++++++++
 include/linux/virtio_balloon.h  |   4 ++
 include/linux/vm_event_item.h   |   2 +
 mm/compaction.c                 | 131 +++++++++++++++++++++++++++++++------
 mm/migrate.c                    |  34 +++++++++-
 mm/vmstat.c                     |   4 ++
 7 files changed, 312 insertions(+), 28 deletions(-)

Change log:
v5:
 * address Andrew Morton's review comments on the patch series;
 * address a couple extra nitpick suggestions on PATCH 01 (Minchan);
v4: 
 * address Rusty Russel's review comments on PATCH 02;
 * re-base virtio_balloon patch on 9c378abc5c0c6fc8e3acf5968924d274503819b3;
V3: 
 * address reviewers nitpick suggestions on PATCH 01 (Mel, Minchan);
V2: 
 * address Mel Gorman's review comments on PATCH 01;


Preliminary test results:
(2 VCPU 1024mB RAM KVM guest running 3.6.0_rc1+ -- after a reboot)

* 64mB balloon:
[root@localhost ~]# awk '/compact/ {print}' /proc/vmstat
compact_blocks_moved 0
compact_pages_moved 0
compact_pagemigrate_failed 0
compact_stall 0
compact_fail 0
compact_success 0
compact_balloon_migrated 0
compact_balloon_failed 0
compact_balloon_isolated 0
compact_balloon_freed 0
[root@localhost ~]#
[root@localhost ~]# for i in $(seq 1 6); do echo 1 > /proc/sys/vm/compact_memory & done &>/dev/null 
[1]   Done                    echo 1 > /proc/sys/vm/compact_memory
[2]   Done                    echo 1 > /proc/sys/vm/compact_memory
[3]   Done                    echo 1 > /proc/sys/vm/compact_memory
[4]   Done                    echo 1 > /proc/sys/vm/compact_memory
[5]-  Done                    echo 1 > /proc/sys/vm/compact_memory
[6]+  Done                    echo 1 > /proc/sys/vm/compact_memory
[root@localhost ~]# 
[root@localhost ~]# awk '/compact/ {print}' /proc/vmstat
compact_blocks_moved 3520
compact_pages_moved 47548
compact_pagemigrate_failed 120
compact_stall 0
compact_fail 0
compact_success 0
compact_balloon_migrated 16378
compact_balloon_failed 0
compact_balloon_isolated 16378
compact_balloon_freed 16378

* 128mB balloon:
[root@localhost ~]# awk '/compact/ {print}' /proc/vmstat
compact_blocks_moved 0
compact_pages_moved 0
compact_pagemigrate_failed 0
compact_stall 0
compact_fail 0
compact_success 0
compact_balloon_migrated 0
compact_balloon_failed 0
compact_balloon_isolated 0
compact_balloon_freed 0
[root@localhost ~]#
[root@localhost ~]# for i in $(seq 1 6); do echo 1 > /proc/sys/vm/compact_memory & done &>/dev/null 
[1]   Done                    echo 1 > /proc/sys/vm/compact_memory
[2]   Done                    echo 1 > /proc/sys/vm/compact_memory
[3]   Done                    echo 1 > /proc/sys/vm/compact_memory
[4]   Done                    echo 1 > /proc/sys/vm/compact_memory
[5]-  Done                    echo 1 > /proc/sys/vm/compact_memory
[6]+  Done                    echo 1 > /proc/sys/vm/compact_memory
[root@localhost ~]# 
[root@localhost ~]# awk '/compact/ {print}' /proc/vmstat
compact_blocks_moved 3356
compact_pages_moved 47099
compact_pagemigrate_failed 158
compact_stall 0
compact_fail 0
compact_success 0
compact_balloon_migrated 26275
compact_balloon_failed 42
compact_balloon_isolated 26317
compact_balloon_freed 26275

-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
