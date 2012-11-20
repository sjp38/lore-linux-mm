Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 617B06B0074
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 03:32:42 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 0/6] Automatic NUMA placement of tasks in cpu cgroup
Date: Tue, 20 Nov 2012 12:31:58 +0400
Message-Id: <1353400324-10897-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Balbir Singh <bsingharora@gmail.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mel@csn.ul.ie>Tejun Heo <tj@kernel.org>

Hi,

This patchset has absolutely nothing to do with NUMA. But now that I got your
attention:

This is an attempt to ressurect a patchset that Tejun Heo sent a while ago,
aiming at deprecation of cpuacct. He only went as far as publishing the files
in the cpu cgroup, but the final work would require us to take advantage
of it by not incurring in hierarchy walks more times than necessary.

It is trivial to do it in the case where we have SCHEDSTATS enabled: we already
record a statistic that is exactly the same as cpuusage: exec_clock. That is
not collected for rt tasks, so the only thing we need to do is to also collect
it for them, and print them back for cpuusage.

In theory, it would also be possible to avoid hierarchy walks even without
SCHEDSTATS: we could modify task_group_charge() to stop walking, and then
update cpuusage only for the current group, during the walk we already do.
I didn't do so, because I believe we care more about setups that would enable
a bunch of options anyway - which is likely to include SCHEDSTATS. Custom setups
can take a much easier route and just compile out the whole thing! But let me
know if I should do it.


Glauber Costa (3):
  don't call cpuacct_charge in stop_task.c
  sched: adjust exec_clock to use it as cpu usage metric
  cpuacct: don't actually do anything.

Tejun Heo (3):
  cgroup: implement CFTYPE_NO_PREFIX
  cgroup, sched: let cpu serve the same files as cpuacct
  cgroup, sched: deprecate cpuacct

 include/linux/cgroup.h   |   1 +
 init/Kconfig             |  11 +-
 kernel/cgroup.c          |  57 ++++++++++-
 kernel/sched/core.c      | 262 ++++++++++++++++++++++++++++++++++++++++++++++-
 kernel/sched/fair.c      |   1 +
 kernel/sched/rt.c        |   2 +
 kernel/sched/sched.h     |  14 ++-
 kernel/sched/stop_task.c |   1 -
 8 files changed, 341 insertions(+), 8 deletions(-)

-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
