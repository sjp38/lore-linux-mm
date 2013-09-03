Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id ED6A96B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 01:57:46 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 13F453EE1B9
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 14:57:45 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 046B045DE5C
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 14:57:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DE8B945DE58
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 14:57:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CFFA2E08002
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 14:57:44 +0900 (JST)
Received: from g01jpfmpwkw02.exch.g01.fujitsu.local (g01jpfmpwkw02.exch.g01.fujitsu.local [10.0.193.56])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 868A21DB8040
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 14:57:44 +0900 (JST)
Message-ID: <52257A1A.2040200@jp.fujitsu.com>
Date: Tue, 3 Sep 2013 14:56:42 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 06/35] mm: Add helpers to retrieve node region
 and zone region for a given page
References: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com> <20130830131542.4947.76970.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830131542.4947.76970.stgit@srivatsabhat.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2013/08/30 22:15), Srivatsa S. Bhat wrote:
> Given a page, we would like to have an efficient mechanism to find out
> the node memory region and the zone memory region to which it belongs.
>
> Since the node is assumed to be divided into equal-sized node memory
> regions, the node memory region can be obtained by simply right-shifting
> the page's pfn by 'MEM_REGION_SHIFT'.
>
> But finding the corresponding zone memory region's index in the zone is
> not that straight-forward. To have a O(1) algorithm to find it out, define a
> zone_region_idx[] array to store the zone memory region indices for every
> node memory region.
>
> To illustrate, consider the following example:
>
> 	|<----------------------Node---------------------->|
> 	 __________________________________________________
> 	|      Node mem reg 0 	 |      Node mem reg 1     |  (Absolute region
> 	|________________________|_________________________|   boundaries)
>
> 	 __________________________________________________
> 	|    ZONE_DMA   |	    ZONE_NORMAL		   |
> 	|               |                                  |
> 	|<--- ZMR 0 --->|<-ZMR0->|<-------- ZMR 1 -------->|
> 	|_______________|________|_________________________|
>
>
> In the above figure,
>
> Node mem region 0:
> ------------------
> This region corresponds to the first zone mem region in ZONE_DMA and also
> the first zone mem region in ZONE_NORMAL. Hence its index array would look
> like this:
>      node_regions[0].zone_region_idx[ZONE_DMA]     == 0
>      node_regions[0].zone_region_idx[ZONE_NORMAL]  == 0
>
>
> Node mem region 1:
> ------------------
> This region corresponds to the second zone mem region in ZONE_NORMAL. Hence
> its index array would look like this:
>      node_regions[1].zone_region_idx[ZONE_NORMAL]  == 1
>
>
> Using this index array, we can quickly obtain the zone memory region to
> which a given page belongs.
>
> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
> ---
>
>   include/linux/mm.h     |   24 ++++++++++++++++++++++++
>   include/linux/mmzone.h |    7 +++++++
>   mm/page_alloc.c        |    1 +
>   3 files changed, 32 insertions(+)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 18fdec4..52329d1 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -723,6 +723,30 @@ static inline struct zone *page_zone(const struct page *page)
>   	return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
>   }
>
> +static inline int page_node_region_id(const struct page *page,
> +				      const pg_data_t *pgdat)
> +{
> +	return (page_to_pfn(page) - pgdat->node_start_pfn) >> MEM_REGION_SHIFT;
> +}
> +
> +/**
> + * Return the index of the zone memory region to which the page belongs.
> + *
> + * Given a page, find the absolute (node) memory region as well as the zone to
> + * which it belongs. Then find the region within the zone that corresponds to
> + * that node memory region, and return its index.
> + */
> +static inline int page_zone_region_id(const struct page *page)
> +{
> +	pg_data_t *pgdat = NODE_DATA(page_to_nid(page));
> +	enum zone_type z_num = page_zonenum(page);
> +	unsigned long node_region_idx;
> +
> +	node_region_idx = page_node_region_id(page, pgdat);
> +
> +	return pgdat->node_regions[node_region_idx].zone_region_idx[z_num];
> +}
> +
>   #ifdef SECTION_IN_PAGE_FLAGS
>   static inline void set_page_section(struct page *page, unsigned long section)
>   {
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 010ab5b..76d9ed2 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -726,6 +726,13 @@ struct node_mem_region {
>   	unsigned long end_pfn;
>   	unsigned long present_pages;
>   	unsigned long spanned_pages;

> +
> +	/*
> +	 * A physical (node) region could be split across multiple zones.
> +	 * Store the indices of the corresponding regions of each such
> +	 * zone for this physical (node) region.
> +	 */
> +	int zone_region_idx[MAX_NR_ZONES];

You should initialize the zone_region_id[] as negative value.
If the zone_region_id is initialized as 0, region 0 belongs to all zones.

Thanks,
Yasuaki Ishimatsu


>   	struct pglist_data *pgdat;
>   };
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 05cedbb..8ffd47b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4877,6 +4877,7 @@ static void __meminit init_zone_memory_regions(struct pglist_data *pgdat)
>   			zone_region->present_pages =
>   					zone_region->spanned_pages - absent;
>
> +			node_region->zone_region_idx[zone_idx(z)] = idx;
>   			idx++;
>   		}
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
