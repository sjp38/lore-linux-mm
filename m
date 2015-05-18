Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 961516B0032
	for <linux-mm@kvack.org>; Mon, 18 May 2015 15:50:00 -0400 (EDT)
Received: by qcbgu10 with SMTP id gu10so94453359qcb.2
        for <linux-mm@kvack.org>; Mon, 18 May 2015 12:50:00 -0700 (PDT)
Received: from mail-qk0-x233.google.com (mail-qk0-x233.google.com. [2607:f8b0:400d:c09::233])
        by mx.google.com with ESMTPS id x8si8810117qkx.126.2015.05.18.12.49.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 12:49:59 -0700 (PDT)
Received: by qkgx75 with SMTP id x75so116735757qkg.1
        for <linux-mm@kvack.org>; Mon, 18 May 2015 12:49:59 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCHSET cgroup/for-4.2] cgroup: make multi-process migration atomic
Date: Mon, 18 May 2015 15:49:48 -0400
Message-Id: <1431978595-12176-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com
Cc: cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-mm@kvack.org

Hello,

When a controller is enabled or disabled on the unified hierarchy, the
effective css changes for all processes in the sub-hierarchy which
virtually is multi-process migration.  This is implemented in
cgroup_update_dfl_csses() as process-by-process migration - all the
target source css_sets are first chained to the target list and
processes are drained from them one-by-one.

If a process gets rejected by a controller after some are successfully
migrated, the recovery action is tricky.  The changes which have
happened upto this point have to be rolled back but there's nothing
guaranteeing such rollback would be successful either.

The unified hierarchy didn't need to deal with this issue because
organizational operations were expected to always succeed;
unfortunately, it turned out that such policy doesn't work too well
for certain type of resources and unified hierarchy would need to
allow migration failures for some restrictied cases.

This patch updates multi-process migration in
cgroup_update_dfl_csses() atomic so that ->can_attach() can fail the
whole transaction.  It's consisted of the following seven patches.

 0001-cpuset-migrate-memory-only-for-threadgroup-leaders.patch
 0002-memcg-restructure-mem_cgroup_can_attach.patch
 0003-memcg-immigrate-charges-only-when-a-threadgroup-lead.patch
 0004-cgroup-memcg-cpuset-implement-cgroup_taskset_for_eac.patch
 0005-reorder-cgroup_migrate-s-parameters.patch
 0006-cgroup-separate-out-taskset-operations-from-cgroup_m.patch
 0007-cgroup-make-cgroup_update_dfl_csses-migrate-all-targ.patch

0001-0004 prepare cpuset and memcg.  Note that 0001 and 0003 do cause
behavioral changes in that mm is now always tied to the threadgroup
leader.  Avoiding this change isn't too difficult but both the code
and behavior are saner this way and I don't think the change is likely
to cause breakage.

0005-0007 prepare and implement atomic multi-process migration.

This patchset is on top of the following patches.

 cgroup/for-4.2 d0f702e648dc ("cgroup: fix some comment typos")
 + [1] [PATCH] cgroup: separate out include/linux/cgroup-defs.h
 + [2] [PATCH] cgroup: reorganize include/linux/cgroup.h
 + [3] [PATCHSET] cgroup, sched: restructure threadgroup locking and replace it with a percpu_rwsem

and available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-multi-process-migration

diffstat follows.  Thanks.

 include/linux/cgroup.h |   22 +++
 kernel/cgroup.c        |  278 ++++++++++++++++++++++++-------------------------
 kernel/cpuset.c        |   41 +++----
 mm/memcontrol.c        |   74 +++++++------
 4 files changed, 228 insertions(+), 187 deletions(-)

--
tejun

[1] http://lkml.kernel.org/g/20150513193840.GC11388@htj.duckdns.org
[2] http://lkml.kernel.org/g/20150513202416.GE11388@htj.duckdns.org
[3] http://lkml.kernel.org/g/1431549318-16756-1-git-send-email-tj@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
