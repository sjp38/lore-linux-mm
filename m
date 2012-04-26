Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 1724D6B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 18:53:14 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v4 0/3] fix problem with static_branch() for sock memcg
Date: Thu, 26 Apr 2012 19:51:04 -0300
Message-Id: <1335480667-8301-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Tejun Heo <tj@kernel.org>, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, devel@openvz.org

Hi,

While trying to fulfill's Christoph's request for using static_branches
to do part of the role of number_of_cpusets in the cpuset cgroup, I took
a much more extensive look at the cpuset code (Thanks Christoph).

I started to feel that removing the cgroup_lock() from cpuset's
destroy is not as safe as I first imagined. At the very best, is not safe
enough to be bundled in a bugfix and deserves its own analysis.

I started then to consider another approach. While I voiced many times
that I would not like to do deferred updates for the static_branches, doing
that during destroy time would be perfectly acceptable IMHO (creation is
another story). In a summary, we are effectively calling the static_branch
updates only when the last reference to the memcg is gone. And that is
already asynchronous by nature, and we cope well with that.

In memcg, it turns out that we already do deferred freeing of the memcg
structure depending on the size of struct mem_cgroup.

My proposal is to always do that, and then we get a worker more or less
for free. Patch 3 is basically the same I had posted before, but without
the mutex lock protection, now in the static branch guaranteed interface.

Let me know if this is acceptable.

Thanks

Glauber Costa (3):
  make jump_labels wait while updates are in place
  Always free struct memcg through schedule_work()
  decrement static keys on real destroy time

 include/net/sock.h        |    9 ++++++++
 kernel/jump_label.c       |   13 ++++++++---
 mm/memcontrol.c           |   50 +++++++++++++++++++++++++++++++++-----------
 net/ipv4/tcp_memcontrol.c |   34 ++++++++++++++++++++++++------
 4 files changed, 82 insertions(+), 24 deletions(-)

-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
