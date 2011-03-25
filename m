Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 01DF98D0047
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 04:44:31 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p2P8iJdW010718
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 01:44:19 -0700
Received: from iyb39 (iyb39.prod.google.com [10.241.49.103])
	by hpaq5.eem.corp.google.com with ESMTP id p2P8i4Zr006561
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 01:44:18 -0700
Received: by iyb39 with SMTP id 39so296152iyb.36
        for <linux-mm@kvack.org>; Fri, 25 Mar 2011 01:44:18 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [RFC 0/5] idle page tracking / working set estimation
Date: Fri, 25 Mar 2011 01:43:50 -0700
Message-Id: <1301042635-11180-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

I would like to sollicit comments on the following patches. In order to
optimize job placement accross many machines, we collect memory utilization
statistics for each cgroup on each machine. The statistics are intended
to be compared accross many machines - we don't just want to know which
cgroup to reclaim from on an individual machine, we also need to know
which machine is best to target a job onto within a large cluster.
Also, we try to have a low impact on the normal MM algorithms - we think
they already do a fine job balancing resources on individual machines, so
we are not trying to mess up with that here.

Patch 1 introduces no functionality; it modifies the page_referenced API
so that it can be more easily extended in patch 2.

Patch 2 introduces page_referenced_kstaled(), which is similar to
page_referenced() but is used for idle page tracking rather than
for memory reclaimation. Since both functions clear the pte_young bits
and we don't want them to interfere with each other, two new page flags
are introduced that track when young pte references have been cleared by
each of the page_referenced variants. The page_referenced functions are also
extended to return the dirty status of any pte references encountered.

Patch 3 introduces the 'kstaled' thread that handles idle page tracking.
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

Patch 4 is a small optimization skipping over memory holes

Patch 5 rate limits the idle page scanning so that it occurs in small
chunks over the length of the scan interval, rather than all at once.

Please note that there are known problems in these changes. In particular,
kstaled_scan_page gets page references in a way that is known to be unsafe
when THP is enabled. I'm still figuring out how to address this, but thought
it may be useful to send the current patches for discussion first.

Michel Lespinasse (5):
  page_referenced: replace vm_flags parameter with struct pr_info
  kstaled: page_referenced_kstaled() and supporting infrastructure.
  kstaled: minimalistic implementation.
  kstaled: skip non-RAM regions.
  kstaled: rate limit pages scanned per second.

 arch/x86/include/asm/page_types.h |    8 +
 arch/x86/kernel/e820.c            |   45 +++++
 include/linux/ksm.h               |    9 +-
 include/linux/mmzone.h            |    7 +
 include/linux/page-flags.h        |   25 +++
 include/linux/rmap.h              |   78 ++++++++-
 mm/ksm.c                          |   15 +-
 mm/memcontrol.c                   |  339 +++++++++++++++++++++++++++++++++++++
 mm/memory.c                       |   14 ++
 mm/rmap.c                         |  136 ++++++++-------
 mm/swap.c                         |    1 +
 mm/vmscan.c                       |   18 +-
 12 files changed, 604 insertions(+), 91 deletions(-)

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
