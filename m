Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 66AC66B008A
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 13:52:52 -0400 (EDT)
Received: by mail-ie0-f173.google.com with SMTP id tr6so7170187ieb.18
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 10:52:52 -0700 (PDT)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id m11si47524228icl.74.2014.07.21.10.52.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 10:52:51 -0700 (PDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Mon, 21 Jul 2014 11:52:50 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 7CE4119D804E
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 11:52:38 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6LHpFvs11075978
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 19:51:15 +0200
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6LHqkrv006770
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 11:52:48 -0600
Date: Mon, 21 Jul 2014 10:52:41 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC Patch V1 22/30] mm, of: Use cpu_to_mem()/numa_mem_id() to
 support memoryless node
Message-ID: <20140721175241.GF4156@linux.vnet.ibm.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
 <1405064267-11678-23-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1405064267-11678-23-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Grant Likely <grant.likely@linaro.org>, Rob Herring <robh+dt@kernel.org>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, devicetree@vger.kernel.org

On 11.07.2014 [15:37:39 +0800], Jiang Liu wrote:
> When CONFIG_HAVE_MEMORYLESS_NODES is enabled, cpu_to_node()/numa_node_id()
> may return a node without memory, and later cause system failure/panic
> when calling kmalloc_node() and friends with returned node id.
> So use cpu_to_mem()/numa_mem_id() instead to get the nearest node with
> memory for the/current cpu.
> 
> If CONFIG_HAVE_MEMORYLESS_NODES is disabled, cpu_to_mem()/numa_mem_id()
> is the same as cpu_to_node()/numa_node_id().
> 
> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
> ---
>  drivers/of/base.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/of/base.c b/drivers/of/base.c
> index b9864806e9b8..40d4772973ad 100644
> --- a/drivers/of/base.c
> +++ b/drivers/of/base.c
> @@ -85,7 +85,7 @@ EXPORT_SYMBOL(of_n_size_cells);
>  #ifdef CONFIG_NUMA
>  int __weak of_node_to_nid(struct device_node *np)
>  {
> -	return numa_node_id();
> +	return numa_mem_id();
>  }
>  #endif

Um, NAK. of_node_to_nid() returns the NUMA node ID for a given device
tree node. The default should be the physically local NUMA node, not the
nearest memory-containing node.

I think the general direction of this patchset is good -- what NUMA
information do we actually are about at each callsite. But the execution
is blind and doesn't consider at all what the code is actually doing.
The changelogs are all identical and don't actually provide any
information about what errors this (or any) specific patch are
resolving.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
