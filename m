Subject: Re: [PATCH] 2.6.23-rc3-mm1 - Move setup of N_CPU node state mask
From: Mel Gorman <mel@csn.ul.ie>
In-Reply-To: <1187971760.5869.22.camel@localhost>
References: <20070727194316.18614.36380.sendpatchset@localhost>
	 <20070727194322.18614.68855.sendpatchset@localhost>
	 <20070731192241.380e93a0.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com>
	 <20070731200522.c19b3b95.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com>
	 <20070731203203.2691ca59.akpm@linux-foundation.org>
	 <1185977011.5059.36.camel@localhost>
	 <Pine.LNX.4.64.0708011037510.20795@schroedinger.engr.sgi.com>
	 <1186085994.5040.98.camel@localhost>
	 <Pine.LNX.4.64.0708021323390.9711@schroedinger.engr.sgi.com>
	 <1186611582.5055.95.camel@localhost>
	 <Pine.LNX.4.64.0708081638270.17335@schroedinger.engr.sgi.com>
	 <1187971760.5869.22.camel@localhost>
Content-Type: text/plain
Date: Thu, 06 Sep 2007 14:56:56 +0100
Message-Id: <1189087016.3834.12.camel@machina.109elm.lan>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-08-24 at 12:09 -0400, Lee Schermerhorn wrote:
> Saw this while looking at "[BUG] 2.6.23-rc3-mm1 kernel BUG at
> mm/page_alloc.c:2876!".  Not sure it matters, as apparently, failure to
> kmalloc() the zone pcp will bug out later anyway.
> 

If the failure path is entered, my expectation is that the CPU would not
appear otherwise active. I'm not convinced the old code is wrong.

> Lee
> --------------------------
> 
> [PATCH] Move setup of N_CPU node state mask
> 
> Against:  2.6.23-rc3-mm1
> 
> Move recording of nodes w/ cpus to before zone loop.
> Otherwise, error exit could skip setup of N_CPU mask.  
> 
> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
> 
>  mm/page_alloc.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6.23-rc3-mm1/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.23-rc3-mm1.orig/mm/page_alloc.c	2007-08-22 10:08:00.000000000 -0400
> +++ linux-2.6.23-rc3-mm1/mm/page_alloc.c	2007-08-22 10:08:44.000000000 -0400
> @@ -2793,6 +2793,8 @@ static int __cpuinit process_zones(int c
>  	struct zone *zone, *dzone;
>  	int node = cpu_to_node(cpu);
>  
> +	node_set_state(node, N_CPU);	/* this node has a cpu */
> +
>  	for_each_zone(zone) {
>  
>  		if (!populated_zone(zone))
> @@ -2810,7 +2812,6 @@ static int __cpuinit process_zones(int c
>  			 	(zone->present_pages / percpu_pagelist_fraction));
>  	}
>  
> -	node_set_state(node, N_CPU);
>  	return 0;
>  bad:
>  	for_each_zone(dzone) {
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
