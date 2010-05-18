Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id EE5826B01D1
	for <linux-mm@kvack.org>; Tue, 18 May 2010 02:17:45 -0400 (EDT)
From: minskey guo <chaohong_guo@linux.intel.com>
Subject: [PATCH] online CPU before memory failed in pcpu_alloc_pages()
Date: Tue, 18 May 2010 14:17:22 +0800
Message-Id: <1274163442-7081-1-git-send-email-chaohong_guo@linux.intel.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: prarit@redhat.com, andi.kleen@intel.com, linux-kernel@vger.kernel.org, minskey guo <chaohong.guo@intel.com>
List-ID: <linux-mm.kvack.org>

From: minskey guo <chaohong.guo@intel.com>

The operation of "enable CPU to online before memory within a node"
fails in some case according to Prarit. The warnings as follows:

Pid: 7440, comm: bash Not tainted 2.6.32 #2
Call Trace:
 [<ffffffff81155985>] pcpu_alloc+0xa05/0xa70
 [<ffffffff81155a20>] __alloc_percpu+0x10/0x20
 [<ffffffff81089605>] __create_workqueue_key+0x75/0x280
 [<ffffffff8110e050>] ? __build_all_zonelists+0x0/0x5d0
 [<ffffffff810c1eba>] stop_machine_create+0x3a/0xb0
 [<ffffffff810c1f57>] stop_machine+0x27/0x60
 [<ffffffff8110f1a0>] build_all_zonelists+0xd0/0x2b0
 [<ffffffff814c1d12>] cpu_up+0xb3/0xe3
 [<ffffffff814b3c40>] store_online+0x70/0xa0
 [<ffffffff81326100>] sysdev_store+0x20/0x30
 [<ffffffff811d29a5>] sysfs_write_file+0xe5/0x170
 [<ffffffff81163d28>] vfs_write+0xb8/0x1a0
 [<ffffffff810cfd22>] ? audit_syscall_entry+0x252/0x280
 [<ffffffff81164761>] sys_write+0x51/0x90
 [<ffffffff81013132>] system_call_fastpath+0x16/0x1b
Built 4 zonelists in Zone order, mobility grouping on.  Total pages: 12331603
PERCPU: allocation failed, size=128 align=64, failed to populate

With "enable CPU to online before memory" patch, when the 1st CPU of
an offlined node is being onlined, we build zonelists for that node.
If per-cpu area needs to be extended during zonelists building period,
alloc_pages_node() will be called. The routine alloc_pages_node() fails
on the node in-onlining because the node doesn't have zonelists created
yet.

To fix this issue,  we try to alloc memory from current node.

Signed-off-by: minskey guo <chaohong.guo@intel.com>
---
 mm/percpu.c |   18 +++++++++++++++++-
 1 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 6e09741..fabdb10 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -714,13 +714,29 @@ static int pcpu_alloc_pages(struct pcpu_chunk *chunk,
 {
 	const gfp_t gfp = GFP_KERNEL | __GFP_HIGHMEM | __GFP_COLD;
 	unsigned int cpu;
+	int nid;
 	int i;
 
 	for_each_possible_cpu(cpu) {
 		for (i = page_start; i < page_end; i++) {
 			struct page **pagep = &pages[pcpu_page_idx(cpu, i)];
 
-			*pagep = alloc_pages_node(cpu_to_node(cpu), gfp, 0);
+			nid = cpu_to_node(cpu);
+
+			/*
+			 * It is allowable to online a CPU within a NUMA
+			 * node which doesn't have onlined local memory.
+			 * In this case, we need to create zonelists for
+			 * that node when cpu is being onlined. If per-cpu
+			 * area needs to be extended at the exact time when
+			 * zonelists of that node is being created, we alloc
+			 * memory from current node.
+			 */
+			if ((nid == -1) ||
+			    !(node_zonelist(nid, GFP_KERNEL)->_zonerefs->zone))
+				nid = numa_node_id();
+
+			*pagep = alloc_pages_node(nid, gfp, 0);
 			if (!*pagep) {
 				pcpu_free_pages(chunk, pages, populated,
 						page_start, page_end);
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
