Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7F5436B004A
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 22:55:50 -0400 (EDT)
Date: Sat, 4 Sep 2010 10:55:16 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/2] Make is_mem_section_removable more conformable
 with offlining code v3
Message-ID: <20100904025516.GB7788@localhost>
References: <AANLkTikYt3Hu_XeNuwAa9KjzfWgpC8cNen6q657ZKmm-@mail.gmail.com>
 <20100902143939.GD10265@tiehlicka.suse.cz>
 <20100902150554.GE10265@tiehlicka.suse.cz>
 <20100903121003.e2b8993a.kamezawa.hiroyu@jp.fujitsu.com>
 <20100903121452.2d22b3aa.kamezawa.hiroyu@jp.fujitsu.com>
 <20100903082558.GC10686@tiehlicka.suse.cz>
 <20100903181327.7dad3f84.kamezawa.hiroyu@jp.fujitsu.com>
 <20100903095049.GG10686@tiehlicka.suse.cz>
 <20100903190520.8751aab6.kamezawa.hiroyu@jp.fujitsu.com>
 <20100903114213.GI10686@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100903114213.GI10686@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kleen, Andi" <andi.kleen@intel.com>, Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 03, 2010 at 07:42:13PM +0800, Michal Hocko wrote:

> +/*
> + * A free or LRU pages block are removable
> + * Do not use MIGRATE_MOVABLE because it can be insufficient and
> + * other MIGRATE types are tricky.
> + * Do not hold zone->lock as this is used from user space by the
> + * sysfs interface.
> + */
> +bool is_page_removable(struct page *page)
> +{
> +	int page_block = 1 << pageblock_order;
> +
> +	/* All pages from the MOVABLE zone are movable */
> +	if (zone_idx(page_zone(page)) == ZONE_MOVABLE)
> +		return true;
> +
> +	while (page_block > 0) {
> +		int order = 0;
> +
> +		if (pfn_valid_within(page_to_pfn(page))) {
> +			if (!page_count(page) && PageBuddy(page)) {

PageBuddy() is true only for the head page and false for all tail
pages. So when is_page_removable() is given a random 4k page
(get_any_page() will exactly do that), the above test is not enough.

It's recommended to reuse is_free_buddy_page(). (Need to do some
cleanup work first: remove the "#ifdef CONFIG_MEMORY_FAILURE" and
abstract out an __is_free_buddy_page() that takes no lock.)

> @@ -5277,14 +5277,11 @@ int set_migratetype_isolate(struct page *page)
>  	struct memory_isolate_notify arg;
>  	int notifier_ret;
>  	int ret = -EBUSY;
> -	int zone_idx;
>  
>  	zone = page_zone(page);
> -	zone_idx = zone_idx(zone);
>  
>  	spin_lock_irqsave(&zone->lock, flags);
> -	if (get_pageblock_migratetype(page) == MIGRATE_MOVABLE ||
> -	    zone_idx == ZONE_MOVABLE) {
> +	if (is_page_removable(page)) {
>  		ret = 0;
>  		goto out;

The above check only applies to the first page in the page block.
The following "if (!page_count(curr_page) || PageLRU(curr_page))"
check in the same function should be converted too (and that's another
reason to use __is_free_buddy_page(): it will be tested for every 4k
pages, including both the head and tail pages).

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
