Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 230B06B02B4
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 23:55:43 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id k71so708381pgd.6
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 20:55:43 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id l75si521300pfk.419.2017.06.06.20.55.41
        for <linux-mm@kvack.org>;
        Tue, 06 Jun 2017 20:55:42 -0700 (PDT)
Date: Wed, 7 Jun 2017 12:55:40 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] Revert "mm: vmpressure: fix sending wrong events on
 underflow"
Message-ID: <20170607035540.GA5687@bbox>
References: <1496804917-7628-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1496804917-7628-1-git-send-email-zhongjiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, vinayakm.list@gmail.com, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jun 07, 2017 at 11:08:37AM +0800, zhongjiang wrote:
> This reverts commit e1587a4945408faa58d0485002c110eb2454740c.
> 
> THP lru page is reclaimed , THP is split to normal page and loop again.
> reclaimed pages should not be bigger than nr_scan.  because of each
> loop will increase nr_scan counter.

Unfortunately, there is still underflow issue caused by slab pages as
Vinayak reported in description of e1587a4945408 so we cannot revert.
Please correct comment instead of removing the logic.

Thanks.

> 
> Signed-off-by: zhongjiang <zhongjiang@huawei.com>
> ---
>  mm/vmpressure.c | 10 +---------
>  1 file changed, 1 insertion(+), 9 deletions(-)
> 
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> index 6063581..149fdf6 100644
> --- a/mm/vmpressure.c
> +++ b/mm/vmpressure.c
> @@ -112,16 +112,9 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
>  						    unsigned long reclaimed)
>  {
>  	unsigned long scale = scanned + reclaimed;
> -	unsigned long pressure = 0;
> +	unsigned long pressure;
>  
>  	/*
> -	 * reclaimed can be greater than scanned in cases
> -	 * like THP, where the scanned is 1 and reclaimed
> -	 * could be 512
> -	 */
> -	if (reclaimed >= scanned)
> -		goto out;
> -	/*
>  	 * We calculate the ratio (in percents) of how many pages were
>  	 * scanned vs. reclaimed in a given time frame (window). Note that
>  	 * time is in VM reclaimer's "ticks", i.e. number of pages
> @@ -131,7 +124,6 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
>  	pressure = scale - (reclaimed * scale / scanned);
>  	pressure = pressure * 100 / scale;
>  
> -out:
>  	pr_debug("%s: %3lu  (s: %lu  r: %lu)\n", __func__, pressure,
>  		 scanned, reclaimed);
>  
> -- 
> 1.7.12.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
