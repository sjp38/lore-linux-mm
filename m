Date: Fri, 24 Aug 2007 17:23:49 -0700
From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Subject: Re: [PATCH 1/6] x86: fix cpu_to_node references (v2)
Message-ID: <20070825002349.GB1894@linux-os.sc.intel.com>
References: <20070824222654.687510000@sgi.com> <20070824222948.587159000@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070824222948.587159000@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 24, 2007 at 03:26:55PM -0700, travis@sgi.com wrote:
> Fix four instances where cpu_to_node is referenced
> by array instead of via the cpu_to_node macro.  This
> is preparation to moving it to the per_cpu data area.
> 
...

>  unsigned long __init numa_free_all_bootmem(void) 
> --- a/arch/x86_64/mm/srat.c
> +++ b/arch/x86_64/mm/srat.c
> @@ -431,9 +431,9 @@
>  			setup_node_bootmem(i, nodes[i].start, nodes[i].end);
>  
>  	for (i = 0; i < NR_CPUS; i++) {
> -		if (cpu_to_node[i] == NUMA_NO_NODE)
> +		if (cpu_to_node(i) == NUMA_NO_NODE)
>  			continue;
> -		if (!node_isset(cpu_to_node[i], node_possible_map))
> +		if (!node_isset(cpu_to_node(i), node_possible_map))
>  			numa_set_node(i, NUMA_NO_NODE);
>  	}
>  	numa_init_array();

During this particular routine execution, per cpu areas are not yet setup. In
future, when we make cpu_to_node(i) use per cpu area, then this code will break.

And actually setup_per_cpu_areas() uses cpu_to_node(). So...

thanks,
suresh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
