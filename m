Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id AADEE6B0038
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 03:47:21 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id c123so15584130pga.17
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 00:47:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q17si12736234pgt.617.2017.11.22.00.47.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 00:47:19 -0800 (PST)
Date: Wed, 22 Nov 2017 09:47:16 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 03/10] lib: add a batch size to fprop_global
Message-ID: <20171122084716.GA11233@quack2.suse.cz>
References: <1510696616-8489-1-git-send-email-josef@toxicpanda.com>
 <1510696616-8489-3-git-send-email-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1510696616-8489-3-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Tue 14-11-17 16:56:49, Josef Bacik wrote:
> From: Josef Bacik <jbacik@fb.com>
> 
> The flexible proportion stuff has been used to track how many pages we
> are writing out over a period of time, so counts everything in single
> increments.  If we wanted to use another base value we need to be able
> to adjust the batch size to fit our the units we'll be using for the
> proportions.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>

Frankly, I had to look into the code to understand what the patch is about.
Can we rephrase the changelog like:

Currently flexible proportion code is using fixed per-cpu counter batch size
since all the counters use only increment / decrement to track number of
pages which completed writeback. When we start tracking amount of done
writeback in different units, we need to update per-cpu counter batch size
accordingly. Make counter batch size configurable on a per-proportion
domain basis to allow for this.

								Honza
> ---
>  include/linux/flex_proportions.h |  4 +++-
>  lib/flex_proportions.c           | 11 +++++------
>  2 files changed, 8 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/flex_proportions.h b/include/linux/flex_proportions.h
> index 0d348e011a6e..853f4305d1b2 100644
> --- a/include/linux/flex_proportions.h
> +++ b/include/linux/flex_proportions.h
> @@ -20,7 +20,7 @@
>   */
>  #define FPROP_FRAC_SHIFT 10
>  #define FPROP_FRAC_BASE (1UL << FPROP_FRAC_SHIFT)
> -
> +#define FPROP_BATCH_SIZE (8*(1+ilog2(nr_cpu_ids)))
>  /*
>   * ---- Global proportion definitions ----
>   */
> @@ -31,6 +31,8 @@ struct fprop_global {
>  	unsigned int period;
>  	/* Synchronization with period transitions */
>  	seqcount_t sequence;
> +	/* batch size */
> +	s32 batch_size;
>  };
>  
>  int fprop_global_init(struct fprop_global *p, gfp_t gfp);
> diff --git a/lib/flex_proportions.c b/lib/flex_proportions.c
> index 2cc1f94e03a1..5552523b663a 100644
> --- a/lib/flex_proportions.c
> +++ b/lib/flex_proportions.c
> @@ -44,6 +44,7 @@ int fprop_global_init(struct fprop_global *p, gfp_t gfp)
>  	if (err)
>  		return err;
>  	seqcount_init(&p->sequence);
> +	p->batch_size = FPROP_BATCH_SIZE;
>  	return 0;
>  }
>  
> @@ -166,8 +167,6 @@ void fprop_fraction_single(struct fprop_global *p,
>  /*
>   * ---- PERCPU ----
>   */
> -#define PROP_BATCH (8*(1+ilog2(nr_cpu_ids)))
> -
>  int fprop_local_init_percpu(struct fprop_local_percpu *pl, gfp_t gfp)
>  {
>  	int err;
> @@ -204,11 +203,11 @@ static void fprop_reflect_period_percpu(struct fprop_global *p,
>  	if (period - pl->period < BITS_PER_LONG) {
>  		s64 val = percpu_counter_read(&pl->events);
>  
> -		if (val < (nr_cpu_ids * PROP_BATCH))
> +		if (val < (nr_cpu_ids * p->batch_size))
>  			val = percpu_counter_sum(&pl->events);
>  
>  		percpu_counter_add_batch(&pl->events,
> -			-val + (val >> (period-pl->period)), PROP_BATCH);
> +			-val + (val >> (period-pl->period)), p->batch_size);
>  	} else
>  		percpu_counter_set(&pl->events, 0);
>  	pl->period = period;
> @@ -219,7 +218,7 @@ static void fprop_reflect_period_percpu(struct fprop_global *p,
>  void __fprop_inc_percpu(struct fprop_global *p, struct fprop_local_percpu *pl)
>  {
>  	fprop_reflect_period_percpu(p, pl);
> -	percpu_counter_add_batch(&pl->events, 1, PROP_BATCH);
> +	percpu_counter_add_batch(&pl->events, 1, p->batch_size);
>  	percpu_counter_add(&p->events, 1);
>  }
>  
> @@ -267,6 +266,6 @@ void __fprop_inc_percpu_max(struct fprop_global *p,
>  			return;
>  	} else
>  		fprop_reflect_period_percpu(p, pl);
> -	percpu_counter_add_batch(&pl->events, 1, PROP_BATCH);
> +	percpu_counter_add_batch(&pl->events, 1, p->batch_size);
>  	percpu_counter_add(&p->events, 1);
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
