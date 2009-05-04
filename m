Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C93FF6B003D
	for <linux-mm@kvack.org>; Sun,  3 May 2009 23:06:04 -0400 (EDT)
Subject: [PATCH] Limit initial tasks' and top level cpuset's mems_allowed
	to nodes with memory
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Reply-To: lts@ldl.fc.hp.com
Content-Type: text/plain
Date: Sun, 03 May 2009 23:06:04 -0400
Message-Id: <1241406364.9211.18.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, linux-numa <linux-numa@vger.kernel.org>, miaox@cn.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Doug Chapman <doug.chapman@hp.com>, Eric Whitney <eric.whitney@hp.com>, Bjorn Helgaas <bjorn.helgaas@hp.com>
List-ID: <linux-mm.kvack.org>


Against:  2.6.20-rc3-mmotm-090428-1631

Since cpusetmm-update-tasks-mems_allowed-in-time.patch removed the call outs
to cpuset_update_task_memory_state(), tasks in the top cpuset don't get their
mems_allowed updated to just nodes with memory.  cpuset_init()initializes
the top cpuset's mems_allowed with nodes_setall() and 
cpuset_init_current_mems_allowed() and kernel_init() initialize the kernel
initialization tasks' mems_allowed to all possible nodes.  Tasks in the top
cpuset that inherit the init task's mems_allowed without modification will
have all possible nodes set.  This can be seen by examining the Mems_allowed
field in /proc/<pid>/status in such a task.

"numactl --interleave=all" also initializes the interleave node mask to all
ones, depending on the masking with mems_allowed to eliminate non-existent
nodes and nodes without memory.  As this was not happening, the interleave
policy was attempting to dereference non-existent nodes.

This patch modifies the nodes_setall() calls in two cpuset init functions and
the initialization of task #1's mems_allowed to use node_states[N_HIGH_MEMORY]. 
This mask has been initialized to contain only existing nodes with memory by
the time the respective init functions are called.

This fixes the bogus pointer deref [Nat Consumption fault on ia64] reported
in:

	[BUG] 2.6.30-rc3-mmotm-090428-1814 -- bogus pointer deref

[The time--1814--was incorrect in that subject line, but the date was correct.]

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 init/main.c     |    4 ++--
 kernel/cpuset.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

Index: linux-2.6.30-rc3-mmotm-090428-1631/kernel/cpuset.c
===================================================================
--- linux-2.6.30-rc3-mmotm-090428-1631.orig/kernel/cpuset.c	2009-05-03 18:26:24.000000000 -0400
+++ linux-2.6.30-rc3-mmotm-090428-1631/kernel/cpuset.c	2009-05-03 20:46:04.000000000 -0400
@@ -1846,7 +1846,7 @@ int __init cpuset_init(void)
 		BUG();
 
 	cpumask_setall(top_cpuset.cpus_allowed);
-	nodes_setall(top_cpuset.mems_allowed);
+	top_cpuset.mems_allowed = node_states[N_HIGH_MEMORY];
 
 	fmeter_init(&top_cpuset.fmeter);
 	set_bit(CS_SCHED_LOAD_BALANCE, &top_cpuset.flags);
@@ -2118,7 +2118,7 @@ void cpuset_cpus_allowed_locked(struct t
 
 void cpuset_init_current_mems_allowed(void)
 {
-	nodes_setall(current->mems_allowed);
+	current->mems_allowed = node_states[N_HIGH_MEMORY];
 }
 
 /**
Index: linux-2.6.30-rc3-mmotm-090428-1631/init/main.c
===================================================================
--- linux-2.6.30-rc3-mmotm-090428-1631.orig/init/main.c	2009-05-03 20:46:04.000000000 -0400
+++ linux-2.6.30-rc3-mmotm-090428-1631/init/main.c	2009-05-03 20:54:03.000000000 -0400
@@ -849,9 +849,9 @@ static int __init kernel_init(void * unu
 	lock_kernel();
 
 	/*
-	 * init can allocate pages on any node
+	 * init can allocate pages on any node with memory
 	 */
-	set_mems_allowed(node_possible_map);
+	set_mems_allowed(node_states[N_HIGH_MEMORY]);
 	/*
 	 * init can run on any cpu.
 	 */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
