Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 097E46B00F9
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 04:23:31 -0500 (EST)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp08.in.ibm.com (8.13.1/8.13.1) with ESMTP id n268ulmf009517
	for <linux-mm@kvack.org>; Fri, 6 Mar 2009 14:26:47 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n269KN7l3743788
	for <linux-mm@kvack.org>; Fri, 6 Mar 2009 14:50:23 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id n269NPTh013815
	for <linux-mm@kvack.org>; Fri, 6 Mar 2009 20:23:26 +1100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Fri, 06 Mar 2009 14:53:23 +0530
Message-Id: <20090306092323.21063.93169.sendpatchset@localhost.localdomain>
Subject: [PATCH 0/4] Memory controller soft limit patches (v4)
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


From: Balbir Singh <balbir@linux.vnet.ibm.com>

New Feature: Soft limits for memory resource controller.

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

Here is v4 of the new soft limit implementation. Soft limits is a new feature
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

If there are no major objections to the patches, I would like to get them
included in -mm.

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
