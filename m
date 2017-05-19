Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB322831F4
	for <linux-mm@kvack.org>; Fri, 19 May 2017 03:23:36 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id q91so3292131wrb.8
        for <linux-mm@kvack.org>; Fri, 19 May 2017 00:23:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e133si13847489wma.1.2017.05.19.00.23.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 00:23:35 -0700 (PDT)
Subject: Re: [PATCH 08/14] mm, compaction: skip over holes in
 __reset_isolation_suitable
References: <20170515085827.16474-1-mhocko@kernel.org>
 <20170515085827.16474-9-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e13bd795-4ac2-1682-edf3-0af85f150f28@suse.cz>
Date: Fri, 19 May 2017 09:23:33 +0200
MIME-Version: 1.0
In-Reply-To: <20170515085827.16474-9-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 05/15/2017 10:58 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> __reset_isolation_suitable walks the whole zone pfn range and it tries
> to jump over holes by checking the zone for each page. It might still
> stumble over offline pages, though. Skip those by checking
> pfn_to_online_page()
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
