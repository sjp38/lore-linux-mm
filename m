Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 81D666B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 20:25:17 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so119089167pab.0
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 17:25:17 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id x5si27114401pdr.77.2015.08.17.17.25.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Aug 2015 17:25:16 -0700 (PDT)
Received: by pacgr6 with SMTP id gr6so119010908pac.2
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 17:25:16 -0700 (PDT)
Date: Mon, 17 Aug 2015 17:25:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Patch V3 3/9] sgi-xp: Replace cpu_to_node() with cpu_to_mem()
 to support memoryless node
In-Reply-To: <1439781546-7217-4-git-send-email-jiang.liu@linux.intel.com>
Message-ID: <alpine.DEB.2.10.1508171723290.5527@chino.kir.corp.google.com>
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com> <1439781546-7217-4-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, Cliff Whickman <cpw@sgi.com>, Robin Holt <robinmholt@gmail.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

On Mon, 17 Aug 2015, Jiang Liu wrote:

> Function xpc_create_gru_mq_uv() allocates memory with __GFP_THISNODE
> flag set, which may cause permanent memory allocation failure on
> memoryless node. So replace cpu_to_node() with cpu_to_mem() to better
> support memoryless node. For node with memory, cpu_to_mem() is the same
> as cpu_to_node().
> 
> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
> ---
>  drivers/misc/sgi-xp/xpc_uv.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/misc/sgi-xp/xpc_uv.c b/drivers/misc/sgi-xp/xpc_uv.c
> index 95c894482fdd..9210981c0d5b 100644
> --- a/drivers/misc/sgi-xp/xpc_uv.c
> +++ b/drivers/misc/sgi-xp/xpc_uv.c
> @@ -238,7 +238,7 @@ xpc_create_gru_mq_uv(unsigned int mq_size, int cpu, char *irq_name,
>  
>  	mq->mmr_blade = uv_cpu_to_blade_id(cpu);
>  
> -	nid = cpu_to_node(cpu);
> +	nid = cpu_to_mem(cpu);
>  	page = alloc_pages_exact_node(nid,
>  				      GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE,
>  				      pg_order);

Why not simply fix build_zonelists_node() so that the __GFP_THISNODE 
zonelists are set up to reference the zones of cpu_to_mem() for memoryless 
nodes?

It seems much better than checking and maintaining every __GFP_THISNODE 
user to determine if they are using a memoryless node or not.  I don't 
feel that this solution is maintainable in the longterm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
