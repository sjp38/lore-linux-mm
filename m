Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 6916E6B0031
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 20:44:49 -0400 (EDT)
Received: by mail-qe0-f53.google.com with SMTP id 1so1361007qee.26
        for <linux-mm@kvack.org>; Mon, 03 Jun 2013 17:44:48 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCHSET] memcg: fix and reimplement iterator
Date: Mon,  3 Jun 2013 17:44:36 -0700
Message-Id: <1370306679-13129-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, hannes@cmpxchg.org, bsingharora@gmail.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

mem_cgroup_iter() wraps around cgroup_next_descendant_pre() to provide
pre-order walk of memcg hierarchy.  In addition to normal walk, it
also implements shared iteration keyed by zone, node and priority so
that multiple reclaimers don't end up hitting on the same nodes.
Reclaimers working on the same zone, node and priority will push the
same iterator forward.

Unfortunately, the way this is implemented is disturbingly
complicated.  It ends up implementing pretty unique synchronization
construct inside memcg which is never a good sign for any subsystem.
While the implemented sychronization is overly elaborate and fragile,
the intention behind it is understandable as previously cgroup
iterator required each iteration to be contained inside a single RCU
read critical section disallowing implementation of saner mechanism.
To work around the limitation, memcg developed this Rube Goldberg
machine to detect whether the cached last cgroup is still alive, which
of course was ever so subtly broken.

Now that cgroup iterations can survive being dropped out of RCU read
critical section, this can be made a lot simpler.  This patchset
contains the following three patches.

 0001-memcg-fix-subtle-memory-barrier-bug-in-mem_cgroup_it.patch
 0002-memcg-restructure-mem_cgroup_iter.patch
 0003-memcg-simplify-mem_cgroup_reclaim_iter.patch

0001 is fix for a subtle memory barrier bug in the current
implementation.  Should be applied to for-3.10-fixes and backported
through -stable.  In general, memory barriers are bad ideas.  Please
don't do it unless utterly necessary, and, if you're doing it, please
add ample documentation explaining how they're paired and what they're
achieving.  Documenting is often extremely helpful for the implementor
oneself too because one ends up looking at and thinking about things a
lot more carefully.

0002 restructure mem_cgroup_iter() so that it's easier to follow and
change.

0003 reimplements the iterator sharing so that it's simpler and more
conventional.  It depends on the new cgroup iterator updates.

This patchset is on top of cgroup/for-3.11[1] which contains the
iterator updates this patchset depends upon and available in the
following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-memcg-simpler-iter

Lightly tested.  Proceed with caution.

 mm/memcontrol.c |  134 ++++++++++++++++++++++----------------------------------
 1 file changed, 54 insertions(+), 80 deletions(-)

Thanks.

--
tejun

[1] git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
