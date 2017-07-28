Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 132736B056D
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 16:48:35 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id o9so85639757iod.13
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 13:48:35 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id a190si6166309itc.68.2017.07.28.13.48.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jul 2017 13:48:33 -0700 (PDT)
Subject: Re: gigantic hugepages vs. movable zones
References: <20170726105004.GI2981@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <6dd3171d-7d61-5476-5465-ab7c06b56e0b@oracle.com>
Date: Fri, 28 Jul 2017 13:48:28 -0700
MIME-Version: 1.0
In-Reply-To: <20170726105004.GI2981@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 07/26/2017 03:50 AM, Michal Hocko wrote:
> Hi,
> I've just noticed that alloc_gigantic_page ignores movability of the
> gigantic page and it uses any existing zone. Considering that
> hugepage_migration_supported only supports 2MB and pgd level hugepages
> then 1GB pages are not migratable and as such allocating them from a
> movable zone will break the basic expectation of this zone. Standard
> hugetlb allocations try to avoid that by using htlb_alloc_mask and I
> believe we should do the same for gigantic pages as well.
> 
> I suspect this behavior is not intentional. What do you think about the
> following untested patch?
> ---
> From 542d32c1eca7dcf38afca1a91bca4a472f6e8651 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Wed, 26 Jul 2017 12:43:43 +0200
> Subject: [PATCH] mm, hugetlb: do not allocate non-migrateable gigantic pages
>  from movable zones
> 
> alloc_gigantic_page doesn't consider movability of the gigantic hugetlb
> when scanning eligible ranges for the allocation. As 1GB hugetlb pages
> are not movable currently this can break the movable zone assumption
> that all allocations are migrateable and as such break memory hotplug.
> 
> Reorganize the code and use the standard zonelist allocations scheme
> that we use for standard hugetbl pages. htlb_alloc_mask will ensure that
> only migratable hugetlb pages will ever see a movable zone.
> 
> Fixes: 944d9fec8d7a ("hugetlb: add support for gigantic page allocation at runtime")
> Signed-off-by: Michal Hocko <mhocko@suse.com>

This seems reasonable to me, and I like the fact that the code is more
like the default huge page case.  I don't see any issues with the code.
I did some simple smoke testing of allocating 1G pages with the new code
and ensuring they ended up as expected.

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

-- 
Mike Kravetz

> ---
>  mm/hugetlb.c | 35 ++++++++++++++++++++---------------
>  1 file changed, 20 insertions(+), 15 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index bc48ee783dd9..60530bb3d228 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1066,11 +1066,11 @@ static void free_gigantic_page(struct page *page, unsigned int order)
>  }
>  
>  static int __alloc_gigantic_page(unsigned long start_pfn,
> -				unsigned long nr_pages)
> +				unsigned long nr_pages, gfp_t gfp_mask)
>  {
>  	unsigned long end_pfn = start_pfn + nr_pages;
>  	return alloc_contig_range(start_pfn, end_pfn, MIGRATE_MOVABLE,
> -				  GFP_KERNEL);
> +				  gfp_mask);
>  }
>  
>  static bool pfn_range_valid_gigantic(struct zone *z,
> @@ -1108,19 +1108,24 @@ static bool zone_spans_last_pfn(const struct zone *zone,
>  	return zone_spans_pfn(zone, last_pfn);
>  }
>  
> -static struct page *alloc_gigantic_page(int nid, unsigned int order)
> +static struct page *alloc_gigantic_page(int nid, struct hstate *h)
>  {
> +	unsigned int order = huge_page_order(h);
>  	unsigned long nr_pages = 1 << order;
>  	unsigned long ret, pfn, flags;
> -	struct zone *z;
> +	struct zonelist *zonelist;
> +	struct zone *zone;
> +	struct zoneref *z;
> +	gfp_t gfp_mask;
>  
> -	z = NODE_DATA(nid)->node_zones;
> -	for (; z - NODE_DATA(nid)->node_zones < MAX_NR_ZONES; z++) {
> -		spin_lock_irqsave(&z->lock, flags);
> +	gfp_mask = htlb_alloc_mask(h) | __GFP_THISNODE;
> +	zonelist = node_zonelist(nid, gfp_mask);
> +	for_each_zone_zonelist_nodemask(zone, z, zonelist, gfp_zone(gfp_mask), NULL) {
> +		spin_lock_irqsave(&zone->lock, flags);
>  
> -		pfn = ALIGN(z->zone_start_pfn, nr_pages);
> -		while (zone_spans_last_pfn(z, pfn, nr_pages)) {
> -			if (pfn_range_valid_gigantic(z, pfn, nr_pages)) {
> +		pfn = ALIGN(zone->zone_start_pfn, nr_pages);
> +		while (zone_spans_last_pfn(zone, pfn, nr_pages)) {
> +			if (pfn_range_valid_gigantic(zone, pfn, nr_pages)) {
>  				/*
>  				 * We release the zone lock here because
>  				 * alloc_contig_range() will also lock the zone
> @@ -1128,16 +1133,16 @@ static struct page *alloc_gigantic_page(int nid, unsigned int order)
>  				 * spinning on this lock, it may win the race
>  				 * and cause alloc_contig_range() to fail...
>  				 */
> -				spin_unlock_irqrestore(&z->lock, flags);
> -				ret = __alloc_gigantic_page(pfn, nr_pages);
> +				spin_unlock_irqrestore(&zone->lock, flags);
> +				ret = __alloc_gigantic_page(pfn, nr_pages, gfp_mask);
>  				if (!ret)
>  					return pfn_to_page(pfn);
> -				spin_lock_irqsave(&z->lock, flags);
> +				spin_lock_irqsave(&zone->lock, flags);
>  			}
>  			pfn += nr_pages;
>  		}
>  
> -		spin_unlock_irqrestore(&z->lock, flags);
> +		spin_unlock_irqrestore(&zone->lock, flags);
>  	}
>  
>  	return NULL;
> @@ -1150,7 +1155,7 @@ static struct page *alloc_fresh_gigantic_page_node(struct hstate *h, int nid)
>  {
>  	struct page *page;
>  
> -	page = alloc_gigantic_page(nid, huge_page_order(h));
> +	page = alloc_gigantic_page(nid, h);
>  	if (page) {
>  		prep_compound_gigantic_page(page, huge_page_order(h));
>  		prep_new_huge_page(h, page, nid);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
