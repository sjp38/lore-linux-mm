Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 191808E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 09:34:44 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id m19so1703405edc.6
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 06:34:44 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m12si5093edc.331.2019.01.08.06.34.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 06:34:42 -0800 (PST)
Date: Tue, 8 Jan 2019 15:34:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node
 offline
Message-ID: <20190108143440.GU31793@dhcp22.suse.cz>
References: <CAFgQCTuu54oZWKq_ppEvZFb4Mz31gVmsa37gTap+e9KbE=T0aQ@mail.gmail.com>
 <20181207155627.GG1286@dhcp22.suse.cz>
 <20181210123738.GN1286@dhcp22.suse.cz>
 <CAFgQCTupPc1rKv2SrmWD+eJ0H6PRaizPBw3+AG67_PuLA2SKFw@mail.gmail.com>
 <20181212115340.GQ1286@dhcp22.suse.cz>
 <CAFgQCTuhW6sPtCNFmnz13p30v3owE3Rty5WJNgtqgz8XaZT-aQ@mail.gmail.com>
 <CAFgQCTtFZ8ku7W_7rcmrbmH4Qvsv7zgOSHKfPSpNSkVjYkPfBg@mail.gmail.com>
 <20181217132926.GM30879@dhcp22.suse.cz>
 <CAFgQCTubm9B1_zM+oc1GLfOChu+XY9N4OcjyeDgk6ggObRtMKg@mail.gmail.com>
 <20181220091934.GC14234@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181220091934.GC14234@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Thu 20-12-18 10:19:34, Michal Hocko wrote:
> On Thu 20-12-18 15:19:39, Pingfan Liu wrote:
> > Hi Michal,
> > 
> > WIth this patch applied on the old one, I got the following message.
> > Please get it from attachment.
> [...]
> > [    0.409637] NUMA: Node 1 [mem 0x00000000-0x0009ffff] + [mem 0x00100000-0x7fffffff] -> [mem 0x00000000-0x7fffffff]
> > [    0.419858] NUMA: Node 1 [mem 0x00000000-0x7fffffff] + [mem 0x100000000-0x47fffffff] -> [mem 0x00000000-0x47fffffff]
> > [    0.430356] NODE_DATA(0) allocated [mem 0x87efd4000-0x87effefff]
> > [    0.436325]     NODE_DATA(0) on node 5
> > [    0.440092] Initmem setup node 0 [mem 0x0000000000000000-0x0000000000000000]
> > [    0.447078] node[0] zonelist: 
> > [    0.450106] NODE_DATA(1) allocated [mem 0x47ffd5000-0x47fffffff]
> > [    0.456114] NODE_DATA(2) allocated [mem 0x87efa9000-0x87efd3fff]
> > [    0.462064]     NODE_DATA(2) on node 5
> > [    0.465852] Initmem setup node 2 [mem 0x0000000000000000-0x0000000000000000]
> > [    0.472813] node[2] zonelist: 
> > [    0.475846] NODE_DATA(3) allocated [mem 0x87ef7e000-0x87efa8fff]
> > [    0.481827]     NODE_DATA(3) on node 5
> > [    0.485590] Initmem setup node 3 [mem 0x0000000000000000-0x0000000000000000]
> > [    0.492575] node[3] zonelist: 
> > [    0.495608] NODE_DATA(4) allocated [mem 0x87ef53000-0x87ef7dfff]
> > [    0.501587]     NODE_DATA(4) on node 5
> > [    0.505349] Initmem setup node 4 [mem 0x0000000000000000-0x0000000000000000]
> > [    0.512334] node[4] zonelist: 
> > [    0.515370] NODE_DATA(5) allocated [mem 0x87ef28000-0x87ef52fff]
> > [    0.521384] NODE_DATA(6) allocated [mem 0x87eefd000-0x87ef27fff]
> > [    0.527329]     NODE_DATA(6) on node 5
> > [    0.531091] Initmem setup node 6 [mem 0x0000000000000000-0x0000000000000000]
> > [    0.538076] node[6] zonelist: 
> > [    0.541109] NODE_DATA(7) allocated [mem 0x87eed2000-0x87eefcfff]
> > [    0.547090]     NODE_DATA(7) on node 5
> > [    0.550851] Initmem setup node 7 [mem 0x0000000000000000-0x0000000000000000]
> > [    0.557836] node[7] zonelist: 
> 
> OK, so it is clear that building zonelists this early is not going to
> fly. We do not have the complete information yet. I am not sure when do
> we get that at this moment but I suspect the we either need to move that
> initialization to a sooner stage or we have to reconsider whether the
> phase when we build zonelists really needs to consider only online numa
> nodes.
> 
> [...]
> > [    1.067658] percpu: Embedded 46 pages/cpu @(____ptrval____) s151552 r8192 d28672 u262144
> > [    1.075692] node[1] zonelist: 1:Normal 1:DMA32 1:DMA 5:Normal 
> > [    1.081376] node[5] zonelist: 5:Normal 1:Normal 1:DMA32 1:DMA 
> 
> I hope to get to this before I leave for christmas vacation, if not I
> will stare into it after then.

I am sorry but I didn't get to this sooner. But I've got another idea. I
concluded that the whole dance is simply bogus and we should treat
memory less nodes, well, as nodes with no memory ranges rather than
special case them. Could you give the following a spin please?

---
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 1308f5408bf7..0e79445cfd85 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -216,8 +216,6 @@ static void __init alloc_node_data(int nid)
 
 	node_data[nid] = nd;
 	memset(NODE_DATA(nid), 0, sizeof(pg_data_t));
-
-	node_set_online(nid);
 }
 
 /**
@@ -535,6 +533,7 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
 	/* Account for nodes with cpus and no memory */
 	node_possible_map = numa_nodes_parsed;
 	numa_nodemask_from_meminfo(&node_possible_map, mi);
+	pr_info("parsed=%*pbl, possible=%*pbl\n", nodemask_pr_args(&numa_nodes_parsed), nodemask_pr_args(&node_possible_map));
 	if (WARN_ON(nodes_empty(node_possible_map)))
 		return -EINVAL;
 
@@ -570,7 +569,7 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
 		return -EINVAL;
 
 	/* Finally register nodes. */
-	for_each_node_mask(nid, node_possible_map) {
+	for_each_node_mask(nid, numa_nodes_parsed) {
 		u64 start = PFN_PHYS(max_pfn);
 		u64 end = 0;
 
@@ -581,9 +580,6 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
 			end = max(mi->blk[i].end, end);
 		}
 
-		if (start >= end)
-			continue;
-
 		/*
 		 * Don't confuse VM with a node that doesn't have the
 		 * minimum amount of memory:
@@ -592,6 +588,8 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
 			continue;
 
 		alloc_node_data(nid);
+		if (end)
+			node_set_online(nid);
 	}
 
 	/* Dump memblock with node info and return. */
@@ -721,21 +719,6 @@ void __init x86_numa_init(void)
 	numa_init(dummy_numa_init);
 }
 
-static void __init init_memory_less_node(int nid)
-{
-	unsigned long zones_size[MAX_NR_ZONES] = {0};
-	unsigned long zholes_size[MAX_NR_ZONES] = {0};
-
-	/* Allocate and initialize node data. Memory-less node is now online.*/
-	alloc_node_data(nid);
-	free_area_init_node(nid, zones_size, 0, zholes_size);
-
-	/*
-	 * All zonelists will be built later in start_kernel() after per cpu
-	 * areas are initialized.
-	 */
-}
-
 /*
  * Setup early cpu_to_node.
  *
@@ -763,9 +746,6 @@ void __init init_cpu_to_node(void)
 		if (node == NUMA_NO_NODE)
 			continue;
 
-		if (!node_online(node))
-			init_memory_less_node(node);
-
 		numa_set_node(cpu, node);
 	}
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2ec9cc407216..52e54d16662a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5234,6 +5234,8 @@ static void build_zonelists(pg_data_t *pgdat)
 	int node, load, nr_nodes = 0;
 	nodemask_t used_mask;
 	int local_node, prev_node;
+	struct zone *zone;
+	struct zoneref *z;
 
 	/* NUMA-aware ordering of nodes */
 	local_node = pgdat->node_id;
@@ -5259,6 +5261,11 @@ static void build_zonelists(pg_data_t *pgdat)
 
 	build_zonelists_in_node_order(pgdat, node_order, nr_nodes);
 	build_thisnode_zonelists(pgdat);
+
+	pr_info("node[%d] zonelist: ", pgdat->node_id);
+	for_each_zone_zonelist(zone, z, &pgdat->node_zonelists[ZONELIST_FALLBACK], MAX_NR_ZONES-1)
+		pr_cont("%d:%s ", zone_to_nid(zone), zone->name);
+	pr_cont("\n");
 }
 
 #ifdef CONFIG_HAVE_MEMORYLESS_NODES
@@ -5361,10 +5368,11 @@ static void __build_all_zonelists(void *data)
 	if (self && !node_online(self->node_id)) {
 		build_zonelists(self);
 	} else {
-		for_each_online_node(nid) {
+		for_each_node(nid) {
 			pg_data_t *pgdat = NODE_DATA(nid);
 
-			build_zonelists(pgdat);
+			if (pgdat)
+				build_zonelists(pgdat);
 		}
 
 #ifdef CONFIG_HAVE_MEMORYLESS_NODES
@@ -6644,10 +6652,8 @@ static unsigned long __init find_min_pfn_for_node(int nid)
 	for_each_mem_pfn_range(i, nid, &start_pfn, NULL, NULL)
 		min_pfn = min(min_pfn, start_pfn);
 
-	if (min_pfn == ULONG_MAX) {
-		pr_warn("Could not find start_pfn for node %d\n", nid);
+	if (min_pfn == ULONG_MAX)
 		return 0;
-	}
 
 	return min_pfn;
 }
@@ -6991,8 +6997,12 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 	mminit_verify_pageflags_layout();
 	setup_nr_node_ids();
 	zero_resv_unavail();
-	for_each_online_node(nid) {
+	for_each_node(nid) {
 		pg_data_t *pgdat = NODE_DATA(nid);
+
+		if (!pgdat)
+			continue;
+
 		free_area_init_node(nid, NULL,
 				find_min_pfn_for_node(nid), NULL);
 
-- 
Michal Hocko
SUSE Labs
