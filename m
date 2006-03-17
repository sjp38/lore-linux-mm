Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k2HHKIQu005363
	for <linux-mm@kvack.org>; Fri, 17 Mar 2006 12:20:18 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k2HHK8R5174986
	for <linux-mm@kvack.org>; Fri, 17 Mar 2006 12:20:08 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k2HHK7IY012435
	for <linux-mm@kvack.org>; Fri, 17 Mar 2006 12:20:08 -0500
Subject: Re: [PATCH: 009/017]Memory hotplug for new nodes v.4.(add return
	code init_currently_empty_zone)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060317163404.C649.Y-GOTO@jp.fujitsu.com>
References: <20060317163404.C649.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain
Date: Fri, 17 Mar 2006 09:19:11 -0800
Message-Id: <1142615951.10906.70.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-03-17 at 17:22 +0900, Yasunori Goto wrote:
> --- pgdat8.orig/mm/memory_hotplug.c	2006-03-16 16:05:38.000000000 +0900
> +++ pgdat8/mm/memory_hotplug.c	2006-03-16 16:45:30.000000000 +0900
> @@ -26,16 +26,23 @@
>  
>  extern void zonetable_add(struct zone *zone, int nid, int zid, unsigned long pfn,
>  			  unsigned long size);
> -static void __add_zone(struct zone *zone, unsigned long phys_start_pfn)
> +static int __add_zone(struct zone *zone, unsigned long phys_start_pfn)
>  {
>  	struct pglist_data *pgdat = zone->zone_pgdat;
>  	int nr_pages = PAGES_PER_SECTION;
>  	int nid = pgdat->node_id;
>  	int zone_type;
> +	int ret = 0;
>  
>  	zone_type = zone - pgdat->node_zones;
> +	if (!populated_zone(zone)) {
> +		ret = init_currently_empty_zone(zone, phys_start_pfn, nr_pages);
> +		if (ret < 0)
> +			return ret;
> +	}
>  	memmap_init_zone(nr_pages, nid, zone_type, phys_start_pfn);
>  	zonetable_add(zone, nid, zone_type, phys_start_pfn, nr_pages);
> +	return 0;
>  }

Minor nit: If you're going to introduce a top-level 'ret' variable, it
is probably best to just use it everywhere.  In this case, you only use
it inside of that if(), so you _could_ declare it in there.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
