Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id EDF786B02FD
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 08:45:10 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w63so24594163wrc.5
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 05:45:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k23si9405925wrk.451.2017.07.24.05.45.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Jul 2017 05:45:09 -0700 (PDT)
Date: Mon, 24 Jul 2017 14:45:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/4] mm, page_ext: periodically reschedule during
 page_ext_init()
Message-ID: <20170724124505.GI25221@dhcp22.suse.cz>
References: <20170720134029.25268-1-vbabka@suse.cz>
 <20170720134029.25268-3-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170720134029.25268-3-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yang Shi <yang.shi@linaro.org>, Laura Abbott <labbott@redhat.com>, Vinayak Menon <vinmenon@codeaurora.org>, zhong jiang <zhongjiang@huawei.com>

On Thu 20-07-17 15:40:27, Vlastimil Babka wrote:
> page_ext_init() can take long on large machines, so add a cond_resched() point
> after each section is processed. This will allow moving the init to a later
> point at boot without triggering lockup reports.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_ext.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/page_ext.c b/mm/page_ext.c
> index 88ccc044b09a..24cf8abefc8d 100644
> --- a/mm/page_ext.c
> +++ b/mm/page_ext.c
> @@ -409,6 +409,7 @@ void __init page_ext_init(void)
>  				continue;
>  			if (init_section_page_ext(pfn, nid))
>  				goto oom;
> +			cond_resched();
>  		}
>  	}
>  	hotplug_memory_notifier(page_ext_callback, 0);
> -- 
> 2.13.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
