Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E657F6B01B9
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 02:46:46 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2T6khrX027756
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 29 Mar 2010 15:46:43 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D7FE45DE52
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 15:46:43 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id F10FB45DE4F
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 15:46:42 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D1FEBE18005
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 15:46:42 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7479AE18003
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 15:46:42 +0900 (JST)
Date: Mon, 29 Mar 2010 15:42:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] memcg documentaion update
Message-Id: <20100329154245.455227d9.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

At reading Documentation/cgroup/memory.txt, I felt

 - old
 - hard to find it's supported what I want to do

Hmm..maybe some rewrite will be necessary.

==
Documentation update. We have too much files now....

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/memory.txt |   48 ++++++++++++++++++++++++++++++---------
 1 file changed, 38 insertions(+), 10 deletions(-)

Index: mmotm-2.6.34-Mar24/Documentation/cgroups/memory.txt
===================================================================
--- mmotm-2.6.34-Mar24.orig/Documentation/cgroups/memory.txt
+++ mmotm-2.6.34-Mar24/Documentation/cgroups/memory.txt
@@ -4,16 +4,6 @@ NOTE: The Memory Resource Controller has
 to as the memory controller in this document. Do not confuse memory controller
 used here with the memory controller that is used in hardware.
 
-Salient features
-
-a. Enable control of Anonymous, Page Cache (mapped and unmapped) and
-   Swap Cache memory pages.
-b. The infrastructure allows easy addition of other types of memory to control
-c. Provides *zero overhead* for non memory controller users
-d. Provides a double LRU: global memory pressure causes reclaim from the
-   global LRU; a cgroup on hitting a limit, reclaims from the per
-   cgroup LRU
-
 Benefits and Purpose of the memory controller
 
 The memory controller isolates the memory behaviour of a group of tasks
@@ -33,6 +23,44 @@ d. A CD/DVD burner could control the amo
 e. There are several other use cases, find one or use the controller just
    for fun (to learn and hack on the VM subsystem).
 
+Current Status: linux-2.6.34-mmotom(2010/March)
+
+Features:
+ - accounting anonymous pages, file caches, swap caches usage and limit them.
+ - private LRU and reclaim routine. (system's global LRU and private LRU
+   work independently from each other)
+ - optionaly, memory+swap usage
+ - hierarchical accounting
+ - softlimit
+ - moving(recharging) account at moving a task
+ - usage threshold notifier
+ - oom-killer disable and oom-notifier
+ - Root cgroup has no limit controls.
+
+ Kernel memory and Hugepages are not under control yet. We just manage
+ pages on LRU. To add more controls, we have to take care of performance.
+
+Brief summary of control files.
+
+ tasks				# attach a task(thread)
+ cgroup.procs			# attach a process(all threads under it)
+ cgroup.event_control		# an interface for event_fd()
+ memory.usage_in_bytes		# show current memory(RSS+Cache) usage.
+ memory.memsw.usage_in_bytes	# show current memory+Swap usage.
+ memory.limit_in_bytes		# set/show limit of memory usage
+ memory.memsw.limit_in_bytes	# set/show limit of memory+Swap usage.
+ memory.failcnt			# show the number of memory usage hit limits.
+ memory.memsw.failcnt		# show the number of memory+Swap hit limits.
+ memory.max_usage_in_bytes	# show max memory usage recorded.
+ memory.memsw.usage_in_bytes	# show max memory+Swap usage recorded.
+ memory.stat			# show various statistics.
+ memory.use_hierarchy		# set/show hierarchical account enabled.
+ memory.force_empty		# trigger forced move charge to parent.
+ memory.swappiness		# set/show swappiness parameter of vmscan
+ 				  (See sysctl's vm.swappiness)
+ memory.move_charge_at_immigrate# set/show controls of moving charges
+ memory.oom_control		# set/show oom controls.
+
 1. History
 
 The memory controller has a long history. A request for comments for the memory

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
