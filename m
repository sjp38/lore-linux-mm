Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 822A72808A4
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 10:27:23 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m7so3731878pga.8
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 07:27:23 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30131.outbound.protection.outlook.com. [40.107.3.131])
        by mx.google.com with ESMTPS id y94si3049213plh.826.2017.08.24.07.27.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 24 Aug 2017 07:27:22 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm: use sc->priority for slab shrink targets
References: <1503430539-2878-1-git-send-email-jbacik@fb.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <a6a68b0b-4138-2563-fa53-ad8406dc6e34@virtuozzo.com>
Date: Thu, 24 Aug 2017 17:29:59 +0300
MIME-Version: 1.0
In-Reply-To: <1503430539-2878-1-git-send-email-jbacik@fb.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: josef@toxicpanda.com, minchan@kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, kernel-team@fb.com
Cc: Josef Bacik <jbacik@fb.com>



On 08/22/2017 10:35 PM, josef@toxicpanda.com wrote:
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -306,9 +306,7 @@ EXPORT_SYMBOL(unregister_shrinker);
>  #define SHRINK_BATCH 128
>  
>  static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
> -				    struct shrinker *shrinker,
> -				    unsigned long nr_scanned,
> -				    unsigned long nr_eligible)
> +				    struct shrinker *shrinker, int priority)
>  {
>  	unsigned long freed = 0;
>  	unsigned long long delta;
> @@ -333,9 +331,8 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>  	nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
>  
>  	total_scan = nr;
> -	delta = (4 * nr_scanned) / shrinker->seeks;
> -	delta *= freeable;
> -	do_div(delta, nr_eligible + 1);
> +	delta = freeable >> priority;
> +	delta = (4 * freeable) / shrinker->seeks;

Something is wrong. The first line does nothing.


>  	total_scan += delta;
>  	if (total_scan < 0) {
>  		pr_err("shrink_slab: %pF negative objects to delete nr=%ld\n",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
