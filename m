Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 23C6A8E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 08:29:30 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id f31so5560480edf.17
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 05:29:30 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a7si1036043edl.383.2018.12.17.05.29.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 05:29:28 -0800 (PST)
Date: Mon, 17 Dec 2018 14:29:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node
 offline
Message-ID: <20181217132926.GM30879@dhcp22.suse.cz>
References: <20181207113044.GB1286@dhcp22.suse.cz>
 <CAFgQCTuf95pJSWDc1BNQ=gN76aJ_dtxMRbAV9a28X6w8vapdMQ@mail.gmail.com>
 <20181207142240.GC1286@dhcp22.suse.cz>
 <CAFgQCTuu54oZWKq_ppEvZFb4Mz31gVmsa37gTap+e9KbE=T0aQ@mail.gmail.com>
 <20181207155627.GG1286@dhcp22.suse.cz>
 <20181210123738.GN1286@dhcp22.suse.cz>
 <CAFgQCTupPc1rKv2SrmWD+eJ0H6PRaizPBw3+AG67_PuLA2SKFw@mail.gmail.com>
 <20181212115340.GQ1286@dhcp22.suse.cz>
 <CAFgQCTuhW6sPtCNFmnz13p30v3owE3Rty5WJNgtqgz8XaZT-aQ@mail.gmail.com>
 <CAFgQCTtFZ8ku7W_7rcmrbmH4Qvsv7zgOSHKfPSpNSkVjYkPfBg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFgQCTtFZ8ku7W_7rcmrbmH4Qvsv7zgOSHKfPSpNSkVjYkPfBg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Thu 13-12-18 17:04:01, Pingfan Liu wrote:
[...]
> > > @@ -592,6 +600,10 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
> > >                         continue;
> > >
> > >                 alloc_node_data(nid);
> > > +               if (!end)
> > > +                       init_memory_less_node(nid);
> 
> Just have some opinion on this. Here is two issue. First, is this node
> online?


It shouldn't be as it doesn't have any memory.

> I do not see node_set_online() is called in this patch.

It is below for nodes with some memory.

> Second, if node is online here, then  init_memory_less_node->
> free_area_init_node is called duplicated when free_area_init_nodes().
> This should be a critical design issue.

I am still trying to wrap my head around the expected code flow here.
numa_init does the following for all CPUs within nr_cpu_ids (aka nr_cpus
aware).
		if (!node_online(nid))
			numa_clear_node(i);

I do not really understand why do we do this. But this enforces
init_cpu_to_node to do init_memory_less_node (with the current upstream
code) and that will mark the node online again and zonelists are built
properly. My patch couldn't help in that respect because the node is
offline (as it should be IMHO).

So let's try another attempt with some larger surgery (on top of the
previous patch). It will also dump the zonelist after it is built for
each node. Let's see whether something more is lurking there.

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index a5548fe668fb..eb7c905d5d86 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -525,19 +525,6 @@ static void __init numa_clear_kernel_node_hotplug(void)
 	}
 }
 
-static void __init init_memory_less_node(int nid)
-{
-	unsigned long zones_size[MAX_NR_ZONES] = {0};
-	unsigned long zholes_size[MAX_NR_ZONES] = {0};
-
-	free_area_init_node(nid, zones_size, 0, zholes_size);
-
-	/*
-	 * All zonelists will be built later in start_kernel() after per cpu
-	 * areas are initialized.
-	 */
-}
-
 static int __init numa_register_memblks(struct numa_meminfo *mi)
 {
 	unsigned long uninitialized_var(pfn_align);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5411de93a363..99252a0b6551 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2045,6 +2045,8 @@ extern void __init pagecache_init(void);
 extern void free_area_init(unsigned long * zones_size);
 extern void __init free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
+extern void init_memory_less_node(int nid);
+
 extern void free_initmem(void);
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2ec9cc407216..a5c035fd6307 100644
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
@@ -5447,6 +5454,20 @@ void __ref build_all_zonelists(pg_data_t *pgdat)
 #endif
 }
 
+void __init init_memory_less_node(int nid)
+{
+	unsigned long zones_size[MAX_NR_ZONES] = {0};
+	unsigned long zholes_size[MAX_NR_ZONES] = {0};
+
+	free_area_init_node(nid, zones_size, 0, zholes_size);
+	__build_all_zonelists(NODE_DATA(nid));
+
+	/*
+	 * All zonelists will be built later in start_kernel() after per cpu
+	 * areas are initialized.
+	 */
+}
+
 /* If zone is ZONE_MOVABLE but memory is mirrored, it is an overlapped init */
 static bool __meminit
 overlap_memmap_init(unsigned long zone, unsigned long *pfn)
-- 
Michal Hocko
SUSE Labs
