Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id C39286B0038
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 07:55:27 -0400 (EDT)
Received: by patj18 with SMTP id j18so76498114pat.2
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 04:55:27 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id bc10si5723560pdb.81.2015.04.07.04.55.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Apr 2015 04:55:26 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [RFC v2 0/3] idle memory tracking
Date: Tue, 7 Apr 2015 14:55:10 +0300
Message-ID: <cover.1428401673.git.vdavydov@parallels.com>
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

The API consists of the new read-write proc file, /proc/kpageidle. For
each page this file contains a 64-bit number, which equals 1 if the page
is idle or 0 otherwise. The file is indexed by PFN. To set or clear a
page's Idle flag, one can write 1 or 0 respectively to this file at the
offset corresponding to the page. It is only possible to modify the Idle
flag for user pages (pages that are on an LRU list, to be more exact).
For other page types, the input is silently ignored. Writing to this
file beyond max PFN results in the ENXIO error.

A page's Idle flag is automatically cleared whenever the page is
accessed (via a page table entry or using the read(2) system call).
Thus by setting the Idle flag for pages of a particular workload, which
can be found e.g. by reading /proc/PID/pagemap, waiting for some time to
let the workload access its working set, and then reading the kpageidle
file, one can estimate the amount of pages that are not used by the
workload.

The reason to introduce the new API is that the current API provided by
the kernel, /proc/PID/{clear_refs,smaps} and friends, has two serious
drawbacks:

 - it does not count unmapped file pages
 - it affects the reclaimer logic

The new API attempts to overcome them both. For more details on this,
please see patch #3.

Apart from /proc/kpageidle, another new proc file is introduced,
/proc/kpagecgroup, which contains the inode number of the memory cgroup
each page is charged to. This file is needed to help estimating the
working set size per cgroup.

An example of using this new API for estimating the number of idle pages
in each memory cgroup is attached below.

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

v1 can be found at: https://lwn.net/Articles/637190/

The patch set is organized as follows:

 - patch 1 adds page_cgroup_ino() helper for the sake of
   /proc/kpagecgroup

 - patch 2 adds /proc/kpagecgroup, which reports cgroup ino each page is
   charged to

 - patch 3 implements the idle page tracking feature, including the
   userspace API, /proc/kpageidle

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

 Documentation/vm/pagemap.txt |   21 ++++-
 fs/proc/Kconfig              |    5 +-
 fs/proc/page.c               |  202 ++++++++++++++++++++++++++++++++++++++++++
 fs/proc/task_mmu.c           |    4 +-
 include/linux/memcontrol.h   |    8 +-
 include/linux/page-flags.h   |   12 +++
 mm/Kconfig                   |   12 +++
 mm/debug.c                   |    4 +
 mm/hwpoison-inject.c         |    5 +-
 mm/memcontrol.c              |   73 +++++++--------
 mm/memory-failure.c          |   16 +---
 mm/rmap.c                    |    7 ++
 mm/swap.c                    |    2 +
 13 files changed, 307 insertions(+), 64 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
