Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 91A499000C6
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 23:39:43 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p8H3daN4031405
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 20:39:36 -0700
Received: from iabz21 (iabz21.prod.google.com [10.12.102.21])
	by hpaq11.eem.corp.google.com with ESMTP id p8H3dYXs021378
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 20:39:35 -0700
Received: by iabz21 with SMTP id z21so4369037iab.23
        for <linux-mm@kvack.org>; Fri, 16 Sep 2011 20:39:33 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 0/8] idle page tracking / working set estimation
Date: Fri, 16 Sep 2011 20:39:05 -0700
Message-Id: <1316230753-8693-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michael Wolf <mjwolf@us.ibm.com>

Please comment on the following patches (which are against the v3.0 kernel).
We are using these to collect memory utilization statistics for each cgroup
accross many machines, and optimize job placement accordingly.

The statistics are intended to be compared accross many machines - we
don't just want to know which cgroup to reclaim from on an individual
machine, we also need to know which machine is best to target a job onto
within a large cluster. Also, we try to have a low impact on the normal
MM algorithms - we think they already do a fine job balancing resources
on individual machines, so we are not trying to mess up with that here.

Patch 1 introduces no functionality; it modifies the page_referenced API
so that it can be more easily extended in patch 3.

Patch 2 documents the proposed features, and adds a configuration option
for these. When the features are compiled in, they are still disabled
until the administrator sets up the desired scanning interval; however
the configuration option seems necessary as the features make use of
3 extra page flags - there is plenty of space for these in 64-bit builds,
but less so in 32-bit builds...

Patch 3 introduces page_referenced_kstaled(), which is similar to
page_referenced() but is used for idle page tracking rather than
for memory reclaimation. Since both functions clear the pte_young bits
and we don't want them to interfere with each other, two new page flags
are introduced that track when young pte references have been cleared by
each of the page_referenced variants. The page_referenced functions are also
extended to return the dirty status of any pte references encountered.

Patch 4 introduces the 'kstaled' thread that handles idle page tracking.
The thread starts disabled; one enables it by setting a scanning interval
in /sys/kernel/mm/kstaled/scan_seconds. It then scans all physical memory
pages, looking for idle pages - pages that have not been touched since the
previous scan interval. These pages are further classified into idle_clean
(which are immediately reclaimable), idle_dirty_swap (which are reclaimable
if swap is enabled on the system), and idle_dirty_file (which are reclaimable
after writeback occurs). These statistics are published for each cgroup in
a new /dev/cgroup/*/memory.idle_page_stats file. We did not use the
memory.stat file there because we thought these stats are different -
first, they are meaningless until one sets the scan_seconds value, and
then they are only updated once per scan interval where the memory.stat
values are continually updated.

Patch 5 is a small optimization skipping over memory holes.

Patch 6 rate limits the idle page scanning so that it occurs in small
chunks over the length of the scan interval, rather than all at once.

Patch 7 adds extra functionality to track how long a given page has been
idle, so that memory.idle_page_stats can report pages that have been
idle for 1,2,5,15,30,60,120 or 240 consecutive scan intervals.

Patch 8 adds extra functionality in the form of an incremental update
feature. Here we only report immediately reclaimable idle pages; however
we don't want to wait for the end of a scan interval to update this number
if the system experiences a rapid increase in memory pressure.

Michel Lespinasse (8):
  page_referenced: replace vm_flags parameter with struct pr_info
  kstaled: documentation and config option.
  kstaled: page_referenced_kstaled() and supporting infrastructure.
  kstaled: minimalistic implementation.
  kstaled: skip non-RAM regions.
  kstaled: rate limit pages scanned per second.
  kstaled: add histogram sampling functionality
  kstaled: add incrementally updating stale page count

 Documentation/cgroups/memory.txt  |  103 ++++++++-
 arch/x86/include/asm/page_types.h |    8 +
 arch/x86/kernel/e820.c            |   45 ++++
 include/linux/ksm.h               |    9 +-
 include/linux/mmzone.h            |   11 +
 include/linux/page-flags.h        |   50 ++++
 include/linux/pagemap.h           |   11 +-
 include/linux/rmap.h              |   82 ++++++-
 mm/Kconfig                        |   10 +
 mm/internal.h                     |    1 +
 mm/ksm.c                          |   15 +-
 mm/memcontrol.c                   |  492 +++++++++++++++++++++++++++++++++++++
 mm/memory_hotplug.c               |    6 +
 mm/mlock.c                        |    1 +
 mm/rmap.c                         |  136 ++++++-----
 mm/swap.c                         |    1 +
 mm/vmscan.c                       |   20 +-
 17 files changed, 904 insertions(+), 97 deletions(-)

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
