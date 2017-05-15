Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 67C3D6B0038
	for <linux-mm@kvack.org>; Mon, 15 May 2017 09:34:39 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 25so46609456qtx.11
        for <linux-mm@kvack.org>; Mon, 15 May 2017 06:34:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l21si10862196qtl.71.2017.05.15.06.34.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 06:34:38 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [RFC PATCH v2 00/17] cgroup: Major changes to cgroup v2 core
Date: Mon, 15 May 2017 09:33:59 -0400
Message-Id: <1494855256-12558-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de, longman@redhat.com

 v1->v2:
  - Add a new pass-through mode to allow each controller its own
    unique virtual hierarchy.
  - Add a new control file "cgroup.resource_control" to enable
    the user creation of separate control knobs for internal process
    anywhere in the v2 hierarchy instead of doing that automatically
    in the thread root only.
  - More functionality in the debug controller to dump out more
    internal states.
  - Ported to the 4.12 kernel.
  - Other miscellaneous bug fixes.

 v1: https://lwn.net/Articles/720651/

The existing cgroup v2 core has quite a number of limitations and
constraints that make it hard to migrate controllers from v1 to v2
without suffering performance loss and usability.

This patchset makes some major changes to the cgroup v2 core to
give more freedom and flexibility to controllers so that they can
have their own unique views of the virtual process hierarchies that
are best suit for thier own use cases without suffering unneeded
performance problem. So "Live Free or Die".

On the other hand, the existing controller activation mechanism via
the cgroup.subtree_control file remains unchanged. So existing code 
that relies on the current cgroup v2 semantics should not be impacted.

The major changes are:
 1) Getting rid of the no internal process constraint by allowing
    controllers that don't like internal process competition to have
    separate sets of control knobs for internal processes as if they
    are in a child cgroup of their own.
 2) A thread mode for threaded controllers (e.g. cpu) that can
    have unthreaded child cgroups under a thread root.
 3) A pass-through mode for controllers that disable them for a cgroup
    effectively collapsing the cgroup's processes to its parent
    from the perspective of those controllers while allowing child
    cgroups to have the controllers enabled again. This allows each
    controller a unique virtual hierarchy that can be quite different
    from other controllers.

This patchset incorporates the following 2 patchsets from Tejun Heo:

 1) cgroup v2 thread mode patchset (Patches 1-5)
    https://lkml.org/lkml/2017/2/2/592
 2) CPU Controller on Control Group v2 (Patches 15 & 16)
    https://lkml.org/lkml/2016/8/5/368

Patch 6 fixes a task_struct reference counting bug introduced in
patch 1.

Patch 7 fixes a problem that css_kill() may be called more than once.

Patch 8 moves the debug cgroup out from cgroup_v1.c into its own
file.

Patch 9 keeps more accurate counts of the number of tasks associated
with each css_set.

Patch 10 enhances the debug controller to provide more information
relevant to the cgroup v2 thread mode to ease debugging effort.

Patch 11 implements the enhanced cgroup v2 thread mode with the
following enhancements:

 1) Thread roots are treated differently from threaded cgroups.
 2) Thread root can now have non-threaded controllers enabled as well
    as non-threaded children.

Patch 12 gets rid of the no internal process contraint.

Patch 13 enables fine grained control of controllers including a new
pass-through mode.

Patch 14 enhances the debug controller to print out the virtual
hierarchies for each controller in cgroup v2.

Patch 17 makes both cpu and cpuacct controllers threaded.

Tejun Heo (7):
  cgroup: reorganize cgroup.procs / task write path
  cgroup: add @flags to css_task_iter_start() and implement
    CSS_TASK_ITER_PROCS
  cgroup: introduce cgroup->proc_cgrp and threaded css_set handling
  cgroup: implement CSS_TASK_ITER_THREADED
  cgroup: implement cgroup v2 thread support
  sched: Misc preps for cgroup unified hierarchy interface
  sched: Implement interface for cgroup unified hierarchy

Waiman Long (10):
  cgroup: Fix reference counting bug in cgroup_procs_write()
  cgroup: Prevent kill_css() from being called more than once
  cgroup: Move debug cgroup to its own file
  cgroup: Keep accurate count of tasks in each css_set
  cgroup: Make debug cgroup support v2 and thread mode
  cgroup: Implement new thread mode semantics
  cgroup: Remove cgroup v2 no internal process constraint
  cgroup: Allow fine-grained controllers control in cgroup v2
  cgroup: Enable printing of v2 controllers' cgroup hierarchy
  sched: Make cpu/cpuacct threaded controllers

 Documentation/cgroup-v2.txt     |  287 +++++++--
 include/linux/cgroup-defs.h     |   68 ++
 include/linux/cgroup.h          |   12 +-
 kernel/cgroup/Makefile          |    1 +
 kernel/cgroup/cgroup-internal.h |   19 +-
 kernel/cgroup/cgroup-v1.c       |  220 ++-----
 kernel/cgroup/cgroup.c          | 1317 ++++++++++++++++++++++++++++++++-------
 kernel/cgroup/cpuset.c          |    6 +-
 kernel/cgroup/debug.c           |  471 ++++++++++++++
 kernel/cgroup/freezer.c         |    6 +-
 kernel/cgroup/pids.c            |    1 +
 kernel/events/core.c            |    1 +
 kernel/sched/core.c             |  150 ++++-
 kernel/sched/cpuacct.c          |   55 +-
 kernel/sched/cpuacct.h          |    5 +
 mm/memcontrol.c                 |    2 +-
 net/core/netclassid_cgroup.c    |    2 +-
 17 files changed, 2148 insertions(+), 475 deletions(-)
 create mode 100644 kernel/cgroup/debug.c

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
