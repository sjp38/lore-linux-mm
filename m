Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id DFF256B0011
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 06:13:28 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v3 0/6] replace cgroup_lock with memcg specific locking
Date: Mon, 21 Jan 2013 15:13:27 +0400
Message-Id: <1358766813-15095-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

Hi,

In memcg, we use the cgroup_lock basically to synchronize against
attaching new children to a cgroup. We do this because we rely on cgroup core to
provide us with this information.

We need to guarantee that upon child creation, our tunables are consistent.
For those, the calls to cgroup_lock() all live in handlers like
mem_cgroup_hierarchy_write(), where we change a tunable in the group that is
hierarchy-related. For instance, the use_hierarchy flag cannot be changed if
the cgroup already have children.

Furthermore, those values are propageted from the parent to the child when a
new child is created. So if we don't lock like this, we can end up with the
following situation:

A                                   B
 memcg_css_alloc()                       mem_cgroup_hierarchy_write()
 copy use hierarchy from parent          change use hierarchy in parent
 finish creation.

This is mainly because during create, we are still not fully connected to the
css tree. So all iterators and the such that we could use, will fail to show
that the group has children.

My observation is that all of creation can proceed in parallel with those
tasks, except value assignment. So what this patchseries does is to first move
all value assignment that is dependent on parent values from css_alloc to
css_online, where the iterators all work, and then we lock only the value
assignment. This will guarantee that parent and children always have consistent
values. Together with an online test, that can be derived from the observation
that the refcount of an online memcg can be made to be always positive, we
should be able to synchronize our side without the cgroup lock.

*v3:
 - simplified test for presence of children, and no longer using refcnt for
   online testing
 - some cleanups as suggested by Michal

*v2:
 - sanitize kmemcg assignment in the light of the current locking change.
 - don't grab locks on immigrate charges by caching the value during can_attach

Glauber Costa (6):
  memcg: prevent changes to move_charge_at_immigrate during task attach
  memcg: split part of memcg creation to css_online
  memcg: fast hierarchy-aware child test.
  memcg: replace cgroup_lock with memcg specific memcg_lock
  memcg: increment static branch right after limit set.
  memcg: avoid dangling reference count in creation failure.

 mm/memcontrol.c | 210 +++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 123 insertions(+), 87 deletions(-)

-- 
1.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
