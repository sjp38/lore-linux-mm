Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6DEFE6B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 07:11:00 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id x4so3398793wme.3
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 04:11:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l73si5862393wmd.112.2017.02.09.04.10.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Feb 2017 04:10:59 -0800 (PST)
Date: Thu, 9 Feb 2017 13:10:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2 v2] mm: vmpressure: fix sending wrong events on
 underflow
Message-ID: <20170209121057.GF10257@dhcp22.suse.cz>
References: <1486641577-11685-1-git-send-email-vinmenon@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1486641577-11685-1-git-send-email-vinmenon@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, riel@redhat.com, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, minchan@kernel.org, shashim@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 09-02-17 17:29:36, Vinayak Menon wrote:
> At the end of a window period, if the reclaimed pages
> is greater than scanned, an unsigned underflow can
> result in a huge pressure value and thus a critical event.
> Reclaimed pages is found to go higher than scanned because
> of the addition of reclaimed slab pages to reclaimed in
> shrink_node without a corresponding increment to scanned
> pages. Minchan Kim mentioned that this can also happen in
> the case of a THP page where the scanned is 1 and reclaimed
> could be 512.
> 
> Acked-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>

Acked-by: Michal Hocko <mhocko@suse.com>

I would prefer the fixup in vmpressure() as already mentioned but this
should work as well.

> ---
> v2: Adding a comment and reordering the patches
>     as per Michal's suggestion
> 
>  mm/vmpressure.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> index 149fdf6..6063581 100644
> --- a/mm/vmpressure.c
> +++ b/mm/vmpressure.c
> @@ -112,9 +112,16 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
>  						    unsigned long reclaimed)
>  {
>  	unsigned long scale = scanned + reclaimed;
> -	unsigned long pressure;
> +	unsigned long pressure = 0;
>  
>  	/*
> +	 * reclaimed can be greater than scanned in cases
> +	 * like THP, where the scanned is 1 and reclaimed
> +	 * could be 512
> +	 */
> +	if (reclaimed >= scanned)
> +		goto out;
> +	/*
>  	 * We calculate the ratio (in percents) of how many pages were
>  	 * scanned vs. reclaimed in a given time frame (window). Note that
>  	 * time is in VM reclaimer's "ticks", i.e. number of pages
> @@ -124,6 +131,7 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
>  	pressure = scale - (reclaimed * scale / scanned);
>  	pressure = pressure * 100 / scale;
>  
> +out:
>  	pr_debug("%s: %3lu  (s: %lu  r: %lu)\n", __func__, pressure,
>  		 scanned, reclaimed);
>  
> -- 
> QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
> member of the Code Aurora Forum, hosted by The Linux Foundation
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
