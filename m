Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 09AF86B00B2
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 03:32:08 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2N8XBN7007312
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 23 Mar 2009 17:33:11 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 05CA045DD7B
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 17:33:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D59CD45DD78
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 17:33:10 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BF2C3E08004
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 17:33:10 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 781ECE08002
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 17:33:10 +0900 (JST)
Date: Mon, 23 Mar 2009 17:31:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/5] Memory controller soft limit patches (v7)
Message-Id: <20090323173145.c80e353e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Mar 2009 22:27:13 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> New Feature: Soft limits for memory resource controller.
> 

Hmm, did you test against _slow_ workload ?

I tried this. My system with 2cpus. 1.6GB of memory.

create 2 cgroups A and B. Assume allocate 1G of ANON in B.
and run kernel-make in group A. (%make -j 4)

0. echo 3 > /proc/sys/drop_caches.
1. set A's softlimit to 300M.
2. alloc memory 1GB in group B.
3. run %make -j 4 in group A.
  => 250MB of memory are swapeed-out from B.

0. echo 3 > /proc/sys/drop_caches.
1. set A's softlimit to 10GB (never reach this.)
2. alloc memory 1GB in group B.
3. run %make -j 4 in group A.
  => 350MB of memory are swapeed-out from B.


Is this enough to your purpose ? 250MB of swap-out is too much....
(the number can be changed depends on enviroment.)
 
Thanks,
-Kame


> Changelog v7...v6
> 1. Added checks in reclaim path to make sure we don't infinitely loop
> 2. Refactored reclaim options into a new patch
> 3. Tested several scenarios, see tests below
> 
> Changelog v6...v5
> 1. If the number of reclaimed pages are zero, select the next mem cgroup
>    for reclamation
> 2. Fixed a bug, where key was being updated after insertion into the tree
> 3. Fixed a build issue, when CONFIG_MEM_RES_CTLR is not enabled
> 
> Changelog v5...v4
> 1. Several changes to the reclaim logic, please see the patch 4 (reclaim on
>    contention). I've experimented with several possibilities for reclaim
>    and chose to come back to this due to the excellent behaviour seen while
>    testing the patchset.
> 2. Reduced the overhead of soft limits on resource counters very significantly.
>    Reaim benchmark now shows almost no drop in performance.
> 
> Changelog v4...v3
> 1. Adopted suggestions from Kamezawa to do a per-zone-per-node reclaim
>    while doing soft limit reclaim. We don't record priorities while
>    doing soft reclaim
> 2. Some of the overheads associated with soft limits (like calculating
>    excess each time) is eliminated
> 3. The time_after(jiffies, 0) bug has been fixed
> 4. Tasks are throttled if the mem cgroup they belong to is being soft reclaimed
>    and at the same time tasks are increasing the memory footprint and causing
>    the mem cgroup to exceed its soft limit.
> 
> Changelog v3...v2
> 1. Implemented several review comments from Kosaki-San and Kamezawa-San
>    Please see individual changelogs for changes
> 
> Changelog v2...v1
> 1. Soft limits now support hierarchies
> 2. Use spinlocks instead of mutexes for synchronization of the RB tree
> 
> Here is v7 of the new soft limit implementation. Soft limits is a new feature
> for the memory resource controller, something similar has existed in the
> group scheduler in the form of shares. The CPU controllers interpretation
> of shares is very different though. 
> 
> Soft limits are the most useful feature to have for environments where
> the administrator wants to overcommit the system, such that only on memory
> contention do the limits become active. The current soft limits implementation
> provides a soft_limit_in_bytes interface for the memory controller and not
> for memory+swap controller. The implementation maintains an RB-Tree of groups
> that exceed their soft limit and starts reclaiming from the group that
> exceeds this limit by the maximum amount.
> 
> So far I have the best test results with this patchset. I've experimented with
> several approaches and methods. I might be a little delayed in responding,
> I might have intermittent access to the internet for the next few days.
> 
> TODOs
> 
> 1. The current implementation maintains the delta from the soft limit
>    and pushes back groups to their soft limits, a ratio of delta/soft_limit
>    might be more useful
> 
> 
> Tests
> -----
> 
> I've run two memory intensive workloads with differing soft limits and
> seen that they are pushed back to their soft limit on contention. Their usage
> was their soft limit plus additional memory that they were able to grab
> on the system. Soft limit can take a while before we see the expected
> results.
> 
> The other tests I've run are
> 1. Deletion of groups while soft limit is in progress in the hierarchy
> 2. Setting the soft limit to zero and running other groups with non-zero
>    soft limits.
> 3. Setting the soft limit to zero and testing if the mem cgroup is able
>    to use available memory
> 4. Tested the patches with hierarchy enabled
> 5. Tested with swapoff -a, to make sure we don't go into an infinite loop
> 
> Please review, comment.
> 
> Series
> ------
> 
> 
> memcg-soft-limits-documentation.patch
> memcg-soft-limits-interface.patch
> memcg-soft-limits-organize.patch
> memcg-soft-limits-refactor-reclaim-bits
> memcg-soft-limits-reclaim-on-contention.patch
> 
> 
> -- 
> 	Balbir
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
