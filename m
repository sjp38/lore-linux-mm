Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 66E176B0031
	for <linux-mm@kvack.org>; Sun,  4 Aug 2013 12:07:34 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id e11so1219129qcx.8
        for <linux-mm@kvack.org>; Sun, 04 Aug 2013 09:07:33 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCHSET cgroup/for-3.12] cgroup: make cgroup_event specific to memcg
Date: Sun,  4 Aug 2013 12:07:21 -0400
Message-Id: <1375632446-2581-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com, hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

Like many other things in cgroup, cgroup_event is way too flexible and
complex - it strives to provide completely flexible event monitoring
facility in cgroup proper which allows any number of users to monitor
custom events.  This is overboard, to say the least, and I strongly
think that cgroup should not any new usages of this facility and
preferably deprecate the existing usages if at all possible.

Fortunately, memcg along with vmpressure is the only user of the
facility and gets to keep it.  This patchset makes cgroup_event
specific to memcg, moves all related code into mm/memcontrol.c and
renames it to mem_cgroup_event so that its usage can't spread to other
subsystems and later deprecation and cleanup can be localized.

Note that after this patchset, cgroup.event_control file exists only
for the hierarchy which has memcg attached to it.  This is a userland
visible change but unlikely to be noticeable as the file has never
been meaningful outside memcg.  If this ever becomes problematic, we
can add a dummy file on hierarchies w/o memcg when !sane_behavior.

This patchset is consited of the following five patches.

 0001-cgroup-implement-CFTYPE_NO_PREFIX.patch
 0002-cgroup-export-__cgroup_from_dentry-and-__cgroup_dput.patch
 0003-cgroup-memcg-move-cgroup_event-implementation-to-mem.patch
 0004-cgroup-memcg-move-cgroup-event_list-_lock-and-event-.patch
 0005-memcg-rename-cgroup_event-to-mem_cgroup_event.patch

The patchset is on top of

  cgroup/for-3.12 61584e3f4 ("cgroup: Merge branch 'for-3.11-fixes' into for-3.12")
+ [1] cgroup: use cgroup_subsys_state as the primary subsystem interface handle

and available in the following branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-memcg_event

diffstat follows.

 Documentation/cgroups/cgroups.txt |   19 --
 include/linux/cgroup.h            |   29 ---
 include/linux/vmpressure.h        |    1
 kernel/cgroup.c                   |  265 +--------------------------------
 mm/memcontrol.c                   |  302 ++++++++++++++++++++++++++++++++++++--
 5 files changed, 315 insertions(+), 301 deletions(-)

Thanks.

--
tejun

[1] https://lkml.org/lkml/2013/8/1/722

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
