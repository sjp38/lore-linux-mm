Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 49C196B0031
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 14:08:49 -0500 (EST)
Received: by mail-ie0-f180.google.com with SMTP id at1so2496706iec.39
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 11:08:49 -0800 (PST)
Received: from mail-ie0-x249.google.com (mail-ie0-x249.google.com [2607:f8b0:4001:c03::249])
        by mx.google.com with ESMTPS id l1si31289233igx.29.2014.01.29.11.08.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Jan 2014 11:08:48 -0800 (PST)
Received: by mail-ie0-f201.google.com with SMTP id tp5so460985ieb.0
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 11:08:48 -0800 (PST)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [RFC 0/4] memcg: Low-limit reclaim
References: <1386771355-21805-1-git-send-email-mhocko@suse.cz>
Date: Wed, 29 Jan 2014 11:08:46 -0800
In-Reply-To: <1386771355-21805-1-git-send-email-mhocko@suse.cz> (Michal
	Hocko's message of "Wed, 11 Dec 2013 15:15:51 +0100")
Message-ID: <xr93sis6obb5.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>

On Wed, Dec 11 2013, Michal Hocko wrote:

> Hi,
> previous discussions have shown that soft limits cannot be reformed
> (http://lwn.net/Articles/555249/). This series introduces an alternative
> approach to protecting memory allocated to processes executing within
> a memory cgroup controller. It is based on a new tunable that was
> discussed with Johannes and Tejun held during the last kernel summit.
>
> This patchset introduces such low limit that is functionally similar to a
> minimum guarantee. Memcgs which are under their lowlimit are not considered
> eligible for the reclaim (both global and hardlimit). The default value of
> the limit is 0 so all groups are eligible by default and an interested
> party has to explicitly set the limit.
>
> The primary use case is to protect an amount of memory allocated to a
> workload without it being reclaimed by an unrelated activity. In some
> cases this requirement can be fulfilled by mlock but it is not suitable
> for many loads and generally requires application awareness. Such
> application awareness can be complex. It effectively forbids the
> use of memory overcommit as the application must explicitly manage
> memory residency.
> With low limits, such workloads can be placed in a memcg with a low
> limit that protects the estimated working set.
>
> Another use case might be unreclaimable groups. Some loads might be so
> sensitive to reclaim that it is better to kill and start it again (or
> since checkpoint) rather than trash. This would be trivial with low
> limit set to unlimited and the OOM killer will handle the situation as
> required (e.g. kill and restart).
>
> The hierarchical behavior of the lowlimit is described in the first
> patch. It is followed by a direct reclaim fix which is necessary to
> handle situation when a no group is eligible because all groups are
> below low limit. This is not a big deal for hardlimit reclaim because
> we simply retry the reclaim few times and then trigger memcg OOM killer
> path. It would blow up in the global case when we would loop without
> doing any progress or trigger OOM killer. I would consider configuration
> leading to this state invalid but we should handle that gracefully.
>
> The third patch finally allows setting the lowlimit.
>
> The last patch tries expedites OOM if it is clear that no group is
> eligible for reclaim. It basically breaks out of loops in the direct
> reclaim and lets kswapd sleep because it wouldn't do any progress anyway.
>
> Thoughts?
>
> Short log says:
> Michal Hocko (4):
>       memcg, mm: introduce lowlimit reclaim
>       mm, memcg: allow OOM if no memcg is eligible during direct reclaim
>       memcg: Allow setting low_limit
>       mm, memcg: expedite OOM if no memcg is reclaimable
>
> And a diffstat
>  include/linux/memcontrol.h  | 14 +++++++++++
>  include/linux/res_counter.h | 40 ++++++++++++++++++++++++++++++
>  kernel/res_counter.c        |  2 ++
>  mm/memcontrol.c             | 60 ++++++++++++++++++++++++++++++++++++++++++++-
>  mm/vmscan.c                 | 59 +++++++++++++++++++++++++++++++++++++++++---
>  5 files changed, 170 insertions(+), 5 deletions(-)

The series looks useful.  We (Google) have been using something similar.
In practice such a low_limit (or memory guarantee), doesn't nest very
well.

Example:
  - parent_memcg: limit 500, low_limit 500, usage 500
    1 privately charged non-reclaimable page (e.g. mlock, slab)
  - child_memcg: limit 500, low_limit 500, usage 499

If a streaming file cache workload (e.g. sha1sum) starts gobbling up
page cache it will lead to an oom kill instead of reclaiming.  One could
argue that this is working as intended because child_memcg was promised
500 but can only get 499.  So child_memcg is oom killed rather than
being forced to operate below its promised low limit.

This has led to various internal workarounds like:
- don't charge any memory to interior tree nodes (e.g. parent_memcg);
  only charge memory to cgroup leafs.  This gets tricky when dealing
  with reparented memory inherited to parent from child during cgroup
  deletion.
- don't set low_limit on non leafs (e.g. do not set low limit on
  parent_memcg).  This constrains the cgroup layout a bit.  Some
  customers want to purchase $MEM and setup their workload with a few
  child cgroups.  A system daemon hands out $MEM by setting low_limit
  for top-level containers (e.g. parent_memcg).  Thereafter such
  customers are able to partition their workload with sub memcg below
  child_memcg.  Example:
     parent_memcg
         \
          child_memcg
            /     \
        server   backup
  Thereafter customers often want some weak isolation between server and
  backup.  To avoid undesired oom kills the server/backup isolation is
  provided with a softer memory guarantee (e.g. soft_limit).  The soft
  limit acts like the low_limit until priority becomes desperate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
