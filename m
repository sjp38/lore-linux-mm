Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 9F2D76B0070
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 16:34:29 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so6262945pad.14
        for <linux-mm@kvack.org>; Wed, 28 Nov 2012 13:34:29 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCHSET cgroup/for-3.8] cpuset: decouple cpuset locking from cgroup core
Date: Wed, 28 Nov 2012 13:34:07 -0800
Message-Id: <1354138460-19286-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com, paul@paulmenage.org, glommer@parallels.com
Cc: containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello, guys.

Depending on cgroup core locking - cgroup_mutex - is messy and makes
cgroup prone to locking dependency problems.  The current code already
has lock dependency loop - memcg nests get_online_cpus() inside
cgroup_mutex.  cpuset the other way around.

Regardless of the locking details, whatever is protecting cgroup has
inherently to be something outer to most other locking constructs.
cgroup calls into a lot of major subsystems which in turn have to
perform subsystem-specific locking.  Trying to nest cgroup
synchronization inside other locks isn't something which can work
well.

cgroup now has enough API to allow subsystems to implement their own
locking and cgroup_mutex is scheduled to be made private to cgroup
core.  This patchset makes cpuset implement its own locking instead of
relying on cgroup_mutex.

cpuset is rather nasty in this respect.  Some of it seems to have come
from the implementation history - cgroup core grew out of cpuset - but
big part stems from cpuset's need to migrate tasks to an ancestor
cgroup when an hotunplug event makes a cpuset empty (w/o any cpu or
memory).

This patchset decouples cpuset locking from cgroup_mutex.  After the
patchset, cpuset uses cpuset-specific cpuset_mutex instead of
cgroup_mutex.  This also removes the lockdep warning triggered during
cpu offlining (see 0009).

Note that this leaves memcg as the only external user of cgroup_mutex.
Michal, Kame, can you guys please convert memcg to use its own locking
too?

This patchset contains the following thirteen patches.

 0001-cpuset-remove-unused-cpuset_unlock.patch
 0002-cpuset-remove-fast-exit-path-from-remove_tasks_in_em.patch
 0003-cpuset-introduce-css_on-offline.patch
 0004-cpuset-introduce-CS_ONLINE.patch
 0005-cpuset-introduce-cpuset_for_each_child.patch
 0006-cpuset-cleanup-cpuset-_can-_attach.patch
 0007-cpuset-drop-async_rebuild_sched_domains.patch
 0008-cpuset-reorganize-CPU-memory-hotplug-handling.patch
 0009-cpuset-don-t-nest-cgroup_mutex-inside-get_online_cpu.patch
 0010-cpuset-make-CPU-memory-hotplug-propagation-asynchron.patch
 0011-cpuset-pin-down-cpus-and-mems-while-a-task-is-being-.patch
 0012-cpuset-schedule-hotplug-propagation-from-cpuset_atta.patch
 0013-cpuset-replace-cgroup_mutex-locking-with-cpuset-inte.patch

0001-0006 are prep patches.

0007-0009 make cpuset nest get_online_cpus() inside cgroup_mutex, not
the other way around.

0010-0012 plug holes which would be exposed by switching to
cpuset-specific locking.

0013 replaces cgroup_mutex with cpuset_mutex.

This patchset is on top of cgroup/for-3.8 (fddfb02ad0) and also
available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cpuset-locking

diffstat follows.

 kernel/cpuset.c |  750 +++++++++++++++++++++++++++++++-------------------------
 1 file changed, 423 insertions(+), 327 deletions(-)

Thanks.

--
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
