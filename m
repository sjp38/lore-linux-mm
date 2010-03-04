Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B45626B00A7
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 12:00:23 -0500 (EST)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 04 Mar 2010 12:08:36 -0500
Message-Id: <20100304170836.10606.40668.sendpatchset@localhost.localdomain>
In-Reply-To: <20100304170654.10606.32225.sendpatchset@localhost.localdomain>
References: <20100304170654.10606.32225.sendpatchset@localhost.localdomain>
Subject: [PATCH/RFC 8/8] numa:  in-kernel profiling -- support memoryless nodes
Sender: owner-linux-mm@kvack.org
To: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, akpm@linux-foundation.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

Against:  2.6.33-mmotm-100302-1838

Patch:  in-kernel profiling -- support memoryless nodes.

Another example of using numa_mem_id() to support memoryless
nodes efficiently.  I stumbled across this when trying to profile
the kernel in the memoryless nodes configuration.  A quick look
at other usages of numa_node_id() and cpu_to_node() for explicit
local allocations indicates that there are several other places
that could be problematic for systems with memoryless nodes that
can also be addressed with this simple substitution:

In-kernel profiling requires that we be able to allocate "local"
memory for each cpu.  Use "cpu_to_mem()" instead of "cpu_to_node()"
to support memoryless nodes.

Depends on the "numa_mem_id()" patch.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 kernel/profile.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6.33-mmotm-100302-1838/kernel/profile.c
===================================================================
--- linux-2.6.33-mmotm-100302-1838.orig/kernel/profile.c
+++ linux-2.6.33-mmotm-100302-1838/kernel/profile.c
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
