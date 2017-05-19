Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8EF831F4
	for <linux-mm@kvack.org>; Fri, 19 May 2017 04:05:40 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c202so13578919wme.10
        for <linux-mm@kvack.org>; Fri, 19 May 2017 01:05:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l62si7658844ede.325.2017.05.19.01.05.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 01:05:39 -0700 (PDT)
Subject: Re: [PATCH 09/14] mm: __first_valid_page skip over offline pages
References: <20170515085827.16474-1-mhocko@kernel.org>
 <20170515085827.16474-10-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <124e3428-d7cb-8c83-3c08-94a3fc7ec58f@suse.cz>
Date: Fri, 19 May 2017 10:05:35 +0200
MIME-Version: 1.0
In-Reply-To: <20170515085827.16474-10-mhocko@kernel.org>
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
> __first_valid_page skips over invalid pfns in the range but it might
> still stumble over offline pages. At least start_isolate_page_range
> will mark those set_migratetype_isolate. This doesn't represent
> any immediate AFAICS because alloc_contig_range will fail to isolate
> those pages but it relies on not fully initialized page which will
> become a problem later when we stop associating offline pages to zones.
> Use pfn_to_online_page to handle this.
> 
> This is more a preparatory patch than a fix.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Iterating over single pages when the whole section is offline seems
rather wasteful, but it should be really rare, so whatever.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/page_isolation.c | 26 ++++++++++++++++++--------
>  1 file changed, 18 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 5092e4ef00c8..3606104893e0 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -138,12 +138,18 @@ static inline struct page *
>  __first_valid_page(unsigned long pfn, unsigned long nr_pages)
>  {
>  	int i;
> -	for (i = 0; i < nr_pages; i++)
> -		if (pfn_valid_within(pfn + i))
> -			break;
> -	if (unlikely(i == nr_pages))
> -		return NULL;
> -	return pfn_to_page(pfn + i);
> +
> +	for (i = 0; i < nr_pages; i++) {
> +		struct page *page;
> +
> +		if (!pfn_valid_within(pfn + i))
> +			continue;
> +		page = pfn_to_online_page(pfn + i);
> +		if (!page)
> +			continue;
> +		return page;
> +	}
> +	return NULL;
>  }
>  
>  /*
> @@ -184,8 +190,12 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>  undo:
>  	for (pfn = start_pfn;
>  	     pfn < undo_pfn;
> -	     pfn += pageblock_nr_pages)
> -		unset_migratetype_isolate(pfn_to_page(pfn), migratetype);
> +	     pfn += pageblock_nr_pages) {
> +		struct page *page = pfn_to_online_page(pfn);
> +		if (!page)
> +			continue;
> +		unset_migratetype_isolate(page, migratetype);
> +	}
>  
>  	return -EBUSY;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
