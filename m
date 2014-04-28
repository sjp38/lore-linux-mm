Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 23DBD6B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 08:27:02 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id c41so4768682eek.8
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 05:27:01 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i49si22895841eem.282.2014.04.28.05.26.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 28 Apr 2014 05:27:00 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v2 0/4] memcg: Low-limit reclaim
Date: Mon, 28 Apr 2014 14:26:41 +0200
Message-Id: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hi,
previous discussions have shown that soft limits cannot be reformed
(http://lwn.net/Articles/555249/). This series introduces an alternative
approach for protecting memory allocated to processes executing within
a memory cgroup controller. It is based on a new tunable that was
discussed with Johannes and Tejun held during the kernel summit 2013 and
at LSF 2014.

This patchset introduces such low limit that is functionally similar
to a minimum guarantee. Memcgs which are under their lowlimit are not
considered eligible for the reclaim (both global and hardlimit) unless
all groups under the reclaimed hierarchy are below the low limit when
all of them are considered eligible.

The previous version of the patchset posted as a RFC
(http://marc.info/?l=linux-mm&m=138677140628677&w=2) suggested a
hard guarantee without any fallback. More discussions led me to
reconsidering the default behavior and come up a more relaxed one. The
hard requirement can be added later based on a use case which really
requires. It would be controlled by memory.reclaim_flags knob which
would specify whether to OOM or fallback (default) when all groups are
bellow low limit.

The default value of the limit is 0 so all groups are eligible by
default and an interested party has to explicitly set the limit.

The primary use case is to protect an amount of memory allocated to a
workload without it being reclaimed by an unrelated activity. In some
cases this requirement can be fulfilled by mlock but it is not suitable
for many loads and generally requires application awareness. Such
application awareness can be complex. It effectively forbids the
use of memory overcommit as the application must explicitly manage
memory residency.
With the low limit, such workloads can be placed in a memcg with a low
limit that protects the estimated working set.

The hierarchical behavior of the lowlimit is described in the first
patch. 
The second patch allows setting the lowlimit.
The last 2 patches clarify documentation about the memcg reclaim in
gereneral (3rd patch) and low limit (4th patch).

There were some calls for using a different name but I couldn't come up
with something better so if there are a better proposals I am happy to
change this.

The series is based on top of the current mmotm tree. Once the series
gets accepted I will post a patch which will mark the soft limit as
deprecated with a note that it will be eventually dropped. Let me know
if you would prefer to have such a patch a part of the series.

Thoughts?

Short log says:
Michal Hocko (4):
      memcg, mm: introduce lowlimit reclaim
      memcg: Allow setting low_limit
      memcg, doc: clarify global vs. limit reclaims
      memcg: Document memory.low_limit_in_bytes

And diffstat says:
 Documentation/cgroups/memory.txt | 40 +++++++++++++++++++++-----------
 include/linux/memcontrol.h       |  9 ++++++++
 include/linux/res_counter.h      | 40 ++++++++++++++++++++++++++++++++
 kernel/res_counter.c             |  2 ++
 mm/memcontrol.c                  | 50 +++++++++++++++++++++++++++++++++++++++-
 mm/vmscan.c                      | 34 ++++++++++++++++++++++++++-
 6 files changed, 159 insertions(+), 16 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
