Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 108DD6B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 16:44:49 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so53652240pdn.0
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 13:44:48 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id n6si38265122pdm.75.2015.03.18.13.44.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 13:44:47 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 0/3] idle memory tracking
Date: Wed, 18 Mar 2015 23:44:33 +0300
Message-ID: <cover.1426706637.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

Knowing the portion of memory that is not used by a certain application
or memory cgroup (idle memory) can be useful for partitioning the system
efficiently. Currently, the only means to estimate the amount of idle
memory provided by the kernel is /proc/PID/clear_refs. However, it has
two serious shortcomings:

 - it does not count unmapped file pages
 - it affects the reclaimer logic

Back in 2011 an attempt was made by Michel Lespinasse to improve the
situation (see http://lwn.net/Articles/459269/). He proposed a kernel
space daemon which would periodically scan physical address range,
testing and clearing ACCESS/YOUNG PTE bits, and counting pages that had
not been referenced since the last scan. The daemon avoided interference
with the page reclaimer by setting the new PG_young flag on referenced
pages and making page_referenced() return >= 1 if PG_young was set.

This patch set reuses the idea of Michel's patch set, but the
implementation is quite different. Instead of introducing a kernel space
daemon, it only provides the userspace with the necessary means to
estimate the amount of idle memory, leaving the daemon to be implemented
in the userspace. In order to achieve that, it adds two new proc files,
/proc/kpagecgroup and /proc/sys/vm/set_idle, and extends the clear_refs
interface.

Usage:

 1. Write 1 to /proc/sys/vm/set_idle.

    This will set the IDLE flag for all user pages. The IDLE flag is cleared
    when the page is read or the ACCESS/YOUNG bit is cleared in any PTE pointing
    to the page. It is also cleared when the page is freed.

 2. Wait some time.

 3. Write 6 to /proc/PID/clear_refs for each PID of interest.

    This will clear the IDLE flag for recently accessed pages.

 4. Count the number of idle pages as reported by /proc/kpageflags. One may use
    /proc/PID/pagemap and/or /proc/kpagecgroup to filter pages that belong to a
    certain application/container.

An example of using this new interface is below. It is a script that
counts the number of pages charged to a specified cgroup that have not
been accessed for a given time interval.

---- BEGIN SCRIPT ----
#! /usr/bin/python
#

import struct
import sys
import os
import stat
import time

def get_end_pfn():
    f = open("/proc/zoneinfo", "r")
    end_pfn = 0
    for l in f.readlines():
        l = l.split()
        if l[0] == "spanned":
            end_pfn = int(l[1])
        elif l[0] == "start_pfn:":
            end_pfn += int(l[1])
    return end_pfn

def set_idle():
    open("/proc/sys/vm/set_idle", "w").write("1")

def clear_refs(target_cg_path):
    procs = open(target_cg_path + "/cgroup.procs", "r")
    for pid in procs.readlines():
        try:
            with open("/proc/" + pid.rstrip() + "/clear_refs", "w") as f:
                f.write("6")
        except IOError as e:
            print "Failed to clear_refs for pid " + pid + ": " + str(e)

def count_idle(target_cg_path):
    target_cg_ino = os.stat(target_cg_path)[stat.ST_INO]

    pgflags = open("/proc/kpageflags", "rb")
    pgcgroup = open("/proc/kpagecgroup", "rb")

    nidle = 0

    for i in range(0, get_end_pfn()):
        cg_ino = struct.unpack('Q', pgcgroup.read(8))[0]
        flags = struct.unpack('Q', pgflags.read(8))[0]

        if cg_ino != target_cg_ino:
            continue

        # unevictable?
        if (flags >> 18) & 1 != 0:
            continue

        # huge?
        if (flags >> 22) & 1 != 0:
            npages = 512
        else:
            npages = 1

        # idle?
        if (flags >> 25) & 1 != 0:
            nidle += npages

    return nidle

if len(sys.argv) <> 3:
    print "Usage: %s cgroup_path scan_interval" % sys.argv[0]
    exit(1)

cg_path = sys.argv[1]
scan_interval = int(sys.argv[2])

while True:
    set_idle()
    time.sleep(scan_interval)
    clear_refs(cg_path)
    print count_idle(cg_path)
---- END SCRIPT ----

Thanks,

Vladimir Davydov (3):
  memcg: add page_cgroup_ino helper
  proc: add kpagecgroup file
  mm: idle memory tracking

 Documentation/filesystems/proc.txt     |    3 +
 Documentation/vm/00-INDEX              |    2 +
 Documentation/vm/idle_mem_tracking.txt |   23 +++++++
 Documentation/vm/pagemap.txt           |   10 ++-
 fs/proc/Kconfig                        |    5 +-
 fs/proc/page.c                         |  107 ++++++++++++++++++++++++++++++++
 fs/proc/task_mmu.c                     |   22 ++++++-
 include/linux/memcontrol.h             |    8 +--
 include/linux/page-flags.h             |   12 ++++
 include/uapi/linux/kernel-page-flags.h |    1 +
 kernel/sysctl.c                        |   14 +++++
 mm/Kconfig                             |   12 ++++
 mm/debug.c                             |    4 ++
 mm/hwpoison-inject.c                   |    5 +-
 mm/memcontrol.c                        |   61 ++++++++----------
 mm/memory-failure.c                    |   16 +----
 mm/rmap.c                              |    7 +++
 mm/swap.c                              |    2 +
 18 files changed, 248 insertions(+), 66 deletions(-)
 create mode 100644 Documentation/vm/idle_mem_tracking.txt

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
