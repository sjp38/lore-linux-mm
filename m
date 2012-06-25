Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id AE7C96B03B1
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 19:26:06 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH 0/4] make balloon pages movable by compaction
Date: Mon, 25 Jun 2012 20:25:55 -0300
Message-Id: <cover.1340665087.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>

This patchset follows the main idea discussed at 2012 LSFMMS section:
"Ballooning for transparent huge pages" -- http://lwn.net/Articles/490114/

to introduce the required changes to the virtio_balloon driver, as well as
changes to the core compaction & migration bits, in order to allow
memory balloon pages become movable within a guest.

Rafael Aquini (4):
  mm: introduce compaction and migration for virtio ballooned pages
  virtio_balloon: handle concurrent accesses to virtio_balloon struct
    elements
  virtio_balloon: introduce migration primitives to balloon pages
  mm: add vm event counters for balloon pages compaction

 drivers/virtio/virtio_balloon.c |  142 +++++++++++++++++++++++++++++++++++----
 include/linux/mm.h              |   17 +++++
 include/linux/virtio_balloon.h  |    6 ++
 include/linux/vm_event_item.h   |    2 +
 mm/compaction.c                 |   74 ++++++++++++++++++++
 mm/migrate.c                    |   32 ++++++++-
 mm/vmstat.c                     |    4 ++
 7 files changed, 263 insertions(+), 14 deletions(-)


Preliminary test results:
(2 VCPU 1024mB RAM KVM guest running 3.5.0_rc4+)

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
[root@localhost ~]# for i in $(seq 1 4); do echo 1> /proc/sys/vm/compact_memory & done &>/dev/null
[1]   Done                    echo > /proc/sys/vm/compact_memory
[2]   Done                    echo > /proc/sys/vm/compact_memory
[3]-  Done                    echo > /proc/sys/vm/compact_memory
[4]+  Done                    echo > /proc/sys/vm/compact_memory
[root@localhost ~]#
[root@localhost ~]# awk '/compact/ {print}' /proc/vmstat
compact_blocks_moved 2683
compact_pages_moved 47502
compact_pagemigrate_failed 61
compact_stall 0
compact_fail 0
compact_success 0
compact_balloon_migrated 16384
compact_balloon_failed 0
compact_balloon_isolated 16384
compact_balloon_freed 16384


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
[root@localhost ~]# for i in $(seq 1 4); do echo 1> /proc/sys/vm/compact_memory & done &>/dev/null
[1]   Done                    echo > /proc/sys/vm/compact_memory
[2]   Done                    echo > /proc/sys/vm/compact_memory
[3]-  Done                    echo > /proc/sys/vm/compact_memory
[4]+  Done                    echo > /proc/sys/vm/compact_memory
[root@localhost ~]# awk '/compact/ {print}' /proc/vmstat
compact_blocks_moved 2624
compact_pages_moved 49195
compact_pagemigrate_failed 54
compact_stall 0
compact_fail 0
compact_success 0
compact_balloon_migrated 29350
compact_balloon_failed 29
compact_balloon_isolated 29379
compact_balloon_freed 29350
-- 
1.7.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
