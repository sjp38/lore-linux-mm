Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 32CFD8D0041
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 05:41:03 -0400 (EDT)
Message-Id: <20110328093957.089007035@suse.cz>
Date: Mon, 28 Mar 2011 11:39:57 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 0/3] Implementation of cgroup isolation
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Hi all,

Memory cgroups can be currently used to throttle memory usage of a group of
processes. It, however, cannot be used for an isolation of processes from
the rest of the system because all the pages that belong to the group are
also placed on the global LRU lists and so they are eligible for the global
memory reclaim.

This patchset aims at providing an opt-in memory cgroup isolation. This
means that a cgroup can be configured to be isolated from the rest of the
system by means of cgroup virtual filesystem (/dev/memctl/group/memory.isolated).

Isolated mem cgroup can be particularly helpful in deployments where we have
a primary service which needs to have a certain guarantees for memory
resources (e.g. a database server) and we want to shield it off the
rest of the system (e.g. a burst memory activity in another group). This is
currently possible only with mlocking memory that is essential for the
application(s) or a rather hacky configuration where the primary app is in
the root mem cgroup while all the other system activity happens in other
groups.

mlocking is not an ideal solution all the time because sometimes the working
set is very large and it depends on the workload (e.g. number of incoming
requests) so it can end up not fitting in into memory (leading to a OOM
killer). If we use mem. cgroup isolation instead we are keeping memory resident
and if the working set goes wild we can still do per-cgroup reclaim so the
service is less prone to be OOM killed.

The patch series is split into 3 patches. First one adds a new flag into
mem_cgroup structure which controls whether the group is isolated (false by
default) and a cgroup fs interface to set it.
The second patch implements interaction with the global LRU. The current
semantic is that we are putting a page into a global LRU only if mem cgroup
LRU functions say they do not want the page for themselves.
The last patch prevents from soft reclaim if the group is isolated.

I have tested the patches with the simple memory consumer (allocating
private and shared anon memory and SYSV SHM). 

One instance (call it big consumer) running in the group and paging in the
memory (>90% of cgroup limit) and sleeping for the rest of its life. Then I
had a pool of consumers running in the same cgroup which page in smaller
amount of memory and paging them in the loop to simulate in group memory
pressure (call them sharks).
The sum of consumed memory is more than memory.limit_in_bytes so some
portion of the memory is swapped out.
There is one consumer running in the root cgroup running in parallel which
makes a pressure on the memory (to trigger background reclaim).

Rss+cache of the group drops down significantly (~66% of the limit) if the
group is not isolated. On the other hand if we isolate the group we are
still saturating the group (~97% of the limit). I can show more
comprehensive results if somebody is interested.

Thanks for comments.

---
 include/linux/memcontrol.h |   24 ++++++++------
 include/linux/mm_inline.h  |   10 ++++-
 mm/memcontrol.c            |   76 ++++++++++++++++++++++++++++++++++++---------
 mm/swap.c                  |   12 ++++---
 mm/vmscan.c                |   43 +++++++++++++++----------
 5 files changed, 118 insertions(+), 47 deletions(-)

-- 
Michal Hocko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
