Subject: Re: [PATCH] change zonelist order v5 [3/3] documentation
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070508201904.0ee47ca2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070508201401.8f78ec37.kamezawa.hiroyu@jp.fujitsu.com>
	 <20070508201904.0ee47ca2.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 08 May 2007 13:08:55 -0400
Message-Id: <1178644135.5203.31.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, clameter@sgi.com, akpm@linux-foundation.org, ak@suse.de, jbarnes@virtuousgeek.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-05-08 at 20:19 +0900, KAMEZAWA Hiroyuki wrote:
> Patch for documentation.
> 
> Signed-Off-By: KAMEZAWA hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 

Will send followup patch with minor editorial changes.
Acked-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

> 
> ---
>  Documentation/kernel-parameters.txt |   10 +++++++
>  Documentation/sysctl/vm.txt         |   48 ++++++++++++++++++++++++++++++++++++
>  2 files changed, 58 insertions(+)
> 
> Index: linux-2.6.21-mm1/Documentation/kernel-parameters.txt
> ===================================================================
> --- linux-2.6.21-mm1.orig/Documentation/kernel-parameters.txt
> +++ linux-2.6.21-mm1/Documentation/kernel-parameters.txt
> @@ -1233,6 +1233,16 @@ and is between 256 and 4096 characters. 
>  
>  	nr_uarts=	[SERIAL] maximum number of UARTs to be registered.
>  
> +	numa_zonelist_oder= [KNL,BOOT]
> +			Select zonelist order for NUMA. zonelist is used for
> +			desiding where the kernel allocates memory from.
> +			Default is automatic configuration. If "node" is
> +			specified, zonelist is ordered by locality. This can
> +			offer the best locality but possibility of OOM may
> +			increase.  If "zone" is specified, the zonelist is
> +			ordered by zone_type.
> +			See Documentaion/sysctl/vm.txt numa_zonelist_order.
> +			
>  	opl3=		[HW,OSS]
>  			Format: <io>
>  
> Index: linux-2.6.21-mm1/Documentation/sysctl/vm.txt
> ===================================================================
> --- linux-2.6.21-mm1.orig/Documentation/sysctl/vm.txt
> +++ linux-2.6.21-mm1/Documentation/sysctl/vm.txt
> @@ -35,6 +35,7 @@ Currently, these files are in /proc/sys/
>  - stat_interval
>  - readahead_ratio
>  - readahead_hit_rate
> +- numa_zonelist_order
>  
>  ==============================================================
>  
> @@ -293,3 +294,49 @@ Possible values can be:
>  The larger value, the more capabilities, with more possible overheads.
>  
>  The default value is 1.
> +
> +==============================================================
> +
> +numa_zonelist_order
> +
> +This sysctl is only for NUMA.
> +'where the memory is allocated from' is controlled by zonelist.
> +(This documentation ignores ZONE_HIGHMEM/ZONE_DMA32 for simple explanation.
> + you may be able to read ZONE_DMA as ZONE_DMA32...)
> +
> +In non-NUMA case, a zonelist for GFP_KERNEL is ordered as following.
> +ZONE_NORMAL -> ZONE_DMA
> +This means that a memory allocation request for GFP_KERNEL will
> +get memory from ZONE_DMA only when ZONE_NORMAL is not available.
> +
> +In NUMA case, you can think of following 2 types of order.
> +Assume 2 node NUMA and below is zonelist of Node(0)'s GFP_KERNEL
> +
> +(A) Node(0) ZONE_NORMAL -> Node(0) ZONE_DMA -> Node(1) ZONE_NORMAL
> +(B) Node(0) ZONE_NORMAL -> Node(1) ZONE_NORMAL -> Node(0) ZONE_DMA.
> +
> +Type(A) offers the best locality for processes on Node(0), but ZONE_DMA
> +will be used before ZONE_NORMAL exhaustion. This increases possibility of
> +out-of-memory(OOM) of ZONE_DMA because ZONE_DMA is tend to be small.
> +
> +Type(B) cannot offer the best locality but very robust against OOM of DMA zone.
> +
> +Type(A) is called as "Node" order. Type (B) is "Zone" order.
> +
> +"Node order" orders the zonelists by node, then by zone within each node.
> +This will offer the best locality but increases possibility of OOM.
> +Specify "[Nn]ode" for zone order
> +
> +"Zone Order"  preserves the DMA zone as long as possible but
> +results in off-node allocation [for node 0] earlier.
> +Specify "[Zz]one"for zode order.
> +
> +Specify "[Dd]efault" to request automatic configuration.  Autoconfiguration
> +will select "node" order in following case.
> +(1) if the DMA zone does not exist or
> +(2) if the DMA zone comprises greater than 50% of the available memory or
> +(3) if a node's DMA zone comprises greater than 60% of its local memory and
> +    the amount of local memory is enough big.
> +
> +Otherwise, "zone" order will be selected. Default order is recommended unless
> +unless this is causing problems for your system/application.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
