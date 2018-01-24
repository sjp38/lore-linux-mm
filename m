Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D664800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 11:40:12 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id d14so2099693wre.6
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 08:40:12 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id 34si473837edj.250.2018.01.24.08.40.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 08:40:11 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id D8CEA1C3B0E
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 16:40:10 +0000 (GMT)
Date: Wed, 24 Jan 2018 16:40:06 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/2] free_pcppages_bulk: do not hold lock when picking
 pages to free
Message-ID: <20180124163926.c7ptagn655aeiut3@techsingularity.net>
References: <20180124023050.20097-1-aaron.lu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20180124023050.20097-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Jan 24, 2018 at 10:30:49AM +0800, Aaron Lu wrote:
> When freeing a batch of pages from Per-CPU-Pages(PCP) back to buddy,
> the zone->lock is held and then pages are chosen from PCP's migratetype
> list. While there is actually no need to do this 'choose part' under
> lock since it's PCP pages, the only CPU that can touch them is us and
> irq is also disabled.
> 
> Moving this part outside could reduce lock held time and improve
> performance. Test with will-it-scale/page_fault1 full load:
> 
> kernel      Broadwell(2S)  Skylake(2S)   Broadwell(4S)  Skylake(4S)
> v4.15-rc4   9037332        8000124       13642741       15728686
> this patch  9608786 +6.3%  8368915 +4.6% 14042169 +2.9% 17433559 +10.8%
> 
> What the test does is: starts $nr_cpu processes and each will repeated
> do the following for 5 minutes:
> 1 mmap 128M anonymouse space;
> 2 write access to that space;
> 3 munmap.
> The score is the aggregated iteration.
> 
> https://github.com/antonblanchard/will-it-scale/blob/master/tests/page_fault1.c
> 
> Signed-off-by: Aaron Lu <aaron.lu@intel.com>
> ---
>  mm/page_alloc.c | 33 +++++++++++++++++++--------------
>  1 file changed, 19 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4093728f292e..a076f754dac1 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1113,12 +1113,12 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>  	int migratetype = 0;
>  	int batch_free = 0;
>  	bool isolated_pageblocks;
> +	struct list_head head;
> +	struct page *page, *tmp;
>  
> -	spin_lock(&zone->lock);
> -	isolated_pageblocks = has_isolate_pageblock(zone);
> +	INIT_LIST_HEAD(&head);
>  

Declare head as LIST_HEAD(head) and avoid INIT_LIST_HEAD. Otherwise I
think this is safe

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
