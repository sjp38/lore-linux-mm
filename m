Subject: Re: [RFC] buddy allocator without bitmap(2) [1/3]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <413455BE.6010302@jp.fujitsu.com>
References: <413455BE.6010302@jp.fujitsu.com>
Content-Type: text/plain
Message-Id: <1093969857.26660.4816.camel@nighthawk>
Mime-Version: 1.0
Date: Tue, 31 Aug 2004 09:30:57 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Tue, 2004-08-31 at 03:41, Hiroyuki KAMEZAWA wrote:
> +static void __init calculate_aligned_end(struct zone *zone,
> +					 unsigned long start_pfn,
> +					 int nr_pages)
...
> +		end_address = (zone->zone_start_pfn + end_idx) << PAGE_SHIFT;
> +#ifndef CONFIG_DISCONTIGMEM
> +		reserve_bootmem(end_address,PAGE_SIZE);
> +#else
> +		reserve_bootmem_node(zone->zone_pgdat,end_address,PAGE_SIZE);
> +#endif
> +	}
> +	return;
> +}

What if someone has already reserved that address?  You might not be
able to grow the zone, right?

>   /*
>    * Initially all pages are reserved - free ones are freed
> @@ -1510,7 +1574,9 @@ void __init memmap_init_zone(unsigned lo
>   {
>   	struct page *start = pfn_to_page(start_pfn);
>   	struct page *page;
> -
> +	unsigned long saved_start_pfn = start_pfn;
> +	struct zone *zonep = zone_table[NODEZONE(nid, zone)];

If you're going to calculate NODEZONE() twice, you might as well just
move it into its own variable.  

> +	/* Because memmap_init_zone() is called in suitable way
> +	 * even if zone has memory holes,
> +	 * calling calculate_aligned_end(zone) here is reasonable
> +	 */
> +	calculate_aligned_end(zonep, saved_start_pfn, size);

Could you please elaborate on "suitable way".  That comment really
doesn't say anything.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
