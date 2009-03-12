Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1840E6B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:56:16 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp09.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2CHV5dA014281
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 23:01:05 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2CHqsCI3997940
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 23:22:54 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2CHu6ps020273
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 04:56:07 +1100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 12 Mar 2009 23:26:03 +0530
Message-Id: <20090312175603.17890.52593.sendpatchset@localhost.localdomain>
Subject: [PATCH 0/4] Memory controller soft limit patches (v5)
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


From: Balbir Singh <balbir@linux.vnet.ibm.com>

New Feature: Soft limits for memory resource controller.

Changelog v5...v4
1. Several changes to the reclaim logic, please see the patch 4 (reclaim on
   contention). I've experimented with several possibilities for reclaim
   and chose to come back to this due to the excellent behaviour seen while
   testing the patchset.
2. Reduced the overhead of soft limits on resource counters very significantly.
   Reaim benchmark now shows almost no drop in performance.

Changelog v4...v3
1. Adopted suggestions from Kamezawa to do a per-zone-per-node reclaim
   while doing soft limit reclaim. We don't record priorities while
   doing soft reclaim
2. Some of the overheads associated with soft limits (like calculating
   excess each time) is eliminated
3. The time_after(jiffies, 0) bug has been fixed
4. Tasks are throttled if the mem cgroup they belong to is being soft reclaimed
   and at the same time tasks are increasing the memory footprint and causing
   the mem cgroup to exceed its soft limit.

Changelog v3...v2
1. Implemented several review comments from Kosaki-San and Kamezawa-San
   Please see individual changelogs for changes

Changelog v2...v1
1. Soft limits now support hierarchies
2. Use spinlocks instead of mutexes for synchronization of the RB tree

Here is v5 of the new soft limit implementation. Soft limits is a new feature
for the memory resource controller, something similar has existed in the
group scheduler in the form of shares. The CPU controllers interpretation
of shares is very different though. 

Soft limits are the most useful feature to have for environments where
the administrator wants to overcommit the system, such that only on memory
contention do the limits become active. The current soft limits implementation
provides a soft_limit_in_bytes interface for the memory controller and not
for memory+swap controller. The implementation maintains an RB-Tree of groups
that exceed their soft limit and starts reclaiming from the group that
exceeds this limit by the maximum amount.

Kamezawa-San has another patchset for soft limits, but I don't like the reclaim logic of watermark based balancing of zones for global memory cgroup limits.
I also don't like the data structures, a list does not scale well. Kamezawa's
objection to this patch is the cost of sorting, which is really negligible,
since the updates happen at a fixed interval (curently four times a second).
I however do like the priority feature in Kamezawa's patchset. The feature
can be easily adopted to this incrementally.

TODOs

1. The current implementation maintains the delta from the soft limit
   and pushes back groups to their soft limits, a ratio of delta/soft_limit
   might be more useful
2. It would be nice to have more targetted reclaim (in terms of pages to
   recalim) interface. So that groups are pushed back, close to their soft
   limits.

Tests
-----

I've run two memory intensive workloads with differing soft limits and
seen that they are pushed back to their soft limit on contention. Their usage
was their soft limit plus additional memory that they were able to grab
on the system. Soft limit can take a while before we see the expected
results.

The other tests I've run are
1. Deletion of groups while soft limit is in progress in the hierarchy
2. Setting the soft limit to zero and running other groups with non-zero
   soft limits.
3. Setting the soft limit to zero and testing if the mem cgroup is able
   to use available memory

Please review, comment.

Series
------

memcg-soft-limit-documentation.patch
memcg-add-soft-limit-interface.patch
memcg-organize-over-soft-limit-groups.patch
memcg-soft-limit-reclaim-on-contention.patch



-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
