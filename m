Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3C0766B000C
	for <linux-mm@kvack.org>; Sat, 24 Mar 2018 12:09:29 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id a127so265275ywc.5
        for <linux-mm@kvack.org>; Sat, 24 Mar 2018 09:09:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v19sor1000992ywc.374.2018.03.24.09.09.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 24 Mar 2018 09:09:28 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCHSET] mm, memcontrol: Make cgroup_rstat available to controllers
Date: Sat, 24 Mar 2018 09:08:58 -0700
Message-Id: <20180324160901.512135-1-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com
Cc: guro@fb.com, riel@surriel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org

Hello,

Since a983b5ebee57 ("mm: memcontrol: fix excessive complexity in
memory.stat reporting"), memcg uses percpu batch-overflowing for all
stat accounting.  While the propagation delay is okay for statistics,
it doesn't work for events.  If a notification for an event is sent
out, the relevant counter must reflect the event when read afterwards.
With the percpu batching, it's easy to miss, for example, an oom or
oom_kill event because it's still buffered in one of the percpu
counters.

cgroup already has a mechanism to efficiently handle hierarchical
statistics in a scalable manner, cgroup_rstat, and it now can be used
by controllers.

This patchset addresses the forementioned problem by converting event
accounting to cgroup_rstat.  While the stat part isn't broken, it's
also converted for consistency and a few other benefits.  Also, while
trying to convert lruvec_stat, I found out that it has no users.
Remove it too (not sure whether it's needed for some non-obvious
reasons tho).

 0001-mm-memcontrol-Use-cgroup_rstat-for-event-accounting.patch
 0002-mm-memcontrol-Use-cgroup_rstat-for-stat-accounting.patch
 0003-mm-memcontrol-Remove-lruvec_stat.patch

This patchset is on top of the "cgroup/for-4.17: Make cgroup_rstat
available to controllers" patchset[1] and also available in the
following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cgroup_rstat

diffstat follows.

 include/linux/memcontrol.h |  131 ++++++++++++------------
 mm/memcontrol.c            |  238 ++++++++++++++++++++-------------------------
 mm/vmscan.c                |    4 
 3 files changed, 180 insertions(+), 193 deletions(-)

Thanks.

--
tejun

[1] http://lkml.kernel.org/r/20180323231313.1254142-1-tj@kernel.org
