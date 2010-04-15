Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C20B2600375
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:31:12 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 15 Apr 2010 13:30:36 -0400
Message-Id: <20100415173036.8801.29768.sendpatchset@localhost.localdomain>
In-Reply-To: <20100415172950.8801.60358.sendpatchset@localhost.localdomain>
References: <20100415172950.8801.60358.sendpatchset@localhost.localdomain>
Subject: [PATCH 7/8] numa: in-kernel profiling: use cpu_to_mem() for per cpu allocations
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andi@domain.invalid, Kleen@domain.invalid, andi@firstfloor.org, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Against:  2.6.34-rc3-mmotm-100405-1609

Patch:  in-kernel profiling -- support memoryless nodes.

In kernel profiling requires that we be able to allocate "local"
memory for each cpu.  Use "cpu_to_mem()" instead of "cpu_to_node()"
to support memoryless nodes.

Depends on the "numa_mem_id()" patch.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

---

New in V3.

V4: No change

 kernel/profile.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6.34-rc3-mmotm-100405-1609/kernel/profile.c
===================================================================
--- linux-2.6.34-rc3-mmotm-100405-1609.orig/kernel/profile.c	2010-04-07 10:04:02.000000000 -0400
+++ linux-2.6.34-rc3-mmotm-100405-1609/kernel/profile.c	2010-04-07 10:11:38.000000000 -0400
@@ -363,7 +363,7 @@ static int __cpuinit profile_cpu_callbac
 	switch (action) {
 	case CPU_UP_PREPARE:
 	case CPU_UP_PREPARE_FROZEN:
-		node = cpu_to_node(cpu);
+		node = cpu_to_mem(cpu);
 		per_cpu(cpu_profile_flip, cpu) = 0;
 		if (!per_cpu(cpu_profile_hits, cpu)[1]) {
 			page = alloc_pages_exact_node(node,
@@ -565,7 +565,7 @@ static int create_hash_tables(void)
 	int cpu;
 
 	for_each_online_cpu(cpu) {
-		int node = cpu_to_node(cpu);
+		int node = cpu_to_mem(cpu);
 		struct page *page;
 
 		page = alloc_pages_exact_node(node,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
