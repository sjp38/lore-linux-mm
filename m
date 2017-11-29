Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D31486B025E
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 12:05:53 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id o20so2282179wro.8
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 09:05:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w10si2058039edj.349.2017.11.29.09.05.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Nov 2017 09:05:52 -0800 (PST)
Date: Wed, 29 Nov 2017 18:05:51 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 05/11] writeback: convert the flexible prop stuff to
 bytes
Message-ID: <20171129170551.GE28256@quack2.suse.cz>
References: <1511385366-20329-1-git-send-email-josef@toxicpanda.com>
 <1511385366-20329-6-git-send-email-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511385366-20329-6-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Wed 22-11-17 16:16:00, Josef Bacik wrote:
> From: Josef Bacik <jbacik@fb.com>
> 
> The flexible proportions were all page based, but now that we are doing
> metadata writeout that can be smaller or larger than page size we need
> to account for this in bytes instead of number of pages.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  mm/page-writeback.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index e4563645749a..2a1994194cc1 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -574,11 +574,11 @@ static unsigned long wp_next_time(unsigned long cur_time)
>  	return cur_time;
>  }
>  
> -static void wb_domain_writeout_inc(struct wb_domain *dom,
> +static void wb_domain_writeout_add(struct wb_domain *dom,
>  				   struct fprop_local_percpu *completions,
> -				   unsigned int max_prop_frac)
> +				   long bytes, unsigned int max_prop_frac)
>  {
> -	__fprop_inc_percpu_max(&dom->completions, completions,
> +	__fprop_add_percpu_max(&dom->completions, completions, bytes,
>  			       max_prop_frac);
>  	/* First event after period switching was turned off? */
>  	if (unlikely(!dom->period_time)) {
> @@ -602,12 +602,12 @@ static inline void __wb_writeout_add(struct bdi_writeback *wb, long bytes)
>  	struct wb_domain *cgdom;
>  
>  	__add_wb_stat(wb, WB_WRITTEN_BYTES, bytes);
> -	wb_domain_writeout_inc(&global_wb_domain, &wb->completions,
> +	wb_domain_writeout_add(&global_wb_domain, &wb->completions, bytes,
>  			       wb->bdi->max_prop_frac);
>  
>  	cgdom = mem_cgroup_wb_domain(wb);
>  	if (cgdom)
> -		wb_domain_writeout_inc(cgdom, wb_memcg_completions(wb),
> +		wb_domain_writeout_add(cgdom, wb_memcg_completions(wb), bytes,
>  				       wb->bdi->max_prop_frac);
>  }
>  
> -- 
> 2.7.5
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
