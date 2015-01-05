Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 528BF6B0032
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 10:28:17 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id i8so15781705qcq.11
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 07:28:17 -0800 (PST)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id a1si60673954qar.108.2015.01.05.07.28.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 05 Jan 2015 07:28:16 -0800 (PST)
Date: Mon, 5 Jan 2015 09:28:14 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 6/6] mm/slab: allocation fastpath without disabling irq
In-Reply-To: <1420421851-3281-7-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.11.1501050859520.24213@gentwo.org>
References: <1420421851-3281-1-git-send-email-iamjoonsoo.kim@lge.com> <1420421851-3281-7-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

On Mon, 5 Jan 2015, Joonsoo Kim wrote:

> index 449fc6b..54656f0 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -168,6 +168,41 @@ typedef unsigned short freelist_idx_t;
>
>  #define SLAB_OBJ_MAX_NUM ((1 << sizeof(freelist_idx_t) * BITS_PER_BYTE) - 1)
>
> +#ifdef CONFIG_PREEMPT
> +/*
> + * Calculate the next globally unique transaction for disambiguiation
> + * during cmpxchg. The transactions start with the cpu number and are then
> + * incremented by CONFIG_NR_CPUS.
> + */
> +#define TID_STEP  roundup_pow_of_two(CONFIG_NR_CPUS)
> +#else
> +/*
> + * No preemption supported therefore also no need to check for
> + * different cpus.
> + */
> +#define TID_STEP 1
> +#endif
> +
> +static inline unsigned long next_tid(unsigned long tid)
> +{
> +	return tid + TID_STEP;
> +}
> +
> +static inline unsigned int tid_to_cpu(unsigned long tid)
> +{
> +	return tid % TID_STEP;
> +}
> +
> +static inline unsigned long tid_to_event(unsigned long tid)
> +{
> +	return tid / TID_STEP;
> +}
> +
> +static inline unsigned int init_tid(int cpu)
> +{
> +	return cpu;
> +}
> +

Ok the above stuff needs to go into the common code. Maybe in mm/slab.h?
And its a significant feature contributed by me so I'd like to have an
attribution here.

>  /*
>   * true if a page was allocated from pfmemalloc reserves for network-based
>   * swap
> @@ -187,7 +222,8 @@ static bool pfmemalloc_active __read_mostly;
>   *
>   */
>  struct array_cache {
> -	unsigned int avail;
> +	unsigned long avail;
> +	unsigned long tid;
>  	unsigned int limit;
>  	unsigned int batchcount;
>  	unsigned int touched;
> @@ -657,7 +693,8 @@ static void start_cpu_timer(int cpu)
>  	}
>  }

This increases the per cpu struct size and should lead to a small
performance penalty.

> -	 */
> -	if (likely(objp)) {
> -		STATS_INC_ALLOCHIT(cachep);
> -		goto out;
> +	objp = ac->entry[avail - 1];
> +	if (unlikely(!this_cpu_cmpxchg_double(
> +		cachep->cpu_cache->avail, cachep->cpu_cache->tid,
> +		avail, tid,
> +		avail - 1, next_tid(tid))))
> +		goto redo;


Hmm... Ok that looks good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
