Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 88F2E6B0253
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 12:05:12 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id i71so1678533wmd.9
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 09:05:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b5si1862260edc.123.2017.11.29.09.05.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Nov 2017 09:05:11 -0800 (PST)
Date: Wed, 29 Nov 2017 18:05:10 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 04/11] lib: add a __fprop_add_percpu_max
Message-ID: <20171129170510.GD28256@quack2.suse.cz>
References: <1511385366-20329-1-git-send-email-josef@toxicpanda.com>
 <1511385366-20329-5-git-send-email-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511385366-20329-5-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Wed 22-11-17 16:15:59, Josef Bacik wrote:
> From: Josef Bacik <jbacik@fb.com>
> 
> This helper allows us to add an arbitrary amount to the fprop
> structures.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/linux/flex_proportions.h | 11 +++++++++--
>  lib/flex_proportions.c           |  9 +++++----
>  2 files changed, 14 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/flex_proportions.h b/include/linux/flex_proportions.h
> index 0d348e011a6e..9f88684bf0a0 100644
> --- a/include/linux/flex_proportions.h
> +++ b/include/linux/flex_proportions.h
> @@ -83,8 +83,8 @@ struct fprop_local_percpu {
>  int fprop_local_init_percpu(struct fprop_local_percpu *pl, gfp_t gfp);
>  void fprop_local_destroy_percpu(struct fprop_local_percpu *pl);
>  void __fprop_inc_percpu(struct fprop_global *p, struct fprop_local_percpu *pl);
> -void __fprop_inc_percpu_max(struct fprop_global *p, struct fprop_local_percpu *pl,
> -			    int max_frac);
> +void __fprop_add_percpu_max(struct fprop_global *p, struct fprop_local_percpu *pl,
> +			    unsigned long nr, int max_frac);
>  void fprop_fraction_percpu(struct fprop_global *p,
>  	struct fprop_local_percpu *pl, unsigned long *numerator,
>  	unsigned long *denominator);
> @@ -99,4 +99,11 @@ void fprop_inc_percpu(struct fprop_global *p, struct fprop_local_percpu *pl)
>  	local_irq_restore(flags);
>  }
>  
> +static inline
> +void __fprop_inc_percpu_max(struct fprop_global *p,
> +			    struct fprop_local_percpu *pl, int max_frac)
> +{
> +	__fprop_add_percpu_max(p, pl, 1, max_frac);
> +}
> +
>  #endif
> diff --git a/lib/flex_proportions.c b/lib/flex_proportions.c
> index b0343ae71f5e..fd95791a2c93 100644
> --- a/lib/flex_proportions.c
> +++ b/lib/flex_proportions.c
> @@ -255,8 +255,9 @@ void fprop_fraction_percpu(struct fprop_global *p,
>   * Like __fprop_inc_percpu() except that event is counted only if the given
>   * type has fraction smaller than @max_frac/FPROP_FRAC_BASE
>   */
> -void __fprop_inc_percpu_max(struct fprop_global *p,
> -			    struct fprop_local_percpu *pl, int max_frac)
> +void __fprop_add_percpu_max(struct fprop_global *p,
> +			    struct fprop_local_percpu *pl, unsigned long nr,
> +			    int max_frac)
>  {
>  	if (unlikely(max_frac < FPROP_FRAC_BASE)) {
>  		unsigned long numerator, denominator;
> @@ -267,6 +268,6 @@ void __fprop_inc_percpu_max(struct fprop_global *p,
>  			return;
>  	} else
>  		fprop_reflect_period_percpu(p, pl);
> -	percpu_counter_add_batch(&pl->events, 1, PROP_BATCH);
> -	percpu_counter_add(&p->events, 1);
> +	percpu_counter_add_batch(&pl->events, nr, PROP_BATCH);
> +	percpu_counter_add(&p->events, nr);
>  }
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
