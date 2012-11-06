Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 16DF96B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 18:04:12 -0500 (EST)
Received: from /spool/local
	by e6.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Tue, 6 Nov 2012 18:04:10 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 1E0A96E803C
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 18:04:08 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA6N47uK321414
	for <linux-mm@kvack.org>; Tue, 6 Nov 2012 18:04:08 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA6N3vqB014229
	for <linux-mm@kvack.org>; Tue, 6 Nov 2012 16:03:58 -0700
Message-ID: <50999755.4000209@linux.vnet.ibm.com>
Date: Tue, 06 Nov 2012 15:03:49 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/8] mm: Introduce memory regions data-structure to
 capture region boundaries within node
References: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com> <20121106195225.6941.2868.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20121106195225.6941.2868.stgit@srivatsabhat.in.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/06/2012 11:52 AM, Srivatsa S. Bhat wrote:
> But of course, memory regions are sub-divisions *within* a node, so it makes
> sense to keep the data-structures in the node's struct pglist_data. (Thus
> this placement makes memory regions parallel to zones in that node).

I think it's pretty silly to create *ANOTHER* subdivision of memory
separate from sparsemem.  One that doesn't handle large amounts of
memory or scale with memory hotplug.  As it stands, you can only support
256*512MB=128GB of address space, which seems pretty puny.

This node_regions[]:

> @@ -687,6 +698,8 @@ typedef struct pglist_data {
>  	struct zone node_zones[MAX_NR_ZONES];
>  	struct zonelist node_zonelists[MAX_ZONELISTS];
>  	int nr_zones;
> +	struct node_mem_region node_regions[MAX_NR_REGIONS];
> +	int nr_node_regions;
>  #ifdef CONFIG_FLAT_NODE_MEM_MAP	/* means !SPARSEMEM */
>  	struct page *node_mem_map;
>  #ifdef CONFIG_MEMCG

looks like it's indexed the same way regardless of which node it is in.
 In other words, if there are two nodes, at least half of it is wasted,
and 3/4 if there are four nodes.  That seems a bit suboptimal.

Could you remind us of the logic for leaving sparsemem out of the
equation here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
