Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id C31AF6B000D
	for <linux-mm@kvack.org>; Sat, 26 May 2018 21:06:56 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 31-v6so5400252plf.19
        for <linux-mm@kvack.org>; Sat, 26 May 2018 18:06:56 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id z14-v6si21275203pgv.514.2018.05.26.18.06.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 May 2018 18:06:55 -0700 (PDT)
Subject: [PATCH 2/2] x86/numa_emulation: Introduce uniform split capability
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 26 May 2018 17:56:57 -0700
Message-ID: <152738261787.11641.828328345742419506.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152738260746.11641.13275998345345705617.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152738260746.11641.13275998345345705617.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@kernel.org
Cc: Wei Yang <richard.weiyang@gmail.com>, David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.orgx86@kernel.org

The current numa emulation capabilities for splitting System RAM by a
fixed size or by a set number of nodes may result in some nodes being
larger than others. The implementation prioritizes establishing a
minimum usable memory size over satisfying the requested number of numa
nodes.

Introduce a uniform split capability that evenly partitions each
physical numa node into N emulated nodes. For example numa=fake=3U
creates 6 emulated nodes total on a system that has 2 physical nodes.

This capability is useful for debugging and evaluating platform
memory-side-cache capabilities as described by the ACPI HMAT (see
5.2.27.5 Memory Side Cache Information Structure in ACPI 6.2a)

Compare numa=fake=6 that results in only 5 nodes being created against
numa=fake=3U which takes the 2 physical nodes and evenly divides them.

numa=fake=6
available: 5 nodes (0-4)
node 0 cpus: 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38
node 0 size: 2648 MB
node 0 free: 2443 MB
node 1 cpus: 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39
node 1 size: 2672 MB
node 1 free: 2442 MB
node 2 cpus: 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38
node 2 size: 5291 MB
node 2 free: 5278 MB
node 3 cpus: 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39
node 3 size: 2677 MB
node 3 free: 2665 MB
node 4 cpus: 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39
node 4 size: 2676 MB
node 4 free: 2663 MB
node distances:
node   0   1   2   3   4
  0:  10  20  10  20  20
  1:  20  10  20  10  10
  2:  10  20  10  20  20
  3:  20  10  20  10  10
  4:  20  10  20  10  10


numa=fake=3U
# numactl --hardware
available: 6 nodes (0-5)
node 0 cpus: 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38
node 0 size: 2900 MB
node 0 free: 2637 MB
node 1 cpus: 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38
node 1 size: 3023 MB
node 1 free: 3012 MB
node 2 cpus: 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38
node 2 size: 2015 MB
node 2 free: 2004 MB
node 3 cpus: 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39
node 3 size: 2704 MB
node 3 free: 2522 MB
node 4 cpus: 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39
node 4 size: 2709 MB
node 4 free: 2698 MB
node 5 cpus: 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39
node 5 size: 2612 MB
node 5 free: 2601 MB
node distances:
node   0   1   2   3   4   5
  0:  10  10  10  20  20  20
  1:  10  10  10  20  20  20
  2:  10  10  10  20  20  20
  3:  20  20  20  10  10  10
  4:  20  20  20  10  10  10
  5:  20  20  20  10  10  10

Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: <x86@kernel.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 Documentation/x86/x86_64/boot-options.txt |    4 +
 arch/x86/mm/numa_emulation.c              |   96 +++++++++++++++++++++++------
 2 files changed, 81 insertions(+), 19 deletions(-)

diff --git a/Documentation/x86/x86_64/boot-options.txt b/Documentation/x86/x86_64/boot-options.txt
index b297c48389b9..d1332609a17e 100644
--- a/Documentation/x86/x86_64/boot-options.txt
+++ b/Documentation/x86/x86_64/boot-options.txt
@@ -156,6 +156,10 @@ NUMA
 		If given as an integer, fills all system RAM with N fake nodes
 		interleaved over physical nodes.
 
+  numa=fake=<N>U
+		If given as an integer followed by 'U', it will divide each
+		physical node into N emulated nodes.
+
 ACPI
 
   acpi=off	Don't enable ACPI
diff --git a/arch/x86/mm/numa_emulation.c b/arch/x86/mm/numa_emulation.c
index 22cbad56acab..039db00541b7 100644
--- a/arch/x86/mm/numa_emulation.c
+++ b/arch/x86/mm/numa_emulation.c
@@ -204,34 +204,58 @@ static u64 __init find_end_of_node(u64 start, u64 max_addr, u64 size)
  *
  * Returns zero on success or negative on error.
  */
-static int __init split_nodes_size_interleave(struct numa_meminfo *ei,
+static int __init split_nodes_size_interleave_uniform(struct numa_meminfo *ei,
 					      struct numa_meminfo *pi,
-					      u64 addr, u64 max_addr, u64 size)
+					      u64 addr, u64 max_addr, u64 size,
+					      int nr_nodes, struct numa_memblk *pblk,
+					      int nid)
 {
 	nodemask_t physnode_mask = numa_nodes_parsed;
+	int i, ret, uniform = 0;
 	u64 min_size;
-	int nid = 0;
-	int i, ret;
 
-	if (!size)
+	if ((!size && !nr_nodes) || (nr_nodes && !pblk))
 		return -1;
+
 	/*
-	 * The limit on emulated nodes is MAX_NUMNODES, so the size per node is
-	 * increased accordingly if the requested size is too small.  This
-	 * creates a uniform distribution of node sizes across the entire
-	 * machine (but not necessarily over physical nodes).
+	 * In the 'uniform' case split the passed in physical node by
+	 * nr_nodes, in the non-uniform case, ignore the passed in
+	 * physical block and try to create nodes of at least size
+	 * @size.
+	 *
+	 * In the uniform case, split the nodes strictly by physical
+	 * capacity, i.e. ignore holes. In the non-uniform case account
+	 * for holes and treat @size as a minimum floor.
 	 */
-	min_size = (max_addr - addr - mem_hole_size(addr, max_addr)) / MAX_NUMNODES;
-	min_size = max(min_size, FAKE_NODE_MIN_SIZE);
-	if ((min_size & FAKE_NODE_MIN_HASH_MASK) < min_size)
-		min_size = (min_size + FAKE_NODE_MIN_SIZE) &
-						FAKE_NODE_MIN_HASH_MASK;
+	if (!nr_nodes)
+		nr_nodes = MAX_NUMNODES;
+	else {
+		nodes_clear(physnode_mask);
+		node_set(pblk->nid, physnode_mask);
+		uniform = 1;
+	}
+
+	if (uniform) {
+		min_size = (max_addr - addr) / nr_nodes;
+		size = min_size;
+	} else {
+		/*
+		 * The limit on emulated nodes is MAX_NUMNODES, so the
+		 * size per node is increased accordingly if the
+		 * requested size is too small.  This creates a uniform
+		 * distribution of node sizes across the entire machine
+		 * (but not necessarily over physical nodes).
+		 */
+		min_size = (max_addr - addr - mem_hole_size(addr, max_addr))
+			/ nr_nodes;
+	}
+	min_size = ALIGN(max(min_size, FAKE_NODE_MIN_SIZE), FAKE_NODE_MIN_SIZE);
 	if (size < min_size) {
 		pr_err("Fake node size %LuMB too small, increasing to %LuMB\n",
 			size >> 20, min_size >> 20);
 		size = min_size;
 	}
-	size &= FAKE_NODE_MIN_HASH_MASK;
+	size = ALIGN_DOWN(size, FAKE_NODE_MIN_SIZE);
 
 	/*
 	 * Fill physical nodes with fake nodes of size until there is no memory
@@ -248,10 +272,14 @@ static int __init split_nodes_size_interleave(struct numa_meminfo *ei,
 				node_clear(i, physnode_mask);
 				continue;
 			}
+
 			start = pi->blk[phys_blk].start;
 			limit = pi->blk[phys_blk].end;
 
-			end = find_end_of_node(start, limit, size);
+			if (uniform)
+				end = start + size;
+			else
+				end = find_end_of_node(start, limit, size);
 			/*
 			 * If there won't be at least FAKE_NODE_MIN_SIZE of
 			 * non-reserved memory in ZONE_DMA32 for the next node,
@@ -266,7 +294,8 @@ static int __init split_nodes_size_interleave(struct numa_meminfo *ei,
 			 * next node, this one must extend to the end of the
 			 * physical node.
 			 */
-			if (limit - end - mem_hole_size(end, limit) < size)
+			if ((limit - end - mem_hole_size(end, limit) < size)
+					&& !uniform)
 				end = limit;
 
 			ret = emu_setup_memblk(ei, pi, nid++ % MAX_NUMNODES,
@@ -276,7 +305,15 @@ static int __init split_nodes_size_interleave(struct numa_meminfo *ei,
 				return ret;
 		}
 	}
-	return 0;
+	return nid;
+}
+
+static int __init split_nodes_size_interleave(struct numa_meminfo *ei,
+					      struct numa_meminfo *pi,
+					      u64 addr, u64 max_addr, u64 size)
+{
+	return split_nodes_size_interleave_uniform(ei, pi, addr, max_addr, size,
+			0, NULL, NUMA_NO_NODE);
 }
 
 int __init setup_emu2phys_nid(int *dfl_phys_nid)
@@ -346,7 +383,28 @@ void __init numa_emulation(struct numa_meminfo *numa_meminfo, int numa_dist_cnt)
 	 * the fixed node size.  Otherwise, if it is just a single number N,
 	 * split the system RAM into N fake nodes.
 	 */
-	if (strchr(emu_cmdline, 'M') || strchr(emu_cmdline, 'G')) {
+	if (strchr(emu_cmdline, 'U')) {
+		nodemask_t physnode_mask = numa_nodes_parsed;
+		unsigned long n;
+		int nid = 0;
+
+		n = simple_strtoul(emu_cmdline, &emu_cmdline, 0);
+		ret = -1;
+		for_each_node_mask(i, physnode_mask) {
+			ret = split_nodes_size_interleave_uniform(&ei, &pi,
+					pi.blk[i].start, pi.blk[i].end, 0,
+					n, &pi.blk[i], nid);
+			if (ret < 0)
+				break;
+			if (ret < n) {
+				pr_info("%s: phys: %d only got %d of %ld nodes, failing\n",
+						__func__, i, ret, n);
+				ret = -1;
+				break;
+			}
+			nid = ret;
+		}
+	} else if (strchr(emu_cmdline, 'M') || strchr(emu_cmdline, 'G')) {
 		u64 size;
 
 		size = memparse(emu_cmdline, &emu_cmdline);
