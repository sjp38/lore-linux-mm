Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5CDAC831CD
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 06:07:50 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id o126so51827287pfb.2
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 03:07:50 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id g2si2966451plk.70.2017.03.08.03.07.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 03:07:49 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: Change generic FALLBACK zonelist creation process
References: <1d67f38b-548f-26a2-23f5-240d6747f286@linux.vnet.ibm.com>
 <20170308092146.5264-1-khandual@linux.vnet.ibm.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <0f787fb7-e299-9afb-8c87-4afdb937fdbb@nvidia.com>
Date: Wed, 8 Mar 2017 03:07:13 -0800
MIME-Version: 1.0
In-Reply-To: <20170308092146.5264-1-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu

On 03/08/2017 01:21 AM, Anshuman Khandual wrote:
> Kernel allocation to CDM node has already been prevented by putting it's
> entire memory in ZONE_MOVABLE. But the CDM nodes must also be isolated
> from implicit allocations happening on the system.
>
> Any isolation seeking CDM node requires isolation from implicit memory
> allocations from user space but at the same time there should also have
> an explicit way to do the memory allocation.
>
> Platform node's both zonelists are fundamental to where the memory comes
> from when there is an allocation request. In order to achieve these two
> objectives as stated above, zonelists building process has to change as
> both zonelists (i.e FALLBACK and NOFALLBACK) gives access to the node's
> memory zones during any kind of memory allocation. The following changes
> are implemented in this regard.
>
> * CDM node's zones are not part of any other node's FALLBACK zonelist
> * CDM node's FALLBACK list contains it's own memory zones followed by
>   all system RAM zones in regular order as before

There was a discussion, on an earlier version of this patchset, in which someone 
pointed out that a slight over-allocation on a device that has much more memory than 
the CPU has, could use up system memory. Your latest approach here does not address 
this.

I'm thinking that, until oversubscription between NUMA nodes is more fully 
implemented in a way that can be properly controlled, you'd probably better just not 
fallback to system memory. In other words, a CDM node really is *isolated* from 
other nodes--no automatic use in either direction.

Also, naming and purpose: maybe this is a "Limited NUMA Node", rather than a 
Coherent Device Memory node. Because: the real point of this thing is to limit the 
normal operation of NUMA, just enough to work with what I am *told* is 
memory-that-is-too-fragile-for-kernel-use (I remain soemwhat on the fence, there, 
even though you did talk me into it earlier, heh).

On process: it would probably help if you gathered up previous discussion points and 
carefully, concisely addressed each one, somewhere, (maybe in a cover letter). 
Because otherwise, it's too easy for earlier, important problems to be forgotten. 
And reviewers don't want to have to repeat themselves, of course.

thanks
John Hubbard
NVIDIA

> * CDM node's zones are part of it's own NOFALLBACK zonelist
>
> These above changes ensure the following which in turn isolates the CDM
> nodes as desired.
>
> * There wont be any implicit memory allocation ending up in the CDM node
> * Only __GFP_THISNODE marked allocations will come from the CDM node
> * CDM node memory can be allocated through mbind(MPOL_BIND) interface
> * System RAM memory will be used as fallback option in regular order in
>   case the CDM memory is insufficient during targted allocation request
>
> Sample zonelist configuration:
>
> [NODE (0)]						RAM
>         ZONELIST_FALLBACK (0xc00000000140da00)
>                 (0) (node 0) (DMA     0xc00000000140c000)
>                 (1) (node 1) (DMA     0xc000000100000000)
>         ZONELIST_NOFALLBACK (0xc000000001411a10)
>                 (0) (node 0) (DMA     0xc00000000140c000)
> [NODE (1)]						RAM
>         ZONELIST_FALLBACK (0xc000000100001a00)
>                 (0) (node 1) (DMA     0xc000000100000000)
>                 (1) (node 0) (DMA     0xc00000000140c000)
>         ZONELIST_NOFALLBACK (0xc000000100005a10)
>                 (0) (node 1) (DMA     0xc000000100000000)
> [NODE (2)]						CDM
>         ZONELIST_FALLBACK (0xc000000001427700)
>                 (0) (node 2) (Movable 0xc000000001427080)
>                 (1) (node 0) (DMA     0xc00000000140c000)
>                 (2) (node 1) (DMA     0xc000000100000000)
>         ZONELIST_NOFALLBACK (0xc00000000142b710)
>                 (0) (node 2) (Movable 0xc000000001427080)
> [NODE (3)]						CDM
>         ZONELIST_FALLBACK (0xc000000001431400)
>                 (0) (node 3) (Movable 0xc000000001430d80)
>                 (1) (node 0) (DMA     0xc00000000140c000)
>                 (2) (node 1) (DMA     0xc000000100000000)
>         ZONELIST_NOFALLBACK (0xc000000001435410)
>                 (0) (node 3) (Movable 0xc000000001430d80)
> [NODE (4)]						CDM
>         ZONELIST_FALLBACK (0xc00000000143b100)
>                 (0) (node 4) (Movable 0xc00000000143aa80)
>                 (1) (node 0) (DMA     0xc00000000140c000)
>                 (2) (node 1) (DMA     0xc000000100000000)
>         ZONELIST_NOFALLBACK (0xc00000000143f110)
>                 (0) (node 4) (Movable 0xc00000000143aa80)
>
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---
>  mm/page_alloc.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 40908de..6f7dddc 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4825,6 +4825,16 @@ static void build_zonelists(pg_data_t *pgdat)
>  	i = 0;
>
>  	while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
> +#ifdef CONFIG_COHERENT_DEVICE
> +		/*
> +		 * CDM node's own zones should not be part of any other
> +		 * node's fallback zonelist but only it's own fallback
> +		 * zonelist.
> +		 */
> +		if (is_cdm_node(node) && (pgdat->node_id != node))
> +			continue;
> +#endif
> +
>  		/*
>  		 * We don't want to pressure a particular node.
>  		 * So adding penalty to the first node in same
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
