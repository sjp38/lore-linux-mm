Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 993736B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 01:41:32 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id t88so3835504pfg.17
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 22:41:32 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id k91si10570919pld.115.2017.12.18.22.41.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 22:41:30 -0800 (PST)
From: Kemi Wang <kemi.wang@intel.com>
Subject: [PATCH v2 0/5] mm: NUMA stats code cleanup and enhancement
Date: Tue, 19 Dec 2017 14:39:21 +0800
Message-Id: <1513665566-4465-1-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Kemi Wang <kemi.wang@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

The existed implementation of NUMA counters is per logical CPU along with
zone->vm_numa_stat[] separated by zone, plus a global numa counter array
vm_numa_stat[]. However, unlike the other vmstat counters, NUMA stats don't
effect system's decision and are only consumed when reading from /proc and
/sys. Also, usually nodes only have a single zone, except for node 0, and
there isn't really any use where you need these hits counts separated by
zone.

Therefore, we can migrate the implementation of numa stats from per-zone to
per-node (as suggested by Andi Kleen), and reuse the existed per-cpu
infrastructure with a little enhancement for NUMA stats. In this way, we
can get rid of the special way for NUMA stats and keep the performance gain
at the same time. With this patch series, about 170 lines code can be
saved.

The first patch migrates NUMA stats from per-zone to pre-node using the
existed per-cpu infrastructure. There is a little user-visual change when
read /proc/zoneinfo listed below:
         Before                               After
Node 0, zone      DMA                   Node 0, zone      DMA
  per-node stats                          per-node stats
      nr_inactive_anon 7244                  *numa_hit     98665086*
      nr_active_anon 177064                  *numa_miss    0*
	      ...                                *numa_foreign 0*
      nr_bounce    0                         *numa_interleave 21059*
      nr_free_cma  0                         *numa_local   98665086*
     *numa_hit     0*                        *numa_other   0*
     *numa_miss    0*                         nr_inactive_anon 20055
     *numa_foreign 0*                         nr_active_anon 389771
     *numa_interleave 0*                   	      ...
     *numa_local   0*                         nr_bounce    0
     *numa_other   0*                         nr_free_cma  0

The second patch extends the local cpu counter vm_stat_node_diff from s8 to
s16. It does not have any functionality change.

The third patch uses a large and constant threshold size for NUMA counters
to reduce the global NUMA counters update frequency.

The forth patch uses node_page_state_snapshot instead of node_page_state
when query a node stats (e.g. cat /sys/devices/system/node/node*/vmstat).
The only differece is that the stats value in local cpus are also included
in node_page_state_snapshot.

The last patch renames zone_statistics() to numa_statistics().

At last, I want to extend my heartiest appreciation for Michal Hocko's
suggestion of reusing the existed per-cpu infrastructure making it much
better than before.

Changelog:
  v1->v2:
  a) enhance the existed per-cpu infrastructure for node page stats by
  entending local cpu counters vm_node_stat_diff from s8 to s16
  b) reuse the per-cpu infrastrcuture for NUMA stats

Kemi Wang (5):
  mm: migrate NUMA stats from per-zone to per-node
  mm: Extends local cpu counter vm_diff_nodestat from s8 to s16
  mm: enlarge NUMA counters threshold size
  mm: use node_page_state_snapshot to avoid deviation
  mm: Rename zone_statistics() to numa_statistics()

 drivers/base/node.c    |  28 +++----
 include/linux/mmzone.h |  31 ++++----
 include/linux/vmstat.h |  31 --------
 mm/mempolicy.c         |   2 +-
 mm/page_alloc.c        |  22 +++---
 mm/vmstat.c            | 206 +++++++++----------------------------------------
 6 files changed, 74 insertions(+), 246 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
