Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9AEAD6B0279
	for <linux-mm@kvack.org>; Mon,  3 Jul 2017 03:44:22 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id j85so17938840wmj.2
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 00:44:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k34si11465234wre.244.2017.07.03.00.44.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Jul 2017 00:44:21 -0700 (PDT)
Date: Mon, 3 Jul 2017 09:44:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: vmpressure: simplify pressure ratio calculation
Message-ID: <20170703074417.GC3217@dhcp22.suse.cz>
References: <1498890459-3983-1-git-send-email-zbestahu@aliyun.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1498890459-3983-1-git-send-email-zbestahu@aliyun.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zbestahu@aliyun.com
Cc: akpm@linux-foundation.org, minchan@kernel.org, linux-mm@kvack.org, Yue Hu <huyue2@coolpad.com>, Anton Vorontsov <anton.vorontsov@linaro.org>

[CC Anton]

On Sat 01-07-17 14:27:39, zbestahu@aliyun.com wrote:
> From: Yue Hu <huyue2@coolpad.com>
> 
> The patch removes the needless scale in existing caluation, it
> makes the calculation more simple and more effective.

I suspect the construct is deliberate and done this way because of the
rounding. Your code will behave slightly differently. If that is
intentional then it should be described in the changedlog.

> Signed-off-by: Yue Hu <huyue2@coolpad.com>
> ---
>  mm/vmpressure.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> index 6063581..174b2f0 100644
> --- a/mm/vmpressure.c
> +++ b/mm/vmpressure.c
> @@ -111,7 +111,6 @@ static enum vmpressure_levels vmpressure_level(unsigned long pressure)
>  static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
>  						    unsigned long reclaimed)
>  {
> -	unsigned long scale = scanned + reclaimed;
>  	unsigned long pressure = 0;
>  
>  	/*
> @@ -128,8 +127,7 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
>  	 * scanned. This makes it possible to set desired reaction time
>  	 * and serves as a ratelimit.
>  	 */
> -	pressure = scale - (reclaimed * scale / scanned);
> -	pressure = pressure * 100 / scale;
> +	pressure = (scanned - reclaimed) * 100 / scanned;
>  
>  out:
>  	pr_debug("%s: %3lu  (s: %lu  r: %lu)\n", __func__, pressure,
> -- 
> 1.9.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
