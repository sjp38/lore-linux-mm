Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 06A076B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 07:40:49 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c85so19105630wmi.6
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 04:40:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w84si7913980wmg.121.2017.02.06.04.40.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Feb 2017 04:40:40 -0800 (PST)
Date: Mon, 6 Feb 2017 13:40:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2 RESEND] mm: vmpressure: fix sending wrong events on
 underflow
Message-ID: <20170206124037.GA10298@dhcp22.suse.cz>
References: <1486383850-30444-1-git-send-email-vinmenon@codeaurora.org>
 <1486383850-30444-2-git-send-email-vinmenon@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1486383850-30444-2-git-send-email-vinmenon@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, riel@redhat.com, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, minchan@kernel.org, shashim@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 06-02-17 17:54:10, Vinayak Menon wrote:
[...]
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> index 149fdf6..3281b34 100644
> --- a/mm/vmpressure.c
> +++ b/mm/vmpressure.c
> @@ -112,8 +112,10 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
>  						    unsigned long reclaimed)
>  {
>  	unsigned long scale = scanned + reclaimed;
> -	unsigned long pressure;
> +	unsigned long pressure = 0;
>  
> +	if (reclaimed >= scanned)
> +		goto out;

This deserves a comment IMHO. Besides that, why shouldn't we normalize
the result already in vmpressure()? Please note that the tree == true
path will aggregate both scanned and reclaimed and that already skews
numbers.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
