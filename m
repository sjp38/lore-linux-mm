Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 59C186B0032
	for <linux-mm@kvack.org>; Sat, 17 Jan 2015 11:29:42 -0500 (EST)
Received: by mail-ie0-f179.google.com with SMTP id rp18so25287704iec.10
        for <linux-mm@kvack.org>; Sat, 17 Jan 2015 08:29:42 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id ar8si9059037icc.91.2015.01.17.08.29.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Jan 2015 08:29:41 -0800 (PST)
Message-ID: <54BA8DEC.1080508@codeaurora.org>
Date: Sat, 17 Jan 2015 21:59:32 +0530
From: Vinayak Menon <vinmenon@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: vmscan: fix the page state calculation in too_many_isolated
References: <1421235419-30736-1-git-send-email-vinmenon@codeaurora.org> <20150115171728.ebc77a48.akpm@linux-foundation.org>
In-Reply-To: <20150115171728.ebc77a48.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, vdavydov@parallels.com, mhocko@suse.cz, mgorman@suse.de, minchan@kernel.org

On 01/16/2015 06:47 AM, Andrew Morton wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm-vmscan-fix-the-page-state-calculation-in-too_many_isolated-fix
>
> Move the zone_page_state_snapshot() fallback logic into
> too_many_isolated(), so shrink_inactive_list() doesn't incorrectly call
> congestion_wait().
>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Vinayak Menon <vinmenon@codeaurora.org>
> Cc: Vladimir Davydov <vdavydov@parallels.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
>   mm/vmscan.c |   23 +++++++++++------------
>   1 file changed, 11 insertions(+), 12 deletions(-)
>
> diff -puN mm/vmscan.c~mm-vmscan-fix-the-page-state-calculation-in-too_many_isolated-fix mm/vmscan.c
> --- a/mm/vmscan.c~mm-vmscan-fix-the-page-state-calculation-in-too_many_isolated-fix
> +++ a/mm/vmscan.c
> @@ -1402,7 +1402,7 @@ int isolate_lru_page(struct page *page)
>   }
>
>   static int __too_many_isolated(struct zone *zone, int file,
> -	struct scan_control *sc, int safe)
> +			       struct scan_control *sc, int safe)
>   {
>   	unsigned long inactive, isolated;
>
> @@ -1435,7 +1435,7 @@ static int __too_many_isolated(struct zo
>    * unnecessary swapping, thrashing and OOM.
>    */
>   static int too_many_isolated(struct zone *zone, int file,
> -		struct scan_control *sc, int safe)
> +			     struct scan_control *sc)
>   {
>   	if (current_is_kswapd())
>   		return 0;
> @@ -1443,12 +1443,14 @@ static int too_many_isolated(struct zone
>   	if (!global_reclaim(sc))
>   		return 0;
>
> -	if (unlikely(__too_many_isolated(zone, file, sc, 0))) {
> -		if (safe)
> -			return __too_many_isolated(zone, file, sc, safe);
> -		else
> -			return 1;
> -	}
> +	/*
> +	 * __too_many_isolated(safe=0) is fast but inaccurate, because it
> +	 * doesn't account for the vm_stat_diff[] counters.  So if it looks
> +	 * like too_many_isolated() is about to return true, fall back to the
> +	 * slower, more accurate zone_page_state_snapshot().
> +	 */
> +	if (unlikely(__too_many_isolated(zone, file, sc, 0)))
> +		return __too_many_isolated(zone, file, sc, safe);

Just noticed now that, in the above statement it should be "1", instead 
of "safe". "safe" is not declared.



-- 
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
