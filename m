Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id B0A156B0035
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 09:16:42 -0500 (EST)
Received: by mail-ee0-f50.google.com with SMTP id c41so2898831eek.23
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 06:16:42 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id 5si19197373eei.249.2013.12.11.06.16.41
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 06:16:42 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 0/4] memcg: Low-limit reclaim
Date: Wed, 11 Dec 2013 15:15:51 +0100
Message-Id: <1386771355-21805-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>

Hi,
previous discussions have shown that soft limits cannot be reformed
(http://lwn.net/Articles/555249/). This series introduces an alternative
approach to protecting memory allocated to processes executing within
a memory cgroup controller. It is based on a new tunable that was
discussed with Johannes and Tejun held during the last kernel summit.

This patchset introduces such low limit that is functionally similar to a
minimum guarantee. Memcgs which are under their lowlimit are not considered
eligible for the reclaim (both global and hardlimit). The default value of
the limit is 0 so all groups are eligible by default and an interested
party has to explicitly set the limit.

The primary use case is to protect an amount of memory allocated to a
workload without it being reclaimed by an unrelated activity. In some
cases this requirement can be fulfilled by mlock but it is not suitable
for many loads and generally requires application awareness. Such
application awareness can be complex. It effectively forbids the
use of memory overcommit as the application must explicitly manage
memory residency.
With low limits, such workloads can be placed in a memcg with a low
limit that protects the estimated working set.

Another use case might be unreclaimable groups. Some loads might be so
sensitive to reclaim that it is better to kill and start it again (or
since checkpoint) rather than trash. This would be trivial with low
limit set to unlimited and the OOM killer will handle the situation as
required (e.g. kill and restart).

The hierarchical behavior of the lowlimit is described in the first
patch. It is followed by a direct reclaim fix which is necessary to
handle situation when a no group is eligible because all groups are
below low limit. This is not a big deal for hardlimit reclaim because
we simply retry the reclaim few times and then trigger memcg OOM killer
path. It would blow up in the global case when we would loop without
doing any progress or trigger OOM killer. I would consider configuration
leading to this state invalid but we should handle that gracefully.

The third patch finally allows setting the lowlimit.

The last patch tries expedites OOM if it is clear that no group is
eligible for reclaim. It basically breaks out of loops in the direct
reclaim and lets kswapd sleep because it wouldn't do any progress anyway.

Thoughts?

Short log says:
Michal Hocko (4):
      memcg, mm: introduce lowlimit reclaim
      mm, memcg: allow OOM if no memcg is eligible during direct reclaim
      memcg: Allow setting low_limit
      mm, memcg: expedite OOM if no memcg is reclaimable

And a diffstat
 include/linux/memcontrol.h  | 14 +++++++++++
 include/linux/res_counter.h | 40 ++++++++++++++++++++++++++++++
 kernel/res_counter.c        |  2 ++
 mm/memcontrol.c             | 60 ++++++++++++++++++++++++++++++++++++++++++++-
 mm/vmscan.c                 | 59 +++++++++++++++++++++++++++++++++++++++++---
 5 files changed, 170 insertions(+), 5 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
