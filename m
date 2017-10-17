Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 998C26B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 09:02:54 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g90so797486wrd.14
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 06:02:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q187si7037533wmg.174.2017.10.17.06.02.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 06:02:53 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm: drop migrate type checks from has_unmovable_pages
References: <20171013115835.zaehapuucuzl2vlv@dhcp22.suse.cz>
 <20171013120013.698-1-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c543061a-ac27-30de-b1c4-ca40a3244579@suse.cz>
Date: Tue, 17 Oct 2017 15:02:51 +0200
MIME-Version: 1.0
In-Reply-To: <20171013120013.698-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 10/13/2017 02:00 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Michael has noticed that the memory offline tries to migrate kernel code
> pages when doing
>  echo 0 > /sys/devices/system/memory/memory0/online
> 
> The current implementation will fail the operation after several failed
> page migration attempts but we shouldn't even attempt to migrate
> that memory and fail right away because this memory is clearly not
> migrateable. This will become a real problem when we drop the retry loop
> counter resp. timeout.
> 
> The real problem is in has_unmovable_pages in fact. We should fail if
> there are any non migrateable pages in the area. In orther to guarantee
> that remove the migrate type checks because MIGRATE_MOVABLE is not
> guaranteed to contain only migrateable pages. It is merely a heuristic.
> Similarly MIGRATE_CMA does guarantee that the page allocator doesn't
> allocate any non-migrateable pages from the block but CMA allocations
> themselves are unlikely to migrateable. Therefore remove both checks.
> 
> Reported-by: Michael Ellerman <mpe@ellerman.id.au>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/page_alloc.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3badcedf96a7..ad0294ab3e4f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7355,9 +7355,6 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  	 */
>  	if (zone_idx(zone) == ZONE_MOVABLE)
>  		return false;
> -	mt = get_pageblock_migratetype(page);
> -	if (mt == MIGRATE_MOVABLE || is_migrate_cma(mt))
> -		return false;
>  
>  	pfn = page_to_pfn(page);
>  	for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++) {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
