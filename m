Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id F2DE16B0088
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 13:48:02 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id i13so5390444qae.6
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 10:48:02 -0700 (PDT)
Received: from e8.ny.us.ibm.com (e8.ny.us.ibm.com. [32.97.182.138])
        by mx.google.com with ESMTPS id t11si29138071qgt.39.2014.07.21.10.48.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 10:48:02 -0700 (PDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Mon, 21 Jul 2014 13:48:02 -0400
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 9BE556E801A
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 13:47:48 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp23034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6LHlw4J1311204
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 17:47:58 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6LHlvsb008794
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 13:47:58 -0400
Date: Mon, 21 Jul 2014 10:47:54 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC Patch V1 28/30] mm: Update _mem_id_[] for every possible
 CPU when memory configuration changes
Message-ID: <20140721174754.GE4156@linux.vnet.ibm.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
 <1405064267-11678-29-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1405064267-11678-29-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

On 11.07.2014 [15:37:45 +0800], Jiang Liu wrote:
> Current kernel only updates _mem_id_[cpu] for onlined CPUs when memory
> configuration changes. So kernel may allocate memory from remote node
> for a CPU if the CPU is still in absent or offline state even if the
> node associated with the CPU has already been onlined.

This just sounds like the topology information is being updated at the
wrong place/time? That is, the memory is online, the CPU is being
brought online, but isn't associated with any node?

> This patch tries to improve performance by updating _mem_id_[cpu] for
> each possible CPU when memory configuration changes, thus kernel could
> always allocate from local node once the node is onlined.

Ok, what is the impact? Do you actually see better performance?

> We check node_online(cpu_to_node(cpu)) because:
> 1) local_memory_node(nid) needs to access NODE_DATA(nid)
> 2) try_offline_node(nid) just zeroes out NODE_DATA(nid) instead of free it
> 
> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
> ---
>  mm/page_alloc.c |   10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0ea758b898fd..de86e941ed57 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3844,13 +3844,13 @@ static int __build_all_zonelists(void *data)
>  		/*
>  		 * We now know the "local memory node" for each node--
>  		 * i.e., the node of the first zone in the generic zonelist.
> -		 * Set up numa_mem percpu variable for on-line cpus.  During
> -		 * boot, only the boot cpu should be on-line;  we'll init the
> -		 * secondary cpus' numa_mem as they come on-line.  During
> -		 * node/memory hotplug, we'll fixup all on-line cpus.
> +		 * Set up numa_mem percpu variable for all possible cpus
> +		 * if associated node has been onlined.
>  		 */
> -		if (cpu_online(cpu))
> +		if (node_online(cpu_to_node(cpu)))
>  			set_cpu_numa_mem(cpu, local_memory_node(cpu_to_node(cpu)));
> +		else
> +			set_cpu_numa_mem(cpu, NUMA_NO_NODE);
>  #endif


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
