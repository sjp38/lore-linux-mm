Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id C6E0C6B0032
	for <linux-mm@kvack.org>; Fri, 12 Jun 2015 05:52:45 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so21740468pdb.1
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 02:52:45 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id qq9si4687637pbb.13.2015.06.12.02.52.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jun 2015 02:52:44 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v6 0/6] idle memory tracking
Date: Fri, 12 Jun 2015 12:52:20 +0300
Message-ID: <cover.1434102076.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel
 Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

This patch set introduces a new user API for tracking user memory pages
that have not been used for a given period of time. The purpose of this
is to provide the userspace with the means of tracking a workload's
working set, i.e. the set of pages that are actively used by the
workload. Knowing the working set size can be useful for partitioning
the system more efficiently, e.g. by tuning memory cgroup limits
appropriately, or for job placement within a compute cluster.

---- USE CASES ----

The unified cgroup hierarchy has memory.low and memory.high knobs, which
are defined as the low and high boundaries for the workload working set
size. However, the working set size of a workload may be unknown or
change in time. With this patch set, one can periodically estimate the
amount of memory unused by each cgroup and tune their memory.low and
memory.high parameters accordingly, therefore optimizing the overall
memory utilization.

Another use case is balancing workloads within a compute cluster.
Knowing how much memory is not really used by a workload unit may help
take a more optimal decision when considering migrating the unit to
another node within the cluster.

Also, as noted by Minchan, this would be useful for per-process reclaim
(https://lwn.net/Articles/545668/). With idle tracking, we could reclaim idle
pages only by smart user memory manager.

---- USER API ----

The user API consists of two new proc files:

 * /proc/kpageidle.  This file implements a bitmap where each bit corresponds
   to a page, indexed by PFN. When the bit is set, the corresponding page is
   idle. A page is considered idle if it has not been accessed since it was
   marked idle. To mark a page idle one should set the bit corresponding to the
   page by writing to the file. A value written to the file is OR-ed with the
   current bitmap value. Only user memory pages can be marked idle, for other
   page types input is silently ignored. Writing to this file beyond max PFN
   results in the ENXIO error. Only available when CONFIG_IDLE_PAGE_TRACKING is
   set.

   This file can be used to estimate the amount of pages that are not
   used by a particular workload as follows:

   1. mark all pages of interest idle by setting corresponding bits in the
      /proc/kpageidle bitmap
   2. wait until the workload accesses its working set
   3. read /proc/kpageidle and count the number of bits set

 * /proc/kpagecgroup.  This file contains a 64-bit inode number of the
   memory cgroup each page is charged to, indexed by PFN. Only available when
   CONFIG_MEMCG is set.

   This file can be used to find all pages (including unmapped file
   pages) accounted to a particular cgroup. Using /proc/kpageidle, one
   can then estimate the cgroup working set size.

For an example of using these files for estimating the amount of unused
memory pages per each memory cgroup, please see the script attached
below.

---- REASONING ----

The reason to introduce the new user API instead of using
/proc/PID/{clear_refs,smaps} is that the latter has two serious
drawbacks:

 - it does not count unmapped file pages
 - it affects the reclaimer logic

The new API attempts to overcome them both. For more details on how it
is achieved, please see the comment to patch 5.

---- CHANGE LOG ----

Changes in v6:

 - Split the patch introducing page_cgroup_ino helper to ease review.
 - Rebase on top of v4.1-rc7-mmotm-2015-06-09-16-55

Changes in v5:

 - Fix possible race between kpageidle_clear_pte_refs() and
   __page_set_anon_rmap() by checking that a page is on an LRU list
   under zone->lru_lock (Minchan).
 - Export idle flag via /proc/kpageflags (Minchan).
 - Rebase on top of 4.1-rc3.

Changes in v4:

This iteration primarily addresses Minchan's comments to v3:

 - Implement /proc/kpageidle as a bitmap instead of using u64 per each page,
   because there does not seem to be any future uses for the other 63 bits.
 - Do not double-increase pra->referenced in page_referenced_one() if the page
   was young and referenced recently.
 - Remove the pointless (page_count == 0) check from kpageidle_get_page().
 - Rename kpageidle_clear_refs() to kpageidle_clear_pte_refs().
 - Improve comments to kpageidle-related functions.
 - Rebase on top of 4.1-rc2.

Note it does not address Minchan's concern of possible __page_set_anon_rmap vs
page_referenced race (see https://lkml.org/lkml/2015/5/3/220) since it is still
unclear if this race can really happen (see https://lkml.org/lkml/2015/5/4/160)

Changes in v3:

 - Enable CONFIG_IDLE_PAGE_TRACKING for 32 bit. Since this feature
   requires two extra page flags and there is no space for them on 32
   bit, page ext is used (thanks to Minchan Kim).
 - Minor code cleanups and comments improved.
 - Rebase on top of 4.1-rc1.

Changes in v2:

 - The main difference from v1 is the API change. In v1 the user can
   only set the idle flag for all pages at once, and for clearing the
   Idle flag on pages accessed via page tables /proc/PID/clear_refs
   should be used.
   The main drawback of the v1 approach, as noted by Minchan, is that on
   big machines setting the idle flag for each pages can result in CPU
   bursts, which would be especially frustrating if the user only wanted
   to estimate the amount of idle pages for a particular process or VMA.
   With the new API a more fine-grained approach is possible: one can
   read a process's /proc/PID/pagemap and set/check the Idle flag only
   for those pages of the process's address space he or she is
   interested in.
   Another good point about the v2 API is that it is possible to limit
   /proc/kpage* scanning rate when the user wants to estimate the total
   number of idle pages, which is unachievable with the v1 approach.
 - Make /proc/kpagecgroup return the ino of the closest online ancestor
   in case the cgroup a page is charged to is offline.
 - Fix /proc/PID/clear_refs not clearing Young page flag.
 - Rebase on top of v4.0-rc6-mmotm-2015-04-01-14-54

v4: https://lkml.org/lkml/2015/5/7/580
v3: https://lkml.org/lkml/2015/4/28/224
v2: https://lkml.org/lkml/2015/4/7/260
v1: https://lkml.org/lkml/2015/3/18/794

---- PATCH SET STRUCTURE ----

The patch set is organized as follows:

 - patch 1 adds page_cgroup_ino() helper for the sake of
   /proc/kpagecgroup and patches 2-3 do related cleanup
 - patch 4 adds /proc/kpagecgroup, which reports cgroup ino each page is
   charged to
 - patch 5 implements the idle page tracking feature, including the
   userspace API, /proc/kpageidle
 - patch 6 exports idle flag via /proc/kpageflags

---- SIMILAR WORKS ----

Originally, the patch for tracking idle memory was proposed back in 2011
by Michel Lespinasse (see http://lwn.net/Articles/459269/). The main
difference between Michel's patch and this one is that Michel
implemented a kernel space daemon for estimating idle memory size per
cgroup while this patch only provides the userspace with the minimal API
for doing the job, leaving the rest up to the userspace. However, they
both share the same idea of Idle/Young page flags to avoid affecting the
reclaimer logic.

---- SCRIPT FOR COUNTING IDLE PAGES PER CGROUP ----
#! /usr/bin/python
#

import os
import stat
import errno
import struct

CGROUP_MOUNT = "/sys/fs/cgroup/memory"
BUFSIZE = 8 * 1024  # must be multiple of 8


def set_idle():
    f = open("/proc/kpageidle", "wb", BUFSIZE)
    while True:
        try:
            f.write(struct.pack("Q", pow(2, 64) - 1))
        except IOError as err:
            if err.errno == errno.ENXIO:
                break
            raise
    f.close()


def count_idle():
    f_flags = open("/proc/kpageflags", "rb", BUFSIZE)
    f_cgroup = open("/proc/kpagecgroup", "rb", BUFSIZE)
    f_idle = open("/proc/kpageidle", "rb", BUFSIZE)

    pfn = 0
    nr_idle = {}
    while True:
        s = f_flags.read(8)
        if not s:
            break

        flags, = struct.unpack('Q', s)
        cgino, = struct.unpack('Q', f_cgroup.read(8))

        bit = pfn % 64
        if not bit:
            idle_bitmap, = struct.unpack('Q', f_idle.read(8))

        idle = idle_bitmap >> bit & 1
        pfn += 1

        unevictable = flags >> 18 & 1
        huge = flags >> 22 & 1

        if idle and not unevictable:
            nr_idle[cgino] = nr_idle.get(cgino, 0) + (512 if huge else 1)

    f_flags.close()
    f_cgroup.close()
    f_idle.close()
    return nr_idle


print "Setting the idle flag for each page..."
set_idle()

raw_input("Wait until the workload accesses its working set, then press Enter")

print "Counting idle pages..."
nr_idle = count_idle()

for dir, subdirs, files in os.walk(CGROUP_MOUNT):
    ino = os.stat(dir)[stat.ST_INO]
    print dir + ": " + str(nr_idle.get(ino, 0) * 4) + " KB"
---- END SCRIPT ----

Comments are more than welcome.

Thanks,

Vladimir Davydov (6):
  memcg: add page_cgroup_ino helper
  hwpoison: use page_cgroup_ino for filtering by memcg
  memcg: zap try_get_mem_cgroup_from_page
  proc: add kpagecgroup file
  proc: add kpageidle file
  proc: export idle flag via kpageflags

 Documentation/vm/pagemap.txt           |  22 +++-
 fs/proc/page.c                         | 234 +++++++++++++++++++++++++++++++++
 fs/proc/task_mmu.c                     |   4 +-
 include/linux/memcontrol.h             |   7 +-
 include/linux/mm.h                     |  88 +++++++++++++
 include/linux/page-flags.h             |   9 ++
 include/linux/page_ext.h               |   4 +
 include/uapi/linux/kernel-page-flags.h |   1 +
 mm/Kconfig                             |  12 ++
 mm/debug.c                             |   4 +
 mm/hwpoison-inject.c                   |   5 +-
 mm/memcontrol.c                        |  71 +++++-----
 mm/memory-failure.c                    |  16 +--
 mm/page_ext.c                          |   3 +
 mm/rmap.c                              |   8 ++
 mm/swap.c                              |   2 +
 16 files changed, 428 insertions(+), 62 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
