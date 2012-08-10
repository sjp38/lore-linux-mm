Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id B65AF6B005A
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 13:55:34 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v7 0/4] make balloon pages movable by compaction
Date: Fri, 10 Aug 2012 14:55:13 -0300
Message-Id: <cover.1344619987.git.aquini@redhat.com>
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

Rafael Aquini (4):
  mm: introduce compaction and migration for virtio ballooned pages
  virtio_balloon: introduce migration primitives to balloon pages
  mm: introduce putback_movable_pages()
  mm: add vm event counters for balloon pages compaction

 drivers/virtio/virtio_balloon.c | 139 +++++++++++++++++++++++++++++++++++++---
 include/linux/migrate.h         |   2 +
 include/linux/mm.h              |  17 +++++
 include/linux/virtio_balloon.h  |   4 ++
 include/linux/vm_event_item.h   |   8 ++-
 mm/compaction.c                 | 131 +++++++++++++++++++++++++++++++------
 mm/migrate.c                    |  51 ++++++++++++++-
 mm/page_alloc.c                 |   2 +-
 mm/vmstat.c                     |  10 ++-
 9 files changed, 331 insertions(+), 33 deletions(-)

Change log:
v7:
 * fix a potential page leak case at 'putback_balloon_page' (Mel);
 * adjust vm-events-counter patch and remove its drop-on-merge message (Rik);
 * add 'putback_movable_pages' to avoid hacks on 'putback_lru_pages' (Minchan);
v6:
 * rename 'is_balloon_page()' to 'movable_balloon_page()' (Rik);
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
(2 VCPU 2048mB RAM KVM guest running 3.6.0_rc1+ -- after a reboot)

* 64mB balloon:
[root@localhost ~]# awk '/compact/ {print}' /proc/vmstat
compact_blocks_moved 0
compact_pages_moved 0
compact_pagemigrate_failed 0
compact_stall 0
compact_fail 0
compact_success 0
compact_balloon_isolated 0
compact_balloon_migrated 0
compact_balloon_returned 0
compact_balloon_released 0
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
compact_blocks_moved 6579
compact_pages_moved 50114
compact_pagemigrate_failed 111
compact_stall 0
compact_fail 0
compact_success 0
compact_balloon_isolated 18361
compact_balloon_migrated 18306
compact_balloon_returned 55
compact_balloon_released 18306


* 128 mB balloon:
[root@localhost ~]# awk '/compact/ {print}' /proc/vmstat
compact_blocks_moved 0
compact_pages_moved 0
compact_pagemigrate_failed 0
compact_stall 0
compact_fail 0
compact_success 0
compact_balloon_isolated 0
compact_balloon_migrated 0
compact_balloon_returned 0
compact_balloon_released 0
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
compact_blocks_moved 6789
compact_pages_moved 64479
compact_pagemigrate_failed 127
compact_stall 0
compact_fail 0
compact_success 0
compact_balloon_isolated 33937
compact_balloon_migrated 33869
compact_balloon_returned 68
compact_balloon_released 33869

-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
