Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 298B76B03A6
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 03:59:26 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b87so757539wmi.14
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 00:59:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v102si1921030wrb.15.2017.04.27.00.59.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Apr 2017 00:59:24 -0700 (PDT)
Date: Thu, 27 Apr 2017 09:59:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 08/13] mm, compaction: skip over holes in
 __reset_isolation_suitable
Message-ID: <20170427075922.GC4706@dhcp22.suse.cz>
References: <20170421120512.23960-1-mhocko@kernel.org>
 <20170421120512.23960-9-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170421120512.23960-9-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Fri 21-04-17 14:05:11, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> __reset_isolation_suitable walks the whole zone pfn range and it tries
> to jump over holes by checking the zone for each page. It might still
> stumble over offline pages, though. Skip those by checking PageReserved.

ups, forgot to update the changelog here. s@PageReserved@pfn_to_online_page()@
 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/compaction.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 613c59e928cb..fb548e4c7bd4 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -236,10 +236,9 @@ static void __reset_isolation_suitable(struct zone *zone)
>  
>  		cond_resched();
>  
> -		if (!pfn_valid(pfn))
> +		page = pfn_to_online_page(pfn);
> +		if (!page)
>  			continue;
> -
> -		page = pfn_to_page(pfn);
>  		if (zone != page_zone(page))
>  			continue;
>  
> -- 
> 2.11.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
