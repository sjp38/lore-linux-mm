Date: Tue, 11 Sep 2007 10:15:16 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH -mm] mm: Fix memory hotplug + sparsemem build.
Message-ID: <20070911091516.GE6288@shadowen.org>
References: <20070911072507.GB19260@linux-sh.org> <20070911170921.F137.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070911170921.F137.Y-GOTO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Paul Mundt <lethal@linux-sh.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 11, 2007 at 05:18:01PM +0900, Yasunori Goto wrote:
> >  	if (onlined_pages)
> > -		node_set_state(zone->node, N_HIGH_MEMORY);
> > +		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
> >  
> >  	setup_per_zone_pages_min();
> 
> Thanks Paul-san. 
> 
> I also have another issue around here.
> (Kswapd doesn't run on memory less node now. It should run when
>  the node has memory.)
> 
> I would like to merge them like following if you don't mind.
> 
> 
> Bye.
> 
> ---
> 
> Fix kswapd doesn't run when memory is added on memory-less-node.
> Fix compile error of zone->node when CONFIG_NUMA is off.
> 
> Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
> Signed-off-by: Paul Mundt <lethal@linux-sh.org>
> 
> 
> ---
>  mm/memory_hotplug.c |    9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
> 
> Index: current/mm/memory_hotplug.c
> ===================================================================
> --- current.orig/mm/memory_hotplug.c	2007-09-07 18:08:07.000000000 +0900
> +++ current/mm/memory_hotplug.c	2007-09-11 17:29:19.000000000 +0900
> @@ -211,10 +211,12 @@ int online_pages(unsigned long pfn, unsi
>  		online_pages_range);
>  	zone->present_pages += onlined_pages;
>  	zone->zone_pgdat->node_present_pages += onlined_pages;
> -	if (onlined_pages)
> -		node_set_state(zone->node, N_HIGH_MEMORY);
>  
>  	setup_per_zone_pages_min();
> +	if (onlined_pages){

Nit, needs a space there before the '{'.

> +		kswapd_run(zone_to_nid(zone));
> +		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
> +	}
>  
>  	if (need_zonelists_rebuild)
>  		build_all_zonelists();
> @@ -269,9 +271,6 @@ int add_memory(int nid, u64 start, u64 s
>  		if (!pgdat)
>  			return -ENOMEM;
>  		new_pgdat = 1;
> -		ret = kswapd_run(nid);
> -		if (ret)
> -			goto error;
>  	}
>  
>  	/* call arch's memory hotadd */

The problem as I see it is that when we boot the system we start a
kswapd on all nodes with memory.  If the hot-add adds memory to a
pre-existing node with no memory we will not start one and we end up
with a node with memory and no kswapd.  Bad.

As kswapd_run is a no-op when a kswapd already exists this seems a safe
way to fix that.  Paul's ->zone conversion is obviously correct also.

Acked-by: Andy Whitcroft <apw@shadowen.org>

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
