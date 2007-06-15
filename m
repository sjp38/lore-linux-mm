Date: Thu, 14 Jun 2007 23:04:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] memory unplug v5 [5/6] page unplug
In-Reply-To: <20070614160458.62e20cbd.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.0.99.0706142303460.1729@chino.kir.corp.google.com>
References: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
 <20070614160458.62e20cbd.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, clameter@sgi.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jun 2007, KAMEZAWA Hiroyuki wrote:

> Index: devel-2.6.22-rc4-mm2/mm/memory_hotplug.c
> ===================================================================
> --- devel-2.6.22-rc4-mm2.orig/mm/memory_hotplug.c
> +++ devel-2.6.22-rc4-mm2/mm/memory_hotplug.c
> @@ -23,6 +23,9 @@
>  #include <linux/vmalloc.h>
>  #include <linux/ioport.h>
>  #include <linux/cpuset.h>
> +#include <linux/delay.h>
> +#include <linux/migrate.h>
> +#include <linux/page-isolation.h>
>  
>  #include <asm/tlbflush.h>
>  
> @@ -301,3 +304,256 @@ error:
>  	return ret;
>  }
>  EXPORT_SYMBOL_GPL(add_memory);
> +
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +/*
> + * Confirm all pages in a range [start, end) is belongs to the same zone.
> + */
> +static int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
> +{
> +	unsigned long pfn;
> +	struct zone *zone = NULL;
> +	struct page *page;
> +	for (pfn = start_pfn;
> +             pfn < end_pfn;
> +	     pfn += MAX_ORDER_NR_PAGES) {
> +#ifdef CONFIG_HOLES_IN_ZONE
> +		int i;
> +		for (i = 0; i < MAX_ORDER_NR_PAGES; i++) {
> +			if (pfn_valid_within(pfn + i))
> +				break;
> +		}
> +		if (i == MAX_ORDER_NR_PAGES)
> +			continue;
> +		page = pfn_to_page(pfn + i);
> +#else
> +		page = pfn_to_page(pfn);
> +#endif

Please extract this out to inlined functions that are conditional are 
CONFIG_HOLES_IN_ZONE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
