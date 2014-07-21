Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f50.google.com (mail-qa0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id 047106B0078
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 13:38:42 -0400 (EDT)
Received: by mail-qa0-f50.google.com with SMTP id s7so5508024qap.9
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 10:38:42 -0700 (PDT)
Received: from e7.ny.us.ibm.com (e7.ny.us.ibm.com. [32.97.182.137])
        by mx.google.com with ESMTPS id r8si30005173qar.32.2014.07.21.10.38.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 10:38:42 -0700 (PDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Mon, 21 Jul 2014 13:38:41 -0400
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 6AD9E38C8026
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 13:38:38 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp22033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6LHcc2j8913220
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 17:38:38 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6LHcaaX001973
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 13:38:37 -0400
Date: Mon, 21 Jul 2014 10:38:33 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC Patch V1 17/30] mm, intel_powerclamp: Use
 cpu_to_mem()/numa_mem_id() to support memoryless node
Message-ID: <20140721173833.GC4156@linux.vnet.ibm.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
 <1405064267-11678-18-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1405064267-11678-18-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Zhang Rui <rui.zhang@intel.com>, Eduardo Valentin <edubezval@gmail.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org

On 11.07.2014 [15:37:34 +0800], Jiang Liu wrote:
> When CONFIG_HAVE_MEMORYLESS_NODES is enabled, cpu_to_node()/numa_node_id()
> may return a node without memory, and later cause system failure/panic
> when calling kmalloc_node() and friends with returned node id.
> So use cpu_to_mem()/numa_mem_id() instead to get the nearest node with
> memory for the/current cpu.

You used the same changelog for all of the patches, it seems. But the
interface below (kthread_create_on_node) doesn't go into kmalloc_node?

kthread_create_on_node eventually sets the value used by
tsk_fork_get_node(), which is used by alloc_task_struct_node() and
alloc_thread_info_node(). The first uses kmem_cache_alloc_node() and the
second, depending on the relative sizes of THREAD_SIZE and PAGE_SIZE
uses either alloc_kmem_pages_node() or kmem_cache_alloc_node().
kmem_cache_alloc_node() goes into the appropriate slab allocator which
on SLUB for instance, goes down into __alloc_pages_nodemask. But no
failure occurs when memoryless nodes are present, you just get memory
that is remote from the node specified? Similarly,
alloc_kmem_pages_node() calls into __alloc_pages with an appropriate
node_zonelist, which should provide for the correct fallback based upon
NUMA topology?

What system failure/panic did you see that is resolved by this patch?

> If CONFIG_HAVE_MEMORYLESS_NODES is disabled, cpu_to_mem()/numa_mem_id()
> is the same as cpu_to_node()/numa_node_id().
> 
> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
> ---
>  drivers/thermal/intel_powerclamp.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/thermal/intel_powerclamp.c b/drivers/thermal/intel_powerclamp.c
> index 95cb7fc20e17..9d9be8cd1b50 100644
> --- a/drivers/thermal/intel_powerclamp.c
> +++ b/drivers/thermal/intel_powerclamp.c
> @@ -531,7 +531,7 @@ static int start_power_clamp(void)
> 
>  		thread = kthread_create_on_node(clamp_thread,
>  						(void *) cpu,
> -						cpu_to_node(cpu),
> +						cpu_to_mem(cpu),

As Tejun has pointed out elsewhere, we lose context here about the
original node we were running on. That information is relevant for a few
reasons:

1) In the underlying allocator, we might not have memory *right now* to
satisfy a request, which, say, causes us to deactivate a slab
(CONFIG_SLUB). But that condition may be relieved in the future and we
want to use the correct node again then.

2) For topologies that are symmetrical around a memoryless node, we
could lose the correct fallback information when we specify a nearest
neighbor with memory.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
