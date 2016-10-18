Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 67A556B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 08:27:53 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id i187so10548245lfe.4
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 05:27:53 -0700 (PDT)
Received: from mail-lf0-f67.google.com (mail-lf0-f67.google.com. [209.85.215.67])
        by mx.google.com with ESMTPS id k82si462408lfe.100.2016.10.18.05.27.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 05:27:51 -0700 (PDT)
Received: by mail-lf0-f67.google.com with SMTP id l131so2617835lfl.0
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 05:27:51 -0700 (PDT)
Date: Tue, 18 Oct 2016 14:27:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: How to make warn_alloc() reliable?
Message-ID: <20161018122749.GE12092@dhcp22.suse.cz>
References: <201610182004.AEF87559.FOOHVLJOQFFtSM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201610182004.AEF87559.FOOHVLJOQFFtSM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, dave.hansen@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 18-10-16 20:04:20, Tetsuo Handa wrote:
[...]
> @@ -1697,11 +1697,25 @@ static bool inactive_reclaimable_pages(struct lruvec *lruvec,
>  	int file = is_file_lru(lru);
>  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
>  	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
> +	unsigned long wait_start = jiffies;
> +	unsigned int wait_timeout = 10 * HZ;
> +	long last_diff = 0;
> +	long diff;
>  
>  	if (!inactive_reclaimable_pages(lruvec, sc, lru))
>  		return 0;
>  
> -	while (unlikely(too_many_isolated(pgdat, file, sc))) {
> +	while (unlikely((diff = too_many_isolated(pgdat, file, sc)) > 0)) {
> +		if (diff < last_diff) {
> +			wait_start = jiffies;
> +			wait_timeout = 10 * HZ;
> +		} else if (time_after(jiffies, wait_start + wait_timeout)) {
> +			warn_alloc(sc->gfp_mask,
> +				   "shrink_inactive_list() stalls for %ums",
> +				   jiffies_to_msecs(jiffies - wait_start));
> +			wait_timeout += 10 * HZ;
> +		}
> +		last_diff = diff;
>  		congestion_wait(BLK_RW_ASYNC, HZ/10);
>  
>  		/* We are about to die and free our memory. Return now. */
> ----------
[...]
> So, how can we make warn_alloc() reliable?

This is not about warn_alloc reliability but more about
too_many_isolated waiting for an unbounded amount of time. And that
should be fixed. I do not have a good idea how right now.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
