Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8A0386B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 07:44:13 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w12so12186410wmf.3
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 04:44:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j77si2601889wmd.76.2016.09.09.04.44.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Sep 2016 04:44:12 -0700 (PDT)
Date: Fri, 9 Sep 2016 13:44:11 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: fix oom work when memory is under pressure
Message-ID: <20160909114410.GG4844@dhcp22.suse.cz>
References: <1473173226-25463-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1473173226-25463-1-git-send-email-zhongjiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-mm@kvack.org

On Tue 06-09-16 22:47:06, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
> 
> Some hungtask come up when I run the trinity, and OOM occurs
> frequently.
> A task hold lock to allocate memory, due to the low memory,
> it will lead to oom. at the some time , it will retry because
> it find that oom is in progress. but it always allocate fails,
> the freed memory was taken away quickly.
> The patch fix it by limit times to avoid hungtask and livelock
> come up.

Which kernel has shown this issue? Since 4.6 IIRC we have oom reaper
responsible for the async memory reclaim from the oom victim and later
changes should help to reduce oom lockups even further.

That being said this is not a right approach. It is even incorrect
because it allows __GFP_NOFAIL to fail now. So NAK to this patch.

> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  mm/page_alloc.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a178b1d..0dcf08b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3457,6 +3457,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	enum compact_result compact_result;
>  	int compaction_retries = 0;
>  	int no_progress_loops = 0;
> +	int oom_failed = 0;
>  
>  	/*
>  	 * In the slowpath, we sanity check order to avoid ever trying to
> @@ -3645,8 +3646,13 @@ retry:
>  	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
>  	if (page)
>  		goto got_pg;
> +	else
> +		oom_failed++;
> +
> +	/* more than limited times will drop out */
> +	if (oom_failed > MAX_RECLAIM_RETRIES)
> +		goto nopage;
>  
> -	/* Retry as long as the OOM killer is making progress */
>  	if (did_some_progress) {
>  		no_progress_loops = 0;
>  		goto retry;
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
