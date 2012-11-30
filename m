Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 2689F6B00AB
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 08:31:48 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 0/4] replace cgroup_lock with local lock in memcg
Date: Fri, 30 Nov 2012 17:31:22 +0400
Message-Id: <1354282286-32278-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

Hi,

In memcg, we use the cgroup_lock basically to synchronize against two events:
attaching tasks and children to a cgroup.

For the problem of attaching tasks, I am using something similar to cpusets:
when task attaching starts, we will flip a flag "attach_in_progress", that will
be flipped down when it finishes. This way, all readers can know that a task is
joining the group and take action accordingly. With this, we can guarantee that
the behavior of move_charge_at_immigrate continues safe

Protecting against children creation requires a bit more work. For those, the
calls to cgroup_lock() all live in handlers like mem_cgroup_hierarchy_write(),
where we change a tunable in the group, that is hierarchy-related. For
instance, the use_hierarchy flag cannot be changed if the cgroup already have
children.

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
assignment. This will guarantee that parent and children always have
consistent values.

Glauber Costa (4):
  cgroup: warn about broken hierarchies only after css_online
  memcg: prevent changes to move_charge_at_immigrate during task attach
  memcg: split part of memcg creation to css_online
  memcg: replace cgroup_lock with memcg specific memcg_lock

 kernel/cgroup.c |  18 +++----
 mm/memcontrol.c | 164 +++++++++++++++++++++++++++++++++++++++++---------------
 2 files changed, 129 insertions(+), 53 deletions(-)

-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
