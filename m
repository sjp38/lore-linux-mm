Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 38E1A6B025F
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 04:00:56 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id o80so52573446wme.1
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 01:00:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a203si13497530wme.4.2016.07.18.01.00.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Jul 2016 01:00:55 -0700 (PDT)
Subject: Re: [PATCH 2/2] mem-hotplug: use different mempolicy in
 alloc_migrate_target()
References: <57884EAA.9030603@huawei.com> <57884FAA.9040500@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <882dd251-9043-8fa0-4fe9-57b95fc6de3a@suse.cz>
Date: Mon, 18 Jul 2016 10:00:52 +0200
MIME-Version: 1.0
In-Reply-To: <57884FAA.9040500@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>

On 07/15/2016 04:51 AM, Xishi Qiu wrote:
> When we offline a node, the new page should alloced from other
> nodes instead of the current node, because re-migrate is a waste of
> time.

Ugh, I'm surprised that it's not the case already. Maybe the allocation 
from same node is already prevented indirectly somehow?

> So use prefer mempolicy for hotplug, use default mempolicy for cma.

IMHO CMA should prefer the same node as the migrated page, if anything. 
Current task's mempolicy shouldn't restrict it (it's likely migrating 
pages of somebody else) or even guide its preferences. Ideally it would 
keep the original page's mempolicy, but we can't afford to track that...

> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>  include/linux/page-isolation.h | 2 +-
>  mm/memory_hotplug.c            | 5 ++++-
>  mm/page_alloc.c                | 2 +-
>  mm/page_isolation.c            | 8 +++++---
>  4 files changed, 11 insertions(+), 6 deletions(-)
>
> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
> index 047d647..c163de3 100644
> --- a/include/linux/page-isolation.h
> +++ b/include/linux/page-isolation.h
> @@ -65,7 +65,7 @@ undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>  int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
>  			bool skip_hwpoisoned_pages);
>
> -struct page *alloc_migrate_target(struct page *page, unsigned long private,
> +struct page *alloc_migrate_target(struct page *page, unsigned long nid,
>  				int **resultp);
>
>  #endif
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index e3cbdca..b5963bf 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1510,12 +1510,15 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  	int move_pages = NR_OFFLINE_AT_ONCE_PAGES;
>  	int not_managed = 0;
>  	int ret = 0;
> +	int nid = NUMA_NO_NODE;
>  	LIST_HEAD(source);
>
>  	for (pfn = start_pfn; pfn < end_pfn && move_pages > 0; pfn++) {
>  		if (!pfn_valid(pfn))
>  			continue;
>  		page = pfn_to_page(pfn);
> +		if (nid == NUMA_NO_NODE)
> +			nid = next_node_in(page_to_nid(page), node_online_map);
>
>  		if (PageHuge(page)) {
>  			struct page *head = compound_head(page);
> @@ -1568,7 +1571,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  		 * alloc_migrate_target should be improooooved!!

So, is this patch improooooving it enough that we can delete the 
comment? If not, could the patch be improooooved? :)

>  		 * migrate_pages returns # of failed pages.
>  		 */
> -		ret = migrate_pages(&source, alloc_migrate_target, NULL, 0,
> +		ret = migrate_pages(&source, alloc_migrate_target, NULL, nid,
>  					MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
>  		if (ret)
>  			putback_movable_pages(&source);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6903b69..b99f1c2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7322,7 +7322,7 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
>  		cc->nr_migratepages -= nr_reclaimed;
>
>  		ret = migrate_pages(&cc->migratepages, alloc_migrate_target,
> -				    NULL, 0, cc->mode, MR_CMA);
> +				    NULL, NUMA_NO_NODE, cc->mode, MR_CMA);
>  	}
>  	if (ret < 0) {
>  		putback_movable_pages(&cc->migratepages);
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 4f32c9f..f471be6 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -279,18 +279,20 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
>  	return pfn < end_pfn ? -EBUSY : 0;
>  }
>
> -struct page *alloc_migrate_target(struct page *page, unsigned long private,
> +struct page *alloc_migrate_target(struct page *page, unsigned long nid,
>  				  int **resultp)
>  {
>  	/*
> -	 * TODO: allocate a destination hugepage from a nearest neighbor node,
> +	 * hugeTLB: allocate a destination page from a nearest neighbor node,

for hugeTLB it's still a TODO, by removing the word the rest of comment 
doesn't make much sense

>  	 * accordance with memory policy of the user process if possible. For
>  	 * now as a simple work-around, we use the next node for destination.
> +	 * Normal page: use prefer mempolicy for destination if called by
> +	 * hotplug, use default mempolicy for destination if called by cma.
>  	 */
>  	if (PageHuge(page))
>  		return alloc_huge_page_node(page_hstate(compound_head(page)),
>  					    next_node_in(page_to_nid(page),
>  							 node_online_map));
>  	else
> -		return alloc_page(GFP_HIGHUSER_MOVABLE);
> +		return alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);
>  }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
