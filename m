Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 543CB6B0068
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 07:02:15 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 0/2] Avoiding expensive reference counting in charge page path
Date: Tue, 14 Aug 2012 14:58:31 +0400
Message-Id: <1344941913-15075-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Frederic Weisbecker <fweisbec@gmail.com>

Hi,

In my last submission for the kmem controller for memcg, Kame noted that the
way we use to guarantee that the memcg will still be around while there are
charges is quite expensive: we issue mem_cgroup_get() in every charge, that is
countered by mem_cgroup_put() in every uncharge.

I am trying an alternate way through the two patches that follow. The idea is to
only call mem_cgroup_get() when the first charge happens. We'll use a bit in the
kmem_accounted bitmap for that: we have plenty.

We allow the allocations to continue paying only the cost of a likely branch
over a simple test after that. We also note through another bit the destruction
of that group. When charges get down to 0 after destruction, we then proceed
to release the reference.

I am sending those two patches separately so they get reviewed on their own.
If nobody opposes, I'll add them ontop of the current kmem patches.

Thanks.

Glauber Costa (2):
  return amount of charges after res_counter_uncharge
  Avoid doing a get/put pair in every kmemcg charge

 Documentation/cgroups/resource_counter.txt |  7 ++--
 include/linux/res_counter.h                | 12 ++++---
 kernel/res_counter.c                       | 20 +++++++----
 mm/memcontrol.c                            | 57 ++++++++++++++++++++++++++----
 4 files changed, 74 insertions(+), 22 deletions(-)

-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
