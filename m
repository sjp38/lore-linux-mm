Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 6F8F86B005C
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 12:51:21 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v4 0/3] make balloon pages movable by compaction
Date: Tue, 17 Jul 2012 13:50:40 -0300
Message-Id: <cover.1342485774.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Rafael Aquini <aquini@linux.com>, Rafael Aquini <aquini@redhat.com>

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

 drivers/virtio/virtio_balloon.c |  146 ++++++++++++++++++++++++++++++++++++---
 include/linux/mm.h              |   15 ++++
 include/linux/virtio_balloon.h  |    4 ++
 include/linux/vm_event_item.h   |    2 +
 mm/compaction.c                 |  127 +++++++++++++++++++++++++++++-----
 mm/migrate.c                    |   32 ++++++++-
 mm/vmstat.c                     |    4 ++
 7 files changed, 302 insertions(+), 28 deletions(-)

Change log:
v4: 
 * address Rusty Russel's review comments on PATCH 02;
 * re-base virtio_balloon patch on 9c378abc5c0c6fc8e3acf5968924d274503819b3;
V3: 
 * address reviewers nitpick suggestions on PATCH 01 (Mel, Minchan);
V2: 
 * address Mel Gorman's review comments on PATCH 01;


Preliminary test results:
(2 VCPU 1024mB RAM KVM guest running 3.5.0_rc7+ -- after a reboot)
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
[root@localhost ~]# for i in $(seq 1 4); do echo 1 > /proc/sys/vm/compact_memory & done &>/dev/null
[1]   Done                    echo 1 > /proc/sys/vm/compact_memory
[2]   Done                    echo 1 > /proc/sys/vm/compact_memory
[3]-  Done                    echo 1 > /proc/sys/vm/compact_memory
[4]+  Done                    echo 1 > /proc/sys/vm/compact_memory
[root@localhost ~]#
[root@localhost ~]# awk '/compact/ {print}' /proc/vmstat
compact_blocks_moved 2842
compact_pages_moved 48429
compact_pagemigrate_failed 81
compact_stall 0
compact_fail 0
compact_success 0
compact_balloon_migrated 16364
compact_balloon_failed 0
compact_balloon_isolated 16364
compact_balloon_freed 16364


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
[root@localhost ~]# for i in $(seq 1 4); do echo 1 > /proc/sys/vm/compact_memory & done &>/dev/null
[1]   Done                    echo 1 > /proc/sys/vm/compact_memory
[2]   Done                    echo 1 > /proc/sys/vm/compact_memory
[3]-  Done                    echo 1 > /proc/sys/vm/compact_memory
[4]+  Done                    echo 1 > /proc/sys/vm/compact_memory
[root@localhost ~]#
[root@localhost ~]# awk '/compact/ {print}' /proc/vmstat
compact_blocks_moved 2162
compact_pages_moved 33735
compact_pagemigrate_failed 69
compact_stall 0
compact_fail 0
compact_success 0
compact_balloon_migrated 21731
compact_balloon_failed 0
compact_balloon_isolated 21731
compact_balloon_freed 21731

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
