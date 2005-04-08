Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j380dS5b329868
	for <linux-mm@kvack.org>; Thu, 7 Apr 2005 20:39:28 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j380dSQ0236586
	for <linux-mm@kvack.org>; Thu, 7 Apr 2005 18:39:28 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j380dRoN010710
	for <linux-mm@kvack.org>; Thu, 7 Apr 2005 18:39:27 -0600
Subject: Re: [ckrm-tech] [PATCH 2/6] CKRM: Core framework support
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050402031249.GC23284@chandralinux.beaverton.ibm.com>
References: <20050402031249.GC23284@chandralinux.beaverton.ibm.com>
Content-Type: text/plain
Date: Thu, 07 Apr 2005 17:39:22 -0700
Message-Id: <1112920762.21749.78.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chandra Seetharaman <sekharan@us.ibm.com>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

xOn Fri, 2005-04-01 at 19:12 -0800, Chandra Seetharaman wrote:
> +struct ckrm_mem_res {
...
> +       struct ckrm_zone ckrm_zone[MAX_NR_ZONES];

 static void
 mem_res_initcls_one(struct ckrm_mem_res *res)
 {
...
+       for_each_zone(zone) {
...
+               res->ckrm_zone[zindex].memcls = res;
+               zindex++;
+       }

MAX_NR_ZONES is actually the max number of *kinds* of zones.  It's the
maximum number of 'struct zones' that a single pg_data_t can have in its
node_zones[] array.  However, each DISCONTIG or NUMA node has one of
these arrays, and that's what for_each_zone() loops over: _all_ of the
system's zones, not just a single node's. See:

#define for_each_zone(zone) \
        for (zone = pgdat_list->node_zones; zone; zone = next_zone(zone))

Thus, the first call to mem_res_initcls_one() on a DISCONTIG or NUMA
system which has a non-node-zero node will overflow that array.

I saw some of this code before, and that's when I asked about the memory
controller's NUMA interaction.  I thought something was wrong, but I
couldn't put my finger on it.

I addition to these overflows, the same issue exists with results from
the page_zonenum() macro.  This badly named macro returns a "unique
identifier" for a node, not its index in its parent pg_data_t's
node_zones[] array (like the code expects).  So, on i386, a page on
node0[ZONE_NORMAL] will have a page_zonenum() of 1, node0[ZONE_HIGHMEM]
will be 2, node1[ZONE_DMA] will be 3, node100[ZONE_NORMAL] will be 301,
etc...

Indexing any array declared array[MAX_NR_ZONES=1] as array[301] is
likely to cause problems pretty fast.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
