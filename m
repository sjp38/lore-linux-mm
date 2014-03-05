Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 11E366B0098
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 22:58:41 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id md12so500204pbc.9
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 19:58:41 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id q5si893597pbh.344.2014.03.04.19.58.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Mar 2014 19:58:40 -0800 (PST)
Received: by mail-pa0-f42.google.com with SMTP id fb1so510931pad.29
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 19:58:39 -0800 (PST)
Date: Tue, 4 Mar 2014 19:58:38 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 00/11] userspace out of memory handling
Message-ID: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

This patchset implements userspace out of memory handling.

It is based on v3.14-rc5.  Individual patches will apply cleanly or you
may pull the entire series from

	git://git.kernel.org/pub/scm/linux/kernel/git/rientjes/linux.git mm/oom

When the system or a memcg is oom, processes running on that system or
attached to that memcg cannot allocate memory.  It is impossible for a
process to reliably handle the oom condition from userspace.

First, consider only system oom conditions.  When memory is completely
depleted and nothing may be reclaimed, the kernel is forced to free some
memory; the only way it can do so is to kill a userspace process.  This
will happen instantaneously and userspace can enforce neither its own
policy nor collect information.

On system oom, there may be a hierarchy of memcgs that represent user
jobs, for example.  Each job may have a priority independent of their
current memory usage.  There is no existing kernel interface to kill the
lowest priority job; userspace can now kill the lowest priority job or
allow priorities to change based on whether the job is using more memory
than its pre-defined reservation.

Additionally, users may want to log the condition or debug applications
that are using too much memory.  They may wish to collect heap profiles
or are able to do memory freeing without killing a process by throttling
or ratelimiting.

Interactive users using X window environments may wish to have a dialogue
box appear to determine how to proceed -- it may even allow them shell
access to examine the state of the system while oom.

It's not sufficient to simply restrict all user processes to a subset of
memory and oom handling processes to the remainder via a memcg hierarchy:
kernel memory and other page allocations can easily deplete all memory
that is not charged to a user hierarchy of memory.

This patchset allows userspace to do all of these things by defining a
small memory reserve that is accessible only by processes that are
handling the notification.

Second, consider memcg oom conditions.  Processes need no special
knowledge of whether they are attached to the root memcg, where memcg
charging will always succeed, or a child memcg where charging will fail
when the limit has been reached.  This allows those processes handling
memcg oom conditions to overcharge the memcg by the amount of reserved
memory.  They need not create child memcgs with smaller limits and
attach the userspace oom handler only to the parent; such support would
not allow userspace to handle system oom conditions anyway.

This patchset introduces a standard interface through memcg that allows
both of these conditions to be handled in the same clean way: users
define memory.oom_reserve_in_bytes to define the reserve and this
amount is allowed to be overcharged to the process handling the oom
condition's memcg.  If used with the root memcg, this amount is allowed
to be allocated below the per-zone watermarks for root processes that
are handling such conditions (only root may write to
cgroup.event_control for the root memcg).
---
 Documentation/cgroups/memory.txt           |  46 ++++++++-
 Documentation/cgroups/resource_counter.txt |  12 +--
 Documentation/sysctl/vm.txt                |   5 +
 arch/m32r/mm/discontig.c                   |   1 +
 include/linux/memcontrol.h                 |  24 +++++
 include/linux/mempolicy.h                  |   3 +-
 include/linux/mmzone.h                     |   2 +
 include/linux/res_counter.h                |  16 ++--
 include/linux/sched.h                      |   2 +-
 kernel/fork.c                              |  13 +--
 kernel/res_counter.c                       |  42 ++++++---
 mm/memcontrol.c                            | 144 ++++++++++++++++++++++++++++-
 mm/mempolicy.c                             |  46 ++-------
 mm/oom_kill.c                              |   7 ++
 mm/page_alloc.c                            |  17 +++-
 mm/slab.c                                  |   8 +-
 mm/slub.c                                  |   2 +-
 17 files changed, 292 insertions(+), 98 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
