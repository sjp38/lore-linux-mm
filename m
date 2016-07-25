Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7050F6B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 02:59:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p129so71419091wmp.3
        for <linux-mm@kvack.org>; Sun, 24 Jul 2016 23:59:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t195si17539029wmt.31.2016.07.24.23.59.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 24 Jul 2016 23:59:30 -0700 (PDT)
Subject: Re: [PATCH v2] mem-hotplug: alloc new page from the next node if zone
 is MOVABLE_ZONE
References: <57918BAC.8000008@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <cd3707d7-fb97-ab90-24d6-6bee3113f515@suse.cz>
Date: Mon, 25 Jul 2016 08:59:26 +0200
MIME-Version: 1.0
In-Reply-To: <57918BAC.8000008@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 07/22/2016 04:57 AM, Xishi Qiu wrote:
> Memory offline could happen on both movable zone and non-movable zone.
> We can offline the whole node if the zone is movable zone, and if the
> zone is non-movable zone, we cannot offline the whole node, because
> some kernel memory can't be migrated.
>
> So if we offline a node with movable zone, use prefer mempolicy to alloc
> new page from the next node instead of the current node or other remote
> nodes, because re-migrate is a waste of time and the distance of the
> remote nodes is often very large.
>
> Also use GFP_HIGHUSER_MOVABLE to alloc new page if the zone is movable
> zone.
>
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>

I think this could be simpler, if you preferred the next node regardless 
of whether it's movable zone or not. What are use cases for trying to 
offline part of non-MOVABLE zone in a node? It's not guaranteed to 
succeed anyway. Also if the reasoning is that the non-MOVABLE offlining 
preference for migration target should be instead on the *same* node, 
then alloc_migrate_target() would anyway prefer the node of the current 
CPU that happens to execute the offlining, which is random wrt the node 
in question. So consistently choosing remote node is IMHO better than 
random even for non-MOVABLE zone.

> ---
>  mm/memory_hotplug.c | 35 +++++++++++++++++++++++++++++------
>  1 file changed, 29 insertions(+), 6 deletions(-)
>
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index e3cbdca..930a5c6 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1501,6 +1501,16 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
>  	return 0;
>  }
>
> +static struct page *new_node_page(struct page *page, unsigned long node,
> +		int **result)
> +{
> +	if (PageHuge(page))
> +		return alloc_huge_page_node(page_hstate(compound_head(page)),
> +					node);
> +	else
> +		return __alloc_pages_node(node, GFP_HIGHUSER_MOVABLE, 0);

You could just test for page in movable (or highmem?) zone here in the 
callback.

> +}
> +
>  #define NR_OFFLINE_AT_ONCE_PAGES	(256)
>  static int
>  do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
> @@ -1510,6 +1520,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  	int move_pages = NR_OFFLINE_AT_ONCE_PAGES;
>  	int not_managed = 0;
>  	int ret = 0;
> +	int nid = NUMA_NO_NODE;
>  	LIST_HEAD(source);
>
>  	for (pfn = start_pfn; pfn < end_pfn && move_pages > 0; pfn++) {
> @@ -1564,12 +1575,24 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  			goto out;
>  		}
>
> -		/*
> -		 * alloc_migrate_target should be improooooved!!
> -		 * migrate_pages returns # of failed pages.
> -		 */
> -		ret = migrate_pages(&source, alloc_migrate_target, NULL, 0,
> -					MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
> +		for (pfn = start_pfn; pfn < end_pfn; pfn++) {
> +			if (!pfn_valid(pfn))
> +				continue;
> +			page = pfn_to_page(pfn);
> +			if (zone_idx(page_zone(page)) == ZONE_MOVABLE)
> +				nid = next_node_in(page_to_nid(page),
> +						node_online_map);
> +			break;
> +		}

Then you could remove the ZONE_MOVABLE check here. I'm not sure how much 
worth the precalculation of nid is, if it has to be a rather complicated 
code like this, hm.

Also, since we know that "next node in node_online_map" is in fact not 
optimal, what about using the opportunity to really try the best 
possible way? Maybe it's as simple as allocating via 
__alloc_pages_nodemask() with current node's zonelist (where remote 
nodes should be already sorted according to NUMA distance), but with 
current node (which would be first in the zonelist) removed from the 
nodemask so that it's skipped over? But check if memory offlining 
process didn't kill the zonelist already at this point, or something.

> +
> +		/* Alloc new page from the next node if possible */
> +		if (nid != NUMA_NO_NODE)
> +			ret = migrate_pages(&source, new_node_page, NULL,
> +					nid, MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
> +		else
> +			ret = migrate_pages(&source, alloc_migrate_target, NULL,
> +					0, MIGRATE_SYNC, MR_MEMORY_HOTPLUG);

Please just use one new callback fully tailored for memory offline, 
instead of choosing between the two like this.

>  		if (ret)
>  			putback_movable_pages(&source);
>  	}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
