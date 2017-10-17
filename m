Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 622B76B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 05:44:49 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r6so968744pfj.14
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 02:44:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b12si5855555plr.486.2017.10.17.02.44.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 02:44:48 -0700 (PDT)
Date: Tue, 17 Oct 2017 11:44:46 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] writeback: Convert timers to use timer_setup()
Message-ID: <20171017094446.GO9762@quack2.suse.cz>
References: <20171016225913.GA99214@beast>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171016225913.GA99214@beast>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Matthew Wilcox <mawilcox@microsoft.com>, Jeff Layton <jlayton@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 16-10-17 15:59:13, Kees Cook wrote:
> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Matthew Wilcox <mawilcox@microsoft.com>
> Cc: Jeff Layton <jlayton@redhat.com>
> Cc: linux-mm@kvack.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

The patch looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  mm/page-writeback.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 94854e243b11..65ba42c7c7da 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -628,9 +628,9 @@ EXPORT_SYMBOL_GPL(wb_writeout_inc);
>   * On idle system, we can be called long after we scheduled because we use
>   * deferred timers so count with missed periods.
>   */
> -static void writeout_period(unsigned long t)
> +static void writeout_period(struct timer_list *t)
>  {
> -	struct wb_domain *dom = (void *)t;
> +	struct wb_domain *dom = from_timer(dom, t, period_timer);
>  	int miss_periods = (jiffies - dom->period_time) /
>  						 VM_COMPLETIONS_PERIOD_LEN;
>  
> @@ -653,8 +653,7 @@ int wb_domain_init(struct wb_domain *dom, gfp_t gfp)
>  
>  	spin_lock_init(&dom->lock);
>  
> -	setup_deferrable_timer(&dom->period_timer, writeout_period,
> -			       (unsigned long)dom);
> +	timer_setup(&dom->period_timer, writeout_period, TIMER_DEFERRABLE);
>  
>  	dom->dirty_limit_tstamp = jiffies;
>  
> -- 
> 2.7.4
> 
> 
> -- 
> Kees Cook
> Pixel Security
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
