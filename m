Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DDAEB6B0047
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 13:20:22 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp07.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2OHYY1l030588
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 04:34:34 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2OHYoMt1151222
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 04:34:52 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2OHYVJB006725
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 04:34:32 +1100
Date: Tue, 24 Mar 2009 23:04:14 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/5] Memory controller soft limit patches (v7)
Message-ID: <20090324173414.GB24227@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* Balbir Singh <balbir@linux.vnet.ibm.com> [2009-03-19 22:27:13]:

> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> New Feature: Soft limits for memory resource controller.
> 
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

I've run lmbench with the soft limit patches and the results show no
major overhead, there are some outliers and unexpected results.

The outliers are at context-switch 16p/64K, in communicating
latencies and some unexpected results where the softlimit changes help improve
performance (I consider these to be in the range of noise).

                 L M B E N C H  2 . 0   S U M M A R Y
                 ------------------------------------


Basic system parameters
----------------------------------------------------
Host                 OS Description              Mhz
                                                    
--------- ------------- ----------------------- ----
nosoftlim Linux 2.6.29-        x86_64-linux-gnu 2131
softlimit Linux 2.6.29-        x86_64-linux-gnu 2131

Processor, Processes - times in microseconds - smaller is better
----------------------------------------------------------------
Host                 OS  Mhz null null      open selct sig  sig  fork exec sh  
                             call  I/O stat clos TCP   inst hndl proc proc proc
--------- ------------- ---- ---- ---- ---- ---- ----- ---- ---- ----
---- ----
nosoftlim Linux 2.6.29- 2131 0.67 1.33 29.9 36.8 6.484 1.12 12.1 508. 1708 6281
softlimit Linux 2.6.29- 2131 0.66 1.31 29.8 36.8 6.486 1.11 12.3 483. 1697 6241

Context switching - times in microseconds - smaller is better
-------------------------------------------------------------
Host                 OS 2p/0K 2p/16K 2p/64K 8p/16K 8p/64K 16p/16K 16p/64K
                        ctxsw  ctxsw  ctxsw ctxsw  ctxsw   ctxsw ctxsw
--------- ------------- ----- ------ ------ ------ ------ --------------
nosoftlim Linux 2.6.29- 2.190 9.2300 3.1900 9.7400   10.8 7.93000 4.36000
softlimit Linux 2.6.29- 0.970 4.8200 3.1300 8.8900   10.3 8.82000 10.7

*Local* Communication latencies in microseconds - smaller is better
-------------------------------------------------------------------
Host                 OS 2p/0K  Pipe AF     UDP  RPC/   TCP  RPC/ TCP
                        ctxsw       UNIX         UDP         TCP conn
--------- ------------- ----- ----- ---- ----- ----- ----- ----- ----
nosoftlim Linux 2.6.29- 2.190  22.0 58.5  53.3  68.7  61.7  64.9 210.
softlimit Linux 2.6.29- 0.970  20.3 55.3  54.0  53.8  79.7  64.5 211.

File & VM system latencies in microseconds - smaller is better
--------------------------------------------------------------
Host                 OS   0K File      10K File      Mmap    Prot Page    
                        Create Delete Create Delete  Latency Fault Fault 
--------- ------------- ------ ------ ------ ------  ------- ----- ----- 
nosoftlim Linux 2.6.29-   51.6   48.6  153.6   87.4    20.2K 7.00000
softlimit Linux 2.6.29-   51.6   48.2  137.8   83.9    20.2K 6.00000

*Local* Communication bandwidths in MB/s - bigger is better
-----------------------------------------------------------
Host                OS  Pipe AF    TCP  File   Mmap  Bcopy  Bcopy  Mem
Mem
                             UNIX      reread reread (libc) (hand) read write
--------- ------------- ---- ---- ---- ------ ------ ------ ------ ---- -----
nosoftlim Linux 2.6.29- 1367 778. 803. 2058.5 4659.4 1303.9 1303.5 4664 1422.
softlimit Linux 2.6.29- 1314 823. 812. 2061.3 4659.9 1290.2 1280.9 4662 1422.

Memory latencies in nanoseconds - smaller is better
    (WARNING - may not be correct, check graphs)
---------------------------------------------------
Host                 OS   Mhz  L1 $   L2 $    Main mem    Guesses
--------- -------------  ---- ----- ------    --------    -------
nosoftlim Linux 2.6.29-  2131 1.875 6.5990   76.8
softlimit Linux 2.6.29-  2131 1.875 6.5980   76.8

Earlier, I ran reaim and saw no regression there as well.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
