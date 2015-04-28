Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id DD92A6B0038
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 08:24:55 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so163247262pab.3
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 05:24:55 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ga3si34359882pbb.49.2015.04.28.05.24.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 05:24:54 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v3 0/3] idle memory tracking
Date: Tue, 28 Apr 2015 15:24:39 +0300
Message-ID: <cover.1430217477.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

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

---- USER API ----

The user API consists of two new proc files:

 * /proc/kpageidle.  For each page this file contains a 64-bit number, which
   equals 1 if the page is idle or 0 otherwise, indexed by PFN. A page is
   considered idle if it has not been accessed since it was marked idle. To
   mark a page idle one should write 1 to this file at the offset corresponding
   to the page. Only user memory pages can be marked idle, for other page types
   input is silently ignored. Writing to this file beyond max PFN results in
   the ENXIO error. Only available when CONFIG_IDLE_PAGE_TRACKING is set.

   This file can be used to estimate the amount of pages that are not
   used by a particular workload as follows:

   1. mark all pages of interest idle by writing 1 at the corresponding
      offsets to /proc/kpageidle
   2. wait until the workload accesses its working set
   3. read /proc/kpageidle and count the amount of idle pages

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
is achieved, please see the comment to patch 3.

---- CHANGE LOG ----

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

v2: https://lkml.org/lkml/2015/4/7/260
v1: https://lkml.org/lkml/2015/3/18/794

---- PATCH SET STRUCTURE ----

The patch set is organized as follows:

 - patch 1 adds page_cgroup_ino() helper for the sake of
   /proc/kpagecgroup
 - patch 2 adds /proc/kpagecgroup, which reports cgroup ino each page is
   charged to
 - patch 3 implements the idle page tracking feature, including the
   userspace API, /proc/kpageidle

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

CGROUP_MOUNT = "/sys/fs/cgroup/memory"

import os
import stat
import errno
import struct

def set_idle():
    pgidle = open("/proc/kpageidle", "wb")
    while True:
        try:
            pgidle.write(struct.pack("Q", 1))
        except IOError as e:
            if e.errno == errno.ENXIO: break
            raise
    pgidle.close()

def count_idle():
    pgflags = open("/proc/kpageflags", "rb")
    pgcgroup = open("/proc/kpagecgroup", "rb")
    pgidle = open("/proc/kpageidle", "rb")
    nidle = {}
    while True:
        s = pgflags.read(8)
        if len(s) != 8: break;
        flags = struct.unpack('Q', s)[0]
        cgino = struct.unpack('Q', pgcgroup.read(8))[0]
        idle = struct.unpack('Q', pgidle.read(8))[0]
        if not idle: continue
        if (flags >> 18) & 1: continue # unevictable?
        npages = 512 if (flags >> 22) & 1 else 1 # huge?
        nidle[cgino] = nidle.get(cgino, 0) + npages
    pgflags.close()
    pgcgroup.close()
    pgidle.close()
    return nidle

print "Setting the idle flag for each page..."
set_idle()

raw_input("Wait until the workload accesses its working set, then press Enter")

print "Counting idle pages..."
nidle = count_idle()

for dir, subdirs, files in os.walk(CGROUP_MOUNT):
    ino = os.stat(dir)[stat.ST_INO]
    print dir + ": " + str(nidle.get(ino, 0))
---- END SCRIPT ----

Comments are more than welcome.

Thanks,

Vladimir Davydov (3):
  memcg: add page_cgroup_ino helper
  proc: add kpagecgroup file
  proc: add kpageidle file

 Documentation/vm/pagemap.txt |   14 ++-
 fs/proc/Kconfig              |    5 +-
 fs/proc/page.c               |  207 ++++++++++++++++++++++++++++++++++++++++++
 fs/proc/task_mmu.c           |    4 +-
 include/linux/memcontrol.h   |    8 +-
 include/linux/mm.h           |   88 ++++++++++++++++++
 include/linux/page-flags.h   |    9 ++
 include/linux/page_ext.h     |    4 +
 mm/Kconfig                   |   12 +++
 mm/debug.c                   |    4 +
 mm/hwpoison-inject.c         |    5 +-
 mm/memcontrol.c              |   73 +++++++--------
 mm/memory-failure.c          |   16 +---
 mm/page_ext.c                |    3 +
 mm/rmap.c                    |    7 ++
 mm/swap.c                    |    2 +
 16 files changed, 397 insertions(+), 64 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
