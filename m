Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 16FF4831F4
	for <linux-mm@kvack.org>; Fri, 19 May 2017 04:17:29 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g12so3560043wrg.15
        for <linux-mm@kvack.org>; Fri, 19 May 2017 01:17:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b51si2244738wrd.194.2017.05.19.01.17.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 01:17:26 -0700 (PDT)
Subject: Re: [PATCH 10/14] mm, vmstat: skip reporting offline pages in
 pagetypeinfo
References: <20170515085827.16474-1-mhocko@kernel.org>
 <20170515085827.16474-11-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <15260936-353e-2513-e751-2117f142bfa8@suse.cz>
Date: Fri, 19 May 2017 10:17:24 +0200
MIME-Version: 1.0
In-Reply-To: <20170515085827.16474-11-mhocko@kernel.org>
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
> pagetypeinfo_showblockcount_print skips over invalid pfns but it would
> report pages which are offline because those have a valid pfn. Their
> migrate type is misleading at best. Now that we have pfn_to_online_page()
> we can use it instead of pfn_valid() and fix this.
> 
> Noticed-by: Joonsoo Kim <js1304@gmail.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

(with the followup fix)

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/vmstat.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 571d3ec05566..c432e581f9a9 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1223,11 +1223,9 @@ static void pagetypeinfo_showblockcount_print(struct seq_file *m,
>  	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
>  		struct page *page;
>  
> -		if (!pfn_valid(pfn))
> +		if (!pfn_to_online_page(pfn))
>  			continue;
>  
> -		page = pfn_to_page(pfn);
> -
>  		/* Watch for unexpected holes punched in the memmap */
>  		if (!memmap_valid_within(pfn, page, zone))
>  			continue;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
