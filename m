Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E68F46B009F
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 00:25:23 -0400 (EDT)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2N5NFtf013632
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 10:53:15 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2N5N8T4319678
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 10:53:08 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2N5MxWG006936
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 16:22:59 +1100
Date: Mon, 23 Mar 2009 10:52:47 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/5] Memory controller soft limit patches (v7)
Message-ID: <20090323052247.GJ24227@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain> <20090323125005.0d8a7219.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090323125005.0d8a7219.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-23 12:50:05]:

> On Thu, 19 Mar 2009 22:27:13 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > 
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> > New Feature: Soft limits for memory resource controller.
> > 
> > Changelog v7...v6
> > 1. Added checks in reclaim path to make sure we don't infinitely loop
> > 2. Refactored reclaim options into a new patch
> > 3. Tested several scenarios, see tests below
> > 
> > Changelog v6...v5
> > 1. If the number of reclaimed pages are zero, select the next mem cgroup
> >    for reclamation
> > 2. Fixed a bug, where key was being updated after insertion into the tree
> > 3. Fixed a build issue, when CONFIG_MEM_RES_CTLR is not enabled
> > 
> > Changelog v5...v4
> > 1. Several changes to the reclaim logic, please see the patch 4 (reclaim on
> >    contention). I've experimented with several possibilities for reclaim
> >    and chose to come back to this due to the excellent behaviour seen while
> >    testing the patchset.
> > 2. Reduced the overhead of soft limits on resource counters very significantly.
> >    Reaim benchmark now shows almost no drop in performance.
> > 
> > Changelog v4...v3
> > 1. Adopted suggestions from Kamezawa to do a per-zone-per-node reclaim
> >    while doing soft limit reclaim. We don't record priorities while
> >    doing soft reclaim
> > 2. Some of the overheads associated with soft limits (like calculating
> >    excess each time) is eliminated
> > 3. The time_after(jiffies, 0) bug has been fixed
> > 4. Tasks are throttled if the mem cgroup they belong to is being soft reclaimed
> >    and at the same time tasks are increasing the memory footprint and causing
> >    the mem cgroup to exceed its soft limit.
> > 
> > Changelog v3...v2
> > 1. Implemented several review comments from Kosaki-San and Kamezawa-San
> >    Please see individual changelogs for changes
> > 
> > Changelog v2...v1
> > 1. Soft limits now support hierarchies
> > 2. Use spinlocks instead of mutexes for synchronization of the RB tree
> > 
> > Here is v7 of the new soft limit implementation. Soft limits is a new feature
> > for the memory resource controller, something similar has existed in the
> > group scheduler in the form of shares. The CPU controllers interpretation
> > of shares is very different though. 
> > 
> > Soft limits are the most useful feature to have for environments where
> > the administrator wants to overcommit the system, such that only on memory
> > contention do the limits become active. The current soft limits implementation
> > provides a soft_limit_in_bytes interface for the memory controller and not
> > for memory+swap controller. The implementation maintains an RB-Tree of groups
> > that exceed their soft limit and starts reclaiming from the group that
> > exceeds this limit by the maximum amount.
> > 
> > So far I have the best test results with this patchset. I've experimented with
> > several approaches and methods. I might be a little delayed in responding,
> > I might have intermittent access to the internet for the next few days.
> > 
> > TODOs
> > 
> > 1. The current implementation maintains the delta from the soft limit
> >    and pushes back groups to their soft limits, a ratio of delta/soft_limit
> >    might be more useful
> > 
> > 
> > Tests
> > -----
> > 
> > I've run two memory intensive workloads with differing soft limits and
> > seen that they are pushed back to their soft limit on contention. Their usage
> > was their soft limit plus additional memory that they were able to grab
> > on the system. Soft limit can take a while before we see the expected
> > results.
> > 
> > The other tests I've run are
> > 1. Deletion of groups while soft limit is in progress in the hierarchy
> > 2. Setting the soft limit to zero and running other groups with non-zero
> >    soft limits.
> > 3. Setting the soft limit to zero and testing if the mem cgroup is able
> >    to use available memory
> > 4. Tested the patches with hierarchy enabled
> > 5. Tested with swapoff -a, to make sure we don't go into an infinite loop
> > 
> > Please review, comment.
> > 
> 
> please add text to explain the behaior, what happens in the following situation.
> 
> 
>    /group_A .....softlimit=100M usage=ANON=1G,FILE=1M
>    /group_B .....softlimit=200M usage=ANON=1G,FILE=1M
>    /group_C .....softlimit=300M
>    on swap-available/swap-less/swap-full system.
> 
>   And Run run "dd" or "cp" of big files under group_C.

That depends on the memory on the system, on my system with 4G, things
run just fine.

I tried the following

        /group_A soft_limit=100M, needed memory=3200M (allocate and touch)
        /group_B soft_limit=200M, needed memory=3200M
        /group_C soft_limit=300M, needed memory=1024M (dd in a while loop)

group_B and group_A had a difference of 200M in their allocations on
average. group_C touched 800M as maximum usage in bytes and around
500M on the average.

With swap turned off

group_C was hit the most with a lot of reclaim taking place on it.
group_A was OOM killed and immediately after group_B got all the
memory it needed and completed successfully.

I have one large swap partition, so I could not test the partial-swap
scenario.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
